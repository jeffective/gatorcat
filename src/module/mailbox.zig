const std = @import("std");
const assert = std.debug.assert;
const Timer = std.time.Timer;
const ns_per_us = std.time.ns_per_us;

const esc = @import("esc.zig");
pub const coe = @import("mailbox/coe.zig");
const nic = @import("nic.zig");
const Port = @import("Port.zig");
const telegram = @import("telegram.zig");
const wire = @import("wire.zig");

pub const HalfConfiguration = struct {
    /// Start memory address of memory governed by the mailbox sync manager.
    start_addr: u16,
    /// Length of the memory region, in bytes, governed by the mailbox sync manager.
    length: u16,

    pub fn init(start_addr: u16, length: u16) !HalfConfiguration {
        if (start_addr == 0 or
            length == 0 or
            length > max_size or
            length < min_size)
            return error.InvalidMbxConfiguration;

        return HalfConfiguration{
            .start_addr = start_addr,
            .length = length,
        };
    }

    pub fn isValid(self: HalfConfiguration) bool {
        return !(self.start_addr == 0 or
            self.length == 0 or
            self.length > max_size or
            self.length < min_size);
    }
};

pub const Configuration = struct {
    /// For communication from subdevice to maindevice
    mbx_in: HalfConfiguration,
    /// For communication from maindevice to subdevice
    mbx_out: HalfConfiguration,

    pub fn init(mbx_in_start_addr: u16, mbx_in_length: u16, mbx_out_start_addr: u16, mbx_out_length: u16) !Configuration {
        return Configuration{
            .mbx_in = try HalfConfiguration.init(mbx_in_start_addr, mbx_in_length),
            .mbx_out = try HalfConfiguration.init(mbx_out_start_addr, mbx_out_length),
        };
    }

    pub fn isValid(self: Configuration) bool {
        return self.mbx_in.isValid() and self.mbx_out.isValid();
    }
};

/// Write to mailbox out (write data from maindevice to subdevice mailbox).
///
/// You must ensure that the size of the content will fit in the mailbox size
/// specified.
/// The mailbox configuration is checked against the provided parameters.
pub fn writeMailboxOut(
    port: *Port,
    station_address: u16,
    recv_timeout_us: u32,
    mbx_out: HalfConfiguration,
    content: OutContent,
) !void {
    assert(mbx_out.isValid());

    const act_mbx_out = try port.fprdPackWkc(
        esc.SyncManagerAttributes,
        .{ .station_address = station_address, .offset = @intFromEnum(esc.RegisterMap.SM0) },
        recv_timeout_us,
        1,
    );

    // Mailbox configured correctly?
    // Can check this for free since we already have the full SM attr.
    if (act_mbx_out.length != mbx_out.length or
        act_mbx_out.physical_start_address != mbx_out.start_addr or
        act_mbx_out.control.buffer_type != .mailbox or
        act_mbx_out.control.direction != .output or
        act_mbx_out.control.DLS_user_event_enable != true or
        act_mbx_out.activate.channel_enable != true)
    {
        // This may occur if:
        // 1. the subdevice loses power etc.
        // 2. we screwed up the configuration
        return error.MisbehavingSubdevice;
    }

    // Mailbox out full?
    // This is an error since it should almost never happen.
    // If it happens it is an indication of incorrect use of this function
    // or malfunctioning subdevice.
    if (act_mbx_out.status.mailbox_full) return error.MisbehavingSubdevice; // mbx out full

    var buf = std.mem.zeroes([max_size]u8);
    var writer = std.Io.Writer.fixed(&buf);

    // impossible to contruct OutContent that is too large
    content.serialize(&writer) catch |err| switch (err) {
        error.WriteFailed => unreachable,
    };
    const size = writer.buffered().len;
    assert(size > 0);

    // you should know the size of the mailbox when calling this function
    // and you should ensure that the data will fit.
    if (size > act_mbx_out.length) unreachable;

    // We write the entire mailbox because the write will not be considered finished by the
    // sync manager until the last byte of the sync manager buffer is written to.
    //
    // TODO: optimize with fpwr to last byte of sync manager when that requires less bytes
    // over the wire.
    //
    // Ref: IEC 61158-4-12:2019 6.7.1
    try port.fpwrWkc(
        .{
            .station_address = station_address,
            .offset = act_mbx_out.physical_start_address,
        },
        buf[0..act_mbx_out.length],
        recv_timeout_us,
        1,
    );
}

