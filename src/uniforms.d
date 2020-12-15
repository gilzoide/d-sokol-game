import sokol_gfx;

import hexagrid = hexagrid_shader;
import standard2d = standard2d_shader;

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

alias CameraUniform = Uniforms!(standard2d.CameraUniform, standard2d.SLOT_CameraUniform);
alias TransformUniform = Uniforms!(standard2d.TransformUniform, standard2d.SLOT_TransformUniform);

