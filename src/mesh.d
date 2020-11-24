import gfx;
import mathtypes;
import std.stdint;
import sokol_gfx;

struct Vertex2D
{
    Vec2 position;
    Vec2 uv;
    Vec4 color;

    static immutable sg_vertex_attr_desc[SG_MAX_VERTEX_ATTRIBUTES] attributes = [
        { format: SG_VERTEXFORMAT_FLOAT2 },
        { format: SG_VERTEXFORMAT_FLOAT2 },
        { format: SG_VERTEXFORMAT_FLOAT4 },
    ];
}
alias IndexType = uint16_t;


struct Mesh(uint NVertices, uint NIndices, string _label = "")
{
    Vertex2D[NVertices] vertices;
    IndexType[NIndices] indices;
    enum label = _label;
}

struct InstancedMesh(uint NInstances = 1, MeshType : Mesh!U, U...)
{
    MeshType mesh;
    Vec4[NInstances] instancePositions;

    sg_buffer vertex_buffer;
    sg_buffer index_buffer;

    void initialize()
    {
        BufferDesc vdesc = {
            content: mesh.vertices,
            type: SG_BUFFERTYPE_VERTEXBUFFER,
            usage: SG_USAGE_IMMUTABLE,
            label: MeshType.label ~ " vertex",
        };
        vertex_buffer = vdesc.make();

        BufferDesc idesc = {
            content: mesh.indices,
            type: SG_BUFFERTYPE_INDEXBUFFER,
            usage: SG_USAGE_IMMUTABLE,
            label: MeshType.label ~ " index",
        };
        index_buffer = idesc.make();
    }

    void draw()
    {
        sg_bindings bindings = {
            vertex_buffers: [vertex_buffer],
            index_buffer: index_buffer,
        };
        sg_apply_bindings(&bindings);
        sg_draw(0, mesh.indices.length, NInstances);
    }
}

