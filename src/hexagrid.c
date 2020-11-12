#include "hexagrid.h"
#include "triangle.glsl.h"

#include <math.h>

static float getW(float radius) {
    return 2 * radius;
}
static float getS(float radius) {
    return 1.5 * radius;
}
static float getH(float radius) {
    return sqrt(3) * radius;
}

HexaGrid build_hexagrid(float radius) {
    const float H = getH(radius), W = getW(radius), S = getS(radius);
    const float half_h = H * 0.5;
    const float s_radius = S - radius;

    const float vertices[] = {
        0, half_h, 0,
        s_radius, 0, 0,
        S, 0, 0,
        W, half_h, 0,
        S, H, 0,
        s_radius, H, 0,
        0, half_h, 0,
    };
    sg_buffer buffer = sg_make_buffer(&(sg_buffer_desc) {
        .size = sizeof(vertices),
        .content = vertices,
        .label = "HexaGrid",
        .usage = SG_USAGE_IMMUTABLE,
    });
    return (HexaGrid) {
        .buffer = buffer,
        .num_elements = sizeof(vertices) / 3 / sizeof(vertices[0]),
    };
}

sg_pipeline build_hexagrid_pipeline() {
    return sg_make_pipeline(&(sg_pipeline_desc) {
        .shader = sg_make_shader(triangle_shader_desc()),
        .layout = {
            .attrs = {
                [ATTR_vs_position].format = SG_VERTEXFORMAT_FLOAT3,
            }
        },
        .label = "triangle-pipeline",
        .primitive_type = SG_PRIMITIVETYPE_LINE_STRIP,
    });
}
