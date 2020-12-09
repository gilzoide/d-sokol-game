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
        duration: 1,
        looping: true,
        yoyo: true,
    };

    enum sizeTweenRemap = ValueRange!Vec2(
        Vec2(0.4, 1),
        Vec2(1, 0.4)
    );

    enum size = 100;
    auto transform = Transform3D.identity
        .scaled(Vec2(size))
        .translated(Vec2(-size*0.5, -size*0.5))
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
        Transform3D t = Transform3D.identity.scaled(scaleTween.value(sizeTweenRemap)) * transform;
        uniforms.transform = t.translated(cursorPos);
    }
}
