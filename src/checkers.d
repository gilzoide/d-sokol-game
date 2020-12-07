import gfx;
import mathtypes;
import mesh;
import node;

struct Checkers
{
    mixin Node;

    Pipelines pipeline;
    Standard2dUniforms uniforms;
    InstancedMesh!() quad;

    void initialize()
    {
        pipeline = Pipelines.standard2d;

        uniforms.projection_matrix = Mat4.orthographic(
            -8, 8,
            -4.5, 4.5,
            -10, 10
        );

        quad.mesh = Mesh.quad;
        quad.texture_id = checkered2x2Texture.getId();
    }
}
