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

test {
    _ = zenoh_plugin;
}
