import bettercmath.hexagrid2d;
import constants;
import mathtypes;
import memory;
import mesh;
import std.stdint;

enum Layout!(Orientation.pointy) hexagonLayout = {
    origin: [-cast(float) (keyboardGridColumns + 1) * 0.5, cast(float) keyboardGridRows * 0.5],
    size: [hexagonSize, -hexagonSize],
};
alias Hexagon = hexagonLayout.Hexagon;

enum Vec4 centerColor = Vec4.ones;
enum Vec4 cornerColor = Vec4.ones;//(0, 0, 0, 1);

enum hexagonIndices = [
    0, 1, 2,
    0, 2, 3,
    0, 3, 4,
    0, 4, 5,
    0, 5, 6,
    0, 6, 1,
];

Vertex2D[7] singleHexagonVertices()
{
    const Vec2[6] corners = hexagonLayout.corners();
    const Vec4 r = [1, 0, 0, 1];
    const Vec4 g = [0, 1, 0, 1];
    const Vec4 b = [0, 0, 1, 1];
    typeof(return) vertices = [
        { [0, 0],     uv: [0.5, 0.5], color: centerColor },
        { corners[0], uv: [1.0, 1.0], color: r },
        { corners[1], uv: [0.5, 1.0], color: g },
        { corners[2], uv: [0.0, 1.0], color: b },
        { corners[3], uv: [0.0, 0.0], color: r },
        { corners[4], uv: [0.5, 0.0], color: g },
        { corners[5], uv: [1.0, 0.0], color: b },
    ];
    return vertices;
}

uint16_t[6 * 3] singleHexagonIndices()
{
    return hexagonIndices;
}

auto _singleHexagonVertices = singleHexagonVertices;
auto _singleHexagonIndices = singleHexagonIndices;

Mesh hexagonMesh()
{
    typeof(return) mesh = {
        vertices: _singleHexagonVertices,
        indices: _singleHexagonIndices,
    };
    return mesh;
}
