pub const C = @cImport({
    @cInclude("sokol_app.h");
    @cInclude("sokol_gfx.h");
    @cInclude("src/glue.h");
    // shaders
    @cInclude("triangle.glsl.h");
});