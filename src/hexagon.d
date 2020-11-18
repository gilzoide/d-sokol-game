import mathtypes;
import std.stdint;
import std.math;

// Reference: http://www.redblobgames.com/grids/hexagons/

enum HexagonType
{
    pointy,
    flat,
}

enum pointyAngles = [30f, 90f, 150f, 210f, 270f, 330f];
enum flatAngles = [0f, 60f, 120f, 180f, 240f, 300f];
enum centerColor = Vec4(1, 1, 1, 1);
enum cornerColor = Vec4(0, 0, 0, 1);

private enum hexagonIndices = [
    0, 1, 2,
    0, 2, 3,
    0, 3, 4,
    0, 4, 5,
    0, 5, 6,
    0, 6, 1,
];

Vec2 pointForCorner(HexagonType type, int i)
in (i >= 0 && i <= 6, "Hexagon corner index out of range")
{
    float[6] angles = type == HexagonType.pointy ? pointyAngles : flatAngles;
    auto angle = angles[i];
    return Vec2(cos(angle), sin(angle));
}

struct HexagonVertex {
    Vec2 position;
    Vec4 color;

    static HexagonVertex[7] singleHexagonVertices(HexagonType type, Vec4 centerColor = centerColor, Vec4 cornerColor = cornerColor)
    {
        typeof(return) vertices = [
            { Vec2(0, 0), centerColor },
            { pointForCorner(type, 0), centerColor },
            { pointForCorner(type, 1), centerColor },
            { pointForCorner(type, 2), centerColor },
            { pointForCorner(type, 3), centerColor },
            { pointForCorner(type, 4), centerColor },
            { pointForCorner(type, 5), centerColor },
        ];
        return vertices;
    }

    static uint16_t[6 * 3] singleHexagonIndices()
    {
        return hexagonIndices;
    }
}


