const std = @import("std");
const sdl = @import("../c.zig").sdl;
const types = @import("types.zig");
const Widget = @import("widget.zig").Widget;
const Window = @import("window.zig").Window;
const Color = types.Color;
const FRect = types.FRect;

pub const Terminal = @This();

window: *Window,
rect: FRect,

ratioRect: FRect,

backgroundColor: Color,

pub fn init(window: *Window, rect: FRect) Terminal {
    const ws = window.getSize();
    const rw = rect.w / @as(f32, @floatFromInt(ws.w));
    const rh = rect.h / @as(f32, @floatFromInt(ws.h));
    const rx = rect.x / @as(f32, @floatFromInt(ws.w));
    const ry = rect.h / @as(f32, @floatFromInt(ws.h));

    const ratioRect = FRect{
        .x = rx,
        .y = ry,
        .w = rw,
        .h = rh,
    };
    // TODO
    ratioRect.println();

    return Terminal{
        .window = window,
        .rect = rect,
        .ratioRect = ratioRect,
        .backgroundColor = .{
            .r = 24,
            .g = 24,
            .b = 24,
            .a = 255,
        },
    };
}

pub fn resize(_: *Terminal) void {}

pub fn draw(this: *Terminal) void {
    _ = sdl.SDL_SetRenderDrawColor(
        this.window.renderer,
        this.backgroundColor.r,
        this.backgroundColor.g,
        this.backgroundColor.b,
        this.backgroundColor.a,
    );

    _ = sdl.SDL_RenderFillRect(
        this.window.renderer,
        @ptrCast(&this.rect),
    );

    // std.debug.print("terminal....\n", .{});
}

pub fn asWidget(terminal: *Terminal) Widget {
    return Widget{
        .resizeFn = @ptrCast(&resize),
        .drawFn = @ptrCast(&draw),
        .self = terminal,
    };
}
