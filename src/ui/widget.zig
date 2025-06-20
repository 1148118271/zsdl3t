pub const Widget = struct {
    drawFn: *const fn (*anyopaque) void,
    self: *anyopaque,

    pub fn draw(w: *const Widget) void {
        w.drawFn(w.self);
    }
};
