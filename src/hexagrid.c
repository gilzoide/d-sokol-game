#include "hexagrid.h"
#include "vertex_types.h"

#include "HandmadeMath.h"
#include <math.h>

#include "hexagrid.glsl.h"

const float angle_index[] = {
    -30.0f * (HMM_PI32 / 180.0f),
    30.0f * (HMM_PI32 / 180.0f),
    90.0f * (HMM_PI32 / 180.0f),
    150.0f * (HMM_PI32 / 180.0f),
    210.0f * (HMM_PI32 / 180.0f),
    270.0f * (HMM_PI32 / 180.0f),
};

static hmm_vec3 hex_point_corner(hmm_vec3 center, float size, int i) {
    float angle_rad = angle_index[i];
    return (hmm_vec3) {
        .X = center.X + size * cos(angle_rad),
        .Y = center.Y + size * sin(angle_rad),
        .Z = center.Z,
    };
}

HexaGrid build_hexagrid(float radius, int columns) {
    hmm_vec3 center = {};
    const hmm_vec3 center_color = { 1, 1, 1 };
    const hmm_vec3 corner_color = { 0, 0, 0 };
    
    const int vertex_buffer_size = 7;
    const int index_buffer_size = 6 * 3;
    
    VertexColor vertices[] = {
        { center, center_color },
        { hex_point_corner(center, radius, 0), corner_color },
        { hex_point_corner(center, radius, 1), corner_color },
        { hex_point_corner(center, radius, 2), corner_color },
        { hex_point_corner(center, radius, 3), corner_color },
        { hex_point_corner(center, radius, 4), corner_color },
        { hex_point_corner(center, radius, 5), corner_color },
    };
    uint16_t indices[] = {
        0, 1, 2,
        0, 2, 3,
        0, 3, 4,
        0, 4, 5,
        0, 5, 6,
        0, 6, 1,
    };

    sg_buffer vertex_buffer = sg_make_buffer(&(sg_buffer_desc) {
        .size = sizeof(vertices),
        .content = vertices,
        .label = "HexaGrid Vertex",
        .usage = SG_USAGE_IMMUTABLE,
        .type = SG_BUFFERTYPE_VERTEXBUFFER,
    });
    sg_buffer index_buffer = sg_make_buffer(&(sg_buffer_desc) {
        .size = sizeof(indices),
        .content = indices,
        .label = "HexaGrid index",
        .usage = SG_USAGE_IMMUTABLE,
        .type = SG_BUFFERTYPE_INDEXBUFFER,
    });
    return (HexaGrid) {
        .vertex_buffer = vertex_buffer,
        .index_buffer = index_buffer,
        .num_elements = index_buffer_size,
    };
}

sg_pipeline build_hexagrid_pipeline() {
    return sg_make_pipeline(&(sg_pipeline_desc) {
        .shader = sg_make_shader(hexagrid_shader_desc()),
        .layout = {
            .attrs = {
                [ATTR_vs_position].format = SG_VERTEXFORMAT_FLOAT3,
                [ATTR_vs_color].format = SG_VERTEXFORMAT_FLOAT3,
            },
        },
        .index_type = SG_INDEXTYPE_UINT16,
        .label = "triangle-pipeline",
        .primitive_type = SG_PRIMITIVETYPE_TRIANGLES,
    });
}
