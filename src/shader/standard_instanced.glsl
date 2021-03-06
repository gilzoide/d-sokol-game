@include uniforms.glsl

@vs vs
@include_block CameraUniform
@include_block StandardInstancedUniform

layout(location=0) in vec3 position;
layout(location=1) in vec2 uv;
layout(location=2) in vec4 color;

out vec4 vs_color;
out vec2 vs_uv;

void main() {
    gl_Position = projection_matrix * transform[gl_InstanceID] * vec4(position, 1);
    vs_color = tint_color[gl_InstanceID] * color;
    vs_uv = uv;
}
@end

@fs fs
in vec4 vs_color;
in vec2 vs_uv;
out vec4 frag_color;

uniform sampler2D tex;

void main() {
    frag_color = texture(tex, vs_uv) * vs_color;
}
@end

#pragma sokol @program standard_instanced vs fs

