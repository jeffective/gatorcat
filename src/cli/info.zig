//! The info subcommand of the GatorCAT CLI.
//!
//! Prints as much information about the subdevices as possible in markdown format.

const std = @import("std");
const gcat = @import("gatorcat");

pub const Args = struct {
    ifname: [:0]const u8,
    ring_position: ?u16 = null,
    recv_timeout_us: u32 = 10_000,
    eeprom_timeout_us: u32 = 100_000,
    INIT_timeout_us: u32 = 5_000_000,
    PREOP_timeout_us: u32 = 10_000_000,
    mbx_timeout_us: u32 = 50_000,
    pub const descriptions = .{
        .ifname = "Network interface to use for the bus scan.",
        .recv_timeout_us = "Frame receive timeout in microseconds.",
        .eeprom_timeout_us = "SII EEPROM timeout in microseconds.",
        .INIT_timeout_us = "state transition to INIT timeout in microseconds.",
        .ring_position = "Optionally specify only a single subdevice at this ring position to be scanned.",
    };
};

pub fn info(allocator: std.mem.Allocator, args: Args) !void {
    _ = allocator;
    var raw_socket = try gcat.nic.RawSocket.init(args.ifname);
    defer raw_socket.deinit();

    var port2 = gcat.Port.init(raw_socket.linkLayer(), .{});
    var port = &port2;
    defer port.deinit();
    try port.ping(args.recv_timeout_us);

    var scanner = gcat.Scanner.init(port, .{ .eeprom_timeout_us = args.eeprom_timeout_us, .recv_timeout_us = args.recv_timeout_us });
    var std_out = std.io.getStdOut();
    const writer = std_out.writer();

    const num_subdevices = try scanner.countSubdevices();
    std.log.warn("detected {} subdevices", .{num_subdevices});

    try scanner.busInit(args.INIT_timeout_us, num_subdevices);
    std.log.warn("bus reached INIT", .{});

    try scanner.assignStationAddresses(num_subdevices);
    std.log.warn("assigned station addresses", .{});

    try writer.print("# Bus Info\n\n", .{});
    try writer.print("```zon\n", .{});
    try std.zon.stringify.serialize(args, .{}, writer);
    try writer.print("\n", .{});
    try writer.print("```\n", .{});

    // summary table
    try writer.print("## Bus Summary\n\n", .{});
    try printBusSummaryTable(writer, port, args.recv_timeout_us, args.eeprom_timeout_us, num_subdevices);
    // detailed info on each subdevice
    if (args.ring_position) |position| {
        try printSubdeviceDetails(writer, port, args.recv_timeout_us, args.eeprom_timeout_us, @intCast(position));
        try printSubdeviceSIIPDOs(
            writer,
            port,
            args.recv_timeout_us,
            args.eeprom_timeout_us,
            gcat.Subdevice.stationAddressFromRingPos(@intCast(position)),
        );
        var subdevice = try scanner.subdevicePREOP(args.PREOP_timeout_us, position);
        try printSubdeviceCoePDOs(writer, port, args.recv_timeout_us, args.mbx_timeout_us, &subdevice);
    } else {
        for (0..num_subdevices) |i| {
            try printSubdeviceDetails(writer, port, args.recv_timeout_us, args.eeprom_timeout_us, @intCast(i));
            try printSubdeviceSIIPDOs(
                writer,
                port,
                args.recv_timeout_us,
                args.eeprom_timeout_us,
                gcat.Subdevice.stationAddressFromRingPos(@intCast(i)),
            );
            var subdevice = try scanner.subdevicePREOP(args.PREOP_timeout_us, @intCast(i));
            try printSubdeviceCoePDOs(writer, port, args.recv_timeout_us, args.mbx_timeout_us, &subdevice);
        }
    }
}

