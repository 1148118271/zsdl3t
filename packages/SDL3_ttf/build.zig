const std = @import("std");

pub const version: std.SemanticVersion = .{ .major = 3, .minor = 2, .patch = 2 };

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const harfbuzz_enabled = b.option(bool, "enable-harfbuzz", "Use HarfBuzz to improve text shaping") orelse true;

    const strip = b.option(bool, "strip", "Strip debug symbols (default: varies)");
    const sanitize_c = b.option(enum { off, trap, full }, "sanitize_c", "Detect C undefined behavior (default: varies)");
    const legacy_sanitize_c_field = @FieldType(std.Build.Module.CreateOptions, "sanitize_c") == ?bool;
    const resolved_sanitize_c = if (sanitize_c) |x| switch (legacy_sanitize_c_field) {
        true => switch (x) {
            .off => false,
            .trap, .full => true,
        },
        false => @as(std.zig.SanitizeC, switch (x) {
            .off => .off,
            .trap => .trap,
            .full => .full,
        }),
    } else null;
    const pic = b.option(bool, "pic", "Produce position-independent code (default: varies)");

    const preferred_linkage = b.option(
        std.builtin.LinkMode,
        "preferred_linkage",
        "Prefer building statically or dynamically linked libraries (default: static)",
    ) orelse .static;

    const sdl_ttf_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .strip = strip,
        .sanitize_c = resolved_sanitize_c,
        .pic = pic,
    });

    const lib = b.addLibrary(.{
        .linkage = preferred_linkage,
        .name = "SDL3_ttf",
        .root_module = sdl_ttf_mod,
        .version = .{
            .major = 0,
            .minor = version.minor,
            .patch = version.patch,
        },
        .use_llvm = null,
    });

    lib.addIncludePath(b.path("include"));
    lib.addIncludePath(b.path("../harfbuzz/include/harfbuzz/"));
    lib.addIncludePath(b.path("src"));
    lib.addCSourceFiles(.{
        .root = b.path("src"),
        .files = srcs,
    });

    if (harfbuzz_enabled) {
        const harfbuzz_dep = b.dependency("harfbuzz", .{
            .target = target,
            .optimize = optimize,
        });
        lib.linkLibrary(harfbuzz_dep.artifact("harfbuzz"));
        lib.root_module.addCMacro("TTF_USE_HARFBUZZ", "1");
    }

    const freetype_dep = b.dependency("freetype", .{
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibrary(freetype_dep.artifact("freetype"));

    const sdl = b.dependency("SDL", .{
        .target = target,
        .optimize = optimize,
        .preferred_linkage = preferred_linkage,
    }).artifact("SDL3");
    lib.linkLibrary(sdl);

    lib.installHeadersDirectory(b.path("include"), "", .{});

    b.installArtifact(lib);
}

const srcs: []const []const u8 = &.{
    "SDL_gpu_textengine.c",
    "SDL_hashtable.c",
    "SDL_hashtable_ttf.c",
    "SDL_renderer_textengine.c",
    "SDL_surface_textengine.c",
    "SDL_ttf.c",
};
