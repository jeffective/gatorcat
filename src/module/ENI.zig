//! EtherCAT Network Information (ENI)
//!
//! The ENI defines the expected subdevices and bus topology.
//!
//! This is not fully spec-compliant (Ref: ETG 2100) since it is intended
//! to be simpler and easier to define.
//!
//! The ENI is constant, and will never be modified by the MainDevice.
const std = @import("std");
const assert = std.debug.assert;

const coe = @import("mailbox.zig").coe;
const gcat = @import("root.zig");
const pdi = @import("pdi.zig");
const sii = @import("sii.zig");
const Subdevice = @import("Subdevice.zig");

const ENI = @This();

/// Subdevices in the order they appear in the ethercat ring (index 0 is first subdevice).
subdevices: []const SubdeviceConfiguration,

pub const SubdeviceConfiguration = struct {
    /// ex. "EL7031-0030"
    name: ?[]const u8 = null,
    identity: sii.SubdeviceIdentity,
    /// SDO startup parameters
    startup_parameters: []const StartupParameter = &.{},
    /// Autoconfigure strategy
    auto_config: enum { auto } = .auto,
    /// Inputs w/r/t the maindevice, also called TxPDO's
    inputs: []const PDO = &.{},
    /// Outputs w/r/t the maindevice, also called the RxPDO's
    outputs: []const PDO = &.{},

    /// Information required for the simulator
    sim: ?Sim = null,

    pub const PDO = struct {
        index: u16,
        entries: []const Entry,
        /// Name of the PDO as provided by the subdevice.
        name: ?[:0]const u8 = null,

        pub const Entry = struct {
            /// Index and subindex are zero when the bits are padding.
            index: u16 = 0,
            subindex: u8 = 0,
            type: gcat.Exhaustive(coe.DataTypeArea) = .UNKNOWN,
            /// Number of bits in the process image. This may conflict with the type.
            /// The type may be larger than this, when that occurs, the least significant
            /// bits are in the process image. For example, an INTERGER32 may have bits=16, which are
            /// the 16 least significant bits.
            bits: u16,
            /// Description as provided from the subdevice.
            description: ?[:0]const u8 = null,

            pub fn isGap(self: Entry) bool {
                return self.index == 0;
            }
        };
    };

    pub const Sim = struct {
        // SII EEPROM contents
        eeprom: []const u8,
        /// The physical memory in the subdevice. Also called the DPRAM.
        /// The first 4 KB (addresses 0x0000 - 0x0fff) is reserved
        /// for ethercat and PDI configuration settings.
        /// It may be up to the full addressable space (u16, 65535 kB).
        ///
        /// Currently, this is the first 4 kB.
        physical_memory: []const u8,
    };

    pub fn inputsBitLength(self: SubdeviceConfiguration) u32 {
        var res: u32 = 0;
        for (self.inputs) |input| {
            for (input.entries) |entry| {
                res += entry.bits;
            }
        }
        return res;
    }

    pub fn outputsBitLength(self: SubdeviceConfiguration) u32 {
        var res: u32 = 0;
        for (self.outputs) |output| {
            for (output.entries) |entry| {
                res += entry.bits;
            }
        }
        return res;
    }
    pub const StartupParameter = struct {
        transition: Transition,
        timeout_us: u32,
        direction: Direction,
        index: u16,
        subindex: u8,
        complete_access: bool,
        data: []const u8,

        pub const Direction = enum {
            read,
            write,
        };

        pub const Transition = enum {
            /// INIT -> PREOP
            IP,
            /// INIT -> SAFEOP
            PS,
            /// PREOP -> INIT
            PI,
            /// SAFEOP -> PREOP
            SP,
            /// SAFEOP -> OP
            SO,
            /// SAFEOP -> INIT
            SI,
            /// OP -> SAFEOP
            OS,
            /// OP -> PREOP
            OP,
            /// OP -> INIT
            OI,
            /// INIT -> BOOT
            IB,
            /// BOOT -> INIT
            BI,
            /// INIT -> INIT
            II,
            /// PREOP -> PREOP
            PP,
            /// SAFEOP -> SAFEOP
            SS,
        };
    };
};