pub fn readMailboxInTimeout(
    port: *Port,
    station_address: u16,
    recv_timeout_us: u32,
    mbx_in: HalfConfiguration,
    mbx_timeout_us: u32,
) !InContent {
    assert(mbx_in.isValid());

    var timer = Timer.start() catch |err| switch (err) {
        error.TimerUnsupported => unreachable,
    };

    while (timer.read() < @as(u64, mbx_timeout_us) * ns_per_us) {
        if (try readMailboxIn(
            port,
            station_address,
            recv_timeout_us,
            mbx_in,
        )) |in_content| {
            return in_content;
        }
    } else {
        return error.MbxTimeout;
    }
}

/// Read mailbox in (communications from subdevice to maindevice).
///
/// Returns null if mailbox is empty.
///
/// The mailbox configuration is checked against the provided parameters.
pub fn readMailboxIn(
    port: *Port,
    station_address: u16,
    recv_timeout_us: u32,
    mbx_in: HalfConfiguration,
) !?InContent {
    assert(mbx_in.isValid());

    const act_mbx_in = try port.fprdPackWkc(
        esc.SyncManagerAttributes,
        .{
            .station_address = station_address,
            .offset = @intFromEnum(esc.RegisterMap.SM1),
        },
        recv_timeout_us,
        1,
    );

    // Mailbox configured correctly?
    // Can check this for free since we already have the full SM attr.
    if (act_mbx_in.length != mbx_in.length or
        act_mbx_in.physical_start_address != mbx_in.start_addr or
        act_mbx_in.control.buffer_type != .mailbox or
        act_mbx_in.control.direction != .input or
        act_mbx_in.control.DLS_user_event_enable != true or
        act_mbx_in.activate.channel_enable != true)
    {
        // This may occur if:
        // 1. the subdevice loses power etc.
        // 2. we screwed up the configuration
        return error.MisbehavingSubdevice;
    }

    // Mailbox empty?
    if (!act_mbx_in.status.mailbox_full) return null;

    // We read the full size of the mailbox because the read operation is not fully completed
    // until we touch the last byte of the sync manager buffer.
    //
    // Ref: IEC 61158-4-12:2019 6.7.1
    var buf = std.mem.zeroes([max_size]u8);
    try port.fprdWkc(
        .{
            .station_address = station_address,
            .offset = act_mbx_in.physical_start_address,
        },
        // subdevice will do nothing if this size is too big.
        buf[0..act_mbx_in.length],
        recv_timeout_us,
        1,
    );
    const in_content = try InContent.deserialize(&buf);
    return in_content;
}

/// All possible contents of MailboxOut (communication from maindevice to subdevice)
pub const OutContent = union(enum) {
    coe: coe.OutContent,

    // TODO: implement other protocols

    pub fn serialize(self: OutContent, writer: *std.Io.Writer) !void {
        return switch (self) {
            .coe => self.coe.serialize(writer),
        };
    }
};

/// All possible contents of MailboxIn (communication from subdevice to maindevice)
pub const InContent = union(enum) {
    coe: coe.InContent,

    // TODO: implement other protocols

    pub fn deserialize(buf: []const u8) !InContent {
        return switch (try identify(buf)) {
            .coe => InContent{ .coe = coe.InContent.deserialize(buf) catch return error.InvalidMbxContent },
        };
    }

    /// identifiy the content of the mailbox in buffer
    pub fn identify(buf: []const u8) !std.meta.Tag(InContent) {
        var reader = std.io.Reader.fixed(buf);
        const mbx_header = wire.packFromECatReader(Header, &reader) catch return error.InvalidMbxContent;

        return switch (mbx_header.type) {
            .CoE => return .coe,
            .ERR, .AoE, .EoE, .FoE, .SoE, .VoE => return error.NotImplemented,
            _ => return error.InvalidMbxContent,
        };
    }
};

