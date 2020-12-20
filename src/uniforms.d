import sokol_gfx;

import mathtypes;

struct Uniforms(T, int slot = 0, sg_shader_stage shader_stage = SG_SHADERSTAGE_VS)
{
    T uniforms;
    alias uniforms this;

    void draw()
    {
        sg_apply_uniforms(shader_stage, slot, &uniforms, T.sizeof);
    }
}

private struct _CameraUniform
{
    Mat4 projection_matrix;
}
private struct _StandardUniform
{
    Transform3D transform = Transform3D.identity;
    Vec4 tint_color = 1;
}
private struct _UVTransformUniform
{
    Transform3D transform = Transform3D.identity;
}

alias CameraUniform = Uniforms!(_CameraUniform, 0);
alias StandardUniform = Uniforms!(_StandardUniform, 1);
alias UVTransformUniform = Uniforms!(_UVTransformUniform, 2);

