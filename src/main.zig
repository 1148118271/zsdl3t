const std = @import("std");
const ui = @import("./ui.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var window: ui.Window = try ui.Window.init(allocator, "主窗口", 1000, 800);
    var term = try ui.Terminal.init(allocator, &window, .{ .x = 200, .y = 200, .w = 400, .h = 400 });
    defer term.close();
    try window.widgets.append(term.asWidget());
    try window.run();
    window.close();
}
