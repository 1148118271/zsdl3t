const std = @import("std");
const builtin = @import("builtin");
const sdl = @import("../c.zig").sdl;
const types = @import("types.zig");
const Widget = @import("widget.zig").Widget;
const Window = @import("window.zig").Window;
const FRect = types.FRect;
const Color = types.Color;
const Event = types.Event;

pub const Terminal = @This();

window: *Window,
font: ?*sdl.TTF_Font,
rect: FRect,
oldRatio: FRect,
backgroundColor: Color,
lines: std.ArrayList([]const u8),
lineSpace: f32,

pub fn init(allocator: std.mem.Allocator, window: *Window, rect: FRect) !Terminal {
    const ws = window.getSize();
    const rw = rect.w / @as(f32, @floatFromInt(ws.w));
    const rh = rect.h / @as(f32, @floatFromInt(ws.h));
    const rx = rect.x / @as(f32, @floatFromInt(ws.w));
    const ry = rect.y / @as(f32, @floatFromInt(ws.h));

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

    const font = sdl.TTF_OpenFont(fontPath, 18);
    if (font == null) {
        std.debug.print("TTF_OpenFont Error: {s}\n", .{sdl.SDL_GetError()});
        // TODO panic
        @panic("font is null!");
    }
    return Terminal{
        .window = window,
        .font = font,
        .rect = rect,
        .oldRatio = .{ .x = rx, .y = ry, .w = rw, .h = rh },
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

pub fn resize(this: *Terminal) void {
    const ws = this.window.getSize();
    this.rect.w = @as(f32, @floatFromInt(ws.w)) * this.oldRatio.w;
    this.rect.h = @as(f32, @floatFromInt(ws.h)) * this.oldRatio.h;
    this.rect.x = @as(f32, @floatFromInt(ws.w)) * this.oldRatio.x;
    this.rect.y = @as(f32, @floatFromInt(ws.h)) * this.oldRatio.y;
    this.draw();
}

pub fn draw(this: *Terminal) void {
    handleType(this.window.event);
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
            std.debug.print("i == len - 1", .{});
            _ = sdl.SDL_SetRenderDrawColor(this.window.renderer, fg.r, fg.g, fg.b, fg.a);
            _ = sdl.SDL_RenderLine(this.window.renderer, textRect.w + 5, fontY, textRect.w + 5, fontY + textRect.h);
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

fn handleType(event: Event) void {
    switch (event.type) {
        else => {},
    }
}
