const std = @import("std");
const gcat = @import("gatorcat");
const assert = std.debug.assert;

const CliConfig = @import("../Config.zig");

const zbor = @import("zbor");
const zenoh = @import("zenoh");

pub const Config = struct {
    // eni: ?ENI = null,
    process_data: []const ProcessVariable = &.{},

    pub const ProcessVariable = struct {
        subdevice: u16,
        direction: gcat.pdi.Direction,
        pdo_index: u16,
        index: u16,
        subindex: u8,
        publishers: []const PubSub = &.{},
        subscribers: []const PubSub = &.{},
    };

    pub const PubSub = struct {
        key_expr: [:0]const u8,
        // TODO: implement downsampling
        // downsampling: ?Downsampling = null,
        // pub const Downsampling = union {
        //     /// On-change downsampling will publish more often if the data has changed.
        //     ///
        //     /// Data is always dropped before publishing if the time since last publishing
        //     /// is less than min_publishing_interval_us microseconds.
        //     ///
        //     /// Data is always published if the time since last publishing is greater than
        //     /// max_publishing_interval_us microseconds.
        //     ///
        //     /// When the time since last publishing is between the min and max, a value is only
        //     /// published if it has changed since the last published value.
        //     on_change: struct {
        //         min_publishing_interval_us: u32,
        //         max_publishing_interval_us: u32,
        //     },
        // };

        /// For publishers, define how to scale the process data value before publishing on zenoh.
        /// For subscribers, define how to scale the incoming value from zenoh before applying it to the
        /// process data.
        ///
        /// Out-of-bounds results of scaling are clamped to the nearest valid value.
        /// NaNs are dropped.
        scale: ?Scale = null,

        pub const Scale = union(enum) {
            /// inverts bools
            not,
            /// y = coeffs[0]*x*x + coeffs[1]*x + coeffs[2]
            polynomial: struct {
                /// The coefficients of a polynomial in decreasing order.
                /// For example, a y=2x+1 scaling would be &.{2.0, 1.0}.
                coeffs: []const f64,

                /// For publishers, the type placed on zenoh.
                /// For subscribers, the type accepted from zenoh.
                type: enum { f64 } = .f64,
            },
            /// a function of the form y = coeffs[0]*10^(coeffs[1]*x + coeffs[2]) + coeffs[3]
            exp10: struct {
                coeffs: [4]f64,
                /// For publishers, the type placed on zenoh.
                /// For subscribers, the type accepted from zenoh.
                type: enum { f64 } = .f64,
            },
        };
    };

    pub const Options = struct {
        pdo_input_publisher_key_format: ?[:0]const u8 = null,
        pdo_output_publisher_key_format: ?[:0]const u8 = null,
        pdo_output_subscriber_key_format: ?[:0]const u8 = null,
    };

    pub fn initFromENILeaky(arena: std.mem.Allocator, eni: gcat.ENI, options: Options) error{OutOfMemory}!Config {
        var process_variables: std.ArrayList(Config.ProcessVariable) = .empty;

        assert(eni.subdevices.len <= std.math.maxInt(u16));
        for (eni.subdevices, 0..) |eni_subdevice, subdevice_index| {
            for (eni_subdevice.inputs) |eni_input| {
                for (eni_input.entries) |eni_entry| {
                    if (eni_entry.isGap()) continue;
                    const substitutions: ProcessVariableSubstitutions = .{
                        .subdevice_index = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{}", .{subdevice_index})),
                        .subdevice_name = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{?s}", .{eni_subdevice.name})),
                        .pdo_direction = "input",
                        .pdo_name = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{?s}", .{eni_input.name})),
                        .pdo_index_hex = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{x:04}", .{eni_input.index})),
                        .pdo_entry_index_hex = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{x:04}", .{eni_entry.index})),
                        .pdo_entry_subindex_hex = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{x:02}", .{eni_entry.subindex})),
                        .pdo_entry_description = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{?s}", .{eni_entry.description})),
                    };
                    try process_variables.append(
                        arena,
                        ProcessVariable{
                            .subdevice = @intCast(subdevice_index),
                            .direction = .input,
                            .pdo_index = eni_input.index,
                            .index = eni_entry.index,
                            .subindex = eni_entry.subindex,
                            .publishers = if (options.pdo_input_publisher_key_format) |pdo_input_publisher_key_format| try arena.dupe(
                                Config.PubSub,
                                &.{
                                    .{
                                        .key_expr = try processVaribleNameSentinelLeaky(arena, pdo_input_publisher_key_format, substitutions, 0),
                                    },
                                },
                            ) else &.{},
                            .subscribers = &.{},
                        },
                    );
                }
            }
            for (eni_subdevice.outputs) |eni_output| {
                for (eni_output.entries) |eni_entry| {
                    if (eni_entry.isGap()) continue;
                    const substitutions: ProcessVariableSubstitutions = .{
                        .subdevice_index = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{}", .{subdevice_index})),
                        .subdevice_name = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{?s}", .{eni_subdevice.name})),
                        .pdo_direction = "output",
                        .pdo_name = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{?s}", .{eni_output.name})),
                        .pdo_index_hex = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{x:04}", .{eni_output.index})),
                        .pdo_entry_index_hex = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{x:04}", .{eni_entry.index})),
                        .pdo_entry_subindex_hex = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{x:02}", .{eni_entry.subindex})),
                        .pdo_entry_description = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{?s}", .{eni_entry.description})),
                    };
                    try process_variables.append(
                        arena,
                        ProcessVariable{
                            .subdevice = @intCast(subdevice_index),
                            .direction = .output,
                            .pdo_index = eni_output.index,
                            .index = eni_entry.index,
                            .subindex = eni_entry.subindex,
                            .publishers = if (options.pdo_output_publisher_key_format) |pdo_output_publisher_key_format| try arena.dupe(
                                Config.PubSub,
                                &.{
                                    .{
                                        .key_expr = try processVaribleNameSentinelLeaky(arena, pdo_output_publisher_key_format, substitutions, 0),
                                    },
                                },
                            ) else &.{},
                            .subscribers = if (options.pdo_output_subscriber_key_format) |pdo_output_subscriber_key_format| try arena.dupe(
                                Config.PubSub,
                                &.{
                                    .{
                                        .key_expr = try processVaribleNameSentinelLeaky(arena, pdo_output_subscriber_key_format, substitutions, 0),
                                    },
                                },
                            ) else &.{},
                        },
                    );
                }
            }
        }

        return Config{ .process_data = try process_variables.toOwnedSlice(arena) };
    }

    pub fn initFromENI(gpa: std.mem.Allocator, eni: gcat.ENI, options: Options) error{OutOfMemory}!gcat.Arena(Config) {
        const arena = try gpa.create(std.heap.ArenaAllocator);
        errdefer gpa.destroy(arena);
        arena.* = std.heap.ArenaAllocator.init(gpa);
        errdefer arena.deinit();
        return .{
            .arena = arena,
            .value = try initFromENILeaky(arena.allocator(), eni, options),
        };
    }
};

