import std.stdint : uint16_t;

import bettercmath.misc;
import bettercmath.transform;
import bettercmath.vector;
import sokol_gfx;

import gfx;
import mathtypes;
import memory;
import uniforms;

alias UV_t = Vector!(uint16_t, 2);
uint16_t UV(const float amount)
{
    return lerp(uint16_t(0), uint16_t.max, amount);
}

struct Vertex
{
    Vec3 position = 0;
    UV_t uv = 0;
    Color color = 255;

    ref Vertex transform(T : Transform!Args, Args...)(const T t) return
    {
        position[0 .. T.dimension] = t.transform(position[0 .. T.dimension]);
        return this;
    }
    Vertex transformed(T : Transform!Args, Args...)(const T t) const
    {
        typeof(return) v = this;
        return v.transform(t);
    }

    static immutable sg_vertex_attr_desc[SG_MAX_VERTEX_ATTRIBUTES] attributes = [
        { format: SG_VERTEXFORMAT_FLOAT3 },
        { format: SG_VERTEXFORMAT_USHORT2N },
        { format: SG_VERTEXFORMAT_UBYTE4N },
    ];
}
alias IndexType = uint16_t;
enum SgIndexType = SG_INDEXTYPE_UINT16;


struct Mesh
{
    Vertex[] vertices;
    IndexType[] indices;

    __gshared Vertex[4] quadVertices = [
        { position: [0, 0], uv: [UV(0), UV(0)] },
        { position: [0, 1], uv: [UV(0), UV(1)] },
        { position: [1, 0], uv: [UV(1), UV(0)] },
        { position: [1, 1], uv: [UV(1), UV(1)] },
    ];
    __gshared IndexType[6] quadIndices = [
        0, 1, 2,
        1, 3, 2,
    ];
    __gshared IndexType[8] quadLinesIndices = [
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

    void disposeMemory()
    {
        Memory.dispose(vertices);
        Memory.dispose(indices);
    }
}

struct InstancedMesh
{
    Mesh mesh;
    uint numInstances = 1;

    sg_buffer vertex_buffer;
    sg_buffer index_buffer;
    sg_image texture_id;

    void setup(Vertex[] vertices, IndexType[] indices)
    {
        Mesh m = {
            vertices: vertices,
            indices: indices,
        };
        mesh = m;
    }

    void initialize()
    {
        sg_buffer_desc vdesc = {
            size: cast(int) (mesh.vertices.length * Vertex.sizeof),
            content: mesh.vertices.ptr,
            type: SG_BUFFERTYPE_VERTEXBUFFER,
            usage: SG_USAGE_IMMUTABLE,
        };
        vertex_buffer = sg_make_buffer(&vdesc);

        sg_buffer_desc idesc = {
            size: cast(int) (mesh.indices.length * IndexType.sizeof),
            content: mesh.indices.ptr,
            type: SG_BUFFERTYPE_INDEXBUFFER,
            usage: SG_USAGE_IMMUTABLE,
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