pub fn processImageSize(self: *const ENI) u32 {
    const stats = self.processImageStats();
    return stats.input_bytes + stats.output_bytes;
}

pub const ProcessImageStats = struct {
    input_bytes: u32,
    output_bytes: u32,
};

pub fn processImageStats(self: *const ENI) ProcessImageStats {
    // each subdevices will be given a byte aligned area for inputs
    // and a byte aligned area for outputs.
    var input_bytes: u32 = 0;
    var output_bytes: u32 = 0;
    for (self.subdevices) |subdevice_config| {
        input_bytes += (subdevice_config.inputsBitLength() + 7) / 8;
        output_bytes += (subdevice_config.outputsBitLength() + 7) / 8;
    }
    return ProcessImageStats{ .input_bytes = input_bytes, .output_bytes = output_bytes };
}

test {
    std.testing.refAllDecls(@This());
}

pub fn ZigTypeFromEntryType(entry_type: gcat.Exhaustive(coe.DataTypeArea), bits: u16) type {
    return switch (entry_type) {
        .UNSIGNED8,
        .UNSIGNED16,
        .UNSIGNED24,
        .UNSIGNED32,
        .UNSIGNED40,
        .UNSIGNED48,
        .UNSIGNED56,
        .UNSIGNED64,
        .UNKNOWN,
        .BITARR8,
        .BITARR16,
        .BITARR32,
        .BIT1,
        .BIT2,
        .BIT3,
        .BIT4,
        .BIT5,
        .BIT6,
        .BIT7,
        .BIT8,
        .BYTE,
        // TODO: assert bit length?
        => @Type(.{ .int = .{ .signedness = .unsigned, .bits = bits } }),
        .BOOLEAN => blk: {
            comptime assert(bits == 1);
            break :blk bool;
        },
        .INTEGER8,
        .INTEGER16,
        .INTEGER24,
        .INTEGER32,
        .INTEGER40,
        .INTEGER48,
        .INTEGER56,
        .INTEGER64,
        => @Type(.{ .int = .{ .signedness = .signed, .bits = bits } }),
        .REAL32,
        .REAL64,
        => @Type(.{ .float = .{ .bits = bits } }),

        else => unreachable, // TODO: unsupported type
    };
}

pub fn PDOEntryType(entry: SubdeviceConfiguration.PDO.Entry) std.builtin.Type.StructField {
    return std.builtin.Type.StructField{
        .name = entry.description orelse std.fmt.comptimePrint("0x{x:04}:{x:02}", .{ entry.index, entry.subindex }),
        .type = ZigTypeFromEntryType(entry.type, entry.bits),
        .alignment = 0,
        .default_value_ptr = null,
        .is_comptime = false,
    };
}

test PDOEntryType {
    const entry = SubdeviceConfiguration.PDO.Entry{
        .bits = 1,
        .description = "output",
        .index = 1234,
        .subindex = 3,
        .type = .BOOLEAN,
    };
    try std.testing.expect(PDOEntryType(entry).type == bool);
}

pub fn PDOType(pdo: SubdeviceConfiguration.PDO) std.builtin.Type.StructField {
    var entries: [pdo.entries.len]std.builtin.Type.StructField = undefined;
    for (pdo.entries, 0..) |entry, i| {
        entries[i] = PDOEntryType(entry);
        if (entry.index == 0 and entry.subindex == 0) {
            entries[i].name = std.fmt.comptimePrint("_padding{}", .{i});
        }
    }
    const PDOStruct = @Type(.{
        .@"struct" = .{
            .layout = .@"packed",
            .fields = &entries,
            .decls = &[_]std.builtin.Type.Declaration{},
            .is_tuple = false,
        },
    });
    return std.builtin.Type.StructField{
        .name = pdo.name orelse std.fmt.comptimePrint("0x{x:04}", .{pdo.index}),
        .alignment = 0,
        .default_value_ptr = null,
        .is_comptime = false,
        .type = PDOStruct,
    };
}

