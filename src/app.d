import sokol_app;
import sokol_gfx;
import sokol_glue;

extern(C):

void init()
{
    sg_desc desc = {
        context: sapp_sgcontext(),
    };
    sg_setup(&desc);
}

void cleanup()
{
    sg_shutdown();
}

sapp_desc sokol_main(int argc, char **argv)
{
    sapp_desc desc = {
        init_cb: &init,
        cleanup_cb: &cleanup,

        window_title: "olars",
    };
    return desc;
}
