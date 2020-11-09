#ifdef __APPLE__
    #define SOKOL_METAL
#elif defined(__EMSCRIPTEN__)
    #define SOKOL_GLES3
#else
    #define SOKOL_GLCORE33
#endif

#define SOKOL_IMPL
#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_time.h"
#include "sokol_audio.h"
#include "sokol_fetch.h"
#include "sokol_glue.h"

void setup_context() {
    sg_desc desc = {
        .context = sapp_sgcontext()
    };
    sg_setup(&desc);
}