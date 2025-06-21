const std = @import("std");

pub const FRect = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,

    pub fn println(this: *const FRect) void {
        std.debug.print(
            "FRect {{ .x = {d}, .y = {d}, .w = {d}, .h = {d} }}\n",
            .{
                this.x,
                this.y,
                this.w,
                this.h,
            },
        );
    }
};

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};
