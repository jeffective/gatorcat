// TODO: Reduce memory usage of the bounded arrays in this module.

const std = @import("std");
const Timer = std.time.Timer;
const ns_per_us = std.time.ns_per_us;
const assert = std.debug.assert;

const stdx = @import("../stdx.zig");

const mailbox = @import("../mailbox.zig");
const nic = @import("../nic.zig");
const Port = @import("../Port.zig");
const logger = @import("../root.zig").logger;
const sii = @import("../sii.zig");
const wire = @import("../wire.zig");
pub const client = @import("coe/client.zig");
pub const server = @import("coe/server.zig");

pub fn sdoWrite(
    port: *Port,
    station_address: u16,
    index: u16,
    subindex: u8,
    complete_access: bool,
    buf: []const u8,
    recv_timeout_us: u32,
    mbx_timeout_us: u32,
    cnt: u3,
    config: mailbox.Configuration,
) !void {
    assert(cnt != 0);
    if (complete_access) {
        assert(subindex == 1 or subindex == 0);
    }
    assert(buf.len > 0);
    assert(buf.len <= std.math.maxInt(u32));
    assert(config.isValid());

    const State = enum {
        start,
        send_expedited_request,
        send_normal_request,
        // send_first_segment,
        read_mbx,
        // read_mbx_first_segment,
    };

    state: switch (State.start) {
        .start => {
            if (buf.len < 5) continue :state .send_expedited_request;

            if (buf.len <= client.Normal.dataMaxSizeForMailbox(config.mbx_out.length)) {
                continue :state .send_normal_request;
            } else {
                return error.NotImplemented;
                // continue :state .send_first_segment;
            }
        },
        .send_expedited_request => {
            assert(buf.len < 5);

            const out_content = OutContent{ .expedited = client.Expedited.initDownloadRequest(
                cnt,
                index,
                subindex,
                complete_access,
                buf,
            ) };

            try mailbox.writeMailboxOut(
                port,
                station_address,
                recv_timeout_us,
                config.mbx_out,
                .{ .coe = out_content },
            );
            continue :state .read_mbx;
        },
        .send_normal_request => {
            assert(buf.len > 4);
            assert(buf.len <= client.Normal.dataMaxSizeForMailbox(config.mbx_out.length));

            const out_content = OutContent{ .normal = client.Normal.initDownloadRequest(
                cnt,
                index,
                subindex,
                complete_access,
                @intCast(buf.len),
                buf,
            ) };

            try mailbox.writeMailboxOut(
                port,
                station_address,
                recv_timeout_us,
                config.mbx_out,
                .{ .coe = out_content },
            );
            continue :state .read_mbx;
        },
        // .send_first_segment => {
        // assert(buf.size > 4);
        // const max_segment_size = client.normal.dataMaxSizeForMailbox(mbx_out_length);
        // assert(buf.size > max_segment_size);
        // assert(fbs.getPos() catch unreachable == 0);

        // const out_content = OutContent{ .normal = client.Normal.initDownloadRequest(
        //     cnt,
        //     index,
        //     subindex,
        //     complete_access,
        //     buf.size,
        //     buf[fbs.getPos() catch unreachable .. max_segment_size],
        // ) };
        // try mailbox.writeMailboxOut(
        //     port,
        //     station_address,
        //     recv_timeout_us,
        //     mbx_out_start_addr,
        //     mbx_out_length,
        //     .{ .coe = out_content },
        // );

        // fbs.seekBy(max_segment_size) catch unreachable;

        // continue :state .read_mbx_first_segment;
        // },
        .read_mbx => {
            const in_content = try mailbox.readMailboxInTimeout(
                port,
                station_address,
                recv_timeout_us,
                config.mbx_in,
                mbx_timeout_us,
            );

            if (in_content != .coe) {
                logger.err("station_addr: {} returned incorrect protocol during COE write at index: {}, subindex: {}", .{ station_address, index, subindex });
                return error.MisbehavingSubdevice;
            }
            switch (in_content.coe) {
                .abort => {
                    logger.err("station_addr: {} aborted COE write at index: {}, subindex: {}", .{ station_address, index, subindex });
                    return error.CoEAbort;
                },
                .segment => {
                    logger.err("station_addr: {} returned unexpected segment during COE write at index: {}, subindex: {}", .{ station_address, index, subindex });
                    return error.MisbehavingSubdevice;
                },
                .normal => {
                    logger.err("station_addr: {} returned unexpected normal during COE write at index: {}, subindex: {}", .{ station_address, index, subindex });
                    return error.MisbehavingSubdevice;
                },
                .emergency => {
                    logger.err("station_addr: {} returned emergency during COE write at index: {}, subindex: {}", .{ station_address, index, subindex });
                    return error.CoEEmergency;
                },
                .expedited => return,
                else => return error.MisbehavingSubdevice,
            }
        },
    }
}

pub const SDOReadPackError = error{
    MailboxTimeout,
    CoEAbort,
    CoEEmergency,
    NotImplemented,
    MisbehavingSubdevice,
} || Port.SendDatagramWkcError;

