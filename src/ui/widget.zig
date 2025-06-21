pub const Widget = struct {
    resizeFn: *const fn (*anyopaque) void,
    drawFn: *const fn (*anyopaque) void,
    self: *anyopaque,

    pub fn resize(w: *const Widget) void {
        w.resizeFn(w.self);
    }

    pub fn draw(w: *const Widget) void {
        w.drawFn(w.self);
    }
};
