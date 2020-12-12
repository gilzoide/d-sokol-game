import std.stdint;

import sokol_gfx;

import gfx;
import mathtypes;
import memory;
import uniforms;

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
enum SgIndexType = SG_INDEXTYPE_UINT16;


struct Mesh
{
    Vertex2D[] vertices;
    IndexType[] indices;

    static Vertex2D[4] quadVertices = [
        { position: [0, 0], uv: [0, 0] },
        { position: [0, 1], uv: [0, 1] },
        { position: [1, 0], uv: [1, 0] },
        { position: [1, 1], uv: [1, 1] },
    ];
    static IndexType[6] quadIndices = [
        0, 1, 2,
        1, 2, 3,
    ];
    static IndexType[8] quadLinesIndices = [
        0, 1,
        1, 3,
        3, 2,
        2, 0,
    ];

    static Mesh quad()
    {
        Mesh m = {
            vertices: quadVertices,
            indices: quadIndices,
        };
        return m;
    }

    static Mesh quadLines()
    {
        Mesh m = {
            vertices: quadVertices,
            indices: quadLinesIndices,
        };
        return m;
    }

    //static Mesh anchoredQuad(Vec2 anchor)
    //{
        //Mesh m = quad;
        //foreach (ref v; m.vertices)
        //{
            //v.position -= anchor;
        //}
        //return m;
    //}
}

struct InstancedMesh(string _label = "")
{
    Mesh mesh;
    uint numInstances = 1;

    sg_buffer vertex_buffer;
    sg_buffer index_buffer;
    sg_image texture_id;

    void initialize()
    {
        sg_buffer_desc vdesc = {
            size: cast(int) (mesh.vertices.length * Vertex2D.sizeof),
            content: mesh.vertices.ptr,
            type: SG_BUFFERTYPE_VERTEXBUFFER,
            usage: SG_USAGE_IMMUTABLE,
            label: _label ~ " vertex",
        };
        vertex_buffer = sg_make_buffer(&vdesc);

        sg_buffer_desc idesc = {
            size: cast(int) (mesh.indices.length * IndexType.sizeof),
            content: mesh.indices.ptr,
            type: SG_BUFFERTYPE_INDEXBUFFER,
            usage: SG_USAGE_IMMUTABLE,
            label: _label ~ " index",
        };
        index_buffer = sg_make_buffer(&idesc);
    }

    void draw()
    {
        sg_bindings bindings = {
            vertex_buffers: [vertex_buffer],
            index_buffer: index_buffer,
            fs_images: [texture_id],
        };
        sg_apply_bindings(&bindings);
        sg_draw(0, cast(int) mesh.indices.length, numInstances);
    }
}
