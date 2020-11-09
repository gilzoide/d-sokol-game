@vs vs
uniform vs_params {
    vec4 color0;
};
in vec4 position;
// in vec4 color0;

out vec4 color;

void main() {
    gl_Position = position;
    color = color0;
}
@end

@fs fs
in vec4 color;
out vec4 frag_color;

void main() {
    vec4 c = color * 0.5;
    frag_color = c;
}
@end

#pragma sokol @program triangle vs fs