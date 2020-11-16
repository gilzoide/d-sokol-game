#if defined(__APPLE__)
    #define SOKOL_METAL
#elif defined(_WIN32) && defined(_MSC_VER)
    #define SOKOL_D3D11
#elif defined(__EMSCRIPTEN__)
    #define SOKOL_GLES3
#else
    #define SOKOL_GLCORE33
#endif

#include <alloca.h>

#define SOKOL_IMPL
#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_time.h"
#include "sokol_audio.h"
#include "sokol_fetch.h"
#include "sokol_glue.h"
