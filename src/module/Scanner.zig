//! Bus scanner. Facilitates gathering information about the subdevices
//! on the bus without prior configuratiion.
const std = @import("std");
const Timer = std.time.Timer;
const ns_per_us = std.time.ns_per_us;

const ENI = @import("ENI.zig");
const esc = @import("esc.zig");
const gcat = @import("root.zig");
const logger = @import("root.zig").logger;
const coe = @import("mailbox/coe.zig");
const MainDevice = @import("MainDevice.zig");
const nic = @import("nic.zig");
const pdi = @import("pdi.zig");
const Port = @import("Port.zig");
const sii = @import("sii.zig");
const Subdevice = @import("Subdevice.zig");
const wire = @import("wire.zig");

const Scanner = @This();

port: *Port,
settings: MainDevice.Settings,

pub fn init(port: *Port, settings: MainDevice.Settings) Scanner {
    return Scanner{
        .port = port,
        .settings = settings,
    };
}

pub fn countSubdevices(self: *const Scanner) !u16 {
    // count subdevices
    const res = try self.port.brdPack(
        esc.ALStatusRegister,
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(esc.RegisterMap.AL_status),
        },
        self.settings.recv_timeout_us,
    );
    return res.wkc;
}

pub fn busInit(self: *const Scanner, state_change_timeout_us: u32, subdevice_count: u16) !void {

    // open all ports
    try self.port.bwrPackWkc(
        esc.DLControlRegisterCompact{
            .forwarding_rule = true, // destroy non-ecat frames
            .temporary_loop_control = false, // permanent settings
            .loop_control_port0 = .auto,
            .loop_control_port1 = .auto,
            .loop_control_port2 = .auto,
            .loop_control_port3 = .auto,
        },
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(esc.RegisterMap.DL_control),
        },
        self.settings.recv_timeout_us,
        subdevice_count,
    );

    // TODO: set IRQ mask

    // reset CRC counters
    try self.port.bwrPackWkc(
        // a write to any one of these counters will reset them all,
        // but I am too lazt to do it any differently.
        esc.RXErrorCounterRegister{
            .port0_frame_errors = 0,
            .port0_physical_errors = 0,
            .port1_frame_errors = 0,
            .port1_physical_errors = 0,
            .port2_frame_errors = 0,
            .port2_physical_errors = 0,
            .port3_frame_errors = 0,
            .port3_physical_errors = 0,
        },
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(
                esc.RegisterMap.rx_error_counter,
            ),
        },
        self.settings.recv_timeout_us,
        subdevice_count,
    );

    // reset FMMUs
    try self.port.bwrPackWkc(
        std.mem.zeroes(esc.FMMURegister),
        .{ .autoinc_address = 0, .offset = @intFromEnum(esc.RegisterMap.FMMU0) },
        self.settings.recv_timeout_us,
        subdevice_count,
    );

    // reset SMs
    try self.port.bwrPackWkc(
        std.mem.zeroes(esc.SMRegister),
        .{ .autoinc_address = 0, .offset = @intFromEnum(esc.RegisterMap.SM0) },
        self.settings.recv_timeout_us,
        subdevice_count,
    );

    // TODO: reset DC activation
    // TODO: reset system time offsets
    // TODO: DC speedstart
    // TODO: DC filter

    // disable alias address
    try self.port.bwrPackWkc(
        esc.DLControlEnableAliasAddressRegister{
            .enable_alias_address = false,
        },
        .{ .autoinc_address = 0, .offset = @intFromEnum(esc.RegisterMap.DL_control_enable_alias_address) },
        self.settings.recv_timeout_us,
        subdevice_count,
    );

    // request INIT
    try self.port.bwrPackWkc(
        esc.ALControlRegister{
            .state = .INIT,

            // Ack errors not required for init transition.
            // Simple subdevices will copy the ack flag directly to the
            // error flag in the AL Status register.
            // Complex devices will not.
            //
            // Ref: IEC 61158-6-12:2019 6.4.1.1
            .ack = false,
            .request_id = false,
        },
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(esc.RegisterMap.AL_control),
        },
        self.settings.recv_timeout_us,
        subdevice_count,
    );

    // Force take away EEPROM from PDI
    try self.port.bwrPackWkc(
        esc.SIIAccessRegisterCompact{
            .owner = .ethercat_DL,
            .lock = true,
        },
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(esc.RegisterMap.SII_access),
        },
        self.settings.recv_timeout_us,
        subdevice_count,
    );

    // Maindevice controls EEPROM
    try self.port.bwrPackWkc(
        esc.SIIAccessRegisterCompact{
            .owner = .ethercat_DL,
            .lock = false,
        },
        .{
            .autoinc_address = 0,
            .offset = @intFromEnum(esc.RegisterMap.SII_access),
        },
        self.settings.recv_timeout_us,
        subdevice_count,
    );

    // command INIT on all subdevices, twice
    // SOEM does this...something about netX100
    for (0..1) |_| {
        self.port.bwrPackWkc(
            esc.ALControlRegister{
                .state = .INIT,
                .ack = false,
                .request_id = false,
            },
            .{
                .autoinc_address = 0,
                .offset = @intFromEnum(esc.RegisterMap.AL_control),
            },
            self.settings.recv_timeout_us,
            subdevice_count,
        ) catch |err| switch (err) {
            error.Wkc => continue, // this happens a lot
            else => |err_subset| return err_subset,
        };
    }

    try self.broadcastALStatusCheck(subdevice_count, .INIT, state_change_timeout_us);
}