fn printBusSummaryTable(
    writer: anytype,
    port: *gcat.Port,
    recv_timeout_us: u32,
    eeprom_timeout_us: u32,
    num_subdevices: u16,
) !void {
    const columns: []const []const u8 = &.{
        "Ring Pos.",
        "Order ID",
        "Auto-incr. Addr.",
        "Station Addr.",
        "Vendor ID",
        "Product Code",
        "Revision Number",
    };

    for (columns) |column| {
        try writer.print("| {s}", .{column});
    }
    try writer.print(" |\n", .{});
    for (columns) |_| {
        try writer.print("|---", .{});
    }
    try writer.print("|\n", .{});
    for (0..num_subdevices) |i| {
        const ring_position: u16 = @intCast(i);
        const autoinc_address: u16 = gcat.Subdevice.autoincAddressFromRingPos(ring_position);
        const station_address: u16 = gcat.Subdevice.stationAddressFromRingPos(ring_position);

        const sub_info = try gcat.sii.readSubdeviceInfoCompact(
            port,
            station_address,
            recv_timeout_us,
            eeprom_timeout_us,
        );

        const cat_general = try gcat.sii.readGeneralCatagory(
            port,
            station_address,
            recv_timeout_us,
            eeprom_timeout_us,
        );

        var order_id: []const u8 = "";
        if (cat_general) |general| {
            const maybe_order_id_string = try gcat.sii.readSIIString(
                port,
                station_address,
                general.order_idx,
                recv_timeout_us,
                eeprom_timeout_us,
            );
            if (maybe_order_id_string) |order_id_string| {
                order_id = order_id_string.slice();
            }
        }
        try writer.print(
            "| {d:<5} | {s:<16} | 0x{x:04} | 0x{x:04} | 0x{x:08} | 0x{x:08} | 0x{x:08} |\n",
            .{ ring_position, order_id, autoinc_address, station_address, sub_info.vendor_id, sub_info.product_code, sub_info.revision_number },
        );
    }
    try writer.print("\n", .{});
}

