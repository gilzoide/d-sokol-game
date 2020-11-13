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
    
    const int vertex_buffer_size = 7 * columns;
    const int index_buffer_size = 6 * 3 * columns;
    
    VertexColor vertices[vertex_buffer_size];
    uint16_t indices[index_buffer_size];

    for(int i = 0; i < columns; i++) {
        const int voffset = i * 7;
        vertices[voffset + 0] = (VertexColor){ center, center_color };
        vertices[voffset + 1] = (VertexColor){ hex_point_corner(center, radius, 0), corner_color };
        vertices[voffset + 2] = (VertexColor){ hex_point_corner(center, radius, 1), corner_color };
        vertices[voffset + 3] = (VertexColor){ hex_point_corner(center, radius, 2), corner_color };
        vertices[voffset + 4] = (VertexColor){ hex_point_corner(center, radius, 3), corner_color };
        vertices[voffset + 5] = (VertexColor){ hex_point_corner(center, radius, 4), corner_color };
        vertices[voffset + 6] = (VertexColor){ hex_point_corner(center, radius, 5), corner_color };

        const uint16_t ioffset = i * 6 * 3;
        indices[ioffset + 0]  = voffset; indices[ioffset + 1]  = voffset + 1; indices[ioffset + 2]  = voffset + 2;
        indices[ioffset + 3]  = voffset; indices[ioffset + 4]  = voffset + 2; indices[ioffset + 5]  = voffset + 3;
        indices[ioffset + 6]  = voffset; indices[ioffset + 7]  = voffset + 3; indices[ioffset + 8]  = voffset + 4;
        indices[ioffset + 9]  = voffset; indices[ioffset + 10] = voffset + 4; indices[ioffset + 11] = voffset + 5;
        indices[ioffset + 12] = voffset; indices[ioffset + 13] = voffset + 5; indices[ioffset + 14] = voffset + 6;
        indices[ioffset + 15] = voffset; indices[ioffset + 16] = voffset + 6; indices[ioffset + 17] = voffset + 1;

        center.X += 2 * radius;
    }

/*
 *    = {
 *        // center
 *        { center, center_color },
 *
 *        { hex_point_corner(center, radius, 0), corner_color },
 *        { hex_point_corner(center, radius, 1), corner_color },
 *        { hex_point_corner(center, radius, 2), corner_color },
 *        { hex_point_corner(center, radius, 3), corner_color },
 *        { hex_point_corner(center, radius, 4), corner_color },
 *        { hex_point_corner(center, radius, 5), corner_color },
 *    };
 */
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
