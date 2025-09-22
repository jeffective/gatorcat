//! Serilization and deserialization utilities specific to EtherCAT.

const std = @import("std");
const assert = std.debug.assert;

const native_endian = @import("builtin").target.cpu.arch.endian();

pub fn packedSize(comptime T: type) comptime_int {
    comptime assert(isECatPackable(T));
    return @divExact(@bitSizeOf(T), 8);
}

// TODO: check recursively for struct fields that are enums?
pub fn isECatPackable(comptime T: type) bool {
    if (@bitSizeOf(T) % 8 != 0) return false;
    return switch (@typeInfo(T)) {
        .@"struct" => |_struct| blk: {
            // must be a packed struct
            break :blk (_struct.layout == .@"packed");
        },
        .int, .float => true,
        .@"union" => |_union| blk: {
            // must be a packed union
            break :blk (_union.layout == .@"packed");
        },
        .@"enum" => |_enum| blk: {
            // TODO: check enum cannot contain invalid values after bitcast
            // i.e. must be non-exhaustive or represent all values of
            // backing integer.
            break :blk !_enum.is_exhaustive;
        },
        else => false,
    };
}

pub fn eCatFromPackToWriter(pack: anytype, writer: anytype) !void {
    comptime assert(isECatPackable(@TypeOf(pack)));
    var bytes = eCatFromPack(pack);
    try writer.writeAll(&bytes);
}

/// convert a packed struct to bytes that can be sent via ethercat
///
/// the packed struct must have bitwidth that is a multiple of 8
pub fn eCatFromPack(pack: anytype) [@divExact(@bitSizeOf(@TypeOf(pack)), 8)]u8 {
    comptime assert(isECatPackable(@TypeOf(pack)));
    var bytes: [@divExact(@bitSizeOf(@TypeOf(pack)), 8)]u8 = undefined;
    switch (native_endian) {
        .little => {
            if (@typeInfo(@TypeOf(pack)) == .@"enum") {
                bytes = @bitCast(@as(@typeInfo(@TypeOf(pack)).@"enum".tag_type, @intFromEnum(pack)));
            } else {
                bytes = @bitCast(pack);
            }
        },
        .big => {
            if (@typeInfo(@TypeOf(pack)) == .@"enum") {
                bytes = @bitCast(@as(@typeInfo(@TypeOf(pack)).@"enum".tag_type, @intFromEnum(pack)));
            } else {
                bytes = @bitCast(pack);
            }
            std.mem.reverse(u8, &bytes);
        },
    }
    return bytes;
}

pub fn zerosFromPack(comptime T: type) [@divExact(@bitSizeOf(T), 8)]u8 {
    comptime assert(isECatPackable(T));
    return std.mem.zeroes([@divExact(@bitSizeOf(T), 8)]u8);
}

test "eCatFromPack" {
    const Command = packed struct(u8) {
        flag: bool = true,
        reserved: u7 = 0,
    };
    try std.testing.expectEqual(
        [_]u8{1},
        eCatFromPack(Command{}),
    );

    const Command2 = packed struct(u16) {
        flag: bool = true,
        reserved: u7 = 0,
        num: u8 = 7,
    };
    try std.testing.expectEqual(
        [_]u8{ 1, 7 },
        eCatFromPack(Command2{}),
    );

    const Command3 = packed struct(u24) {
        flag: bool = true,
        reserved: u7 = 0,
        num: u16 = 0x1122,
    };
    try std.testing.expectEqual(
        [_]u8{ 1, 0x22, 0x11 },
        eCatFromPack(Command3{}),
    );

    const Command4 = packed struct(u32) {
        flag: bool = true,
        reserved: u7 = 0,
        num: u16 = 0x1122,
        num2: u5 = 0x03,
        num3: u3 = 0,
    };
    try std.testing.expectEqual(
        [_]u8{ 1, 0x22, 0x11, 0x03 },
        eCatFromPack(Command4{}),
    );
    const Command5 = packed struct(u40) {
        flag: bool = true,
        reserved: u7 = 0,
        num: u16 = 0x1122,
        num2: u5 = 0x03,
        num3: u3 = 0,
        num4: u8 = 0xAB,
    };
    try std.testing.expectEqual(
        [_]u8{ 1, 0x22, 0x11, 0x03, 0xAB },
        eCatFromPack(Command5{}),
    );

    const command_enum: enum(u16) { zero, one, _ } = .one;
    try std.testing.expectEqual(
        [_]u8{ 0x01, 0x00 },
        eCatFromPack(command_enum),
    );
}

