import gfx;
import hexagon;
import hexagrid_shader;
import node;
import sokol_gfx;

struct Hexagrid
{
    mixin Node;

    Pipeline pipeline;
    Bindings bindings;

    void initialize()
    {
        auto pipeline_desc = buildPipeline();
        pipeline = sg_make_pipeline(&pipeline_desc);
        BufferDesc vertices = {
            content: HexagonVertex.singleHexagonVertices(HexagonType.pointy),
            type: SG_BUFFERTYPE_VERTEXBUFFER,
            label: "Hexagrid vertices",
        };
        BufferDesc indices = {
            content: HexagonVertex.singleHexagonIndices(),
            type: SG_BUFFERTYPE_INDEXBUFFER,
            label: "Hexagrid indices",
        };
        Bindings bindings = {
            bindings: {
                vertex_buffers: vertices.make(),
                index_buffer: indices.make(),
            }
        };
        this.bindings = bindings;
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
            primitive_type: SG_PRIMITIVETYPE_TRIANGLES,
        };
        return desc;
    }
}
