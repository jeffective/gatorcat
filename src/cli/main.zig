const std = @import("std");
const builtin = @import("builtin");

const flags = @import("flags");
const gcat = @import("gatorcat");

const benchmark = @import("benchmark.zig");
const info = @import("info.zig");
const read_eeprom = @import("read_eeprom.zig");
const run = @import("run.zig");
const scan = @import("scan.zig");
const Config = @import("Config.zig");
const dc = @import("dc.zig");

const gatorcat_version: []const u8 = @import("build_zig_zon").version;

var log_level: std.log.Level = .warn;
pub const std_options: std.Options = .{
    .log_level = .debug, // effects comptime log level
    .logFn = logFn,
};
fn logFn(
    comptime message_level: std.log.Level,
    comptime scope: @TypeOf(.enum_literal),
    comptime format: []const u8,
    args: anytype,
) void {
    if (@intFromEnum(message_level) <= @intFromEnum(log_level)) {
        std.log.defaultLog(message_level, scope, format, args);
    }
}

const Args = struct {
    pub const description =
        \\The GatorCAT CLI.
        \\
        \\Run, scan, and debug EtherCAT networks.
        \\Each subcommand also has its own help text.
        \\The suggested workflow is:
        \\
        \\1. scan the network and write a configuration file that describes the network using "gatorcat scan".
        \\2. operate the ethercat network using "gatorcat run".
        \\
        \\Example usage (write configuration file):
        \\gatorcat scan --ifname eth0 > config.zon
    ;
    log_level: std.log.Level = .warn,
    // sub commands
    command: union(enum) {
        // scan bus
        scan: scan.Args,
        benchmark: benchmark.Args,
        read_eeprom: read_eeprom.Args,
        run: run.Args,
        info: info.Args,
        version: struct {},
        dc: dc.Args,
        pub const descriptions = .{
            .scan = "Scan the EtherCAT bus and print an EtherCAT Network Information (ENI) ZON.",
            .benchmark = "Benchmark the performance of the EtherCAT bus.",
            .read_eeprom = "Read the eeprom of a subdevice.",
            .run = "Run an EtherCAT maindevice.",
            .info = "Prints as much human-readable information (in markdown) about the subdevices as possible.",
            .version = "Print the version of gatorcat.",
            .dc = "Experimental. Get information about distributed clocks.",
        };
    },

    pub const descriptions = .{
        .log_level = "Log level for zig std.log",
    };
};

pub fn main() !void {
    @setEvalBranchQuota(4000);
    var args_mem: [4096]u8 = undefined;
    var args_allocator = std.heap.FixedBufferAllocator.init(&args_mem);
    const args = try std.process.argsAlloc(args_allocator.allocator());
    defer std.process.argsFree(args_allocator.allocator(), args);

    const parsed_args = flags.parse(args, "gatorcat", Args, .{});

    log_level = parsed_args.log_level;

    switch (parsed_args.command) {
        .scan => |scan_args| try scan.scan(scan_args),
        .benchmark => |benchmark_args| try benchmark.benchmark(benchmark_args),
        .read_eeprom => |read_eeprom_args| try read_eeprom.read_eeprom(read_eeprom_args),
        .run => |run_args| try run.run(run_args),
        .info => |info_args| try info.info(info_args),
        .dc => |dc_args| try dc.dc(dc_args),
        .version => {
            var std_out = std.fs.File.stdout().writer(&.{});
            const writer = &std_out.interface;
            try writer.print("{s}\n", .{gatorcat_version});
        },
    }
}

test {
    _ = benchmark;
    _ = Config;
    _ = info;
    _ = read_eeprom;
    _ = run;
    _ = scan;
}
