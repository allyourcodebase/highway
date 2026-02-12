# Google Highway

This is [Google Highway](https://github.com/google/highway), packaged for
[Zig](https://ziglang.org/).

**Does not yet include `libhwy_contrib`.**

## How to use it

First, update your `build.zig.zon`:

```
zig fetch --save git+https://github.com/allyourcodebase/highway
```

Next, in `build.zig`, declare the dependency and link with the static library:

```zig
const highway_dep = b.dependency("highway", .{
    .target = target,
    .optimize = optimize,
});

// ...
exe.linkLibrary(highway_dep.artifact("hwy"));
```
