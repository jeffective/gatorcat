const std = @import("std");
const assert = std.debug.assert;

pub const ENI = @import("ENI.zig");
pub const esc = @import("esc.zig");
pub const mailbox = @import("mailbox.zig");
pub const MainDevice = @import("MainDevice.zig");
pub const nic = @import("nic.zig");
pub const pdi = @import("pdi.zig");
pub const Port = @import("Port.zig");
pub const Scanner = @import("Scanner.zig");
pub const sii = @import("sii.zig");
pub const sim = @import("sim.zig");
pub const Subdevice = @import("Subdevice.zig");
pub const telegram = @import("telegram.zig");
pub const wire = @import("wire.zig");

pub const logger = std.log.scoped(.gatorcat);

const gcat = @This();

// given the time of the first cycle and the cycle duration, sleep until the next cycle
// Using a cycle time of zero immediatley reutrns.
pub fn sleepUntilNextCycle(start_time: std.time.Instant, cycle_time_us: u32) void {
    if (cycle_time_us == 0) return;
    assert(cycle_time_us != 0); // modulo below will invoke undefined behavior.
    const now = std.time.Instant.now() catch @panic("Timer unsupported.");
    // use modulo to sleep until the next cycle
    const time_to_sleep_ns = @as(u64, cycle_time_us) * std.time.ns_per_us - now.since(start_time) % (@as(u64, cycle_time_us) * std.time.ns_per_us);
    std.Thread.sleep(time_to_sleep_ns);
}

pub const max_subdevices = 65535;

// TODO: remove this if its in std
pub fn Exhaustive(@"enum": type) type {
    comptime assert(@typeInfo(@"enum").@"enum".is_exhaustive == false);
    var type_info = @typeInfo(@"enum");
    type_info.@"enum".is_exhaustive = true;
    return @Type(type_info);
}

test Exhaustive {
    const MyEnum = enum(u8) {
        zero,
        one,
        two,
        _,
    };

    const NewEnum = Exhaustive(MyEnum);

    try std.testing.expect(@typeInfo(NewEnum).@"enum".is_exhaustive);
    try std.testing.expectEqual(0, @intFromEnum(NewEnum.zero));
    try std.testing.expectEqual(1, @intFromEnum(NewEnum.one));
    try std.testing.expectEqual(2, @intFromEnum(NewEnum.two));
}

/// Call deinit() on this to free it.
pub fn Arena(comptime T: type) type {
    return struct {
        arena: *std.heap.ArenaAllocator,
        value: T,
        pub fn deinit(self: @This()) void {
            const allocator = self.arena.child_allocator;
            self.arena.deinit();
            allocator.destroy(self.arena);
        }
    };
}

test {
    std.testing.refAllDecls(@This());
}
