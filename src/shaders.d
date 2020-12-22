import flyweightbyid;
import sokol_gfx;

extern(C)
{
    private const(sg_shader_desc*) standard_shader_desc();
    private const(sg_shader_desc*) standard_instanced_shader_desc();
    private const(sg_shader_desc*) standard_uv_transform_shader_desc();
}

auto shaderDescs = [
    &standard_shader_desc,
    &standard_instanced_shader_desc,
    &standard_uv_transform_shader_desc,
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
    "standard_instanced",
    "standard_uv_transform",
];
alias Shader = Flyweight!(sg_shader, makeShader, disposeShader, shaderNames);
