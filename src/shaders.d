import flyweightbyid;
import sokol_gfx;

import hexagrid_shader;
import standard2d_shader;

enum ShaderEnum
{
    hexagrid,
    standard2d,
}
enum shaderDescs = [
    &hexagrid_shader_desc,
    &standard2d_shader_desc,
];

sg_shader makeShader(uint which)
in { assert(which < shaderDescs.length); }
do
{
    return sg_make_shader(shaderDescs[which]());
}
void disposeShader(sg_shader shader)
{
    sg_destroy_shader(shader);
}

alias Shaders = Flyweight!(sg_shader, makeShader, disposeShader, ShaderEnum);
