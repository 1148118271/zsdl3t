const std = @import("std");
const ui = @import("./ui.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var window: ui.Window = try ui.Window.init(allocator, "mian", 1000, 800);
    var term = ui.Terminal.init(window.renderer, &window.event);
    try window.widgets.append(term.asWidget());
    try window.run();
    window.close();
}