fn printSubdeviceDetails(
    writer: anytype,
    port: *gcat.Port,
    recv_timeout_us: u32,
    eeprom_timeout_us: u32,
    ring_position: u16,
) !void {
    const autoinc_address: u16 = gcat.Subdevice.autoincAddressFromRingPos(ring_position);
    const station_address: u16 = gcat.Subdevice.stationAddressFromRingPos(ring_position);

    const sub_info = try gcat.sii.readSubdeviceInfoCompact(
        port,
        station_address,
        recv_timeout_us,
        eeprom_timeout_us,
    );

    const cat_general = try gcat.sii.readGeneralCatagory(
        port,
        station_address,
        recv_timeout_us,
        eeprom_timeout_us,
    );

    var name: []const u8 = "";
    var order_id: []const u8 = "";
    var group: []const u8 = "";
    if (cat_general) |general| {
        if (try gcat.sii.readSIIString(
            port,
            station_address,
            general.name_idx,
            recv_timeout_us,
            eeprom_timeout_us,
        )) |name_string| {
            name = name_string.slice();
        }
        if (try gcat.sii.readSIIString(
            port,
            station_address,
            general.order_idx,
            recv_timeout_us,
            eeprom_timeout_us,
        )) |order_id_string| {
            order_id = order_id_string.slice();
        }
        if (try gcat.sii.readSIIString(
            port,
            station_address,
            general.group_idx,
            recv_timeout_us,
            eeprom_timeout_us,
        )) |group_string| {
            group = group_string.slice();
        }
    }
    try writer.print("### Subdevice {d}(0x{x:04}): {s} \n\n", .{ ring_position, station_address, order_id });

    try writer.writeAll("#### Addressing\n\n");

    // position
    try writer.print("| Property               | Value  |\n", .{});
    try writer.print("|---                     |---     |\n", .{});
    try writer.print("| Ring position          | {d:>5}  |\n", .{ring_position});
    try writer.print("| Auto-increment address | 0x{x:04} |\n", .{autoinc_address});
    try writer.print("| Station address        | 0x{x:04} |\n", .{station_address});
    try writer.print("\n", .{});

    try writer.writeAll("#### Identity\n\n");

    try writer.print("| Property         | Value |\n", .{});
    try writer.print("|---               |---    |\n", .{});
    try writer.print("| Order ID         | {s} |\n", .{order_id});
    try writer.print("| Name             | {s} |\n", .{name});
    try writer.print("| Group            | {s} |\n", .{group});
    try writer.print("| Vendor ID        | 0x{x:08} |\n", .{sub_info.vendor_id});
    try writer.print("| Product code     | 0x{x:08} |\n", .{sub_info.product_code});
    try writer.print("| Revision number  | 0x{x:08} |\n", .{sub_info.revision_number});
    try writer.print("| Serial number    | 0x{x:08} |\n", .{sub_info.serial_number});
    try writer.print("\n", .{});

    try writer.writeAll("#### SII Mailbox Info\n\n");

    // supported protocols
    try writer.print("Supported mailbox protocols: ", .{});

    const has_mailbox = sub_info.mbx_protocol.AoE or
        sub_info.mbx_protocol.EoE or
        sub_info.mbx_protocol.CoE or
        sub_info.mbx_protocol.FoE or
        sub_info.mbx_protocol.SoE or
        sub_info.mbx_protocol.VoE;

    if (sub_info.mbx_protocol.AoE) try writer.print("AoE ", .{});
    if (sub_info.mbx_protocol.EoE) try writer.print("EoE ", .{});
    if (sub_info.mbx_protocol.CoE) try writer.print("CoE ", .{});
    if (sub_info.mbx_protocol.FoE) try writer.print("FoE ", .{});
    if (sub_info.mbx_protocol.SoE) try writer.print("SoE ", .{});
    if (sub_info.mbx_protocol.VoE) try writer.print("VoE ", .{});
    if (!has_mailbox) {
        try writer.print("None\n\n", .{});
    } else {
        try writer.print("\n", .{});
    }
    try writer.print("\n", .{});

    if (has_mailbox) {
        try writer.print("Default mailbox configuration:\n\n", .{});
        try writer.print(
            "    Mailbox out: offset: 0x{x:04} size: {}\n",
            .{ sub_info.std_recv_mbx_offset, sub_info.std_recv_mbx_size },
        );
        try writer.print(
            "    Mailbox in:  offset: 0x{x:04} size: {}\n",
            .{ sub_info.std_send_mbx_offset, sub_info.std_send_mbx_size },
        );
    }
    try writer.print("\n", .{});

    if (sub_info.mbx_protocol.FoE) {
        try writer.print("Bootstrap mailbox configuration:\n\n", .{});
        try writer.print(
            "    Mailbox out: offset: 0x{x:04} size: {}\n",
            .{ sub_info.bootstrap_recv_mbx_offset, sub_info.bootstrap_recv_mbx_size },
        );
        try writer.print(
            "    Mailbox in:  offset: 0x{x:04} size: {}\n",
            .{ sub_info.bootstrap_send_mbx_offset, sub_info.bootstrap_send_mbx_size },
        );
    }
    try writer.print("\n", .{});

    try writer.writeAll("#### SII Catagory: General\n\n");

    if (cat_general) |general| {
        try writer.print("| Property                               | Value |\n", .{});
        try writer.print("|---                                     |---    |\n", .{});
        if (sub_info.mbx_protocol.CoE) {
            inline for (std.meta.fields(gcat.sii.CoEDetails)) |field| {
                if (comptime std.mem.eql(u8, field.name, "reserved")) continue;
                try writer.print("| coe_details.{s:<26} | {:>5} |\n", .{ field.name, @field(general.coe_details, field.name) });
            }
        }
        if (sub_info.mbx_protocol.FoE) {
            inline for (std.meta.fields(gcat.sii.FoEDetails)) |field| {
                if (comptime std.mem.eql(u8, field.name, "reserved")) continue;
                try writer.print("| foe_details.{s:<26} | {:>5} |\n", .{ field.name, @field(general.foe_details, field.name) });
            }
        }
        if (sub_info.mbx_protocol.EoE) {
            inline for (std.meta.fields(gcat.sii.EoEDetails)) |field| {
                if (comptime std.mem.eql(u8, field.name, "reserved")) continue;
                try writer.print("| eoe_details.{s:<26} | {:>5} |\n", .{ field.name, @field(general.eoe_details, field.name) });
            }
        }
        // flags
        inline for (std.meta.fields(gcat.sii.Flags)) |field| {
            if (comptime std.mem.eql(u8, field.name, "reserved")) continue;
            try writer.print("| flags.{s:<32} | {:>5} |\n", .{ field.name, @field(general.flags, field.name) });
        }
        if (general.flags.identity_physical_memory) {
            try writer.print("| ID Switch Phys Mem Addr | 0x{x} |\n", .{general.physical_memory_address});
        }
    } else {
        try writer.writeAll("Catgory not present.\n\n");
    }
    try writer.writeAll("\n");

    try writer.writeAll("#### SII Catagory: Sync Managers\n\n");

    const sm_catagory = try gcat.sii.readSMCatagory(port, station_address, recv_timeout_us, eeprom_timeout_us);
    if (sm_catagory.len > 0) {
        for (sm_catagory.slice(), 0..) |sm, i| {
            try writer.print("##### SM{d}\n\n", .{i});
            try writer.print("    type: {s}\n", .{std.enums.tagName(gcat.sii.SyncMType, sm.syncM_type) orelse "INVALID"});
            try writer.print("    physical start addr: 0x{x}\n", .{sm.physical_start_address});
            try writer.print("    length: {}\n", .{sm.length});
            try writer.print("    control:\n", .{});
            inline for (std.meta.fields(gcat.esc.SyncManagerControlRegister)) |field| {
                if (comptime std.mem.eql(u8, field.name, "reserved")) continue;
                try writer.print("        {s:<26}  {:<5}\n", .{ field.name, @field(sm.control, field.name) });
            }
            try writer.print("    status:\n", .{});
            inline for (std.meta.fields(gcat.esc.SyncManagerActivateRegister)) |field| {
                if (comptime std.mem.eql(u8, field.name, "reserved")) continue;
                try writer.print("        {s:<26}  {:<5}\n", .{ field.name, @field(sm.status, field.name) });
            }
            try writer.print("    enable:\n", .{});
            inline for (std.meta.fields(gcat.sii.EnableSyncMangager)) |field| {
                if (comptime std.mem.eql(u8, field.name, "reserved")) continue;
                try writer.print("        {s:<26}  {:<5}\n", .{ field.name, @field(sm.enable_sync_manager, field.name) });
            }
            try writer.print("\n", .{});
        }
    } else {
        try writer.writeAll("No sync managers.\n\n");
    }

    try writer.print("\n", .{});
}

