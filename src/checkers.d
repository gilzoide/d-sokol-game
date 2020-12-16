import std.math : PI;

import constants;
import gfx;
import globals;
import input;
import mathtypes;
import mesh;
import node;
import regular_polygon;
import timer;
import tween;

//enum projection_matrix = Mat4.orthographic(
    //-8, 8,
    //-4.5, 4.5,
    //-10, 10
//);
enum projection_matrix = Mat4.perspectiveDegrees(
    100,
    windowAspectX,
    1,
    100,
) 
* Transform3D.fromTranslation(Vec3(0, 0, -4)).full;

struct Arena(uint N)
{
    mixin Node;

    TransformUniform arenaTransform = {{
        transform: Transform3D.identity.full,
    }};
    InstancedMesh!() lines;

    IndexType[N * Mesh.quadIndices.length] indices = void;
    Vertex[N * Mesh.quadVertices.length] vertices = void;

    void generateIndices()
    {
        import std.range : chunks, enumerate;
        enum length = Mesh.quadIndices.length;
        foreach (i, c; indices[].chunks(length).enumerate)
        {
            c[] = Mesh.quadIndices[] + cast(IndexType)(Mesh.quadVertices.length * i);
        }
    }
    void generateVertices()
    {
        enum sideSize = 1.2;
        enum radius = 4;
        enum depth = 10;
        enum Color colorFront = [0, 200, 200, 255];
        enum Color colorBack = [51, 51, 51, 0];
        enum Vertex[4] lineVertices = [
            { position: [-sideSize, -radius],         uv: [UV(0), UV(0)], color: colorFront },
            { position: [+sideSize, -radius],         uv: [UV(0), UV(1)], color: colorFront },
            { position: [-sideSize, -radius, -depth], uv: [UV(4), UV(0)], color: colorBack },
            { position: [+sideSize, -radius, -depth], uv: [UV(4), UV(1)], color: colorBack },
        ];

        import std.range : chunks, enumerate;
        foreach (i, c; vertices[].chunks(lineVertices.length).enumerate)
        {
            const auto rotation = Transform3D.fromRotation(RegularPolygon!N.angleAt(cast(int) i));
            foreach (j, ref vertex; c)
            {
                vertex = lineVertices[j].transformed(rotation);
            }
        }
    }
    
    Mesh generateLanes()
    {
        generateVertices();
        generateIndices();
        Mesh mesh = {
            vertices: vertices,
            indices: indices,
        };
        return mesh;
    }

    void initialize()
    {
        lines.mesh = generateLanes();
        lines.texture_id = checkered2x2Texture.getId();
    }
}

struct Checkers
{
    mixin Node;

    Pipelines pipeline;
    CameraUniform camera = {{
        projection_matrix: projection_matrix,
    }};
    TransformUniform quadTransform;
    InstancedMesh!() quad;
    Arena!N arena;

    enum tweenDuration = 0.8;
    Tween!("easeOutQuad", TweenOptions.yoyo | TweenOptions.endCallback) jumpTween = {
        duration: tweenDuration / 2,
        running: false,
        looping: false,
        yoyoLoops: true,
    };

    enum N = 5;

    int currentAngleIndex = 0;
    alias RotateArenaAngles = RegularPolygon!(N * 2);
    auto angleRange = RotateArenaAngles.angleRangeClockwise(0);
    alias RotateSelfAngles = RegularPolygon!(2);
    auto inverseAngleRange = RotateSelfAngles.angleRangeCounterClockwise(0);

    enum size = 1;
    enum transform = Transform3D.identity
        .scale(Vec2(size))
        .translate(Vec2(-size*0.5, -size*0.5))
        ;
    enum jumpTranslate = Vec2Range(
        Vec2(0, -3.5),
        Vec2(0, -2),
    );

    void initialize()
    {
        pipeline = Pipelines.standard;

        quad.mesh = Mesh.quad;
        quad.texture_id = checkered2x2Texture.getId();

        jumpTween.endCallback = &jumpEndCallback;
    }

    void jumpEndCallback()
    {
        currentAngleIndex += 1;
        angleRange = RotateArenaAngles.angleRangeClockwise(currentAngleIndex);
        inverseAngleRange = RotateSelfAngles.angleRangeCounterClockwise(-currentAngleIndex);
        if (jumpTween.isRewinding)
        {
            angleRange.invert();
            inverseAngleRange.invert();
        }
    }

    void update(double dt)
    {
        if (Mouse.left.pressed)
        {
            jumpTween.running = true;
        }
        transform
            .rotate(inverseAngleRange.lerp(jumpTween.position))
            .translate(jumpTween.value(jumpTranslate))
            .rotate(angleRange.lerp(jumpTween.position))
            .fullInto(quadTransform.transform);
    }
}
