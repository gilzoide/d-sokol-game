import mathtypes;
import std.stdint;
import sokol_gfx;

alias indexType = uint16_t;

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

