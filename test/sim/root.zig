const std = @import("std");
const assert = std.debug.assert;
const builtin = @import("builtin");

const eni: gcat.ENI = @import("./eni.zon");
const gcat = @import("gatorcat");

pub const std_options: std.Options = .{
    .log_level = .info, // effects comptime log level
    .logFn = logFn,
};
fn logFn(
    comptime message_level: std.log.Level,
    comptime scope: @TypeOf(.enum_literal),
    comptime format: []const u8,
    args: anytype,
) void {

    // suppress err logs in this module due to
    // https://github.com/ziglang/zig/issues/5738#issuecomment-1466902082

    if (message_level == .err) {
        std.log.defaultLog(.warn, scope, format, args);
        return;
    }

    std.log.defaultLog(message_level, scope, format, args);
    return;
}
test "ping simulator" {
    var simulator = try gcat.sim.Simulator.init(eni, std.testing.allocator, .{});
    defer simulator.deinit(std.testing.allocator);

    var port = gcat.Port.init(simulator.linkLayer(), .{});
    try port.ping(10000);
}

test {
    std.testing.log_level = .info;
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
    try md.busPreop(5_000_000);
}

const bad_enis: []const gcat.ENI = &.{
    @import("eni bad vendor.zon"),
    @import("eni bad product code.zon"),
    @import("eni bad serial.zon"),
    @import("eni bad revision.zon"),
};
test "bad vendor id" {
    for (bad_enis) |sim_eni| {
        std.testing.log_level = .err;
        var simulator = try gcat.sim.Simulator.init(sim_eni, std.testing.allocator, .{});
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
            sim_eni,
        );
        defer md.deinit(stack_fba.allocator());

        try md.busInit(5_000_000);
        try std.testing.expectError(
            error.BusConfigurationMismatch,
            md.busPreop(5_000_000),
        );
    }
}
