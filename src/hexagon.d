import mathtypes;
import mesh;
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
enum centerColor = Vec4([1, 1, 1, 1]);
enum cornerColor = Vec4([0, 0, 0, 1]);

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
    auto angle = deg2rad(angles[i]);
    return Vec2([cos(angle), sin(angle)]);
}

Vertex2D[7] singleHexagonMesh(HexagonType type, Vec4 centerColor = centerColor, Vec4 cornerColor = cornerColor)
{
    typeof(return) vertices = [
        { Vec2([0, 0]), color: centerColor },
        { pointForCorner(type, 0), color: cornerColor },
        { pointForCorner(type, 1), color: cornerColor },
        { pointForCorner(type, 2), color: cornerColor },
        { pointForCorner(type, 3), color: cornerColor },
        { pointForCorner(type, 4), color: cornerColor },
        { pointForCorner(type, 5), color: cornerColor },
    ];
    return vertices;
}

uint16_t[6 * 3] singleHexagonIndices()
{
    return hexagonIndices;
}

