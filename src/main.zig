const std = @import("std");
const builtin = std.builtin;
const assert = std.debug.assert;
const expect = std.testing.expect;

const sokol = @import("sokol");
const app = sokol.app;
const gfx = sokol.gfx;
const C = @import("cstuff.zig").C;
const Triangle = @import("Triangle.zig");

const triangle_pipeline = Triangle.pipeline();
var default_pass: gfx.PassAction = .{};

fn init() callconv(.C) void {
    C.setup_context();
    default_pass.colors[0] = .{
        .action = .CLEAR,
        .val = .{ 0, 0, 0, 1 },
    };
}

fn frame() callconv(.C) void {
    gfx.beginDefaultPass(default_pass, app.width(), app.height());
    gfx.applyPipeline(triangle_pipeline);
    gfx.endPass();
}

fn cleanup() callconv(.C) void {
    gfx.shutdown();
}

fn event(ev: [*c]const sokol.app.Event) callconv(.C) void {

}

fn fail(msg: [*c]const u8) callconv(.C) void {

}

export fn sokol_main() sokol.app.Desc {
    return .{
        .width = 800,
        .height = 600,
        .high_dpi = true,
        .window_title = "Título",

        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .event_cb = event,
        .fail_cb = fail,
    };
}