pub fn subdevicePREOP(self: *Scanner, change_timeout_us: u32, ring_position: u16) !Subdevice {
    const station_address = Subdevice.stationAddressFromRingPos(@intCast(ring_position));
    const info = try sii.readSIIFP_ps(
        self.port,
        sii.SubdeviceInfoCompact,
        station_address,
        @intFromEnum(sii.ParameterMap.PDI_control),
        self.settings.recv_timeout_us,
        self.settings.eeprom_timeout_us,
    );

    var fake_process_data: [1]u8 = .{0};
    var subdevice = Subdevice.init(
        .{
            .identity = .{
                .vendor_id = info.vendor_id,
                .product_code = info.product_code,
                .revision_number = info.revision_number,
            },
            .auto_config = .auto,
        },
        @intCast(ring_position),
        .{
            .inputs = fake_process_data[0..0],
            .inputs_area = .{ .start_addr = 0, .bit_length = 0 },
            .outputs = fake_process_data[0..0],
            .outputs_area = .{ .start_addr = 0, .bit_length = 0 },
        },
    );
    try subdevice.transitionIP(
        self.port,
        self.settings.recv_timeout_us,
        self.settings.eeprom_timeout_us,
    );

    try subdevice.setALState(self.port, .PREOP, change_timeout_us, self.settings.recv_timeout_us);

    return subdevice;
}

pub fn readEni(
    self: *Scanner,
    allocator: std.mem.Allocator,
    state_change_timeout_us: u32,
    /// Read information for simulator.
    /// Not required unless you are running the simulator.
    sim: bool,
    pv_name_prefix: ?[]const u8,
) !gcat.Arena(ENI) {
    const arena = try allocator.create(std.heap.ArenaAllocator);
    errdefer allocator.destroy(arena);
    arena.* = .init(allocator);
    errdefer arena.deinit();
    return gcat.Arena(ENI){
        .arena = arena,
        .value = try self.readEniLeaky(
            arena.allocator(),
            state_change_timeout_us,
            sim,
            pv_name_prefix,
        ),
    };
}

/// This function leaks memory, it is the callers responsibilty to use an arena.
pub fn readEniLeaky(
    self: *Scanner,
    allocator: std.mem.Allocator,
    state_change_timeout_us: u32,
    sim: bool,
    pv_name_prefix: ?[]const u8,
) !ENI {
    var subdevice_configs = std.ArrayList(gcat.ENI.SubdeviceConfiguration).init(allocator);
    defer subdevice_configs.deinit();
    const num_subdevices = try self.countSubdevices();
    for (0..num_subdevices) |i| {
        const config = try self.readSubdeviceConfigurationLeaky(
            allocator,
            @intCast(i),
            state_change_timeout_us,
            sim,
            pv_name_prefix,
        );
        try subdevice_configs.append(config);
    }
    return gcat.ENI{ .subdevices = try subdevice_configs.toOwnedSlice() };
}

pub fn readSubdeviceConfiguration(
    self: *Scanner,
    allocator: std.mem.Allocator,
    ring_position: u16,
    state_change_timeout_us: u32,
    sim: bool,
    pv_name_prefix: ?[]const u8,
) !gcat.Arena(ENI.SubdeviceConfiguration) {
    const arena = try allocator.create(std.heap.ArenaAllocator);
    errdefer allocator.destroy(arena);
    arena.* = .init(allocator);
    errdefer arena.deinit();
    return gcat.Arena(ENI.SubdeviceConfiguration){
        .arena = arena,
        .value = try self.readSubdeviceConfigurationLeaky(
            arena.allocator(),
            ring_position,
            state_change_timeout_us,
            sim,
            pv_name_prefix,
        ),
    };
}