fn printSubdeviceSIIPDOs(
    writer: anytype,
    port: *gcat.Port,
    recv_timeout_us: u32,
    eeprom_timeout_us: u32,
    station_address: u16,
) !void {
    const input_pdos_bit_length = try gcat.sii.readPDOBitLengths(
        port,
        station_address,
        .input,
        recv_timeout_us,
        eeprom_timeout_us,
    );

    const output_pdos_bit_length = try gcat.sii.readPDOBitLengths(
        port,
        station_address,
        .output,
        recv_timeout_us,
        eeprom_timeout_us,
    );

    try writer.print("\n", .{});

    const input_pdos = try gcat.sii.readPDOs(
        port,
        station_address,
        .input,
        recv_timeout_us,
        eeprom_timeout_us,
    );

    const output_pdos = try gcat.sii.readPDOs(
        port,
        station_address,
        .output,
        recv_timeout_us,
        eeprom_timeout_us,
    );

    try writer.writeAll("#### SII Catagory: TxPDOs\n\n");

    if (input_pdos.len != 0) {
        try writer.print("    Inputs bit length: {d:<5}\n", .{input_pdos_bit_length});
        try printPDOTable(writer, input_pdos, port, station_address, recv_timeout_us, eeprom_timeout_us);
        try writer.print("\n", .{});
    } else {
        try writer.writeAll("No TxPDOs catagory.\n\n");
    }

    try writer.writeAll("#### SII Catagory: RxPDOs\n\n");

    if (output_pdos.len != 0) {
        try writer.print("    Outputs bit length: {d:<5}\n", .{output_pdos_bit_length});
        try printPDOTable(writer, output_pdos, port, station_address, recv_timeout_us, eeprom_timeout_us);
        try writer.print("\n", .{});
    } else {
        try writer.writeAll("No RxPDOs catagory.\n\n");
    }
}

