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
            publishers: ?[]const PubSub = null,
            /// Subscribers receive data fron zenoh and write to the process data image.
            /// They must be sorted by bit position without overlaps for optimal performance.
            /// This requirement may be relaxed in the future.
            subscribers: ?[]const PubSub = null,

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

            return gcat.Arena(Zenoh).{
                .arena = 
            }

        }
    };
};