/// Read a packed type from an SDO.
pub fn sdoReadPack(
    port: *Port,
    station_address: u16,
    index: u16,
    subindex: u8,
    complete_access: bool,
    comptime packed_type: type,
    recv_timeout_us: u32,
    mbx_timeout_us: u32,
    cnt: u3,
    config: mailbox.Configuration,
) SDOReadPackError!packed_type {
    assert(config.isValid());

    var bytes = wire.zerosFromPack(packed_type);
    var writer = std.Io.Writer.fixed(&bytes);
    sdoRead(
        port,
        station_address,
        index,
        subindex,
        complete_access,
        &writer,
        recv_timeout_us,
        mbx_timeout_us,
        cnt,
        config,
    ) catch |err| switch (err) {
        error.WriteFailed => return error.MisbehavingSubdevice,
        error.LinkError,
        error.RecvTimeout,
        error.Wkc,
        error.MisbehavingSubdevice,
        error.MailboxTimeout,
        error.CoEAbort,
        error.CoEEmergency,
        error.NotImplemented,
        => |e| return e,
    };
    const n_bytes_read = writer.buffered().len;
    if (n_bytes_read != bytes.len) {
        logger.err("expected pack size: {}, got {}", .{ bytes.len, n_bytes_read });
        return error.MisbehavingSubdevice;
    }
    return wire.packFromECat(packed_type, bytes);
}

pub const SDOReadError = error{
    MisbehavingSubdevice,
    MailboxTimeout,
    CoEAbort,
    CoEEmergency,
    WriteFailed,
    NotImplemented,
} || Port.SendDatagramWkcError;

// TODO: support segmented reads
/// Read the SDO from the subdevice into a buffer.
///
/// Rather weirdly, it appears that complete access = true and subindex 0
/// will return two bytes for subindex 0, which is given type u8 in the
/// the beckhoff manuals.
/// You should probably just use complete access = true, subindex 1.
pub fn sdoRead(
    port: *Port,
    station_address: u16,
    index: u16,
    subindex: u8,
    complete_access: bool,
    writer: *std.Io.Writer,
    recv_timeout_us: u32,
    mbx_timeout_us: u32,
    cnt: u3,
    config: mailbox.Configuration,
) SDOReadError!void {
    assert(cnt != 0);
    if (complete_access) {
        assert(subindex == 1 or subindex == 0);
    }
    assert(config.isValid());

    var in_content: mailbox.InContent = undefined;
    const State = enum {
        send_read_request,
        read_mbx,
        expedited,
        normal,
        segment,
        request_segment,
        read_mbx_segment,
    };
    state: switch (State.send_read_request) {
        .send_read_request => {
            // The coding of a normal and expedited upload request is identical.
            // We issue and upload request and the server may respond with an
            // expedited, normal, or segmented response. The server will respond
            // with an expedited response if the data is less than 4 bytes,
            // a normal response if the data is more than 4 bytes and can fit into
            // a single mailbox, and a segmented response if the data is larger
            // than the mailbox.
            const request = mailbox.OutContent{
                .coe = OutContent{
                    .expedited = client.Expedited.initUploadRequest(
                        cnt,
                        index,
                        subindex,
                        complete_access,
                    ),
                },
            };
            try mailbox.writeMailboxOut(
                port,
                station_address,
                recv_timeout_us,
                config.mbx_out,
                request,
            );
            continue :state .read_mbx;
        },

        .read_mbx => {
            in_content = try mailbox.readMailboxInTimeout(
                port,
                station_address,
                recv_timeout_us,
                config.mbx_in,
                mbx_timeout_us,
            );

            if (in_content != .coe) {
                return error.MisbehavingSubdevice;
            }
            switch (in_content.coe) {
                .expedited => continue :state .expedited,
                .normal => continue :state .normal,
                .abort => {
                    logger.err("station addr: 0x{x}, aborted sdo read at index 0x{x}:{x}, code: {}", .{
                        station_address,
                        index,
                        subindex,
                        in_content.coe.abort.abort_code,
                    });
                    return error.CoEAbort;
                },
                .segment => return error.MisbehavingSubdevice,
                .emergency => return error.CoEEmergency,
                else => return error.MisbehavingSubdevice,
            }
        },
        .expedited => {
            assert(in_content == .coe);
            assert(in_content.coe == .expedited);
            try writer.writeAll(in_content.coe.expedited.data);
            return;
        },
        .normal => {
            assert(in_content == .coe);
            assert(in_content.coe == .normal);

            const data: []const u8 = in_content.coe.normal.data;
            try writer.writeAll(data);
            if (in_content.coe.normal.complete_size > data.len) {
                continue :state .request_segment;
            }
            return;
        },
        .request_segment => return error.NotImplemented,
        .segment => return error.NotImplemented,
        .read_mbx_segment => return error.NotImplemented,
    }
    unreachable;
}

/// Cnt session id for CoE
///
/// Ref: IEC 61158-6-12:2019 5.6.1
pub const Cnt = struct {
    // 0 reserved, next after 7 is 1
    cnt: u3 = 1,

    // TODO: atomics / thread safety
    pub fn nextCnt(self: *Cnt) u3 {
        const next_cnt: u3 = switch (self.cnt) {
            0 => unreachable,
            1 => 2,
            2 => 3,
            3 => 4,
            4 => 5,
            5 => 6,
            6 => 7,
            7 => 1,
        };
        assert(next_cnt != 0);
        self.cnt = next_cnt;
        return next_cnt;
    }
};

