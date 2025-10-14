const std = @import("std");
const builtin = @import("builtin");
const build_zig_zon = @import("build_zig_zon");

const gcat = @import("gatorcat");

const Config = @import("Config.zig");

pub const Args = struct {
    ifname: [:0]const u8,
    ring_position: ?u16 = null,
    recv_timeout_us: u32 = 10_000,
    eeprom_timeout_us: u32 = 10_000,
    init_timeout_us: u32 = 5_000_000,
    preop_timeout_us: u32 = 10_000_000,
    mbx_timeout_us: u32 = 50_000,
    json: bool = false,
    sim: bool = false,
    eni: bool = false,
    plugin_zenoh_enable: bool = false,
    plugin_zenoh_pdo_input_publisher_key_format: ?[:0]const u8 = "ethercat/maindevice/pdi/subdevices/{{subdevice_index}}/{{subdevice_name}}/{{pdo_direction}}/0x{{pdo_index_hex}}/{{pdo_name}}/0x{{pdo_entry_index_hex}}/0x{{pdo_entry_subindex_hex}}/{{pdo_entry_description}}",
    plugin_zenoh_pdo_output_publisher_key_format: ?[:0]const u8 = "ethercat/maindevice/pdi/subdevices/{{subdevice_index}}/{{subdevice_name}}/{{pdo_direction}}/0x{{pdo_index_hex}}/{{pdo_name}}/0x{{pdo_entry_index_hex}}/0x{{pdo_entry_subindex_hex}}/{{pdo_entry_description}}",
    plugin_zenoh_pdo_output_subscriber_key_format: ?[:0]const u8 = "ethercat/subdevices/{{subdevice_index}}/{{subdevice_name}}/{{pdo_direction}}/0x{{pdo_index_hex}}/{{pdo_name}}/0x{{pdo_entry_index_hex}}/0x{{pdo_entry_subindex_hex}}/{{pdo_entry_description}}",
    pub const descriptions = .{
        .ifname = "Network interface to use for the bus scan.",
        .recv_timeout_us = "Frame receive timeout in microseconds.",
        .eeprom_timeout_us = "SII EEPROM timeout in microseconds.",
        .init_timeout_us = "State transition to INIT timeout in microseconds.",
        .preop_timeout_us = "State transition to PREOP timeout in microseconds.",
        .mbx_timeout_us = "Mailbox timeout in microseconds.",
        .ring_position = "Optionally specify only a single subdevice at this ring position to be scanned.",
        .json = "Export the ENI as JSON instead of ZON.",
        .sim = "Also scan information required for simulation.",
        .eni = "Only output the ethercat network information (ENI) part of the configuration. For use with gatorcat module.",
        .plugin_zenoh_enable = "Output a configuration that enables zenoh communication.",
        .plugin_zenoh_pdo_input_publisher_key_format = "Format string used to contruct zenoh publisher key expressions for input pdos.",
        .plugin_zenoh_pdo_output_publisher_key_format = "Format string used to contruct zenoh publisher key expressions for output pdos.",
        .plugin_zenoh_pdo_output_subscriber_key_format = "Format string used to contruct zenoh subscriber key expressions for output pdos.",
    };
};

pub fn scan(allocator: std.mem.Allocator, args: Args) !void {
    var raw_socket = try gcat.nic.RawSocket.init(args.ifname);
    defer raw_socket.deinit();

    var port2 = gcat.Port.init(raw_socket.linkLayer(), .{});
    const port = &port2;
    defer port.deinit();

    try port.ping(args.recv_timeout_us);
    std.log.info("ping successful", .{});

    var scanner = gcat.Scanner.init(port, .{ .eeprom_timeout_us = args.eeprom_timeout_us, .mbx_timeout_us = args.mbx_timeout_us, .recv_timeout_us = args.recv_timeout_us });

    const num_subdevices = try scanner.countSubdevices();
    std.log.info("detected {} subdevices", .{num_subdevices});
    try scanner.busInit(args.init_timeout_us, num_subdevices);
    try scanner.assignStationAddresses(num_subdevices);
    std.log.info("assigned station addresses", .{});

    if (args.ring_position) |ring_position| {
        std.log.info("scanning single subdevice at position: {}", .{ring_position});
        const subdevice_eni = try scanner.readSubdeviceConfiguration(allocator, ring_position, args.preop_timeout_us, args.sim);
        defer subdevice_eni.deinit();
        var std_out = std.fs.File.stdout().writer(&.{});
        const writer = &std_out.interface;

        if (args.json) {
            try std.json.Stringify.value(subdevice_eni.value, .{}, writer);
            try writer.writeByte('\n');
        } else {
            try std.zon.stringify.serialize(subdevice_eni.value, .{ .emit_default_optional_fields = false }, writer);
            try writer.writeByte('\n');
        }
    } else {
        std.log.info("scanning all subdevices...", .{});
        const eni = try scanner.readEni(allocator, args.preop_timeout_us, args.sim);
        defer eni.deinit();
        std.log.info("scan completed", .{});

        const maybe_zenoh: ?gcat.Arena(Config.Plugins.Zenoh) = if (args.plugin_zenoh_enable) try Config.Plugins.Zenoh.initFromENI(allocator, eni.value, .{
            .pdo_input_publisher_key_format = args.plugin_zenoh_pdo_input_publisher_key_format,
            .pdo_output_publisher_key_format = args.plugin_zenoh_pdo_output_publisher_key_format,
            .pdo_output_subscriber_key_format = args.plugin_zenoh_pdo_output_subscriber_key_format,
        }) else null;
        defer if (maybe_zenoh) |zenoh| zenoh.deinit();

        const config: Config = .{
            .version = build_zig_zon.version,
            .eni = eni.value,
            .plugins = .{ .zenoh = if (maybe_zenoh) |zenoh| zenoh.value else null },
        };

        var std_out = std.fs.File.stdout().writer(&.{});
        const writer = &std_out.interface;

        if (args.json) {
            if (args.eni) {
                try std.json.Stringify.value(config.eni, .{ .emit_null_optional_fields = false }, writer);
                try writer.writeByte('\n');
            } else {
                try std.json.Stringify.value(config, .{ .emit_null_optional_fields = false }, writer);
                try writer.writeByte('\n');
            }
        } else {
            if (args.eni) {
                try std.zon.stringify.serialize(config.eni, .{ .emit_default_optional_fields = false }, writer);
                try writer.writeByte('\n');
            } else {
                try std.zon.stringify.serialize(config, .{ .emit_default_optional_fields = false }, writer);
                try writer.writeByte('\n');
            }
        }
    }
}