/// Read a packed struct, int, or float from a reader containing
/// EtherCAT (little endian) data into host endian representation.
pub fn packFromECatReader(comptime T: type, reader: *std.Io.Reader) !T {
    comptime assert(isECatPackable(T));
    var bytes: [@divExact(@bitSizeOf(T), 8)]u8 = undefined;
    try reader.readSliceAll(&bytes);
    return packFromECat(T, bytes);
}

test packFromECatReader {
    const bytes = [_]u8{ 0, 1, 2 };
    var fbs = std.Io.Reader.fixed(&bytes);
    const reader = &fbs;
    const Pack = packed struct(u24) {
        a: u8,
        b: u8,
        c: u8,
    };
    const expected_pack = Pack{ .a = 0, .b = 1, .c = 2 };
    const actual_pack = packFromECatReader(Pack, reader);

    try std.testing.expectEqualDeep(expected_pack, actual_pack);
}

/// Convert little endian packed bytes from EtherCAT to host representation.
///
/// Supports enums, packed structs, and most primitive types. All most have
/// bitlength divisible by 8.
pub fn packFromECat(comptime T: type, ecat_bytes: [@divExact(@bitSizeOf(T), 8)]u8) T {
    comptime assert(isECatPackable(T));
    switch (native_endian) {
        .little => {
            if (@typeInfo(T) == .@"enum") {
                return @enumFromInt(@as(@typeInfo(T).@"enum".tag_type, @bitCast(ecat_bytes)));
            }
            return @bitCast(ecat_bytes);
        },
        .big => {
            var bytes_copy = ecat_bytes;
            std.mem.reverse(u8, &bytes_copy);
            if (@typeInfo(T) == .@"enum") {
                return @enumFromInt(@as(@typeInfo(T).@"enum".tag_type, @bitCast(ecat_bytes)));
            }
            return @bitCast(bytes_copy);
        },
    }
    unreachable;
}

pub fn packFromECatSlice(comptime T: type, ecat_bytes: []const u8) T {
    comptime assert(isECatPackable(T));
    assert(ecat_bytes.len == @divExact(@bitSizeOf(T), 8));
    var bytes: [@divExact(@bitSizeOf(T), 8)]u8 = undefined;
    @memcpy(&bytes, ecat_bytes);
    return packFromECat(T, bytes);
}

test "packFromECat" {
    const Command = packed struct(u8) {
        flag: bool = true,
        reserved: u7 = 0,
    };
    try std.testing.expectEqual(
        Command{},
        packFromECat(Command, [_]u8{1}),
    );

    const Command2 = packed struct(u16) {
        flag: bool = true,
        reserved: u7 = 0,
        num: u8 = 7,
    };
    try std.testing.expectEqual(
        Command2{},
        packFromECat(Command2, [_]u8{ 1, 7 }),
    );

    const Command3 = packed struct(u24) {
        flag: bool = true,
        reserved: u7 = 0,
        num: u16 = 0x1122,
    };
    try std.testing.expectEqual(
        Command3{},
        packFromECat(Command3, [_]u8{ 1, 0x22, 0x11 }),
    );

    const Command4 = packed struct(u32) {
        flag: bool = true,
        reserved: u7 = 0,
        num: u16 = 0x1122,
        num2: u5 = 0x03,
        num3: u3 = 0,
    };
    try std.testing.expectEqual(
        Command4{},
        packFromECat(Command4, [_]u8{ 1, 0x22, 0x11, 0x03 }),
    );
    const Command5 = packed struct(u40) {
        flag: bool = true,
        reserved: u7 = 0,
        num: u16 = 0x1122,
        num2: u5 = 0x03,
        num3: u3 = 0,
        num4: u8 = 0xAB,
    };
    try std.testing.expectEqual(
        Command5{},
        packFromECat(Command5, [_]u8{ 1, 0x22, 0x11, 0x03, 0xAB }),
    );
}