/// MailboxOut Content for CoE
pub const OutContent = union(enum) {
    expedited: client.Expedited,
    normal: client.Normal,
    segment: client.Segment,
    abort: client.Abort,
    get_entry_description_request: client.GetEntryDescriptionRequest,
    get_object_description_request: client.GetObjectDescriptionRequest,
    get_od_list_request: client.GetODListRequest,

    // TODO: implement remaining CoE content types

    pub fn serialize(self: OutContent, writer: *std.Io.Writer) !void {
        switch (self) {
            .expedited => return self.expedited.serialize(writer),
            .normal => return self.normal.serialize(writer),
            .segment => return self.segment.serialize(writer),
            .abort => return self.abort.serialize(writer),
            .get_entry_description_request => return self.get_entry_description_request.serialize(writer),
            .get_object_description_request => return self.get_object_description_request.serialize(writer),
            .get_od_list_request => return self.get_od_list_request.serialize(writer),
        }
    }
};

/// MailboxIn Content for CoE.
pub const InContent = union(enum) {
    expedited: server.Expedited,
    normal: server.Normal,
    segment: server.Segment,
    abort: server.Abort,
    emergency: server.Emergency,
    sdo_info_response: server.SDOInfoResponse,
    sdo_info_error: server.SDOInfoError,

    // TODO: implement remaining CoE content types

    pub fn deserialize(buf: []const u8) !InContent {
        switch (try identify(buf)) {
            .expedited => return InContent{ .expedited = server.Expedited.deserialize(buf) catch return error.InvalidMbxContent },
            .normal => return InContent{ .normal = server.Normal.deserialize(buf) catch return error.InvalidMbxContent },
            .segment => return InContent{ .segment = server.Segment.deserialize(buf) catch return error.InvalidMbxContent },
            .abort => return InContent{ .abort = server.Abort.deserialize(buf) catch return error.InvalidMbxContent },
            .emergency => return InContent{ .emergency = server.Emergency.deserialize(buf) catch return error.InvalidMbxContent },
            .sdo_info_response => return InContent{ .sdo_info_response = server.SDOInfoResponse.deserialize(buf) catch return error.InvalidMbxContent },
            .sdo_info_error => return InContent{ .sdo_info_error = server.SDOInfoError.deserialize(buf) catch return error.InvalidMbxContent },
        }
    }

    /// Identify what kind of CoE content is in MailboxIn
    fn identify(buf: []const u8) !std.meta.Tag(InContent) {
        var reader = std.Io.Reader.fixed(buf);
        const mbx_header = wire.packFromECatReader(mailbox.Header, &reader) catch return error.InvalidMbxContent;

        switch (mbx_header.type) {
            .CoE => {},
            else => return error.WrongMbxProtocol,
        }
        const header = wire.packFromECatReader(Header, &reader) catch return error.InvalidMbxContent;

        switch (header.service) {
            .tx_pdo => return error.NotImplemented,
            .rx_pdo => return error.NotImplemented,
            .tx_pdo_remote_request => return error.NotImplemented,
            .rx_pdo_remote_request => return error.NotImplemented,
            .sdo_info => {
                const sdo_info_header = wire.packFromECatReader(SDOInfoHeader, &reader) catch return error.InvalidMbxContent;
                return switch (sdo_info_header.opcode) {
                    .get_entry_description_response,
                    .get_object_description_response,
                    .get_od_list_response,
                    => .sdo_info_response,
                    .sdo_info_error_request => .sdo_info_error,
                    .get_entry_description_request, .get_object_description_request, .get_od_list_request => return error.InvalidMbxContent,
                    _ => return error.InvalidMbxContent,
                };
            },

            .sdo_request => {
                const sdo_header = wire.packFromECatReader(server.SDOHeader, &reader) catch return error.InvalidMbxContent;
                return switch (sdo_header.command) {
                    .abort_transfer_request => .abort,
                    else => error.InvalidMbxContent,
                };
            },
            .sdo_response => {
                const sdo_header = wire.packFromECatReader(server.SDOHeader, &reader) catch return error.InvalidMbxContent;
                switch (sdo_header.command) {
                    .upload_segment_response => return .segment,
                    .download_segment_response => return .segment,
                    .initiate_upload_response => switch (sdo_header.transfer_type) {
                        .normal => return .normal,
                        .expedited => return .expedited,
                    },
                    .initiate_download_response => return .expedited,
                    .abort_transfer_request => return .abort,
                    _ => return error.InvalidMbxContent,
                }
            },
            .emergency => return .emergency,
            _ => return error.InvalidMbxContent,
        }
    }
};

test "serialize deserialize mailbox in content" {
    const expected = InContent{
        .expedited = server.Expedited.initDownloadResponse(
            3,
            234,
            23,
            4,
            false,
        ),
    };

    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    var writer = std.Io.Writer.fixed(&bytes);
    try expected.expedited.serialize(&writer);
    const byte_size = writer.buffered().len;
    try std.testing.expectEqual(@as(usize, 6 + 2 + 8), byte_size);
    const actual = try InContent.deserialize(&bytes);
    try std.testing.expectEqualDeep(expected, actual);
}