pub const ProcessVariableSubstitutions = struct {
    subdevice_index: []const u8,
    subdevice_name: []const u8,
    pdo_direction: []const u8,
    pdo_name: []const u8,
    pdo_index_hex: []const u8,
    pdo_entry_index_hex: []const u8,
    pdo_entry_subindex_hex: []const u8,
    pdo_entry_description: []const u8,
};

pub fn processVaribleNameSentinelLeaky(
    arena: std.mem.Allocator,
    format: []const u8,
    substitutions: ProcessVariableSubstitutions,
    comptime sentinel: u8,
) error{OutOfMemory}![:sentinel]const u8 {
    var res: std.ArrayList(u8) = .empty;
    try res.appendSlice(arena, format);
    inline for (comptime std.meta.fieldNames(ProcessVariableSubstitutions)) |field_name| {
        try findAndReplaceSingleForwardPass(arena, &res, "{{" ++ field_name ++ "}}", @field(substitutions, field_name));
    }
    return try res.toOwnedSliceSentinel(arena, sentinel);
}

/// Replaces all instances of "needle" in "haystack" using a single, forward pass.
/// It is fine if needle == replacement.
/// Needle must not have zero length.
pub fn findAndReplaceSingleForwardPass(
    allocator: std.mem.Allocator,
    haystack: *std.ArrayList(u8),
    needle: []const u8,
    replacement: []const u8,
) !void {
    assert(needle.len > 0);
    var cursor: usize = 0;
    while (cursor < haystack.items.len) {
        cursor = std.mem.indexOfPos(
            u8,
            haystack.items,
            cursor,
            needle,
        ) orelse return;
        try haystack.replaceRange(
            allocator,
            cursor,
            needle.len,
            replacement,
        );
        cursor += replacement.len;
    }
}