/// A bit reader with an API loosely similar to std.io.bitReader, but with some customizations
/// to our use case:
///
/// - only supports little endian
/// - skip bits by using read with type void.
/// - readBitsNoEof(u16, 16) -> u16
/// - readBitsNoEof(u16, 32) -> u16 (ignores higher bits from bitstream)
/// - readBitsNoEof(u16, 8) -> u16 (higher bits are zero filled)
/// - readBitsNoEof(boo1, 1) -> bool
/// - readBitsNoEof(bool, 0) -> bool (false)
/// - readBitsNoEof(bool, 2) -> bool (ignores higher bits from bitsream)
/// - readBitsNoEof(void, 2) -> void (skips 2 bits in bitstream)
pub fn LossyBitReader(comptime Reader: type) type {
    return struct {
        reader: Reader,
        current_byte: u8 = 0,
        pos_in_byte: u3 = 0,
        pub fn readBitsNoEof(self: *@This(), comptime T: type, num: u32) !T {
            var rval: @Type(.{ .int = .{ .signedness = .unsigned, .bits = @bitSizeOf(T) } }) = 0;
            var used_bits: u32 = 0;
            var bits_remaining = num;
            while (bits_remaining > 0) : ({
                bits_remaining -= 1;
                self.pos_in_byte +%= 1;
            }) {
                if (self.pos_in_byte == 0) {
                    self.current_byte = try self.reader.readByte();
                }
                if (used_bits < @bitSizeOf(T)) {
                    const bit_value: u1 = @intCast((self.current_byte >> self.pos_in_byte) & 0b00000001);
                    const mask = @as(@TypeOf(rval), @intCast(1)) << @intCast(used_bits);
                    switch (bit_value) {
                        0 => rval = rval & ~mask,
                        1 => rval = rval | mask,
                    }
                    used_bits += 1;
                }
            }
            return switch (T) {
                void => void{},
                else => return @bitCast(rval),
            };
        }

        pub fn reset(self: *@This()) void {
            self.pos_in_byte = 0;
            self.current_byte = 0; // not strictly necessary?
        }
    };
}

pub fn lossyBitReader(reader: anytype) LossyBitReader(@TypeOf(reader)) {
    return .{ .reader = reader };
}

test lossyBitReader {
    const t: []const u8 = &.{1};
    var fbs = std.io.fixedBufferStream(t);
    const reader = fbs.reader();
    var bit_reader = lossyBitReader(reader);
    try std.testing.expectEqual(true, try bit_reader.readBitsNoEof(bool, 1));
}

test "lossyBitReader 0 bytes" {
    const t: []const u8 = &.{};
    var fbs = std.io.fixedBufferStream(t);
    const reader = fbs.reader();
    var bit_reader = lossyBitReader(reader);

    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 0));
    try std.testing.expectEqual(0, bit_reader.pos_in_byte);
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0, try bit_reader.readBitsNoEof(u4, 0));
    try std.testing.expectEqual(0, bit_reader.pos_in_byte);
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0, try bit_reader.readBitsNoEof(u22, 0));
    try std.testing.expectEqual(0, bit_reader.pos_in_byte);
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0, try bit_reader.readBitsNoEof(u0, 0));
    try std.testing.expectEqual(0, bit_reader.pos_in_byte);
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectError(error.EndOfStream, bit_reader.readBitsNoEof(u0, 1));
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectError(error.EndOfStream, bit_reader.readBitsNoEof(u0, 400));
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0, try bit_reader.readBitsNoEof(u1, 0));
    try std.testing.expectEqual(0, bit_reader.pos_in_byte);
    fbs.reset();
    bit_reader.reset();
}

