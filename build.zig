const std = @import("std");

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
    step_docker.dependOn(step_release);

    const step_ci = b.step("ci-test", "Run through full CI build and tests.");
    step_ci.dependOn(step_cli);
    step_ci.dependOn(step_test);
    step_ci.dependOn(step_examples);
    step_ci.dependOn(step_sim_test);
    step_ci.dependOn(step_release);
    step_ci.dependOn(step_docker);

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
    _ = buildCli(b, step_cli, target, optimize, module, .default);

    // zig build release
    const installs = buildRelease(b, step_release) catch @panic("oom");

    // zig build test
    buildTest(b, step_test, target, optimize);

    // zig build examples
    buildExamples(b, step_examples, module, target, optimize);

    // zig build sim-test
    buildSimTest(b, step_sim_test, module, target, optimize);

    // zig build docker
    buildDocker(b, step_docker, installs);
}

pub fn buildDocker(
    b: *std.Build,
    step: *std.Build.Step,
    installs: std.ArrayList(*std.Build.Step.InstallArtifact),
) void {
    const docker_builder = b.addExecutable(.{
        .name = "docker-builder",
        .root_source_file = b.path("src/ci/release_docker.zig"),
        .target = b.graph.host,
    });
    docker_builder.root_module.addAnonymousImport("build_zig_zon", .{ .root_source_file = b.path("build.zig.zon") });
    const run = b.addRunArtifact(docker_builder);
    for (installs.items) |install| {
        run.step.dependOn(&install.step);
    }
    step.dependOn(&run.step);
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
    const cli = b.addExecutable(.{
        .name = "gatorcat",
        .root_source_file = b.path("src/cli/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    cli.root_module.addImport("gatorcat", gatorcat_module);
    cli.root_module.addImport("flags", flags_module);
    cli.root_module.addImport("zenoh", zenoh_module);
    cli.root_module.addImport("zbor", zbor_module);
    cli.root_module.addAnonymousImport("build_zig_zon", .{ .root_source_file = b.path("build.zig.zon") });
    if (target.result.os.tag == .windows) cli.linkLibC();

    const cli_install = b.addInstallArtifact(cli, .{ .dest_dir = dest_dir });
    step.dependOn(&cli_install.step);
    return cli_install;
}

pub fn buildRelease(
    b: *std.Build,
    step: *std.Build.Step,
) !std.ArrayList(*std.Build.Step.InstallArtifact) {
    const targets: []const std.Target.Query = &.{
        .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },
        // TODO: re-enable windows
        // .{ .cpu_arch = .x86_64, .os_tag = .windows, .abi = .gnu },
        .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .musl },
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
        try installs.append(buildCli(
            b,
            step,
            options.target,
            options.optimize,
            gatorcat_module,
            .{ .override = .{ .custom = target.zigTriple(b.allocator) catch @panic("oom") } },
        ));
    }
    return installs;
}
