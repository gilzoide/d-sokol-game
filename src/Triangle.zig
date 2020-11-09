const C = @import("cstuff.zig").C;
const gfx = @import("sokol").gfx;

pub fn shader() gfx.Shader {
    return gfx.makeShader(C.triangle_shader_desc());
}
pub fn pipeline() gfx.Pipeline {
    const attrs = [_]gfx.VertexAttrDesc{.{
        .format = .FLOAT3,
    }} ++ [_]gfx.VertexAttrDesc{.{}} ** 15;
    return gfx.makePipeline(.{
        .shader = shader(),
        .layout = .{
            .attrs = attrs,
        },
    });
}