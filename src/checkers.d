import bettercmath.valuerange;

import gfx;
import globals;
import input;
import mathtypes;
import mesh;
import node;
import tween;

struct Checkers
{
    mixin Node;

    Pipelines pipeline;
    Standard2dUniforms uniforms;
    InstancedMesh!() quad;
    Tween!(easeInOutCubic!float) scaleTween = {
        duration: 0.4,
        looping: true,
        yoyo: true,
    };

    enum sizeTweenRemap = ValueRange!Vec2(
        Vec2(0.4, 1),
        Vec2(1, 0.4)
    );
    enum shearTweenRemap = ValueRange!Vec2(
        Vec2(0),
        Vec2(0.3, 0)
    );
    enum rotateTweenRemap = FloatRange(0, 2);

    enum size = 100;
    enum transform = Transform3D.identity
        .scale(Vec2(size))
        .translate(Vec2(-size*0.5, -size*0.5))
        ;

    void initialize()
    {
        pipeline = Pipelines.standard2d;

        uniforms.projection_matrix = Mat4.orthographic(
            0, framebufferSize.x,
            framebufferSize.y, 0,
            -10, 10
        );

        quad.mesh = Mesh.quad;
        quad.texture_id = checkered2x2Texture.getId();
    }

    void update(double dt)
    {
        uniforms.transform = transform
            .scale(scaleTween.value(sizeTweenRemap))
            .shear(scaleTween.value(shearTweenRemap))
            .translate(cursorPos);
    }
}
