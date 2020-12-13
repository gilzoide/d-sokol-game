import bettercmath.cmath : cos, sin;

import mathtypes;
import memory;
import mesh;

struct RegularPolygon(uint N)
{
    import std.math : PI;
    enum angle = 2 * PI / N;

    static float angleAt(const int i)
    {
        return i * angle;
    }

    static FloatRange angleRangeClockwise(const int i)
    {
        return FloatRange(angleAt(i), angleAt(i + 1));
    }
    alias angleRangeCW = angleRangeClockwise;

    static FloatRange angleRangeCounterClockwise(const int i)
    {
        return FloatRange(angleAt(i), angleAt(i - 1));
    }
    alias angleRangeCCW = angleRangeCounterClockwise;

    static Vertex2D[] generateVertices(const float angleOffset)
    {
        auto vertices = Memory.makeArray!Vertex2D(N);
        foreach (i; 0 .. N)
        {
            with (vertices[i])
            {
                const float a = angleAt(i) + angleOffset;
                position.x = cos(a);
                position.y = sin(a);
                uv = position;
                color = Vertex2D.init.color;
            }
        }
        return vertices;
    }
    static IndexType[] generateIndicesLines()
    {
        auto indices = Memory.makeArray!IndexType(N * 2);
        for (IndexType i = 0; i < N - 1; i++)
        {
            auto doubled = i*2;
            indices[doubled] = i;
            indices[doubled + 1] = cast(IndexType)(i + 1);
        }
        indices[$ - 2] = N - 1;
        indices[$ - 1] = 0;
        return indices;
    }

    static Mesh generateMeshLines(const float angleOffset = 0)
    {
        return Mesh(generateVertices(angleOffset), generateIndicesLines());
    }
}