test "serialize deserialize mailbox in content sdo info" {
    const expected = InContent{
        .sdo_info_error = .init(3, 23, .ToggleBitNotChanged),
    };

    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    var writer = std.Io.Writer.fixed(&bytes);
    try expected.sdo_info_error.serialize(&writer);
    const byte_size = writer.buffered().len;
    try std.testing.expectEqual(@as(usize, 6 + 2 + 4 + 4), byte_size);
    const actual = try InContent.deserialize(&bytes);
    try std.testing.expectEqualDeep(expected, actual);
}

pub const DataSetSize = enum(u2) {
    four_octets = 0x00,
    three_octets = 0x01,
    two_octets = 0x02,
    one_octet = 0x03,
};

pub const SegmentDataSize = enum(u3) {
    seven_octets = 0x00,
    six_octets = 0x01,
    five_octets = 0x02,
    four_octets = 0x03,
    three_octets = 0x04,
    two_octets = 0x05,
    one_octet = 0x06,
    zero_octets = 0x07,
};

/// CoE Services
///
/// Ref: IEC 61158-6-12:2019 5.6.1
pub const Service = enum(u4) {
    emergency = 0x01,
    sdo_request = 0x02,
    sdo_response = 0x03,
    tx_pdo = 0x04,
    rx_pdo = 0x05,
    tx_pdo_remote_request = 0x06,
    rx_pdo_remote_request = 0x07,
    sdo_info = 0x08,
    _,
};

pub const Header = packed struct(u16) {
    number: u9 = 0,
    reserved: u3 = 0,
    service: Service,
};

pub const TransferType = enum(u1) {
    normal = 0x00,
    expedited = 0x01,
};

/// SDO Info Op Codes
///
/// Ref: IEC 61158-6-12:2019 5.6.3.2
pub const SDOInfoOpCode = enum(u7) {
    get_od_list_request = 0x01,
    get_od_list_response = 0x02,
    get_object_description_request = 0x03,
    get_object_description_response = 0x04,
    get_entry_description_request = 0x05,
    get_entry_description_response = 0x06,
    sdo_info_error_request = 0x07,
    _,
};

/// SDO Info Header
///
/// Ref: IEC 61158-6-12:2019 5.6.3.2
pub const SDOInfoHeader = packed struct {
    opcode: SDOInfoOpCode,
    incomplete: bool,
    reserved: u8 = 0,
    fragments_left: u16,
};

/// OD List Types
///
/// Ref: IEC 61158-6-12:2019 5.6.3.3.1
pub const ODListType = enum(u16) {
    num_object_in_5_lists = 0x00,
    all_objects = 0x01,
    rxpdo_mappable = 0x02,
    txpdo_mappable = 0x03,
    device_replacement_stored = 0x04, // what does this mean?
    startup_parameters = 0x05,
    _,
};

/// Object Code
///
/// Ref: IEC 61158-6-12:2019 5.6.3.5.2
pub const ObjectCode = enum(u8) {
    variable = 7,
    array = 8,
    record = 9,
    _,
};

/// Value Info
///
/// What info about the value will be included in the response.
///
/// Of there is more data, the remaining data is a description (array of char).
///
/// Ref: IEC 61158-6-12:2019 5.6.3.6.1
pub const ValueInfo = packed struct(u8) {
    reserved: u3 = 0,
    unit_type: bool,
    default_value: bool,
    minimum_value: bool,
    maximum_value: bool,
    reserved2: u1 = 0,

    pub const description_only = ValueInfo{
        .unit_type = false,
        .default_value = false,
        .minimum_value = false,
        .maximum_value = false,
    };
};

/// Object Access
///
/// Ref: IEC 61158-6-12:2019 5.6.3.2
pub const ObjectAccess = packed struct(u16) {
    read_PREOP: bool,
    read_SAFEOP: bool,
    read_OP: bool,
    write_PREOP: bool,
    write_SAFEOP: bool,
    write_OP: bool,
    rxpdo_mappable: bool,
    txpdo_mappable: bool,
    backup: bool,
    setting: bool,
    reserved: u6 = 0,
};

/// Map of indexes in the CoE Communication Area
///
/// Ref: IEC 61158-6-12:2019 5.6.7.4
pub const CommunicationAreaMap = enum(u16) {
    device_type = 0x1000,
    error_register = 0x1001,

    manufacturer_device_name = 0x1008,
    manufacturer_hardware_version = 0x1009,
    manufacturer_software_version = 0x100A,
    identity_object = 0x1018,
    sync_manager_communication_type = 0x1c00,

    pub fn smChannel(sm: u5) u16 {
        return 0x1c10 + @as(u16, sm);
    }
    pub fn smSync(sm: u5) u16 {
        return 0x1c30 + @as(u16, sm);
    }
};

/// Device Type
///
/// Ref: IEC 61158-6-12:2019 5.6.7.4.1
pub const DeviceType = packed struct(u32) {
    device_profile: u16,
    profile_info: u16,
};

/// Error Register
///
/// Ref: IEC 61158-6-12:2019 5.6.7.4.2
pub const ErrorRegister = packed struct(u8) {
    generic: bool,
    current: bool,
    voltage: bool,
    temperature: bool,
    communication: bool,
    device_profile_specific: bool,
    reserved: bool,
    manufacturer_specific: bool,
};

/// Manufacturer Device Name
///
/// Ref: IEC 61158-6-12:2019 5.6.7.4.3
pub const ManufacturerDeviceName = []const u8;

