const std = @import("std");
const builtin = @import("builtin");

const build_zig_zon = @embedFile("build.zig.zon");

pub fn build(b: *std.Build) void {
    // const git_describe = std.mem.trimRight(u8, b.run(&.{ "git", "describe", "--tags" }), '\n');

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const step_cli = b.default_step;
    const step_test = b.step("test", "Run unit tests.");
    const step_examples = b.step("examples", "Build examples.");
    const step_sim_test = b.step("sim-test", "Run the sim tests.");
    const step_release = b.step("release", "Build the release binaries.");
    const step_docker = b.step("docker", "Build the docker container.");

    step_docker.dependOn(step_test);
    step_docker.dependOn(step_sim_test);

    const step_ci_test = b.step("ci-test", "Run through full CI build and tests. If environment varaible GATORCAT_RELEASE is set, it will attempt to publish docker containers.");
    step_ci_test.dependOn(step_cli);
    step_ci_test.dependOn(step_test);
    step_ci_test.dependOn(step_examples);
    step_ci_test.dependOn(step_sim_test);
    step_ci_test.dependOn(step_release);
    step_ci_test.dependOn(step_docker);

    // gatorcat module
    const module = b.addModule("gatorcat", .{
        .root_source_file = b.path("src/module/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    // depend on the npcap sdk if we are building for windows
    switch (target.result.os.tag) {
        .windows => {
            if (b.lazyDependency("npcap", .{
                .target = target,
                .optimize = optimize,
            })) |npcap| {
                module.addImport("npcap", npcap.module("npcap"));
            }
        },
        else => {},
    }

    // zig build
    _ = buildCli(b, step_cli, target, optimize, module, .default, "gatorcat");

    // zig build release
    const installs = buildRelease(b, step_release) catch @panic("oom");

    // zig build test
    buildTest(b, step_test, target, optimize);

    // zig build examples
    buildExamples(b, step_examples, module, target, optimize);

    // zig build sim-test
    buildSimTest(b, step_sim_test, module, target, optimize);

    // zig build docker
    const run_docker = buildDocker(b, step_docker, installs);
    run_docker.dependOn(step_test);
    run_docker.dependOn(step_sim_test);
}

// returns run step that builds docker
pub fn buildDocker(
    b: *std.Build,
    step: *std.Build.Step,
    installs: std.ArrayList(*std.Build.Step.InstallArtifact),
) *std.Build.Step {
    const docker_builder = b.addExecutable(.{
        .name = "docker-builder",
        .root_source_file = b.path("src/release_docker.zig"),
        .target = b.graph.host,
    });
    docker_builder.root_module.addAnonymousImport("build_zig_zon", .{ .root_source_file = b.path("build.zig.zon") });
    const run = b.addRunArtifact(docker_builder);
    run.has_side_effects = true;
    for (installs.items) |install| {
        run.step.dependOn(&install.step);
    }
    step.dependOn(&run.step);
    return &run.step;
}

pub fn buildSimTest(
    b: *std.Build,
    step: *std.Build.Step,
    gatorcat_module: *std.Build.Module,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    const sim_test = b.addTest(.{
        .root_source_file = b.path("test/sim/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    sim_test.root_module.addImport("gatorcat", gatorcat_module);
    const run_sim_test = b.addRunArtifact(sim_test);
    step.dependOn(&run_sim_test.step);
}

pub fn buildExamples(
    b: *std.Build,
    step: *std.Build.Step,
    gatorcat_module: *std.Build.Module,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) void {

    // example: simple
    const simple_example = b.addExecutable(.{
        .name = "simple",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("doc/examples/simple/main.zig"),
    });
    simple_example.root_module.addImport("gatorcat", gatorcat_module);
    // using addInstallArtifact here so it only installs for the example step
    const example_install = b.addInstallArtifact(simple_example, .{});
    step.dependOn(&example_install.step);
    if (target.result.os.tag == .windows) simple_example.linkLibC();

    // example: simple2
    const simple2_example = b.addExecutable(.{
        .name = "simple2",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("doc/examples/simple2/main.zig"),
    });
    simple2_example.root_module.addImport("gatorcat", gatorcat_module);
    // using addInstallArtifact here so it only installs for the example step
    const simple2_install = b.addInstallArtifact(simple2_example, .{});
    step.dependOn(&simple2_install.step);
    if (target.result.os.tag == .windows) simple2_example.linkLibC();

    // example: simple3
    const simple3_example = b.addExecutable(.{
        .name = "simple3",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("doc/examples/simple3/main.zig"),
    });
    simple3_example.root_module.addImport("gatorcat", gatorcat_module);
    // using addInstallArtifact here so it only installs for the example step
    const simple3_install = b.addInstallArtifact(simple3_example, .{});
    step.dependOn(&simple3_install.step);
    if (target.result.os.tag == .windows) simple3_example.linkLibC();

    // example: simple4
    const simple4_example = b.addExecutable(.{
        .name = "simple4",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("doc/examples/simple4/main.zig"),
    });
    simple4_example.root_module.addImport("gatorcat", gatorcat_module);
    // using addInstallArtifact here so it only installs for the example step
    const simple4_install = b.addInstallArtifact(simple4_example, .{});
    step.dependOn(&simple4_install.step);
    if (target.result.os.tag == .windows) simple4_example.linkLibC();
}

pub fn buildTest(
    b: *std.Build,
    step: *std.Build.Step,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    const root_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/module/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_root_unit_tests = b.addRunArtifact(root_unit_tests);
    step.dependOn(&run_root_unit_tests.step);
}

pub fn buildCli(
    b: *std.Build,
    step: *std.Build.Step,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    gatorcat_module: *std.Build.Module,
    dest_dir: std.Build.Step.InstallArtifact.Options.Dir,
    exe_name: []const u8,
) *std.Build.Step.InstallArtifact {
    const flags_module = b.dependency("flags", .{
        .target = target,
        .optimize = optimize,
    }).module("flags");
    const zbor_module = b.dependency("zbor", .{
        .target = target,
        .optimize = optimize,
    }).module("zbor");
    const zenoh_module = b.dependency("zenoh", .{
        .target = target,
        .optimize = optimize,
    }).module("zenoh");
    const cli_module = b.createModule(.{
        .optimize = optimize,
        .target = target,
        .error_tracing = true,
        .root_source_file = b.path("src/cli/main.zig"),
    });
    cli_module.addImport("gatorcat", gatorcat_module);
    cli_module.addImport("flags", flags_module);
    cli_module.addImport("zenoh", zenoh_module);
    cli_module.addImport("zbor", zbor_module);
    cli_module.addAnonymousImport("build_zig_zon", .{ .root_source_file = b.path("build.zig.zon") });

    const cli = b.addExecutable(.{
        .name = exe_name,
        .root_module = cli_module,
    });

    if (target.result.os.tag == .windows) cli.linkLibC();

    const cli_install = b.addInstallArtifact(cli, .{ .dest_dir = dest_dir });
    step.dependOn(&cli_install.step);
    return cli_install;
}

pub fn buildRelease(
    b: *std.Build,
    step: *std.Build.Step,
) !std.ArrayList(*std.Build.Step.InstallArtifact) {
    const targets = [_]std.Target.Query{
        .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },
        .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .musl },
        .{ .cpu_arch = .x86_64, .os_tag = .windows, .abi = .gnu },
    };

    var installs = std.ArrayList(*std.Build.Step.InstallArtifact).init(b.allocator);

    for (targets) |target| {
        const options: struct {
            target: std.Build.ResolvedTarget,
            optimize: std.builtin.OptimizeMode,
        } = .{
            .target = b.resolveTargetQuery(target),
            .optimize = .ReleaseSafe,
        };
        const gatorcat_module = b.createModule(.{
            .root_source_file = b.path("src/module/root.zig"),
            .target = options.target,
            .optimize = options.optimize,
        });
        // depend on the npcap sdk if we are building for windows
        switch (options.target.result.os.tag) {
            .windows => {
                if (b.lazyDependency("npcap", .{
                    .target = options.target,
                    .optimize = options.optimize,
                })) |npcap| {
                    gatorcat_module.addImport("npcap", npcap.module("npcap"));
                }
            },
            else => {},
        }
        const triple = target.zigTriple(b.allocator) catch @panic("oom");
        try installs.append(
            buildCli(
                b,
                step,
                options.target,
                options.optimize,
                gatorcat_module,
                .{ .override = .{ .custom = "release" } },
                try std.fmt.allocPrint(b.allocator, "gatorcat-{}-{s}", .{ getVersionFromZon(), triple }),
            ),
        );
    }
    return installs;
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
