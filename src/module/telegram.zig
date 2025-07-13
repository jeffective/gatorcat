const std = @import("std");
const lossyCast = std.math.lossyCast;
const assert = std.debug.assert;
const big = std.builtin.Endian.big;
const little = std.builtin.Endian.little;

const logger = @import("root.zig").logger;
const wire = @import("wire.zig");

/// EtherCAT command, present in the EtherCAT datagram header.
pub const Command = enum(u8) {
    /// No operation.
    /// The subdevice ignores the command.
    NOP = 0x00,
    /// Auto increment physical read.
    /// A subdevice increments the address.
    /// A subdevice writes the data it has read to the EtherCAT datagram
    /// if the address received is zero.
    APRD,
    /// Auto increment physical write.
    /// A subdevice increments the address.
    /// A subdevice writes data to a memory area if the address received is zero.
    APWR,
    /// Auto increment physical read write.
    /// A subdevice increments the address.
    /// A subdevice writes the data it has read to the EtherCAT datagram and writes
    /// the newly acquired data to the same memory area if the received address is zero.
    APRW,
    /// Configured address physical read.
    /// A subdevice writes the data it has read to the EtherCAT datagram if its subdevice
    /// address matches one of the addresses configured in the datagram.
    FPRD,
    /// Configured address physical write.
    /// A subdevice writes data to a memory area if its subdevice address matches one
    /// of the addresses configured in the datagram.
    FPWR,
    /// Configured address physical read write.
    /// A subdevice writes the data it has read to the EtherCAT datagram and writes
    /// the newly acquired data to the same memory area if its subdevice address matches
    /// one of the addresses configured in the datagram.
    FPRW,
    /// Broadcast read.
    /// All subdevices write a logical OR of the data from the memory area and the data
    /// from the EtherCAT datagram to the EtherCAT datagram. All subdevices increment the
    /// position field.
    BRD,
    /// Broadcast write.
    /// All subdevices write data to a memory area. All subdevices increment the position field.
    BWR,
    /// Broadcast read write.
    /// All subdevices write a logical OR of the data from the memory area and the data from the
    /// EtherCAT datagram to the EtherCAT datagram; all subdevices write data to the memory area.
    /// BRW is typically not used. All subdevices increment the position field.
    BRW,
    /// Logical memory read.
    /// A subdevice writes data it has read to the EtherCAT datagram if the address received
    /// matches one of the FMMU areas configured for reading.
    LRD,
    /// Logical memory write.
    /// Subdevices write data to their memory area if the address received matches one of
    /// the FMMU areas configured for writing.
    LWR,
    /// Logical memory read write.
    /// A subdevice writes data it has read to the EtherCAT datagram if the address received
    /// matches one of the FMMU areas configured for reading. Subdevices write data to their memory area
    /// if the address received matches one of the FMMU areas configured for writing.
    LRW,
    /// Auto increment physical read multiple write.
    /// A subdevice increments the address field. A subdevice writes data it has read to the EtherCAT
    /// datagram when the address received is zero, otherwise it writes data to the memory area.
    ARMW,
    /// Configured address physical read multiple write.
    FRMW,
    /// Never serialize an unnamed value. This is here only to help ensure we
    /// handle invalid data correctly on deserialization.
    _,
};

/// Position Address (Auto Increment Address)
pub const PositionAddress = packed struct(u32) {
    /// Each subdevice increments this address. The subdevice is addressed if position=0.
    autoinc_address: u16,
    /// local register address or local memory address of the ESC
    offset: u16,
};

pub const StationAddress = packed struct(u32) {
    /// The subdevice is addressed if its address corresponds to the configured station address
    /// or the configured station alias (if enabled).
    station_address: u16,
    /// local register address or local memory address of the ESC
    offset: u16,
};

pub const LogicalAddress = u32;

