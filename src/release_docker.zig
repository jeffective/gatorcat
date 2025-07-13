pub const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const Arg0Expand = std.process.Child.Arg0Expand;
const EnvMap = std.process.EnvMap;
const RunError = std.process.Child.RunError;
const RunResult = std.process.Child.RunResult;
const ChildProcess = std.process.Child;
const assert = std.debug.assert;

const build_zig_zon = @embedFile("build_zig_zon");

/// Customization of std.process.Child.run:
///     - allows writing to stdin
///
/// Spawns a child process, sends bytes to stdin, waits for it, collecting stdout and stderr, and then returns.
/// If it succeeds, the caller owns result.stdout and result.stderr memory.
pub fn runWithStdin(args: struct {
    allocator: mem.Allocator,
    argv: []const []const u8,
    cwd: ?[]const u8 = null,
    cwd_dir: ?fs.Dir = null,
    env_map: ?*const EnvMap = null,
    max_output_bytes: usize = 50 * 1024,
    expand_arg0: Arg0Expand = .no_expand,
    progress_node: std.Progress.Node = std.Progress.Node.none,
    stdin: ?[]const u8 = null,
}) (std.Thread.SpawnError || std.posix.WriteError || RunError)!RunResult {
    var child = ChildProcess.init(args.argv, args.allocator);
    child.stdin_behavior = if (args.stdin) |_| .Pipe else .Ignore;
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;
    child.cwd = args.cwd;
    child.cwd_dir = args.cwd_dir;
    child.env_map = args.env_map;
    child.expand_arg0 = args.expand_arg0;
    child.progress_node = args.progress_node;

    var stdout: std.ArrayListUnmanaged(u8) = .empty;
    errdefer stdout.deinit(args.allocator);
    var stderr: std.ArrayListUnmanaged(u8) = .empty;
    errdefer stderr.deinit(args.allocator);

    try child.spawn();
    errdefer {
        _ = child.kill() catch {};
    }

    // write to stdin of the child
    {
        var writer_thread: ?std.Thread = null;
        defer if (writer_thread) |thread| thread.join();
        if (args.stdin) |stdin| {
            writer_thread = try std.Thread.spawn(.{}, struct {
                fn write_stdin(destination: std.fs.File, source: []const u8) void {
                    defer destination.close();
                    destination.writeAll(source) catch {};
                }
            }.write_stdin, .{ child.stdin.?, stdin });
        }
    }
    child.stdin = null; // avoids double close on child.wait()
    assert(child.stdin == null);

    try child.collectOutput(args.allocator, &stdout, &stderr, args.max_output_bytes);
    return RunResult{
        .stdout = try stdout.toOwnedSlice(args.allocator),
        .stderr = try stderr.toOwnedSlice(args.allocator),
        .term = try child.wait(),
    };
}
pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer _ = gpa.deinit();

    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    const is_release: bool = if (std.process.getEnvVarOwned(allocator, "GATORCAT_RELEASE")) |_| true else |_| false;

    if (is_release) {
        const password = try std.process.getEnvVarOwned(allocator, "GITHUB_TOKEN");

        const docker_login = try std.process.Child.run(.{
            .allocator = allocator,
            .argv = &.{ "docker", "login", "--username", "jeffective", "--password", password, "ghcr.io" },
        });

        switch (docker_login.term) {
            .Exited => |code| {
                std.debug.print("child exited with code {}\nstdout:\n{s}\nstderr:\n{s}\n", .{ code, docker_login.stdout, docker_login.stderr });
                if (code != 0) return error.ChildFailed;
            },
            .Signal => return error.Signal,
            .Stopped => return error.Stopped,
            .Unknown => return error.Unknown,
        }
    }

    const buildx_create = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &.{ "docker", "buildx", "create", "--use" },
    });

    switch (buildx_create.term) {
        .Exited => |code| {
            std.debug.print("child exited with code {}\nstdout:\n{s}\nstderr:\n{s}\n", .{ code, buildx_create.stdout, buildx_create.stderr });
            if (code != 0) return error.ChildFailed;
        },
        .Signal => return error.Signal,
        .Stopped => return error.Stopped,
        .Unknown => return error.Unknown,
    }

    const version_str = try std.fmt.allocPrint(allocator, "{}", .{getVersionFromZon()});
    const version_str_nl = try std.fmt.allocPrint(allocator, "{s}\n", .{version_str});
    const tag = try std.fmt.allocPrint(allocator, "ghcr.io/jeffective/gatorcat:{s}", .{version_str});

    const dockerfile_fmt =
        \\FROM scratch AS build-amd64
        \\COPY zig-out/release/gatorcat-{}-x86_64-linux-musl gatorcat
        \\FROM scratch AS build-arm64
        \\COPY zig-out/release/gatorcat-{}-aarch64-linux-musl gatorcat
        \\ARG TARGETARCH
        \\FROM build-${{TARGETARCH}}
        \\ENTRYPOINT ["/gatorcat"]
    ;

    const dockerfile = try std.fmt.allocPrint(allocator, dockerfile_fmt, .{ getVersionFromZon(), getVersionFromZon() });

    const docker_build_arm64 = try runWithStdin(.{
        .allocator = allocator,
        .argv = &.{
            "docker",
            "buildx",
            "build",
            "--platform",
            "linux/arm64",
            "-t",
            tag,
            "-f-",
            ".",
            "--load",
        },
        .stdin = dockerfile,
    });

    switch (docker_build_arm64.term) {
        .Exited => |code| {
            std.debug.print("child exited with code {}\nstdout:\n{s}\nstderr:\n{s}\n", .{ code, docker_build_arm64.stdout, docker_build_arm64.stderr });
            if (code != 0) return error.ChildFailed;
        },
        .Signal => return error.Signal,
        .Stopped => return error.Stopped,
        .Unknown => return error.Unknown,
    }

    const test_arm64 = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &.{ "docker", "run", "--platform", "linux/arm64", tag, "version" },
    });

    switch (test_arm64.term) {
        .Exited => |code| {
            std.debug.print("child exited with code {}\nstdout:\n{s}\nstderr:\n{s}\n", .{ code, test_arm64.stdout, test_arm64.stderr });
            if (code != 0) return error.ChildFailed;
        },
        .Signal => return error.Signal,
        .Stopped => return error.Stopped,
        .Unknown => return error.Unknown,
    }
    try std.testing.expectEqualSlices(u8, version_str_nl, test_arm64.stdout);

    const docker_build_amd64 = try runWithStdin(.{
        .allocator = allocator,
        .argv = &.{
            "docker",
            "buildx",
            "build",
            "--platform",
            "linux/amd64",
            "-t",
            tag,
            "-f-",
            ".",
            "--load",
        },
        .stdin = dockerfile,
    });

    switch (docker_build_amd64.term) {
        .Exited => |code| {
            std.debug.print("child exited with code {}\nstdout:\n{s}\nstderr:\n{s}\n", .{ code, docker_build_amd64.stdout, docker_build_amd64.stderr });
            if (code != 0) return error.ChildFailed;
        },
        .Signal => return error.Signal,
        .Stopped => return error.Stopped,
        .Unknown => return error.Unknown,
    }

    const test_amd64 = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &.{ "docker", "run", "--platform", "linux/amd64", tag, "version" },
    });

    switch (test_amd64.term) {
        .Exited => |code| {
            std.debug.print("child exited with code {}\nstdout:\n{s}\nstderr:\n{s}\n", .{ code, test_amd64.stdout, test_amd64.stderr });
            if (code != 0) return error.ChildFailed;
        },
        .Signal => return error.Signal,
        .Stopped => return error.Stopped,
        .Unknown => return error.Unknown,
    }
    try std.testing.expectEqualSlices(u8, version_str_nl, test_amd64.stdout);

    if (is_release) {
        const docker_push = try runWithStdin(.{
            .allocator = allocator,
            .argv = &.{
                "docker",
                "buildx",
                "build",
                "--platform",
                "linux/amd64,linux/arm64",
                "-t",
                tag,
                "-f-",
                ".",
                "--push",
            },
            .stdin = dockerfile,
        });

        switch (docker_push.term) {
            .Exited => |code| {
                std.debug.print("child exited with code {}\nstdout:\n{s}\nstderr:\n{s}\n", .{ code, docker_push.stdout, docker_push.stderr });
                if (code != 0) return error.ChildFailed;
            },
            .Signal => return error.Signal,
            .Stopped => return error.Stopped,
            .Unknown => return error.Unknown,
        }
    }
}

fn getVersionFromZon() std.SemanticVersion {
    var buffer: [10 * build_zig_zon.len]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const version = std.zon.parse.fromSlice(
        struct { version: []const u8 },
        fba.allocator(),
        build_zig_zon,
        null,
        .{ .ignore_unknown_fields = true },
    ) catch @panic("Invalid build.zig.zon!");
    const semantic_version = std.SemanticVersion.parse(version.version) catch @panic("Invalid version!");
    return std.SemanticVersion{
        .major = semantic_version.major,
        .minor = semantic_version.minor,
        .patch = semantic_version.patch,
        .build = null, // dont return pointers to stack memory
        .pre = null, // dont return pointers to stack memory
    };
}
