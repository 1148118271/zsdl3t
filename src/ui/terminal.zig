const std = @import("std");
const sdl = @import("../c.zig").sdl;
const types = @import("types.zig");
const Widget = @import("widget.zig").Widget;
const Color = types.Color;
const FRect = types.FRect;

pub const Terminal = @This();

renderer: ?*sdl.SDL_Renderer,
event: ?*sdl.SDL_Event,

rect: FRect,
backgroundColor: Color,

pub fn init(renderer: ?*sdl.SDL_Renderer, event: *sdl.SDL_Event, rect: FRect) Terminal {
    return Terminal{
        .renderer = renderer,
        .event = event,
        .rect = rect,
        .backgroundColor = .{ .r = 24, .g = 24, .b = 24, .a = 255 },
    };
}

pub fn draw(this: *Terminal) void {
    _ = sdl.SDL_SetRenderDrawColor(
        this.renderer,
        this.backgroundColor.r,
        this.backgroundColor.g,
        this.backgroundColor.b,
        this.backgroundColor.a,
    );

    _ = sdl.SDL_RenderFillRect(
        this.renderer,
        @ptrCast(&this.rect),
    );

    // std.debug.print("terminal....\n", .{});
}

pub fn asWidget(terminal: *Terminal) Widget {
    return Widget{
        .drawFn = @ptrCast(&draw),
        .self = terminal,
    };
}