test "lossyBitReader 1 byte" {
    const t: []const u8 = &.{0b00001101};
    var fbs = std.io.fixedBufferStream(t);
    const reader = fbs.reader();
    var bit_reader = lossyBitReader(reader);
    try std.testing.expectEqual(0, bit_reader.pos_in_byte);
    try std.testing.expectEqual(true, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(true, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(true, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectError(error.EndOfStream, bit_reader.readBitsNoEof(bool, 1));
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0b00001101, try bit_reader.readBitsNoEof(u8, 8));
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0b1, try bit_reader.readBitsNoEof(u4, 1));
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0b01, try bit_reader.readBitsNoEof(u4, 2));
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0b101, try bit_reader.readBitsNoEof(u4, 3));
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0b1101, try bit_reader.readBitsNoEof(u4, 4));
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0b01101, try bit_reader.readBitsNoEof(u4, 5));
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0b1101, try bit_reader.readBitsNoEof(u4, 8));
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectError(error.EndOfStream, bit_reader.readBitsNoEof(u4, 9));
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0b00000000_00001101, try bit_reader.readBitsNoEof(u16, 8));
    fbs.reset();
    bit_reader.reset();
}

test "lossyBitReader 2 bytes" {
    const t: []const u8 = &.{ 0b00001101, 0b00100110 };
    var fbs = std.io.fixedBufferStream(t);
    const reader = fbs.reader();
    var bit_reader = lossyBitReader(reader);
    try std.testing.expectEqual(true, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(true, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(true, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(true, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(true, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(true, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectEqual(false, try bit_reader.readBitsNoEof(bool, 1));
    try std.testing.expectError(error.EndOfStream, bit_reader.readBitsNoEof(bool, 1));
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0b0100110_00001101, try bit_reader.readBitsNoEof(u15, 16));
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0b00100110_00001101, try bit_reader.readBitsNoEof(u16, 16));
    fbs.reset();
    bit_reader.reset();

    try std.testing.expectEqual(0b00100110_00001101, try bit_reader.readBitsNoEof(u17, 16));
    fbs.reset();
    bit_reader.reset();
}

/// Write bits of length at bit position in the buffer.
/// Write value as little-endian.
/// Bit position is lowest to highest memory address, least to most significant within a byte.
///
/// writeBitsAtPos(bool, 0, N) does nothing
/// writeBitsAtPos(bool, 1, N) writes 1 bit at position N
/// writeBitsAtPos(bool, 2, N) writes 2 bits, bool at position N, 0 at position N + 1
/// writeBitsAtPos(void, 3, N) writes 3 zero bits at position N
/// writeBitsAtPos(u8, 5, N) writes the 5 least significant bits of u8 at position N
pub fn writeBitsAtPos(bytes: []u8, bit_offset: usize, bit_count: usize, value: anytype) void {
    // TODO: implement
    return switch (@TypeOf(value)) {
        void => {}, // do nothing
        bool => std.mem.writeVarPackedInt(bytes, bit_offset, bit_count, @as(u1, @intFromBool(value)), .little),
        f32 => std.mem.writeVarPackedInt(bytes, bit_offset, bit_count, @as(u32, @bitCast(value)), .little),
        f64 => std.mem.writeVarPackedInt(bytes, bit_offset, bit_count, @as(u64, @bitCast(value)), .little),
        else => std.mem.writeVarPackedInt(bytes, bit_offset, bit_count, value, .little),
    };
}

// tests for writeVarPackedInt
test {
    var buf = [_]u8{ 0b0000_0000, 0, 0, 0 };
    writeBitsAtPos(&buf, 3, 2, @as(u1, 1));
    try std.testing.expectEqual(buf[0], 0b0000_1000);
}

test {
    var buf = [_]u8{ 0b1111_1111, 0, 0, 0 };
    writeBitsAtPos(&buf, 3, 2, @as(u1, 0));
    try std.testing.expectEqual(buf[0], 0b1110_0111);
}

test {
    var buf = [_]u8{ 0, 0, 0, 0 };
    writeBitsAtPos(&buf, 3, 2, @as(u12, 0b111));
    try std.testing.expectEqualSlices(u8, &buf, &.{ 0b0001_1000, 0, 0, 0 });
}

test {
    std.testing.refAllDecls(@This());
}
