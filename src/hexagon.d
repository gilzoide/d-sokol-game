import gl3n.linalg;
import std.math;

// Reference: http://www.redblobgames.com/grids/hexagons/

enum HexagonType
{
    pointy,
    flat,
}

enum pointyAngles = [30f, 90f, 150f, 210f, 270f, 330f];
enum flatAngles = [0f, 60f, 120f, 180f, 240f, 300f];

vec2 pointForCorner(HexagonType type, int i)
in (i >= 0 && i <= 6, "Hexagon corner index out of range")
{
    float[6] angles = type == HexagonType.pointy ? pointyAngles : flatAngles;
    auto angle = angles[i];
    return vec2(cos(angle), sin(angle));
}
