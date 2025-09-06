//! Configuration file to support configuration of
//! additional features in the gatorcat CLI.
const std = @import("std");
const assert = std.debug.assert;

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
        /// The process data image can be manipulated via zenoh.
        pdi: ?PDI = null,

        pub const PDI = struct {
            /// Publishers publish data from process data image.
            /// They must be sorted by bit position without overlaps for optimal performance.
            /// This requirement may be relaxed in the future.
            publishers: []const PubSub = &.{},
            /// Subscribers receive data fron zenoh and write to the process data image.
            /// They must be sorted by bit position without overlaps for optimal performance.
            /// This requirement may be relaxed in the future.
            subscribers: []const PubSub = &.{},

            pub const PubSub = struct {
                /// The zenoh key expression for the publisher / subscriber.
                key_expr: [:0]const u8,
                /// The bit position in the process image at the start of the data.
                bit_position: u35,
                /// The bit length of the data in the process data image.
                bit_length: u16,
                /// The type of the data in the process data image.
                type: gcat.Exhaustive(gcat.mailbox.coe.DataTypeArea),
                /// The encoding of the payload in zenoh.
                encoding: Encoding = .application_cbor,
                /// Maximum allowable publishing rate in Hz.
                /// Data is simply dropped before being published
                /// if the last publishing time was too recent.
                max_rate_hz: f64 = 0,

                pub const Encoding = enum {
                    application_cbor,
                };

                comptime {
                    // The ethercat process data is a 32-bit byte-addressable space.
                    // Therefore, u35 is the size of the bit-addressable space.
                    assert(@FieldType(PubSub, "bit_position") ==
                        std.math.IntFittingRange(0, std.math.maxInt(u32) * 8));
                }
            };
        };

        pub fn initFromENI(gpa: std.mem.Allocator, eni: *const gcat.ENI) error{OutOfMemory}!gcat.Arena(Zenoh) {
            const arena = try gpa.create(std.heap.ArenaAllocator);
            arena.* = std.heap.ArenaAllocator.init(gpa);
            errdefer gpa.destroy(arena);
            const allocator = arena.allocator();
            var publishers: std.ArrayList(PDI.PubSub) = try .initCapacity(allocator, eni.nInputs() + eni.nOutputs());
            var subscribers: std.ArrayList(PDI.PubSub) = try .initCapacity(allocator, eni.nOutputs());

            return gcat.Arena(Zenoh){
                .arena = arena,
                .value = .{
                    .pdi = .{
                        .publishers = try publishers.toOwnedSlice(allocator),
                        .subscribers = try subscribers.toOwnedSlice(allocator),
                    },
                },
            };
        }
    };
};

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