fn testFindAndReplaceSingleForwardPass(haystack_init: []const u8, needle: []const u8, replacement: []const u8, expected: []const u8) !void {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var haystack: std.ArrayList(u8) = .empty;
    try haystack.appendSlice(allocator, haystack_init);
    try findAndReplaceSingleForwardPass(allocator, &haystack, needle, replacement);
    try std.testing.expectEqualSlices(u8, expected, haystack.items);
}

test findAndReplaceSingleForwardPass {
    try testFindAndReplaceSingleForwardPass("aaaa", "a", "b", "bbbb");
    try testFindAndReplaceSingleForwardPass("aaaa", "aa", "b", "bb");
    try testFindAndReplaceSingleForwardPass("aaaa", "a", "bb", "bbbbbbbb");
    try testFindAndReplaceSingleForwardPass("aaaa", "a", "a", "aaaa");
    try testFindAndReplaceSingleForwardPass("aaa", "aa", "b", "ba");
}

/// Sanitizes untrusted input in-place for inclusion into zenoh key expressions.
pub fn sanitizeKeyExprComponent(str: []u8) []u8 {
    // the encoding of strings in ethercat is IEC 8859-1,
    // lets just normalize to 7-bit ascii.
    for (str) |*char| {
        if (!std.ascii.isAscii(char.*)) {
            char.* = '_';
        }
    }
    // *, $, ?, # prohibited by zenoh
    // / is separator
    _ = std.mem.replace(u8, str, "*", "_", str);
    _ = std.mem.replace(u8, str, "$", "_", str);
    _ = std.mem.replace(u8, str, "?", "_", str);
    _ = std.mem.replace(u8, str, "#", "_", str);
    _ = std.mem.replace(u8, str, "/", "_", str);
    // no whitespace (personal preference)
    _ = std.mem.replace(u8, str, " ", "_", str);
    return str;
}

pub const LogLevel = enum { trace, debug, info, warn, @"error" };

