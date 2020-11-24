@vs vs
layout(binding=0) uniform vs_params {
    mat4 projection_matrix;
    vec4[100] instance_positions;
};

layout(location=0) in vec2 position;
layout(location=1) in vec2 uv;
layout(location=2) in vec4 color;

out vec4 vs_color;

void main() {
    gl_Position = projection_matrix * vec4(position + instance_positions[gl_InstanceID].xy, 0, 1);
    vs_color = color;
}
@end

@fs fs
in vec4 vs_color;
out vec4 frag_color;

void main() {
    frag_color = vs_color;
}
@end

#pragma sokol @program hexagrid vs fs
