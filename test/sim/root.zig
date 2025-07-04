const std = @import("std");
const assert = std.debug.assert;
const builtin = @import("builtin");

const gcat = @import("gatorcat");

const eni = @import("network_config.zig").eni;

pub const std_options: std.Options = .{
    .log_level = .info,
};

test "ping simulator" {
    var simulator = try gcat.sim.Simulator.init(eni, std.testing.allocator, .{});
    defer simulator.deinit(std.testing.allocator);

    var port = gcat.Port.init(simulator.linkLayer(), .{});
    try port.ping(10000);
}

test {
    var simulator = try gcat.sim.Simulator.init(eni, std.testing.allocator, .{});
    defer simulator.deinit(std.testing.allocator);

    var port = gcat.Port.init(simulator.linkLayer(), .{});
    try port.ping(10000);

    const estimated_stack_usage = 300000;
    var stack_memory: [estimated_stack_usage]u8 = undefined;
    var stack_fba = std.heap.FixedBufferAllocator.init(&stack_memory);

    var md = try gcat.MainDevice.init(
        stack_fba.allocator(),
        &port,
        .{ .recv_timeout_us = 20000, .eeprom_timeout_us = 10_000 },
        eni,
    );
    defer md.deinit(stack_fba.allocator());

    try md.busInit(5_000_000);
    // try md.busPreop(5_000_000);
}