/// Mailbox Types
///
/// Ref: IEC 61158-4-12:2019 5.6
pub const MailboxType = enum(u4) {
    /// error
    ERR = 0x00,
    /// ADS over EtherCAT (AoE)
    AoE,
    /// Ethernet over EtherCAT (EoE)
    EoE,
    /// CAN Application Protocol over EtherCAT (CoE)
    CoE,
    /// File Access over EtherCAT (FoE)
    FoE,
    /// Servo Drive Profile over EtherCAT (SoE)
    SoE,
    /// Vendor Specfic over EtherCAT (VoE)
    VoE = 0x0f,
    _,
};

pub const MailboxErrorCode = enum(u16) {
    /// syntax of 6 octet mailbox header is wrong
    syntax = 0x01,
    /// specified mailbox protocol is not supported
    unsupported_protocol,
    /// channel field contains wrong value (a subdevice can ignore the channel field)
    invalid_channel,
    /// service in the mailbox protocol is not supported
    service_not_supported,
    /// mailbox protocl header of the mailbox protocol is wrong (without
    /// the 6 octet mailbox header)
    invalid_header,
    /// length of the recieved mailbox data is too short
    size_too_short,
    /// mailbox protocol cannot be processed because of limited resources,
    no_more_memory,
    /// length of the data is inconsistent
    invalid_size,
    /// mailbox service already in use
    service_in_work,
};

/// Mailbox Error Reply
///
/// Ref: IEC 61158-4-12:2019 5.6
pub const MailboxErrorReplyServiceData = struct {
    type: u16, // 0x01: mailbox command
    detail: MailboxErrorCode,
};

pub const StationAddress = u16;

/// Mailbox Header
///
/// Ref: IEC 61158-4-12:2019 5.6
pub const Header = packed struct(u48) {
    /// length of mailbox service data
    length: u16,
    address: StationAddress,
    /// reserved
    channel: u6,
    /// 0: lowest priority, 3: highest priority
    priority: u2,
    /// type of mailbox communication
    type: MailboxType,
    /// counter for the mailbox services
    /// zero is reserved. 1 is start value. next value after 7 is 1.
    ///
    /// Subdevice shall increment the counter for each new mailbox service. The maindevice
    /// shall check this for detection of lost mailbox services. The maindevice shall
    /// increment the counter value before retrying and the subdevice shall check for this
    /// for detection of repeat service. The subdevice shall not check the sequence of the
    /// counter value. The maindevice and the subdevice counters are independent.
    cnt: u3,
    reserved: u1 = 0,
};

/// Mailbox
///
/// Mailbox communication data. Goes in data field of datagram.
///
/// Ref: IEC 61158-4-12:2019 5.6
pub const Mailbox = struct {
    mbx_header: Header,
    /// mailbox service data
    data: []u8,
};

/// The maximum mailbox size is limited by the maximum data that can be
/// read by a single datagram.
/// This applies to both mailbox out and mailbox in.
pub const max_size = 1486;
// Derivation of max_size:
comptime {
    assert(max_size == telegram.max_frame_length - // 1514
        @divExact(@bitSizeOf(telegram.EthernetFrame.Header), 8) - // u112
        @divExact(@bitSizeOf(telegram.EtherCATFrame.Header), 8) - // u16
        @divExact(@bitSizeOf(telegram.Datagram.Header), 8) - // u80
        @divExact(@bitSizeOf(u16), 8)); // wkc
}

/// The minimum mailbox size is the size required to hold
/// the max of:
/// 1. smallest coe segment request.
/// 2. smallest coe normal request.
/// 3. smallest coe expedited request.
pub const min_size = 16;

// TODO: derive min_size

test {
    std.testing.refAllDecls(@This());
}
