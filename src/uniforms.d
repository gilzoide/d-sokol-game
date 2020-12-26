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
private align(16) struct CameraUniform_
{
    Mat4 projection_matrix = Mat4.identity;
    mixin UniformPadding;
}
private align(16) struct StandardUniform_
{
    Transform3D transform = Transform3D.identity;
    Vec4 tint_color = 1;
    mixin UniformPadding;
}
private align(16) struct UVTransformUniform_
{
    Transform3D transform = Transform3D.identity;
    mixin UniformPadding;
}

alias CameraUniform = Uniforms!(CameraUniform_, 0);
alias StandardUniform = Uniforms!(StandardUniform_, 1);
alias UVTransformUniform = Uniforms!(UVTransformUniform_, 2);

