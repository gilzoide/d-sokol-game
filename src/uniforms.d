import soa;
import sokol_gfx;

import mathtypes;

align(16) struct Uniforms(T, int slot = 0, sg_shader_stage shader_stage = SG_SHADERSTAGE_VS)
{
    T uniforms;
    alias uniforms this;

    mixin UniformPadding;

    void draw()
    {
        sg_apply_uniforms(shader_stage, slot, &this, Uniforms.sizeof);
    }
}

/// Padding for uniform blocks
mixin template UniformPadding()
{
    private alias T = typeof(this);
    static if (T.sizeof % T.alignof > 0)
    {
        pragma(msg, "Adding padding of " ~ (16 - T.sizeof % T.alignof));
        byte[16 - T.sizeof % T.alignof] __pad;
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

alias StandardInstancedUniform_ = SOA!(StandardUniform_, 16);

alias CameraUniform = Uniforms!(CameraUniform_, 0);
alias StandardUniform = Uniforms!(StandardUniform_, 1);
alias StandardInstancedUniform = Uniforms!(StandardInstancedUniform_, 1);
alias UVTransformUniform = Uniforms!(UVTransformUniform_, 2);
