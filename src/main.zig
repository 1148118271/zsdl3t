const std = @import("std");
const ui = @import("./ui.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var window: ui.Window = try ui.Window.init(allocator, "主窗口", 1000, 800);
    var term = ui.Terminal.init(&window, .{ .x = 200, .y = 200, .w = 400, .h = 400 });
    try window.widgets.append(term.asWidget());
    try window.run();
    window.close();
}
