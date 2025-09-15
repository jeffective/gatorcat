const std = @import("std");
const assert = std.debug.assert;
const builtin = @import("builtin");

const gcat = @import("gatorcat");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var raw_socket = try gcat.nic.RawSocket.init("enx00e04c68191a");
    defer raw_socket.deinit();
    var port = gcat.Port.init(raw_socket.linkLayer(), .{});
    defer port.deinit();
    try port.ping(10000);

    var scanner = gcat.Scanner.init(&port, .{});
    try scanner.busInit(10_000_000, try scanner.countSubdevices());
    const eni = try scanner.readEni(
        gpa.allocator(),
        10_000_000,
        false,
    );
    defer eni.deinit();

    var md = try gcat.MainDevice.init(
        gpa.allocator(),
        &port,
        .{ .recv_timeout_us = 20000, .eeprom_timeout_us = 10_000 },
        eni.value,
    );
    defer md.deinit(gpa.allocator());

    try md.busInit(5_000_000);
    try md.busPreop(10_000_000);
    try md.busSafeop(10_000_000);
    // 0x10f3 diagnosis history
    var buf: [10000]u8 = undefined;
    const bytes_read = try md.subdevices[3].sdoRead(&port, &buf, 0x10f3, 8, false, 10_000, 10_000);
    std.log.err("got {} bytes", .{bytes_read});
    try md.busOp(10_000_000);

    var print_timer = try std.time.Timer.start();
    var cycle_count: u32 = 0;

    while (true) {
        // exchange process data
        try md.sendRecvCyclicFrames();

        // do application
        if (print_timer.read() > std.time.ns_per_s * 1) {
            print_timer.reset();
            std.debug.print("----------------------------------\n", .{});
            std.log.warn("cycles/s: {}", .{cycle_count});
            std.debug.print("----------------------------------\n", .{});
            cycle_count = 0;
        }
        // sleep until next cycle
        gcat.sleepUntilNextCycle(md.first_cycle_time.?, 2000);

        cycle_count += 1;
    }
}
