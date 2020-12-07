import gfx;
import hexagon;
import hexagrid_shader;
import keyboard;
import input;
import mathtypes;
import mesh;
import node;
import sokol_gfx;
import texture;

import cdefs;

struct Hexagrid(uint columns, uint rows)
{
    private enum NInstances = columns * rows;

    mixin Node;
    Pipeline pipeline;
    Uniforms!(vs_params, SLOT_vs_params) uniforms;
    InstancedMesh!(NInstances) instancedMesh;
    //InstancedMesh!() quad = {
        //mesh: Mesh.quad,
    //};

    Vec4 defaultColor = [1, 1, 1, 1];
    Vec4 highlightColor = [1, 1, 0, 1];

    void highlightHexagonAt(Vec2i index, bool highlight)
    {
        if (index.x >= 0 && index.x < columns && index.y >= 0 && index.y < rows)
        {
            const uint id = index.y * columns + index.x;
            uniforms.instance_colors[id] = highlight ? highlightColor : defaultColor;
        }
    }

    void initialize()
    {
        //auto tex = checkered2x2Texture;
        //quad.texture_id = tex.getId();
        uniforms.projection_matrix = Mat4.orthographic(
            -8, 8,
            -4.5, 4.5,
            -10, 10
        );
        auto pipeline_desc = buildPipeline();
        pipeline.pipeline = sg_make_pipeline(&pipeline_desc);

        instancedMesh.mesh = hexagonMesh();
        foreach (i; 0 .. rows)
        {
            foreach (j; 0 .. columns)
            {
                const uint id = i*columns + j;
                const Hexagon hex = Hexagon(j, i);
                const Vec2 centerPixel = hexagonLayout.toPixel(hex);
                instancedMesh.instancePositions[id].xy = centerPixel;
                //instancedMesh.instanceColors[id].gb = centerPixel;
            }
        }
        uniforms.instance_positions[0 .. NInstances] = instancedMesh.instancePositions[];
        uniforms.instance_colors[0 .. NInstances] = instancedMesh.instanceColors[];

        //Color white = 255, black = [0, 0, 0, 255];
        //Texture!(4, 4) texture = {
            //pixels: [
                //white, black, white, black,
                //black, white, black, white,
                //white, black, white, black,
                //black, white, black, white,
            //],
            ////filter: SG_FILTER_NEAREST,
        //};
        //instancedMesh.texture_id = checkered2x2Texture.getId();
    }

    //void update(double dt)
    //{
        //quad.instancePositions[0].xy = getMousePos();
    //}

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
