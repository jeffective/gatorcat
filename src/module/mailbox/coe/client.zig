const std = @import("std");
const assert = std.debug.assert;

const stdx = @import("../../stdx.zig");

const mailbox = @import("../../mailbox.zig");
const wire = @import("../../wire.zig");
const coe = @import("../coe.zig");
const server = @import("server.zig");
/// SDO Client Abort Transfer Request
///
/// The coding for abort transfer requests is identical between server
/// and client.
///
/// Ref: IEC 61158-6-12:2019 5.6.2.7.1
pub const Abort = server.Abort;

/// Client Command Specifer
///
/// Ref: IEC 61158-6-12:2019 5.6.2.1.1
/// The spec refers to this as a "command specifier".
/// CoE is a wrapper on CANopen. In the CANopen specificaiton,
/// this is actually separated between client command specifier (CCS) and
/// server command specifier (scs).
///
/// Ref: CiA 301 V4.2.0
pub const CommandSpecifier = enum(u3) {
    download_segment_request = 0,
    initiate_download_request = 1,
    initiate_upload_request = 2,
    upload_segment_request = 3,
    abort_transfer_request = 4,
    // block_upload = 5,
    // block_download = 6,
};

/// SDO Header for CoE for maindevice to subdevice (client to server)
/// messages.
///
/// Ref: IEC 61158-6-12
pub const SDOHeader = packed struct(u32) {
    size_indicator: bool,
    transfer_type: coe.TransferType,
    data_set_size: coe.DataSetSize,
    /// false: entry addressed with index and subindex will be downloaded.
    /// true: complete object will be downlaoded. subindex shall be zero (when subindex zero
    /// is to be included) or one (subindex 0 excluded)
    complete_access: bool,
    command: CommandSpecifier,
    index: u16,
    /// shall be zero or one if complete access is true.
    subindex: u8,
};

pub const Expedited = packed struct(u128) {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,
    sdo_header: SDOHeader,
    data: u32,

    /// Create an SDO Download Expedited Request
    ///
    /// data.len must be > 0 and < 5.
    ///
    /// Ref: IEC 61158-6-12:2019 5.6.2.1.1
    pub fn initDownloadRequest(
        cnt: u3,
        index: u16,
        subindex: u8,
        complete_access: bool,
        data: []const u8,
    ) Expedited {
        assert(cnt != 0);
        assert(data.len > 0);
        assert(data.len < 5);
        if (complete_access) {
            assert(subindex == 1 or subindex == 0);
        }

        const size: coe.DataSetSize = switch (data.len) {
            1 => .one_octet,
            2 => .two_octets,
            3 => .three_octets,
            4 => .four_octets,
            else => unreachable,
        };

        var data_buf = std.mem.zeroes([4]u8);
        var fbs = std.io.fixedBufferStream(&data_buf);
        const writer = fbs.writer();
        writer.writeAll(data) catch unreachable;

        return Expedited{
            .mbx_header = .{
                .length = 0x0A,
                .address = 0,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = 0,
                .service = .sdo_request,
            },
            .sdo_header = .{
                .size_indicator = true,
                .transfer_type = .expedited,
                .data_set_size = size,
                .complete_access = complete_access,
                .command = .initiate_download_request,
                .index = index,
                .subindex = subindex,
            },
            .data = @bitCast(data_buf),
        };
    }

    /// Create an SDO Upload Expedited Request or
    /// an SDO Upload Normal Request (they have the same coding).
    ///
    /// Ref: IEC 61158-6-12:2019 5.6.2.4.1
    pub fn initUploadRequest(
        cnt: u3,
        index: u16,
        subindex: u8,
        complete_access: bool,
    ) Expedited {
        assert(cnt != 0);
        if (complete_access) {
            assert(subindex == 1 or subindex == 0);
        }
        return Expedited{
            .mbx_header = .{
                .length = 0x0A,
                .address = 0,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = 0,
                .service = .sdo_request,
            },
            // first 4 bits are reserved to be zero
            .sdo_header = .{
                .size_indicator = false,
                .transfer_type = @enumFromInt(0),
                .data_set_size = @enumFromInt(0),
                .complete_access = complete_access,
                .command = .initiate_upload_request,
                .index = index,
                .subindex = subindex,
            },
            // last 4 bytes are reserved as zero
            .data = 0,
        };
    }

    pub fn deserialize(buf: []const u8) !Expedited {
        var fbs = std.Io.Reader.fixed(buf);
        const reader = &fbs;
        return wire.packFromECatReader(Expedited, reader) catch return error.InvalidMbxContent;
    }

    pub fn serialize(self: Expedited, out: []u8) !usize {
        var fbs = std.io.fixedBufferStream(out);
        const writer = fbs.writer();
        try wire.eCatFromPackToWriter(self, writer);
        return fbs.getWritten().len;
    }
};

