const std = @import("std");
const window = @import("ui/window.zig");

pub fn main() !void {
    try window.create();
    window.run();
    window.close();
}
