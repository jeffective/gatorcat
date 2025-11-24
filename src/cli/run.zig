//! Run subcommand of the GatorCAT CLI.
//!
//! Intended to exemplify a reasonable default way of doing things with as little configuratiuon as possible.

const std = @import("std");
const assert = std.debug.assert;
const builtin = @import("builtin");

const gcat = @import("gatorcat");
const Config = @import("Config.zig");
const zenoh_plugin = @import("plugins/zenoh.zig");

const ZenohHandler = zenoh_plugin.ZenohHandler;

pub const Args = struct {
    ifname: [:0]const u8,
    recv_timeout_us: u32 = 10_000,
    eeprom_timeout_us: u32 = 10_000,
    init_timeout_us: u32 = 5_000_000,
    preop_timeout_us: u32 = 3_000_000,
    safeop_timeout_us: u32 = 10_000_000,
    op_timeout_us: u32 = 10_000_000,
    mbx_timeout_us: u32 = 50_000,
    cycle_time_us: ?u32 = null,
    max_recv_timeouts_before_rescan: u32 = 3,

    zenoh_log_level: zenoh_plugin.LogLevel = .@"error",
    config_file: ?[:0]const u8 = null,
    config_file_json: ?[:0]const u8 = null,
    rt_prio: ?i32 = null,
    verbose: bool = false,
    mlockall: bool = false,

    auto_scan_plugin_zenoh_enable: bool = false,
    plugin_zenoh_config_default: bool = false,
    plugin_zenoh_config_file: ?[:0]const u8 = null,
    plugin_zenoh_pdo_input_publisher_key_format: ?[:0]const u8 = "ethercat/maindevice/pdi/subdevices/{{subdevice_index}}/{{subdevice_name}}/{{pdo_direction}}/0x{{pdo_index_hex}}/{{pdo_name}}/0x{{pdo_entry_index_hex}}/0x{{pdo_entry_subindex_hex}}/{{pdo_entry_description}}",
    plugin_zenoh_pdo_output_publisher_key_format: ?[:0]const u8 = "ethercat/maindevice/pdi/subdevices/{{subdevice_index}}/{{subdevice_name}}/{{pdo_direction}}/0x{{pdo_index_hex}}/{{pdo_name}}/0x{{pdo_entry_index_hex}}/0x{{pdo_entry_subindex_hex}}/{{pdo_entry_description}}",
    plugin_zenoh_pdo_output_subscriber_key_format: ?[:0]const u8 = "ethercat/subdevices/{{subdevice_index}}/{{subdevice_name}}/{{pdo_direction}}/0x{{pdo_index_hex}}/{{pdo_name}}/0x{{pdo_entry_index_hex}}/0x{{pdo_entry_subindex_hex}}/{{pdo_entry_description}}",

    pub const descriptions = .{
        .ifname = "Network interface to use for the bus scan. Example: eth0",
        .recv_timeout_us = "Frame receive timeout in microseconds. Example: 10000",
        .eeprom_timeout_us = "SII EEPROM timeout in microseconds. Example: 10000",
        .init_timeout_us = "State transition to init timeout in microseconds. Example: 100000",
        .preop_timeout_us = "State transition to preop timeout in microseconds. Example: 100000",
        .safeop_timeout_us = "State transition to safeop timeout in microseconds. Example: 100000",
        .op_timeout_us = "State transition to op timeout in microseconds. Example: 100000",
        .mbx_timeout_us = "Mailbox timeout in microseconds. Example: 100000",
        .cycle_time_us = "Cycle time in microseconds. Example: 10000",
        .auto_scan_plugin_zenoh_enable = "Enable the zenoh plugin for operating without a --config-file. Has no effect if you already have a --config-file.",
        .plugin_zenoh_config_default = "Enable zenoh and use the default zenoh configuration.",
        .plugin_zenoh_config_file = "Enable zenoh and use this file path for the zenoh configuration. Example: path/to/comfig.json5",
        .config_file = "Path to config file (as ZON). See output of `gatorcat scan` for an example.",
        .config_file_json = "Same as --config-file but as JSON.",
        .rt_prio = "Set a real-time priority for this process. Does nothing on windows.",
        .verbose = "Enable verbose logs.",
        .mlockall = "Do mlockall syscall to prevent this process' memory from being swapped. Improves real-time performance. Only applicable to linux.",
    };
};

