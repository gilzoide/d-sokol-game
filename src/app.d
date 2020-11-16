import sokol_app;
import sokol_gfx;
import sokol_glue;

import gl3n.math;

struct Game {
    sg_pass_action default_pass_action = {
        colors: [{
            action: SG_ACTION_CLEAR,
            val: [0.2, 0.2, 0.2, 1],
        }],
    };
}

__gshared Game game;

extern(C):

void init()
{
    sg_desc desc = {
        context: sapp_sgcontext(),
    };
    sg_setup(&desc);
}

void frame()
{
    int width = sapp_width(), height = sapp_height();
    sg_begin_default_pass(&game.default_pass_action, width, height);
    sg_end_pass();
    sg_commit();
}

void cleanup()
{
    sg_shutdown();
}

sapp_desc sokol_main(int argc, char **argv)
{
    sapp_desc desc = {
        init_cb: &init,
        frame_cb: &frame,
        cleanup_cb: &cleanup,

        window_title: "olars",
    };
    return desc;
}