pub fn ImageType(config: SubdeviceConfiguration, ring_position: u16) std.builtin.Type.StructField {
    var inputs: [config.inputs.len]std.builtin.Type.StructField = undefined;
    for (config.inputs, 0..) |input, i| {
        inputs[i] = PDOType(input);
    }
    // byte-align inputs
    const inputs_padding_bits: u16 = config.inputsBitLength() % 8;
    if (inputs_padding_bits != 0) {
        const field = std.builtin.Type.StructField{
            .alignment = 0,
            .default_value_ptr = null,
            .is_comptime = false,
            .name = "_alignment_padding",
            .type = @Type(.{ .int = .{ .bits = inputs_padding_bits, .signedness = .unsigned } }),
        };
        inputs ++ &[1]std.builtin.Type.StructField{field};
    }

    var outputs: [config.outputs.len]std.builtin.Type.StructField = undefined;
    for (config.outputs, 0..) |output, i| {
        outputs[i] = PDOType(output);
    }
    // byte-align outputs
    const outputs_padding_bits: u16 = config.outputsBitLength() % 8;
    if (outputs_padding_bits != 0) {
        const field = std.builtin.Type.StructField{
            .alignment = 0,
            .default_value_ptr = null,
            .is_comptime = false,
            .name = "_padding",
            .type = @Type(.{ .int = .{ .bits = outputs_padding_bits, .signedness = .unsigned } }),
        };
        inputs ++ &[1]std.builtin.Type.StructField{field};
    }
    const fields: [2]std.builtin.Type.StructField = .{
        std.builtin.Type.StructField{
            .name = "inputs",
            .alignment = 0,
            .default_value_ptr = null,
            .is_comptime = false,
            .type = @Type(.{
                .@"struct" = .{
                    .layout = .@"packed",
                    .fields = &inputs,
                    .decls = &[_]std.builtin.Type.Declaration{},
                    .is_tuple = false,
                },
            }),
        },
        std.builtin.Type.StructField{
            .name = "outputs",
            .alignment = 0,
            .default_value_ptr = null,
            .is_comptime = false,
            .type = @Type(.{
                .@"struct" = .{
                    .layout = .@"packed",
                    .fields = &outputs,
                    .decls = &[_]std.builtin.Type.Declaration{},
                    .is_tuple = false,
                },
            }),
        },
    };
    const ImageStruct = @Type(.{
        .@"struct" = .{
            .layout = .@"packed",
            .fields = &fields,
            .decls = &[_]std.builtin.Type.Declaration{},
            .is_tuple = false,
        },
    });
    return std.builtin.Type.StructField{
        .name = std.fmt.comptimePrint("s{}_{s}", .{ ring_position, config.name }),
        .alignment = 0,
        .default_value_ptr = null,
        .is_comptime = false,
        .type = ImageStruct,
    };
}

pub fn ProcessImageType(eni: @This()) type {
    var subs: [eni.subdevices.len]std.builtin.Type.StructField = undefined;
    for (eni.subdevices, 0..) |subdevice_config, i| {
        subs[i] = ImageType(subdevice_config, i);
    }
    return @Type(.{
        .@"struct" = .{
            .layout = .@"packed",
            .fields = &subs,
            .decls = &[_]std.builtin.Type.Declaration{},
            .is_tuple = false,
        },
    });
}

