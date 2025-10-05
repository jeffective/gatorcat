const std = @import("std");
const assert = std.debug.assert;

const stdx = @import("../../stdx.zig");

const mailbox = @import("../../mailbox.zig");
const wire = @import("../../wire.zig");
const coe = @import("../coe.zig");

/// Server Command Specifier
///
/// See Client Command Specifier.
pub const CommandSpecifier = enum(u3) {
    upload_segment_response = 0,
    download_segment_response = 1,
    initiate_upload_response = 2,
    initiate_download_response = 3,
    abort_transfer_request = 4,
    // block_download = 5,
    // block_upload = 6,
    _,
};

/// SDO Header for CoE for subdevice to maindevice (server to client)
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

    pub fn getDataSize(self: SDOHeader) usize {
        return switch (self.data_set_size) {
            .four_octets => 4,
            .three_octets => 3,
            .two_octets => 2,
            .one_octet => 1,
        };
    }
};

/// SDO Segment Header Server
///
/// Client / server language is from CANopen.
///
/// Ref: IEC 61158-6-12:2019 5.6.2.3.1
pub const SegmentHeader = packed struct {
    more_follows: bool,
    seg_data_size: coe.SegmentDataSize,
    /// shall toggle with every segment, starting with 0x00
    toggle: bool,
    command: CommandSpecifier,
};

/// SDO Expedited Responses
///
/// The coding for the SDO Download Normal Response is the same
/// as the SDO Download Expedited Response.
///
/// Ref: IEC 61158-6-12:2019 5.6.2.1.2 (SDO Download Expedited Response)
/// Ref: IEC 61158-6-12:2019 5.6.2.2.2 (SDO Download Normal Response)
/// Ref: IEC 61158-6-12:2019 5.6.2.4.2 (SDO Upload Expedited Response)
pub const Expedited = struct {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,
    sdo_header: SDOHeader,
    data: []const u8,

    pub fn initDownloadResponse(
        cnt: u3,
        station_address: u16,
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
                .length = 10,
                .address = station_address,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = 0,
                .service = .sdo_response,
            },
            .sdo_header = .{
                .size_indicator = false,
                .transfer_type = .normal,
                .data_set_size = .four_octets,
                .complete_access = complete_access,
                .command = .initiate_download_response,
                .index = index,
                .subindex = subindex,
            },
            .data = &.{ 0, 0, 0, 0 },
        };
    }

    pub fn initUploadResponse(
        cnt: u3,
        station_address: u16,
        index: u16,
        subindex: u8,
        complete_access: bool,
        data: []const u8,
    ) Expedited {
        assert(data.len > 0);
        assert(data.len < 5);
        assert(cnt != 0);
        if (complete_access) {
            assert(subindex == 1 or subindex == 0);
        }

        const data_set_size: coe.DataSetSize = switch (data.len) {
            0 => unreachable,
            1 => .one_octet,
            2 => .two_octets,
            3 => .three_octets,
            4 => .four_octets,
            else => unreachable,
        };

        return Expedited{
            .mbx_header = .{
                .length = 10,
                .address = station_address,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = 0,
                .service = .sdo_response,
            },
            .sdo_header = .{
                .size_indicator = true,
                .transfer_type = .expedited,
                .data_set_size = data_set_size,
                .complete_access = complete_access,
                .command = .initiate_upload_response,
                .index = index,
                .subindex = subindex,
            },
            // data length already asserted
            .data = data,
        };
    }

    pub fn deserialize(buf: []const u8) !Expedited {
        var fbs = std.Io.Reader.fixed(buf);
        const reader = &fbs;
        const mbx_header = try wire.packFromECatReader(mailbox.Header, reader);
        const coe_header = try wire.packFromECatReader(coe.Header, reader);
        const sdo_header = try wire.packFromECatReader(SDOHeader, reader);
        const data_size: usize = sdo_header.getDataSize();
        const data = try reader.take(data_size);
        return Expedited{
            .mbx_header = mbx_header,
            .coe_header = coe_header,
            .sdo_header = sdo_header,
            .data = data,
        };
    }

    pub fn serialize(self: Expedited, writer: *std.Io.Writer) !void {
        try wire.eCatFromPackToWriter(self.mbx_header, writer);
        try wire.eCatFromPackToWriter(self.coe_header, writer);
        try wire.eCatFromPackToWriter(self.sdo_header, writer);
        try writer.writeAll(self.data);
    }
};

