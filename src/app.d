import sokol_app;
import sokol_gfx;
import sokol_glue;

extern(C) sapp_desc sokol_main(int argc, char **argv) {
    sapp_desc desc = {
        window_title: "olars",
    };
    return desc;
}