test "serialize deserialize sdo client expedited" {
    const expected = Expedited.initDownloadRequest(
        5,
        1234,
        23,
        false,
        &.{ 1, 2, 3, 4 },
    );

    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    const byte_size = try expected.serialize(&bytes);
    try std.testing.expectEqual(@as(usize, 6 + 2 + 8), byte_size);
    const actual = try Expedited.deserialize(&bytes);
    try std.testing.expectEqualDeep(expected, actual);
}

pub const Normal = struct {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,
    sdo_header: SDOHeader,
    complete_size: u32,
    data: stdx.BoundedArray(u8, data_max_size),

    pub const data_max_size = mailbox.max_size - 16;

    fn eq(self: Normal, operand: Normal) bool {
        return self.mbx_header == operand.mbx_header and
            self.coe_header == operand.coe_header and
            self.sdo_header == operand.sdo_header and
            self.complete_size == operand.complete_size and
            std.mem.eql(u8, self.data.slice(), operand.data.slice());
    }

    /// Create an SDO Download Normal Request
    ///
    /// Ref: IEC 61158-6-12:2019 5.6.2.2.1
    /// Ref: IEC 61158-6-12:2019 5.6.2.5.1
    pub fn initDownloadRequest(
        cnt: u3,
        index: u16,
        subindex: u8,
        complete_access: bool,
        complete_size: u32,
        data: []const u8,
    ) Normal {
        assert(cnt != 0);
        assert(data.len <= data_max_size);
        if (complete_access) {
            assert(subindex == 1 or subindex == 0);
        }
        return Normal{
            .mbx_header = .{
                .length = @as(u16, @intCast(data.len)) + 10,
                .address = 0x0,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = 0,
                .service = .sdo_request,
            },
            .sdo_header = .{
                .size_indicator = true,
                .transfer_type = .normal,
                .data_set_size = .four_octets,
                .complete_access = complete_access,
                .command = .initiate_download_request,
                .index = index,
                .subindex = subindex,
            },
            .complete_size = complete_size,
            .data = stdx.BoundedArray(
                u8,
                data_max_size,
            ).fromSlice(data) catch unreachable,
        };
    }

    pub fn deserialize(buf: []const u8) !Normal {
        var fbs = std.Io.Reader.fixed(buf);
        const reader = &fbs;
        const mbx_header = try wire.packFromECatReader(mailbox.Header, reader);
        const coe_header = try wire.packFromECatReader(coe.Header, reader);
        const sdo_header = try wire.packFromECatReader(SDOHeader, reader);
        const complete_size = try wire.packFromECatReader(u32, reader);

        if (mbx_header.length < 10) return error.InvalidMbxContent;
        const data_length: u16 = mbx_header.length -| 10;
        var data = try stdx.BoundedArray(
            u8,
            data_max_size,
        ).init(data_length);
        reader.readSliceAll(data.slice()) catch |err| switch (err) {
            error.EndOfStream => return error.InvalidMbxContent,
            error.ReadFailed => return error.ReadFailed,
        };

        return Normal{
            .mbx_header = mbx_header,
            .coe_header = coe_header,
            .sdo_header = sdo_header,
            .complete_size = complete_size,
            .data = data,
        };
    }

    pub fn serialize(self: *const Normal, out: []u8) !usize {
        var fbs = std.io.fixedBufferStream(out);
        const writer = fbs.writer();
        try wire.eCatFromPackToWriter(self.mbx_header, writer);
        try wire.eCatFromPackToWriter(self.coe_header, writer);
        try wire.eCatFromPackToWriter(self.sdo_header, writer);
        try wire.eCatFromPackToWriter(self.complete_size, writer);
        try writer.writeAll(self.data.slice());
        return fbs.getWritten().len;
    }

    /// Get the maximum size of data that can be transfered
    /// in a single mailbox transfer given the size of the mailbox.
    pub fn dataMaxSizeForMailbox(mbx_size: u16) u16 {
        assert(mbx_size <= mailbox.max_size);
        assert(mbx_size >= mailbox.min_size);

        return mbx_size - @divExact(@bitSizeOf(mailbox.Header), 8) -
            @divExact(@bitSizeOf(coe.Header), 8) -
            @divExact(@bitSizeOf(SDOHeader), 8) -
            @divExact(@bitSizeOf(u32), 8);
    }

    comptime {
        assert(data_max_size ==
            mailbox.max_size -
                @divExact(@bitSizeOf(mailbox.Header), 8) -
                @divExact(@bitSizeOf(coe.Header), 8) -
                @divExact(@bitSizeOf(SDOHeader), 8) -
                @divExact(@bitSizeOf(u32), 8));
    }
};

