import flyweightbyid;
import sokol_gfx;

import mesh;
import shaders;

private struct _Pipeline
{
    sg_pipeline pipeline;
    Shader shader;

    invariant
    {
        assert((pipeline == 0 && shader.object == 0) || (pipeline != 0 && shader.object != 0));
    }

    void draw()
    {
        sg_apply_pipeline(pipeline);
    }
}

_Pipeline makeStandard()
{
    auto shader = Shader.standard;
    sg_pipeline_desc desc = {
        shader: shader.object,
        layout: {
            attrs: Vertex.attributes,
        },
        depth_stencil: {
            depth_write_enabled: true,
            depth_compare_func: SG_COMPAREFUNC_LESS,
        },
        rasterizer: {
            cull_mode: SG_CULLMODE_BACK,
        },
        index_type: SgIndexType,
        label: "Standard pipeline",
        primitive_type: SG_PRIMITIVETYPE_TRIANGLES,
    };
    return _Pipeline(sg_make_pipeline(&desc), shader);
}
_Pipeline makeStandardLines()
{
    auto shader = Shader.standard;
    sg_pipeline_desc desc = {
        shader: shader.object,
        layout: {
            attrs: Vertex.attributes,
        },
        depth_stencil: {
            depth_write_enabled: true,
            depth_compare_func: SG_COMPAREFUNC_LESS,
        },
        rasterizer: {
            cull_mode: SG_CULLMODE_BACK,
        },
        index_type: SgIndexType,
        label: "Standard Lines pipeline",
        primitive_type: SG_PRIMITIVETYPE_LINES,
    };
    return _Pipeline(sg_make_pipeline(&desc), shader);
}
_Pipeline makeStandardUVTransform()
{
    auto shader = Shader.standard_uv_transform;
    sg_pipeline_desc desc = {
        shader: shader.object,
        layout: {
            attrs: Vertex.attributes,
        },
        depth_stencil: {
            depth_write_enabled: true,
            depth_compare_func: SG_COMPAREFUNC_LESS,
        },
        rasterizer: {
            cull_mode: SG_CULLMODE_BACK,
        },
        index_type: SgIndexType,
        label: "Standard UV transform pipeline",
        primitive_type: SG_PRIMITIVETYPE_TRIANGLES,
    };
    return _Pipeline(sg_make_pipeline(&desc), shader);
}
auto pipelineDescs = [
    &makeStandard,
    &makeStandardLines,
    &makeStandardUVTransform,
];

_Pipeline makePipeline(uint which)
in { assert(which < pipelineDescs.length); }
do
{
    return pipelineDescs[which]();
}
void disposePipeline(ref _Pipeline pipeline)
{
    sg_destroy_pipeline(pipeline.pipeline);
    pipeline = Pipeline.init;
}

enum pipelineNames = [
    "standard",
    "standardLines",
    "standardUVTransform",
];
alias Pipeline = Flyweight!(_Pipeline, makePipeline, disposePipeline, pipelineNames);