test "SDO Server Expedited Serialize Deserialize" {
    const expected = Expedited.initDownloadResponse(
        3,
        234,
        23,
        4,
        false,
    );

    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    var writer = std.Io.Writer.fixed(&bytes);
    try expected.serialize(&writer);
    const byte_size = writer.buffered().len;
    try std.testing.expectEqual(@as(usize, 6 + 2 + 8), byte_size);
    const actual = try Expedited.deserialize(&bytes);
    try std.testing.expectEqualDeep(expected, actual);
}

/// SDO Normal Reponses
///
/// Ref: IEC 61158-6-12:2019 5.6.2.5.2 (SDO Upload Normal Response)
pub const Normal = struct {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,
    sdo_header: SDOHeader,
    complete_size: u32,
    data: []const u8,

    pub const data_max_size = mailbox.max_size - 16;

    fn eq(self: Normal, operand: Normal) bool {
        return self.mbx_header == operand.mbx_header and
            self.coe_header == operand.coe_header and
            self.sdo_header == operand.sdo_header and
            self.complete_size == operand.complete_size and
            std.mem.eql(u8, self.data, operand.data);
    }

    pub fn initUploadResponse(
        cnt: u3,
        station_address: u16,
        index: u16,
        subindex: u8,
        complete_access: bool,
        complete_size: u32,
        data: []const u8,
    ) Normal {
        assert(cnt != 0);
        assert(data.len < data_max_size);
        if (complete_access) {
            assert(subindex == 1 or subindex == 0);
        }

        return Normal{
            .mbx_header = .{
                .length = @as(u16, @intCast(data.len)) + 10,
                .address = station_address,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = 0,
                .service = .sdo_response,
            },
            .sdo_header = .{
                .size_indicator = true,
                .transfer_type = .normal,
                .data_set_size = @enumFromInt(0),
                .complete_access = complete_access,
                .command = .upload_segment_response,
                .index = index,
                .subindex = subindex,
            },
            .complete_size = complete_size,
            .data = data,
        };
    }

    pub fn deserialize(buf: []const u8) !Normal {
        var fbs = std.io.Reader.fixed(buf);
        const reader = &fbs;
        const mbx_header = try wire.packFromECatReader(mailbox.Header, reader);
        const coe_header = try wire.packFromECatReader(coe.Header, reader);
        const sdo_header = try wire.packFromECatReader(SDOHeader, reader);
        const complete_size = try wire.packFromECatReader(u32, reader);

        if (mbx_header.length < 10) return error.InvalidMbxContent;

        const data_length: u16 = mbx_header.length -| 10;
        const data = try reader.take(data_length);

        return Normal{
            .mbx_header = mbx_header,
            .coe_header = coe_header,
            .sdo_header = sdo_header,
            .complete_size = complete_size,
            .data = data,
        };
    }

    pub fn serialize(self: *const Normal, writer: *std.Io.Writer) !void {
        try wire.eCatFromPackToWriter(self.mbx_header, writer);
        try wire.eCatFromPackToWriter(self.coe_header, writer);
        try wire.eCatFromPackToWriter(self.sdo_header, writer);
        try wire.eCatFromPackToWriter(self.complete_size, writer);
        try writer.writeAll(self.data);
    }

    comptime {
        assert(data_max_size == mailbox.max_size -
            @divExact(@bitSizeOf(mailbox.Header), 8) -
            @divExact(@bitSizeOf(coe.Header), 8) -
            @divExact(@bitSizeOf(SDOHeader), 8) -
            @divExact(@bitSizeOf(u32), 8));
    }
};

test "serialize and deserialize sdo server normal" {
    const expected = Normal.initUploadResponse(
        2,
        0,
        1234,
        0,
        true,
        2345,
        &.{ 1, 2, 3, 4 },
    );
    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    var writer = std.Io.Writer.fixed(&bytes);
    try expected.serialize(&writer);
    const byte_size = writer.buffered().len;
    try std.testing.expectEqual(@as(usize, 6 + 2 + 12), byte_size);
    const actual = try Normal.deserialize(&bytes);
    try std.testing.expect(Normal.eq(expected, actual));
}