test ProcessImageType {
    const eni: @This() = .{ .subdevices = &.{
        .{
            .name = "EK1100",
            .identity = .{ .vendor_id = 2, .product_code = 72100946, .revision_number = 1114112 },
        },
        .{
            .name = "EL2008",
            .identity = .{ .vendor_id = 2, .product_code = 131608658, .revision_number = 1048576 },
            .outputs = &.{
                .{ .index = 5632, .entries = &.{.{ .index = 28672, .subindex = 1, .type = .BOOLEAN, .bits = 1, .description = "Output" }}, .name = "Channel 1" },
                .{ .index = 5633, .entries = &.{.{ .index = 28688, .subindex = 1, .type = .BOOLEAN, .bits = 1, .description = "Output" }}, .name = "Channel 2" },
                .{ .index = 5634, .entries = &.{.{ .index = 28704, .subindex = 1, .type = .BOOLEAN, .bits = 1, .description = "Output" }}, .name = "Channel 3" },
                .{ .index = 5635, .entries = &.{.{ .index = 28720, .subindex = 1, .type = .BOOLEAN, .bits = 1, .description = "Output" }}, .name = "Channel 4" },
                .{ .index = 5636, .entries = &.{.{ .index = 28736, .subindex = 1, .type = .BOOLEAN, .bits = 1, .description = "Output" }}, .name = "Channel 5" },
                .{ .index = 5637, .entries = &.{.{ .index = 28752, .subindex = 1, .type = .BOOLEAN, .bits = 1, .description = "Output" }}, .name = "Channel 6" },
                .{ .index = 5638, .entries = &.{.{ .index = 28768, .subindex = 1, .type = .BOOLEAN, .bits = 1, .description = "Output" }}, .name = "Channel 7" },
                .{ .index = 5639, .entries = &.{.{ .index = 28784, .subindex = 1, .type = .BOOLEAN, .bits = 1, .description = "Output" }}, .name = "Channel 8" },
            },
        },
    } };

    var pi: ProcessImageType(eni) = undefined;
    pi.s1_EL2008.outputs.@"Channel 1".Output = true;
    try std.testing.expect(pi.s1_EL2008.outputs.@"Channel 1".Output == true);
}

/// Initialize a slice of undefined subdevices using information from the ENI.
///
/// We also layout the process image here.
///
/// Most implementations put the inputs in the first half of the process image
/// and the outputs in the last half. This unnessesarily destroys information.
/// The logical grouping of the data is by subdevice, not by inputs and outputs.
/// Therefore, we will place the data for each subdevice together, like so:
///
/// - subdevice 0 inputs (byte-aligned)
/// - subdevice 0 outputs (byte-aligned)
/// - subdevice 1 inputs (byte-aligned)
/// - subdevice 1 outputs (byte-aligned)
/// - ...
///
/// The start of each input or output area is byte-aligned.
/// For example, a subdevice having 4 input bits and 4 output bits will
/// consume 2 bytes, where the first byte has the four least significant input bits and 4
/// padding bits, and the second byte has 4 output bits and 4 padding bits.
///
/// Asserts subdevices is the same length as eni.subdevices.
/// Asserts process_image is the same length as eni.processImageSize
pub fn initSubdevicesFromENI(eni: ENI, subdevices: []Subdevice, process_image: []u8) void {
    assert(eni.subdevices.len <= gcat.max_subdevices);
    assert(eni.subdevices.len == subdevices.len);
    assert(eni.processImageSize() == process_image.len);

    if (subdevices.len == 0) return;

    var last_byte_idx: u32 = 0;
    for (subdevices, eni.subdevices, 0..) |*subdevice, subdevice_config, i| {

        // subdevices without inputs or outputs will receive empty slice
        const inputs_byte_size: u32 = (subdevice_config.inputsBitLength() + 7) / 8;
        const outputs_byte_size: u32 = (subdevice_config.outputsBitLength() + 7) / 8;

        const inputs: []u8 = process_image[last_byte_idx .. last_byte_idx + inputs_byte_size];
        const inputs_area: pdi.LogicalMemoryArea = .{ .start_addr = last_byte_idx, .bit_length = subdevice_config.inputsBitLength() };
        last_byte_idx += inputs_byte_size;

        const outputs: []u8 = process_image[last_byte_idx .. last_byte_idx + outputs_byte_size];
        const outputs_area: pdi.LogicalMemoryArea = .{ .start_addr = last_byte_idx, .bit_length = subdevice_config.outputsBitLength() };
        last_byte_idx += outputs_byte_size;

        const pi = Subdevice.ProcessImage{
            .inputs = inputs,
            .inputs_area = inputs_area,
            .outputs = outputs,
            .outputs_area = outputs_area,
        };

        subdevice.* = Subdevice.init(subdevice_config, @intCast(i), pi);
    }
    assert(last_byte_idx == eni.processImageSize());

    // check for overlaps
    assert(subdevices.len > 0);
    // TODO: check slices too
    for (1..subdevices.len) |i| {
        const this_start = subdevices[i].runtime_info.pi.inputs_area.start_addr;
        assert(this_start <= process_image.len);
        const prev_start = subdevices[i - 1].runtime_info.pi.inputs_area.start_addr;
        assert(prev_start <= process_image.len);
        const prev_len = subdevices[i - 1].runtime_info.pi.inputs.len;
        // having the same start addr is allowed if len == 0;
        assert(prev_start + prev_len <= this_start);
    }
    for (1..subdevices.len) |i| {
        const this_start = subdevices[i].runtime_info.pi.outputs_area.start_addr;
        assert(this_start <= process_image.len);
        const prev_start = subdevices[i - 1].runtime_info.pi.outputs_area.start_addr;
        assert(prev_start <= process_image.len);
        const prev_len = subdevices[i - 1].runtime_info.pi.outputs.len;
        // having the same start addr is allowed if len == 0;
        assert(prev_start + prev_len <= this_start);
    }
}

