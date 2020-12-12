import bettercmath.valuerange;

import gfx;
import globals;
import input;
import mathtypes;
import mesh;
import node;
import timer;
import tween;

enum projection_matrix = Mat4.orthographic(
    -8, 8,
    -4.5, 4.5,
    -10, 10
);

struct CircleAngles(uint N)
{
    import std.math : PI;
    enum angle = 2 * PI / N;

    static FloatRange rangeClockwise(int i)
    {
        return FloatRange(i * angle, (i + 1) * angle);
    }
    static FloatRange rangeCounterClockwise(int i)
    {
        return FloatRange(i * angle, (i - 1) * angle);
    }
}

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
    Tween!("easeOutQuad", TweenOptions.yoyo | TweenOptions.endCallback) jumpTween = {
        duration: 0.3,
        running: false,
        looping: false,
        yoyoLoops: true,
    };

    int currentAngleIndex = 0;
    alias ArenaAngles = CircleAngles!(4*2);
    auto angleRange = ArenaAngles.rangeClockwise(0);
    alias SelfAngles = CircleAngles!(4);
    auto inverseAngleRange = SelfAngles.rangeCounterClockwise(0);

    enum size = 1;
    enum transform = Transform3D.identity
        .scale(Vec2(size))
        .translate(Vec2(-size*0.5, -size*0.5))
        ;
    enum jumpTranslate = ValueRange!Vec2(
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
        angleRange = ArenaAngles.rangeClockwise(currentAngleIndex);
        inverseAngleRange = SelfAngles.rangeCounterClockwise(currentAngleIndex);
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
            //.scale(scaleTween.value(sizeTweenRemap))
            //.shear(scaleTween.value(shearTweenRemap))
            .fullInto(uniforms.transform);
    }
}
