pub const Terminal = @This();

const std = @import("std");
const builtin = @import("builtin");
const sdl = @import("sdl.zig").sdl;
const types = @import("types.zig");
const Allocator = std.mem.Allocator;
const Widget = @import("widget.zig").Widget;
const Window = @import("window.zig").Window;
const FRect = types.FRect;
const Color = types.Color;
const Event = types.Event;

window: *Window,
font: ?*sdl.TTF_Font,
rect: FRect,
backgroundColor: Color,
lines: std.ArrayList([]const u8),
lineSpace: f32,

const Text = struct {
    allocator: Allocator,
    prefix: []const u8,
    history_lines: std.ArrayList([]const u8),
    current_line: []const u8,

    // fn init(allocator: Allocator) Text {

    // }
};

pub fn init(allocator: Allocator, window: *Window, rect: FRect) !Terminal {
    const scale = window.getDisplayScale();

    var lines = std.ArrayList([]const u8).init(allocator);
    try lines.append("PS C:\\Users\\86176> 123");
    try lines.append("123");
    try lines.append("PS C:\\Users\\86176>");

    const fontPath = comptime switch (builtin.os.tag) {
        .windows => "C:/Windows/Fonts/msyh.ttc",
        .macos => "/System/Library/Fonts/PingFang.ttc",
        else => {
            @panic("unknown os!");
        },
    };

    const font = sdl.TTF_OpenFont(fontPath, 18 * scale);
    if (font == null) {
        std.debug.print("TTF_OpenFont Error: {s}\n", .{sdl.SDL_GetError()});
        // TODO panic
        @panic("font is null!");
    }

    return Terminal{
        .window = window,
        .font = font,
        .rect = .{
            .x = rect.x * scale,
            .y = rect.y * scale,
            .w = rect.w * scale,
            .h = rect.h * scale,
        },
        .backgroundColor = .{
            .r = 24,
            .g = 24,
            .b = 24,
            .a = 255,
        },
        .lines = lines,
        .lineSpace = 2.0,
    };
}

pub fn resize(_: *Terminal) void {
    // const ws = this.window.getSize();
    // this.rect.w = @as(f32, @floatFromInt(ws.w)) * this.oldRatio.w;
    // this.rect.h = @as(f32, @floatFromInt(ws.h)) * this.oldRatio.h;
    // this.rect.x = @as(f32, @floatFromInt(ws.w)) * this.oldRatio.x;
    // this.rect.y = @as(f32, @floatFromInt(ws.h)) * this.oldRatio.y;
    // this.draw();
}

pub fn draw(this: *Terminal) void {
    this.handleType(this.window.event);
    _ = sdl.SDL_SetRenderDrawColor(
        this.window.renderer,
        this.backgroundColor.r,
        this.backgroundColor.g,
        this.backgroundColor.b,
        this.backgroundColor.a,
    );
    _ = sdl.SDL_RenderFillRect(
        this.window.renderer,
        &this.rect,
    );

    const fg = Color{
        .r = 204,
        .g = 204,
        .b = 204,
        .a = 255,
    };
    var fontY = this.rect.x + 1;
    for (this.lines.items, 0..) |text, i| {
        const surface = sdl.TTF_RenderText_Blended_Wrapped(
            this.font,
            text.ptr,
            text.len,
            fg,
            @intFromFloat(this.rect.w),
        );
        const texture = sdl.SDL_CreateTextureFromSurface(
            this.window.renderer,
            surface,
        );
        defer {
            sdl.SDL_DestroyTexture(texture);
            sdl.SDL_DestroySurface(surface);
        }
        const textRect = FRect{
            .x = this.rect.x + 1,
            .y = fontY,
            .w = @floatFromInt(texture.*.w),
            .h = @floatFromInt(texture.*.h),
        };
        _ = sdl.SDL_RenderTexture(this.window.renderer, texture, null, &textRect);

        if (i == this.lines.items.len - 1) {
            this.drawCursor(fontY, textRect.w, textRect.h);
        }

        fontY += textRect.h + this.lineSpace;
    }
}

pub fn asWidget(this: *Terminal) Widget {
    return Widget{
        .resizeFn = @ptrCast(&resize),
        .drawFn = @ptrCast(&draw),
        .self = this,
    };
}

pub fn close(this: *Terminal) void {
    if (this.font != null) {
        sdl.TTF_CloseFont(this.font);
    }
    this.lines.deinit();
}

fn drawCursor(this: *Terminal, fontY: f32, fontW: f32, fontH: f32) void {
    const scale = this.window.getDisplayScale();
    const rect = FRect{ .x = fontW + 10 * scale, .y = fontY, .w = 2 * scale, .h = fontH };
    _ = sdl.SDL_SetRenderDrawColor(this.window.renderer, 204, 204, 204, 255);
    _ = sdl.SDL_RenderFillRect(
        this.window.renderer,
        &rect,
    );
}

fn handleType(this: *Terminal, event: Event) void {
    _ = sdl.SDL_StartTextInput(this.window.window);
    // const inputRect = rect{100, 100, 600, 30};
    // sdl.SDL_SetTe();
    // std.debug.print("handletype : {?}", .{event.type});
    switch (event.type) {
        sdl.SDL_EVENT_TEXT_INPUT => {
            // const text = this.lines.items[this.lines.items.len - 1];
            std.debug.print("输入: {s}", .{event.text.text});
        },
        else => {},
    }
}
