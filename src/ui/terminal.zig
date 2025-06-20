const std = @import("std");
const sdl = @import("../c.zig").sdl;
const Widget = @import("widget.zig").Widget;

pub const Terminal = @This();

renderer: ?*sdl.SDL_Renderer,
event: ?*sdl.SDL_Event,

pub fn init(renderer: ?*sdl.SDL_Renderer, event: *sdl.SDL_Event) Terminal {
    return Terminal{
        .renderer = renderer,
        .event = event,
    };
}

pub fn draw(_: *Terminal) void {
    // std.debug.print("terminal....\n", .{});
}

pub fn asWidget(terminal: *Terminal) Widget {
    return Widget{
        .drawFn = @ptrCast(&draw),
        .self = terminal,
    };
}
