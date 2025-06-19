const std = @import("std");
const sdl = @import("c.zig").sdl;

pub fn main() !void {
    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        std.debug.print("SDL_Init Error: {s}\n", .{sdl.SDL_GetError()});
        return;
    }
    const window = sdl.SDL_CreateWindow("My Window", 800, 600, sdl.SDL_WINDOW_RESIZABLE);
    if (window == null) {
        std.debug.print("SDL_CreateWindow Error: {s}\n", .{sdl.SDL_GetError()});
        sdl.SDL_Quit();
        return;
    }
    var event: sdl.SDL_Event = undefined;
    var running: bool = true;
    while (running) {
        _ = sdl.SDL_WaitEvent(&event);
        switch (event.type) {
            sdl.SDL_EVENT_QUIT => {
                running = false;
                std.debug.print("quit -------\n", .{});
                break;
            },
            else => {},
        }
        // SDL_Delay(16);
    }

    sdl.SDL_DestroyWindow(window);
    sdl.SDL_Quit();
}
