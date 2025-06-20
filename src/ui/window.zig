const std = @import("std");
const sdl = @import("../c.zig").sdl;

pub const Window = @This();

pub const Error = error{
    SdlInit,
    CreateWindow,
    CreateRenderer,
};

window: ?*sdl.SDL_Window,
renderer: ?*sdl.SDL_Renderer,
event: sdl.SDL_Event,
running: bool,
backgroundColor: sdl.SDL_Color,

pub fn create(title: []const u8, w: i32, h: i32) Window.Error!Window {
    std.debug.print("create......\n", .{});
    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        std.debug.print("SDL_Init Error: {s}\n", .{sdl.SDL_GetError()});
        return Window.Error.SdlInit;
    }
    const win: ?*sdl.SDL_Window = sdl.SDL_CreateWindow(title.ptr, w, h, sdl.SDL_WINDOW_RESIZABLE);
    if (win == null) {
        std.debug.print("SDL_CreateWindow Error: {s}\n", .{sdl.SDL_GetError()});
        sdl.SDL_Quit();
        return Window.Error.CreateWindow;
    }
    const render: ?*sdl.SDL_Renderer = sdl.SDL_CreateRenderer(win, null);
    if (render == null) {
        sdl.SDL_Quit();
        return Window.Error.CreateRenderer;
    }
    return Window{
        .window = win,
        .renderer = render,
        .running = true,
        .event = undefined,
        .backgroundColor = sdl.SDL_Color{
            .r = 0,
            .g = 0,
            .b = 0,
            .a = 255,
        },
    };
}

pub fn run(window: *Window) !void {
    std.debug.print("run......\n", .{});
    while (window.running) {
        _ = sdl.SDL_WaitEvent(&window.event);
        switch (window.event.type) {
            sdl.SDL_EVENT_QUIT => {
                window.running = false;
                std.debug.print("quit......\n", .{});
                break;
            },
            sdl.SDL_EVENT_WINDOW_RESIZED => {},
            else => {},
        }
        // SDL_Delay(16);
    }
}

pub fn close(window: *Window) void {
    std.debug.print("close......\n", .{});
    sdl.SDL_DestroyRenderer(window.renderer);
    sdl.SDL_DestroyWindow(window.window);
    sdl.SDL_Quit();
}
