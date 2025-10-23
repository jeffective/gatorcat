//! Configuration file for the gatorcat CLI.
//! Includes ethercat network information and plugin behaviors.
const std = @import("std");
const assert = std.debug.assert;
const Config = @This();

const gcat = @import("gatorcat");
const zenoh = @import("zenoh");
const zenoh_plugin = @import("plugins/zenoh.zig");

/// The version of gatorcat that generated this config file.
/// Currently does nothing.
version: []const u8 = "",
/// EtherCAT Network Information
/// Description of the contents and configuration of the EtherCAT network.
eni: gcat.ENI,
plugins: ?Plugins = null,

pub const Plugins = struct {
    zenoh: ?Zenoh = null,
    pub const Zenoh = zenoh_plugin.Config;
};

pub fn fromSlice(allocator: std.mem.Allocator, slice: [:0]const u8) !gcat.Arena(Config) {
    const arena = try allocator.create(std.heap.ArenaAllocator);
    errdefer allocator.destroy(arena);
    arena.* = .init(allocator);
    errdefer arena.deinit();
    const config = try std.zon.parse.fromSlice(Config, arena.allocator(), slice, null, .{});
    try config.validate();
    return gcat.Arena(Config){ .arena = arena, .value = config };
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
    try config.validate();
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
    try config.validate();
    return gcat.Arena(Config){ .arena = arena, .value = config };
}

pub fn validate(self: Config) !void {
    if (self.plugins) |plugins| {
        if (plugins.zenoh) |this_zenoh| {
            for (this_zenoh.process_data) |pv| {
                const eni_pv = self.eni.lookupProcessVariable(
                    pv.subdevice,
                    pv.direction,
                    pv.pdo_index,
                    pv.index,
                    pv.subindex,
                ) catch |err| switch (err) {
                    error.NotFound => {
                        // TODO: promote to err once https://github.com/ziglang/zig/issues/5738 is done
                        std.log.err("Invalid configuration for process variable: {any}", .{pv});
                        return error.InvalidConfig;
                    },
                };

                for (pv.publishers) |publisher| {
                    if (publisher.scale) |scale| {
                        switch (scale) {
                            .not => if (eni_pv.entry.type != .BOOLEAN) {
                                // TODO: promote to err once https://github.com/ziglang/zig/issues/5738 is done
                                std.log.warn("Unsupported scaling for boolean process data: {any}", .{pv});
                                return error.InvalidConfig;
                            },
                            .exp10, .polynomial => switch (eni_pv.entry.type) {
                                .BOOLEAN,
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
                                    // TODO: promote to err once https://github.com/ziglang/zig/issues/5738 is done
                                    std.log.warn("Unsupported scaling for process data: {any}", .{pv});
                                    return error.InvalidConfig;
                                },
                                else => {},
                            },
                        }
                    }
                }

                for (pv.subscribers) |subscriber| {
                    if (subscriber.scale) |scale| {
                        switch (scale) {
                            .not => if (eni_pv.entry.type != .BOOLEAN) {
                                // TODO: promote to err once https://github.com/ziglang/zig/issues/5738 is done
                                std.log.warn("Unsupported scaling for boolean process data: {any}", .{pv});
                                return error.InvalidConfig;
                            },
                            .exp10, .polynomial => switch (eni_pv.entry.type) {
                                .BOOLEAN,
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
                                    // TODO: promote to err once https://github.com/ziglang/zig/issues/5738 is done
                                    std.log.warn("Unsupported scaling for process data: {any}", .{pv});
                                    return error.InvalidConfig;
                                },
                                else => {},
                            },
                        }
                    }
                }
            }
        }
    }
}

test validate {
    try std.testing.expectError(
        error.InvalidConfig,
        Config.fromSlice(
            std.testing.allocator,
            @embedFile("test_assets/invalid_config.zon"),
        ),
    );
    try std.testing.expectError(
        error.InvalidConfig,
        Config.fromSlice(
            std.testing.allocator,
            @embedFile("test_assets/invalid_config2.zon"),
        ),
    );
    try std.testing.expectError(
        error.InvalidConfig,
        Config.fromSlice(
            std.testing.allocator,
            @embedFile("test_assets/invalid_config3.zon"),
        ),
    );
}

test {
    _ = zenoh_plugin;
}
