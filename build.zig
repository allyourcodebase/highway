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
}
