@include ctypes.glsl

@vs vs
@include uniforms2d.glsl

in vec3 position;
in vec3 color;

out vec3 vs_color;

void main() {
    gl_Position = projection_matrix * vec4(position, 1);
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

#pragma sokol @program triangle vs fs
