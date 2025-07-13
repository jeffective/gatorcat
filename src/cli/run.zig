//! Run subcommand of the GatorCAT CLI.
//!
//! Intended to exemplify a reasonable default way of doing things with as little configuratiuon as possible.

const std = @import("std");
const assert = std.debug.assert;
const builtin = @import("builtin");

const gcat = @import("gatorcat");
const zbor = @import("zbor");
const zenoh = @import("zenoh");

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
    zenoh_config_default: bool = false,
    zenoh_config_file: ?[:0]const u8 = null,
    zenoh_log_level: ZenohLogLevel = .@"error",
    eni_file: ?[:0]const u8 = null,
    eni_file_json: ?[:0]const u8 = null,
    rt_prio: ?i32 = null,
    verbose: bool = false,
    pv_name_prefix: ?[]const u8,

    pub const ZenohLogLevel = enum { trace, debug, info, warn, @"error" };

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
        .zenoh_config_default = "Enable zenoh and use the default zenoh configuration.",
        .zenoh_config_file = "Enable zenoh and use this file path for the zenoh configuration. Example: path/to/comfig.json5",
        .eni_file = "Path to ethercat nework information file (as ZON). See output of `gatorcat scan` for an example.",
        .eni_file_json = "Same as --eni-file but as JSON.",
        .rt_prio = "Set a real-time priority for this process. Does nothing on windows.",
        .verbose = "Enable verbose logs.",
        .pv_name_prefix = "Add a prefix (separated by /) to process variable names, if desired. Not applicable if eni file provided.",
    };
};

pub const RunError = error{
    /// Reached a non-recoverable state and the program should die.
    NonRecoverable,
};

