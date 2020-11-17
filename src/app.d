import constants;
import game;
import sokol_app;
import sokol_gfx;
import sokol_glue;
import sokol_time;

extern(C):

__gshared sg_pass_action default_pass_action = {
    colors: [{
        action: SG_ACTION_CLEAR,
        val: clearColor,
    }],
};

void init()
{
    sg_desc desc = {
        context: sapp_sgcontext(),
    };
    sg_setup(&desc);

    stm_setup();
}

void frame()
{
    int width = sapp_width(), height = sapp_height();
    sg_begin_default_pass(&default_pass_action, width, height);
        game.instance.frame();
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

        width: initialWindowWidth,
        height: initialWindowHeight,
        window_title: windowTitle,
    };
    return desc;
}