/// Datagram
///
/// The IEC standard specifies the different commands
/// as different structures. However, the structure are all
/// very similar to they are combined here as one datagram.
///
/// The ETG standards appear to do combine them all too.
///
/// The only difference between the different commands is the addressing
/// scheme. They all have the same size.
///
/// Ref: IEC 61158-4-12:2019 5.4.1.2
pub const Datagram = struct {
    header: Header,
    data: []u8,
    /// Working counter.
    /// The working counter is incremented if an EtherCAT device was successfully addressed
    /// and a read operation, a write operation or a read/write operation was executed successfully.
    /// Each datagram can be assigned a value for the corking counter that is expected after the
    /// telegram has passed through all devices. The maindevice can check whether an EtherCAT datagram
    /// was processed successfully by comparing the value to be expected for the working counter
    /// with the actual value of the working counter after it has passed through all devices.
    ///
    /// For a read command: if successful wkc+=1.
    /// For a write command: if write command successful wkc+=1.
    /// For a read/write command: if read command successful wkc+=1, if write command successful wkc+=2. If both wkc+=3.
    wkc: u16,

    pub fn init(command: Command, address: u32, next: bool, data: []u8) Datagram {
        assert(data.len < max_data_length);
        return Datagram{
            .header = .{
                .command = command,
                .address = .{ .logical = address },
                .length = @intCast(data.len),
                .circulating = false,
                .next = next,
                .irq = 0,
            },
            .data = data,
            .wkc = 0,
        };
    }

    pub fn getLength(self: Datagram) u11 {
        return self.header.length +
            @divExact(@bitSizeOf(Header), 8) +
            @divExact(@bitSizeOf(u16), 8);
    }

    /// max length of datagram data field
    pub const max_data_length = EtherCATFrame.max_datagrams_length -
        @divExact(@bitSizeOf(Header), 8) -
        @divExact(@bitSizeOf(u16), 8); // wkc

    /// number of bytes required when there is no data.
    pub const data_overhead = @divExact(@bitSizeOf(Header), 8) +
        @divExact(@bitSizeOf(u16), 8); // wkc

    /// Datagram Header
    ///
    /// Ref: IEC 61158-4-12:2019 5.4.1.2
    pub const Header = packed struct(u80) {
        /// service command, APRD etc.
        command: Command,
        /// used my maindevice to identify duplicate or lost datagrams
        idx: u8 = 0,
        /// auto-increment, configured station, or logical address
        /// when position addressing
        address: packed union {
            position: PositionAddress,
            station: StationAddress,
            logical: LogicalAddress,
        },
        /// length of following data, in bytes, not including wkc
        length: u11,
        /// reserved, 0
        reserved: u3 = 0,
        /// true when frame has circulated at least once, else false
        circulating: bool,
        /// multiple datagrams, true when more datagrams follow, else false
        next: bool,
        /// EtherCAT event request register of all subdevices combined with
        /// a logical OR. Two byte bitmask (IEC 61131-3 WORD)
        irq: u16,
    };
};

// TODO: EtherCAT frame structure containing network variables. Ref: IEC 61158-4-12:2019 5.3.3

