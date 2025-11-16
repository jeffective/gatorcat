const std = @import("std");
const assert = std.debug.assert;

/// A stripped-down version of BoundedArray intended solely for
/// the return type of simple and small deserialization functions.
///
/// Functions that mutate the items are intentionally omitted.
pub fn ConstBoundedArray(comptime T: type, comptime buffer_capacity: usize) type {
    return struct {
        const Self = @This();
        buffer: [buffer_capacity]T = undefined,
        len: usize = 0,

        pub fn fromSlice(m: []const T) error{Overflow}!Self {
            if (m.len > buffer_capacity) return error.Overflow;
            var list = Self{ .len = m.len };
            @memcpy(list.buffer[0..m.len], m);
            return list;
        }

        pub fn slice(self: *const Self) []const T {
            return self.buffer[0..self.len];
        }

        pub fn get(self: Self, i: usize) T {
            return self.slice()[i];
        }

        pub fn capacity(self: Self) usize {
            return self.buffer.len;
        }
    };
}

pub fn BoundedArray(comptime T: type, comptime buffer_capacity: usize) type {
    return struct {
        const Self = @This();
        buffer: [buffer_capacity]T = undefined,
        len: usize = 0,

        pub fn init(len: usize) error{Overflow}!Self {
            if (len > buffer_capacity) return error.Overflow;
            return Self{ .len = len };
        }

        pub fn slice(self: anytype) switch (@TypeOf(&self.buffer)) {
            *[buffer_capacity]T => []T,
            *const [buffer_capacity]T => []const T,
            else => unreachable,
        } {
            return self.buffer[0..self.len];
        }

        pub fn constSlice(self: *const Self) []const T {
            return self.slice();
        }

        pub fn clear(self: *Self) void {
            self.len = 0;
        }

        pub fn fromSlice(m: []const T) error{Overflow}!Self {
            var list = try init(m.len);
            @memcpy(list.slice(), m);
            return list;
        }

        pub fn get(self: Self, i: usize) T {
            return self.constSlice()[i];
        }

        pub fn ensureUnusedCapacity(self: Self, additional_count: usize) error{Overflow}!void {
            if (self.len + additional_count > buffer_capacity) {
                return error.Overflow;
            }
        }

        pub fn addOne(self: *Self) error{Overflow}!*T {
            try self.ensureUnusedCapacity(1);
            return self.addOneAssumeCapacity();
        }

        pub fn addOneAssumeCapacity(self: *Self) *T {
            assert(self.len < buffer_capacity);
            self.len += 1;
            return &self.slice()[self.len - 1];
        }

        pub fn appendAssumeCapacity(self: *Self, item: T) void {
            const new_item_ptr = self.addOneAssumeCapacity();
            new_item_ptr.* = item;
        }

        pub fn append(self: *Self, item: T) error{Overflow}!void {
            const new_item_ptr = try self.addOne();
            new_item_ptr.* = item;
        }

        pub fn capacity(self: Self) usize {
            return self.buffer.len;
        }
    };
}