fn printPDOTable(
    writer: anytype,
    pdos: gcat.sii.PDOs,
    port: *gcat.Port,
    station_address: u16,
    recv_timeout_us: u32,
    eeprom_timeout_us: u32,
) !void {
    const columns: []const []const u8 = &.{
        "PDO Index",
        "SM",
        "Mapped Index",
        "Bits",
        "Type",
        "Name",
    };

    for (columns) |column| {
        try writer.print("| {s}", .{column});
    }
    try writer.print(" |\n", .{});
    for (columns) |_| {
        try writer.print("|---", .{});
    }
    try writer.print("|\n", .{});

    const pdo_slice: []const gcat.sii.PDO = pdos.slice();

    for (pdo_slice) |pdo| {
        var pdo_name: []const u8 = "";
        const maybe_name = try gcat.sii.readSIIString(port, station_address, pdo.header.name_idx, recv_timeout_us, eeprom_timeout_us);
        if (maybe_name) |name| pdo_name = name.slice();
        var total_bit_length: u32 = 0;
        for (pdo.entries.slice()) |entry| {
            total_bit_length += entry.bit_length;
        }
        try writer.print("| 0x{x:04} | {d:>3} |           | {d:>3} |                  | {s:<26} |\n", .{ pdo.header.index, pdo.header.syncM, total_bit_length, pdo_name });

        const entries_slice: []const gcat.sii.PDO.Entry = pdo.entries.slice();
        for (entries_slice) |entry| {
            var entry_name: []const u8 = "";
            const maybe_name2 = try gcat.sii.readSIIString(port, station_address, entry.name_idx, recv_timeout_us, eeprom_timeout_us);
            if (maybe_name2) |name2| entry_name = name2.slice();
            try writer.print("|        |     | 0x{x:04}:{x:02} | {d:>3} | {s:<16} | {s:<26} |\n", .{
                entry.index,
                entry.subindex,
                entry.bit_length,
                std.enums.tagName(gcat.mailbox.coe.DataTypeArea, @enumFromInt(entry.data_type)) orelse "-",
                entry_name,
            });
        }
    }
}
fn printSubdeviceCoePDOs(
    writer: anytype,
    port: *gcat.Port,
    recv_timeout_us: u32,
    mbx_timeout_us: u32,
    subdevice: *gcat.Subdevice,
) !void {
    const coe_info = &(subdevice.runtime_info.coe orelse return);

    const station_address = gcat.Subdevice.stationAddressFromRingPos(subdevice.runtime_info.ring_position);
    const cnt = &coe_info.cnt;
    const mailbox_config = coe_info.config;

    const sm_comms = try gcat.mailbox.coe.readSMComms(port, station_address, recv_timeout_us, mbx_timeout_us, cnt, mailbox_config);

    try writer.writeAll("#### CoE: Sync Manager Communication Types\n\n");

    try writer.print("| SM  | Purpose          |\n", .{});
    try writer.print("|---  |---               |\n", .{});
    for (sm_comms.slice(), 0..) |sm_comm, sm_idx| {
        try writer.print("| {d:<3} | {s:<16} |\n", .{ sm_idx, std.enums.tagName(gcat.mailbox.coe.SMComm, sm_comm) orelse "Invalid SM Comm Type" });
    }
    try writer.print("\n", .{});

    try writer.writeAll("#### CoE: PDO Assignment\n\n");

    const columns: []const []const u8 = &.{
        "PDO Index",
        "SM",
        "Mapped Index",
        "Bits",
        "Type",
        "Name",
    };

    for (columns) |column| {
        try writer.print("| {s}", .{column});
    }
    try writer.print(" |\n", .{});
    for (columns) |_| {
        try writer.print("|---", .{});
    }
    try writer.print("|\n", .{});

    for (sm_comms.slice(), 0..) |sm_comm, sm_idx| {
        switch (sm_comm) {
            .input, .output => {},
            .mailbox_in, .mailbox_out, .unused => continue,
            _ => continue,
        }
        const sm_pdo_assignment = gcat.mailbox.coe.readSMChannel(port, station_address, recv_timeout_us, mbx_timeout_us, cnt, mailbox_config, @intCast(sm_idx)) catch |err| switch (err) {
            error.Aborted => continue,
            else => |err2| return err2,
        };

        for (sm_pdo_assignment.slice()) |pdo_index| {
            const pdo_mapping = try gcat.mailbox.coe.readPDOMapping(port, station_address, recv_timeout_us, mbx_timeout_us, cnt, mailbox_config, pdo_index);
            try writer.print("| 0x{x:04} | {d:>3} |           | {d:>3} |         | {s:<64}|\n", .{ pdo_index, sm_idx, pdo_mapping.bitLength(), @as([]const u8, &.{}) });
            for (pdo_mapping.entries.slice()) |entry| {
                if (entry.isGap()) {
                    try writer.print("|        |     |           | {d:>3} | PADDING | {s:<64}|\n", .{ entry.bit_length, @as([]const u8, &.{}) });
                } else {
                    const entry_description = gcat.mailbox.coe.readEntryDescription(
                        port,
                        station_address,
                        recv_timeout_us,
                        mbx_timeout_us,
                        cnt,
                        mailbox_config,
                        entry.index,
                        @intCast(entry.subindex),
                        .description_only,
                    ) catch |err| switch (err) {
                        error.ObjectDoesNotExist => {
                            std.log.err("station addr: 0x{x:04}, index: 0x{x:04}:{x:02} does not exist.", .{ station_address, entry.index, entry.subindex });
                            continue;
                        },
                        else => |err2| return err2,
                    };
                    try writer.print("|        |     | 0x{x:04}:{x:02} | {d:>3} |         | {s:<64}|\n", .{ entry.index, entry.subindex, entry.bit_length, entry_description.data.slice() });
                }
            }
        }
    }

    try writer.print("\n", .{});
    try writer.print("\n", .{});

    try writer.writeAll("#### CoE: Object Description Lists\n\n");

    try writer.print("| List                             | Length |\n", .{});
    try writer.print("|---                               |---     |\n", .{});

    const od_list_lengths = try gcat.mailbox.coe.readODListLengths(
        port,
        station_address,
        recv_timeout_us,
        mbx_timeout_us,
        cnt,
        mailbox_config,
    );
    inline for (std.meta.fields(gcat.mailbox.coe.ODListLengths)) |field| {
        try writer.print("| {s:<32} |  {:>5} |\n", .{ field.name, @field(od_list_lengths, field.name) });
    }
    try writer.print("\n", .{});

    const od_list_all = try gcat.mailbox.coe.readODList(
        port,
        station_address,
        recv_timeout_us,
        mbx_timeout_us,
        cnt,
        mailbox_config,
        .all_objects,
    );
    const od_list_rxpdo = try gcat.mailbox.coe.readODList(
        port,
        station_address,
        recv_timeout_us,
        mbx_timeout_us,
        cnt,
        mailbox_config,
        .rxpdo_mappable,
    );
    const od_list_txpdo = try gcat.mailbox.coe.readODList(
        port,
        station_address,
        recv_timeout_us,
        mbx_timeout_us,
        cnt,
        mailbox_config,
        .txpdo_mappable,
    );
    const od_list_stored = try gcat.mailbox.coe.readODList(
        port,
        station_address,
        recv_timeout_us,
        mbx_timeout_us,
        cnt,
        mailbox_config,
        .device_replacement_stored,
    );
    const od_list_start = try gcat.mailbox.coe.readODList(
        port,
        station_address,
        recv_timeout_us,
        mbx_timeout_us,
        cnt,
        mailbox_config,
        .startup_parameters,
    );

    const od_lists: [5]struct {
        heading: []const u8,
        list: []const u16,
    } = .{
        .{
            .heading = "#### CoE: Object Description List: All Objects\n\n",
            .list = od_list_all.slice(),
        },
        .{
            .heading = "#### CoE: Object Description List: RxPDO Mappable\n\n",
            .list = od_list_rxpdo.slice(),
        },
        .{
            .heading = "#### CoE: Object Description List: TxPDO Mappable\n\n",
            .list = od_list_txpdo.slice(),
        },
        .{
            .heading = "#### CoE: Object Description List: Stored for Device Replacement\n\n",
            .list = od_list_stored.slice(),
        },
        .{
            .heading = "#### CoE: Object Description List: Startup Parameters\n\n",
            .list = od_list_start.slice(),
        },
    };

    for (od_lists) |od_list| {
        try writer.writeAll(od_list.heading);

        const columns2: []const []const u8 = &.{
            "Index",
            "Max Subindex / Subindex",
            "Name",
            "Type",
        };

        for (columns2) |column| {
            try writer.print("| {s}", .{column});
        }
        try writer.print(" |\n", .{});
        for (columns2) |_| {
            try writer.print("|---", .{});
        }
        try writer.print("|\n", .{});

        for (od_list.list) |index| {
            const object_description = gcat.mailbox.coe.readObjectDescription(
                port,
                station_address,
                recv_timeout_us,
                mbx_timeout_us,
                cnt,
                mailbox_config,
                index,
            ) catch |err| switch (err) {
                error.ObjectDoesNotExist => continue,
                else => |err2| return err2,
            };

            try writer.print("| 0x{x}    | {x:02} | {s:<48} | {s:<16} |     |\n", .{ index, object_description.max_subindex, object_description.name.slice(), std.enums.tagName(gcat.mailbox.coe.DataTypeArea, object_description.data_type) orelse "INVALID" });

            for (1..@as(u9, object_description.max_subindex) + 1) |subindex| {
                const entry_description = gcat.mailbox.coe.readEntryDescription(
                    port,
                    station_address,
                    recv_timeout_us,
                    mbx_timeout_us,
                    cnt,
                    mailbox_config,
                    index,
                    @intCast(subindex),
                    .description_only,
                ) catch |err| switch (err) {
                    error.ObjectDoesNotExist => {
                        std.log.err("station addr: 0x{x:04}, index: 0x{x:04}:{x:02} does not exist.", .{ station_address, index, subindex });
                        continue;
                    },
                    else => |err2| return err2,
                };
                try writer.print("|           | {x:02} | {s:<48} | {s:<16} | {d:<3} |\n", .{ subindex, entry_description.data.slice(), std.enums.tagName(gcat.mailbox.coe.DataTypeArea, entry_description.data_type) orelse "INVALID", entry_description.bit_length });
            }
        }
        try writer.writeAll("\n");
    }

    // const mapping = try gcat.mailbox.coe.readPDOMapping(
    //     port,
    //     gcat.Subdevice.stationAddressFromRingPos(subdevice.runtime_info.ring_position),
    //     recv_timeout_us,
    //     mbx_timeout_us,
    //     &subdevice.runtime_info.coe.?.cnt,
    //     subdevice.runtime_info.coe.?.config,
    //     0x1600,
    // );
    // try writer.print("mapping: {}\n", .{mapping});
}