/// Manufacturer Hardware Version
///
/// Ref: IEC 61158-6-12:2019 5.6.7.4.4
pub const ManufacturerHardwareVersion = []const u8;

/// Manufacturer Software Version
///
/// Ref: IEC 61158-6-12:2019 5.6.7.4.6
pub const ManufacturerSoftwareVersion = []const u8;

/// Identity Object
///
/// Ref: IEC 61158-6-12:2019 5.6.7.4.6
pub const IdentityObject = struct {
    /// subindex 1
    vendor_id: u32,
    /// subindex 2
    product_code: u32,
    /// subindex 3
    revision_number: u32,
    /// subindex 4
    serial_number: u32,
};

/// SM Communication Type
///
/// Ref: IEC 61158-6-12:2019 5.6.7.4.9
pub const SMComm = enum(u8) {
    unused = 0,
    mailbox_out = 1,
    mailbox_in = 2,
    output = 3,
    input = 4,
    _,
};

/// Ref: IEC 61158-6-12:2019 5.6.7.4.9
pub const SMComms = stdx.ConstBoundedArray(SMComm, max_sm);

pub fn readSMComms(
    port: *Port,
    station_address: u16,
    recv_timeout_us: u32,
    mbx_timeout_us: u32,
    cnt: *Cnt,
    config: mailbox.Configuration,
) !SMComms {
    const n_sm = try sdoReadPack(
        port,
        station_address,
        @intFromEnum(CommunicationAreaMap.sync_manager_communication_type),
        0,
        false,
        u8,
        recv_timeout_us,
        mbx_timeout_us,
        cnt.nextCnt(),
        config,
    );

    if (n_sm > max_sm) {
        logger.err("station_addr: {} has invalid number of sync managers: {}", .{ station_address, n_sm });
        return error.MisbehavingSubdevice;
    }

    assert(n_sm <= max_sm);
    var sm_comms = SMComms{};
    for (0..n_sm) |sm_idx| {
        sm_comms.buffer[sm_idx] = try sdoReadPack(
            port,
            station_address,
            @intFromEnum(CommunicationAreaMap.sync_manager_communication_type),
            @intCast(sm_idx + 1),
            false,
            SMComm,
            recv_timeout_us,
            mbx_timeout_us,
            cnt.nextCnt(),
            config,
        );
    }
    sm_comms.len = @intCast(n_sm);
    return sm_comms;
}

pub fn isValidPDOIndex(index: u16) bool {
    // PDOs can have indices from 0x1600 to 0x1BFF (inclusive)
    return index >= 0x1600 and index <= 0x1BFF;
}

/// Sync Manager Channel
///
/// The u16 in this array is the PDO index.
///
/// Ref: IEC 61158-6-12:2019 5.6.7.4.10.1
/// Note: the spec uses both the terms "channel" and "PDO assignment"
/// to refer to this structure. Its purpose is to assign PDOs to this
/// sync manager.
pub const SMChannel = stdx.ConstBoundedArray(u16, 254);

pub fn readSMChannel(
    port: *Port,
    station_address: u16,
    recv_timeout_us: u32,
    mbx_timeout_us: u32,
    cnt: *Cnt,
    config: mailbox.Configuration,
    sm_idx: u5,
) (error{MisbehavingSubdevice} || SDOReadPackError)!SMChannel {
    const index = CommunicationAreaMap.smChannel(sm_idx);

    const n_pdo = try sdoReadPack(
        port,
        station_address,
        index,
        0,
        false,
        u8,
        recv_timeout_us,
        mbx_timeout_us,
        cnt.nextCnt(),
        config,
    );
    var channel = SMChannel{};
    if (n_pdo > channel.capacity()) {
        logger.err("station_addr: {} returned invalid n pdos: {} for sm_idx: {}", .{ station_address, n_pdo, sm_idx });
        return error.MisbehavingSubdevice;
    }
    assert(n_pdo <= channel.capacity());
    for (0..n_pdo) |i| {
        const pdo_index = try sdoReadPack(
            port,
            station_address,
            index,
            @intCast(i + 1),
            false,
            u16,
            recv_timeout_us,
            mbx_timeout_us,
            cnt.nextCnt(),
            config,
        );
        if (!isValidPDOIndex(pdo_index)) {
            logger.err("station_addr: {} returned invalid pdo_index: {} for n_pdo: {}, sm_idx: {}", .{ station_address, pdo_index, i, sm_idx });
            return error.MisbehavingSubdevice;
        }
        channel.buffer[i] = pdo_index;
    }
    channel.len = @intCast(n_pdo);
    return channel;
}

/// Sync Manager Synchronization Type
///
/// Ref: IEC 61158-6-12:2019 5.6.7.4.11
pub const SMSyncType = enum(u16) {
    not_synchronized = 0,
    /// Synchronized iwth AL event on this SM
    sm_synchron = 1,
    /// Synchronized with AL event Sync0
    dc_sync0 = 2,
    /// Synchronized with AL event Sync1
    dc_sync1 = 3,
    _,
    /// synchronized with AL event of SMxx
    pub fn syncSM(sm: u5) u16 {
        return 32 + @as(u16, sm);
    }
};

/// Sync Manager Synchronization
///
/// Ref: IEC 61158-6-12:2019 5.6.7.4.11
pub const SMSynchronization = struct {
    // subindex 0 can be 1-3
    sync_type: SMSyncType,
    cycle_time_ns: ?u32,
    shift_time_ns: ?u32,
};