test "serialize deserialize SDO client normal" {
    const expected = Normal.initDownloadRequest(
        2,
        1000,
        1,
        true,
        12345,
        &.{ 1, 2, 3 },
    );

    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    const byte_size = try expected.serialize(&bytes);
    try std.testing.expectEqual(@as(usize, 6 + 2 + 8 + 3), byte_size);
    const actual = try Normal.deserialize(&bytes);
    try std.testing.expect(Normal.eq(expected, actual));
}

///
pub const Segment = struct {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,
    seg_header: SDOSegmentHeaderClient,
    data: stdx.BoundedArray(u8, data_max_size),

    pub const data_max_size = mailbox.max_size - 9;

    fn eq(self: Segment, operand: Segment) bool {
        return self.mbx_header == operand.mbx_header and
            self.coe_header == operand.coe_header and
            self.seg_header == operand.seg_header and
            std.mem.eql(u8, self.data.slice(), operand.data.slice());
    }

    /// Create an SDO Download Segmented Request
    ///
    /// Ref: IEC 61158-6-12:2019 5.6.2.3.1
    pub fn initDownloadRequest(
        cnt: u3,
        more_follows: bool,
        toggle: bool,
        data: []const u8,
    ) !Segment {
        assert(cnt != 0);
        // We must always send a minimum of 7 octets in the data section.
        // The first octets are used and the remaining are padded with zeros.
        const length = @max(10, @as(u16, @intCast(data.len + 3)));
        const padding_length: usize = @min(7, 7 -| data.len);
        assert(padding_length <= 7);

        const seg_data_size: coe.SegmentDataSize = switch (data.len) {
            0 => .zero_octets,
            1 => .one_octet,
            2 => .two_octets,
            3 => .three_octets,
            4 => .four_octets,
            5 => .five_octets,
            6 => .six_octets,
            else => .seven_octets,
        };

        var temp_data = try stdx.BoundedArray(
            u8,
            data_max_size,
        ).fromSlice(data);
        try temp_data.appendNTimes(@as(u8, 0), padding_length);
        assert(temp_data.len >= 7);

        return Segment{
            .mbx_header = .{
                .length = length,
                .address = 0x0,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = 0,
                .service = .sdo_request,
            },
            .seg_header = .{
                .more_follows = more_follows,
                .seg_data_size = seg_data_size,
                .toggle = toggle,
                .command = .download_segment_request,
            },
            .data = temp_data,
        };
    }

    /// Create an SDO Upload Segmented Request
    ///
    /// Ref: IEC 61158-6-12:2019 5.6.2.6.1
    pub fn initUploadRequest(
        cnt: u3,
        toggle: bool,
    ) Segment {
        assert(cnt != 0);
        return Segment{
            .mbx_header = .{
                .length = 10,
                .address = 0x0,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = 0,
                .service = .sdo_request,
            },
            .seg_header = .{
                .more_follows = false,
                .seg_data_size = @enumFromInt(0),
                .toggle = toggle,
                .command = .upload_segment_request,
            },
            .data = std.BoundedArray(
                u8,
                data_max_size,
            ).fromSlice(&.{ 0, 0, 0, 0, 0, 0, 0 }) catch unreachable,
        };
    }

    pub fn deserialize(buf: []const u8) !Segment {
        var fbs = std.Io.Reader.fixed(buf);
        const reader = &fbs;
        const mbx_header = try wire.packFromECatReader(mailbox.Header, reader);
        const coe_header = try wire.packFromECatReader(coe.Header, reader);
        const seg_header = try wire.packFromECatReader(SDOSegmentHeaderClient, reader);

        if (mbx_header.length < 10) {
            return error.InvalidMbxHeaderLength;
        }
        const data_length: u16 = mbx_header.length -| 3;
        var data = try stdx.BoundedArray(
            u8,
            data_max_size,
        ).init(data_length);
        reader.readSliceAll(data.slice()) catch |err| switch (err) {
            error.EndOfStream => return error.InvalidMbxContent,
            error.ReadFailed => return error.ReadFailed,
        };

        return Segment{
            .mbx_header = mbx_header,
            .coe_header = coe_header,
            .seg_header = seg_header,
            .data = data,
        };
    }

    pub fn serialize(self: *const Segment, out: []u8) !usize {
        var fbs = std.io.fixedBufferStream(out);
        const writer = fbs.writer();
        try wire.eCatFromPackToWriter(self.mbx_header, writer);
        try wire.eCatFromPackToWriter(self.coe_header, writer);
        try wire.eCatFromPackToWriter(self.seg_header, writer);
        try writer.writeAll(self.data.slice());
        return fbs.getWritten().len;
    }

    comptime {
        assert(data_max_size ==
            mailbox.max_size -
                @divExact(@bitSizeOf(mailbox.Header), 8) -
                @divExact(@bitSizeOf(coe.Header), 8) -
                @divExact(@bitSizeOf(SDOSegmentHeaderClient), 8));
    }

    comptime {
        assert(data_max_size >= 7); // must be able to fit upload request
    }
};