/// EtherCAT Frame.
/// Must be embedded inside an Ethernet Frame.
///
/// Also called DLPDU (Data Link Layer Process Data Unit).
///
/// Ref: IEC 61158-4-12:2019 5.3.3
pub const EtherCATFrame = struct {
    header: Header,
    datagrams: []Datagram,

    pub fn init(dgrams: []Datagram) EtherCATFrame {
        assert(dgrams.len > 0); // no datagrams
        assert(dgrams.len <= max_datagrams); // too many datagrams
        for (dgrams) |datagram| {
            assert(datagram.data.len > 0); // zero length datagrams are not supported
        }
        var header_length: u11 = 0;
        for (dgrams) |datagram| {
            header_length += @intCast(datagram.getLength());
        }
        const header = Header{
            .length = header_length,
        };
        return EtherCATFrame{
            .header = header,
            .datagrams = dgrams,
        };
    }

    fn getLength(self: EtherCATFrame) usize {
        return self.header.length + @divExact(@bitSizeOf(Header), 8);
    }

    /// when sending and receiving a frame,
    /// only certain parts of the frame should change.
    /// We choose to not trust the received frame.
    /// This function determines if the frame is "currupted"
    /// when compared to an "original" frame.
    pub fn isCurrupted(self: *const EtherCATFrame, original: *const EtherCATFrame) bool {
        if (self.header != original.header) {
            return true;
        }
        if (self.datagrams.len != original.datagrams.len) {
            return true;
        }
        assert(self.datagrams.len == original.datagrams.len);
        for (self.datagrams, original.datagrams, 0..) |self_dgram, orig_dgram, i| {
            switch (self_dgram.header.command) {
                .BWR, .BRD, .BRW, .APRD, .APWR, .APRW, .ARMW, .FPRD, .FPWR, .FPRW, .LRD, .LWR, .LRW, .FRMW, .NOP => {},
                _ => return true,
            }
            if (self_dgram.header.command != orig_dgram.header.command) {
                return true;
            }
            // address may be incremented depending on commands
            const check_addr: bool = switch (orig_dgram.header.command) {
                .BWR, .BRD, .BRW, .APRD, .APWR, .APRW, .ARMW => false,
                .FPRD, .FPWR, .FPRW, .LRD, .LWR, .LRW, .FRMW, .NOP => true,
                _ => unreachable, // sent datagrams should never have been _
            };
            if (check_addr and @as(u32, @bitCast(self_dgram.header.address)) != @as(u32, @bitCast(orig_dgram.header.address))) return true;
            // idx is skipped since it is injected on serialization
            if (i != 0 and self_dgram.header.idx != orig_dgram.header.idx) return true;
            if (self_dgram.header.length != orig_dgram.header.length) return true;
            if (self_dgram.header.circulating != orig_dgram.header.circulating) return true;
            if (self_dgram.header.next != orig_dgram.header.next) return true;
            // TODO: irq can change, i think?
            if (self_dgram.data.len != orig_dgram.data.len) return true;
            // enforce wkc unchanged for NOP
            if (self_dgram.header.command == .NOP and self_dgram.wkc != orig_dgram.wkc) return true;
        }
        return false;
    }

    pub const max_datagrams_length = max_frame_length -
        @divExact(@bitSizeOf(EthernetFrame.Header), 8) -
        @divExact(@bitSizeOf(Header), 8);

    pub const max_datagrams = 15;

    /// EtherCAT Header
    ///
    /// Ref: IEC 61158-4-12:2019 5.3.3
    pub const Header = packed struct(u16) {
        /// length of the following datagrams (not including this header)
        length: u11,
        reserved: u1 = 0,
        /// ESC's only support EtherCAT commands (0x1)
        type: u4 = 0x1,
    };

    pub const empty = EtherCATFrame{ .header = .{ .length = 0 }, .datagrams = &.{} };
};

pub const EtherType = enum(u16) {
    UDP_ETHERCAT = 0x8000,
    ETHERCAT = 0x88a4,
    _,
};

// TODO: EtherCAT in UDP Frame. Ref: IEC 61158-4-12:2019 5.3.2