pub fn readSMSync(
    port: *Port,
    station_address: u16,
    recv_timeout_us: u32,
    mbx_timeout_us: u32,
    cnt: *Cnt,
    config: mailbox.Configuration,
    sm_idx: u5,
) !SMSynchronization {
    const index = CommunicationAreaMap.smChannel(sm_idx);

    const n_params = try sdoReadPack(
        port,
        station_address,
        index,
        0,
        false,
        u8,
        recv_timeout_us,
        mbx_timeout_us,
        cnt.nextCnt(),
        config,
    );

    if (n_params > 3 or n_params == 0) return error.InvalidSMSync;

    const sync_type = try sdoReadPack(
        port,
        station_address,
        index,
        1,
        false,
        SMSyncType,
        recv_timeout_us,
        mbx_timeout_us,
        cnt.nextCnt(),
        config,
    );

    const cycle_time: ?u32 = blk: {
        if (n_params < 2) break :blk null;

        break :blk try sdoReadPack(
            port,
            station_address,
            index,
            2,
            false,
            u32,
            recv_timeout_us,
            mbx_timeout_us,
            cnt.nextCnt(),
            config,
        );
    };

    const shift_time: ?u32 = blk: {
        if (n_params < 3) break :blk null;

        break :blk try sdoReadPack(
            port,
            station_address,
            index,
            3,
            false,
            u32,
            recv_timeout_us,
            mbx_timeout_us,
            cnt.nextCnt(),
            config,
        );
    };

    return SMSynchronization{
        .sync_type = sync_type,
        .cycle_time_ns = cycle_time,
        .shift_time_ns = shift_time,
    };
}

/// The maximum number of sync managers is limited to 32.
///
/// Ref: IEC 61158-6-12:2019 5.6.7.4
pub const max_sm = 32;

/// PDO Mapping
///
/// Tx and Rx are both represented here.
///
/// Ref: IEC 61158-6-12:2019 5.6.7.4.7
pub const PDOMapping = struct {
    entries: stdx.ConstBoundedArray(Entry, max_entries) = .{},

    const max_entries = 254;

    /// PDO Mapping Entry
    ///
    /// The PDO mapping index contains multiple subindices.
    ///
    /// Ref: IEC 61158-6-12:2019 5.6.7.4.7
    pub const Entry = packed struct(u32) {
        bit_length: u8,
        /// shall be zero if gap in PDO
        subindex: u8,
        /// shall be zero if gap in PDO
        index: u16,

        /// A gap is padding in the PDO. It is still included
        /// in the process image but the subdevice does nothing with it.
        /// Typically this is for byte-alignment.
        pub fn isGap(self: Entry) bool {
            return self.index == 0;
        }
    };

    pub fn bitLength(self: PDOMapping) u32 {
        var bit_length: u32 = 0;
        for (self.entries.slice()) |entry| {
            bit_length += entry.bit_length;
        }
        return bit_length;
    }
};

pub fn readPDOMapping(
    port: *Port,
    station_address: u16,
    recv_timeout_us: u32,
    mbx_timeout_us: u32,
    cnt: *Cnt,
    config: mailbox.Configuration,
    index: u16,
) !PDOMapping {
    assert(isValidPDOIndex(index));

    const n_entries = try sdoReadPack(
        port,
        station_address,
        index,
        0,
        false,
        u8,
        recv_timeout_us,
        mbx_timeout_us,
        cnt.nextCnt(),
        config,
    );

    var entries = PDOMapping{};
    if (n_entries > PDOMapping.max_entries) {
        logger.err("station_addr: {} reported invalid number of COE entries: {} for index: {}", .{ station_address, n_entries, index });
        return error.MisbehavingSubdevice;
    }

    assert(n_entries <= PDOMapping.max_entries);
    for (0..n_entries) |i| {
        entries.entries.buffer[i] = try sdoReadPack(
            port,
            station_address,
            index,
            // the subindex of the CoE obeject is 1 + the sm_idx. (subindex 1 contains the data for SM0)
            @intCast(i + 1),
            false,
            PDOMapping.Entry,
            recv_timeout_us,
            mbx_timeout_us,
            cnt.nextCnt(),
            config,
        );
    }
    entries.entries.len = n_entries;
    return entries;
}

