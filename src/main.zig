const std = @import("std");
const ui = @import("./ui.zig");

pub fn main() !void {
    var window: ui.Window = try ui.Window.init("mian", 1000, 800);
    try window.run();
    window.close();
}