/// Ethernet Frame
///
/// This is what is actually sent on the wire.
/// It is a standard ethernet frame with EtherCAT data in it.
///
/// Ref: IEC 61158-4-12:2019 5.3.1
pub const EthernetFrame = struct {
    header: Header,
    ethercat_frame: EtherCATFrame,
    n_padding: u8, // number of zero padding bytes

    pub fn init(
        header: Header,
        ethercat_frame: EtherCATFrame,
    ) EthernetFrame {
        const length: usize = @divExact(@bitSizeOf(Header), 8) + ethercat_frame.getLength();
        const n_pad: u8 = @intCast(min_frame_length -| length);

        return EthernetFrame{
            .header = header,
            .ethercat_frame = ethercat_frame,
            .n_padding = n_pad,
        };
    }

    /// Serialize this frame into the out buffer
    /// for transmission on the line.
    /// Returns number of bytes written, or error.
    /// If idx is provided, it will be injected into the first datagram.
    pub fn serialize(self: *EthernetFrame, maybe_idx: ?u8, out: []u8) !usize {
        var fbs = std.io.fixedBufferStream(out);
        const writer = fbs.writer();
        try writer.writeInt(u48, self.header.dest_mac, big);
        try writer.writeInt(u48, self.header.src_mac, big);
        try writer.writeInt(u16, @intFromEnum(self.header.ether_type), big);
        try wire.eCatFromPackToWriter(self.ethercat_frame.header, writer);
        for (self.ethercat_frame.datagrams, 0..) |datagram, i| {
            // inject idx at first datagram to identify frame
            if (i == 0) {
                var header_copy = datagram.header;
                if (maybe_idx) |idx| {
                    header_copy.idx = idx;
                }
                try wire.eCatFromPackToWriter(header_copy, writer);
            } else {
                try wire.eCatFromPackToWriter(datagram.header, writer);
            }
            try writer.writeAll(datagram.data);
            try wire.eCatFromPackToWriter(datagram.wkc, writer);
        }
        try writer.writeByteNTimes(0, self.n_padding);
        return fbs.getWritten().len;
    }

    pub fn deserialize(
        /// received bytes from the wire,
        /// lifetime must exceed return value
        received: []u8,
        /// uninitialized datagrams,
        /// lifetime must exceed return value
        scratch_datagrams: *[15]Datagram,
    ) !EthernetFrame {
        var fbs_reading = std.io.fixedBufferStream(received);
        const reader = fbs_reading.reader();

        const ethernet_header = Header{
            .dest_mac = try reader.readInt(u48, big),
            .src_mac = try reader.readInt(u48, big),
            .ether_type = @enumFromInt(try reader.readInt(u16, big)),
        };
        if (ethernet_header.ether_type != .ETHERCAT) {
            return error.NotAnEtherCATFrame;
        }
        const ethercat_header = wire.packFromECatReader(EtherCATFrame.Header, reader) catch return error.InvalidFrame;
        const bytes_remaining = try fbs_reading.getEndPos() - try fbs_reading.getPos();
        const bytes_total = try fbs_reading.getEndPos();
        if (bytes_total < min_frame_length) {
            return error.InvalidFrameLengthTooSmall;
        }
        if (ethercat_header.length > bytes_remaining) {
            logger.debug(
                "length field: {}, remaining: {}, end pos: {}",
                .{ ethercat_header.length, bytes_remaining, try fbs_reading.getEndPos() },
            );
            return error.InvalidEtherCATHeader;
        }

        var scratch_datagrams_used: usize = 0;
        reading_datagrams: for (0..15) |i| {
            const header = wire.packFromECatReader(Datagram.Header, reader) catch return error.CurruptedFrame;
            fbs_reading.seekBy(header.length) catch return error.CurruptedFrame;
            const datagram_data: []u8 = received[try fbs_reading.getPos() - header.length .. try fbs_reading.getPos()];
            const wkc = wire.packFromECatReader(u16, reader) catch return error.CurruptedFrame;
            scratch_datagrams[i] = Datagram{
                .header = header,
                .data = datagram_data,
                .wkc = wkc,
            };
            scratch_datagrams_used += 1;
            if (!header.next) break :reading_datagrams;
        } else {
            return error.CurruptedFrame; // should always see header.next false
        }
        assert(scratch_datagrams_used > 0);
        const ethercat_frame = EtherCATFrame.init(scratch_datagrams[0..scratch_datagrams_used]);
        return EthernetFrame.init(
            ethernet_header,
            ethercat_frame,
        );
    }

    /// Ethernet Header
    ///
    /// Ref: IEC 61158-4-12:2019 5.3.1
    pub const Header = packed struct(u112) {
        dest_mac: u48,
        src_mac: u48,
        ether_type: EtherType,
    };
};