test "serialize deserialize sdo client segment" {
    const expected = try Segment.initDownloadRequest(
        3,
        true,
        true,
        &.{ 1, 2, 3, 4, 5, 6, 7 },
    );

    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    const byte_size = try expected.serialize(&bytes);
    try std.testing.expectEqual(@as(usize, 6 + 2 + 8), byte_size);
    const actual = try Segment.deserialize(&bytes);
    try std.testing.expect(Segment.eq(expected, actual));
}

test "sdo client segment seg_data_size" {
    const actual = try Segment.initDownloadRequest(
        3,
        true,
        true,
        &.{ 1, 2, 3, 4 },
    );
    try std.testing.expectEqual(
        coe.SegmentDataSize.four_octets,
        actual.seg_header.seg_data_size,
    );
}

/// SDO Segment Header Client
///
/// Client / server language is from CANopen.
///
/// Ref: IEC 61158-6-12:2019 5.6.2.3.1
pub const SDOSegmentHeaderClient = packed struct(u8) {
    more_follows: bool,
    seg_data_size: coe.SegmentDataSize,
    /// shall toggle with every segment, starting with 0x00
    toggle: bool,
    command: CommandSpecifier,
};

/// Get OD List Request
///
/// Ref: IEC 61158-6-12:2019 5.6.3.3.1
pub const GetODListRequest = packed struct {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,
    sdo_info_header: coe.SDOInfoHeader,
    list_type: coe.ODListType,

    pub fn init(
        cnt: u3,
        list_type: coe.ODListType,
    ) GetODListRequest {
        assert(cnt != 0);
        return GetODListRequest{
            .mbx_header = .{
                .length = 8,
                .address = 0,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = 0,
                .service = .sdo_info,
            },
            .sdo_info_header = .{
                .opcode = .get_od_list_request,
                .incomplete = false,
                .fragments_left = 0,
            },
            .list_type = list_type,
        };
    }

    pub fn deserialize(buf: []const u8) !GetODListRequest {
        var fbs = std.Io.Reader.fixed(buf);
        const reader = &fbs;
        return try wire.packFromECatReader(GetODListRequest, reader);
    }

    pub fn serialize(self: GetODListRequest, out: []u8) !usize {
        var fbs = std.io.fixedBufferStream(out);
        const writer = fbs.writer();
        try wire.eCatFromPackToWriter(self, writer);
        return fbs.getWritten().len;
    }
};