/// SDO Segment Responses
///
/// Ref: IEC 61158-6-12:2019 5.6.2.3.2 (SDO Download Segment Reponse)
/// Ref: Ref: IEC 61158-6-12:2019 5.6.2.6.2 (SDO Upload Segment Response)
pub const Segment = struct {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,
    seg_header: SegmentHeader,
    data: []const u8,

    const data_max_size = mailbox.max_size - 9;

    fn eq(self: Segment, operand: Segment) bool {
        return self.mbx_header == operand.mbx_header and
            self.coe_header == operand.coe_header and
            self.seg_header == operand.seg_header and
            std.mem.eql(u8, self.data, operand.data);
    }

    pub fn initDownloadResponse(
        cnt: u3,
        station_address: u16,
        toggle: bool,
    ) Segment {
        assert(cnt != 0);

        return Segment{
            .mbx_header = .{
                .length = 10,
                .address = station_address,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = 0,
                .service = .sdo_response,
            },
            .seg_header = .{
                .more_follows = false,
                .seg_data_size = @enumFromInt(0),

                .toggle = toggle,
                .command = .download_segment_response,
            },
            // the serialize and deserialize methods will handle
            // the required seven padding bytes
            .data = &.{},
        };
    }

    pub fn initUploadResponse(
        cnt: u3,
        station_address: u16,
        more_follows: bool,
        toggle: bool,
        data: []const u8,
    ) Segment {
        assert(cnt != 0);
        assert(data.len <= data_max_size);

        const length = @max(10, @as(u16, @intCast(data.len + 3)));

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

        return Segment{
            .mbx_header = .{
                .length = length,
                .address = station_address,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = 0,
                .service = .sdo_response,
            },
            .seg_header = .{
                .more_follows = more_follows,
                .seg_data_size = seg_data_size,
                .toggle = toggle,
                .command = .upload_segment_response,
            },
            // the serialize and deserialize methods will handle
            // the sometimes required seven padding bytes
            .data = data,
        };
    }
    pub fn deserialize(buf: []const u8) !Segment {
        var fbs = std.Io.Reader.fixed(buf);
        const reader = &fbs;
        const mbx_header = try wire.packFromECatReader(mailbox.Header, reader);
        const coe_header = try wire.packFromECatReader(coe.Header, reader);
        const seg_header = try wire.packFromECatReader(SegmentHeader, reader);

        var data_size: usize = 0;
        if (mbx_header.length < 10) {
            return error.InvalidMbxContent;
        } else if (mbx_header.length == 10) {
            data_size = switch (seg_header.seg_data_size) {
                .zero_octets => 0,
                .one_octet => 1,
                .two_octets => 2,
                .three_octets => 3,
                .four_octets => 4,
                .five_octets => 5,
                .six_octets => 6,
                .seven_octets => 7,
            };
        } else {
            assert(mbx_header.length > 10);
            data_size = mbx_header.length - 3;
            assert(data_size == mbx_header.length -
                @divExact(@bitSizeOf(coe.Header), 8) -
                @divExact(@bitSizeOf(SegmentHeader), 8));
        }
        const data = try reader.take(data_size);

        return Segment{
            .mbx_header = mbx_header,
            .coe_header = coe_header,
            .seg_header = seg_header,
            .data = data,
        };
    }

    pub fn serialize(self: *const Segment, writer: *std.Io.Writer) !void {
        try wire.eCatFromPackToWriter(self.mbx_header, writer);
        try wire.eCatFromPackToWriter(self.coe_header, writer);
        try wire.eCatFromPackToWriter(self.seg_header, writer);
        try writer.writeAll(self.data);
        const padding_length: usize = @min(7, 7 -| self.data.len);
        assert(padding_length <= 7);
        try writer.splatByteAll(0, padding_length);
    }

    comptime {
        assert(data_max_size == mailbox.max_size -
            @divExact(@bitSizeOf(mailbox.Header), 8) -
            @divExact(@bitSizeOf(coe.Header), 8) -
            @divExact(@bitSizeOf(SegmentHeader), 8));
        assert(data_max_size >= 7);
    }
};

test "serialize and deserialize sdo server segment" {
    const expected = Segment.initUploadResponse(
        2,
        0,
        false,
        false,
        &.{ 1, 2, 3, 4 },
    );
    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    var writer = std.Io.Writer.fixed(&bytes);
    try expected.serialize(&writer);
    const byte_size = writer.buffered().len;
    try std.testing.expectEqual(@as(usize, 6 + 2 + 8), byte_size);
    const actual = try Segment.deserialize(&bytes);
    try std.testing.expect(Segment.eq(expected, actual));
}