test "ethernet frame serialization" {
    var data: [4]u8 = .{ 0x01, 0x02, 0x03, 0x04 };
    var datagrams: [1]Datagram = .{
        Datagram.init(.BRD, 0xABCDEF12, false, &data),
    };
    var frame = EthernetFrame.init(
        .{
            .dest_mac = 0x1122_3344_5566,
            .src_mac = 0xAABB_CCDD_EEFF,
            .ether_type = .ETHERCAT,
        },
        EtherCATFrame.init(&datagrams),
    );
    var out_buf: [max_frame_length]u8 = undefined;
    const serialized = out_buf[0..try frame.serialize(123, &out_buf)];
    const expected = [min_frame_length]u8{
        // zig fmt: off

        // ethernet header
        0x11, 0x22, 0x33, 0x44, 0x55, 0x66, // src mac
        0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff, // dest mac
        0x88, 0xa4, // 0x88a4 big endian

        // ethercat header
        0x10, 0b0001_0_000, // length=16, reserved=0, type=1

        // datagram header
        0x07, // BRD
        123, // idx
        0x12, 0xEF, 0xCD, 0xAB, // address
        0x04, //length
        0x00, // reserved, circulating, next
        0x00, 0x00, // irq
        0x01, 0x02, 0x03, 0x04, // data
        // wkc
        0x00, 0x00,
        // padding (28 bytes since 32 bytes above)
        0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00,
        // zig fmt: on
    };
    try std.testing.expectEqualSlices(u8, &expected, serialized);
}

test "ethernet frame serialization / deserialization" {

    var data: [4]u8 = .{ 0x01, 0x02, 0x03, 0x04 };
    var datagrams: [1]Datagram = .{
        Datagram.init(.BRD, 0xABCD, false, &data,),
    };

    var frame = EthernetFrame.init(
        .{
            .dest_mac = 0xffff_ffff_ffff,
            .src_mac = 0xAAAA_AAAA_AAAA,
            .ether_type = .ETHERCAT,
        },
        EtherCATFrame.init(&datagrams),
    );

    var out_buf: [max_frame_length]u8 = undefined;
    const serialized = out_buf[0..try frame.serialize(0, &out_buf)];
    var allocator = std.testing.allocator;
    const serialize_copy = try allocator.dupe(u8, serialized);
    defer allocator.free(serialize_copy);

    var data2: [4]u8 = undefined;
    var datagrams2 = datagrams;
    datagrams2[0].data = &data2;

    var scratch_datagrams: [15]Datagram = undefined;
    const frame2 = try EthernetFrame.deserialize(serialize_copy, &scratch_datagrams);

    try std.testing.expect(!frame2.ethercat_frame.isCurrupted(&frame.ethercat_frame));
    try std.testing.expectEqual(frame.header, frame2.header);
    try std.testing.expectEqual(frame.ethercat_frame.header, frame2.ethercat_frame.header);
    try std.testing.expectEqual(frame.ethercat_frame.datagrams.len, frame2.ethercat_frame.datagrams.len);
    try std.testing.expectEqual(frame.ethercat_frame.datagrams.len, 1);
    try std.testing.expectEqual(@as(u80, @bitCast(frame.ethercat_frame.datagrams[0].header)),@as(u80, @bitCast(frame2.ethercat_frame.datagrams[0].header)));
    try std.testing.expectEqualSlices(u8, frame.ethercat_frame.datagrams[0].data, frame2.ethercat_frame.datagrams[0].data);
    try std.testing.expectEqual(frame.ethercat_frame.datagrams[0].wkc, frame2.ethercat_frame.datagrams[0].wkc);
    try std.testing.expectEqual(frame.n_padding, frame2.n_padding);
}

/// Max frame length
/// Includes header, but not FCS (intended to be the max allowable size to
/// give to a raw socket send().)
/// FCS is handled by hardware and not normally returned to user.
///
/// Constructed of 1500 payload and 14 byte header.
pub const max_frame_length = 1514;
comptime {
    assert(max_frame_length == @divExact(@bitSizeOf(EthernetFrame.Header), 8) + 1500);
}
pub const min_frame_length = 60;

test {
    std.testing.refAllDecls(@This());
}