// TODO: this function is freaking massive.
/// This function leaks memory, it is the callers responsibilty to use an arena.
pub fn readSubdeviceConfigurationLeaky(
    self: *Scanner,
    allocator: std.mem.Allocator,
    ring_position: u16,
    state_change_timeout_us: u32,
    sim: bool,
    pv_name_prefix: ?[]const u8,
) !ENI.SubdeviceConfiguration {
    const station_address = Subdevice.stationAddressFromRingPos(ring_position);
    const info = try sii.readSIIFP_ps(
        self.port,
        sii.SubdeviceInfoCompact,
        station_address,
        @intFromEnum(sii.ParameterMap.PDI_control),
        self.settings.recv_timeout_us,
        self.settings.eeprom_timeout_us,
    );

    var name: []const u8 = "";
    if (try sii.readGeneralCatagory(
        self.port,
        station_address,
        self.settings.recv_timeout_us,
        self.settings.eeprom_timeout_us,
    )) |general| {
        const name_idx = general.order_idx;
        if (try sii.readSIIString(
            self.port,
            station_address,
            name_idx,
            self.settings.recv_timeout_us,
            self.settings.eeprom_timeout_us,
        )) |sii_name| {
            name = try allocator.dupe(u8, sii_name.slice());
        }
    }

    var inputs = std.ArrayList(ENI.SubdeviceConfiguration.PDO).init(allocator);
    defer inputs.deinit();
    var outputs = std.ArrayList(ENI.SubdeviceConfiguration.PDO).init(allocator);
    defer outputs.deinit();

    var fake_process_data: [1]u8 = .{0};
    var subdevice = Subdevice.init(
        .{
            .identity = .{
                .vendor_id = info.vendor_id,
                .product_code = info.product_code,
                .revision_number = info.revision_number,
            },
            .auto_config = .auto,
        },
        @intCast(ring_position),
        .{
            .inputs = fake_process_data[0..0],
            .inputs_area = .{ .start_addr = 0, .bit_length = 0 },
            .outputs = fake_process_data[0..0],
            .outputs_area = .{ .start_addr = 0, .bit_length = 0 },
        },
    );
    try subdevice.transitionIP(
        self.port,
        self.settings.recv_timeout_us,
        self.settings.eeprom_timeout_us,
    );
    try subdevice.setALState(self.port, .PREOP, state_change_timeout_us, self.settings.recv_timeout_us);

    // If the subdevices supports CoE, grab the PDOs from the CoE.

    if (subdevice.runtime_info.coe != null) {

        // 1. scan sync manager communication types => number of used sync managers
        // 2. scan each sync manager channel => mapped PDOs
        // 3. scan each PDO => profit

        // TODO: shift these APIs into the subdevice? The cnt is subdevice specific...

        const sm_comms = try gcat.mailbox.coe.readSMComms(
            self.port,
            station_address,
            self.settings.recv_timeout_us,
            self.settings.mbx_timeout_us,
            &subdevice.runtime_info.coe.?.cnt,
            subdevice.runtime_info.coe.?.config,
        );

        sm_comm_loop: for (sm_comms.slice(), 0..) |sm_comm_type, sm_idx| {
            switch (sm_comm_type) {
                .input, .output => {},
                .mailbox_in, .mailbox_out, .unused => continue :sm_comm_loop,
                _ => continue :sm_comm_loop,
            }
            const sm_pdo_assignment = try gcat.mailbox.coe.readSMChannel(
                self.port,
                station_address,
                self.settings.recv_timeout_us,
                self.settings.mbx_timeout_us,
                &subdevice.runtime_info.coe.?.cnt,
                subdevice.runtime_info.coe.?.config,
                @intCast(sm_idx),
            );
            for (sm_pdo_assignment.slice()) |pdo_index| {
                const pdo_mapping = try gcat.mailbox.coe.readPDOMapping(
                    self.port,
                    station_address,
                    self.settings.recv_timeout_us,
                    self.settings.mbx_timeout_us,
                    &subdevice.runtime_info.coe.?.cnt,
                    subdevice.runtime_info.coe.?.config,
                    pdo_index,
                );
                const object_description = try coe.readObjectDescription(
                    self.port,
                    station_address,
                    self.settings.recv_timeout_us,
                    self.settings.mbx_timeout_us,
                    &subdevice.runtime_info.coe.?.cnt,
                    subdevice.runtime_info.coe.?.config,
                    pdo_index,
                );

                var entries = std.ArrayList(ENI.SubdeviceConfiguration.PDO.Entry).init(allocator);
                defer entries.deinit();

                for (pdo_mapping.entries.slice()) |entry| {
                    if (entry.isGap()) {
                        try entries.append(ENI.SubdeviceConfiguration.PDO.Entry{
                            .description = null,
                            .index = 0,
                            .subindex = 0,
                            .bits = entry.bit_length,
                            .type = .UNKNOWN,
                        });
                    } else {
                        const entry_description = try coe.readEntryDescription(
                            self.port,
                            station_address,
                            self.settings.recv_timeout_us,
                            self.settings.mbx_timeout_us,
                            &subdevice.runtime_info.coe.?.cnt,
                            subdevice.runtime_info.coe.?.config,
                            entry.index,
                            entry.subindex,
                            .description_only,
                        );
                        var pv_name: ?[:0]const u8 = null;
                        var pv_name_fb: ?[:0]const u8 = null;
                        if (entry.index == 0 and entry.subindex == 0) {
                            pv_name = null;
                            pv_name_fb = null;
                        } else {
                            pv_name = try processVariableNameZ(
                                allocator,
                                ring_position,
                                if (sm_comm_type == .input) .input else .output,
                                entry.index,
                                entry.subindex,
                                name,
                                try allocator.dupeZ(u8, object_description.name.slice()),
                                try allocator.dupeZ(u8, entry_description.data.slice()),
                                pv_name_prefix,
                                false,
                            );
                            pv_name_fb = try processVariableNameZ(
                                allocator,
                                ring_position,
                                if (sm_comm_type == .input) .input else .output,
                                entry.index,
                                entry.subindex,
                                name,
                                try allocator.dupeZ(u8, object_description.name.slice()),
                                try allocator.dupeZ(u8, entry_description.data.slice()),
                                pv_name_prefix,
                                true,
                            );
                        }
                        try entries.append(ENI.SubdeviceConfiguration.PDO.Entry{
                            .description = try allocator.dupeZ(u8, entry_description.data.slice()),
                            .index = entry_description.index,
                            .subindex = entry_description.subindex,
                            // NOTE: entry description bit length sometimes differs from PDO mapping bit length.
                            // The entry description apparently reports the underlying data size, but the PDO mapping
                            // can be smaller.
                            // We trust the PDO mapping bit length. Example: EL7031-0030 0x1A00 vs 0x1A01 (16 vs 32 bit counters)
                            .bits = entry.bit_length,
                            // TODO: there is probably a bettter function for this
                            .type = std.meta.intToEnum(gcat.Exhaustive(coe.DataTypeArea), @as(u16, @intFromEnum(entry_description.data_type))) catch .UNKNOWN,
                            .pv_name = pv_name,
                            .pv_name_fb = pv_name_fb,
                        });
                    }
                }
                switch (sm_comm_type) {
                    .input => {
                        try inputs.append(
                            ENI.SubdeviceConfiguration.PDO{
                                .name = try allocator.dupeZ(u8, object_description.name.slice()),
                                .index = pdo_index,
                                .entries = try entries.toOwnedSlice(),
                            },
                        );
                    },
                    .output => {
                        try outputs.append(
                            ENI.SubdeviceConfiguration.PDO{
                                .name = try allocator.dupeZ(u8, object_description.name.slice()),
                                .index = pdo_index,
                                .entries = try entries.toOwnedSlice(),
                            },
                        );
                    },
                    .mailbox_in, .mailbox_out, .unused => unreachable,
                    _ => unreachable,
                }
            }
        }
    } else {
        const directions: []const pdi.Direction = &.{ .input, .output };
        for (directions) |direction| {
            const sii_pdos = try sii.readPDOs(
                self.port,
                station_address,
                direction,
                self.settings.recv_timeout_us,
                self.settings.eeprom_timeout_us,
            );

            const pdos: []const sii.PDO = sii_pdos.slice();

            for (pdos) |pdo| {
                var pdo_name: ?[:0]const u8 = null;
                if (try sii.readSIIString(
                    self.port,
                    station_address,
                    pdo.header.name_idx,
                    self.settings.recv_timeout_us,
                    self.settings.eeprom_timeout_us,
                )) |pdo_name_array| {
                    pdo_name = try allocator.dupeZ(u8, pdo_name_array.slice());
                }

                var entries = std.ArrayList(ENI.SubdeviceConfiguration.PDO.Entry).init(allocator);
                defer entries.deinit();

                const sii_entries: []const sii.PDO.Entry = pdo.entries.slice();
                for (sii_entries) |entry| {
                    var entry_name: ?[:0]const u8 = null;
                    if (try sii.readSIIString(
                        self.port,
                        station_address,
                        entry.name_idx,
                        self.settings.recv_timeout_us,
                        self.settings.eeprom_timeout_us,
                    )) |entry_name_array| {
                        entry_name = try allocator.dupeZ(u8, entry_name_array.slice());
                    }

                    var pv_name: ?[:0]const u8 = null;
                    var pv_name_fb: ?[:0]const u8 = null;
                    if (entry.index == 0 and entry.subindex == 0) {
                        pv_name = null;
                        pv_name_fb = null;
                    } else {
                        pv_name = try processVariableNameZ(
                            allocator,
                            ring_position,
                            direction,
                            entry.index,
                            entry.subindex,
                            name,
                            pdo_name orelse "",
                            entry_name orelse "",
                            pv_name_prefix,
                            false,
                        );
                        pv_name_fb = try processVariableNameZ(
                            allocator,
                            ring_position,
                            direction,
                            entry.index,
                            entry.subindex,
                            name,
                            pdo_name orelse "",
                            entry_name orelse "",
                            pv_name_prefix,
                            true,
                        );
                    }

                    try entries.append(ENI.SubdeviceConfiguration.PDO.Entry{
                        .index = entry.index,
                        .subindex = entry.subindex,
                        .bits = entry.bit_length,
                        .type = std.meta.intToEnum(gcat.Exhaustive(coe.DataTypeArea), entry.data_type) catch .UNKNOWN,
                        .description = entry_name,
                        .pv_name = pv_name,
                        .pv_name_fb = pv_name_fb,
                    });
                }

                switch (direction) {
                    .input => {
                        try inputs.append(
                            ENI.SubdeviceConfiguration.PDO{
                                .name = pdo_name orelse "",
                                .index = pdo.header.index,
                                .entries = try entries.toOwnedSlice(),
                            },
                        );
                    },
                    .output => {
                        try outputs.append(
                            ENI.SubdeviceConfiguration.PDO{
                                .name = pdo_name orelse "",
                                .index = pdo.header.index,
                                .entries = try entries.toOwnedSlice(),
                            },
                        );
                    },
                }
            }
        }
    }

    var sim_result: ?ENI.SubdeviceConfiguration.Sim = null;
    if (sim) {
        const eeprom_info = try gcat.sii.readSubdeviceInfo(
            self.port,
            station_address,
            self.settings.recv_timeout_us,
            self.settings.eeprom_timeout_us,
        );

        const sii_byte_length: u64 = (@as(u64, eeprom_info.size) + 1) * 1024 / 8;
        logger.info("stations addr: 0x{x:04}, Reading full eeprom size: {} B", .{ station_address, sii_byte_length });

        var sii_stream = gcat.sii.SIIStream.init(
            self.port,
            station_address,
            0,
            self.settings.recv_timeout_us,
            self.settings.eeprom_timeout_us,
        );

        const sii_reader = sii_stream.reader();
        var limited_reader = std.io.limitedReader(sii_reader, sii_byte_length);
        const reader = limited_reader.reader();

        const eeprom_content = try allocator.alloc(u8, sii_byte_length);
        try reader.readNoEof(eeprom_content);

        const physical_memory = try allocator.create([4096]u8);
        physical_memory.* = @splat(0);

        try self.readFullPhysicalMemory(ring_position, physical_memory);

        sim_result = .{
            .eeprom = eeprom_content,
            .physical_memory = physical_memory[0..],
        };
    }

    const res = ENI.SubdeviceConfiguration{
        .name = name,
        .identity = .{
            .vendor_id = info.vendor_id,
            .product_code = info.product_code,
            .revision_number = info.revision_number,
        },
        .inputs = try inputs.toOwnedSlice(),
        .outputs = try outputs.toOwnedSlice(),
        .sim = sim_result,
    };
    return res;
}

