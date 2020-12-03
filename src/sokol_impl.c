#ifdef __EMSCRIPTEN__
    #define SOKOL_GLES3
#else
    #define SOKOL_GLCORE33
#endif

#include <alloca.h>

#include "glad.h"

#define SOKOL_IMPL
/*#include "sokol_app.h"*/
/*#include "sokol_args.h"*/
/*#include "sokol_audio.h"*/
/*#include "sokol_fetch.h"*/
#include "sokol_gfx.h"
/*#include "sokol_glue.h"*/
/*#include "sokol_time.h"*/
