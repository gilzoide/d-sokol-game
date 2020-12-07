import flyweightbyid;
import sokol_gfx;

import hexagrid_shader;
import standard2d_shader;

auto shaderDescs = [
    &hexagrid_shader_desc,
    &standard2d_shader_desc,
];

sg_shader makeShader(uint which)
in { assert(which < shaderDescs.length); }
do
{
    return sg_make_shader(shaderDescs[which]());
}
void disposeShader(ref sg_shader shader)
{
    sg_destroy_shader(shader);
    shader = 0;
}

enum shaderNames = [
    "hexagrid",
    "standard2d",
];
alias Shaders = Flyweight!(sg_shader, makeShader, disposeShader, shaderNames);
