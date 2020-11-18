import gfx;
import hexagon;
import hexagrid_shader;
import mathtypes;
import node;
import sokol_gfx;
import std.stdint;

import cdefs;

struct Hexagrid
{

    mixin Node;
    Pipeline pipeline;
    Bindings bindings;
    Uniforms!(vs_params, SLOT_vs_params) uniforms = {{
        num_columns: 1,
        radius: 1,
    }};
    int num_elements;

    void initialize()
    {
        uniforms.projection_matrix = Mat4.Orthographic(
            -4, 4,
            -3, 3,
            -10, 10
        );
        auto pipeline_desc = buildPipeline();
        pipeline.pipeline = sg_make_pipeline(&pipeline_desc);
        auto vertices = HexagonVertex.singleHexagonVertices(HexagonType.pointy);
        BufferDesc vertex_buffer = {
            content: vertices,
            type: SG_BUFFERTYPE_VERTEXBUFFER,
            label: "Hexagrid vertices",
        };
        uint16_t[3 * 6] indices = HexagonVertex.singleHexagonIndices();
        BufferDesc index_buffer = {
            content: indices,
            type: SG_BUFFERTYPE_INDEXBUFFER,
            label: "Hexagrid indices",
        };
        num_elements = indices.length;
        Bindings _bindings = {{
            vertex_buffers: [vertex_buffer.make(), {}],
            index_buffer: index_buffer.make(),
        }};
        bindings = _bindings;
    }

    void draw()
    {
        drawChildren();
        sg_draw(0, num_elements, 2);
    }

    static sg_pipeline_desc buildPipeline()
    {
        sg_pipeline_desc desc = {
            shader: sg_make_shader(hexagrid_shader_desc()),
            layout: {
                attrs: [{
                    format: SG_VERTEXFORMAT_FLOAT2,
                }, {
                    format: SG_VERTEXFORMAT_FLOAT4,
                }],
            },
            index_type: SG_INDEXTYPE_UINT16,
            label: "Hexagrid pipeline",
            primitive_type: SG_PRIMITIVETYPE_TRIANGLES,
        };
        return desc;
    }
}
