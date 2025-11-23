const std = @import("std");
const builtin = @import("builtin");

const gcat = @import("gatorcat");

pub const Args = struct {
    ifname: [:0]const u8,
    ring_position: u16,
    recv_timeout_us: u32 = 10_000,
    eeprom_timeout_us: u32 = 10_000,
    format: enum { bin } = .bin,
    out: ?[:0]const u8,
    INIT_timeout_us: u32 = 5_000_000,

    pub const descriptions = .{
        .ifname = "Network interface to use for contacting the subdevice (e.g. \"eth0\").",
        .ring_position = "Subdevice position in the ring to read the EEPROM from.",
        .recv_timeout_us = "Frame receive timeout in microseconds.",
        .eeprom_timeout_us = "SII EEPROM timeout is microseconds.",
        .format = "Output format.",
        .out = "Output file name.",
        .INIT_timeout_us = "INIT state change timeout in microseconds.",
    };
};

pub fn read_eeprom(args: Args) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var raw_socket = try gcat.nic.RawSocket.init(args.ifname);
    defer raw_socket.deinit();

    var port2 = gcat.Port.init(raw_socket.linkLayer(), .{});
    const port = &port2;
    defer port.deinit();
    try port.ping(args.recv_timeout_us);

    var scanner = gcat.Scanner.init(port, .{ .eeprom_timeout_us = args.eeprom_timeout_us, .recv_timeout_us = args.recv_timeout_us });
    var std_out = std.fs.File.stdout().writer(&.{});
    const writer = &std_out.interface;

    const num_subdevices = try scanner.countSubdevices();
    try writer.print("Detected {} subdevices.\n", .{num_subdevices});

    try scanner.busInit(args.INIT_timeout_us, num_subdevices);
    try writer.print("Successfully reached INIT.\n", .{});

    try scanner.assignStationAddresses(num_subdevices);
    try writer.print("Successfully assigned station addresses.\n", .{});

    const station_address = gcat.Subdevice.stationAddressFromRingPos(args.ring_position);
    try writer.print("Reading EEPROM of ring position: {}, station address: {}\n", .{ args.ring_position, station_address });

    const eeprom_info = try gcat.sii.readSubdeviceInfo(
        port,
        station_address,
        args.recv_timeout_us,
        args.eeprom_timeout_us,
    );

    const sii_byte_length: u64 = (@as(u64, eeprom_info.size) + 1) * 1024 / 8;
    try writer.print("Found EEPROM size: {} KiBit ({} bytes).\n", .{ eeprom_info.size + 1, sii_byte_length });

    var buffer: [4]u8 = undefined;
    var sii_stream = gcat.sii.SIIStream.init(
        port,
        station_address,
        0,
        args.recv_timeout_us,
        args.eeprom_timeout_us,
        &buffer,
    );
    const reader = &sii_stream.reader;

    try writer.print("Reading EEPROM...\n", .{});
    const eeprom_content = try allocator.alloc(u8, sii_byte_length);
    defer allocator.free(eeprom_content);
    try reader.readSliceAll(eeprom_content);

    try writer.print("EEPROM Content:\n", .{});
    for (eeprom_content, 0..) |content, i| {
        try writer.print("{x:02}", .{content});
        if (i % 16 == 15 and i % 32 != 0) {
            try writer.writeByte(' ');
        }
        if (i % 32 == 31) {
            try writer.writeByte('\n');
        }
    }
    try writer.writeByte('\n');

    // TODO: file output
    // if (args.out_file_name) |file_name| {
    //     try writer.print("Writing eeprom contents to {s} ...\n", .{file_name});
    //     // const cwd = std.fs.cwd();
    //     // const absolute_path = cwd.writeFile(.{.})
    //     // const path = std.fs.
    //     // try std.fs.cre
    // }
}
