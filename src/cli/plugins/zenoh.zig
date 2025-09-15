pub const zenoh = @This();
const std = @import("std");
const gcat = @import("gatorcat");
const assert = std.debug.assert;

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