test "serialize and deserialize sdo server segment longer than 7 bytes" {
    const expected = Segment.initUploadResponse(
        2,
        0,
        false,
        false,
        &.{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 },
    );
    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    var writer = std.Io.Writer.fixed(&bytes);
    try expected.serialize(&writer);
    const byte_size = writer.buffered().len;
    try std.testing.expectEqual(@as(usize, 6 + 2 + 14), byte_size);
    const actual = try Segment.deserialize(&bytes);
    try std.testing.expect(Segment.eq(expected, actual));
}

/// SDO Abort Codes
///
/// Ref: IEC 61158-6-12:2019 5.6.2.7.2
pub const SDOAbortCode = enum(u32) {
    ToggleBitNotChanged = 0x05_03_00_00,
    SdoProtocolTimeout = 0x05_04_00_00,
    CommandSpecifierNotValidOrUnknown = 0x05_04_00_01,
    OutOfMemory = 0x05_04_00_05,
    UnsupportedAccessToAnObject = 0x06_01_00_00,
    AttemptToReadToAWriteOnlyObject = 0x06_01_00_01,
    AttemptToWriteToAReadOnlyObject = 0x06_01_00_02,
    SubindexCannotBeWritten = 0x06_01_00_03,
    SdoCompleteAccessNotSupportedForVariableLengthObjects = 0x06_01_00_04,
    ObjectLengthExceedsMailboxSize = 0x06_01_00_05,
    ObjectMappedToRxPdoSdoDownloadBlocked = 0x06_01_00_06,
    ObjectDoesNotExistInObjectDirectory = 0x06_02_00_00,
    ObjectCannotBeMappedIntoPdo = 0x06_04_00_41,
    NumberAndLengthOfObjectsExceedsPdoLength = 0x06_04_00_42,
    GeneralParameterIncompatibilityReason = 0x06_04_00_43,
    GeneralInternalIncompatibilityInDevice = 0x06_04_00_47,
    AccessFailedDueToHardwareError = 0x06_06_00_00,
    DataTypeMismatchLengthOfServiceParameterDoesNotMatch = 0x06_07_00_10,
    DataTypeMismatchLengthOfServiceParameterTooHigh = 0x06_07_00_12,
    DataTypeMismatchLengthOfServiceParameterTooLow = 0x06_07_00_13,
    SubindexDoesNotExist = 0x06_09_00_11,
    ValueRangeOfParameterExceeded = 0x06_09_00_30,
    ValueOfParameterWrittenTooHigh = 0x06_09_00_31,
    ValueOfParameterWrittenTooLow = 0x06_09_00_32,
    MaximumValueLessThanMinimumValue = 0x06_09_00_36,
    GeneralError = 0x08_00_00_00,
    DataCannotBeTransferredOrStoredToApplication = 0x08_00_00_20,
    DataCannotBeTransferredOrStoredDueToLocalControl = 0x08_00_00_21,
    DataCannotBeTransferredOrStoredDueToESMState = 0x08_00_00_22,
    ObjectDictionaryDynamicGenerationFailedOrNoObjectDictionaryPresent = 0x08_00_00_23,
};

/// Abort SDO Transfer Request
///
/// Ref: IEC 61158-6-12:2019 5.6.2.7.1
pub const Abort = packed struct(u128) {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,
    sdo_header: SDOHeader,
    abort_code: SDOAbortCode,

    pub fn init(
        cnt: u3,
        station_address: u16,
        index: u16,
        subindex: u8,
        abort_code: SDOAbortCode,
    ) Abort {
        assert(cnt != 0);

        return Abort{
            .mbx_header = .{
                .length = 10,
                .address = station_address,
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
                .size_indicator = false,
                .transfer_type = @enumFromInt(0),
                .data_set_size = @enumFromInt(0),
                .complete_access = false,
                .command = .abort_transfer_request,
                .index = index,
                .subindex = subindex,
            },
            .abort_code = abort_code,
        };
    }

    pub fn deserialize(buf: []const u8) !Abort {
        var fbs = std.Io.Reader.fixed(buf);
        return try wire.packFromECatReader(Abort, &fbs);
    }

    pub fn serialize(self: Abort, writer: *std.Io.Writer) !void {
        try wire.eCatFromPackToWriter(self, writer);
    }
};

