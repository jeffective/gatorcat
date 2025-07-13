const std = @import("std");
const assert = std.debug.assert;

const esc = @import("../esc.zig");
const sim = @import("../sim.zig");
const wire = @import("../wire.zig");

/// SII emulation for sim subdevice
///
/// Ref: IEC 61158-4-12:2019 8.2.5
const SII = @This();

status: esc.SIIControlStatusAddressRegister = .{
    .write_access = false,
    .EEPROM_emulation = false,
    .read_size = .four_bytes,
    .address_algorithm = .two_byte_address,
    .read_operation = false,
    .write_operation = false,
    .reload_operation = false,
    .checksum_error = false,
    .device_info_error = false,
    .command_error = false,
    .write_error = false,
    .busy = false,
    .sii_address = 0,
},
data: esc.SIIDataRegister4Byte = .{ .data = 0 },

pub fn initTick(self: *SII, phys_mem: *sim.Subdevice.PhysMem) void {
    sim.writeRegister(self.status, esc.RegisterMap.SII_control_status, phys_mem);
    sim.writeRegister(self.data, esc.RegisterMap.SII_data, phys_mem);
}

// TODO: writable eeprom
pub fn tick(self: *SII, phys_mem: *sim.Subdevice.PhysMem, eeprom: []const u8) void {
    defer sim.writeRegister(self.status, esc.RegisterMap.SII_control_status, phys_mem);
    defer sim.writeRegister(self.data, esc.RegisterMap.SII_data, phys_mem);

    const cmd = sim.readRegister(esc.SIIControlStatusAddressRegister, esc.RegisterMap.SII_control_status, phys_mem);

    const n_ops: u2 = @intFromBool(cmd.read_operation) + @intFromBool(cmd.write_operation) + @intFromBool(cmd.reload_operation);
    const too_many_ops: bool = n_ops > 1;

    done: switch (self.status.busy) {
        false => {
            if (too_many_ops) {
                self.status.command_error = true;
                std.log.err("eeprom: simultaneous read/write/reload ops commanded of eeprom", .{});
                break :done;
            }
            if (cmd.write_operation and !self.status.write_access) {
                self.status.command_error = true;
                std.log.err("eeprom: write operation attempted without write access enabled", .{});
                break :done;
            }
            if (cmd.write_operation) {
                self.status.command_error = true;
                std.log.err("TODO: implement eeprom write", .{});
                break :done;
            }

            if (!validSIIAddress(cmd.sii_address, eeprom)) {
                self.status.command_error = true;
                std.log.err("invalid sii address: {}, eeprom size: {}", .{ cmd.sii_address, eeprom.len });
                break :done;
            }

            self.status.command_error = false;
            self.status.sii_address = cmd.sii_address;
            self.status.busy = true;
        },
        true => {
            // TODO: implement random sii delay
            assert(validSIIAddress(self.status.sii_address, eeprom));
            const start = @as(u32, self.status.sii_address) * 2;
            self.data = wire.packFromECatSlice(esc.SIIDataRegister4Byte, eeprom[start .. start + 4]);
            self.status.busy = false;
            break :done;
        },
    }
}

fn validSIIAddress(word_address: u16, eeprom: []const u8) bool {
    return (@as(u17, word_address) * 2 + 4 <= eeprom.len);
}

test "valid sii address" {
    try std.testing.expect(validSIIAddress(0, &.{ 0, 0, 0, 0 }));
    try std.testing.expect(!validSIIAddress(0, &.{ 0, 0, 0 }));
    try std.testing.expect(validSIIAddress(0, &.{ 0, 0, 0, 0, 0 }));
    try std.testing.expect(!validSIIAddress(1, &.{ 0, 0, 0, 0 }));
}

test {
    std.testing.refAllDecls(@This());
}