test "serialize deserialize get od list request" {
    const expected = GetODListRequest.init(
        3,
        .all_objects,
    );

    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    const byte_size = try expected.serialize(&bytes);
    try std.testing.expectEqual(@as(usize, 6 + 2 + 4 + 2), byte_size);
    const actual = try GetODListRequest.deserialize(&bytes);
    try std.testing.expectEqualDeep(expected, actual);
}

/// Get Object Description Request
///
/// Ref: IEC 61158-6-12:2019 5.6.3.5.1
pub const GetObjectDescriptionRequest = packed struct {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,
    sdo_info_header: coe.SDOInfoHeader,
    index: u16,

    pub fn init(
        cnt: u3,
        index: u16,
    ) GetObjectDescriptionRequest {
        assert(cnt != 0);
        return GetObjectDescriptionRequest{
            .mbx_header = .{
                .length = 8,
                .address = 0,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = 0,
                .service = .sdo_info,
            },
            .sdo_info_header = .{
                .opcode = .get_object_description_request,
                .incomplete = false,
                .fragments_left = 0,
            },
            .index = index,
        };
    }

    pub fn deserialize(buf: []const u8) !GetObjectDescriptionRequest {
        var fbs = std.Io.Reader.fixed(buf);
        const reader = &fbs;
        return try wire.packFromECatReader(GetObjectDescriptionRequest, reader);
    }

    pub fn serialize(self: GetObjectDescriptionRequest, out: []u8) !usize {
        var fbs = std.io.fixedBufferStream(out);
        const writer = fbs.writer();
        try wire.eCatFromPackToWriter(self, writer);
        return fbs.getWritten().len;
    }
};

test "serialize deserialize get object description request" {
    const expected = GetObjectDescriptionRequest.init(
        3,
        234,
    );
    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    const byte_size = try expected.serialize(&bytes);
    try std.testing.expectEqual(@as(usize, 6 + 2 + 4 + 2), byte_size);
    const actual = try GetObjectDescriptionRequest.deserialize(&bytes);
    try std.testing.expectEqualDeep(expected, actual);
}

