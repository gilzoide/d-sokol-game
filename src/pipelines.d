import flyweightbyid;
import sokol_gfx;

import mesh;
import shaders;

struct Pipeline
{
    sg_pipeline pipeline;
    Shaders shader;

    void draw()
    {
        sg_apply_pipeline(pipeline);
    }
}

Pipeline makeStandard()
{
    auto shader = Shaders.standard;
    sg_pipeline_desc desc = {
        shader: shader.object,
        layout: {
            attrs: Vertex.attributes,
        },
        depth_stencil: {
            depth_write_enabled: true,
            depth_compare_func: SG_COMPAREFUNC_LESS,
        },
        index_type: SgIndexType,
        label: "Standard2D pipeline",
        primitive_type: SG_PRIMITIVETYPE_TRIANGLES,
    };
    return Pipeline(sg_make_pipeline(&desc), shader);
}
Pipeline makeStandardLines()
{
    auto shader = Shaders.standard;
    sg_pipeline_desc desc = {
        shader: shader.object,
        layout: {
            attrs: Vertex.attributes,
        },
        depth_stencil: {
            depth_write_enabled: true,
            depth_compare_func: SG_COMPAREFUNC_LESS,
        },
        index_type: SgIndexType,
        label: "Standard2D Lines pipeline",
        primitive_type: SG_PRIMITIVETYPE_LINES,
    };
    return Pipeline(sg_make_pipeline(&desc), shader);
}
auto pipelineDescs = [
    &makeStandard,
    &makeStandardLines,
];

Pipeline makePipeline(uint which)
in { assert(which < pipelineDescs.length); }
do
{
    return pipelineDescs[which]();
}
void disposePipeline(ref Pipeline pipeline)
{
    sg_destroy_pipeline(pipeline.pipeline);
    pipeline = Pipeline.init;
}

enum pipelineNames = [
    "standard",
    "standardLines",
];
alias Pipelines = Flyweight!(Pipeline, makePipeline, disposePipeline, pipelineNames);
