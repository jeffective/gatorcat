const std = @import("std");
const builtin = @import("builtin");

const gcat = @import("gatorcat");

pub const Args = struct {
    ifname: [:0]const u8,
    ring_position: ?u16 = null,
    recv_timeout_us: u32 = 10_000,
    eeprom_timeout_us: u32 = 10_000,
    INIT_timeout_us: u32 = 5_000_000,
    PREOP_timeout_us: u32 = 10_000_000,
    mbx_timeout_us: u32 = 50_000,
    json: bool = false,
    sim: bool = false,
    pub const descriptions = .{
        .ifname = "Network interface to use for the bus scan.",
        .recv_timeout_us = "Frame receive timeout in microseconds.",
        .eeprom_timeout_us = "SII EEPROM timeout in microseconds.",
        .INIT_timeout_us = "state transition to INIT timeout in microseconds.",
        .ring_position = "Optionally specify only a single subdevice at this ring position to be scanned.",
        .json = "Export the ENI as JSON instead of ZON.",
        .sim = "Also scan information required for simulation.",
    };
};

pub fn scan(allocator: std.mem.Allocator, args: Args) !void {
    var raw_socket = try gcat.nic.RawSocket.init(args.ifname);
    defer raw_socket.deinit();

    var port2 = gcat.Port.init(raw_socket.linkLayer(), .{});
    const port = &port2;

    try port.ping(args.recv_timeout_us);

    var scanner = gcat.Scanner.init(port, .{ .eeprom_timeout_us = args.eeprom_timeout_us, .mbx_timeout_us = args.mbx_timeout_us, .recv_timeout_us = args.recv_timeout_us });

    const num_subdevices = try scanner.countSubdevices();
    try scanner.busInit(args.INIT_timeout_us, num_subdevices);
    try scanner.assignStationAddresses(num_subdevices);

    if (args.ring_position) |ring_position| {
        const subdevice_eni = try scanner.readSubdeviceConfiguration(allocator, ring_position, args.PREOP_timeout_us);
        defer subdevice_eni.deinit();
        var std_out = std.io.getStdOut();

        if (args.json) {
            try std.json.stringify(subdevice_eni.value, .{}, std_out.writer());
            try std_out.writer().writeByte('\n');
        } else {
            try std.zon.stringify.serialize(subdevice_eni.value, .{ .emit_default_optional_fields = false }, std_out.writer());
            try std_out.writer().writeByte('\n');
        }
    } else {
        const eni = try scanner.readEni(allocator, args.PREOP_timeout_us);
        defer eni.deinit();

        var std_out = std.io.getStdOut();

        if (args.json) {
            try std.json.stringify(eni.value, .{}, std_out.writer());
            try std_out.writer().writeByte('\n');
        } else {
            try std.zon.stringify.serialize(eni.value, .{ .emit_default_optional_fields = false }, std_out.writer());
            try std_out.writer().writeByte('\n');
        }
    }
}
