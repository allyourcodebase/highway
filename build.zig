const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("highway", .{});

    const lib = b.addLibrary(.{
        .name = "hwy",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    lib.linkLibCpp();
    lib.addIncludePath(upstream.path(""));
    lib.addCSourceFiles(.{
        .root = upstream.path("hwy"),
        .files = &.{
            "abort.cc",
            "aligned_allocator.cc",
            "nanobenchmark.cc",
            "per_target.cc",
            "perf_counters.cc",
            "print.cc",
            "profiler.cc",
            "stats.cc",
            "targets.cc",
            "timer.cc",
        },
        .flags = &.{
            "-fmerge-all-constants",
            "-fno-cxx-exceptions",
            "-fno-slp-vectorize",
            "-fno-vectorize",
            "-fno-sanitize=undefined",
            "-fno-sanitize-trap=undefined",
        },
    });
    lib.installHeadersDirectory(upstream.path("hwy"), "hwy", .{ .include_extensions = &.{".h"} });
    b.installArtifact(lib);

    // TODO: Add contrib libs.

    const skeleton_test = b.addExecutable(.{
        .name = "skeleton_test",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    skeleton_test.linkLibrary(lib);
    // We need these paths for `HWY_TARGET_INCLUDE`.
    skeleton_test.addIncludePath(upstream.path(""));
    skeleton_test.addIncludePath(upstream.path("hwy"));
    const skeleton_test_flags = &.{
        "-DHWY_IS_TEST=1",
        "-DHWY_TEST_STANDALONE=1",
    };
    skeleton_test.addCSourceFiles(.{
        .root = upstream.path("hwy"),
        .files = &.{
            "examples/skeleton.cc",
            "examples/skeleton_test.cc",
            "tests/test_util.cc",
        },
        .flags = skeleton_test_flags,
    });
    const skeleton_test_run = b.addRunArtifact(skeleton_test);
    const test_step = b.step("test", "Run skeleton test");
    test_step.dependOn(&skeleton_test_run.step);
}
