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
        const Vec2 origin = [-cast(float) (columns + rows*0.5) * 0.5, -cast(float) rows * 0.5];
        foreach (i; 0 .. rows)
        {
            foreach (j; 0 .. columns)
            {
                const uint id = i*columns + j;
                const Hexagon hex = Hexagon(j, i);
                const Vec2 centerPixel = hex.centerPixel(origin, Vec2(hexagonSize, hexagonSize));
                instancedMesh.instancePositions[id].xy = centerPixel;
                instancedMesh.instanceColors[id].gb = centerPixel;
            }
        }
        uniforms.instance_positions[0 .. NInstances] = instancedMesh.instancePositions[];
        uniforms.instance_colors[0 .. NInstances] = instancedMesh.instanceColors[];
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