pub fn readSMPDOAssigns(
    port: *Port,
    station_address: u16,
    recv_timeout_us: u32,
    eeprom_timeout_us: u32,
    mbx_timeout_us: u32,
    cnt: *Cnt,
    config: mailbox.Configuration,
) (error{MisbehavingSubdevice} || SDOReadPackError || sii.ReadError)!sii.SMPDOAssigns {
    // We need the start addr of the SM from the SII, but we want to trust the CoE
    // on what PDOs are mapped. What a pain.
    var res = sii.SMPDOAssigns{};

    const sm_catagory = try sii.readSMCatagory(
        port,
        station_address,
        recv_timeout_us,
        eeprom_timeout_us,
    );
    if (sm_catagory.len == 0) return res;
    const sync_managers = sm_catagory.slice();

    for (sync_managers, 0..) |sm_config, sm_idx| {
        switch (sm_config.syncM_type) {
            .mailbox_in, .mailbox_out, .not_used_or_unknown => {},
            _ => return error.MisbehavingSubdevice,
            .process_data_inputs, .process_data_outputs => |direction| {
                res.addSyncManager(sm_config, @intCast(sm_idx)) catch |err| switch (err) {
                    error.Overflow => return error.MisbehavingSubdevice,
                };

                const sm_pdo_assignment = try mailbox.coe.readSMChannel(port, station_address, recv_timeout_us, mbx_timeout_us, cnt, config, @intCast(sm_idx));

                for (sm_pdo_assignment.slice()) |pdo_index| {
                    const pdo_mapping = try mailbox.coe.readPDOMapping(port, station_address, recv_timeout_us, mbx_timeout_us, cnt, config, pdo_index);
                    for (pdo_mapping.entries.slice()) |entry| {
                        res.addPDOBitsToSM(
                            entry.bit_length,
                            @intCast(sm_idx),
                            switch (direction) {
                                .process_data_inputs => .input,
                                .process_data_outputs => .output,
                                else => unreachable,
                            },
                        ) catch |err| switch (err) {
                            error.SyncManagerNotFound, error.WrongDirection => return error.MisbehavingSubdevice,
                        };
                    }
                }
            },
        }
    }
    res.sortAndVerifyNonOverlapping() catch |err| switch (err) {
        error.OverlappingSM => return error.MisbehavingSubdevice,
    };
    return res;
}

/// There are 5 OD lists.
///
/// An OD list is an object description list where each item
/// is an index in the object dictionary.
///
/// This struct is the length reported for each of the OD lists.
///
/// Ref: IEC 61158-6-12:2019 5.6.3.3
pub const ODListLengths = struct {
    all_objects: u16,
    rx_pdo_mappable: u16,
    tx_pdo_mappable: u16,
    stored_for_device_replacement: u16,
    startup_parameters: u16,
};

pub fn readODListLengths(
    port: *Port,
    station_address: u16,
    recv_timeout_us: u32,
    mbx_timeout_us: u32,
    cnt: *Cnt,
    config: mailbox.Configuration,
) !ODListLengths {
    const index_list = try readODList(
        port,
        station_address,
        recv_timeout_us,
        mbx_timeout_us,
        cnt,
        config,
        .num_object_in_5_lists,
    );

    if (index_list.len != 5) return error.MisbehavingSubdevice;
    assert(index_list.len == 5);
    return ODListLengths{
        .all_objects = index_list.slice()[0],
        .rx_pdo_mappable = index_list.slice()[1],
        .tx_pdo_mappable = index_list.slice()[2],
        .stored_for_device_replacement = index_list.slice()[3],
        .startup_parameters = index_list.slice()[4],
    };
}

pub fn readODList(
    port: *Port,
    station_address: u16,
    recv_timeout_us: u32,
    mbx_timeout_us: u32,
    cnt: *Cnt,
    config: mailbox.Configuration,
    list_type: ODListType,
) !server.GetODListResponse.IndexList {
    const request = mailbox.OutContent{
        .coe = .{
            .get_od_list_request = .init(cnt.nextCnt(), list_type),
        },
    };
    try mailbox.writeMailboxOut(
        port,
        station_address,
        recv_timeout_us,
        config.mbx_out,
        request,
    );

    var full_service_data_buffer: [4096]u8 = undefined; // TODO: this is arbitrary
    var writer = std.Io.Writer.fixed(&full_service_data_buffer);
    try readSDOInfoFragments(
        port,
        station_address,
        recv_timeout_us,
        mbx_timeout_us,
        config,
        .get_od_list_response,
        &writer,
    );
    const full_service_data = writer.buffered();
    const response = try server.GetODListResponse.deserialize(full_service_data);
    if (response.list_type != list_type) return error.MisbehavingSubdevice;
    return response.index_list;
}

pub fn readSDOInfoFragments(
    port: *Port,
    station_address: u16,
    recv_timeout_us: u32,
    mbx_timeout_us: u32,
    config: mailbox.Configuration,
    opcode: SDOInfoOpCode,
    writer: *std.Io.Writer,
) !void {
    var expected_fragments_left: u16 = 0;
    get_fragments: for (0..1024) |i| {
        const in_content = try mailbox.readMailboxInTimeout(port, station_address, recv_timeout_us, config.mbx_in, mbx_timeout_us);
        if (in_content != .coe) return error.MisbehavingSubdevice;
        switch (in_content.coe) {
            .abort => {
                return error.CoEAbort;
            },
            .emergency => return error.CoEEmergency,
            .sdo_info_response => |response| {
                if (i == 0) expected_fragments_left = response.sdo_info_header.fragments_left;
                if (response.sdo_info_header.opcode != opcode) return error.MisbehavingSubdevice;
                if (response.sdo_info_header.fragments_left != expected_fragments_left) return error.MissedFragment;
                try writer.writeAll(response.service_data);
                if (response.sdo_info_header.fragments_left == 0) break :get_fragments;
                assert(expected_fragments_left > 0);
                expected_fragments_left -= 1;
            },
            else => {
                // TODO: handle this better?
                logger.err(
                    "station addr: 0x{x:04}, unexpected protocol during sdo info fragment transfer: {}",
                    .{ station_address, in_content.coe },
                );
                if (in_content.coe == .sdo_info_error) {
                    if (in_content.coe.sdo_info_error.abort_code == .SubindexDoesNotExist or
                        in_content.coe.sdo_info_error.abort_code == .ObjectDoesNotExistInObjectDirectory)
                    {
                        return error.ObjectDoesNotExist;
                    }
                }
                return error.MisbehavingSubdevice;
            },
        }
    } else return error.MisbehavingSubdevice;
}

