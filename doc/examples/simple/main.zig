const std = @import("std");
const assert = std.debug.assert;
const builtin = @import("builtin");

const eni: gcat.ENI = @import("eni.zon");
const gcat = @import("gatorcat");

pub const std_options: std.Options = .{
    .log_level = .info,
};

pub fn main() !void {
    var raw_socket = try gcat.nic.RawSocket.init("enx00e04c68191a");
    defer raw_socket.deinit();
    var port = gcat.Port.init(raw_socket.linkLayer(), .{});
    defer port.deinit();
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
    try md.busPreop(10_000_000);
    try md.busSafeop(10_000_000);
    try md.busOp(10_000_000);

    std.debug.print("EL2008 PROCESS IMAGE: {}\n", .{md.subdevices[1].runtime_info.pi});

    var print_timer = try std.time.Timer.start();
    var blink_timer = try std.time.Timer.start();
    var kill_timer = try std.time.Timer.start();
    var wkc_error_timer = try std.time.Timer.start();
    var cycle_count: u32 = 0;

    const ek1100 = &md.subdevices[0];
    const el2008 = &md.subdevices[1];

    while (true) {

        // exchange process data
        const diag = md.sendRecvCyclicFramesDiag() catch |err| switch (err) {
            error.RecvTimeout => {
                std.log.warn("recv timeout", .{});
                continue;
            },
            error.LinkError,
            => |err2| return err2,
        };
        if (diag.brd_status_wkc != eni.subdevices.len) return error.TopologyChanged;
        if (diag.brd_status.state != .OP) {
            std.log.err("Not all subdevices in OP! brd status {}", .{diag.brd_status});
            return error.NotAllSubdevicesInOP;
        }
        if (diag.process_data_wkc != md.expectedProcessDataWkc() and wkc_error_timer.read() > 1 * std.time.ns_per_s) {
            wkc_error_timer.reset();
            std.log.err("process data wkc wrong: {}, expected: {}", .{ diag.process_data_wkc, md.expectedProcessDataWkc() });
        }
        cycle_count += 1;

        // do application
        if (print_timer.read() > std.time.ns_per_s * 1) {
            print_timer.reset();
            std.log.warn("frames/s: {}", .{cycle_count});
            @setEvalBranchQuota(30000);
            var std_out = std.fs.File.stdout().writer(&.{});
            const writer = &std_out.interface;
            try std.zon.stringify.serialize(md.getProcessImage(eni), .{}, writer);
            // std.debug.print("process image: {any}\n", .{md.getProcessImage(eni)});
            cycle_count = 0;
        }
        if (blink_timer.read() > std.time.ns_per_s * 0.1) {
            blink_timer.reset();
            // make the lights flash on the EL2008
            el2008.runtime_info.pi.outputs[0] *%= 2;
            if (el2008.runtime_info.pi.outputs[0] == 0) {
                el2008.runtime_info.pi.outputs[0] = 1;
            }
        }
        if (kill_timer.read() > std.time.ns_per_s * 10) {
            kill_timer.reset();
            try ek1100.setALState(&port, .SAFEOP, 10000, 10000);
        }
    }
}
