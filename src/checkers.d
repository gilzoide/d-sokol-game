import std.math : PI;

import gfx;
import globals;
import input;
import mathtypes;
import mesh;
import node;
import regular_polygon;
import timer;
import tween;

enum projection_matrix = Mat4.orthographic(
    -8, 8,
    -4.5, 4.5,
    -10, 10
);

struct Arena(uint N)
{
    mixin Node;

    Pipelines pipeline;
    TransformUniform arenaTransform = {{
        transform: Transform3D.identity.full,
    }};
    InstancedMesh!() lines;

    IndexType[N * 2] indices = void;
    Vertex2D[N * 2] vertices = Vertex2D.init;

    void generateIndices()
    {
        for (IndexType i = 0; i < indices.length; i++)
        {
            indices[i] = i;
        }
    }
    void generateVertices()
    {
        enum Vec2[2] lineVertices = [
            Vec2(-1.3, -4),
            Vec2(+1.3, -4),
        ];

        foreach (i; 0 .. N)
        {
            auto rotation = Transform2D.fromRotation(RegularPolygon!N.angleAt(i));
            vertices[i * 2].position = rotation.transform(lineVertices[0]);
            vertices[i * 2 + 1].position = rotation.transform(lineVertices[1]);
        }
    }
    
    Mesh generateLines()
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
        pipeline = Pipelines.standard2dLines;

        lines.mesh = generateLines();
        lines.texture_id = defaultTexture.getId();
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

    enum N = 3;

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
        pipeline = Pipelines.standard2d;

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