/// Returns the number of input process image variables.
/// Only variables that are not gaps are counted.
pub fn nInputs(self: ENI) u32 {
    var result: u32 = 0;
    for (self.subdevices) |subdevice| {
        for (subdevice.inputs) |input| {
            for (input.entries) |entry| {
                if (!entry.isGap()) |_| {
                    result += 1;
                }
            }
        }
    }
    return result;
}

/// Returns the number of output process image variables.
/// Only variables that are not gaps are counted.
pub fn nOutputs(self: ENI) u32 {
    var result: u32 = 0;
    for (self.subdevices) |subdevice| {
        for (subdevice.outputs) |output| {
            for (output.entries) |entry| {
                if (entry.isGap()) |_| {
                    result += 1;
                }
            }
        }
    }
    return result;
}

pub fn fromFile(allocator: std.mem.Allocator, file_path: []const u8, max_bytes: usize) !gcat.Arena(ENI) {
    const arena = try allocator.create(std.heap.ArenaAllocator);
    errdefer allocator.destroy(arena);
    arena.* = .init(allocator);
    errdefer arena.deinit();
    const eni_bytes = try std.fs.cwd().readFileAllocOptions(
        arena.allocator(),
        file_path,
        max_bytes,
        null,
        .@"1",
        0,
    );
    const eni = try std.zon.parse.fromSlice(gcat.ENI, arena.allocator(), eni_bytes, null, .{});
    return gcat.Arena(ENI){ .arena = arena, .value = eni };
}

pub fn fromFileJson(allocator: std.mem.Allocator, file_path: []const u8, max_bytes: usize) !gcat.Arena(ENI) {
    const arena = try allocator.create(std.heap.ArenaAllocator);
    errdefer allocator.destroy(arena);
    arena.* = .init(allocator);
    errdefer arena.deinit();
    const eni_bytes = try std.fs.cwd().readFileAllocOptions(
        arena.allocator(),
        file_path,
        max_bytes,
        null,
        .@"1",
        0,
    );
    const eni = try std.json.parseFromSliceLeaky(gcat.ENI, arena.allocator(), eni_bytes, .{});
    return gcat.Arena(ENI){ .arena = arena, .value = eni };
}
