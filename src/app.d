import constants;
import game;
import hexagrid;
import sokol_app;
import sokol_gfx;
import sokol_glue;
import sokol_time;

import cdefs;

extern(C):

__gshared Game!(maxObjects) GAME = {};

/// Pass action to clear with color
__gshared sg_pass_action default_pass_action = {
    colors: [{
        action: SG_ACTION_CLEAR,
        val: clearColor,
    }],
};

/// Sokol init callback
void d_init()
{
    sg_desc desc = {
        context: sapp_sgcontext(),
    };
    sg_setup(&desc);

    stm_setup();

    GAME.createObject!(Hexagrid!(keyboardGridColumns, keyboardGridRows));
}

/// Sokol frame callback
void d_frame()
{
    const int width = sapp_width(), height = sapp_height();
    sg_begin_default_pass(&default_pass_action, width, height);

    GAME.frame();

    sg_end_pass();
    sg_commit();
}

/// Sokol cleanup callback
void d_cleanup()
{
    sg_shutdown();
}

/// Sokol fail callback
void d_fail(const char* msg)
{
    printf("ERRO: %s\n", msg);
}

/// Sokol main
sapp_desc sokol_main(int argc, char **argv)
{
    sapp_desc desc = {
        init_cb: &d_init,
        frame_cb: &d_frame,
        cleanup_cb: &d_cleanup,
        fail_cb: &d_fail,

        width: initialWindowWidth,
        height: initialWindowHeight,
        window_title: windowTitle,
    };
    return desc;
}