pub fn readFullPhysicalMemory(
    self: *Scanner,
    ring_position: u16,
    out: *[4096]u8,
) !void {
    for (0..4) |i| {
        const start: usize = i * 1024;
        const end: usize = (i + 1) * 1024;
        try self.port.fprdWkc(
            .{ .station_address = Subdevice.stationAddressFromRingPos(ring_position), .offset = 0 },
            out[start..end],
            self.settings.recv_timeout_us,
            1,
        );
    }
}

pub const process_variable_fmt = "subdevices/{}/{s}/{s}/0x{x:04}/{s}/0x{x:02}/{s}";

/// Produces a unique process image variable name.
pub fn processVariableNameZ(
    allocator: std.mem.Allocator,
    ring_position: u16,
    direction: pdi.Direction,
    pdo_idx: u16,
    entry_idx: u16,
    subdevice_name: []const u8,
    pdo_name: []const u8,
    entry_description: []const u8,
    maybe_prefix: ?[]const u8,
    comptime is_fb: bool,
) error{OutOfMemory}![:0]const u8 {
    const direction_str: []const u8 = if (direction == .input) "inputs" else "outputs";
    var name: [:0]const u8 = undefined;
    const fb_prefix_fmt = if (is_fb) "maindevice/pdi/" else "";
    if (maybe_prefix) |prefix| {
        name = try std.fmt.allocPrintZ(allocator, "{s}/" ++ fb_prefix_fmt ++ process_variable_fmt, .{
            prefix,
            ring_position,
            zenohSanitize(try allocator.dupe(u8, subdevice_name)),
            direction_str,
            pdo_idx,
            zenohSanitize(try allocator.dupe(u8, pdo_name)),
            entry_idx,
            zenohSanitize(try allocator.dupe(u8, entry_description)),
        });
    } else {
        name = try std.fmt.allocPrintZ(allocator, fb_prefix_fmt ++ process_variable_fmt, .{
            ring_position,
            zenohSanitize(try allocator.dupe(u8, subdevice_name)),
            direction_str,
            pdo_idx,
            zenohSanitize(try allocator.dupe(u8, pdo_name)),
            entry_idx,
            zenohSanitize(try allocator.dupe(u8, entry_description)),
        });
    }

    return name;
}