test "serialize and deserialize abort sdo transfer request" {
    const expected = Abort.init(
        3,
        345,
        345,
        3,
        .AccessFailedDueToHardwareError,
    );
    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    var writer = std.Io.Writer.fixed(&bytes);
    try expected.serialize(&writer);
    const byte_size = writer.buffered().len;
    try std.testing.expectEqual(@as(usize, 6 + 2 + 8), byte_size);
    const actual = try Abort.deserialize(&bytes);
    try std.testing.expectEqualDeep(expected, actual);
}

pub const SDOInfoResponse = struct {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,
    sdo_info_header: coe.SDOInfoHeader,
    service_data: []const u8,

    pub const service_data_max_length = 1474;

    pub fn init(
        cnt: u3,
        station_address: u16,
        more_follows: bool,
        fragments_left: u16,
        service_data: []const u8,
    ) SDOInfoResponse {
        assert(cnt != 0);
        assert(service_data.len <= service_data_max_length);
        const mbx_header_length = service_data.len + 6;
        return SDOInfoResponse{
            .mbx_header = .{
                .length = @intCast(mbx_header_length),
                .address = station_address,
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
                .opcode = .get_od_list_response,
                .incomplete = more_follows,
                .fragments_left = fragments_left,
            },
            .service_data = service_data,
        };
    }

    pub fn deserialize(buf: []const u8) !SDOInfoResponse {
        var fbs = std.Io.Reader.fixed(buf);
        const reader = &fbs;

        const mbx_header = try wire.packFromECatReader(mailbox.Header, reader);
        const coe_header = try wire.packFromECatReader(coe.Header, reader);
        const sdo_info_header = try wire.packFromECatReader(coe.SDOInfoHeader, reader);
        const service_data_length = mbx_header.length -| 6;
        const service_data = try reader.take(service_data_length);
        return SDOInfoResponse{
            .mbx_header = mbx_header,
            .coe_header = coe_header,
            .sdo_info_header = sdo_info_header,
            .service_data = service_data,
        };
    }

    pub fn serialize(self: SDOInfoResponse, writer: *std.Io.Writer) !void {
        try wire.eCatFromPackToWriter(self.mbx_header, writer);
        try wire.eCatFromPackToWriter(self.coe_header, writer);
        try wire.eCatFromPackToWriter(self.sdo_info_header, writer);
        try writer.writeAll(self.service_data);
    }

    comptime {
        assert(service_data_max_length ==
            mailbox.max_size -
                @divExact(@bitSizeOf(mailbox.Header), 8) -
                @divExact(@bitSizeOf(coe.Header), 8) -
                @divExact(@bitSizeOf(coe.SDOInfoHeader), 8));
    }
};

test "serialize and deserialize sdo info response" {
    const expected = SDOInfoResponse.init(3, 234, true, 151, &.{ 1, 2, 3, 4 });
    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    var writer = std.Io.Writer.fixed(&bytes);
    try expected.serialize(&writer);
    const byte_size = writer.buffered().len;
    try std.testing.expectEqual(@as(usize, 6 + 2 + 4 + 4), byte_size);
    const actual = try SDOInfoResponse.deserialize(&bytes);
    try std.testing.expectEqual(expected.coe_header, actual.coe_header);
    try std.testing.expectEqual(expected.mbx_header, actual.mbx_header);
    try std.testing.expectEqual(expected.sdo_info_header, actual.sdo_info_header);
    try std.testing.expectEqualSlices(u8, expected.service_data, actual.service_data);
}

