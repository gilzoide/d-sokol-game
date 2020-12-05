import gfx;
import mathtypes;
import memory;
import std.stdint;
import sokol_gfx;

struct Vertex2D
{
    Vec2 position;
    Vec2 uv;
    Vec4 color = Vec4.ones;

    static immutable sg_vertex_attr_desc[SG_MAX_VERTEX_ATTRIBUTES] attributes = [
        { format: SG_VERTEXFORMAT_FLOAT2 },
        { format: SG_VERTEXFORMAT_FLOAT2 },
        { format: SG_VERTEXFORMAT_FLOAT4 },
    ];
}
alias IndexType = uint16_t;


struct Mesh
{
    Vertex2D[] vertices;
    IndexType[] indices;

    enum Mesh quad = {
        vertices: [
            { [0, 0], [0, 0] },
            { [0, 1], [0, 1] },
            { [1, 0], [1, 0] },
            { [1, 1], [1, 1] },
        ],
        indices: [
            0, 1, 2,
            1, 2, 3,
        ],
    };

    static Mesh anchoredQuad(Vec2 anchor)
    {
        Mesh m = quad;
        foreach (ref v; m.vertices)
        {
            v.position -= anchor;
        }
        return m;
    }
}

struct InstancedMesh(uint NInstances = 1, string _label = "")
{
    Mesh mesh;
    Vec4[NInstances] instancePositions;
    Vec4[NInstances] instanceColors = Vec4.ones;

    sg_buffer vertex_buffer;
    sg_buffer index_buffer;
    sg_image texture_id;

    void initialize()
    {
        BufferDesc vdesc = {
            content: mesh.vertices,
            type: SG_BUFFERTYPE_VERTEXBUFFER,
            usage: SG_USAGE_IMMUTABLE,
            label: _label ~ " vertex",
        };
        vertex_buffer = vdesc.make();

        BufferDesc idesc = {
            content: mesh.indices,
            type: SG_BUFFERTYPE_INDEXBUFFER,
            usage: SG_USAGE_IMMUTABLE,
            label: _label ~ " index",
        };
        index_buffer = idesc.make();
    }

    void draw()
    {
        sg_bindings bindings = {
            vertex_buffers: [vertex_buffer],
            index_buffer: index_buffer,
            fs_images: [texture_id],
        };
        sg_apply_bindings(&bindings);
        sg_draw(0, cast(int) mesh.indices.length, NInstances);
    }
}
