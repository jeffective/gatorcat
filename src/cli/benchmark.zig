const std = @import("std");
const builtin = @import("builtin");

const gcat = @import("gatorcat");

pub const Args = struct {
    ifname: [:0]const u8,
    recv_timeout_us: u32 = 10_000,
    duration_s: f64 = 10.0,
    cycle_time_us: u32 = 2000,
    rt_prio: ?i32 = null,
    affinity: ?u10 = null,

    pub const descriptions = .{
        .ifname = "Network interface to use for the benchmark (e.g. \"eth0\").",
        .recv_timeout_us = "Frame receive timeout in microseconds.",
        .duration_s = "Duration of the test in seconds.",
        .cycle_time_us = "Intended cycle time in microseconds.",
        .rt_prio = "Set the real-time priority of this process.",
        .affinity = "Set the cpu affinity of the this process.",
    };
};

pub fn benchmark(args: Args) !void {
    var io_impl = std.Io.Threaded.init_single_threaded;
    const io = io_impl.io();

    var raw_socket = try gcat.nic.RawSocket.init(args.ifname);
    defer raw_socket.deinit();

    var port = gcat.Port.init(raw_socket.linkLayer(), .{});
    defer port.deinit();
    try port.ping(args.recv_timeout_us);
    var std_out = std.fs.File.stdout().writer(&.{});
    const writer = &std_out.interface;
    if (builtin.os.tag == .linux) {
        if (args.affinity) |affinity| {
            // using pid = 0 means this process will have the scheduler set.
            const cpu_set: std.os.linux.cpu_set_t = @bitCast(@as(u1024, 1) << affinity);
            try std.os.linux.sched_setaffinity(0, &cpu_set);
            try writer.print("Set cpu affinity to {}.\n", .{affinity});
        }
        if (args.rt_prio) |rt_prio| {
            // using pid = 0 means this process will have the scheduler set.
            const rval = std.os.linux.sched_setscheduler(0, .{ .mode = .FIFO }, &.{
                .priority = rt_prio,
            });
            switch (std.posix.errno(rval)) {
                .SUCCESS => {
                    try writer.print("Set real-time priority to {}.\n", .{rt_prio});
                },
                else => |err| {
                    try writer.print("Error when setting real-time priority: {}\n", .{err});
                    return error.CannotSetRealtimePriority;
                },
            }
        }

        const scheduler: gcat.NonExhaustive(std.os.linux.SCHED.Mode) = @enumFromInt(std.os.linux.sched_getscheduler(0));
        const scheduler_name = std.enums.tagName(gcat.NonExhaustive(std.os.linux.SCHED.Mode), scheduler) orelse "UNKNOWN";
        try writer.print("Scheduler: {s}\n", .{scheduler_name});
    }

    try writer.print("benchmarking for {d:.2}s...\n", .{args.duration_s});

    var run_timer = try std.time.Timer.start();
    var n_cycles: u64 = 0;
    var max_cycle_time_ns: u64 = 0;
    var min_cycle_time_ns: u64 = @as(u64, args.recv_timeout_us) * std.time.ns_per_us;
    var cycle_timer = try std.time.Timer.start();
    const first_cycle_time = std.time.Instant.now() catch @panic("Timer unsupported");
    while (@as(f64, @floatFromInt(run_timer.read())) < args.duration_s * std.time.ns_per_s) {
        try port.ping(args.recv_timeout_us);
        n_cycles += 1;

        try gcat.sleepUntilNextCycle(io, first_cycle_time, args.cycle_time_us);
        const cycle_time_ns = cycle_timer.read();
        cycle_timer.reset();
        if (cycle_time_ns > max_cycle_time_ns) {
            max_cycle_time_ns = cycle_time_ns;
        }
        if (cycle_time_ns < min_cycle_time_ns) {
            min_cycle_time_ns = cycle_time_ns;
        }
    }
    const total_time_s: f64 = @as(f64, @floatFromInt(run_timer.read())) / std.time.ns_per_s;
    const cycles_per_second: f64 = @as(f64, @floatFromInt(n_cycles)) / total_time_s;
    const max_cycle_time_s: f64 = @as(f64, @floatFromInt(max_cycle_time_ns)) / std.time.ns_per_s;
    const min_cycle_time_s: f64 = @as(f64, @floatFromInt(min_cycle_time_ns)) / std.time.ns_per_s;
    try writer.print("Completed {} cycles in {d:.2}s or {d:.2} cycles/s.\n", .{ n_cycles, total_time_s, cycles_per_second });
    try writer.print("Max cycle time: {d:.6}s.\n", .{max_cycle_time_s});
    try writer.print("Min cycle time: {d:.6}s.\n", .{min_cycle_time_s});
}
