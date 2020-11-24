import bettercmath.hexagrid2d;
import mathtypes;
import mesh;
import std.stdint;

alias Hexagon = Hex!(Orientation.pointy, int);

enum Vec4 centerColor = Vec4.ones;
enum Vec4 cornerColor = Vec4(0, 0, 0, 1);

enum hexagonIndices = [
    0, 1, 2,
    0, 2, 3,
    0, 3, 4,
    0, 4, 5,
    0, 5, 6,
    0, 6, 1,
];

Vertex2D[7] singleHexagonVertices(float size)
{
    const Vec2[6] corners = Hexagon.corners(size, size);
    typeof(return) vertices = [
        { [0, 0], color: centerColor },
        { corners[0], color: cornerColor },
        { corners[1], color: cornerColor },
        { corners[2], color: cornerColor },
        { corners[3], color: cornerColor },
        { corners[4], color: cornerColor },
        { corners[5], color: cornerColor },
    ];
    return vertices;
}

uint16_t[6 * 3] singleHexagonIndices()
{
    return hexagonIndices;
}

alias HexagonMeshType = Mesh!(7, 6*3, "Hexagon");
HexagonMeshType hexagonMesh(float size)
{
    typeof(return) mesh = {
        vertices: singleHexagonVertices(size),
        indices: singleHexagonIndices(),
    };
    return mesh;
}