/// Sanitizes untrusted input in-place for inclusion into zenoh key expressions.
pub fn zenohSanitize(str: []u8) []u8 {
    // the encoding of strings in ethercat is IEC 8859-1,
    // lets just normalize to 7-bit ascii.
    for (str) |*char| {
        if (!std.ascii.isAscii(char.*)) {
            char.* = '_';
        }
    }
    // *, $, ?, # prohibited by zenoh
    // / is separator
    _ = std.mem.replace(u8, str, "*", "_", str);
    _ = std.mem.replace(u8, str, "$", "_", str);
    _ = std.mem.replace(u8, str, "?", "_", str);
    _ = std.mem.replace(u8, str, "#", "_", str);
    _ = std.mem.replace(u8, str, "/", "_", str);
    // no whitespace (personal preference)
    _ = std.mem.replace(u8, str, " ", "_", str);
    return str;
}

pub fn broadcastALStatusCheck(
    self: *const Scanner,
    subdevice_count: ?u16,
    state: esc.ALStateStatus,
    change_timeout_us: u32,
) !void {
    var timer = Timer.start() catch |err| switch (err) {
        error.TimerUnsupported => unreachable,
    };

    while (timer.read() < @as(u64, change_timeout_us) * ns_per_us) {
        const status_res = try self.port.brdPack(
            esc.ALStatusRegister,
            .{
                .autoinc_address = 0,
                .offset = @intFromEnum(esc.RegisterMap.AL_status),
            },
            self.settings.recv_timeout_us,
        );

        if (subdevice_count) |expected_wkc| {
            if (status_res.wkc != expected_wkc) return error.Wkc;
        }
        const status = status_res.ps;

        if (status.state == state) {
            return;
        }
        if (status.err) {
            logger.err("state change refused. status: {}", .{status});
            return error.StateChangeRefused;
        }
    } else {
        return error.StateChangeTimeout;
    }
    unreachable;
}

pub fn assignStationAddresses(self: *const Scanner, subdevice_count: u16) !void {
    for (0..subdevice_count) |i| {
        try MainDevice.assignStationAddress(self.port, Subdevice.stationAddressFromRingPos(@intCast(i)), @intCast(i), self.settings.recv_timeout_us);
    }
}
