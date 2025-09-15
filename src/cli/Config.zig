//! Configuration file to support configuration of
//! additional features in the gatorcat CLI.
const std = @import("std");
const assert = std.debug.assert;
const Config = @This();

const gcat = @import("gatorcat");
const zenoh = @import("zenoh");

/// EtherCAT Network Information
/// Description of the contents and configuration of the EtherCAT network.
eni: gcat.ENI,

plugins: ?Plugins = null,

pub const Plugins = struct {
    zenoh: ?Zenoh = null,

    /// The zenoh plugin allows publishing and subscribing on a zenoh session.
    pub const Zenoh = struct {
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

        pub fn initFromENILeaky(arena: std.mem.Allocator, eni: gcat.ENI, options: Options) error{OutOfMemory}!Zenoh {
            var subdevices: std.ArrayList(Zenoh.ENI.Subdevice) = .empty;
            for (eni.subdevices, 0..) |eni_subdevice, subdevice_index| {
                var inputs: std.ArrayList(Zenoh.ENI.Subdevice.PDO) = .empty;
                for (eni_subdevice.inputs) |eni_input| {
                    var entries: std.ArrayList(Zenoh.ENI.Subdevice.PDO.Entry) = .empty;
                    for (eni_input.entries) |eni_entry| {
                        if (eni_entry.isGap()) continue;
                        const substitutions: ProcessVariableSubstitutions = .{
                            .subdevice_index = zenohSanitize(try std.fmt.allocPrint(arena, "{}", .{subdevice_index})),
                            .subdevice_name = zenohSanitize(try std.fmt.allocPrint(arena, "{?s}", .{eni_subdevice.name})),
                            .pdo_direction = "output",
                            .pdo_name = zenohSanitize(try std.fmt.allocPrint(arena, "{?s}", .{eni_input.name})),
                            .pdo_index_hex = zenohSanitize(try std.fmt.allocPrint(arena, "{x:04}", .{eni_input.index})),
                            .pdo_entry_index_hex = zenohSanitize(try std.fmt.allocPrint(arena, "{x:04}", .{eni_entry.index})),
                            .pdo_entry_subindex_hex = zenohSanitize(try std.fmt.allocPrint(arena, "{x:02}", .{eni_entry.subindex})),
                            .pdo_entry_description = zenohSanitize(try std.fmt.allocPrint(arena, "{?s}", .{eni_entry.description})),
                        };
                        try entries.append(
                            arena,
                            Zenoh.ENI.Subdevice.PDO.Entry{
                                .index = eni_entry.index,
                                .subindex = eni_entry.subindex,
                                .publishers = if (options.pdo_input_publisher_key_format) |pdo_input_publisher_key_format| try arena.dupe(
                                    Zenoh.ENI.PubSub,
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
                    try inputs.append(arena, Zenoh.ENI.Subdevice.PDO{
                        .index = eni_input.index,
                        .entries = try entries.toOwnedSlice(arena),
                    });
                }

                var outputs: std.ArrayList(Zenoh.ENI.Subdevice.PDO) = .empty;
                for (eni_subdevice.outputs) |eni_output| {
                    var entries: std.ArrayList(Zenoh.ENI.Subdevice.PDO.Entry) = .empty;
                    for (eni_output.entries) |eni_entry| {
                        if (eni_entry.isGap()) continue;
                        const substitutions: ProcessVariableSubstitutions = .{
                            .subdevice_index = zenohSanitize(try std.fmt.allocPrint(arena, "{}", .{subdevice_index})),
                            .subdevice_name = zenohSanitize(try std.fmt.allocPrint(arena, "{?s}", .{eni_subdevice.name})),
                            .pdo_direction = "output",
                            .pdo_name = zenohSanitize(try std.fmt.allocPrint(arena, "{?s}", .{eni_output.name})),
                            .pdo_index_hex = zenohSanitize(try std.fmt.allocPrint(arena, "{x:04}", .{eni_output.index})),
                            .pdo_entry_index_hex = zenohSanitize(try std.fmt.allocPrint(arena, "{x:04}", .{eni_entry.index})),
                            .pdo_entry_subindex_hex = zenohSanitize(try std.fmt.allocPrint(arena, "{x:02}", .{eni_entry.subindex})),
                            .pdo_entry_description = zenohSanitize(try std.fmt.allocPrint(arena, "{?s}", .{eni_entry.description})),
                        };

                        try entries.append(arena, Zenoh.ENI.Subdevice.PDO.Entry{
                            .index = eni_entry.index,
                            .subindex = eni_entry.subindex,
                            .publishers = if (options.pdo_output_publisher_key_format) |pdo_output_publisher_key_format| try arena.dupe(
                                Zenoh.ENI.PubSub,
                                &.{
                                    .{
                                        .key_expr = try processVaribleNameSentinelLeaky(arena, pdo_output_publisher_key_format, substitutions, 0),
                                    },
                                },
                            ) else &.{},
                            .subscribers = if (options.pdo_output_subscriber_key_format) |pdo_output_subscriber_key_format| try arena.dupe(
                                Zenoh.ENI.PubSub,
                                &.{
                                    .{
                                        .key_expr = try processVaribleNameSentinelLeaky(arena, pdo_output_subscriber_key_format, substitutions, 0),
                                    },
                                },
                            ) else &.{},
                        });
                    }
                    try outputs.append(arena, Zenoh.ENI.Subdevice.PDO{
                        .index = eni_output.index,
                        .entries = try entries.toOwnedSlice(arena),
                    });
                }
                try subdevices.append(arena, Zenoh.ENI.Subdevice{
                    .inputs = try inputs.toOwnedSlice(arena),
                    .outputs = try outputs.toOwnedSlice(arena),
                });
            }

            return Zenoh{ .eni = .{ .subdevices = try subdevices.toOwnedSlice(arena) } };
        }

        pub fn initFromENI(gpa: std.mem.Allocator, eni: gcat.ENI, options: Options) error{OutOfMemory}!gcat.Arena(Zenoh) {
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

// var pv_name: ?[:0]const u8 = null;
// var pv_name_fb: ?[:0]const u8 = null;
// if (entry.index == 0 and entry.subindex == 0) {
//     pv_name = null;
//     pv_name_fb = null;
// } else {
//     pv_name = try processVariableNameZ(
//         allocator,
//         ring_position,
//         if (sm_comm_type == .input) .input else .output,
//         entry.index,
//         entry.subindex,
//         name,
//         try allocator.dupeZ(u8, object_description.name.slice()),
//         try allocator.dupeZ(u8, entry_description.data.slice()),
//         pv_name_prefix,
//         false,
//     );
//     pv_name_fb = try processVariableNameZ(
//         allocator,
//         ring_position,
//         if (sm_comm_type == .input) .input else .output,
//         entry.index,
//         entry.subindex,
//         name,
//         try allocator.dupeZ(u8, object_description.name.slice()),
//         try allocator.dupeZ(u8, entry_description.data.slice()),
//         pv_name_prefix,
//         true,
//     );
// }

pub const process_variable_fmt = "subdevices/{}/{s}/{s}/0x{x:04}/{s}/0x{x:02}/{s}";

/// Produces a unique process image variable name.
pub fn processVariableNameZ(
    allocator: std.mem.Allocator,
    ring_position: u16,
    direction: gcat.pdi.Direction,
    pdo_idx: u16,
    entry_idx: u16,
    subdevice_name: []const u8,
    pdo_name: []const u8,
    entry_description: []const u8,
    maybe_prefix: ?[]const u8,
    comptime is_fb: bool,
) error{OutOfMemory}![:0]const u8 {
    const direction_str: []const u8 = if (direction == .input) "inputs" else "outputs";
    var name: [:0]const u8 = undefined;
    const fb_prefix_fmt = if (is_fb) "maindevice/pdi/" else "";
    if (maybe_prefix) |prefix| {
        name = try std.fmt.allocPrintSentinel(
            allocator,
            "{s}/" ++ fb_prefix_fmt ++ process_variable_fmt,
            .{
                prefix,
                ring_position,
                zenohSanitize(try allocator.dupe(u8, subdevice_name)),
                direction_str,
                pdo_idx,
                zenohSanitize(try allocator.dupe(u8, pdo_name)),
                entry_idx,
                zenohSanitize(try allocator.dupe(u8, entry_description)),
            },
            0,
        );
    } else {
        name = try std.fmt.allocPrintSentinel(
            allocator,
            fb_prefix_fmt ++ process_variable_fmt,
            .{
                ring_position,
                zenohSanitize(try allocator.dupe(u8, subdevice_name)),
                direction_str,
                pdo_idx,
                zenohSanitize(try allocator.dupe(u8, pdo_name)),
                entry_idx,
                zenohSanitize(try allocator.dupe(u8, entry_description)),
            },
            0,
        );
    }

    return name;
}

/// Sanitizes untrusted input in-place for inclusion into zenoh key expressions.
pub fn zenohSanitize(str: []u8) []u8 {
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

pub fn fromFile(allocator: std.mem.Allocator, file_path: []const u8, max_bytes: usize) !gcat.Arena(Config) {
    const arena = try allocator.create(std.heap.ArenaAllocator);
    errdefer allocator.destroy(arena);
    arena.* = .init(allocator);
    errdefer arena.deinit();
    const config_bytes = try std.fs.cwd().readFileAllocOptions(
        arena.allocator(),
        file_path,
        max_bytes,
        null,
        .@"1",
        0,
    );
    const config = try std.zon.parse.fromSlice(Config, arena.allocator(), config_bytes, null, .{});
    return gcat.Arena(Config){ .arena = arena, .value = config };
}

pub fn fromFileJson(allocator: std.mem.Allocator, file_path: []const u8, max_bytes: usize) !gcat.Arena(Config) {
    const arena = try allocator.create(std.heap.ArenaAllocator);
    errdefer allocator.destroy(arena);
    arena.* = .init(allocator);
    errdefer arena.deinit();
    const config_bytes = try std.fs.cwd().readFileAllocOptions(
        arena.allocator(),
        file_path,
        max_bytes,
        null,
        .@"1",
        0,
    );
    const config = try std.json.parseFromSliceLeaky(Config, arena.allocator(), config_bytes, .{});
    return gcat.Arena(Config){ .arena = arena, .value = config };
}