pub fn run(allocator: std.mem.Allocator, args: Args) RunError!void {
    if (args.eni_file_json != null and args.eni_file != null) {
        std.log.err("only one of --eni-file and --eni-file-json is allowed", .{});
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
        const scheduler: std.os.linux.SCHED.Mode = @enumFromInt(std.os.linux.sched_getscheduler(0));
        std.log.warn("Scheduler: {s}", .{@tagName(scheduler)});
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

        const eni = blk: {
            if (args.eni_file) |eni_file_path| {
                const eni = gcat.ENI.fromFile(allocator, eni_file_path, 1e9) catch return error.NonRecoverable;
                std.log.warn("Loaded ENI: {s}", .{eni_file_path});
                break :blk eni;
            }
            if (args.eni_file_json) |eni_file_path| {
                const eni = gcat.ENI.fromFileJson(allocator, eni_file_path, 1e9) catch return error.NonRecoverable;
                std.log.warn("Loaded ENI: {s}", .{eni_file_path});
                break :blk eni;
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

            break :blk scanner.readEni(allocator, args.preop_timeout_us, false, args.pv_name_prefix) catch |err| switch (err) {
                error.LinkError,
                error.Overflow,
                error.NoSpaceLeft,
                error.OutOfMemory,
                error.RecvTimeout,
                error.Wkc,
                error.StateChangeRefused,
                error.StateChangeTimeout,
                error.Timeout,
                error.UnexpectedSubdevice,
                error.InvalidSII,
                error.InvalidMbxConfiguration,
                error.CoENotSupported,
                error.CoECompleteAccessNotSupported,
                error.Emergency,
                error.NotImplemented,
                error.MbxOutFull,
                error.InvalidMbxContent,
                error.MbxTimeout,
                error.Aborted,
                error.WrongProtocol,
                error.MissedFragment,
                error.ObjectDoesNotExist,
                error.InvalidCoE,
                error.EndOfStream,
                => continue :bus_scan,
            };
        };

        defer eni.deinit();

        var md = gcat.MainDevice.init(
            allocator,
            &port,
            .{ .eeprom_timeout_us = args.eeprom_timeout_us, .mbx_timeout_us = args.mbx_timeout_us, .recv_timeout_us = args.recv_timeout_us },
            eni.value,
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
            error.WrongNumberOfSubdevices,
            => continue :bus_scan,
        };
        // we should not initiate zenoh until the bus contents are verified.

        write_mutex.lock();
        var maybe_zh: ?ZenohHandler = blk: {
            if (args.zenoh_config_file) |config_file| {
                const zh = ZenohHandler.init(allocator, eni.value, config_file, &md, args.zenoh_log_level) catch return error.NonRecoverable;
                break :blk zh;
            } else if (args.zenoh_config_default) {
                const zh = ZenohHandler.init(allocator, eni.value, null, &md, args.zenoh_log_level) catch return error.NonRecoverable;
                break :blk zh;
            } else break :blk null;
        };
        write_mutex.unlock();

        defer {
            if (maybe_zh) |*zh| {
                zh.deinit(allocator);
            }
        }

        md.busPreop(args.preop_timeout_us) catch |err| switch (err) {
            error.LinkError,
            error.InvalidSII,
            error.CoENotSupported,
            error.CoECompleteAccessNotSupported,
            error.Aborted,
            error.WrongProtocol,
            error.InvalidMbxContent,
            => return error.NonRecoverable,
            error.Wkc,
            error.StateChangeRefused,
            error.Timeout,
            error.Emergency,
            error.RecvTimeout,
            error.StateChangeTimeout,
            error.InvalidMbxConfiguration,
            error.UnexpectedSubdevice,
            error.NotImplemented,
            error.MbxOutFull, //wtf is this?
            error.MbxTimeout,
            => continue :bus_scan,
        };

        // warm up zenoh
        if (maybe_zh) |*zh| {
            std.log.warn("warming up zenoh...", .{});
            var z_warmup_timer = std.time.Timer.start() catch @panic("timer unsupported");
            zh.publishInputsOutputs(&md, eni.value) catch |err| {
                std.log.err("failed to publish inputs / outputs on zenoh: {s}", .{@errorName(err)});
                break :bus_scan; // TODO: correct action here?
            };
            std.log.warn("zenoh warmup time: {} us", .{z_warmup_timer.read() / 1000});
        }

        // TODO: wtf jeff reduce the number of errors!
        md.busSafeop(args.safeop_timeout_us) catch |err| switch (err) {
            error.LinkError,
            error.Overflow,
            error.NoSpaceLeft,
            error.CoENotSupported,
            error.CoECompleteAccessNotSupported,
            error.WrongProtocol,
            error.WrongDirection,
            error.SyncManagerNotFound,
            error.RecvTimeout,
            error.Wkc,
            error.StateChangeTimeout,
            error.Timeout,
            error.InvalidCoE,
            error.InvalidSII,
            error.InvalidMbxConfiguration,
            error.Emergency,
            error.NotImplemented,
            error.MbxOutFull,
            error.InvalidMbxContent,
            error.MbxTimeout,
            error.Aborted,
            error.SMAssigns,
            error.NotEnoughFMMUs,
            error.InvalidInputsBitLength,
            error.InvalidOutputsBitLength,
            error.WrongInputsBitLength,
            error.WrongOutputsBitLength,
            => return error.NonRecoverable,
            // => continue :bus_scan,
        };

        md.busOp(args.op_timeout_us) catch |err| switch (err) {
            error.LinkError,
            error.CoENotSupported,
            error.CoECompleteAccessNotSupported,
            error.NotImplemented,
            error.Aborted,
            error.WrongProtocol,
            => return error.NonRecoverable,
            error.RecvTimeout,
            error.Wkc,
            error.StateChangeTimeout,
            error.InvalidMbxConfiguration,
            error.Emergency,
            error.MbxOutFull,
            error.InvalidMbxContent,
            error.MbxTimeout,
            => continue :bus_scan,
        };

        var print_timer = std.time.Timer.start() catch @panic("Timer unsupported");
        var cycle_count: u32 = 0;
        var recv_timeouts: u32 = 0;
        std.log.info("Beginning operation at cycle time: {} us.", .{cycle_time_us});
        while (true) {

            // exchange process data
            {
                write_mutex.lock();
                defer write_mutex.unlock();
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
                zh.publishInputsOutputs(&md, eni.value) catch |err| {
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

var write_mutex = std.Thread.Mutex{};

pub const ZenohHandler = struct {
    arena: *std.heap.ArenaAllocator,
    config: *zenoh.c.z_owned_config_t,
    session: *zenoh.c.z_owned_session_t,
    // TODO: store string keys as [:0] const u8 by calling hash map ourselves with StringContext
    pubs: std.StringArrayHashMap(zenoh.c.z_owned_publisher_t),
    subs: *const std.StringArrayHashMap(SubscriberClosure),

    fn createPublisher(
        allocator: std.mem.Allocator,
        pubs: *std.StringArrayHashMap(zenoh.c.z_owned_publisher_t),
        session: *zenoh.c.z_owned_session_t,
        key: [:0]const u8,
    ) !void {
        var publisher: zenoh.c.z_owned_publisher_t = undefined;
        const view_keyexpr = try allocator.create(zenoh.c.z_view_keyexpr_t);
        const result = zenoh.c.z_view_keyexpr_from_str(view_keyexpr, key.ptr);
        try zenoh.err(result);
        var publisher_options: zenoh.c.z_publisher_options_t = undefined;
        zenoh.c.z_publisher_options_default(&publisher_options);
        publisher_options.congestion_control = zenoh.c.Z_CONGESTION_CONTROL_DROP;
        const result2 = zenoh.c.z_declare_publisher(zenoh.loan(session), &publisher, zenoh.loan(view_keyexpr), &publisher_options);
        try zenoh.err(result2);
        errdefer zenoh.drop(zenoh.move(&publisher));
        const put_result = try pubs.getOrPutValue(key, publisher);
        if (put_result.found_existing) {
            std.log.err("duplicate key found: {s}", .{key});
            return error.PVNameConflict;
        } // TODO: assert this?
    }

    /// Lifetime of md must be past deinit.
    /// Lifetime of eni must be past deinit.
    pub fn init(p_allocator: std.mem.Allocator, eni: gcat.ENI, maybe_config_file: ?[:0]const u8, md: *const gcat.MainDevice, log_level: Args.ZenohLogLevel) !ZenohHandler {
        var arena = try p_allocator.create(std.heap.ArenaAllocator);
        arena.* = .init(p_allocator);
        errdefer p_allocator.destroy(arena);
        errdefer arena.deinit();
        const allocator = arena.allocator();

        // TODO: set log level from cli
        try zenoh.err(zenoh.c.zc_init_log_from_env_or(@tagName(log_level)));

        const config = try allocator.create(zenoh.c.z_owned_config_t);
        if (maybe_config_file) |config_file| {
            try zenoh.err(zenoh.c.zc_config_from_file(config, config_file.ptr));
        } else {
            try zenoh.err(zenoh.c.z_config_default(config));
        }
        errdefer zenoh.drop(zenoh.move(config));

        var open_options: zenoh.c.z_open_options_t = undefined;
        zenoh.c.z_open_options_default(&open_options);

        const session = try allocator.create(zenoh.c.z_owned_session_t);
        const open_result = zenoh.c.z_open(session, zenoh.move(config), &open_options);
        try zenoh.err(open_result);
        errdefer zenoh.drop(zenoh.move(session));

        var pubs = std.StringArrayHashMap(zenoh.c.z_owned_publisher_t).init(allocator);
        errdefer pubs.deinit();
        errdefer {
            for (pubs.values()) |*publisher| {
                zenoh.drop(zenoh.move(publisher));
            }
        }

        for (eni.subdevices) |subdevice| {
            for (subdevice.inputs) |input| {
                for (input.entries) |entry| {
                    if (entry.pv_name) |pv_name| {
                        std.log.warn("zenoh: declaring publisher: {s}, ethercat type: {s}", .{ pv_name, @tagName(entry.type) });
                        try createPublisher(allocator, &pubs, session, pv_name);
                    }
                    if (entry.pv_name_fb) |pv_name_fb| {
                        std.log.warn("zenoh: declaring publisher: {s}, ethercat type: {s}", .{ pv_name_fb, @tagName(entry.type) });
                        try createPublisher(allocator, &pubs, session, pv_name_fb);
                    }
                }
            }
            for (subdevice.outputs) |output| {
                for (output.entries) |entry| {
                    if (entry.pv_name_fb) |pv_name_fb| {
                        std.log.warn("zenoh: declaring publisher: {s}, ethercat type: {s}", .{ pv_name_fb, @tagName(entry.type) });
                        try createPublisher(allocator, &pubs, session, pv_name_fb);
                    }
                }
            }
        }

        const subs = try allocator.create(std.StringArrayHashMap(SubscriberClosure));
        subs.* = .init(allocator);
        errdefer subs.deinit();
        errdefer {
            for (subs.values()) |*subscriber_closure| {
                subscriber_closure.deinit();
            }
        }

        for (eni.subdevices, 0..) |subdevice, subdevice_index| {
            var bit_offset: u32 = 0;
            for (subdevice.outputs) |output| {
                for (output.entries) |entry| {
                    defer bit_offset += entry.bits;
                    if (entry.pv_name == null) continue;

                    const key_expr = try allocator.create(zenoh.c.z_view_keyexpr_t);
                    try zenoh.err(zenoh.c.z_view_keyexpr_from_str(key_expr, entry.pv_name.?.ptr));

                    const subscriber_sample_context = try allocator.create(SubscriberSampleContext);
                    subscriber_sample_context.* = SubscriberSampleContext{
                        .subdevice_output_process_data = md.subdevices[subdevice_index].getOutputProcessData(),
                        .type = entry.type,
                        .bit_count = entry.bits,
                        .bit_offset_in_process_data = bit_offset,
                    };

                    const closure = try allocator.create(zenoh.c.z_owned_closure_sample_t);
                    zenoh.c.z_closure_sample(closure, &data_handler, null, subscriber_sample_context);
                    errdefer zenoh.drop(zenoh.move(closure));

                    var subscriber_options: zenoh.c.z_subscriber_options_t = undefined;
                    zenoh.c.z_subscriber_options_default(&subscriber_options);

                    const subscriber = try allocator.create(zenoh.c.z_owned_subscriber_t);
                    try zenoh.err(zenoh.c.z_declare_subscriber(zenoh.loan(session), subscriber, zenoh.loan(key_expr), zenoh.move(closure), &subscriber_options));
                    errdefer zenoh.drop(zenoh.move(subscriber));
                    std.log.warn("zenoh: declared subscriber: {s}, ethercat type: {s}, bit_pos: {}", .{
                        entry.pv_name.?,
                        @tagName(entry.type),
                        bit_offset,
                    });

                    const subscriber_closure = SubscriberClosure{
                        .closure = closure,
                        .subscriber = subscriber,
                    };

                    const put_result = try subs.getOrPutValue(entry.pv_name.?, subscriber_closure);
                    if (put_result.found_existing) {
                        std.log.err("duplicate pv_name found: {s}", .{entry.pv_name.?});
                        return error.PVNameConflict;
                    } // TODO: assert this?
                }
            }
        }

        return ZenohHandler{
            .arena = arena,
            .config = config,
            .session = session,
            .pubs = pubs,
            .subs = subs,
        };
    }

    const SubscriberClosure = struct {
        closure: *zenoh.c.z_owned_closure_sample_t,
        subscriber: *zenoh.c.z_owned_subscriber_t,
        pub fn deinit(self: SubscriberClosure) void {
            zenoh.drop(zenoh.move(self.subscriber));
            zenoh.drop(zenoh.move(self.closure));
        }
    };

    const SubscriberSampleContext = struct {
        subdevice_output_process_data: []u8,
        type: gcat.Exhaustive(gcat.mailbox.coe.DataTypeArea),
        bit_count: u16,
        bit_offset_in_process_data: u32,
    };

    // TODO: get more type safety here for subs_ctx?
    // TODO: refactor naming of subs_context?
    fn data_handler(sample: [*c]zenoh.c.z_loaned_sample_t, subs_ctx: ?*anyopaque) callconv(.c) void {
        // TODO: get rid of this mutex!
        write_mutex.lock();
        defer write_mutex.unlock();

        // if (subs_ctx == null) return; // TODO: assert?
        assert(subs_ctx != null);

        const ctx: *SubscriberSampleContext = @ptrCast(@alignCast(subs_ctx.?));
        const payload = zenoh.c.z_sample_payload(sample);
        var slice: zenoh.c.z_owned_slice_t = undefined;
        zenoh.err(zenoh.c.z_bytes_to_slice(payload, &slice)) catch {
            std.log.err("zenoh: failed to convert bytes to slice", .{});
            return;
        };
        defer zenoh.drop(zenoh.move(&slice));
        var raw_data: []const u8 = undefined;
        raw_data.ptr = zenoh.c.z_slice_data(zenoh.loan(&slice));
        raw_data.len = zenoh.c.z_slice_len(zenoh.loan(&slice));

        const key = zenoh.c.z_sample_keyexpr(sample);
        var view_str: zenoh.c.z_view_string_t = undefined;
        zenoh.c.z_keyexpr_as_view_string(key, &view_str);
        var key_slice: []const u8 = undefined;
        key_slice.ptr = zenoh.c.z_string_data(zenoh.loan(&view_str));
        key_slice.len = zenoh.c.z_string_len(zenoh.loan(&view_str));

        std.log.info("zenoh: received sample from key: {s}, type: {s}, bit_count: {}, bit_offset: {}", .{
            key_slice,
            @tagName(ctx.type),
            ctx.bit_count,
            ctx.bit_offset_in_process_data,
        });

        const data_item = zbor.DataItem.new(raw_data) catch {
            std.log.err("Invalid data for key: {s}, {x}", .{ key_slice, raw_data });
            return;
        };
        switch (ctx.type) {
            .BOOLEAN => {
                const value = zbor.parse(bool, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .BIT1 => {
                const value = zbor.parse(u1, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .BIT2 => {
                const value = zbor.parse(u2, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .BIT3 => {
                const value = zbor.parse(u3, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .BIT4 => {
                const value = zbor.parse(u4, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .BIT5 => {
                const value = zbor.parse(u5, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .BIT6 => {
                const value = zbor.parse(u6, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .BIT7 => {
                const value = zbor.parse(u7, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .BIT8, .UNSIGNED8, .BYTE, .BITARR8 => {
                const value = zbor.parse(u8, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .INTEGER8 => {
                const value = zbor.parse(i8, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .INTEGER16 => {
                const value = zbor.parse(i16, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .INTEGER32 => {
                const value = zbor.parse(i32, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .UNSIGNED16, .BITARR16 => {
                const value = zbor.parse(u16, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .UNSIGNED24 => {
                const value = zbor.parse(u24, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .UNSIGNED32, .BITARR32 => {
                const value = zbor.parse(u32, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .UNSIGNED40 => {
                const value = zbor.parse(u40, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .UNSIGNED48 => {
                const value = zbor.parse(u48, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .UNSIGNED56 => {
                const value = zbor.parse(u56, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .UNSIGNED64 => {
                const value = zbor.parse(u64, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .REAL32 => {
                const value = zbor.parse(f32, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .REAL64 => {
                const value = zbor.parse(f64, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .INTEGER24 => {
                const value = zbor.parse(i24, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .INTEGER40 => {
                const value = zbor.parse(i40, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .INTEGER48 => {
                const value = zbor.parse(i48, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .INTEGER56 => {
                const value = zbor.parse(i56, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .INTEGER64 => {
                const value = zbor.parse(i64, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .OCTET_STRING,
            .UNICODE_STRING,
            .TIME_OF_DAY,
            .TIME_DIFFERENCE,
            .DOMAIN,
            .GUID,
            .PDO_MAPPING,
            .IDENTITY,
            .COMMAND_PAR,
            .SYNC_PAR,
            .UNKNOWN,
            .VISIBLE_STRING,
            => std.log.err("zenoh: keyexpr {s}, Unsupported type: {s}", .{ key_slice, @tagName(ctx.type) }),
        }
    }

    /// Asserts the given key exists.
    fn publishAssumeKey(self: *ZenohHandler, key: [:0]const u8, payload: []const u8) !void {
        var options: zenoh.c.z_publisher_put_options_t = undefined;
        zenoh.c.z_publisher_put_options_default(&options);
        var encoding: zenoh.c.z_owned_encoding_t = undefined;
        zenoh.c.z_encoding_clone(&encoding, zenoh.c.z_encoding_application_cbor());
        options.encoding = zenoh.move(&encoding);
        var bytes: zenoh.c.z_owned_bytes_t = undefined;
        const result_copy = zenoh.c.z_bytes_copy_from_buf(&bytes, payload.ptr, payload.len);
        try zenoh.err(result_copy);
        errdefer zenoh.drop(zenoh.move(&bytes));
        var publisher = self.pubs.get(key).?;
        const result = zenoh.c.z_publisher_put(zenoh.loan(&publisher), zenoh.move(&bytes), &options);
        try zenoh.err(result);
        errdefer comptime unreachable;
    }

    pub fn deinit(self: ZenohHandler, p_allocator: std.mem.Allocator) void {
        for (self.pubs.values()) |*publisher| {
            zenoh.drop(zenoh.move(publisher));
        }
        zenoh.drop(zenoh.move(self.config));
        zenoh.drop(zenoh.move(self.session));
        self.arena.deinit();
        p_allocator.destroy(self.arena);
    }

    pub fn publishInputsOutputs(self: *ZenohHandler, md: *const gcat.MainDevice, eni: gcat.ENI) !void {
        for (md.subdevices, eni.subdevices) |sub, sub_config| {
            const input_data = sub.getInputProcessData();
            var input_fbs = std.io.fixedBufferStream(input_data);
            const input_reader = input_fbs.reader();
            var intput_bit_reader = gcat.wire.lossyBitReader(input_reader);

            for (sub_config.inputs) |input| {
                for (input.entries) |entry| {
                    var out_buffer: [32]u8 = undefined; // TODO: this is arbitrary
                    var fbs_out = std.io.fixedBufferStream(&out_buffer);
                    const writer = fbs_out.writer();
                    zborSerialize(entry, &intput_bit_reader, writer) catch continue;
                    if (entry.pv_name) |pv_name| {
                        try self.publishAssumeKey(pv_name, fbs_out.getWritten());
                    }
                    if (entry.pv_name_fb) |pv_name_fb| {
                        try self.publishAssumeKey(pv_name_fb, fbs_out.getWritten());
                    }
                }
            }

            const output_data = sub.getOutputProcessData();
            var output_fbs = std.io.fixedBufferStream(output_data);
            const output_reader = output_fbs.reader();
            var output_bit_reader = gcat.wire.lossyBitReader(output_reader);

            for (sub_config.outputs) |output| {
                for (output.entries) |entry| {
                    var out_buffer: [32]u8 = undefined; // TODO: this is arbitrary
                    var fbs_out = std.io.fixedBufferStream(&out_buffer);
                    const writer = fbs_out.writer();
                    zborSerialize(entry, &output_bit_reader, writer) catch continue;
                    if (entry.pv_name_fb) |pv_name_fb| {
                        try self.publishAssumeKey(pv_name_fb, fbs_out.getWritten());
                    }
                }
            }
        }
    }
    fn zborSerialize(
        entry: gcat.ENI.SubdeviceConfiguration.PDO.Entry,
        bit_reader: anytype,
        writer: anytype,
    ) error{UnsupportedType}!void {
        switch (entry.type) {
            .BOOLEAN => {
                const value = bit_reader.readBitsNoEof(bool, entry.bits) catch unreachable;
                switch (value) {
                    false => zbor.stringify(false, .{}, writer) catch unreachable,
                    true => zbor.stringify(true, .{}, writer) catch unreachable,
                }
            },
            .BIT1 => {
                const value = bit_reader.readBitsNoEof(u1, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .BIT2 => {
                const value = bit_reader.readBitsNoEof(u2, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .BIT3 => {
                const value = bit_reader.readBitsNoEof(u3, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .BIT4 => {
                const value = bit_reader.readBitsNoEof(u4, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .BIT5 => {
                const value = bit_reader.readBitsNoEof(u5, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .BIT6 => {
                const value = bit_reader.readBitsNoEof(u6, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .BIT7 => {
                const value = bit_reader.readBitsNoEof(u7, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            // TODO: encode as bit array?
            .BIT8, .UNSIGNED8, .BYTE, .BITARR8 => {
                const value = bit_reader.readBitsNoEof(u8, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .INTEGER8 => {
                const value = bit_reader.readBitsNoEof(i8, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .INTEGER16 => {
                const value = bit_reader.readBitsNoEof(i16, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .INTEGER32 => {
                const value = bit_reader.readBitsNoEof(i32, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            // TODO: encode as bit array?
            .UNSIGNED16, .BITARR16 => {
                const value = bit_reader.readBitsNoEof(u16, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .UNSIGNED24 => {
                const value = bit_reader.readBitsNoEof(u24, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            // TODO: encode as bit array?
            .UNSIGNED32, .BITARR32 => {
                const value = bit_reader.readBitsNoEof(u32, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .UNSIGNED40 => {
                const value = bit_reader.readBitsNoEof(u40, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .UNSIGNED48 => {
                const value = bit_reader.readBitsNoEof(u48, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .UNSIGNED56 => {
                const value = bit_reader.readBitsNoEof(u56, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .UNSIGNED64 => {
                const value = bit_reader.readBitsNoEof(u64, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .REAL32 => {
                const value = bit_reader.readBitsNoEof(f32, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .REAL64 => {
                const value = bit_reader.readBitsNoEof(f64, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .INTEGER24 => {
                const value = bit_reader.readBitsNoEof(i24, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .INTEGER40 => {
                const value = bit_reader.readBitsNoEof(i40, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .INTEGER48 => {
                const value = bit_reader.readBitsNoEof(i48, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .INTEGER56 => {
                const value = bit_reader.readBitsNoEof(i56, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .INTEGER64 => {
                const value = bit_reader.readBitsNoEof(i64, entry.bits) catch unreachable;
                zbor.stringify(value, .{}, writer) catch unreachable;
            },
            .OCTET_STRING,
            .UNICODE_STRING,
            .TIME_OF_DAY,
            .TIME_DIFFERENCE,
            .DOMAIN,
            .GUID,
            .PDO_MAPPING,
            .IDENTITY,
            .COMMAND_PAR,
            .SYNC_PAR,
            .UNKNOWN,
            .VISIBLE_STRING,
            => {
                bit_reader.readBitsNoEof(void, entry.bits) catch unreachable;
                return error.UnsupportedType;
            },
        }
    }
};
