const std = @import("std");
const gcat = @import("gatorcat");
const assert = std.debug.assert;

const zbor = @import("zbor");
const zenoh = @import("zenoh");

pub const Config = struct {
    eni: ?ENI = null,

    pub const ENI = struct {
        subdevices: []const Subdevice = &.{},

        pub const Subdevice = struct {
            inputs: []const PDO = &.{},
            outputs: []const PDO = &.{},

            pub const PDO = struct {
                index: u16,
                entries: []const Entry = &.{},

                pub const Entry = struct {
                    index: u16,
                    subindex: u8,
                    /// Publish the value of this PDO entry on zenoh.
                    publishers: []const PubSub = &.{},
                    /// Subscribe to this key on zenoh and write to this PDO entry.
                    subscribers: []const PubSub = &.{},
                };
            };
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
        };
    };

    pub const Options = struct {
        pdo_input_publisher_key_format: ?[:0]const u8 = null,
        pdo_output_publisher_key_format: ?[:0]const u8 = null,
        pdo_output_subscriber_key_format: ?[:0]const u8 = null,
    };

    pub fn initFromENILeaky(arena: std.mem.Allocator, eni: gcat.ENI, options: Options) error{OutOfMemory}!Config {
        var subdevices: std.ArrayList(Config.ENI.Subdevice) = .empty;
        for (eni.subdevices, 0..) |eni_subdevice, subdevice_index| {
            var inputs: std.ArrayList(Config.ENI.Subdevice.PDO) = .empty;
            for (eni_subdevice.inputs) |eni_input| {
                var entries: std.ArrayList(Config.ENI.Subdevice.PDO.Entry) = .empty;
                for (eni_input.entries) |eni_entry| {
                    if (eni_entry.isGap()) continue;
                    const substitutions: ProcessVariableSubstitutions = .{
                        .subdevice_index = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{}", .{subdevice_index})),
                        .subdevice_name = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{?s}", .{eni_subdevice.name})),
                        .pdo_direction = "output",
                        .pdo_name = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{?s}", .{eni_input.name})),
                        .pdo_index_hex = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{x:04}", .{eni_input.index})),
                        .pdo_entry_index_hex = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{x:04}", .{eni_entry.index})),
                        .pdo_entry_subindex_hex = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{x:02}", .{eni_entry.subindex})),
                        .pdo_entry_description = sanitizeKeyExprComponent(try std.fmt.allocPrint(arena, "{?s}", .{eni_entry.description})),
                    };
                    try entries.append(
                        arena,
                        Config.ENI.Subdevice.PDO.Entry{
                            .index = eni_entry.index,
                            .subindex = eni_entry.subindex,
                            .publishers = if (options.pdo_input_publisher_key_format) |pdo_input_publisher_key_format| try arena.dupe(
                                Config.ENI.PubSub,
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
                try inputs.append(arena, Config.ENI.Subdevice.PDO{
                    .index = eni_input.index,
                    .entries = try entries.toOwnedSlice(arena),
                });
            }

            var outputs: std.ArrayList(Config.ENI.Subdevice.PDO) = .empty;
            for (eni_subdevice.outputs) |eni_output| {
                var entries: std.ArrayList(Config.ENI.Subdevice.PDO.Entry) = .empty;
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

                    try entries.append(arena, Config.ENI.Subdevice.PDO.Entry{
                        .index = eni_entry.index,
                        .subindex = eni_entry.subindex,
                        .publishers = if (options.pdo_output_publisher_key_format) |pdo_output_publisher_key_format| try arena.dupe(
                            Config.ENI.PubSub,
                            &.{
                                .{
                                    .key_expr = try processVaribleNameSentinelLeaky(arena, pdo_output_publisher_key_format, substitutions, 0),
                                },
                            },
                        ) else &.{},
                        .subscribers = if (options.pdo_output_subscriber_key_format) |pdo_output_subscriber_key_format| try arena.dupe(
                            Config.ENI.PubSub,
                            &.{
                                .{
                                    .key_expr = try processVaribleNameSentinelLeaky(arena, pdo_output_subscriber_key_format, substitutions, 0),
                                },
                            },
                        ) else &.{},
                    });
                }
                try outputs.append(arena, Config.ENI.Subdevice.PDO{
                    .index = eni_output.index,
                    .entries = try entries.toOwnedSlice(arena),
                });
            }
            try subdevices.append(arena, Config.ENI.Subdevice{
                .inputs = try inputs.toOwnedSlice(arena),
                .outputs = try outputs.toOwnedSlice(arena),
            });
        }

        return Config{ .eni = .{ .subdevices = try subdevices.toOwnedSlice(arena) } };
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
    config: *zenoh.c.z_owned_config_t,
    session: *zenoh.c.z_owned_session_t,
    // TODO: store string keys as [:0] const u8 by calling hash map ourselves with StringContext
    pubs: std.StringArrayHashMap(zenoh.c.z_owned_publisher_t),
    subs: *const std.StringArrayHashMap(SubscriberClosure),
    pdi_write_mutex: *std.Thread.Mutex,

    /// Lifetime of md must be past deinit.
    /// Lifetime of eni must be past deinit.
    /// Lifetime of pdi_write_mutex must be past deinit.
    pub fn init(
        p_allocator: std.mem.Allocator,
        eni: gcat.ENI,
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
                    _ = entry;
                    // if (entry.pv_name) |pv_name| {
                    //     std.log.warn("zenoh: declaring publisher: {s}, ethercat type: {s}", .{ pv_name, gcat.exhaustiveTagName(entry.type) });
                    //     try createPublisher(allocator, &pubs, session, pv_name);
                    // }
                    // if (entry.pv_name_fb) |pv_name_fb| {
                    //     std.log.warn("zenoh: declaring publisher: {s}, ethercat type: {s}", .{ pv_name_fb, gcat.exhaustiveTagName(entry.type) });
                    //     try createPublisher(allocator, &pubs, session, pv_name_fb);
                    // }
                }
            }
            for (subdevice.outputs) |output| {
                for (output.entries) |entry| {
                    _ = entry;
                    // if (entry.pv_name_fb) |pv_name_fb| {
                    //     std.log.warn("zenoh: declaring publisher: {s}, ethercat type: {s}", .{ pv_name_fb, gcat.exhaustiveTagName(entry.type) });
                    //     try createPublisher(allocator, &pubs, session, pv_name_fb);
                    // }
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
                        .pdi_write_mutex = pdi_write_mutex,
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
                        gcat.exhaustiveTagName(entry.type),
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
            .pdi_write_mutex = pdi_write_mutex,
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
        pdi_write_mutex: *std.Thread.Mutex,
    };

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

    // TODO: get more type safety here for subs_ctx?
    // TODO: refactor naming of subs_context?
    fn data_handler(sample: [*c]zenoh.c.z_loaned_sample_t, subs_ctx: ?*anyopaque) callconv(.c) void {
        assert(subs_ctx != null);
        const ctx: *SubscriberSampleContext = @ptrCast(@alignCast(subs_ctx.?));
        // TODO: get rid of this mutex!
        ctx.write_mutex.lock();
        defer ctx.write_mutex.unlock();
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
            => std.log.err("zenoh: keyexpr {s}, Unsupported type: {s}", .{ key_slice, gcat.exhaustiveTagName(ctx.type) }),
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
