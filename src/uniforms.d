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

private struct CameraUniform_
{
    Mat4 projection_matrix = Mat4.identity;
}
private struct StandardUniform_
{
    Transform3D transform = Transform3D.identity;
    Vec4 tint_color = 1;
}
private struct UVTransformUniform_
{
    Transform3D transform = Transform3D.identity;
}

alias CameraUniform = Uniforms!(CameraUniform_, 0);
alias StandardUniform = Uniforms!(StandardUniform_, 1);
alias UVTransformUniform = Uniforms!(UVTransformUniform_, 2);