/// Get OD List Response
///
/// This is encapsulated and transferred as service_data in SDOInfoResponse.
///
/// Ref: IEC 61158-6-12:2019 5.6.3.3.2
pub const GetODListResponse = struct {
    list_type: coe.ODListType,
    index_list: IndexList,

    pub const IndexList = stdx.BoundedArray(u16, index_list_max_length);
    pub const index_list_max_length = 1024; // TODO: this length is arbitrary

    fn eq(self: GetODListResponse, operand: GetODListResponse) bool {
        return self.list_type == operand.list_type and
            std.mem.eql(u16, self.index_list.slice(), operand.index_list.slice());
    }

    pub fn init(
        list_type: coe.ODListType,
        index_list: []const u16,
    ) GetODListResponse {
        assert(index_list.len <= index_list_max_length);
        return GetODListResponse{
            .list_type = list_type,
            .index_list = IndexList.fromSlice(index_list) catch unreachable,
        };
    }

    /// Input buffer must be exact length.
    pub fn deserialize(buf: []const u8) !GetODListResponse {
        var fbs = std.Io.Reader.fixed(buf);
        const reader = &fbs;

        const list_type = try wire.packFromECatReader(coe.ODListType, reader);
        var index_list = IndexList{};

        const bytes_remaining = fbs.end - fbs.seek;
        if (bytes_remaining % 2 != 0) return error.InvalidServiceData;
        if (bytes_remaining / 2 > index_list_max_length) return error.StreamTooLong;
        for (0..bytes_remaining / 2) |_| {
            index_list.append(wire.packFromECatReader(u16, reader) catch unreachable) catch unreachable;
        }
        return GetODListResponse{
            .list_type = list_type,
            .index_list = index_list,
        };
    }

    pub fn serialize(self: GetODListResponse, writer: *std.Io.Writer) !void {
        try wire.eCatFromPackToWriter(self.list_type, writer);
        for (self.index_list.slice()) |index| {
            try wire.eCatFromPackToWriter(index, writer);
        }
    }
};

test "serialize and deserialize get od list response" {
    const expected = GetODListResponse.init(
        .all_objects,
        &.{ 1, 2, 3, 4 },
    );
    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    var writer = std.Io.Writer.fixed(&bytes);
    try expected.serialize(&writer);
    const byte_size = writer.buffered().len;
    try std.testing.expectEqual(@as(usize, 2 + 8), byte_size);
    const actual = try GetODListResponse.deserialize(bytes[0..byte_size]);
    try std.testing.expect(GetODListResponse.eq(expected, actual));
}

/// Get Object Description Response
///
/// This is encapsulated and transferred as service_data in SDOInfoResponse.
///
/// Ref: IEC 61158-6-12:2019 5.6.3.5.2
pub const GetObjectDescriptionResponse = struct {
    /// index of the object description
    index: u16,
    /// reference to data type list
    data_type: coe.DataTypeArea,
    /// maximum number of subindexes of the object
    max_subindex: u8,
    object_code: coe.ObjectCode,
    /// name of the object
    name: []const u8,

    pub const max_name_length = 512; // TODO: this is arbitrary

    fn eq(self: GetObjectDescriptionResponse, operand: GetObjectDescriptionResponse) bool {
        return self.index == operand.index and self.data_type == operand.data_type and
            self.max_subindex == operand.max_subindex and
            self.object_code == operand.object_code and
            std.mem.eql(u8, self.name, operand.name);
    }

    pub fn init(
        index: u16,
        data_type: coe.DataTypeArea,
        max_subindex: u8,
        object_code: coe.ObjectCode,
        name: []const u8,
    ) GetObjectDescriptionResponse {
        assert(name.len <= max_name_length);
        return GetObjectDescriptionResponse{
            .index = index,
            .data_type = data_type,
            .max_subindex = max_subindex,
            .object_code = object_code,
            .name = name,
        };
    }

    pub fn deserialize(buf: []const u8) !GetObjectDescriptionResponse {
        var fbs = std.Io.Reader.fixed(buf);
        const reader = &fbs;
        const index = wire.packFromECatReader(u16, reader) catch return error.InvalidMbxContent;
        const data_type = wire.packFromECatReader(coe.DataTypeArea, reader) catch return error.InvalidMbxContent;
        const max_subindex = wire.packFromECatReader(u8, reader) catch return error.InvalidMbxContent;
        const object_code = wire.packFromECatReader(coe.ObjectCode, reader) catch return error.InvalidMbxContent;

        const name_length = reader.end - reader.seek;
        if (name_length > max_name_length) return error.InvalidMbxContent;
        assert(name_length <= max_name_length);
        const name = try reader.take(name_length);
        return GetObjectDescriptionResponse{
            .index = index,
            .data_type = data_type,
            .max_subindex = max_subindex,
            .object_code = object_code,
            .name = name,
        };
    }

    pub fn serialize(self: GetObjectDescriptionResponse, writer: *std.Io.Writer) !void {
        try wire.eCatFromPackToWriter(self.index, writer);
        try wire.eCatFromPackToWriter(self.data_type, writer);
        try wire.eCatFromPackToWriter(self.max_subindex, writer);
        try wire.eCatFromPackToWriter(self.object_code, writer);
        try writer.writeAll(self.name);
    }
};

