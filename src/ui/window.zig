const std = @import("std");
const sdl = @import("../c.zig").sdl;

pub const WindowError = error{
    SdlInit,
    CreateWindow,
};

var window: ?*sdl.SDL_Window = null;
var event: sdl.SDL_Event = undefined;
var running: bool = true;

pub fn create() WindowError!void {
    std.debug.print("create......\n", .{});
    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        std.debug.print("SDL_Init Error: {s}\n", .{sdl.SDL_GetError()});
        return WindowError.SdlInit;
    }
    window = sdl.SDL_CreateWindow("My Window", 800, 600, sdl.SDL_WINDOW_RESIZABLE);
    if (window == null) {
        std.debug.print("SDL_CreateWindow Error: {s}\n", .{sdl.SDL_GetError()});
        sdl.SDL_Quit();
        return WindowError.CreateWindow;
    }
}

pub fn run() void {
    std.debug.print("run......\n", .{});
    while (running) {
        _ = sdl.SDL_WaitEvent(&event);
        switch (event.type) {
            sdl.SDL_EVENT_QUIT => {
                running = false;
                std.debug.print("quit......\n", .{});
                break;
            },
            else => {},
        }
        // SDL_Delay(16);
    }
}

pub fn close() void {
    std.debug.print("close......\n", .{});
    sdl.SDL_DestroyWindow(window);
    sdl.SDL_Quit();
}
