import flyweightbyid;
import sokol_gfx;

import standard_shader;

auto shaderDescs = [
    &standard_shader_desc,
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
    "standard",
];
alias Shaders = Flyweight!(sg_shader, makeShader, disposeShader, shaderNames);
