import gfx;
import hexagon;
import hexagrid_shader;
import mathtypes;
import mesh;
import node;
import sokol_gfx;
import std.stdint;

import cdefs;

struct Hexagrid(uint columns, uint rows)
{
    private enum NInstances = columns * rows;
    private enum hexagonSize = 0.7;

    mixin Node;
    Pipeline pipeline;
    Uniforms!(vs_params, SLOT_vs_params) uniforms;
    InstancedMesh!(NInstances, HexagonMeshType) instancedMesh;

    void initialize()
    {
        uniforms.projection_matrix = Mat4.orthographic(
            -8, 8,
            -4.5, 4.5,
            -10, 10
        );
        auto pipeline_desc = buildPipeline();
        pipeline.pipeline = sg_make_pipeline(&pipeline_desc);

        instancedMesh.mesh = hexagonMesh(hexagonSize);
        //const Hexagon hexOffset = Hexagon(-rows/2, -columns/2);
        foreach (i; 0 .. rows)
        {
            foreach (j; 0 .. columns)
            {
                const uint id = i*columns + j;
                const Hexagon hex = Hexagon(j - columns/2, i - rows/2);
                const Vec2 centerPixel = hex.centerPixel(Vec2(0, 0), Vec2(hexagonSize, hexagonSize));
                instancedMesh.instancePositions[id].x = centerPixel.x;
                instancedMesh.instancePositions[id].y = centerPixel.y;
            }
        }
        uniforms.instance_positions[0 .. NInstances] = instancedMesh.instancePositions[];
        initializeChildren();
    }

    void draw()
    {
        drawChildren();
    }

    static sg_pipeline_desc buildPipeline()
    {
        sg_pipeline_desc desc = {
            shader: sg_make_shader(hexagrid_shader_desc()),
            layout: {
                attrs: Vertex2D.attributes,
            },
            index_type: SG_INDEXTYPE_UINT16,
            label: "Hexagrid pipeline",
            primitive_type: SG_PRIMITIVETYPE_TRIANGLES,
        };
        return desc;
    }
}
