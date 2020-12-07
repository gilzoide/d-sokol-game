import gfx;
import input;
import mathtypes;
import mesh;
import node;

struct Checkers
{
    mixin Node;

    Pipelines pipeline;
    Standard2dUniforms uniforms;
    InstancedMesh!() quad;

    Transform3D transform = Transform3D.makeScale(Vec2(50)).translated(Vec2(-25, -25));

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
        uniforms.transform = transform.translated(cursorPos);
    }
}