test "serialize and deserialize get object description response" {
    const expected = GetObjectDescriptionResponse.init(
        2624,
        .BIT1,
        23,
        .array,
        "name",
    );
    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    var writer = std.Io.Writer.fixed(&bytes);
    try expected.serialize(&writer);
    const byte_size = writer.buffered().len;
    try std.testing.expectEqual(@as(usize, 2 + 2 + 1 + 1 + 4), byte_size);
    const actual = try GetObjectDescriptionResponse.deserialize(bytes[0..byte_size]);
    try std.testing.expect(GetObjectDescriptionResponse.eq(expected, actual));
}

/// Get Entry Description Response
///
/// This is encapsulated and transferred as service_data in SDOInfoResponse.
///
/// Ref: IEC 61158-6-12:2019 5.6.3.2
pub const GetEntryDescriptionResponse = struct {
    index: u16,
    subindex: u8,
    value_info: coe.ValueInfo,
    data_type: coe.DataTypeArea,
    bit_length: u16,
    object_access: coe.ObjectAccess,
    data: []const u8,

    pub const max_data_length = 2048; // TODO: this is arbitrary

    fn eq(self: GetEntryDescriptionResponse, operand: GetEntryDescriptionResponse) bool {
        return self.index == operand.index and
            self.subindex == operand.subindex and
            self.value_info == operand.value_info and
            self.data_type == operand.data_type and
            self.bit_length == operand.bit_length and
            self.object_access == operand.object_access and
            std.mem.eql(u8, self.data, operand.data);
    }

    pub fn init(
        index: u16,
        subindex: u8,
        value_info: coe.ValueInfo,
        data_type: coe.DataTypeArea,
        bit_length: u16,
        object_access: coe.ObjectAccess,
        data: []const u8,
    ) GetEntryDescriptionResponse {
        assert(data.len <= max_data_length);
        return GetEntryDescriptionResponse{
            .index = index,
            .subindex = subindex,
            .value_info = value_info,
            .data_type = data_type,
            .bit_length = bit_length,
            .object_access = object_access,
            .data = data,
        };
    }

    pub fn deserialize(buf: []const u8) !GetEntryDescriptionResponse {
        var fbs = std.Io.Reader.fixed(buf);
        const reader = &fbs;

        const index = wire.packFromECatReader(u16, reader) catch return error.InvalidMbxContent;
        const subindex = wire.packFromECatReader(u8, reader) catch return error.InvalidMbxContent;
        const value_info = wire.packFromECatReader(coe.ValueInfo, reader) catch return error.InvalidMbxContent;
        const data_type = wire.packFromECatReader(coe.DataTypeArea, reader) catch return error.InvalidMbxContent;
        const bit_length = wire.packFromECatReader(u16, reader) catch return error.InvalidMbxContent;
        const object_access = wire.packFromECatReader(coe.ObjectAccess, reader) catch return error.InvalidMbxContent;

        const data_length = fbs.end - fbs.seek;
        if (data_length > max_data_length) return error.InvalidMbxContent;
        assert(data_length <= max_data_length);
        const data = try reader.take(data_length);
        return GetEntryDescriptionResponse{
            .index = index,
            .subindex = subindex,
            .value_info = value_info,
            .data_type = data_type,
            .bit_length = bit_length,
            .object_access = object_access,
            .data = data,
        };
    }

    pub fn serialize(self: GetEntryDescriptionResponse, writer: *std.Io.Writer) !void {
        try wire.eCatFromPackToWriter(self.index, writer);
        try wire.eCatFromPackToWriter(self.subindex, writer);
        try wire.eCatFromPackToWriter(self.value_info, writer);
        try wire.eCatFromPackToWriter(self.data_type, writer);
        try wire.eCatFromPackToWriter(self.bit_length, writer);
        try wire.eCatFromPackToWriter(self.object_access, writer);
        try writer.writeAll(self.data);
    }
};

