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
    Tween!(easeInOutQuad!float) scaleTween = {
        duration: 3,
        looping: true,
        yoyo: true,
    };

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
        Transform3D t = Transform3D.fromRotation(GAME.time).scaled(Vec2(scaleTween.value)) * transform;
        uniforms.transform = t.translated(cursorPos);
    }
}
