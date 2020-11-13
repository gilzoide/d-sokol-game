#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_glue.h"

#include "constants.h"
#include "hexagrid.h"

#include "HandmadeMath.h"
#include "hexagrid.glsl.h"

sg_pass_action pass_action;

HexaGrid hexagrid;
sg_pipeline hexagrid_pipeline;
sg_bindings hexagrid_bindings;
vs_params_t hexagrid_uniforms;

void init() {
    sg_setup(&(sg_desc){
        .context = sapp_sgcontext()
    });

    hexagrid = build_hexagrid(1, 2);
    hexagrid_bindings.vertex_buffers[0] = hexagrid.vertex_buffer;
    hexagrid_bindings.index_buffer = hexagrid.index_buffer;
    hexagrid_pipeline = build_hexagrid_pipeline();

    pass_action = (sg_pass_action) {
        .colors[0] = { .action=SG_ACTION_CLEAR, .val={ 0.0f, 0.0f, 0.0f, 1.0f } }
    };

    hexagrid_uniforms.projection_matrix = HMM_Orthographic(
        -4, 4,
        -3, 3,
        -10, 10
    );
}

void frame() {
    float width = sapp_width(), height = sapp_height();
    sg_begin_default_pass(&pass_action, width, height);
        sg_apply_pipeline(hexagrid_pipeline);
        sg_apply_bindings(&hexagrid_bindings);
        sg_apply_uniforms(SG_SHADERSTAGE_VS, SLOT_vs_params, &hexagrid_uniforms, sizeof(hexagrid_uniforms));

        sg_draw(0, hexagrid.num_elements, 1);
    sg_end_pass();
    sg_commit();
}

void cleanup() {
    sg_destroy_pipeline(hexagrid_pipeline);
    sg_destroy_buffer(hexagrid.vertex_buffer);
    sg_destroy_buffer(hexagrid.index_buffer);
    sg_shutdown();
}

sapp_desc sokol_main(int argc, char **argv) {
    return (sapp_desc){
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        
        .width = INITIAL_WINDOW_WIDTH,
        .height = INITIAL_WINDOW_HEIGHT,
        
        .gl_force_gles2 = true,
        .window_title = WINDOW_TITLE,
    };
}