pub fn readObjectDescription(
    port: *Port,
    station_address: u16,
    recv_timeout_us: u32,
    mbx_timeout_us: u32,
    cnt: *Cnt,
    config: mailbox.Configuration,
    index: u16,
    full_service_data_buffer: []u8,
) !server.GetObjectDescriptionResponse {
    const request = mailbox.OutContent{
        .coe = .{
            .get_object_description_request = .init(cnt.nextCnt(), index),
        },
    };
    try mailbox.writeMailboxOut(
        port,
        station_address,
        recv_timeout_us,
        config.mbx_out,
        request,
    );

    var writer = std.Io.Writer.fixed(full_service_data_buffer);
    readSDOInfoFragments(
        port,
        station_address,
        recv_timeout_us,
        mbx_timeout_us,
        config,
        .get_object_description_response,
        &writer,
    ) catch |err| switch (err) {
        error.WriteFailed => return error.ObjectDescriptionTooBig,
        else => |err2| return err2,
    };
    const full_service_data = writer.buffered();
    const response = try server.GetObjectDescriptionResponse.deserialize(full_service_data);
    if (response.index != index) return error.MisbehavingSubdevice;
    return response;
}

pub fn readEntryDescription(
    port: *Port,
    station_address: u16,
    recv_timeout_us: u32,
    mbx_timeout_us: u32,
    cnt: *Cnt,
    config: mailbox.Configuration,
    index: u16,
    subindex: u8,
    value_info: ValueInfo,
    full_service_data_buffer: []u8,
) !server.GetEntryDescriptionResponse {
    const request = mailbox.OutContent{
        .coe = .{ .get_entry_description_request = .init(cnt.nextCnt(), index, subindex, value_info) },
    };
    try mailbox.writeMailboxOut(
        port,
        station_address,
        recv_timeout_us,
        config.mbx_out,
        request,
    );

    var writer = std.Io.Writer.fixed(full_service_data_buffer);
    readSDOInfoFragments(
        port,
        station_address,
        recv_timeout_us,
        mbx_timeout_us,
        config,
        .get_entry_description_response,
        &writer,
    ) catch |err| switch (err) {
        error.WriteFailed => return error.EntryDescriptionTooBig,
        else => |err2| return err2,
    };
    const full_service_data = writer.buffered();
    const response = try server.GetEntryDescriptionResponse.deserialize(full_service_data);
    if (response.index != index or response.subindex != subindex or response.value_info != value_info) return error.MisbehavingSubdevice;
    return response;
}

/// Basic Data Type Area
///
/// Ref: IEC 61158-6-12:2019 5.6.7.3 Table 64
pub const DataTypeArea = enum(u16) {
    /// the table does not explicitly mark this as padding but it
    /// seems beckhoff is using 0 for padding.
    UNKNOWN = 0x0000,
    BOOLEAN = 0x0001,
    INTEGER8 = 0x0002,
    INTEGER16 = 0x0003,
    INTEGER32 = 0x0004,
    UNSIGNED8 = 0x0005,
    UNSIGNED16 = 0x0006,
    UNSIGNED32 = 0x0007,
    REAL32 = 0x0008,
    VISIBLE_STRING = 0x0009,
    OCTET_STRING = 0x000a,
    UNICODE_STRING = 0x000b,
    TIME_OF_DAY = 0x000c,
    TIME_DIFFERENCE = 0x000d,
    // reserved = 0x00e
    DOMAIN = 0x000f,
    INTEGER24 = 0x0010,
    REAL64 = 0x0011,
    INTEGER40 = 0x0012,
    INTEGER48 = 0x0013,
    INTEGER56 = 0x0014,
    INTEGER64 = 0x0015,
    UNSIGNED24 = 0x0016,
    // reserved = 0x0017
    UNSIGNED40 = 0x0018,
    UNSIGNED48 = 0x0019,
    UNSIGNED56 = 0x001a,
    UNSIGNED64 = 0x001b,
    // reserved = 0x001c,
    GUID = 0x001d,
    BYTE = 0x001e,
    // reserved = 0x001f-0x002c
    BITARR8 = 0x002d,
    BITARR16 = 0x002e,
    BITARR32 = 0x002f,
    // reserved = 0x0020
    PDO_MAPPING = 0x0021,
    // reserved = 0x0022,
    IDENTITY = 0x0023,
    // reserved = 0x0024,
    COMMAND_PAR = 0x0025,
    // reserved = 0x0026-0x0028
    SYNC_PAR = 0x0029,
    // reserved = 0x002a-0x002f
    BIT1 = 0x0030,
    BIT2 = 0x0031,
    BIT3 = 0x0032,
    BIT4 = 0x0033,
    BIT5 = 0x0034,
    BIT6 = 0x0035,
    BIT7 = 0x0036,
    BIT8 = 0x0037,
    // reserved = 0x0038-0x003f
    // rest is device profile stuff and reserved
    _,
};

test {
    std.testing.refAllDecls(@This());
}