test "serialize and deserialize get entry description response" {
    const expected = GetEntryDescriptionResponse.init(
        53,
        56,
        .{
            .default_value = true,
            .maximum_value = false,
            .minimum_value = true,
            .unit_type = false,
        },
        .BITARR8,
        234,
        .{
            .read_OP = false,
            .backup = true,
            .read_PREOP = true,
            .read_SAFEOP = false,
            .rxpdo_mappable = true,
            .setting = true,
            .write_OP = false,
            .txpdo_mappable = false,
            .write_PREOP = false,
            .write_SAFEOP = true,
        },
        "foo",
    );
    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    var writer = std.Io.Writer.fixed(&bytes);
    try expected.serialize(&writer);
    const byte_size = writer.buffered().len;
    try std.testing.expectEqual(@as(usize, 2 + 1 + 1 + 2 + 2 + 2 + 3), byte_size);
    const actual = try GetEntryDescriptionResponse.deserialize(bytes[0..byte_size]);
    try std.testing.expect(GetEntryDescriptionResponse.eq(expected, actual));
}

/// SDO Info Error Request
///
/// Ref: IEC 61158-6-12:2019 5.6.3.8
pub const SDOInfoError = packed struct(u128) {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,
    sdo_info_header: coe.SDOInfoHeader,
    abort_code: SDOAbortCode,

    pub fn init(
        cnt: u3,
        station_address: u16,
        abort_code: SDOAbortCode,
    ) SDOInfoError {
        assert(cnt != 0);
        return SDOInfoError{
            .mbx_header = .{
                .length = 10,
                .address = station_address,
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
                .opcode = .sdo_info_error_request,
                .incomplete = false,
                .fragments_left = 0,
            },
            .abort_code = abort_code,
        };
    }

    pub fn deserialize(buf: []const u8) !SDOInfoError {
        var fbs = std.io.Reader.fixed(buf);
        return try wire.packFromECatReader(SDOInfoError, &fbs);
    }

    pub fn serialize(self: SDOInfoError, writer: *std.Io.Writer) !void {
        try wire.eCatFromPackToWriter(self, writer);
    }
};

test "serialize and deserialize sdo info error" {
    const expected = SDOInfoError.init(
        3,
        1234,
        .AccessFailedDueToHardwareError,
    );
    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    var writer = std.Io.Writer.fixed(&bytes);
    try expected.serialize(&writer);
    const byte_size = writer.buffered().len;
    try std.testing.expectEqual(@as(usize, 6 + 2 + 4 + 4), byte_size);
    const actual = try SDOInfoError.deserialize(&bytes);
    try std.testing.expectEqualDeep(expected, actual);
}

/// Emergency Request
///
/// Ref: IEC 61158-6-12:2019 5.6.4.1
pub const Emergency = packed struct(u128) {
    mbx_header: mailbox.Header,
    coe_header: coe.Header,
    error_code: u16,
    error_register: u8,
    data: u40,

    pub fn init(
        cnt: u3,
        station_address: u16,
        error_code: u16,
        error_register: u8,
        data: u40,
    ) Emergency {
        return Emergency{
            .mbx_header = .{
                .length = 10,
                .address = station_address,
                .channel = 0,
                .priority = 0,
                .type = .CoE,
                .cnt = cnt,
            },
            .coe_header = .{
                .number = 0,
                .service = .emergency,
            },
            .error_code = error_code,
            .error_register = error_register,
            .data = data,
        };
    }

    pub fn deserialize(buf: []const u8) !Emergency {
        var fbs = std.Io.Reader.fixed(buf);
        return try wire.packFromECatReader(Emergency, &fbs);
    }

    pub fn serialize(self: Emergency, writer: *std.Io.Writer) !void {
        try wire.eCatFromPackToWriter(self, writer);
    }
};

test "serialize and deserialize emergency request" {
    const expected = Emergency.init(
        4,
        234,
        2366,
        23,
        3425654,
    );
    var bytes = std.mem.zeroes([mailbox.max_size]u8);
    var writer = std.Io.Writer.fixed(&bytes);
    try expected.serialize(&writer);
    const byte_size = writer.buffered().len;
    try std.testing.expectEqual(@as(usize, 6 + 2 + 8), byte_size);
    const actual = try Emergency.deserialize(&bytes);
    try std.testing.expectEqualDeep(expected, actual);
}

test {
    std.testing.refAllDecls(@This());
}
