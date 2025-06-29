pub const Window = @This();

const std = @import("std");
const sdl = @import("sdl.zig").sdl;
const types = @import("types.zig");
const Widget = @import("widget.zig").Widget;
const Color = types.Color;
const Event = types.Event;

pub const Error = error{
    SdlInit,
    TtfInit,
    CreateWindow,
    CreateRenderer,
};

window: ?*sdl.SDL_Window,
renderer: ?*sdl.SDL_Renderer,
event: Event,
running: bool,
backgroundColor: Color,

widgets: std.ArrayList(Widget),

pub fn init(allocator: std.mem.Allocator, title: []const u8, w: i32, h: i32) Window.Error!Window {
    std.debug.print("create......\n", .{});
    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        std.debug.print("SDL_Init Error: {s}\n", .{sdl.SDL_GetError()});
        return Window.Error.SdlInit;
    }
    if (!sdl.TTF_Init()) {
        std.debug.print("SDL_Init Error: {s}\n", .{sdl.SDL_GetError()});
        return Window.Error.TtfInit;
    }
    const win: ?*sdl.SDL_Window = sdl.SDL_CreateWindow(title.ptr, w, h, sdl.SDL_WINDOW_HIGH_PIXEL_DENSITY | sdl.SDL_WINDOW_RESIZABLE);
    if (win == null) {
        std.debug.print("SDL_CreateWindow Error: {s}\n", .{sdl.SDL_GetError()});
        sdl.SDL_Quit();
        return Window.Error.CreateWindow;
    }
    const render: ?*sdl.SDL_Renderer = sdl.SDL_CreateRenderer(win, null);
    if (render == null) {
        std.debug.print("SDL_Renderer Error: {s}\n", .{sdl.SDL_GetError()});
        sdl.SDL_Quit();
        return Window.Error.CreateRenderer;
    }

    return Window{
        .window = win,
        .renderer = render,
        .running = true,
        .event = undefined,
        .backgroundColor = sdl.SDL_Color{
            .r = 255,
            .g = 255,
            .b = 255,
            .a = 255,
        },
        .widgets = std.ArrayList(Widget).init(allocator),
    };
}

pub fn run(this: *Window) !void {
    std.debug.print("run......\n", .{});
    while (this.running) {
        _ = sdl.SDL_WaitEvent(&this.event);
        switch (this.event.type) {
            sdl.SDL_EVENT_QUIT => {
                this.running = false;
                std.debug.print("quit......\n", .{});
            },
            sdl.SDL_EVENT_WINDOW_RESIZED => {
                // for (this.widgets.items) |widget| {
                //     widget.resize();
                // }
                // _ = sdl.SDL_RenderPresent(this.renderer);
            },
            else => {},
        }
        this.renderColor();
        for (this.widgets.items) |widget| {
            widget.draw();
        }
        _ = sdl.SDL_RenderPresent(this.renderer);
        // SDL_Delay(16);
    }
}

pub fn close(this: *Window) void {
    std.debug.print("close......\n", .{});
    sdl.SDL_DestroyRenderer(this.renderer);
    sdl.SDL_DestroyWindow(this.window);
    sdl.SDL_Quit();
    // free widget
    this.widgets.deinit();
}

pub fn getSize(this: *Window) struct { w: i32, h: i32 } {
    var w: i32 = undefined;
    var h: i32 = undefined;
    _ = sdl.SDL_GetWindowSizeInPixelsInPixels(this.window, &w, &h);
    return .{
        .w = w,
        .h = h,
    };
}

pub fn getDisplayScale(this: *Window) f32 {
    return sdl.SDL_GetWindowDisplayScale(this.window);
}

fn renderColor(this: *Window) void {
    _ = sdl.SDL_SetRenderDrawColor(
        this.renderer,
        this.backgroundColor.r,
        this.backgroundColor.g,
        this.backgroundColor.b,
        this.backgroundColor.a,
    );
    _ = sdl.SDL_RenderClear(this.renderer);
}
