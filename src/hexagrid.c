#include "hexagrid.h"
#include "triangle.glsl.h"

#include "HandmadeMath.h"
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

static hmm_vec3 hex_point_corner(hmm_vec3 center, float size, int i) {
    float angle_deg = 60 * i - 30;
    float angle_rad = HMM_ToRadians(angle_deg);
    return (hmm_vec3) {
        .X = center.X + size * cos(angle_rad),
        .Y = center.Y + size * sin(angle_rad),
        .Z = center.Z,
    };
}

HexaGrid build_hexagrid(float radius) {
    const hmm_vec3 center = {};
    const hmm_vec3 vertices[] = {
        // center
        center,

        hex_point_corner(center, radius, 0),
        hex_point_corner(center, radius, 1),
        hex_point_corner(center, radius, 2),
        hex_point_corner(center, radius, 3),
        hex_point_corner(center, radius, 4),
        hex_point_corner(center, radius, 5),
    };
    sg_buffer vertex_buffer = sg_make_buffer(&(sg_buffer_desc) {
        .size = sizeof(vertices),
        .content = vertices,
        .label = "HexaGrid Vertex",
        .usage = SG_USAGE_IMMUTABLE,
        .type = SG_BUFFERTYPE_VERTEXBUFFER,
    });
    const uint16_t indexes[] = {
        1, 2, 3,
        1, 3, 4,
        1, 4, 5,
        1, 5, 6,
        1, 6, 7,
        1, 7, 2,
    };
    sg_buffer index_buffer = sg_make_buffer(&(sg_buffer_desc) {
        .size = sizeof(indexes),
        .content = indexes,
        .label = "HexaGrid index",
        .usage = SG_USAGE_IMMUTABLE,
        .type = SG_BUFFERTYPE_INDEXBUFFER,
    });
    return (HexaGrid) {
        .vertex_buffer = vertex_buffer,
        .index_buffer = index_buffer,
        .num_elements = sizeof(indexes) / sizeof(indexes[0]),
    };
}

sg_pipeline build_hexagrid_pipeline() {
    return sg_make_pipeline(&(sg_pipeline_desc) {
        .shader = sg_make_shader(triangle_shader_desc()),
        .layout = {
            .attrs = {
                [ATTR_vs_position].format = SG_VERTEXFORMAT_FLOAT3,
            },
        },
        .index_type = SG_INDEXTYPE_UINT16,
        .label = "triangle-pipeline",
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLES,
    });
}