pub const RunError = error{
    /// Reached a non-recoverable state and the program should die.
    NonRecoverable,
};

pub fn run(args: Args) RunError!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    if (args.config_file_json != null and args.config_file != null) {
        std.log.err("only one of --config-file and --config-file-json is allowed", .{});
        return error.NonRecoverable;
    }
    if (builtin.os.tag == .linux) {
        if (args.rt_prio) |rt_prio| {
            // using pid = 0 means this process will have the scheduler set.
            const rval = std.os.linux.sched_setscheduler(0, .{ .mode = .FIFO }, &.{
                .priority = rt_prio,
            });
            switch (std.posix.errno(rval)) {
                .SUCCESS => {
                    std.log.warn("Set real-time priority to {}.", .{rt_prio});
                },
                else => |err| {
                    std.log.warn("Error when setting real-time priority: Error {}", .{err});
                    return error.NonRecoverable;
                },
            }
        }
        const scheduler: gcat.NonExhaustive(std.os.linux.SCHED.Mode) = @enumFromInt(std.os.linux.sched_getscheduler(0));
        const scheduler_name = std.enums.tagName(gcat.NonExhaustive(std.os.linux.SCHED.Mode), scheduler) orelse "UNKNOWN";
        std.log.warn("Scheduler: {s}", .{scheduler_name});

        if (args.mlockall) {
            switch (std.posix.errno(std.os.linux.mlockall(.{ .CURRENT = true, .FUTURE = true }))) {
                .SUCCESS => {
                    std.log.warn("mlockall successful", .{});
                    gcat.probeStack(1 * 1024 * 1024);
                    std.log.warn("stack probe successful", .{});
                },
                else => |e| {
                    std.log.err("failed to lock memory: {}", .{e});
                    return error.NonRecoverable;
                },
            }
        }
    }

    defer {
        if (builtin.os.tag == .linux and args.mlockall) {
            switch (std.posix.errno(std.os.linux.munlockall())) {
                .SUCCESS => {
                    std.log.info("unlocked memory", .{});
                },
                else => |e| {
                    std.log.err("failed to unlock memory: {}", .{e});
                },
            }
        }
    }

    var raw_socket = gcat.nic.RawSocket.init(args.ifname) catch return error.NonRecoverable;
    defer raw_socket.deinit();
    var port = gcat.Port.init(raw_socket.linkLayer(), .{});
    defer port.deinit();

    bus_scan: while (true) {
        var ping_timer = std.time.Timer.start() catch @panic("Timer not supported");
        port.ping(args.recv_timeout_us) catch |err| switch (err) {
            error.LinkError => return error.NonRecoverable,
            error.RecvTimeout => {
                std.log.err("Ping failed. No frame returned before the recv timeout. Is anything connected to the specified interface ({s})?", .{args.ifname});
                return error.NonRecoverable;
            },
        };
        std.log.warn("Ping returned in {} us.", .{ping_timer.read() / std.time.ns_per_us});

        const cycle_time_us = blk: {
            if (args.cycle_time_us) |cycle_time_us| break :blk cycle_time_us;

            const default_cycle_times = [_]u32{ 100, 200, 500, 1000, 2000, 4000, 10000 };
            std.log.warn("Cycle time not specified. Estimating appropriate cycle time...", .{});

            var highest_ping: u64 = 0;
            const ping_count = 1000;
            for (0..ping_count) |_| {
                const start = ping_timer.read();
                port.ping(10000) catch return error.NonRecoverable;
                const end = ping_timer.read();
                if ((end - start) / 1000 > highest_ping) {
                    highest_ping = (end - start) / 1000;
                }
            }

            const selected_cycle_time = for (default_cycle_times) |cycle_time| {
                if (highest_ping *| 2 < cycle_time) break cycle_time;
            } else 10000;

            std.log.warn("Max ping after {} tries is {} us. Selected {} us as cycle time.", .{ ping_count, highest_ping, selected_cycle_time });

            break :blk selected_cycle_time;
        };

        const config = blk: {
            if (args.config_file) |config_file_path| {
                const config = Config.fromFile(allocator, config_file_path, 1e9) catch return error.NonRecoverable;
                std.log.warn("Loaded config: {s}", .{config_file_path});
                break :blk config;
            }
            if (args.config_file_json) |config_file_path| {
                const config = Config.fromFileJson(allocator, config_file_path, 1e9) catch return error.NonRecoverable;
                std.log.warn("Loaded config: {s}", .{config_file_path});
                break :blk config;
            }
            std.log.warn("Scanning bus...", .{});
            var scanner = gcat.Scanner.init(&port, .{
                .eeprom_timeout_us = args.eeprom_timeout_us,
                .mbx_timeout_us = args.mbx_timeout_us,
                .recv_timeout_us = args.recv_timeout_us,
            });
            const num_subdevices = scanner.countSubdevices() catch |err| switch (err) {
                error.LinkError => return error.NonRecoverable,
                error.RecvTimeout => continue :bus_scan,
            };
            std.log.warn("Detected {} subdevices.", .{num_subdevices});
            scanner.busInit(args.init_timeout_us, num_subdevices) catch |err| switch (err) {
                error.LinkError => return error.NonRecoverable,
                error.RecvTimeout, error.Wkc, error.StateChangeRefused, error.StateChangeTimeout => continue :bus_scan,
            };
            scanner.assignStationAddresses(num_subdevices) catch |err| switch (err) {
                error.LinkError => return error.NonRecoverable,
                error.RecvTimeout, error.Wkc => continue :bus_scan,
            };

            const arena = allocator.create(std.heap.ArenaAllocator) catch return error.NonRecoverable;
            errdefer allocator.destroy(arena);
            arena.* = .init(allocator);
            errdefer arena.deinit();

            const eni = scanner.readEniLeaky(arena.allocator(), args.preop_timeout_us, false) catch |err| switch (err) {
                error.LinkError,
                error.OutOfMemory,
                error.RecvTimeout,
                error.SIITimeout,
                error.Wkc,
                error.StateChangeRefused,
                error.StateChangeTimeout,
                error.BusConfigurationMismatch,
                error.ProtocolViolation,
                error.NotImplemented,
                error.MailboxTimeout,
                error.CoEAbort,
                error.CoEEmergency,
                error.MissedFragment,
                error.StartupParametersFailed,
                => continue :bus_scan,
            };
            const zenoh_plugin_config: ?zenoh_plugin.Config = zenoh_blk: {
                if (args.auto_scan_plugin_zenoh_enable) {
                    break :zenoh_blk zenoh_plugin.Config.initFromENILeaky(
                        arena.allocator(),
                        eni,
                        .{
                            .pdo_input_publisher_key_format = args.plugin_zenoh_pdo_input_publisher_key_format,
                            .pdo_output_publisher_key_format = args.plugin_zenoh_pdo_output_publisher_key_format,
                            .pdo_output_subscriber_key_format = args.plugin_zenoh_pdo_output_subscriber_key_format,
                        },
                    ) catch return error.NonRecoverable;
                } else break :zenoh_blk null;
            };
            break :blk gcat.Arena(Config){ .arena = arena, .value = Config{ .eni = eni, .plugins = .{ .zenoh = zenoh_plugin_config } } };
        };

        defer config.deinit();

        var md = gcat.MainDevice.init(
            allocator,
            &port,
            .{ .eeprom_timeout_us = args.eeprom_timeout_us, .mbx_timeout_us = args.mbx_timeout_us, .recv_timeout_us = args.recv_timeout_us },
            config.value.eni,
        ) catch |err| switch (err) {
            error.OutOfMemory => return error.NonRecoverable,
        };
        defer md.deinit(allocator);

        md.busInit(args.init_timeout_us) catch |err| switch (err) {
            error.LinkError => return error.NonRecoverable,
            error.RecvTimeout,
            error.Wkc,
            error.StateChangeRefused,
            error.StateChangeTimeout,
            error.BusConfigurationMismatch,
            => continue :bus_scan,
        };
        // we should not initiate zenoh until the bus contents are verified.

        // TODO: get rid of this mutex!
        var pdi_write_mutex = std.Thread.Mutex{};

        var maybe_zh: ?ZenohHandler = blk: {
            if (args.plugin_zenoh_config_file) |config_file| {
                const zh = ZenohHandler.init(
                    allocator,
                    config.value,
                    config_file,
                    &md,
                    args.zenoh_log_level,
                    &pdi_write_mutex,
                ) catch return error.NonRecoverable;
                break :blk zh;
            } else if (args.plugin_zenoh_config_default) {
                if (config.value.plugins == null or config.value.plugins.?.zenoh == null) {
                    break :blk null;
                }
                const zh = ZenohHandler.init(
                    allocator,
                    config.value,
                    null,
                    &md,
                    args.zenoh_log_level,
                    &pdi_write_mutex,
                ) catch return error.NonRecoverable;
                break :blk zh;
            } else break :blk null;
        };
        defer {
            if (maybe_zh) |*zh| {
                zh.deinit(allocator);
            }
        }

        md.busPreop(args.preop_timeout_us) catch |err| switch (err) {
            error.LinkError,
            error.ProtocolViolation,
            error.StartupParametersFailed,
            => return error.NonRecoverable,
            error.Wkc,
            error.StateChangeRefused,
            error.RecvTimeout,
            error.SIITimeout,
            error.StateChangeTimeout,
            error.BusConfigurationMismatch,
            => continue :bus_scan,
        };

        // warm up zenoh
        if (maybe_zh) |*zh| {
            std.log.warn("warming up zenoh...", .{});
            var z_warmup_timer = std.time.Timer.start() catch @panic("timer unsupported");
            zh.publishInputsOutputs(&md, config.value) catch |err| {
                std.log.err("failed to publish inputs / outputs on zenoh: {s}", .{@errorName(err)});
                break :bus_scan; // TODO: correct action here?
            };
            std.log.warn("zenoh warmup time: {} us", .{z_warmup_timer.read() / 1000});
        }

        // TODO: wtf jeff reduce the number of errors!
        md.busSafeop(args.safeop_timeout_us) catch |err| switch (err) {
            error.MailboxTimeout,
            error.CoEAbort,
            error.CoEEmergency,
            error.NotImplemented,
            error.SIITimeout,
            error.LinkError,
            error.ProtocolViolation,
            error.RecvTimeout,
            error.Wkc,
            error.StateChangeTimeout,
            error.BusConfigurationMismatch,
            error.StartupParametersFailed,
            => return error.NonRecoverable,
            // => continue :bus_scan,
        };

        md.busOp(args.op_timeout_us) catch |err| switch (err) {
            error.LinkError => return error.NonRecoverable,
            error.StartupParametersFailed,
            error.RecvTimeout,
            error.Wkc,
            error.StateChangeTimeout,
            error.CoEEmergency,
            => continue :bus_scan,
        };

        var print_timer = std.time.Timer.start() catch @panic("Timer unsupported");
        var cycle_count: u32 = 0;
        var recv_timeouts: u32 = 0;
        std.log.info("Beginning operation at cycle time: {} us.", .{cycle_time_us});
        while (true) {

            // exchange process data
            {
                pdi_write_mutex.lock();
                defer pdi_write_mutex.unlock();
                if (md.sendRecvCyclicFrames()) {
                    recv_timeouts = 0;
                } else |err| switch (err) {
                    error.RecvTimeout => {
                        std.log.info("recv timeout!", .{});
                        recv_timeouts += 1;
                        if (recv_timeouts > args.max_recv_timeouts_before_rescan) continue :bus_scan;
                    },
                    error.LinkError => return error.NonRecoverable,
                    error.NotAllSubdevicesInOP,
                    error.TopologyChanged,
                    error.Wkc,
                    => |err2| {
                        std.log.err("failure out of OP: {s}", .{@errorName(err2)});
                        continue :bus_scan;
                    },
                }
            }

            if (maybe_zh) |*zh| {
                zh.publishInputsOutputs(&md, config.value) catch |err| {
                    std.log.err("failed to publish inputs / outputs on zenoh: {s}", .{@errorName(err)});
                    break :bus_scan; // TODO: correct action here?
                };
            }

            // do application
            cycle_count += 1;

            if (print_timer.read() > std.time.ns_per_s * 1) {
                print_timer.reset();
                if (args.verbose) {
                    std.log.info("cycles/s: {}", .{cycle_count});
                }
                cycle_count = 0;
            }
            gcat.sleepUntilNextCycle(md.first_cycle_time.?, cycle_time_us);
        }
    }
}