/// Get Entry Description Request
///
/// Ref: IEC 61158-6-12:2019 5.6.3.6.1
pub const GetEntryDescriptionRequest = packed struct {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,
    sdo_info_header: coe.SDOInfoHeader,
    index: u16,
    subindex: u8,
    value_info: coe.ValueInfo,

    pub fn init(
        cnt: u3,
        index: u16,
        subindex: u8,
        value_info: coe.ValueInfo,
    ) GetEntryDescriptionRequest {
        assert(cnt != 0);
        return GetEntryDescriptionRequest{
            .mbx_header = .{
                .length = 10,
                .address = 0,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = 0,
                .service = .sdo_info,
            },
            .sdo_info_header = .{
                .opcode = .get_entry_description_request,
                .incomplete = false,
                .fragments_left = 0,
            },
            .index = index,
            .subindex = subindex,
            .value_info = value_info,
        };
    }

    pub fn deserialize(buf: []const u8) !GetEntryDescriptionRequest {
        var fbs = std.Io.Reader.fixed(buf);
        const reader = &fbs;
        return try wire.packFromECatReader(GetEntryDescriptionRequest, reader);
    }

    pub fn serialize(self: GetEntryDescriptionRequest, out: []u8) !usize {
        var fbs = std.io.fixedBufferStream(out);
        const writer = fbs.writer();
        try wire.eCatFromPackToWriter(self, writer);
        return fbs.getWritten().len;
    }
};

test "serialize deserialize get entry description request" {
    const expected = GetEntryDescriptionRequest.init(
        3,
        35,
        2,
        .{
            .default_value = true,
            .maximum_value = true,
            .minimum_value = false,
            .unit_type = true,
        },
    );
    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    const byte_size = try expected.serialize(&bytes);
    try std.testing.expectEqual(@as(usize, 6 + 2 + 4 + 4), byte_size);
    const actual = try GetEntryDescriptionRequest.deserialize(&bytes);
    try std.testing.expectEqualDeep(expected, actual);
}

/// PDO Mailbox Transmission
///
/// Ref: IEC 61158-6-12:2019 5.6.5.1
/// Ref: IEC 61158-6-12:2019 5.6.5.1
pub const PDOTransmission = struct {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,
    data: []const u8,

    pub fn rx(
        cnt: u3,
        number: u9,
        data: []const u8,
    ) PDOTransmission {
        assert(cnt != 0);
        assert(data.len > 0);
        return PDOTransmission{
            .mbx_header = .{
                .length = @intCast(data.len + 2),
                .address = 0,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = number,
                .service = .rx_pdo,
            },
            .data = data,
        };
    }

    pub fn tx(
        cnt: u3,
        number: u9,
        data: []const u8,
    ) PDOTransmission {
        assert(cnt != 0);
        assert(data.len > 0);
        return PDOTransmission{
            .mbx_header = .{
                .length = @intCast(data.len + 2),
                .address = 0,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = number,
                .service = .tx_pdo,
            },
            .data = data,
        };
    }
};

/// PDO Remote Transmission Request
///
/// Ref: IEC 61158-6-12:2019 5.6.5.3
/// Ref: IEC 61158-6-12:2019 5.6.5.4
pub const PDORemoteTransmissionRequest = packed struct {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,

    pub fn rx(
        cnt: u3,
        number: u9,
    ) PDORemoteTransmissionRequest {
        assert(cnt != 0);
        return PDORemoteTransmissionRequest{
            .mbx_header = .{
                .length = 2,
                .address = 0,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = number,
                .service = .rx_pdo_remote_request,
            },
        };
    }

    pub fn tx(
        cnt: u3,
        number: u9,
    ) PDORemoteTransmissionRequest {
        assert(cnt != 0);
        return PDORemoteTransmissionRequest{
            .mbx_header = .{
                .length = 2,
                .address = 0,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = number,
                .service = .tx_pdo_remote_request,
            },
        };
    }
};

pub const CommandStatus = enum(u8) {
    completed_no_errors_no_reply = 0,
    completed_no_errors_reply = 1,
    complete_error_no_reply = 2,
    complete_error_reply = 3,
    executing = 255,
    _,
};

/// Command Object Structure
///
/// Each command shall have data type 0x0025.
///
/// Ref: IEC 61158-6-12:2019 5.6.6
pub const Command = struct {
    n_entries: u8,
    command: []u8,
    status: u8,
    reply: []u8,
};

test {
    std.testing.refAllDecls(@This());
}
