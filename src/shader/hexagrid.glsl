@include ctypes.glsl

@vs vs
uniform vs_params {
    mat4 projection_matrix;
    float num_columns;
    float radius;
};

in vec3 position;
in vec3 color;

out vec3 vs_color;

void main() {
    vec3 pos = position + vec3(sqrt(3) * radius * gl_InstanceID, 0, 0);
    gl_Position = projection_matrix * vec4(pos, 1);
    vs_color = color;
}
@end

@fs fs
in vec3 vs_color;
out vec4 frag_color;

void main() {
    frag_color = vec4(vs_color, 1.0);
}
@end

#pragma sokol @program hexagrid vs fs
