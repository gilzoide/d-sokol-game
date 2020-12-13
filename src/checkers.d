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

struct Arena
{
    mixin Node;

    Pipelines pipeline;
    Standard2dUniforms uniforms = {{
        projection_matrix: projection_matrix,
        transform: Transform3D.identity
            .translate(Vec2(-0.5, -0.5))
            .scale(Vec2(8))
            .full,
    }};
    InstancedMesh!() quad;

    void initialize()
    {
        pipeline = Pipelines.standard2dLines;

        quad.mesh = Mesh.quadLines;
        quad.texture_id = defaultTexture.getId();
    }
}

struct Checkers
{
    mixin Node;

    Pipelines pipeline;
    Standard2dUniforms uniforms = {{
        projection_matrix: projection_matrix,
    }};
    InstancedMesh!() quad;
    Arena arena;

    enum tweenDuration = 0.8;
    Tween!("easeOutQuad", TweenOptions.yoyo | TweenOptions.endCallback) jumpTween = {
        duration: tweenDuration / 2,
        running: false,
        looping: false,
        yoyoLoops: true,
    };

    enum N = 4;

    int currentAngleIndex = 0;
    alias RotateArenaAngles = RegularPolygon!(N * 2);
    auto angleRange = RotateArenaAngles.angleRangeClockwise(0);
    alias RotateSelfAngles = RegularPolygon!(N);
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
            .fullInto(uniforms.transform);
    }
}
