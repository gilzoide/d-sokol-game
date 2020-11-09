#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_glue.h"

#include "triangle.glsl.h"

sg_pass_action pass_action;
sg_pipeline pipeline;
sg_bindings triangulo;

vs_params_t triangulo_uniforms;

void init() {
    sg_setup(&(sg_desc){
        .context = sapp_sgcontext()
    });

    /* a vertex buffer with 3 vertices */
    float vertices[] = {
        // positions            // // colors
         0.0f,  0.5f, 0.5f,     // 1.0f, 0.0f, 0.0f, 1.0f,
         0.5f, -0.5f, 0.5f,     // 0.0f, 1.0f, 0.0f, 1.0f,
        -0.5f, -0.5f, 0.5f,     // 0.0f, 0.0f, 1.0f, 1.0f
    };
    triangulo_uniforms = (vs_params_t){
        .color0 = { 0.0f, 1.0f, 0.0f, 1.0f },
    };

    triangulo.vertex_buffers[0] = sg_make_buffer(&(sg_buffer_desc){
        .size = sizeof(vertices),
        .content = vertices,
        .label = "triangle-vertices",
    });

    /* create a pipeline object (default render states are fine for triangle) */
    pipeline = sg_make_pipeline(&(sg_pipeline_desc){
        /* create shader from code-generated sg_shader_desc */
        .shader = sg_make_shader(triangle_shader_desc()),
        /* if the vertex layout doesn't have gaps, don't need to provide strides and offsets */
        .layout = {
            .attrs = {
                [ATTR_vs_position].format = SG_VERTEXFORMAT_FLOAT3,
            }
        },
        .label = "triangle-pipeline"
    });


    pass_action = (sg_pass_action) {
        .colors[0] = { .action=SG_ACTION_CLEAR, .val={ 0.0f, 0.0f, 0.0f, 1.0f } }
    };
}

void frame() {
    sg_begin_default_pass(&pass_action, sapp_width(), sapp_height());
        sg_apply_pipeline(pipeline);
        sg_apply_bindings(&triangulo);
        sg_apply_uniforms(SG_SHADERSTAGE_VS, SLOT_vs_params, &triangulo_uniforms, sizeof(triangulo_uniforms));
        sg_draw(0, 3, 1);
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sg_shutdown();
}

sapp_desc sokol_main(int argc, char **argv) {
    return (sapp_desc){
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = 800,
        .height = 600,
        .gl_force_gles2 = true,
        .window_title = "Clear (sokol app)",
    };
}