pub const ZenohHandler = struct {
    arena: *std.heap.ArenaAllocator,
    session: zenoh.Session,
    pubs: std.StringArrayHashMap(zenoh.AdvancedPublisher),
    subs: *const std.StringArrayHashMap(SubscriberClosure),
    pdi_write_mutex: *std.Thread.Mutex,

    /// Lifetime of md must be past deinit.
    /// Lifetime of eni must be past deinit.
    /// Lifetime of pdi_write_mutex must be past deinit.
    pub fn init(
        p_allocator: std.mem.Allocator,
        cli_config: CliConfig,
        maybe_config_file: ?[:0]const u8,
        md: *const gcat.MainDevice,
        log_level: LogLevel,
        pdi_write_mutex: *std.Thread.Mutex,
    ) !ZenohHandler {
        var arena = try p_allocator.create(std.heap.ArenaAllocator);
        arena.* = .init(p_allocator);
        errdefer p_allocator.destroy(arena);
        errdefer arena.deinit();
        const allocator = arena.allocator();

        // TODO: set log level from cli
        try zenoh.err(zenoh.c.zc_init_log_from_env_or(gcat.exhaustiveTagName(log_level)));

        var config = blk: {
            if (maybe_config_file) |config_file| {
                break :blk try zenoh.Config.initFromFile(config_file);
            } else {
                break :blk try zenoh.Config.initDefault();
            }
        };
        errdefer config.deinit();

        var session = try zenoh.Session.open(&config, &zenoh.Session.OpenOptions.init());
        errdefer session.deinit();

        var pubs = std.StringArrayHashMap(zenoh.AdvancedPublisher).init(allocator);
        errdefer pubs.deinit();
        errdefer {
            for (pubs.values()) |*publisher| {
                publisher.deinit();
            }
        }

        // declare all publishers
        if (cli_config.plugins) |plugins| {
            if (plugins.zenoh) |zenoh_plugin| {
                for (zenoh_plugin.process_data) |pv| {
                    _ = cli_config.eni.lookupProcessVariable(
                        pv.subdevice,
                        pv.direction,
                        pv.pdo_index,
                        pv.index,
                        pv.subindex,
                    ) catch |err| switch (err) {
                        error.NotFound => {
                            std.log.err("Invalid configuration for process variable: {any}", .{pv});
                            return error.InvalidConfig;
                        },
                    };
                    for (pv.publishers) |publisher| {
                        std.log.warn("zenoh: declaring publisher: {s}", .{publisher.key_expr});
                        try createPublisher(&pubs, &session, publisher.key_expr);
                    }
                }
            }
        }

        // declare all subscribers
        const subs = try allocator.create(std.StringArrayHashMap(SubscriberClosure));
        subs.* = .init(allocator);
        errdefer subs.deinit();
        errdefer {
            for (subs.values()) |*subscriber_closure| {
                subscriber_closure.deinit();
            }
        }

        if (cli_config.plugins) |plugins| {
            if (plugins.zenoh) |zenoh_plugin| {
                for (zenoh_plugin.process_data) |pv| {
                    for (pv.subscribers) |subscriber_config| {
                        const pv_info = cli_config.eni.lookupProcessVariable(
                            pv.subdevice,
                            pv.direction,
                            pv.pdo_index,
                            pv.index,
                            pv.subindex,
                        ) catch |err| switch (err) {
                            error.NotFound => {
                                std.log.err("Invalid configuration for process variable: {any}", .{pv});
                                return error.InvalidConfig;
                            },
                        };
                        const entry = pv_info.entry;
                        const subdevice_index = pv.subdevice;
                        const bit_offset = pv_info.bit_offset;
                        const name = subscriber_config.key_expr;

                        var key_expr = try zenoh.KeyExpr.initFromStr(name);
                        errdefer key_expr.deinit();

                        const subscriber_sample_context = try allocator.create(SubscriberSampleContext);
                        errdefer allocator.destroy(subscriber_sample_context);
                        subscriber_sample_context.* = SubscriberSampleContext{
                            .subdevice_output_process_data = md.subdevices[subdevice_index].getOutputProcessData(),
                            .type = entry.type,
                            .bit_count = entry.bits,
                            .bit_offset_in_process_data = bit_offset,
                            .pdi_write_mutex = pdi_write_mutex,
                            .scale = subscriber_config.scale,
                        };

                        const closure = try allocator.create(zenoh.ClosureSample);
                        errdefer allocator.destroy(closure);
                        closure.* = zenoh.ClosureSample.init(
                            &data_handler,
                            null,
                            subscriber_sample_context,
                        );
                        errdefer closure.deinit();

                        var subscriber_options = zenoh.Session.AdvancedSubscriberOptions.init();
                        subscriber_options._c.subscriber_detection = true;
                        const subscriber = try allocator.create(zenoh.AdvancedSubscriber);
                        errdefer allocator.destroy(subscriber);
                        subscriber.* = try session.declareAdvancedSubscriber(&key_expr, closure, &subscriber_options);
                        errdefer subscriber.deinit();

                        std.log.warn("zenoh: declared subscriber: {s}, ethercat type: {s}, bit_pos: {}", .{
                            name,
                            gcat.exhaustiveTagName(entry.type),
                            bit_offset,
                        });

                        const subscriber_closure = SubscriberClosure{
                            .closure = closure,
                            .subscriber = subscriber,
                        };

                        const put_result = try subs.getOrPutValue(name, subscriber_closure);
                        if (put_result.found_existing) {
                            std.log.err("duplicate key_expr found: {s}", .{name});
                            return error.PVNameConflict;
                        } // TODO: assert this?

                    }
                }
            }
        }

        return ZenohHandler{
            .arena = arena,
            .session = session,
            .pubs = pubs,
            .subs = subs,
            .pdi_write_mutex = pdi_write_mutex,
        };
    }

    const SubscriberClosure = struct {
        closure: *zenoh.ClosureSample,
        subscriber: *zenoh.AdvancedSubscriber,
        pub fn deinit(self: SubscriberClosure) void {
            self.closure.deinit();
            self.subscriber.deinit();
        }
    };

    const SubscriberSampleContext = struct {
        subdevice_output_process_data: []u8,
        type: gcat.Exhaustive(gcat.mailbox.coe.DataTypeArea),
        bit_count: u16,
        bit_offset_in_process_data: u32,
        pdi_write_mutex: *std.Thread.Mutex,
        scale: ?Config.PubSub.Scale,
    };

    fn createPublisher(
        pubs: *std.StringArrayHashMap(zenoh.AdvancedPublisher),
        session: *zenoh.Session,
        key: [:0]const u8,
    ) !void {
        const key_expr = try zenoh.KeyExpr.initFromStr(key);

        var publisher_options = zenoh.Session.AdvancedPublisherOptions.init();
        publisher_options._c.publisher_options.congestion_control = zenoh.c.Z_CONGESTION_CONTROL_DROP;
        publisher_options._c.publisher_detection = true;

        var publisher = try session.declareAdvancedPublisher(&key_expr, &publisher_options);
        errdefer publisher.deinit();

        const put_result = try pubs.getOrPutValue(key, publisher);
        if (put_result.found_existing) {
            std.log.err("duplicate key found: {s}", .{key});
            return error.PVNameConflict;
        }
    }

    // TODO: get more type safety here for subs_ctx?
    // TODO: refactor naming of subs_context?
    fn data_handler(sample: [*c]zenoh.c.z_loaned_sample_t, subs_ctx: ?*anyopaque) callconv(.c) void {
        assert(subs_ctx != null);
        const ctx: *SubscriberSampleContext = @ptrCast(@alignCast(subs_ctx.?));
        // TODO: get rid of this mutex!
        ctx.pdi_write_mutex.lock();
        defer ctx.pdi_write_mutex.unlock();
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
            gcat.exhaustiveTagName(ctx.type),
            ctx.bit_count,
            ctx.bit_offset_in_process_data,
        });

        const data_item = zbor.DataItem.new(raw_data) catch {
            std.log.err("Invalid data for key: {s}, {x}", .{ key_slice, raw_data });
            return;
        };
        switch (ctx.type) {
            .BOOLEAN => {
                var value = zbor.parse(bool, data_item, .{}) catch {
                    std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                    return;
                };
                if (ctx.scale) |sc| switch (sc) {
                    .not => {
                        value = !value;
                    },
                    .polynomial, .exp10 => unreachable,
                };
                gcat.wire.writeBitsAtPos(
                    ctx.subdevice_output_process_data,
                    ctx.bit_offset_in_process_data,
                    ctx.bit_count,
                    value,
                );
            },
            .BIT1 => {
                writeMaybeScaledIntsFloats(u1, ctx, data_item, key_slice, raw_data);
            },
            .BIT2 => {
                writeMaybeScaledIntsFloats(u2, ctx, data_item, key_slice, raw_data);
            },
            .BIT3 => {
                writeMaybeScaledIntsFloats(u3, ctx, data_item, key_slice, raw_data);
            },
            .BIT4 => {
                writeMaybeScaledIntsFloats(u4, ctx, data_item, key_slice, raw_data);
            },
            .BIT5 => {
                writeMaybeScaledIntsFloats(u5, ctx, data_item, key_slice, raw_data);
            },
            .BIT6 => {
                writeMaybeScaledIntsFloats(u6, ctx, data_item, key_slice, raw_data);
            },
            .BIT7 => {
                writeMaybeScaledIntsFloats(u7, ctx, data_item, key_slice, raw_data);
            },
            .BIT8, .UNSIGNED8, .BYTE, .BITARR8 => {
                writeMaybeScaledIntsFloats(u8, ctx, data_item, key_slice, raw_data);
            },
            .INTEGER8 => {
                writeMaybeScaledIntsFloats(i8, ctx, data_item, key_slice, raw_data);
            },
            .INTEGER16 => {
                writeMaybeScaledIntsFloats(i16, ctx, data_item, key_slice, raw_data);
            },
            .INTEGER32 => {
                writeMaybeScaledIntsFloats(i32, ctx, data_item, key_slice, raw_data);
            },
            .UNSIGNED16, .BITARR16 => {
                writeMaybeScaledIntsFloats(u16, ctx, data_item, key_slice, raw_data);
            },
            .UNSIGNED24 => {
                writeMaybeScaledIntsFloats(u24, ctx, data_item, key_slice, raw_data);
            },
            .UNSIGNED32, .BITARR32 => {
                writeMaybeScaledIntsFloats(u32, ctx, data_item, key_slice, raw_data);
            },
            .UNSIGNED40 => {
                writeMaybeScaledIntsFloats(u40, ctx, data_item, key_slice, raw_data);
            },
            .UNSIGNED48 => {
                writeMaybeScaledIntsFloats(u48, ctx, data_item, key_slice, raw_data);
            },
            .UNSIGNED56 => {
                writeMaybeScaledIntsFloats(u56, ctx, data_item, key_slice, raw_data);
            },
            .UNSIGNED64 => {
                writeMaybeScaledIntsFloats(u64, ctx, data_item, key_slice, raw_data);
            },
            .REAL32 => {
                writeMaybeScaledIntsFloats(f32, ctx, data_item, key_slice, raw_data);
            },
            .REAL64 => {
                writeMaybeScaledIntsFloats(f64, ctx, data_item, key_slice, raw_data);
            },
            .INTEGER24 => {
                writeMaybeScaledIntsFloats(i24, ctx, data_item, key_slice, raw_data);
            },
            .INTEGER40 => {
                writeMaybeScaledIntsFloats(i40, ctx, data_item, key_slice, raw_data);
            },
            .INTEGER48 => {
                writeMaybeScaledIntsFloats(i48, ctx, data_item, key_slice, raw_data);
            },
            .INTEGER56 => {
                writeMaybeScaledIntsFloats(i56, ctx, data_item, key_slice, raw_data);
            },
            .INTEGER64 => {
                writeMaybeScaledIntsFloats(i64, ctx, data_item, key_slice, raw_data);
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
            => std.log.err("zenoh: keyexpr {s}, Unsupported type: {s}", .{ key_slice, gcat.exhaustiveTagName(ctx.type) }),
        }
    }

    /// Asserts the given key exists.
    fn publishAssumeKey(self: *ZenohHandler, key: [:0]const u8, payload: []const u8) !void {
        var put_options = zenoh.AdvancedPublisher.PutOptions.init();
        var encoding: zenoh.c.z_owned_encoding_t = undefined;
        zenoh.c.z_encoding_clone(&encoding, zenoh.c.z_encoding_application_cbor());
        put_options._c.put_options.encoding = zenoh.move(&encoding);

        var bytes = try zenoh.Bytes.init(payload);
        errdefer bytes.deinit();

        var publisher = self.pubs.get(key).?;
        try publisher.put(&bytes, &put_options);
    }

    pub fn deinit(self: *ZenohHandler, p_allocator: std.mem.Allocator) void {
        for (self.pubs.values()) |*publisher| {
            publisher.deinit();
        }
        self.session.deinit();
        self.arena.deinit();
        p_allocator.destroy(self.arena);
    }

    pub fn publishInputsOutputs(self: *ZenohHandler, md: *const gcat.MainDevice, config: CliConfig) !void {
        if (config.plugins == null) return error.InvalidConfig;
        if (config.plugins.?.zenoh == null) return error.InvalidConfig;
        for (config.plugins.?.zenoh.?.process_data) |pv| {
            for (pv.publishers) |publisher_config| {
                // TODO: optimize to not lookup process variable every time
                const pv_info = config.eni.lookupProcessVariable(
                    pv.subdevice,
                    pv.direction,
                    pv.pdo_index,
                    pv.index,
                    pv.subindex,
                ) catch unreachable; // checked on declare publishers
                const sub_process_data: []const u8 = switch (pv.direction) {
                    .input => md.subdevices[pv.subdevice].getInputProcessData(),
                    .output => md.subdevices[pv.subdevice].getOutputProcessData(),
                };
                var reader = std.Io.Reader.fixed(sub_process_data);
                var input_bit_reader = gcat.wire.LossyBitReader.init(&reader);
                var out_buffer: [32]u8 = undefined; // TODO: this is arbitrary
                var writer = std.Io.Writer.fixed(&out_buffer);
                input_bit_reader.readBitsNoEof(void, pv_info.bit_offset) catch unreachable;
                zborSerialize(pv_info.entry, &input_bit_reader, &writer, publisher_config.scale) catch {
                    std.log.err("cannot serialize to cbor: {any}", .{pv});
                };
                try self.publishAssumeKey(publisher_config.key_expr, writer.buffered());
            }
        }
    }
    fn zborSerialize(
        entry: gcat.ENI.SubdeviceConfiguration.PDO.Entry,
        bit_reader: *gcat.wire.LossyBitReader,
        writer: *std.Io.Writer,
        scale: ?Config.PubSub.Scale,
    ) error{UnsupportedType}!void {
        switch (entry.type) {
            .BOOLEAN => {
                var value = bit_reader.readBitsNoEof(bool, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .not => {
                        value = !value;
                    },
                    .polynomial, .exp10 => unreachable,
                };
                switch (value) {
                    false => zbor.stringify(false, .{}, writer) catch unreachable,
                    true => zbor.stringify(true, .{}, writer) catch unreachable,
                }
            },
            .BIT1 => {
                const value = bit_reader.readBitsNoEof(u1, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .BIT2 => {
                const value = bit_reader.readBitsNoEof(u2, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .BIT3 => {
                const value = bit_reader.readBitsNoEof(u3, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .BIT4 => {
                const value = bit_reader.readBitsNoEof(u4, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .BIT5 => {
                const value = bit_reader.readBitsNoEof(u5, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .BIT6 => {
                const value = bit_reader.readBitsNoEof(u6, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .BIT7 => {
                const value = bit_reader.readBitsNoEof(u7, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            // TODO: encode as bit array?
            .BIT8, .UNSIGNED8, .BYTE, .BITARR8 => {
                const value = bit_reader.readBitsNoEof(u8, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .INTEGER8 => {
                const value = bit_reader.readBitsNoEof(i8, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .INTEGER16 => {
                const value = bit_reader.readBitsNoEof(i16, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .INTEGER32 => {
                const value = bit_reader.readBitsNoEof(i32, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            // TODO: encode as bit array?
            .UNSIGNED16, .BITARR16 => {
                const value = bit_reader.readBitsNoEof(u16, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .UNSIGNED24 => {
                const value = bit_reader.readBitsNoEof(u24, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            // TODO: encode as bit array?
            .UNSIGNED32, .BITARR32 => {
                const value = bit_reader.readBitsNoEof(u32, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .UNSIGNED40 => {
                const value = bit_reader.readBitsNoEof(u40, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .UNSIGNED48 => {
                const value = bit_reader.readBitsNoEof(u48, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .UNSIGNED56 => {
                const value = bit_reader.readBitsNoEof(u56, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .UNSIGNED64 => {
                const value = bit_reader.readBitsNoEof(u64, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .REAL32 => {
                const value = bit_reader.readBitsNoEof(f32, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatCast(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatCast(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .REAL64 => {
                const value = bit_reader.readBitsNoEof(f64, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, value);
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, value);
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .INTEGER24 => {
                const value = bit_reader.readBitsNoEof(i24, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .INTEGER40 => {
                const value = bit_reader.readBitsNoEof(i40, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .INTEGER48 => {
                const value = bit_reader.readBitsNoEof(i48, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .INTEGER56 => {
                const value = bit_reader.readBitsNoEof(i56, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
            },
            .INTEGER64 => {
                const value = bit_reader.readBitsNoEof(i64, entry.bits) catch unreachable;
                if (scale) |sc| switch (sc) {
                    .polynomial => |params| {
                        const fval = poly(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .exp10 => |params| {
                        const fval = exp10(params.coeffs, @floatFromInt(value));
                        zbor.stringify(fval, .{}, writer) catch unreachable;
                    },
                    .not => unreachable,
                } else {
                    zbor.stringify(value, .{}, writer) catch unreachable;
                }
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

/// Evaluate a polynomial with coefficients `coeffs` at `x`.
///
/// coeffs are in decreasing order.
///
/// For example:
/// coeffs &.{1.0, 2.0, -3.0} is polynomial y = 1.0*x^2 + 2.0*x - 3.0.
///
/// Special cases:
/// - when coeffs.len == 0, always returns zero.
fn poly(coeffs: []const f64, x: f64) f64 {
    // Horner's method.
    // https://en.wikipedia.org/wiki/Horner%27s_method
    var result: f64 = 0;
    for (coeffs) |coeff| {
        result = result * x + coeff;
    }
    return result;
}

test poly {
    try std.testing.expectEqual(2.0, poly(&.{ 2.0, 0.0 }, 1.0));
    try std.testing.expectEqual(2.0, poly(&.{ 2.0, 0.0 }, 1.0));
    try std.testing.expectEqual(4.0, poly(&.{ 2.0, 0.0 }, 2.0));
    try std.testing.expectEqual(21.0, poly(&.{ 1.0, 1.0, 1.0 }, 4.0));
}

fn exp10(coeffs: [4]f64, x: f64) f64 {
    return coeffs[0] * std.math.pow(f64, 10.0, coeffs[1] * x + coeffs[2]) + coeffs[3];
}

test exp10 {
    try std.testing.expectEqual(1.0, exp10(.{ 1.0, 0.0, 0.0, 0.0 }, 0.0));
    try std.testing.expectEqual(1.0000000000004e13, exp10(.{ 1.0, 2.0, 3.0, 4.0 }, 5.0));
    try std.testing.expectEqual(7.1021965193816e13, exp10(.{ 1.1, 2.1, 3.1, 4.1 }, 5.1));
}

fn writeMaybeScaledIntsFloats(
    comptime T: type,
    ctx: *const ZenohHandler.SubscriberSampleContext,
    data_item: zbor.DataItem,
    key_slice: []const u8,
    raw_data: []const u8,
) void {
    if (ctx.scale) |sc| switch (sc) {
        .not => unreachable,
        .polynomial => |params| {
            const value = zbor.parse(f64, data_item, .{}) catch {
                std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                return;
            };
            const scaled = poly(params.coeffs, value);
            gcat.wire.writeBitsAtPos(
                ctx.subdevice_output_process_data,
                ctx.bit_offset_in_process_data,
                ctx.bit_count,
                std.math.lossyCast(T, scaled),
            );
        },
        .exp10 => |params| {
            const value = zbor.parse(f64, data_item, .{}) catch {
                std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
                return;
            };
            const scaled = exp10(params.coeffs, value);
            gcat.wire.writeBitsAtPos(
                ctx.subdevice_output_process_data,
                ctx.bit_offset_in_process_data,
                ctx.bit_count,
                std.math.lossyCast(T, scaled),
            );
        },
    } else {
        const value = zbor.parse(T, data_item, .{}) catch {
            std.log.err("Failed to decode cbor data for key: {s}, data: {x}", .{ key_slice, raw_data });
            return;
        };
        gcat.wire.writeBitsAtPos(
            ctx.subdevice_output_process_data,
            ctx.bit_offset_in_process_data,
            ctx.bit_count,
            value,
        );
    }
}
