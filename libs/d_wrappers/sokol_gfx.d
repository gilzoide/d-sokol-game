extern (C):

/*
    sokol_gfx.h -- simple 3D API wrapper

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    In the same place define one of the following to select the rendering
    backend:
        #define SOKOL_GLCORE33
        #define SOKOL_GLES2
        #define SOKOL_GLES3
        #define SOKOL_D3D11
        #define SOKOL_METAL
        #define SOKOL_WGPU
        #define SOKOL_DUMMY_BACKEND

    I.e. for the GL 3.3 Core Profile it should look like this:

    #include ...
    #include ...
    #define SOKOL_IMPL
    #define SOKOL_GLCORE33
    #include "sokol_gfx.h"

    The dummy backend replaces the platform-specific backend code with empty
    stub functions. This is useful for writing tests that need to run on the
    command line.

    Optionally provide the following defines with your own implementations:

    SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
    SOKOL_MALLOC(s)     - your own malloc function (default: malloc(s))
    SOKOL_FREE(p)       - your own free function (default: free(p))
    SOKOL_LOG(msg)      - your own logging function (default: puts(msg))
    SOKOL_UNREACHABLE() - a guard macro for unreachable code (default: assert(false))
    SOKOL_API_DECL      - public function declaration prefix (default: extern)
    SOKOL_API_IMPL      - public function implementation prefix (default: -)
    SOKOL_TRACE_HOOKS   - enable trace hook callbacks (search below for TRACE HOOKS)

    If sokol_gfx.h is compiled as a DLL, define the following before
    including the declaration or implementation:

    SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    If you want to compile without deprecated structs and functions,
    define:

    SOKOL_NO_DEPRECATED

    API usage validation macros:

    SOKOL_VALIDATE_BEGIN()      - begin a validation block (default:_sg_validate_begin())
    SOKOL_VALIDATE(cond, err)   - like assert but for API validation (default: _sg_validate(cond, err))
    SOKOL_VALIDATE_END()        - end a validation block, return true if all checks in block passed (default: bool _sg_validate())

    If you don't want validation errors to be fatal, define SOKOL_VALIDATE_NON_FATAL,
    be aware though that this may spam SOKOL_LOG messages.

    Optionally define the following to force debug checks and validations
    even in release mode:

    SOKOL_DEBUG         - by default this is defined if _DEBUG is defined


    sokol_gfx DOES NOT:
    ===================
    - create a window or the 3D-API context/device, you must do this
      before sokol_gfx is initialized, and pass any required information
      (like 3D device pointers) to the sokol_gfx initialization call

    - present the rendered frame, how this is done exactly usually depends
      on how the window and 3D-API context/device was created

    - provide a unified shader language, instead 3D-API-specific shader
      source-code or shader-bytecode must be provided

    For complete code examples using the various backend 3D-APIs, see:

        https://github.com/floooh/sokol-samples

    For an optional shader-cross-compile solution, see:

        https://github.com/floooh/sokol-tools/blob/master/docs/sokol-shdc.md


    STEP BY STEP
    ============
    --- to initialize sokol_gfx, after creating a window and a 3D-API
        context/device, call:

            sg_setup(const sg_desc*)

    --- create resource objects (at least buffers, shaders and pipelines,
        and optionally images and passes):

            sg_buffer sg_make_buffer(const sg_buffer_desc*)
            sg_image sg_make_image(const sg_image_desc*)
            sg_shader sg_make_shader(const sg_shader_desc*)
            sg_pipeline sg_make_pipeline(const sg_pipeline_desc*)
            sg_pass sg_make_pass(const sg_pass_desc*)

    --- start rendering to the default frame buffer with:

            sg_begin_default_pass(const sg_pass_action* actions, int width, int height)

    --- or start rendering to an offscreen framebuffer with:

            sg_begin_pass(sg_pass pass, const sg_pass_action* actions)

    --- set the pipeline state for the next draw call with:

            sg_apply_pipeline(sg_pipeline pip)

    --- fill an sg_bindings struct with the resource bindings for the next
        draw call (1..N vertex buffers, 0 or 1 index buffer, 0..N image objects
        to use as textures each on the vertex-shader- and fragment-shader-stage
        and then call

            sg_apply_bindings(const sg_bindings* bindings)

        to update the resource bindings

    --- optionally update shader uniform data with:

            sg_apply_uniforms(sg_shader_stage stage, int ub_index, const void* data, int num_bytes)

    --- kick off a draw call with:

            sg_draw(int base_element, int num_elements, int num_instances)

        In the case of no instancing: num_instances should be set to 1 and base_element/num_elements are
        amounts of vertices. In the case of instancing (meaning num_instances > 1), num elements is the
        number of vertices in one instance, while base_element remains unchanged. base_element is the index
        of the first vertex to begin drawing from.

    --- finish the current rendering pass with:

            sg_end_pass()

    --- when done with the current frame, call

            sg_commit()

    --- at the end of your program, shutdown sokol_gfx with:

            sg_shutdown()

    --- if you need to destroy resources before sg_shutdown(), call:

            sg_destroy_buffer(sg_buffer buf)
            sg_destroy_image(sg_image img)
            sg_destroy_shader(sg_shader shd)
            sg_destroy_pipeline(sg_pipeline pip)
            sg_destroy_pass(sg_pass pass)

    --- to set a new viewport rectangle, call

            sg_apply_viewport(int x, int y, int width, int height, bool origin_top_left)

    --- to set a new scissor rect, call:

            sg_apply_scissor_rect(int x, int y, int width, int height, bool origin_top_left)

        both sg_apply_viewport() and sg_apply_scissor_rect() must be called
        inside a rendering pass

        beginning a pass will reset the viewport to the size of the framebuffer used
        in the new pass,

    --- to update (overwrite) the content of buffer and image resources, call:

            sg_update_buffer(sg_buffer buf, const void* ptr, int num_bytes)
            sg_update_image(sg_image img, const sg_image_content* content)

        Buffers and images to be updated must have been created with
        SG_USAGE_DYNAMIC or SG_USAGE_STREAM

        Only one update per frame is allowed for buffer and image resources.
        The rationale is to have a simple countermeasure to avoid the CPU
        scribbling over data the GPU is currently using, or the CPU having to
        wait for the GPU

        Buffer and image updates can be partial, as long as a rendering
        operation only references the valid (updated) data in the
        buffer or image.

    --- to append a chunk of data to a buffer resource, call:

            int sg_append_buffer(sg_buffer buf, const void* ptr, int num_bytes)

        The difference to sg_update_buffer() is that sg_append_buffer()
        can be called multiple times per frame to append new data to the
        buffer piece by piece, optionally interleaved with draw calls referencing
        the previously written data.

        sg_append_buffer() returns a byte offset to the start of the
        written data, this offset can be assigned to
        sg_bindings.vertex_buffer_offsets[n] or
        sg_bindings.index_buffer_offset

        Code example:

        for (...) {
            const void* data = ...;
            const int num_bytes = ...;
            int offset = sg_append_buffer(buf, data, num_bytes);
            bindings.vertex_buffer_offsets[0] = offset;
            sg_apply_pipeline(pip);
            sg_apply_bindings(&bindings);
            sg_apply_uniforms(...);
            sg_draw(...);
        }

        A buffer to be used with sg_append_buffer() must have been created
        with SG_USAGE_DYNAMIC or SG_USAGE_STREAM.

        If the application appends more data to the buffer then fits into
        the buffer, the buffer will go into the "overflow" state for the
        rest of the frame.

        Any draw calls attempting to render an overflown buffer will be
        silently dropped (in debug mode this will also result in a
        validation error).

        You can also check manually if a buffer is in overflow-state by calling

            bool sg_query_buffer_overflow(sg_buffer buf)

        NOTE: Due to restrictions in underlying 3D-APIs, appended chunks of
        data will be 4-byte aligned in the destination buffer. This means
        that there will be gaps in index buffers containing 16-bit indices
        when the number of indices in a call to sg_append_buffer() is
        odd. This isn't a problem when each call to sg_append_buffer()
        is associated with one draw call, but will be problematic when
        a single indexed draw call spans several appended chunks of indices.

    --- to check at runtime for optional features, limits and pixelformat support,
        call:

            sg_features sg_query_features()
            sg_limits sg_query_limits()
            sg_pixelformat_info sg_query_pixelformat(sg_pixel_format fmt)

    --- if you need to call into the underlying 3D-API directly, you must call:

            sg_reset_state_cache()

        ...before calling sokol_gfx functions again

    --- you can inspect the original sg_desc structure handed to sg_setup()
        by calling sg_query_desc(). This will return an sg_desc struct with
        the default values patched in instead of any zero-initialized values

    --- you can inspect various internal resource attributes via:

            sg_buffer_info sg_query_buffer_info(sg_buffer buf)
            sg_image_info sg_query_image_info(sg_image img)
            sg_shader_info sg_query_shader_info(sg_shader shd)
            sg_pipeline_info sg_query_pipeline_info(sg_pipeline pip)
            sg_pass_info sg_query_pass_info(sg_pass pass)

        ...please note that the returned info-structs are tied quite closely
        to sokol_gfx.h internals, and may change more often than other
        public API functions and structs.

    --- you can ask at runtime what backend sokol_gfx.h has been compiled
        for, or whether the GLES3 backend had to fall back to GLES2 with:

            sg_backend sg_query_backend(void)

    --- you can query the default resource creation parameters through the functions

            sg_buffer_desc sg_query_buffer_defaults(const sg_buffer_desc* desc)
            sg_image_desc sg_query_image_defaults(const sg_image_desc* desc)
            sg_shader_desc sg_query_shader_defaults(const sg_shader_desc* desc)
            sg_pipeline_desc sg_query_pipeline_defaults(const sg_pipeline_desc* desc)
            sg_pass_desc sg_query_pass_defaults(const sg_pass_desc* desc)

        These functions take a pointer to a desc structure which may contain
        zero-initialized items for default values. These zero-init values
        will be replaced with their concrete values in the returned desc
        struct.

    ON INITIALIZATION:
    ==================
    When calling sg_setup(), a pointer to an sg_desc struct must be provided
    which contains initialization options. These options provide two types
    of information to sokol-gfx:

        (1) upper bounds and limits needed to allocate various internal
            data structures:
                - the max number of resources of each type that can
                  be alive at the same time, this is used for allocating
                  internal pools
                - the max overall size of uniform data that can be
                  updated per frame, including a worst-case alignment
                  per uniform update (this worst-case alignment is 256 bytes)
                - the max size of all dynamic resource updates (sg_update_buffer,
                  sg_append_buffer and sg_update_image) per frame
                - the max number of entries in the texture sampler cache
                  (how many unique texture sampler can exist at the same time)
            Not all of those limit values are used by all backends, but it is
            good practice to provide them none-the-less.

        (2) 3D-API "context information" (sometimes also called "bindings"):
            sokol_gfx.h doesn't create or initialize 3D API objects which are
            closely related to the presentation layer (this includes the "rendering
            device", the swapchain, and any objects which depend on the
            swapchain). These API objects (or callback functions to obtain
            them, if those objects might change between frames), must
            be provided in a nested sg_context_desc struct inside the
            sg_desc struct. If sokol_gfx.h is used together with
            sokol_app.h, have a look at the sokol_glue.h header which provides
            a convenience function to get a sg_context_desc struct filled out
            with context information provided by sokol_app.h

    See the documention block of the sg_desc struct below for more information.

    BACKEND-SPECIFIC TOPICS:
    ========================
    --- the GL backends need to know about the internal structure of uniform
        blocks, and the texture sampler-name and -type:

            typedef struct {
                float mvp[16] = 0;      // model-view-projection matrix
                float offset0[2] = 0;   // some 2D vectors
                float offset1[2] = 0;
                float offset2[2] = 0;
            } params_t;

            // uniform block structure and texture image definition in sg_shader_desc:
            sg_shader_desc desc = {
                // uniform block description (size and internal structure)
                .vs.uniform_blocks[0] = {
                    .size = sizeof(params_t),
                    .uniforms = {
                        [0] = { .name="mvp", .type=SG_UNIFORMTYPE_MAT4 },
                        [1] = { .name="offset0", .type=SG_UNIFORMTYPE_VEC2 },
                        ...
                    }
                },
                // one texture on the fragment-shader-stage, GLES2/WebGL needs name and image type
                .fs.images[0] = { .name="tex", .type=SG_IMAGETYPE_ARRAY }
                ...
            };

    --- the Metal and D3D11 backends only need to know the size of uniform blocks,
        not their internal member structure, and they only need to know
        the type of a texture sampler, not its name:

            sg_shader_desc desc = {
                .vs.uniform_blocks[0].size = sizeof(params_t),
                .fs.images[0].type = SG_IMAGETYPE_ARRAY,
                ...
            };

    --- when creating a shader object, GLES2/WebGL need to know the vertex
        attribute names as used in the vertex shader:

            sg_shader_desc desc = {
                .attrs = {
                    [0] = { .name="position" },
                    [1] = { .name="color1" }
                }
            };

        The vertex attribute names provided when creating a shader will be
        used later in sg_create_pipeline() for matching the vertex layout
        to vertex shader inputs.

    --- on D3D11 you need to provide a semantic name and semantic index in the
        shader description struct instead (see the D3D11 documentation on
        D3D11_INPUT_ELEMENT_DESC for details):

            sg_shader_desc desc = {
                .attrs = {
                    [0] = { .sem_name="POSITION", .sem_index=0 }
                    [1] = { .sem_name="COLOR", .sem_index=1 }
                }
            };

        The provided semantic information will be used later in sg_create_pipeline()
        to match the vertex layout to vertex shader inputs.

    --- on D3D11, and when passing HLSL source code (instead of byte code) to shader
        creation, you can optionally define the shader model targets on the vertex
        stage:

            sg_shader_Desc desc = {
                .vs = {
                    ...
                    .d3d11_target = "vs_5_0"
                },
                .fs = {
                    ...
                    .d3d11_target = "ps_5_0"
                }
            };

        The default targets are "ps_4_0" and "fs_4_0". Note that those target names
        are only used when compiling shaders from source. They are ignored when
        creating a shader from bytecode.

    --- on Metal, GL 3.3 or GLES3/WebGL2, you don't need to provide an attribute
        name or semantic name, since vertex attributes can be bound by their slot index
        (this is mandatory in Metal, and optional in GL):

            sg_pipeline_desc desc = {
                .layout = {
                    .attrs = {
                        [0] = { .format=SG_VERTEXFORMAT_FLOAT3 },
                        [1] = { .format=SG_VERTEXFORMAT_FLOAT4 }
                    }
                }
            };

    WORKING WITH CONTEXTS
    =====================
    sokol-gfx allows to switch between different rendering contexts and
    associate resource objects with contexts. This is useful to
    create GL applications that render into multiple windows.

    A rendering context keeps track of all resources created while
    the context is active. When the context is destroyed, all resources
    "belonging to the context" are destroyed as well.

    A default context will be created and activated implicitly in
    sg_setup(), and destroyed in sg_shutdown(). So for a typical application
    which *doesn't* use multiple contexts, nothing changes, and calling
    the context functions isn't necessary.

    Three functions have been added to work with contexts:

    --- sg_context sg_setup_context():
        This must be called once after a GL context has been created and
        made active.

    --- void sg_activate_context(sg_context ctx)
        This must be called after making a different GL context active.
        Apart from 3D-API-specific actions, the call to sg_activate_context()
        will internally call sg_reset_state_cache().

    --- void sg_discard_context(sg_context ctx)
        This must be called right before a GL context is destroyed and
        will destroy all resources associated with the context (that
        have been created while the context was active) The GL context must be
        active at the time sg_discard_context(sg_context ctx) is called.

    Also note that resources (buffers, images, shaders and pipelines) must
    only be used or destroyed while the same GL context is active that
    was also active while the resource was created (an exception is
    resource sharing on GL, such resources can be used while
    another context is active, but must still be destroyed under
    the same context that was active during creation).

    For more information, check out the multiwindow-glfw sample:

    https://github.com/floooh/sokol-samples/blob/master/glfw/multiwindow-glfw.c

    TRACE HOOKS:
    ============
    sokol_gfx.h optionally allows to install "trace hook" callbacks for
    each public API functions. When a public API function is called, and
    a trace hook callback has been installed for this function, the
    callback will be invoked with the parameters and result of the function.
    This is useful for things like debugging- and profiling-tools, or
    keeping track of resource creation and destruction.

    To use the trace hook feature:

    --- Define SOKOL_TRACE_HOOKS before including the implementation.

    --- Setup an sg_trace_hooks structure with your callback function
        pointers (keep all function pointers you're not interested
        in zero-initialized), optionally set the user_data member
        in the sg_trace_hooks struct.

    --- Install the trace hooks by calling sg_install_trace_hooks(),
        the return value of this function is another sg_trace_hooks
        struct which contains the previously set of trace hooks.
        You should keep this struct around, and call those previous
        functions pointers from your own trace callbacks for proper
        chaining.

    As an example of how trace hooks are used, have a look at the
    imgui/sokol_gfx_imgui.h header which implements a realtime
    debugging UI for sokol_gfx.h on top of Dear ImGui.

    A NOTE ON PORTABLE PACKED VERTEX FORMATS:
    =========================================
    There are two things to consider when using packed
    vertex formats like UBYTE4, SHORT2, etc which need to work
    across all backends:

    - D3D11 can only convert *normalized* vertex formats to
      floating point during vertex fetch, normalized formats = 0
      have a trailing 'N', and are "normalized" to a range
      -1.0..+1.0 (for the signed formats) or 0.0..1.0 (for the
      unsigned formats):

        - SG_VERTEXFORMAT_BYTE4N
        - SG_VERTEXFORMAT_UBYTE4N
        - SG_VERTEXFORMAT_SHORT2N
        - SG_VERTEXFORMAT_USHORT2N
        - SG_VERTEXFORMAT_SHORT4N
        - SG_VERTEXFORMAT_USHORT4N

      D3D11 will not convert *non-normalized* vertex formats to floating point
      vertex shader inputs, those can only be uses with the *ivecn* vertex shader
      input types when D3D11 is used as backend (GL and Metal can use both formats)

        - SG_VERTEXFORMAT_BYTE4,
        - SG_VERTEXFORMAT_UBYTE4
        - SG_VERTEXFORMAT_SHORT2
        - SG_VERTEXFORMAT_SHORT4

    - WebGL/GLES2 cannot use integer vertex shader inputs (int or ivecn)

    - SG_VERTEXFORMAT_UINT10_N2 is not supported on WebGL/GLES2

    So for a vertex input layout which works on all platforms, only use the following
    vertex formats, and if needed "expand" the normalized vertex shader
    inputs in the vertex shader by multiplying with 127.0, 255.0, 32767.0 or
    65535.0:

        - SG_VERTEXFORMAT_FLOAT,
        - SG_VERTEXFORMAT_FLOAT2,
        - SG_VERTEXFORMAT_FLOAT3,
        - SG_VERTEXFORMAT_FLOAT4,
        - SG_VERTEXFORMAT_BYTE4N,
        - SG_VERTEXFORMAT_UBYTE4N,
        - SG_VERTEXFORMAT_SHORT2N,
        - SG_VERTEXFORMAT_USHORT2N
        - SG_VERTEXFORMAT_SHORT4N,
        - SG_VERTEXFORMAT_USHORT4N

    TODO:
    ====
    - talk about asynchronous resource creation

    zlib/libpng license

    Copyright (c) 2018 Andre Weissflog

    This software is provided 'as-is', without any express or implied warranty.
    In no event will the authors be held liable for any damages arising from the
    use of this software.

    Permission is granted to anyone to use this software for any purpose,
    including commercial applications, and to alter it and redistribute it
    freely, subject to the following restrictions:

        1. The origin of this software must not be misrepresented; you must not
        claim that you wrote the original software. If you use this software in a
        product, an acknowledgment in the product documentation would be
        appreciated but is not required.

        2. Altered source versions must be plainly marked as such, and must not
        be misrepresented as being the original software.

        3. This notice may not be removed or altered from any source
        distribution.
*/
enum SOKOL_GFX_INCLUDED = 1;

/* nonstandard extension used: nameless struct/union */

/*
    Resource id typedefs:

    sg_buffer:      vertex- and index-buffers
    sg_image:       textures and render targets
    sg_shader:      vertex- and fragment-shaders, uniform blocks
    sg_pipeline:    associated shader and vertex-layouts, and render states
    sg_pass:        a bundle of render targets and actions on them
    sg_context:     a 'context handle' for switching between 3D-API contexts

    Instead of pointers, resource creation functions return a 32-bit
    number which uniquely identifies the resource object.

    The 32-bit resource id is split into a 16-bit pool index in the lower bits,
    and a 16-bit 'unique counter' in the upper bits. The index allows fast
    pool lookups, and combined with the unique-mask it allows to detect
    'dangling accesses' (trying to use an object which no longer exists, and
    its pool slot has been reused for a new object)

    The resource ids are wrapped into a struct so that the compiler
    can complain when the wrong resource type is used.
*/
alias sg_buffer = uint;

alias sg_image = uint;

alias sg_shader = uint;

alias sg_pipeline = uint;

alias sg_pass = uint;

alias sg_context = uint;

/*
    various compile-time constants

    FIXME: it may make sense to convert some of those into defines so
    that the user code can override them.
*/
enum
{
    SG_INVALID_ID = 0,
    SG_NUM_SHADER_STAGES = 2,
    SG_NUM_INFLIGHT_FRAMES = 2,
    SG_MAX_COLOR_ATTACHMENTS = 4,
    SG_MAX_SHADERSTAGE_BUFFERS = 8,
    SG_MAX_SHADERSTAGE_IMAGES = 12,
    SG_MAX_SHADERSTAGE_UBS = 4,
    SG_MAX_UB_MEMBERS = 16,
    SG_MAX_VERTEX_ATTRIBUTES = 16, /* NOTE: actual max vertex attrs can be less on GLES2, see sg_limits! */
    SG_MAX_MIPMAPS = 16,
    SG_MAX_TEXTUREARRAY_LAYERS = 128
}


/*
    sg_backend

    The active 3D-API backend, use the function sg_query_backend()
    to get the currently active backend.

    The returned value corresponds with the compile-time define to select
    a backend, with the only exception of SOKOL_GLES3: this may
    return SG_BACKEND_GLES2 if the backend has to fallback to GLES2 mode
    because GLES3 isn't supported.
*/
enum sg_backend
{
    SG_BACKEND_GLCORE33 = 0,
    SG_BACKEND_GLES2 = 1,
    SG_BACKEND_GLES3 = 2,
    SG_BACKEND_D3D11 = 3,
    SG_BACKEND_METAL_IOS = 4,
    SG_BACKEND_METAL_MACOS = 5,
    SG_BACKEND_METAL_SIMULATOR = 6,
    SG_BACKEND_WGPU = 7,
    SG_BACKEND_DUMMY = 8
}

alias SG_BACKEND_GLCORE33 = sg_backend.SG_BACKEND_GLCORE33;
alias SG_BACKEND_GLES2 = sg_backend.SG_BACKEND_GLES2;
alias SG_BACKEND_GLES3 = sg_backend.SG_BACKEND_GLES3;
alias SG_BACKEND_D3D11 = sg_backend.SG_BACKEND_D3D11;
alias SG_BACKEND_METAL_IOS = sg_backend.SG_BACKEND_METAL_IOS;
alias SG_BACKEND_METAL_MACOS = sg_backend.SG_BACKEND_METAL_MACOS;
alias SG_BACKEND_METAL_SIMULATOR = sg_backend.SG_BACKEND_METAL_SIMULATOR;
alias SG_BACKEND_WGPU = sg_backend.SG_BACKEND_WGPU;
alias SG_BACKEND_DUMMY = sg_backend.SG_BACKEND_DUMMY;

/*
    sg_pixel_format

    sokol_gfx.h basically uses the same pixel formats as WebGPU, since these
    are supported on most newer GPUs. GLES2 and WebGL has a much smaller
    subset of available pixel formats. Call sg_query_pixelformat() to check
    at runtime if a pixel format supports the desired features.

    A pixelformat name consist of three parts:

        - components (R, RG, RGB or RGBA)
        - bit width per component (8, 16 or 32)
        - component data type:
            - unsigned normalized (no postfix)
            - signed normalized (SN postfix)
            - unsigned integer (UI postfix)
            - signed integer (SI postfix)
            - float (F postfix)

    Not all pixel formats can be used for everything, call sg_query_pixelformat()
    to inspect the capabilities of a given pixelformat. The function returns
    an sg_pixelformat_info struct with the following bool members:

        - sample: the pixelformat can be sampled as texture at least with
                  nearest filtering
        - filter: the pixelformat can be samples as texture with linear
                  filtering
        - render: the pixelformat can be used for render targets
        - blend:  blending is supported when using the pixelformat for
                  render targets
        - msaa:   multisample-antialiasing is supported when using the
                  pixelformat for render targets
        - depth:  the pixelformat can be used for depth-stencil attachments

    When targeting GLES2/WebGL, the only safe formats to use
    as texture are SG_PIXELFORMAT_R8 and SG_PIXELFORMAT_RGBA8. For rendering
    in GLES2/WebGL, only SG_PIXELFORMAT_RGBA8 is safe. All other formats
    must be checked via sg_query_pixelformats().

    The default pixel format for texture images is SG_PIXELFORMAT_RGBA8.

    The default pixel format for render target images is platform-dependent:
        - for Metal and D3D11 it is SG_PIXELFORMAT_BGRA8
        - for GL backends it is SG_PIXELFORMAT_RGBA8

    This is mainly because of the default framebuffer which is setup outside
    of sokol_gfx.h. On some backends, using BGRA for the default frame buffer
    allows more efficient frame flips. For your own offscreen-render-targets,
    use whatever renderable pixel format is convenient for you.
*/
enum sg_pixel_format
{
    _SG_PIXELFORMAT_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_PIXELFORMAT_NONE = 1,

    SG_PIXELFORMAT_R8 = 2,
    SG_PIXELFORMAT_R8SN = 3,
    SG_PIXELFORMAT_R8UI = 4,
    SG_PIXELFORMAT_R8SI = 5,

    SG_PIXELFORMAT_R16 = 6,
    SG_PIXELFORMAT_R16SN = 7,
    SG_PIXELFORMAT_R16UI = 8,
    SG_PIXELFORMAT_R16SI = 9,
    SG_PIXELFORMAT_R16F = 10,
    SG_PIXELFORMAT_RG8 = 11,
    SG_PIXELFORMAT_RG8SN = 12,
    SG_PIXELFORMAT_RG8UI = 13,
    SG_PIXELFORMAT_RG8SI = 14,

    SG_PIXELFORMAT_R32UI = 15,
    SG_PIXELFORMAT_R32SI = 16,
    SG_PIXELFORMAT_R32F = 17,
    SG_PIXELFORMAT_RG16 = 18,
    SG_PIXELFORMAT_RG16SN = 19,
    SG_PIXELFORMAT_RG16UI = 20,
    SG_PIXELFORMAT_RG16SI = 21,
    SG_PIXELFORMAT_RG16F = 22,
    SG_PIXELFORMAT_RGBA8 = 23,
    SG_PIXELFORMAT_RGBA8SN = 24,
    SG_PIXELFORMAT_RGBA8UI = 25,
    SG_PIXELFORMAT_RGBA8SI = 26,
    SG_PIXELFORMAT_BGRA8 = 27,
    SG_PIXELFORMAT_RGB10A2 = 28,
    SG_PIXELFORMAT_RG11B10F = 29,

    SG_PIXELFORMAT_RG32UI = 30,
    SG_PIXELFORMAT_RG32SI = 31,
    SG_PIXELFORMAT_RG32F = 32,
    SG_PIXELFORMAT_RGBA16 = 33,
    SG_PIXELFORMAT_RGBA16SN = 34,
    SG_PIXELFORMAT_RGBA16UI = 35,
    SG_PIXELFORMAT_RGBA16SI = 36,
    SG_PIXELFORMAT_RGBA16F = 37,

    SG_PIXELFORMAT_RGBA32UI = 38,
    SG_PIXELFORMAT_RGBA32SI = 39,
    SG_PIXELFORMAT_RGBA32F = 40,

    SG_PIXELFORMAT_DEPTH = 41,
    SG_PIXELFORMAT_DEPTH_STENCIL = 42,

    SG_PIXELFORMAT_BC1_RGBA = 43,
    SG_PIXELFORMAT_BC2_RGBA = 44,
    SG_PIXELFORMAT_BC3_RGBA = 45,
    SG_PIXELFORMAT_BC4_R = 46,
    SG_PIXELFORMAT_BC4_RSN = 47,
    SG_PIXELFORMAT_BC5_RG = 48,
    SG_PIXELFORMAT_BC5_RGSN = 49,
    SG_PIXELFORMAT_BC6H_RGBF = 50,
    SG_PIXELFORMAT_BC6H_RGBUF = 51,
    SG_PIXELFORMAT_BC7_RGBA = 52,
    SG_PIXELFORMAT_PVRTC_RGB_2BPP = 53,
    SG_PIXELFORMAT_PVRTC_RGB_4BPP = 54,
    SG_PIXELFORMAT_PVRTC_RGBA_2BPP = 55,
    SG_PIXELFORMAT_PVRTC_RGBA_4BPP = 56,
    SG_PIXELFORMAT_ETC2_RGB8 = 57,
    SG_PIXELFORMAT_ETC2_RGB8A1 = 58,
    SG_PIXELFORMAT_ETC2_RGBA8 = 59,
    SG_PIXELFORMAT_ETC2_RG11 = 60,
    SG_PIXELFORMAT_ETC2_RG11SN = 61,

    _SG_PIXELFORMAT_NUM = 62,
    _SG_PIXELFORMAT_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_PIXELFORMAT_DEFAULT = sg_pixel_format._SG_PIXELFORMAT_DEFAULT;
alias SG_PIXELFORMAT_NONE = sg_pixel_format.SG_PIXELFORMAT_NONE;
alias SG_PIXELFORMAT_R8 = sg_pixel_format.SG_PIXELFORMAT_R8;
alias SG_PIXELFORMAT_R8SN = sg_pixel_format.SG_PIXELFORMAT_R8SN;
alias SG_PIXELFORMAT_R8UI = sg_pixel_format.SG_PIXELFORMAT_R8UI;
alias SG_PIXELFORMAT_R8SI = sg_pixel_format.SG_PIXELFORMAT_R8SI;
alias SG_PIXELFORMAT_R16 = sg_pixel_format.SG_PIXELFORMAT_R16;
alias SG_PIXELFORMAT_R16SN = sg_pixel_format.SG_PIXELFORMAT_R16SN;
alias SG_PIXELFORMAT_R16UI = sg_pixel_format.SG_PIXELFORMAT_R16UI;
alias SG_PIXELFORMAT_R16SI = sg_pixel_format.SG_PIXELFORMAT_R16SI;
alias SG_PIXELFORMAT_R16F = sg_pixel_format.SG_PIXELFORMAT_R16F;
alias SG_PIXELFORMAT_RG8 = sg_pixel_format.SG_PIXELFORMAT_RG8;
alias SG_PIXELFORMAT_RG8SN = sg_pixel_format.SG_PIXELFORMAT_RG8SN;
alias SG_PIXELFORMAT_RG8UI = sg_pixel_format.SG_PIXELFORMAT_RG8UI;
alias SG_PIXELFORMAT_RG8SI = sg_pixel_format.SG_PIXELFORMAT_RG8SI;
alias SG_PIXELFORMAT_R32UI = sg_pixel_format.SG_PIXELFORMAT_R32UI;
alias SG_PIXELFORMAT_R32SI = sg_pixel_format.SG_PIXELFORMAT_R32SI;
alias SG_PIXELFORMAT_R32F = sg_pixel_format.SG_PIXELFORMAT_R32F;
alias SG_PIXELFORMAT_RG16 = sg_pixel_format.SG_PIXELFORMAT_RG16;
alias SG_PIXELFORMAT_RG16SN = sg_pixel_format.SG_PIXELFORMAT_RG16SN;
alias SG_PIXELFORMAT_RG16UI = sg_pixel_format.SG_PIXELFORMAT_RG16UI;
alias SG_PIXELFORMAT_RG16SI = sg_pixel_format.SG_PIXELFORMAT_RG16SI;
alias SG_PIXELFORMAT_RG16F = sg_pixel_format.SG_PIXELFORMAT_RG16F;
alias SG_PIXELFORMAT_RGBA8 = sg_pixel_format.SG_PIXELFORMAT_RGBA8;
alias SG_PIXELFORMAT_RGBA8SN = sg_pixel_format.SG_PIXELFORMAT_RGBA8SN;
alias SG_PIXELFORMAT_RGBA8UI = sg_pixel_format.SG_PIXELFORMAT_RGBA8UI;
alias SG_PIXELFORMAT_RGBA8SI = sg_pixel_format.SG_PIXELFORMAT_RGBA8SI;
alias SG_PIXELFORMAT_BGRA8 = sg_pixel_format.SG_PIXELFORMAT_BGRA8;
alias SG_PIXELFORMAT_RGB10A2 = sg_pixel_format.SG_PIXELFORMAT_RGB10A2;
alias SG_PIXELFORMAT_RG11B10F = sg_pixel_format.SG_PIXELFORMAT_RG11B10F;
alias SG_PIXELFORMAT_RG32UI = sg_pixel_format.SG_PIXELFORMAT_RG32UI;
alias SG_PIXELFORMAT_RG32SI = sg_pixel_format.SG_PIXELFORMAT_RG32SI;
alias SG_PIXELFORMAT_RG32F = sg_pixel_format.SG_PIXELFORMAT_RG32F;
alias SG_PIXELFORMAT_RGBA16 = sg_pixel_format.SG_PIXELFORMAT_RGBA16;
alias SG_PIXELFORMAT_RGBA16SN = sg_pixel_format.SG_PIXELFORMAT_RGBA16SN;
alias SG_PIXELFORMAT_RGBA16UI = sg_pixel_format.SG_PIXELFORMAT_RGBA16UI;
alias SG_PIXELFORMAT_RGBA16SI = sg_pixel_format.SG_PIXELFORMAT_RGBA16SI;
alias SG_PIXELFORMAT_RGBA16F = sg_pixel_format.SG_PIXELFORMAT_RGBA16F;
alias SG_PIXELFORMAT_RGBA32UI = sg_pixel_format.SG_PIXELFORMAT_RGBA32UI;
alias SG_PIXELFORMAT_RGBA32SI = sg_pixel_format.SG_PIXELFORMAT_RGBA32SI;
alias SG_PIXELFORMAT_RGBA32F = sg_pixel_format.SG_PIXELFORMAT_RGBA32F;
alias SG_PIXELFORMAT_DEPTH = sg_pixel_format.SG_PIXELFORMAT_DEPTH;
alias SG_PIXELFORMAT_DEPTH_STENCIL = sg_pixel_format.SG_PIXELFORMAT_DEPTH_STENCIL;
alias SG_PIXELFORMAT_BC1_RGBA = sg_pixel_format.SG_PIXELFORMAT_BC1_RGBA;
alias SG_PIXELFORMAT_BC2_RGBA = sg_pixel_format.SG_PIXELFORMAT_BC2_RGBA;
alias SG_PIXELFORMAT_BC3_RGBA = sg_pixel_format.SG_PIXELFORMAT_BC3_RGBA;
alias SG_PIXELFORMAT_BC4_R = sg_pixel_format.SG_PIXELFORMAT_BC4_R;
alias SG_PIXELFORMAT_BC4_RSN = sg_pixel_format.SG_PIXELFORMAT_BC4_RSN;
alias SG_PIXELFORMAT_BC5_RG = sg_pixel_format.SG_PIXELFORMAT_BC5_RG;
alias SG_PIXELFORMAT_BC5_RGSN = sg_pixel_format.SG_PIXELFORMAT_BC5_RGSN;
alias SG_PIXELFORMAT_BC6H_RGBF = sg_pixel_format.SG_PIXELFORMAT_BC6H_RGBF;
alias SG_PIXELFORMAT_BC6H_RGBUF = sg_pixel_format.SG_PIXELFORMAT_BC6H_RGBUF;
alias SG_PIXELFORMAT_BC7_RGBA = sg_pixel_format.SG_PIXELFORMAT_BC7_RGBA;
alias SG_PIXELFORMAT_PVRTC_RGB_2BPP = sg_pixel_format.SG_PIXELFORMAT_PVRTC_RGB_2BPP;
alias SG_PIXELFORMAT_PVRTC_RGB_4BPP = sg_pixel_format.SG_PIXELFORMAT_PVRTC_RGB_4BPP;
alias SG_PIXELFORMAT_PVRTC_RGBA_2BPP = sg_pixel_format.SG_PIXELFORMAT_PVRTC_RGBA_2BPP;
alias SG_PIXELFORMAT_PVRTC_RGBA_4BPP = sg_pixel_format.SG_PIXELFORMAT_PVRTC_RGBA_4BPP;
alias SG_PIXELFORMAT_ETC2_RGB8 = sg_pixel_format.SG_PIXELFORMAT_ETC2_RGB8;
alias SG_PIXELFORMAT_ETC2_RGB8A1 = sg_pixel_format.SG_PIXELFORMAT_ETC2_RGB8A1;
alias SG_PIXELFORMAT_ETC2_RGBA8 = sg_pixel_format.SG_PIXELFORMAT_ETC2_RGBA8;
alias SG_PIXELFORMAT_ETC2_RG11 = sg_pixel_format.SG_PIXELFORMAT_ETC2_RG11;
alias SG_PIXELFORMAT_ETC2_RG11SN = sg_pixel_format.SG_PIXELFORMAT_ETC2_RG11SN;
alias _SG_PIXELFORMAT_NUM = sg_pixel_format._SG_PIXELFORMAT_NUM;
alias _SG_PIXELFORMAT_FORCE_U32 = sg_pixel_format._SG_PIXELFORMAT_FORCE_U32;

/*
    Runtime information about a pixel format, returned
    by sg_query_pixelformat().
*/
struct sg_pixelformat_info
{
    bool sample; /* pixel format can be sampled in shaders */
    bool filter; /* pixel format can be sampled with filtering */
    bool render; /* pixel format can be used as render target */
    bool blend; /* alpha-blending is supported */
    bool msaa; /* pixel format can be used as MSAA render target */
    bool depth; /* pixel format is a depth format */
}

/*
    Runtime information about available optional features,
    returned by sg_query_features()
*/
struct sg_features
{
    bool instancing; /* hardware instancing supported */
    bool origin_top_left; /* framebuffer and texture origin is in top left corner */
    bool multiple_render_targets; /* offscreen render passes can have multiple render targets attached */
    bool msaa_render_targets; /* offscreen render passes support MSAA antialiasing */
    bool imagetype_3d; /* creation of SG_IMAGETYPE_3D images is supported */
    bool imagetype_array; /* creation of SG_IMAGETYPE_ARRAY images is supported */
    bool image_clamp_to_border; /* border color and clamp-to-border UV-wrap mode is supported */
}

/*
    Runtime information about resource limits, returned by sg_query_limit()
*/
struct sg_limits
{
    uint max_image_size_2d; /* max width/height of SG_IMAGETYPE_2D images */
    uint max_image_size_cube; /* max width/height of SG_IMAGETYPE_CUBE images */
    uint max_image_size_3d; /* max width/height/depth of SG_IMAGETYPE_3D images */
    uint max_image_size_array; /* max width/height pf SG_IMAGETYPE_ARRAY images */
    uint max_image_array_layers; /* max number of layers in SG_IMAGETYPE_ARRAY images */
    uint max_vertex_attrs; /* <= SG_MAX_VERTEX_ATTRIBUTES (only on some GLES2 impls) */
}

/*
    sg_resource_state

    The current state of a resource in its resource pool.
    Resources start in the INITIAL state, which means the
    pool slot is unoccupied and can be allocated. When a resource is
    created, first an id is allocated, and the resource pool slot
    is set to state ALLOC. After allocation, the resource is
    initialized, which may result in the VALID or FAILED state. The
    reason why allocation and initialization are separate is because
    some resource types (e.g. buffers and images) might be asynchronously
    initialized by the user application. If a resource which is not
    in the VALID state is attempted to be used for rendering, rendering
    operations will silently be dropped.

    The special INVALID state is returned in sg_query_xxx_state() if no
    resource object exists for the provided resource id.
*/
enum sg_resource_state
{
    SG_RESOURCESTATE_INITIAL = 0,
    SG_RESOURCESTATE_ALLOC = 1,
    SG_RESOURCESTATE_VALID = 2,
    SG_RESOURCESTATE_FAILED = 3,
    SG_RESOURCESTATE_INVALID = 4,
    _SG_RESOURCESTATE_FORCE_U32 = 0x7FFFFFFF
}

alias SG_RESOURCESTATE_INITIAL = sg_resource_state.SG_RESOURCESTATE_INITIAL;
alias SG_RESOURCESTATE_ALLOC = sg_resource_state.SG_RESOURCESTATE_ALLOC;
alias SG_RESOURCESTATE_VALID = sg_resource_state.SG_RESOURCESTATE_VALID;
alias SG_RESOURCESTATE_FAILED = sg_resource_state.SG_RESOURCESTATE_FAILED;
alias SG_RESOURCESTATE_INVALID = sg_resource_state.SG_RESOURCESTATE_INVALID;
alias _SG_RESOURCESTATE_FORCE_U32 = sg_resource_state._SG_RESOURCESTATE_FORCE_U32;

/*
    sg_usage

    A resource usage hint describing the update strategy of
    buffers and images. This is used in the sg_buffer_desc.usage
    and sg_image_desc.usage members when creating buffers
    and images:

    SG_USAGE_IMMUTABLE:     the resource will never be updated with
                            new data, instead the content of the
                            resource must be provided on creation
    SG_USAGE_DYNAMIC:       the resource will be updated infrequently
                            with new data (this could range from "once
                            after creation", to "quite often but not
                            every frame")
    SG_USAGE_STREAM:        the resource will be updated each frame
                            with new content

    The rendering backends use this hint to prevent that the
    CPU needs to wait for the GPU when attempting to update
    a resource that might be currently accessed by the GPU.

    Resource content is updated with the functions sg_update_buffer() or
    sg_append_buffer() for buffer objects, and sg_update_image() for image
    objects. For the sg_update_*() functions, only one update is allowed per
    frame and resource object, while sg_append_buffer() can be called
    multiple times per frame on the same buffer. The application must update
    all data required for rendering (this means that the update data can be
    smaller than the resource size, if only a part of the overall resource
    size is used for rendering, you only need to make sure that the data that
    *is* used is valid).

    The default usage is SG_USAGE_IMMUTABLE.
*/
enum sg_usage
{
    _SG_USAGE_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_USAGE_IMMUTABLE = 1,
    SG_USAGE_DYNAMIC = 2,
    SG_USAGE_STREAM = 3,
    _SG_USAGE_NUM = 4,
    _SG_USAGE_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_USAGE_DEFAULT = sg_usage._SG_USAGE_DEFAULT;
alias SG_USAGE_IMMUTABLE = sg_usage.SG_USAGE_IMMUTABLE;
alias SG_USAGE_DYNAMIC = sg_usage.SG_USAGE_DYNAMIC;
alias SG_USAGE_STREAM = sg_usage.SG_USAGE_STREAM;
alias _SG_USAGE_NUM = sg_usage._SG_USAGE_NUM;
alias _SG_USAGE_FORCE_U32 = sg_usage._SG_USAGE_FORCE_U32;

/*
    sg_buffer_type

    This indicates whether a buffer contains vertex- or index-data,
    used in the sg_buffer_desc.type member when creating a buffer.

    The default value is SG_BUFFERTYPE_VERTEXBUFFER.
*/
enum sg_buffer_type
{
    _SG_BUFFERTYPE_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_BUFFERTYPE_VERTEXBUFFER = 1,
    SG_BUFFERTYPE_INDEXBUFFER = 2,
    _SG_BUFFERTYPE_NUM = 3,
    _SG_BUFFERTYPE_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_BUFFERTYPE_DEFAULT = sg_buffer_type._SG_BUFFERTYPE_DEFAULT;
alias SG_BUFFERTYPE_VERTEXBUFFER = sg_buffer_type.SG_BUFFERTYPE_VERTEXBUFFER;
alias SG_BUFFERTYPE_INDEXBUFFER = sg_buffer_type.SG_BUFFERTYPE_INDEXBUFFER;
alias _SG_BUFFERTYPE_NUM = sg_buffer_type._SG_BUFFERTYPE_NUM;
alias _SG_BUFFERTYPE_FORCE_U32 = sg_buffer_type._SG_BUFFERTYPE_FORCE_U32;

/*
    sg_index_type

    Indicates whether indexed rendering (fetching vertex-indices from an
    index buffer) is used, and if yes, the index data type (16- or 32-bits).
    This is used in the sg_pipeline_desc.index_type member when creating a
    pipeline object.

    The default index type is SG_INDEXTYPE_NONE.
*/
enum sg_index_type
{
    _SG_INDEXTYPE_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_INDEXTYPE_NONE = 1,
    SG_INDEXTYPE_UINT16 = 2,
    SG_INDEXTYPE_UINT32 = 3,
    _SG_INDEXTYPE_NUM = 4,
    _SG_INDEXTYPE_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_INDEXTYPE_DEFAULT = sg_index_type._SG_INDEXTYPE_DEFAULT;
alias SG_INDEXTYPE_NONE = sg_index_type.SG_INDEXTYPE_NONE;
alias SG_INDEXTYPE_UINT16 = sg_index_type.SG_INDEXTYPE_UINT16;
alias SG_INDEXTYPE_UINT32 = sg_index_type.SG_INDEXTYPE_UINT32;
alias _SG_INDEXTYPE_NUM = sg_index_type._SG_INDEXTYPE_NUM;
alias _SG_INDEXTYPE_FORCE_U32 = sg_index_type._SG_INDEXTYPE_FORCE_U32;

/*
    sg_image_type

    Indicates the basic type of an image object (2D-texture, cubemap,
    3D-texture or 2D-array-texture). 3D- and array-textures are not supported
    on the GLES2/WebGL backend (use sg_query_features().imagetype_3d and
    sg_query_features().imagetype_array to check for support). The image type
    is used in the sg_image_desc.type member when creating an image, and
    in sg_shader_image_desc when describing a shader's texture sampler binding.

    The default image type when creating an image is SG_IMAGETYPE_2D.
*/
enum sg_image_type
{
    _SG_IMAGETYPE_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_IMAGETYPE_2D = 1,
    SG_IMAGETYPE_CUBE = 2,
    SG_IMAGETYPE_3D = 3,
    SG_IMAGETYPE_ARRAY = 4,
    _SG_IMAGETYPE_NUM = 5,
    _SG_IMAGETYPE_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_IMAGETYPE_DEFAULT = sg_image_type._SG_IMAGETYPE_DEFAULT;
alias SG_IMAGETYPE_2D = sg_image_type.SG_IMAGETYPE_2D;
alias SG_IMAGETYPE_CUBE = sg_image_type.SG_IMAGETYPE_CUBE;
alias SG_IMAGETYPE_3D = sg_image_type.SG_IMAGETYPE_3D;
alias SG_IMAGETYPE_ARRAY = sg_image_type.SG_IMAGETYPE_ARRAY;
alias _SG_IMAGETYPE_NUM = sg_image_type._SG_IMAGETYPE_NUM;
alias _SG_IMAGETYPE_FORCE_U32 = sg_image_type._SG_IMAGETYPE_FORCE_U32;

/*
    sg_sampler_type

    Indicates the basic data type of a shader's texture sampler which
    can be float , unsigned integer or signed integer. The sampler
    type is used in the sg_shader_image_desc to describe the
    sampler type of a shader's texture sampler binding.

    The default sampler type is SG_SAMPLERTYPE_FLOAT.
*/
enum sg_sampler_type
{
    _SG_SAMPLERTYPE_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_SAMPLERTYPE_FLOAT = 1,
    SG_SAMPLERTYPE_SINT = 2,
    SG_SAMPLERTYPE_UINT = 3
}

alias _SG_SAMPLERTYPE_DEFAULT = sg_sampler_type._SG_SAMPLERTYPE_DEFAULT;
alias SG_SAMPLERTYPE_FLOAT = sg_sampler_type.SG_SAMPLERTYPE_FLOAT;
alias SG_SAMPLERTYPE_SINT = sg_sampler_type.SG_SAMPLERTYPE_SINT;
alias SG_SAMPLERTYPE_UINT = sg_sampler_type.SG_SAMPLERTYPE_UINT;

/*
    sg_cube_face

    The cubemap faces. Use these as indices in the sg_image_desc.content
    array.
*/
enum sg_cube_face
{
    SG_CUBEFACE_POS_X = 0,
    SG_CUBEFACE_NEG_X = 1,
    SG_CUBEFACE_POS_Y = 2,
    SG_CUBEFACE_NEG_Y = 3,
    SG_CUBEFACE_POS_Z = 4,
    SG_CUBEFACE_NEG_Z = 5,
    SG_CUBEFACE_NUM = 6,
    _SG_CUBEFACE_FORCE_U32 = 0x7FFFFFFF
}

alias SG_CUBEFACE_POS_X = sg_cube_face.SG_CUBEFACE_POS_X;
alias SG_CUBEFACE_NEG_X = sg_cube_face.SG_CUBEFACE_NEG_X;
alias SG_CUBEFACE_POS_Y = sg_cube_face.SG_CUBEFACE_POS_Y;
alias SG_CUBEFACE_NEG_Y = sg_cube_face.SG_CUBEFACE_NEG_Y;
alias SG_CUBEFACE_POS_Z = sg_cube_face.SG_CUBEFACE_POS_Z;
alias SG_CUBEFACE_NEG_Z = sg_cube_face.SG_CUBEFACE_NEG_Z;
alias SG_CUBEFACE_NUM = sg_cube_face.SG_CUBEFACE_NUM;
alias _SG_CUBEFACE_FORCE_U32 = sg_cube_face._SG_CUBEFACE_FORCE_U32;

/*
    sg_shader_stage

    There are 2 shader stages: vertex- and fragment-shader-stage.
    Each shader stage consists of:

    - one slot for a shader function (provided as source- or byte-code)
    - SG_MAX_SHADERSTAGE_UBS slots for uniform blocks
    - SG_MAX_SHADERSTAGE_IMAGES slots for images used as textures by
      the shader function
*/
enum sg_shader_stage
{
    SG_SHADERSTAGE_VS = 0,
    SG_SHADERSTAGE_FS = 1,
    _SG_SHADERSTAGE_FORCE_U32 = 0x7FFFFFFF
}

alias SG_SHADERSTAGE_VS = sg_shader_stage.SG_SHADERSTAGE_VS;
alias SG_SHADERSTAGE_FS = sg_shader_stage.SG_SHADERSTAGE_FS;
alias _SG_SHADERSTAGE_FORCE_U32 = sg_shader_stage._SG_SHADERSTAGE_FORCE_U32;

/*
    sg_primitive_type

    This is the common subset of 3D primitive types supported across all 3D
    APIs. This is used in the sg_pipeline_desc.primitive_type member when
    creating a pipeline object.

    The default primitive type is SG_PRIMITIVETYPE_TRIANGLES.
*/
enum sg_primitive_type
{
    _SG_PRIMITIVETYPE_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_PRIMITIVETYPE_POINTS = 1,
    SG_PRIMITIVETYPE_LINES = 2,
    SG_PRIMITIVETYPE_LINE_STRIP = 3,
    SG_PRIMITIVETYPE_TRIANGLES = 4,
    SG_PRIMITIVETYPE_TRIANGLE_STRIP = 5,
    _SG_PRIMITIVETYPE_NUM = 6,
    _SG_PRIMITIVETYPE_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_PRIMITIVETYPE_DEFAULT = sg_primitive_type._SG_PRIMITIVETYPE_DEFAULT;
alias SG_PRIMITIVETYPE_POINTS = sg_primitive_type.SG_PRIMITIVETYPE_POINTS;
alias SG_PRIMITIVETYPE_LINES = sg_primitive_type.SG_PRIMITIVETYPE_LINES;
alias SG_PRIMITIVETYPE_LINE_STRIP = sg_primitive_type.SG_PRIMITIVETYPE_LINE_STRIP;
alias SG_PRIMITIVETYPE_TRIANGLES = sg_primitive_type.SG_PRIMITIVETYPE_TRIANGLES;
alias SG_PRIMITIVETYPE_TRIANGLE_STRIP = sg_primitive_type.SG_PRIMITIVETYPE_TRIANGLE_STRIP;
alias _SG_PRIMITIVETYPE_NUM = sg_primitive_type._SG_PRIMITIVETYPE_NUM;
alias _SG_PRIMITIVETYPE_FORCE_U32 = sg_primitive_type._SG_PRIMITIVETYPE_FORCE_U32;

/*
    sg_filter

    The filtering mode when sampling a texture image. This is
    used in the sg_image_desc.min_filter and sg_image_desc.mag_filter
    members when creating an image object.

    The default filter mode is SG_FILTER_NEAREST.
*/
enum sg_filter
{
    _SG_FILTER_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_FILTER_NEAREST = 1,
    SG_FILTER_LINEAR = 2,
    SG_FILTER_NEAREST_MIPMAP_NEAREST = 3,
    SG_FILTER_NEAREST_MIPMAP_LINEAR = 4,
    SG_FILTER_LINEAR_MIPMAP_NEAREST = 5,
    SG_FILTER_LINEAR_MIPMAP_LINEAR = 6,
    _SG_FILTER_NUM = 7,
    _SG_FILTER_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_FILTER_DEFAULT = sg_filter._SG_FILTER_DEFAULT;
alias SG_FILTER_NEAREST = sg_filter.SG_FILTER_NEAREST;
alias SG_FILTER_LINEAR = sg_filter.SG_FILTER_LINEAR;
alias SG_FILTER_NEAREST_MIPMAP_NEAREST = sg_filter.SG_FILTER_NEAREST_MIPMAP_NEAREST;
alias SG_FILTER_NEAREST_MIPMAP_LINEAR = sg_filter.SG_FILTER_NEAREST_MIPMAP_LINEAR;
alias SG_FILTER_LINEAR_MIPMAP_NEAREST = sg_filter.SG_FILTER_LINEAR_MIPMAP_NEAREST;
alias SG_FILTER_LINEAR_MIPMAP_LINEAR = sg_filter.SG_FILTER_LINEAR_MIPMAP_LINEAR;
alias _SG_FILTER_NUM = sg_filter._SG_FILTER_NUM;
alias _SG_FILTER_FORCE_U32 = sg_filter._SG_FILTER_FORCE_U32;

/*
    sg_wrap

    The texture coordinates wrapping mode when sampling a texture
    image. This is used in the sg_image_desc.wrap_u, .wrap_v
    and .wrap_w members when creating an image.

    The default wrap mode is SG_WRAP_REPEAT.

    NOTE: SG_WRAP_CLAMP_TO_BORDER is not supported on all backends
    and platforms. To check for support, call sg_query_features()
    and check the "clamp_to_border" boolean in the returned
    sg_features struct.

    Platforms which don't support SG_WRAP_CLAMP_TO_BORDER will silently fall back
    to SG_WRAP_CLAMP_TO_EDGE without a validation error.

    Platforms which support clamp-to-border are:

        - all desktop GL platforms
        - Metal on macOS
        - D3D11

    Platforms which do not support clamp-to-border:

        - GLES2/3 and WebGL/WebGL2
        - Metal on iOS
*/
enum sg_wrap
{
    _SG_WRAP_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_WRAP_REPEAT = 1,
    SG_WRAP_CLAMP_TO_EDGE = 2,
    SG_WRAP_CLAMP_TO_BORDER = 3,
    SG_WRAP_MIRRORED_REPEAT = 4,
    _SG_WRAP_NUM = 5,
    _SG_WRAP_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_WRAP_DEFAULT = sg_wrap._SG_WRAP_DEFAULT;
alias SG_WRAP_REPEAT = sg_wrap.SG_WRAP_REPEAT;
alias SG_WRAP_CLAMP_TO_EDGE = sg_wrap.SG_WRAP_CLAMP_TO_EDGE;
alias SG_WRAP_CLAMP_TO_BORDER = sg_wrap.SG_WRAP_CLAMP_TO_BORDER;
alias SG_WRAP_MIRRORED_REPEAT = sg_wrap.SG_WRAP_MIRRORED_REPEAT;
alias _SG_WRAP_NUM = sg_wrap._SG_WRAP_NUM;
alias _SG_WRAP_FORCE_U32 = sg_wrap._SG_WRAP_FORCE_U32;

/*
    sg_border_color

    The border color to use when sampling a texture, and the UV wrap
    mode is SG_WRAP_CLAMP_TO_BORDER.

    The default border color is SG_BORDERCOLOR_OPAQUE_BLACK
*/
enum sg_border_color
{
    _SG_BORDERCOLOR_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_BORDERCOLOR_TRANSPARENT_BLACK = 1,
    SG_BORDERCOLOR_OPAQUE_BLACK = 2,
    SG_BORDERCOLOR_OPAQUE_WHITE = 3,
    _SG_BORDERCOLOR_NUM = 4,
    _SG_BORDERCOLOR_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_BORDERCOLOR_DEFAULT = sg_border_color._SG_BORDERCOLOR_DEFAULT;
alias SG_BORDERCOLOR_TRANSPARENT_BLACK = sg_border_color.SG_BORDERCOLOR_TRANSPARENT_BLACK;
alias SG_BORDERCOLOR_OPAQUE_BLACK = sg_border_color.SG_BORDERCOLOR_OPAQUE_BLACK;
alias SG_BORDERCOLOR_OPAQUE_WHITE = sg_border_color.SG_BORDERCOLOR_OPAQUE_WHITE;
alias _SG_BORDERCOLOR_NUM = sg_border_color._SG_BORDERCOLOR_NUM;
alias _SG_BORDERCOLOR_FORCE_U32 = sg_border_color._SG_BORDERCOLOR_FORCE_U32;

/*
    sg_vertex_format

    The data type of a vertex component. This is used to describe
    the layout of vertex data when creating a pipeline object.
*/
enum sg_vertex_format
{
    SG_VERTEXFORMAT_INVALID = 0,
    SG_VERTEXFORMAT_FLOAT = 1,
    SG_VERTEXFORMAT_FLOAT2 = 2,
    SG_VERTEXFORMAT_FLOAT3 = 3,
    SG_VERTEXFORMAT_FLOAT4 = 4,
    SG_VERTEXFORMAT_BYTE4 = 5,
    SG_VERTEXFORMAT_BYTE4N = 6,
    SG_VERTEXFORMAT_UBYTE4 = 7,
    SG_VERTEXFORMAT_UBYTE4N = 8,
    SG_VERTEXFORMAT_SHORT2 = 9,
    SG_VERTEXFORMAT_SHORT2N = 10,
    SG_VERTEXFORMAT_USHORT2N = 11,
    SG_VERTEXFORMAT_SHORT4 = 12,
    SG_VERTEXFORMAT_SHORT4N = 13,
    SG_VERTEXFORMAT_USHORT4N = 14,
    SG_VERTEXFORMAT_UINT10_N2 = 15,
    _SG_VERTEXFORMAT_NUM = 16,
    _SG_VERTEXFORMAT_FORCE_U32 = 0x7FFFFFFF
}

alias SG_VERTEXFORMAT_INVALID = sg_vertex_format.SG_VERTEXFORMAT_INVALID;
alias SG_VERTEXFORMAT_FLOAT = sg_vertex_format.SG_VERTEXFORMAT_FLOAT;
alias SG_VERTEXFORMAT_FLOAT2 = sg_vertex_format.SG_VERTEXFORMAT_FLOAT2;
alias SG_VERTEXFORMAT_FLOAT3 = sg_vertex_format.SG_VERTEXFORMAT_FLOAT3;
alias SG_VERTEXFORMAT_FLOAT4 = sg_vertex_format.SG_VERTEXFORMAT_FLOAT4;
alias SG_VERTEXFORMAT_BYTE4 = sg_vertex_format.SG_VERTEXFORMAT_BYTE4;
alias SG_VERTEXFORMAT_BYTE4N = sg_vertex_format.SG_VERTEXFORMAT_BYTE4N;
alias SG_VERTEXFORMAT_UBYTE4 = sg_vertex_format.SG_VERTEXFORMAT_UBYTE4;
alias SG_VERTEXFORMAT_UBYTE4N = sg_vertex_format.SG_VERTEXFORMAT_UBYTE4N;
alias SG_VERTEXFORMAT_SHORT2 = sg_vertex_format.SG_VERTEXFORMAT_SHORT2;
alias SG_VERTEXFORMAT_SHORT2N = sg_vertex_format.SG_VERTEXFORMAT_SHORT2N;
alias SG_VERTEXFORMAT_USHORT2N = sg_vertex_format.SG_VERTEXFORMAT_USHORT2N;
alias SG_VERTEXFORMAT_SHORT4 = sg_vertex_format.SG_VERTEXFORMAT_SHORT4;
alias SG_VERTEXFORMAT_SHORT4N = sg_vertex_format.SG_VERTEXFORMAT_SHORT4N;
alias SG_VERTEXFORMAT_USHORT4N = sg_vertex_format.SG_VERTEXFORMAT_USHORT4N;
alias SG_VERTEXFORMAT_UINT10_N2 = sg_vertex_format.SG_VERTEXFORMAT_UINT10_N2;
alias _SG_VERTEXFORMAT_NUM = sg_vertex_format._SG_VERTEXFORMAT_NUM;
alias _SG_VERTEXFORMAT_FORCE_U32 = sg_vertex_format._SG_VERTEXFORMAT_FORCE_U32;

/*
    sg_vertex_step

    Defines whether the input pointer of a vertex input stream is advanced
    'per vertex' or 'per instance'. The default step-func is
    SG_VERTEXSTEP_PER_VERTEX. SG_VERTEXSTEP_PER_INSTANCE is used with
    instanced-rendering.

    The vertex-step is part of the vertex-layout definition
    when creating pipeline objects.
*/
enum sg_vertex_step
{
    _SG_VERTEXSTEP_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_VERTEXSTEP_PER_VERTEX = 1,
    SG_VERTEXSTEP_PER_INSTANCE = 2,
    _SG_VERTEXSTEP_NUM = 3,
    _SG_VERTEXSTEP_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_VERTEXSTEP_DEFAULT = sg_vertex_step._SG_VERTEXSTEP_DEFAULT;
alias SG_VERTEXSTEP_PER_VERTEX = sg_vertex_step.SG_VERTEXSTEP_PER_VERTEX;
alias SG_VERTEXSTEP_PER_INSTANCE = sg_vertex_step.SG_VERTEXSTEP_PER_INSTANCE;
alias _SG_VERTEXSTEP_NUM = sg_vertex_step._SG_VERTEXSTEP_NUM;
alias _SG_VERTEXSTEP_FORCE_U32 = sg_vertex_step._SG_VERTEXSTEP_FORCE_U32;

/*
    sg_uniform_type

    The data type of a uniform block member. This is used to
    describe the internal layout of uniform blocks when creating
    a shader object.
*/
enum sg_uniform_type
{
    SG_UNIFORMTYPE_INVALID = 0,
    SG_UNIFORMTYPE_FLOAT = 1,
    SG_UNIFORMTYPE_FLOAT2 = 2,
    SG_UNIFORMTYPE_FLOAT3 = 3,
    SG_UNIFORMTYPE_FLOAT4 = 4,
    SG_UNIFORMTYPE_MAT4 = 5,
    _SG_UNIFORMTYPE_NUM = 6,
    _SG_UNIFORMTYPE_FORCE_U32 = 0x7FFFFFFF
}

alias SG_UNIFORMTYPE_INVALID = sg_uniform_type.SG_UNIFORMTYPE_INVALID;
alias SG_UNIFORMTYPE_FLOAT = sg_uniform_type.SG_UNIFORMTYPE_FLOAT;
alias SG_UNIFORMTYPE_FLOAT2 = sg_uniform_type.SG_UNIFORMTYPE_FLOAT2;
alias SG_UNIFORMTYPE_FLOAT3 = sg_uniform_type.SG_UNIFORMTYPE_FLOAT3;
alias SG_UNIFORMTYPE_FLOAT4 = sg_uniform_type.SG_UNIFORMTYPE_FLOAT4;
alias SG_UNIFORMTYPE_MAT4 = sg_uniform_type.SG_UNIFORMTYPE_MAT4;
alias _SG_UNIFORMTYPE_NUM = sg_uniform_type._SG_UNIFORMTYPE_NUM;
alias _SG_UNIFORMTYPE_FORCE_U32 = sg_uniform_type._SG_UNIFORMTYPE_FORCE_U32;

/*
    sg_cull_mode

    The face-culling mode, this is used in the
    sg_pipeline_desc.rasterizer.cull_mode member when creating a
    pipeline object.

    The default cull mode is SG_CULLMODE_NONE
*/
enum sg_cull_mode
{
    _SG_CULLMODE_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_CULLMODE_NONE = 1,
    SG_CULLMODE_FRONT = 2,
    SG_CULLMODE_BACK = 3,
    _SG_CULLMODE_NUM = 4,
    _SG_CULLMODE_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_CULLMODE_DEFAULT = sg_cull_mode._SG_CULLMODE_DEFAULT;
alias SG_CULLMODE_NONE = sg_cull_mode.SG_CULLMODE_NONE;
alias SG_CULLMODE_FRONT = sg_cull_mode.SG_CULLMODE_FRONT;
alias SG_CULLMODE_BACK = sg_cull_mode.SG_CULLMODE_BACK;
alias _SG_CULLMODE_NUM = sg_cull_mode._SG_CULLMODE_NUM;
alias _SG_CULLMODE_FORCE_U32 = sg_cull_mode._SG_CULLMODE_FORCE_U32;

/*
    sg_face_winding

    The vertex-winding rule that determines a front-facing primitive. This
    is used in the member sg_pipeline_desc.rasterizer.face_winding
    when creating a pipeline object.

    The default winding is SG_FACEWINDING_CW (clockwise)
*/
enum sg_face_winding
{
    _SG_FACEWINDING_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_FACEWINDING_CCW = 1,
    SG_FACEWINDING_CW = 2,
    _SG_FACEWINDING_NUM = 3,
    _SG_FACEWINDING_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_FACEWINDING_DEFAULT = sg_face_winding._SG_FACEWINDING_DEFAULT;
alias SG_FACEWINDING_CCW = sg_face_winding.SG_FACEWINDING_CCW;
alias SG_FACEWINDING_CW = sg_face_winding.SG_FACEWINDING_CW;
alias _SG_FACEWINDING_NUM = sg_face_winding._SG_FACEWINDING_NUM;
alias _SG_FACEWINDING_FORCE_U32 = sg_face_winding._SG_FACEWINDING_FORCE_U32;

/*
    sg_compare_func

    The compare-function for depth- and stencil-ref tests.
    This is used when creating pipeline objects in the members:

    sg_pipeline_desc
        .depth_stencil
            .depth_compare_func
            .stencil_front.compare_func
            .stencil_back.compare_func

    The default compare func for depth- and stencil-tests is
    SG_COMPAREFUNC_ALWAYS.
*/
enum sg_compare_func
{
    _SG_COMPAREFUNC_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_COMPAREFUNC_NEVER = 1,
    SG_COMPAREFUNC_LESS = 2,
    SG_COMPAREFUNC_EQUAL = 3,
    SG_COMPAREFUNC_LESS_EQUAL = 4,
    SG_COMPAREFUNC_GREATER = 5,
    SG_COMPAREFUNC_NOT_EQUAL = 6,
    SG_COMPAREFUNC_GREATER_EQUAL = 7,
    SG_COMPAREFUNC_ALWAYS = 8,
    _SG_COMPAREFUNC_NUM = 9,
    _SG_COMPAREFUNC_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_COMPAREFUNC_DEFAULT = sg_compare_func._SG_COMPAREFUNC_DEFAULT;
alias SG_COMPAREFUNC_NEVER = sg_compare_func.SG_COMPAREFUNC_NEVER;
alias SG_COMPAREFUNC_LESS = sg_compare_func.SG_COMPAREFUNC_LESS;
alias SG_COMPAREFUNC_EQUAL = sg_compare_func.SG_COMPAREFUNC_EQUAL;
alias SG_COMPAREFUNC_LESS_EQUAL = sg_compare_func.SG_COMPAREFUNC_LESS_EQUAL;
alias SG_COMPAREFUNC_GREATER = sg_compare_func.SG_COMPAREFUNC_GREATER;
alias SG_COMPAREFUNC_NOT_EQUAL = sg_compare_func.SG_COMPAREFUNC_NOT_EQUAL;
alias SG_COMPAREFUNC_GREATER_EQUAL = sg_compare_func.SG_COMPAREFUNC_GREATER_EQUAL;
alias SG_COMPAREFUNC_ALWAYS = sg_compare_func.SG_COMPAREFUNC_ALWAYS;
alias _SG_COMPAREFUNC_NUM = sg_compare_func._SG_COMPAREFUNC_NUM;
alias _SG_COMPAREFUNC_FORCE_U32 = sg_compare_func._SG_COMPAREFUNC_FORCE_U32;

/*
    sg_stencil_op

    The operation performed on a currently stored stencil-value when a
    comparison test passes or fails. This is used when creating a pipeline
    object in the members:

    sg_pipeline_desc
        .depth_stencil
            .stencil_front
                .fail_op
                .depth_fail_op
                .pass_op
            .stencil_back
                .fail_op
                .depth_fail_op
                .pass_op

    The default value is SG_STENCILOP_KEEP.
*/
enum sg_stencil_op
{
    _SG_STENCILOP_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_STENCILOP_KEEP = 1,
    SG_STENCILOP_ZERO = 2,
    SG_STENCILOP_REPLACE = 3,
    SG_STENCILOP_INCR_CLAMP = 4,
    SG_STENCILOP_DECR_CLAMP = 5,
    SG_STENCILOP_INVERT = 6,
    SG_STENCILOP_INCR_WRAP = 7,
    SG_STENCILOP_DECR_WRAP = 8,
    _SG_STENCILOP_NUM = 9,
    _SG_STENCILOP_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_STENCILOP_DEFAULT = sg_stencil_op._SG_STENCILOP_DEFAULT;
alias SG_STENCILOP_KEEP = sg_stencil_op.SG_STENCILOP_KEEP;
alias SG_STENCILOP_ZERO = sg_stencil_op.SG_STENCILOP_ZERO;
alias SG_STENCILOP_REPLACE = sg_stencil_op.SG_STENCILOP_REPLACE;
alias SG_STENCILOP_INCR_CLAMP = sg_stencil_op.SG_STENCILOP_INCR_CLAMP;
alias SG_STENCILOP_DECR_CLAMP = sg_stencil_op.SG_STENCILOP_DECR_CLAMP;
alias SG_STENCILOP_INVERT = sg_stencil_op.SG_STENCILOP_INVERT;
alias SG_STENCILOP_INCR_WRAP = sg_stencil_op.SG_STENCILOP_INCR_WRAP;
alias SG_STENCILOP_DECR_WRAP = sg_stencil_op.SG_STENCILOP_DECR_WRAP;
alias _SG_STENCILOP_NUM = sg_stencil_op._SG_STENCILOP_NUM;
alias _SG_STENCILOP_FORCE_U32 = sg_stencil_op._SG_STENCILOP_FORCE_U32;

/*
    sg_blend_factor

    The source and destination factors in blending operations.
    This is used in the following members when creating a pipeline object:

    sg_pipeline_desc
        .blend
            .src_factor_rgb
            .dst_factor_rgb
            .src_factor_alpha
            .dst_factor_alpha

    The default value is SG_BLENDFACTOR_ONE for source
    factors, and SG_BLENDFACTOR_ZERO for destination factors.
*/
enum sg_blend_factor
{
    _SG_BLENDFACTOR_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_BLENDFACTOR_ZERO = 1,
    SG_BLENDFACTOR_ONE = 2,
    SG_BLENDFACTOR_SRC_COLOR = 3,
    SG_BLENDFACTOR_ONE_MINUS_SRC_COLOR = 4,
    SG_BLENDFACTOR_SRC_ALPHA = 5,
    SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA = 6,
    SG_BLENDFACTOR_DST_COLOR = 7,
    SG_BLENDFACTOR_ONE_MINUS_DST_COLOR = 8,
    SG_BLENDFACTOR_DST_ALPHA = 9,
    SG_BLENDFACTOR_ONE_MINUS_DST_ALPHA = 10,
    SG_BLENDFACTOR_SRC_ALPHA_SATURATED = 11,
    SG_BLENDFACTOR_BLEND_COLOR = 12,
    SG_BLENDFACTOR_ONE_MINUS_BLEND_COLOR = 13,
    SG_BLENDFACTOR_BLEND_ALPHA = 14,
    SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA = 15,
    _SG_BLENDFACTOR_NUM = 16,
    _SG_BLENDFACTOR_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_BLENDFACTOR_DEFAULT = sg_blend_factor._SG_BLENDFACTOR_DEFAULT;
alias SG_BLENDFACTOR_ZERO = sg_blend_factor.SG_BLENDFACTOR_ZERO;
alias SG_BLENDFACTOR_ONE = sg_blend_factor.SG_BLENDFACTOR_ONE;
alias SG_BLENDFACTOR_SRC_COLOR = sg_blend_factor.SG_BLENDFACTOR_SRC_COLOR;
alias SG_BLENDFACTOR_ONE_MINUS_SRC_COLOR = sg_blend_factor.SG_BLENDFACTOR_ONE_MINUS_SRC_COLOR;
alias SG_BLENDFACTOR_SRC_ALPHA = sg_blend_factor.SG_BLENDFACTOR_SRC_ALPHA;
alias SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA = sg_blend_factor.SG_BLENDFACTOR_ONE_MINUS_SRC_ALPHA;
alias SG_BLENDFACTOR_DST_COLOR = sg_blend_factor.SG_BLENDFACTOR_DST_COLOR;
alias SG_BLENDFACTOR_ONE_MINUS_DST_COLOR = sg_blend_factor.SG_BLENDFACTOR_ONE_MINUS_DST_COLOR;
alias SG_BLENDFACTOR_DST_ALPHA = sg_blend_factor.SG_BLENDFACTOR_DST_ALPHA;
alias SG_BLENDFACTOR_ONE_MINUS_DST_ALPHA = sg_blend_factor.SG_BLENDFACTOR_ONE_MINUS_DST_ALPHA;
alias SG_BLENDFACTOR_SRC_ALPHA_SATURATED = sg_blend_factor.SG_BLENDFACTOR_SRC_ALPHA_SATURATED;
alias SG_BLENDFACTOR_BLEND_COLOR = sg_blend_factor.SG_BLENDFACTOR_BLEND_COLOR;
alias SG_BLENDFACTOR_ONE_MINUS_BLEND_COLOR = sg_blend_factor.SG_BLENDFACTOR_ONE_MINUS_BLEND_COLOR;
alias SG_BLENDFACTOR_BLEND_ALPHA = sg_blend_factor.SG_BLENDFACTOR_BLEND_ALPHA;
alias SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA = sg_blend_factor.SG_BLENDFACTOR_ONE_MINUS_BLEND_ALPHA;
alias _SG_BLENDFACTOR_NUM = sg_blend_factor._SG_BLENDFACTOR_NUM;
alias _SG_BLENDFACTOR_FORCE_U32 = sg_blend_factor._SG_BLENDFACTOR_FORCE_U32;

/*
    sg_blend_op

    Describes how the source and destination values are combined in the
    fragment blending operation. It is used in the following members when
    creating a pipeline object:

    sg_pipeline_desc
        .blend
            .op_rgb
            .op_alpha

    The default value is SG_BLENDOP_ADD.
*/
enum sg_blend_op
{
    _SG_BLENDOP_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_BLENDOP_ADD = 1,
    SG_BLENDOP_SUBTRACT = 2,
    SG_BLENDOP_REVERSE_SUBTRACT = 3,
    _SG_BLENDOP_NUM = 4,
    _SG_BLENDOP_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_BLENDOP_DEFAULT = sg_blend_op._SG_BLENDOP_DEFAULT;
alias SG_BLENDOP_ADD = sg_blend_op.SG_BLENDOP_ADD;
alias SG_BLENDOP_SUBTRACT = sg_blend_op.SG_BLENDOP_SUBTRACT;
alias SG_BLENDOP_REVERSE_SUBTRACT = sg_blend_op.SG_BLENDOP_REVERSE_SUBTRACT;
alias _SG_BLENDOP_NUM = sg_blend_op._SG_BLENDOP_NUM;
alias _SG_BLENDOP_FORCE_U32 = sg_blend_op._SG_BLENDOP_FORCE_U32;

/*
    sg_color_mask

    Selects the color channels when writing a fragment color to the
    framebuffer. This is used in the members
    sg_pipeline_desc.blend.color_write_mask when creating a pipeline object.

    The default colormask is SG_COLORMASK_RGBA (write all colors channels)

    NOTE: since the color mask value 0 is reserved for the default value
    (SG_COLORMASK_RGBA), use SG_COLORMASK_NONE if all color channels
    should be disabled.
*/
enum sg_color_mask
{
    _SG_COLORMASK_DEFAULT = 0, /* value 0 reserved for default-init */
    SG_COLORMASK_NONE = 0x10, /* special value for 'all channels disabled */
    SG_COLORMASK_R = 1 << 0,
    SG_COLORMASK_G = 1 << 1,
    SG_COLORMASK_B = 1 << 2,
    SG_COLORMASK_A = 1 << 3,
    SG_COLORMASK_RGB = 0x7,
    SG_COLORMASK_RGBA = 0xF,
    _SG_COLORMASK_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_COLORMASK_DEFAULT = sg_color_mask._SG_COLORMASK_DEFAULT;
alias SG_COLORMASK_NONE = sg_color_mask.SG_COLORMASK_NONE;
alias SG_COLORMASK_R = sg_color_mask.SG_COLORMASK_R;
alias SG_COLORMASK_G = sg_color_mask.SG_COLORMASK_G;
alias SG_COLORMASK_B = sg_color_mask.SG_COLORMASK_B;
alias SG_COLORMASK_A = sg_color_mask.SG_COLORMASK_A;
alias SG_COLORMASK_RGB = sg_color_mask.SG_COLORMASK_RGB;
alias SG_COLORMASK_RGBA = sg_color_mask.SG_COLORMASK_RGBA;
alias _SG_COLORMASK_FORCE_U32 = sg_color_mask._SG_COLORMASK_FORCE_U32;

/*
    sg_action

    Defines what action should be performed at the start of a render pass:

    SG_ACTION_CLEAR:    clear the render target image
    SG_ACTION_LOAD:     load the previous content of the render target image
    SG_ACTION_DONTCARE: leave the render target image content undefined

    This is used in the sg_pass_action structure.

    The default action for all pass attachments is SG_ACTION_CLEAR, with the
    clear color rgba = {0.5f, 0.5f, 0.5f, 1.0f], depth=1.0 and stencil=0.

    If you want to override the default behaviour, it is important to not
    only set the clear color, but the 'action' field as well (as long as this
    is in its _SG_ACTION_DEFAULT, the value fields will be ignored).
*/
enum sg_action
{
    _SG_ACTION_DEFAULT = 0,
    SG_ACTION_CLEAR = 1,
    SG_ACTION_LOAD = 2,
    SG_ACTION_DONTCARE = 3,
    _SG_ACTION_NUM = 4,
    _SG_ACTION_FORCE_U32 = 0x7FFFFFFF
}

alias _SG_ACTION_DEFAULT = sg_action._SG_ACTION_DEFAULT;
alias SG_ACTION_CLEAR = sg_action.SG_ACTION_CLEAR;
alias SG_ACTION_LOAD = sg_action.SG_ACTION_LOAD;
alias SG_ACTION_DONTCARE = sg_action.SG_ACTION_DONTCARE;
alias _SG_ACTION_NUM = sg_action._SG_ACTION_NUM;
alias _SG_ACTION_FORCE_U32 = sg_action._SG_ACTION_FORCE_U32;

/*
    sg_pass_action

    The sg_pass_action struct defines the actions to be performed
    at the start of a rendering pass in the functions sg_begin_pass()
    and sg_begin_default_pass().

    A separate action and clear values can be defined for each
    color attachment, and for the depth-stencil attachment.

    The default clear values are defined by the macros:

    - SG_DEFAULT_CLEAR_RED:     0.5f
    - SG_DEFAULT_CLEAR_GREEN:   0.5f
    - SG_DEFAULT_CLEAR_BLUE:    0.5f
    - SG_DEFAULT_CLEAR_ALPHA:   1.0f
    - SG_DEFAULT_CLEAR_DEPTH:   1.0f
    - SG_DEFAULT_CLEAR_STENCIL: 0
*/
struct sg_color_attachment_action
{
    sg_action action;
    float[4] val = 0;
}

struct sg_depth_attachment_action
{
    sg_action action;
    float val = 0;
}

struct sg_stencil_attachment_action
{
    sg_action action;
    ubyte val;
}

struct sg_pass_action
{
    uint _start_canary;
    sg_color_attachment_action[SG_MAX_COLOR_ATTACHMENTS] colors;
    sg_depth_attachment_action depth;
    sg_stencil_attachment_action stencil;
    uint _end_canary;
}

/*
    sg_bindings

    The sg_bindings structure defines the resource binding slots
    of the sokol_gfx render pipeline, used as argument to the
    sg_apply_bindings() function.

    A resource binding struct contains:

    - 1..N vertex buffers
    - 0..N vertex buffer offsets
    - 0..1 index buffers
    - 0..1 index buffer offsets
    - 0..N vertex shader stage images
    - 0..N fragment shader stage images

    The max number of vertex buffer and shader stage images
    are defined by the SG_MAX_SHADERSTAGE_BUFFERS and
    SG_MAX_SHADERSTAGE_IMAGES configuration constants.

    The optional buffer offsets can be used to put different unrelated
    chunks of vertex- and/or index-data into the same buffer objects.
*/
struct sg_bindings
{
    uint _start_canary;
    sg_buffer[SG_MAX_SHADERSTAGE_BUFFERS] vertex_buffers;
    int[SG_MAX_SHADERSTAGE_BUFFERS] vertex_buffer_offsets;
    sg_buffer index_buffer;
    int index_buffer_offset;
    sg_image[SG_MAX_SHADERSTAGE_IMAGES] vs_images;
    sg_image[SG_MAX_SHADERSTAGE_IMAGES] fs_images;
    uint _end_canary;
}

/*
    sg_buffer_desc

    Creation parameters for sg_buffer objects, used in the
    sg_make_buffer() call.

    The default configuration is:

    .size:      0       (this *must* be set to a valid size in bytes)
    .type:      SG_BUFFERTYPE_VERTEXBUFFER
    .usage:     SG_USAGE_IMMUTABLE
    .content    0
    .label      0       (optional string label for trace hooks)

    The label will be ignored by sokol_gfx.h, it is only useful
    when hooking into sg_make_buffer() or sg_init_buffer() via
    the sg_install_trace_hooks() function.

    ADVANCED TOPIC: Injecting native 3D-API buffers:

    The following struct members allow to inject your own GL, Metal
    or D3D11 buffers into sokol_gfx:

    .gl_buffers[SG_NUM_INFLIGHT_FRAMES]
    .mtl_buffers[SG_NUM_INFLIGHT_FRAMES]
    .d3d11_buffer

    You must still provide all other members except the .content member, and
    these must match the creation parameters of the native buffers you
    provide. For SG_USAGE_IMMUTABLE, only provide a single native 3D-API
    buffer, otherwise you need to provide SG_NUM_INFLIGHT_FRAMES buffers
    (only for GL and Metal, not D3D11). Providing multiple buffers for GL and
    Metal is necessary because sokol_gfx will rotate through them when
    calling sg_update_buffer() to prevent lock-stalls.

    Note that it is expected that immutable injected buffer have already been
    initialized with content, and the .content member must be 0!

    Also you need to call sg_reset_state_cache() after calling native 3D-API
    functions, and before calling any sokol_gfx function.
*/
struct sg_buffer_desc
{
    uint _start_canary;
    int size;
    sg_buffer_type type;
    sg_usage usage;
    const(void)* content;
    const(char)* label;
    /* GL specific */
    uint[SG_NUM_INFLIGHT_FRAMES] gl_buffers;
    /* Metal specific */
    const(void)*[SG_NUM_INFLIGHT_FRAMES] mtl_buffers;
    /* D3D11 specific */
    const(void)* d3d11_buffer;
    /* WebGPU specific */
    const(void)* wgpu_buffer;
    uint _end_canary;
}

/*
    sg_subimage_content

    Pointer to and size of a subimage-surface data, this is
    used to describe the initial content of immutable-usage images,
    or for updating a dynamic- or stream-usage images.

    For 3D- or array-textures, one sg_subimage_content item
    describes an entire mipmap level consisting of all array- or
    3D-slices of the mipmap level. It is only possible to update
    an entire mipmap level, not parts of it.
*/
struct sg_subimage_content
{
    const(void)* ptr; /* pointer to subimage data */
    int size; /* size in bytes of pointed-to subimage data */
}

/*
    sg_image_content

    Defines the content of an image through a 2D array
    of sg_subimage_content structs. The first array dimension
    is the cubemap face, and the second array dimension the
    mipmap level.
*/
struct sg_image_content
{
    sg_subimage_content[SG_MAX_MIPMAPS][SG_CUBEFACE_NUM] subimage;
}

/*
    sg_image_desc

    Creation parameters for sg_image objects, used in the
    sg_make_image() call.

    The default configuration is:

    .type:              SG_IMAGETYPE_2D
    .render_target:     false
    .width              0 (must be set to >0)
    .height             0 (must be set to >0)
    .depth/.layers:     1
    .num_mipmaps:       1
    .usage:             SG_USAGE_IMMUTABLE
    .pixel_format:      SG_PIXELFORMAT_RGBA8 for textures, or sg_desc.context.color_format for render targets
    .sample_count:      1 for textures, or sg_desc.context.sample_count for render target
    .min_filter:        SG_FILTER_NEAREST
    .mag_filter:        SG_FILTER_NEAREST
    .wrap_u:            SG_WRAP_REPEAT
    .wrap_v:            SG_WRAP_REPEAT
    .wrap_w:            SG_WRAP_REPEAT (only SG_IMAGETYPE_3D)
    .border_color       SG_BORDERCOLOR_OPAQUE_BLACK
    .max_anisotropy     1 (must be 1..16)
    .min_lod            0.0f
    .max_lod            FLT_MAX
    .content            an sg_image_content struct to define the initial content
    .label              0       (optional string label for trace hooks)

    Q: Why is the default sample_count for render targets identical with the
    "default sample count" from sg_desc.context.sample_count?

    A: So that it matches the default sample count in pipeline objects. Even
    though it is a bit strange/confusing that offscreen render targets by default
    get the same sample count as the default framebuffer, but it's better that
    an offscreen render target created with default parameters matches
    a pipeline object created with default parameters.

    NOTE:

    SG_IMAGETYPE_ARRAY and SG_IMAGETYPE_3D are not supported on
    WebGL/GLES2, use sg_query_features().imagetype_array and
    sg_query_features().imagetype_3d at runtime to check
    if array- and 3D-textures are supported.

    Images with usage SG_USAGE_IMMUTABLE must be fully initialized by
    providing a valid .content member which points to
    initialization data.

    ADVANCED TOPIC: Injecting native 3D-API textures:

    The following struct members allow to inject your own GL, Metal
    or D3D11 textures into sokol_gfx:

    .gl_textures[SG_NUM_INFLIGHT_FRAMES]
    .mtl_textures[SG_NUM_INFLIGHT_FRAMES]
    .d3d11_texture
    .d3d11_shader_resource_view

    For GL, you can also specify the texture target or leave it empty
    to use the default texture target for the image type (GL_TEXTURE_2D
    for SG_IMAGETYPE_2D etc)

    For D3D11, you can provide either a D3D11 texture, or a
    shader-resource-view, or both. If only a texture is provided,
    a matching shader-resource-view will be created. If only a
    shader-resource-view is provided, the texture will be looked
    up from the shader-resource-view.

    The same rules apply as for injecting native buffers
    (see sg_buffer_desc documentation for more details).
*/
struct sg_image_desc
{
    uint _start_canary;
    sg_image_type type;
    bool render_target;
    int width;
    int height;

    union
    {
        int depth;
        int layers;
    }

    int num_mipmaps;
    sg_usage usage;
    sg_pixel_format pixel_format;
    int sample_count;
    sg_filter min_filter;
    sg_filter mag_filter;
    sg_wrap wrap_u;
    sg_wrap wrap_v;
    sg_wrap wrap_w;
    sg_border_color border_color;
    uint max_anisotropy;
    float min_lod = 0;
    float max_lod = 0;
    sg_image_content content;
    const(char)* label;
    /* GL specific */
    uint[SG_NUM_INFLIGHT_FRAMES] gl_textures;
    uint gl_texture_target;
    /* Metal specific */
    const(void)*[SG_NUM_INFLIGHT_FRAMES] mtl_textures;
    /* D3D11 specific */
    const(void)* d3d11_texture;
    const(void)* d3d11_shader_resource_view;
    /* WebGPU specific */
    const(void)* wgpu_texture;
    uint _end_canary;
}

/*
    sg_shader_desc

    The structure sg_shader_desc defines all creation parameters
    for shader programs, used as input to the sg_make_shader() function:

    - reflection information for vertex attributes (vertex shader inputs):
        - vertex attribute name (required for GLES2, optional for GLES3 and GL)
        - a semantic name and index (required for D3D11)
    - for each shader-stage (vertex and fragment):
        - the shader source or bytecode
        - an optional entry function name
        - an optional compile target (only for D3D11 when source is provided,
          defaults are "vs_4_0" and "ps_4_0")
        - reflection info for each uniform block used by the shader stage:
            - the size of the uniform block in bytes
            - reflection info for each uniform block member (only required for GL backends):
                - member name
                - member type (SG_UNIFORMTYPE_xxx)
                - if the member is an array, the number of array items
        - reflection info for the texture images used by the shader stage:
            - the image type (SG_IMAGETYPE_xxx)
            - the sampler type (SG_SAMPLERTYPE_xxx, default is SG_SAMPLERTYPE_FLOAT)
            - the name of the texture sampler (required for GLES2, optional everywhere else)

    For all GL backends, shader source-code must be provided. For D3D11 and Metal,
    either shader source-code or byte-code can be provided.

    For D3D11, if source code is provided, the d3dcompiler_47.dll will be loaded
    on demand. If this fails, shader creation will fail. When compiling HLSL
    source code, you can provide an optional target string via
    sg_shader_stage_desc.d3d11_target, the default target is "vs_4_0" for the
    vertex shader stage and "ps_4_0" for the pixel shader stage.
*/
struct sg_shader_attr_desc
{
    const(char)* name; /* GLSL vertex attribute name (only required for GLES2) */
    const(char)* sem_name; /* HLSL semantic name */
    int sem_index; /* HLSL semantic index */
}

struct sg_shader_uniform_desc
{
    const(char)* name;
    sg_uniform_type type;
    int array_count;
}

struct sg_shader_uniform_block_desc
{
    int size;
    sg_shader_uniform_desc[SG_MAX_UB_MEMBERS] uniforms;
}

struct sg_shader_image_desc
{
    const(char)* name;
    sg_image_type type; /* FIXME: should this be renamed to 'image_type'? */
    sg_sampler_type sampler_type;
}

struct sg_shader_stage_desc
{
    const(char)* source;
    const(ubyte)* byte_code;
    int byte_code_size;
    const(char)* entry;
    const(char)* d3d11_target;
    sg_shader_uniform_block_desc[SG_MAX_SHADERSTAGE_UBS] uniform_blocks;
    sg_shader_image_desc[SG_MAX_SHADERSTAGE_IMAGES] images;
}

struct sg_shader_desc
{
    uint _start_canary;
    sg_shader_attr_desc[SG_MAX_VERTEX_ATTRIBUTES] attrs;
    sg_shader_stage_desc vs;
    sg_shader_stage_desc fs;
    const(char)* label;
    uint _end_canary;
}

/*
    sg_pipeline_desc

    The sg_pipeline_desc struct defines all creation parameters
    for an sg_pipeline object, used as argument to the
    sg_make_pipeline() function:

    - the vertex layout for all input vertex buffers
    - a shader object
    - the 3D primitive type (points, lines, triangles, ...)
    - the index type (none, 16- or 32-bit)
    - depth-stencil state
    - alpha-blending state
    - rasterizer state

    If the vertex data has no gaps between vertex components, you can omit
    the .layout.buffers[].stride and layout.attrs[].offset items (leave them
    default-initialized to 0), sokol-gfx will then compute the offsets and strides
    from the vertex component formats (.layout.attrs[].format). Please note
    that ALL vertex attribute offsets must be 0 in order for the
    automatic offset computation to kick in.

    The default configuration is as follows:

    .layout:
        .buffers[]:         vertex buffer layouts
            .stride:        0 (if no stride is given it will be computed)
            .step_func      SG_VERTEXSTEP_PER_VERTEX
            .step_rate      1
        .attrs[]:           vertex attribute declarations
            .buffer_index   0 the vertex buffer bind slot
            .offset         0 (offsets can be omitted if the vertex layout has no gaps)
            .format         SG_VERTEXFORMAT_INVALID (must be initialized!)
    .shader:            0 (must be initialized with a valid sg_shader id!)
    .primitive_type:    SG_PRIMITIVETYPE_TRIANGLES
    .index_type:        SG_INDEXTYPE_NONE
    .depth_stencil:
        .stencil_front, .stencil_back:
            .fail_op:               SG_STENCILOP_KEEP
            .depth_fail_op:         SG_STENCILOP_KEEP
            .pass_op:               SG_STENCILOP_KEEP
            .compare_func           SG_COMPAREFUNC_ALWAYS
        .depth_compare_func:    SG_COMPAREFUNC_ALWAYS
        .depth_write_enabled:   false
        .stencil_enabled:       false
        .stencil_read_mask:     0
        .stencil_write_mask:    0
        .stencil_ref:           0
    .blend:
        .enabled:               false
        .src_factor_rgb:        SG_BLENDFACTOR_ONE
        .dst_factor_rgb:        SG_BLENDFACTOR_ZERO
        .op_rgb:                SG_BLENDOP_ADD
        .src_factor_alpha:      SG_BLENDFACTOR_ONE
        .dst_factor_alpha:      SG_BLENDFACTOR_ZERO
        .op_alpha:              SG_BLENDOP_ADD
        .color_write_mask:      SG_COLORMASK_RGBA
        .color_attachment_count 1
        .color_format           SG_PIXELFORMAT_RGBA8
        .depth_format           SG_PIXELFORMAT_DEPTHSTENCIL
        .blend_color:           { 0.0f, 0.0f, 0.0f, 0.0f }
    .rasterizer:
        .alpha_to_coverage_enabled:     false
        .cull_mode:                     SG_CULLMODE_NONE
        .face_winding:                  SG_FACEWINDING_CW
        .sample_count:                  sg_desc.context.sample_count
        .depth_bias:                    0.0f
        .depth_bias_slope_scale:        0.0f
        .depth_bias_clamp:              0.0f
    .label  0       (optional string label for trace hooks)
*/
struct sg_buffer_layout_desc
{
    int stride;
    sg_vertex_step step_func;
    int step_rate;
}

struct sg_vertex_attr_desc
{
    int buffer_index;
    int offset;
    sg_vertex_format format;
}

struct sg_layout_desc
{
    sg_buffer_layout_desc[SG_MAX_SHADERSTAGE_BUFFERS] buffers;
    sg_vertex_attr_desc[SG_MAX_VERTEX_ATTRIBUTES] attrs;
}

struct sg_stencil_state
{
    sg_stencil_op fail_op;
    sg_stencil_op depth_fail_op;
    sg_stencil_op pass_op;
    sg_compare_func compare_func;
}

struct sg_depth_stencil_state
{
    sg_stencil_state stencil_front;
    sg_stencil_state stencil_back;
    sg_compare_func depth_compare_func;
    bool depth_write_enabled;
    bool stencil_enabled;
    ubyte stencil_read_mask;
    ubyte stencil_write_mask;
    ubyte stencil_ref;
}

struct sg_blend_state
{
    bool enabled;
    sg_blend_factor src_factor_rgb;
    sg_blend_factor dst_factor_rgb;
    sg_blend_op op_rgb;
    sg_blend_factor src_factor_alpha;
    sg_blend_factor dst_factor_alpha;
    sg_blend_op op_alpha;
    ubyte color_write_mask;
    int color_attachment_count;
    sg_pixel_format color_format;
    sg_pixel_format depth_format;
    float[4] blend_color = 0;
}

struct sg_rasterizer_state
{
    bool alpha_to_coverage_enabled;
    sg_cull_mode cull_mode;
    sg_face_winding face_winding;
    int sample_count;
    float depth_bias = 0;
    float depth_bias_slope_scale = 0;
    float depth_bias_clamp = 0;
}

struct sg_pipeline_desc
{
    uint _start_canary;
    sg_layout_desc layout;
    sg_shader shader;
    sg_primitive_type primitive_type;
    sg_index_type index_type;
    sg_depth_stencil_state depth_stencil;
    sg_blend_state blend;
    sg_rasterizer_state rasterizer;
    const(char)* label;
    uint _end_canary;
}

/*
    sg_pass_desc

    Creation parameters for an sg_pass object, used as argument
    to the sg_make_pass() function.

    A pass object contains 1..4 color-attachments and none, or one,
    depth-stencil-attachment. Each attachment consists of
    an image, and two additional indices describing
    which subimage the pass will render to: one mipmap index, and
    if the image is a cubemap, array-texture or 3D-texture, the
    face-index, array-layer or depth-slice.

    Pass images must fulfill the following requirements:

    All images must have:
    - been created as render target (sg_image_desc.render_target = true)
    - the same size
    - the same sample count

    In addition, all color-attachment images must have the same pixel format.
*/
struct sg_attachment_desc
{
    sg_image image;
    int mip_level;

    union
    {
        int face;
        int layer;
        int slice;
    }
}

struct sg_pass_desc
{
    uint _start_canary;
    sg_attachment_desc[SG_MAX_COLOR_ATTACHMENTS] color_attachments;
    sg_attachment_desc depth_stencil_attachment;
    const(char)* label;
    uint _end_canary;
}

/*
    sg_trace_hooks

    Installable callback functions to keep track of the sokol-gfx calls,
    this is useful for debugging, or keeping track of resource creation
    and destruction.

    Trace hooks are installed with sg_install_trace_hooks(), this returns
    another sg_trace_hooks struct with the previous set of
    trace hook function pointers. These should be invoked by the
    new trace hooks to form a proper call chain.
*/
struct sg_trace_hooks
{
    void* user_data;
    void function (void* user_data) reset_state_cache;
    void function (const(sg_buffer_desc)* desc, sg_buffer result, void* user_data) make_buffer;
    void function (const(sg_image_desc)* desc, sg_image result, void* user_data) make_image;
    void function (const(sg_shader_desc)* desc, sg_shader result, void* user_data) make_shader;
    void function (const(sg_pipeline_desc)* desc, sg_pipeline result, void* user_data) make_pipeline;
    void function (const(sg_pass_desc)* desc, sg_pass result, void* user_data) make_pass;
    void function (sg_buffer buf, void* user_data) destroy_buffer;
    void function (sg_image img, void* user_data) destroy_image;
    void function (sg_shader shd, void* user_data) destroy_shader;
    void function (sg_pipeline pip, void* user_data) destroy_pipeline;
    void function (sg_pass pass, void* user_data) destroy_pass;
    void function (sg_buffer buf, const(void)* data_ptr, int data_size, void* user_data) update_buffer;
    void function (sg_image img, const(sg_image_content)* data, void* user_data) update_image;
    void function (sg_buffer buf, const(void)* data_ptr, int data_size, int result, void* user_data) append_buffer;
    void function (const(sg_pass_action)* pass_action, int width, int height, void* user_data) begin_default_pass;
    void function (sg_pass pass, const(sg_pass_action)* pass_action, void* user_data) begin_pass;
    void function (int x, int y, int width, int height, bool origin_top_left, void* user_data) apply_viewport;
    void function (int x, int y, int width, int height, bool origin_top_left, void* user_data) apply_scissor_rect;
    void function (sg_pipeline pip, void* user_data) apply_pipeline;
    void function (const(sg_bindings)* bindings, void* user_data) apply_bindings;
    void function (sg_shader_stage stage, int ub_index, const(void)* data, int num_bytes, void* user_data) apply_uniforms;
    void function (int base_element, int num_elements, int num_instances, void* user_data) draw;
    void function (void* user_data) end_pass;
    void function (void* user_data) commit;
    void function (sg_buffer result, void* user_data) alloc_buffer;
    void function (sg_image result, void* user_data) alloc_image;
    void function (sg_shader result, void* user_data) alloc_shader;
    void function (sg_pipeline result, void* user_data) alloc_pipeline;
    void function (sg_pass result, void* user_data) alloc_pass;
    void function (sg_buffer buf_id, const(sg_buffer_desc)* desc, void* user_data) init_buffer;
    void function (sg_image img_id, const(sg_image_desc)* desc, void* user_data) init_image;
    void function (sg_shader shd_id, const(sg_shader_desc)* desc, void* user_data) init_shader;
    void function (sg_pipeline pip_id, const(sg_pipeline_desc)* desc, void* user_data) init_pipeline;
    void function (sg_pass pass_id, const(sg_pass_desc)* desc, void* user_data) init_pass;
    void function (sg_buffer buf_id, void* user_data) fail_buffer;
    void function (sg_image img_id, void* user_data) fail_image;
    void function (sg_shader shd_id, void* user_data) fail_shader;
    void function (sg_pipeline pip_id, void* user_data) fail_pipeline;
    void function (sg_pass pass_id, void* user_data) fail_pass;
    void function (const(char)* name, void* user_data) push_debug_group;
    void function (void* user_data) pop_debug_group;
    void function (void* user_data) err_buffer_pool_exhausted;
    void function (void* user_data) err_image_pool_exhausted;
    void function (void* user_data) err_shader_pool_exhausted;
    void function (void* user_data) err_pipeline_pool_exhausted;
    void function (void* user_data) err_pass_pool_exhausted;
    void function (void* user_data) err_context_mismatch;
    void function (void* user_data) err_pass_invalid;
    void function (void* user_data) err_draw_invalid;
    void function (void* user_data) err_bindings_invalid;
}

/*
    sg_buffer_info
    sg_image_info
    sg_shader_info
    sg_pipeline_info
    sg_pass_info

    These structs contain various internal resource attributes which
    might be useful for debug-inspection. Please don't rely on the
    actual content of those structs too much, as they are quite closely
    tied to sokol_gfx.h internals and may change more frequently than
    the other public API elements.

    The *_info structs are used as the return values of the following functions:

    sg_query_buffer_info()
    sg_query_image_info()
    sg_query_shader_info()
    sg_query_pipeline_info()
    sg_query_pass_info()
*/
struct sg_slot_info
{
    sg_resource_state state; /* the current state of this resource slot */
    uint res_id; /* type-neutral resource if (e.g. sg_buffer.id) */
    uint ctx_id; /* the context this resource belongs to */
}

struct sg_buffer_info
{
    sg_slot_info slot; /* resource pool slot info */
    uint update_frame_index; /* frame index of last sg_update_buffer() */
    uint append_frame_index; /* frame index of last sg_append_buffer() */
    int append_pos; /* current position in buffer for sg_append_buffer() */
    bool append_overflow; /* is buffer in overflow state (due to sg_append_buffer) */
    int num_slots; /* number of renaming-slots for dynamically updated buffers */
    int active_slot; /* currently active write-slot for dynamically updated buffers */
}

struct sg_image_info
{
    sg_slot_info slot; /* resource pool slot info */
    uint upd_frame_index; /* frame index of last sg_update_image() */
    int num_slots; /* number of renaming-slots for dynamically updated images */
    int active_slot; /* currently active write-slot for dynamically updated images */
    int width; /* image width */
    int height; /* image height */
}

struct sg_shader_info
{
    sg_slot_info slot; /* resoure pool slot info */
}

struct sg_pipeline_info
{
    sg_slot_info slot; /* resource pool slot info */
}

struct sg_pass_info
{
    sg_slot_info slot; /* resource pool slot info */
}

/*
    sg_desc

    The sg_desc struct contains configuration values for sokol_gfx,
    it is used as parameter to the sg_setup() call.

    NOTE that all callback function pointers come in two versions, one without
    a userdata pointer, and one with a userdata pointer. You would
    either initialize one or the other depending on whether you pass data
    to your callbacks.

    FIXME: explain the various configuration options

    The default configuration is:

    .buffer_pool_size       128
    .image_pool_size        128
    .shader_pool_size       32
    .pipeline_pool_size     64
    .pass_pool_size         16
    .context_pool_size      16
    .sampler_cache_size     64
    .uniform_buffer_size    4 MB (4*1024*1024)
    .staging_buffer_size    8 MB (8*1024*1024)

    .context.color_format: default value depends on selected backend:
        all GL backends:    SG_PIXELFORMAT_RGBA8
        Metal and D3D11:    SG_PIXELFORMAT_BGRA8
        WGPU:               *no default* (must be queried from WGPU swapchain)
    .context.depth_format   SG_PIXELFORMAT_DEPTH_STENCIL
    .context.sample_count   1

    GL specific:
        .context.gl.force_gles2
            if this is true the GL backend will act in "GLES2 fallback mode" even
            when compiled with SOKOL_GLES3, this is useful to fall back
            to traditional WebGL if a browser doesn't support a WebGL2 context

    Metal specific:
        (NOTE: All Objective-C object references are transferred through
        a bridged (const void*) to sokol_gfx, which will use a unretained
        bridged cast (__bridged id<xxx>) to retrieve the Objective-C
        references back. Since the bridge cast is unretained, the caller
        must hold a strong reference to the Objective-C object for the
        duration of the sokol_gfx call!

        .context.metal.device
            a pointer to the MTLDevice object
        .context.metal.renderpass_descriptor_cb
        .context.metal_renderpass_descriptor_userdata_cb
            A C callback function to obtain the MTLRenderPassDescriptor for the
            current frame when rendering to the default framebuffer, will be called
            in sg_begin_default_pass().
        .context.metal.drawable_cb
        .context.metal.drawable_userdata_cb
            a C callback function to obtain a MTLDrawable for the current
            frame when rendering to the default framebuffer, will be called in
            sg_end_pass() of the default pass
        .context.metal.user_data
            optional user data pointer passed to the userdata versions of
            callback functions

    D3D11 specific:
        .context.d3d11.device
            a pointer to the ID3D11Device object, this must have been created
            before sg_setup() is called
        .context.d3d11.device_context
            a pointer to the ID3D11DeviceContext object
        .context.d3d11.render_target_view_cb
        .context.d3d11.render_target_view_userdata_cb
            a C callback function to obtain a pointer to the current
            ID3D11RenderTargetView object of the default framebuffer,
            this function will be called in sg_begin_pass() when rendering
            to the default framebuffer
        .context.d3d11.depth_stencil_view_cb
        .context.d3d11.depth_stencil_view_userdata_cb
            a C callback function to obtain a pointer to the current
            ID3D11DepthStencilView object of the default framebuffer,
            this function will be called in sg_begin_pass() when rendering
            to the default framebuffer
        .context.metal.user_data
            optional user data pointer passed to the userdata versions of
            callback functions

    WebGPU specific:
        .context.wgpu.device
            a WGPUDevice handle
        .context.wgpu.render_format
            WGPUTextureFormat of the swap chain surface
        .context.wgpu.render_view_cb
        .context.wgpu.render_view_userdata_cb
            callback to get the current WGPUTextureView of the swapchain's
            rendering attachment (may be an MSAA surface)
        .context.wgpu.resolve_view_cb
        .context.wgpu.resolve_view_userdata_cb
            callback to get the current WGPUTextureView of the swapchain's
            MSAA-resolve-target surface, must return 0 if not MSAA rendering
        .context.wgpu.depth_stencil_view_cb
        .context.wgpu.depth_stencil_view_userdata_cb
            callback to get current default-pass depth-stencil-surface WGPUTextureView
            the pixel format of the default WGPUTextureView must be WGPUTextureFormat_Depth24Plus8
        .context.metal.user_data
            optional user data pointer passed to the userdata versions of
            callback functions

    When using sokol_gfx.h and sokol_app.h together, consider using the
    helper function sapp_sgcontext() in the sokol_glue.h header to
    initialize the sg_desc.context nested struct. sapp_sgcontext() returns
    a completely initialized sg_context_desc struct with information
    provided by sokol_app.h.
*/
struct sg_gl_context_desc
{
    bool force_gles2;
}

struct sg_mtl_context_desc
{
    const(void)* device;
    const(void)* function () renderpass_descriptor_cb;
    const(void)* function (void*) renderpass_descriptor_userdata_cb;
    const(void)* function () drawable_cb;
    const(void)* function (void*) drawable_userdata_cb;
    void* user_data;
}

alias sg_metal_context_desc = sg_mtl_context_desc;

struct sg_d3d11_context_desc
{
    const(void)* device;
    const(void)* device_context;
    const(void)* function () render_target_view_cb;
    const(void)* function (void*) render_target_view_userdata_cb;
    const(void)* function () depth_stencil_view_cb;
    const(void)* function (void*) depth_stencil_view_userdata_cb;
    void* user_data;
}

struct sg_wgpu_context_desc
{
    const(void)* device; /* WGPUDevice */
    const(void)* function () render_view_cb; /* returns WGPUTextureView */
    const(void)* function (void*) render_view_userdata_cb;
    const(void)* function () resolve_view_cb; /* returns WGPUTextureView */
    const(void)* function (void*) resolve_view_userdata_cb;
    const(void)* function () depth_stencil_view_cb; /* returns WGPUTextureView, must be WGPUTextureFormat_Depth24Plus8 */
    const(void)* function (void*) depth_stencil_view_userdata_cb;
    void* user_data;
}

struct sg_context_desc
{
    sg_pixel_format color_format;
    sg_pixel_format depth_format;
    int sample_count;
    sg_gl_context_desc gl;
    sg_metal_context_desc metal;
    sg_d3d11_context_desc d3d11;
    sg_wgpu_context_desc wgpu;
}

struct sg_desc
{
    uint _start_canary;
    int buffer_pool_size;
    int image_pool_size;
    int shader_pool_size;
    int pipeline_pool_size;
    int pass_pool_size;
    int context_pool_size;
    int uniform_buffer_size;
    int staging_buffer_size;
    int sampler_cache_size;
    sg_context_desc context;
    uint _end_canary;
}

/* setup and misc functions */
void sg_setup (const(sg_desc)* desc);
void sg_shutdown ();
bool sg_isvalid ();
void sg_reset_state_cache ();
sg_trace_hooks sg_install_trace_hooks (const(sg_trace_hooks)* trace_hooks);
void sg_push_debug_group (const(char)* name);
void sg_pop_debug_group ();

/* resource creation, destruction and updating */
sg_buffer sg_make_buffer (const(sg_buffer_desc)* desc);
sg_image sg_make_image (const(sg_image_desc)* desc);
sg_shader sg_make_shader (const(sg_shader_desc)* desc);
sg_pipeline sg_make_pipeline (const(sg_pipeline_desc)* desc);
sg_pass sg_make_pass (const(sg_pass_desc)* desc);
void sg_destroy_buffer (sg_buffer buf);
void sg_destroy_image (sg_image img);
void sg_destroy_shader (sg_shader shd);
void sg_destroy_pipeline (sg_pipeline pip);
void sg_destroy_pass (sg_pass pass);
void sg_update_buffer (sg_buffer buf, const(void)* data_ptr, int data_size);
void sg_update_image (sg_image img, const(sg_image_content)* data);
int sg_append_buffer (sg_buffer buf, const(void)* data_ptr, int data_size);
bool sg_query_buffer_overflow (sg_buffer buf);

/* rendering functions */
void sg_begin_default_pass (const(sg_pass_action)* pass_action, int width, int height);
void sg_begin_pass (sg_pass pass, const(sg_pass_action)* pass_action);
void sg_apply_viewport (int x, int y, int width, int height, bool origin_top_left);
void sg_apply_scissor_rect (int x, int y, int width, int height, bool origin_top_left);
void sg_apply_pipeline (sg_pipeline pip);
void sg_apply_bindings (const(sg_bindings)* bindings);
void sg_apply_uniforms (sg_shader_stage stage, int ub_index, const(void)* data, int num_bytes);
void sg_draw (int base_element, int num_elements, int num_instances);
void sg_end_pass ();
void sg_commit ();

/* getting information */
sg_desc sg_query_desc ();
sg_backend sg_query_backend ();
sg_features sg_query_features ();
sg_limits sg_query_limits ();
sg_pixelformat_info sg_query_pixelformat (sg_pixel_format fmt);
/* get current state of a resource (INITIAL, ALLOC, VALID, FAILED, INVALID) */
sg_resource_state sg_query_buffer_state (sg_buffer buf);
sg_resource_state sg_query_image_state (sg_image img);
sg_resource_state sg_query_shader_state (sg_shader shd);
sg_resource_state sg_query_pipeline_state (sg_pipeline pip);
sg_resource_state sg_query_pass_state (sg_pass pass);
/* get runtime information about a resource */
sg_buffer_info sg_query_buffer_info (sg_buffer buf);
sg_image_info sg_query_image_info (sg_image img);
sg_shader_info sg_query_shader_info (sg_shader shd);
sg_pipeline_info sg_query_pipeline_info (sg_pipeline pip);
sg_pass_info sg_query_pass_info (sg_pass pass);
/* get resource creation desc struct with their default values replaced */
sg_buffer_desc sg_query_buffer_defaults (const(sg_buffer_desc)* desc);
sg_image_desc sg_query_image_defaults (const(sg_image_desc)* desc);
sg_shader_desc sg_query_shader_defaults (const(sg_shader_desc)* desc);
sg_pipeline_desc sg_query_pipeline_defaults (const(sg_pipeline_desc)* desc);
sg_pass_desc sg_query_pass_defaults (const(sg_pass_desc)* desc);

/* separate resource allocation and initialization (for async setup) */
sg_buffer sg_alloc_buffer ();
sg_image sg_alloc_image ();
sg_shader sg_alloc_shader ();
sg_pipeline sg_alloc_pipeline ();
sg_pass sg_alloc_pass ();
void sg_init_buffer (sg_buffer buf_id, const(sg_buffer_desc)* desc);
void sg_init_image (sg_image img_id, const(sg_image_desc)* desc);
void sg_init_shader (sg_shader shd_id, const(sg_shader_desc)* desc);
void sg_init_pipeline (sg_pipeline pip_id, const(sg_pipeline_desc)* desc);
void sg_init_pass (sg_pass pass_id, const(sg_pass_desc)* desc);
void sg_fail_buffer (sg_buffer buf_id);
void sg_fail_image (sg_image img_id);
void sg_fail_shader (sg_shader shd_id);
void sg_fail_pipeline (sg_pipeline pip_id);
void sg_fail_pass (sg_pass pass_id);

/* rendering contexts (optional) */
sg_context sg_setup_context ();
void sg_activate_context (sg_context ctx_id);
void sg_discard_context (sg_context ctx_id);

/* Backend-specific helper functions, these may come in handy for mixing
   sokol-gfx rendering with 'native backend' rendering functions.

   This group of functions will be expanded as needed.
*/

/* D3D11: return ID3D11Device */
const(void)* sg_d3d11_device ();

/* Metal: return __bridge-casted MTLDevice */
const(void)* sg_mtl_device ();

/* Metal: return __bridge-casted MTLRenderCommandEncoder in current pass (or zero if outside pass) */
const(void)* sg_mtl_render_command_encoder ();

/* extern "C" */

/* reference-based equivalents for c++ */

// SOKOL_GFX_INCLUDED

/*--- IMPLEMENTATION ---------------------------------------------------------*/

/* memset */
/* FLT_MAX */

/* default clear values */

/* nonstandard extension used: nameless struct/union */
/* named type definition in parentheses */
/* unreferenced local function has been removed */

// see https://clang.llvm.org/docs/LanguageExtensions.html#automatic-reference-counting

/*=== COMMON BACKEND STUFF ===================================================*/

/* resource pool slots */

/* constants */

/* fixed-size string */

/* helper macros */

/*=== GENERIC SAMPLER CACHE ==================================================*/

/*
    this is used by the Metal and WGPU backends to reduce the
    number of sampler state objects created through the backend API
*/

/* orig min/max_lod is float, this is int(min/max_lod*1000.0) */

/* return matching sampler cache item index or -1 */

/* fallthrough: no matching cache item found */

/*=== DUMMY BACKEND DECLARATIONS =============================================*/

/*== GL BACKEND DECLARATIONS =================================================*/

/* if true, external buffers were injected with sg_buffer_desc.gl_buffers */

/* if true, external textures were injected with sg_image_desc.gl_textures */

/* -1 if attr is not enabled */
/* -1 if not initialized */

/*== D3D11 BACKEND DECLARATIONS ==============================================*/

/* on-demand loaded d3dcompiler_47.dll handles */

/* the following arrays are used for unbinding resources, they will always contain zeroes */

/* global subresourcedata array for texture updates */

/*=== METAL BACKEND DECLARATIONS =============================================*/

/* frame index at which it is safe to release this resource */

/* index into _sg_mtl_pool */

/* resouce binding state cache */

/*=== WGPU BACKEND DECLARATIONS ==============================================*/

/* a pool of per-frame uniform buffers */

/* current offset into current frame's mapped uniform buffer */

/* the GPU-side uniform buffer */

/* CPU-side staging buffers */
/* if != 0, staging buffer currently mapped */

/* ...a similar pool (like uniform buffer pool) of dynamic-resource staging buffers */

/* current offset into current frame's staging buffer */
/* number of staging buffers */
/* this frame's staging buffer */
/* CPU-side staging buffers */
/* if != 0, staging buffer currently mapped */

/* the WGPU backend state */

/*=== RESOURCE POOL DECLARATIONS =============================================*/

/* this *MUST* remain 0 */

/*=== VALIDATION LAYER DECLARATIONS ==========================================*/

/* special case 'validation was successful' */

/* buffer creation */

/* image creation */

/* shader creation */

/* pipeline creation */

/* pass creation */

/* sg_begin_pass validation */

/* sg_apply_pipeline validation */

/* sg_apply_bindings validation */

/* sg_apply_uniforms validation */

/* sg_update_buffer validation */

/* sg_append_buffer validation */

/* sg_update_image validation */

/*=== GENERIC BACKEND STATE ==================================================*/

/* original desc with default values patched in */

/*-- helper functions --------------------------------------------------------*/

/* return byte size of a vertex format */

/* return the byte size of a shader uniform */

/* FIXME: std140??? */

/* return true if pixel format is a compressed format */

/* return true if pixel format is a valid render target format */

/* return true if pixel format is a valid depth format */

/* return true if pixel format is a depth-stencil format */

/* return the bytes-per-pixel for a pixel format */

/* return row pitch for an image
    see ComputePitch in https://github.com/microsoft/DirectXTex/blob/master/DirectXTex/DirectXTexUtil.cpp
*/

/* compute the number of rows in a surface depending on pixel format */

/* return pitch of a 2D subimage / texture slice
    see ComputePitch in https://github.com/microsoft/DirectXTex/blob/master/DirectXTex/DirectXTexUtil.cpp
*/

/* capability table pixel format helper functions */

/* resolve pass action defaults into a new pass action struct */

/*== DUMMY BACKEND IMPL ======================================================*/

/* empty */

/* empty*/

/* NOTE: may return null */

/* NOTE: may return null */

/* empty */

/* empty */

/* NOTE: this is a requirement from WebGPU, but we want identical behaviour across all backend */

/*== GL BACKEND ==============================================================*/

/*-- type translation --------------------------------------------------------*/

/* see: https://www.khronos.org/registry/OpenGL-Refpages/es3.0/html/glTexImage2D.xhtml */

// FIXME: WEBGL_depth_texture extension?

/* FIXME: OES_half_float_blend */

/* GLES2 can only render to RGBA, and there's no RG format */

/* GLES2 can only render to RGBA, and there's no RG format */

/* scan extensions */
/* BC1..BC3 */
/* BC4 and BC5 */
/* BC6H and BC7 */

/* limits */

/* pixel formats */
/* not a bug */

/* FIXME??? */

/* BC1..BC3 */
/* BC4 and BC5 */
/* BC6H and BC7 */

/* limits */

/* pixel formats */

/* not a bug */

/* BC1..BC3 */
/* BC4 and BC5 */
/* BC6H and BC7 */

/* don't bother with half_float support on WebGL1
    has_texture_half_float = strstr(ext, "_texture_half_float");
    has_texture_half_float_linear = strstr(ext, "_texture_half_float_linear");
    has_colorbuffer_half_float = strstr(ext, "_color_buffer_half_float");
*/

/* limits */

/* pixel formats */
/* not a bug */

/* GLES2 doesn't allow multi-sampled render targets at all */

/*-- state cache implementation ----------------------------------------------*/

/* we only care restoring valid ids */

/* we only care restoring valid ids */

/* called when from _sg_gl_destroy_buffer() */

/* it's valid to call this function with target=0 and/or texture=0
   target=0 will unbind the previous binding, texture=0 will clear
   the new binding
*/

/* if the target has changed, clear the previous binding on that target */

/* apply new binding (texture can be 0 to unbind) */

/* we only care restoring valid ids */

/* called from _sg_gl_destroy_texture() */

/* called from _sg_gl_destroy_shader() */

/* shader program */

/* depth-stencil state */

/* blend state */

/* rasterizer state */

/* assumes that _sg.gl is already zero-initialized */

/* clear initial GL error state */

/* NOTE: ctx can be 0 to unset the current context */

/*-- GL backend resource creation and destruction ----------------------------*/

/* check if texture format is support */

/* check for optional texture types */

/* special case depth-stencil-buffer? */

/* cannot provide external texture for depth images */

/* regular color texture */

/* if this is a MSAA render target, need to create a separate render buffer */

/* inject externally GL textures */

/* create our own GL texture(s) */

/* GL spec has strange defaults for mipmap min/max lod: -1000 to +1000 */

/* compilation failed, log error and delete shader */

/* copy vertex attribute names over, these are required for GLES2, and optional for GLES3 and GL3.x */

/* resolve uniforms */

/* resolve image locations */

/* it's legal to call glUseProgram with 0 */

/* resolve vertex attributes */

/* empty */

/*
    _sg_create_pass

    att_imgs must point to a _sg_image* att_imgs[SG_MAX_COLOR_ATTACHMENTS+1] array,
    first entries are the color attachment images (or nullptr), last entry
    is the depth-stencil image (or nullptr).
*/

/* copy image pointers */

/* store current framebuffer binding (restored at end of function) */

/* create a framebuffer object */

/* attach msaa render buffer or textures */

/* 3D- or array-texture */

/* attach depth-stencil buffer to framebuffer */

/* check if framebuffer is complete */

/* setup color attachments for the framebuffer */

/* create MSAA resolve framebuffers if necessary */

/* check if framebuffer is complete */

/* setup color attachments for the framebuffer */

/* restore original framebuffer binding */

/* NOTE: may return null */

/* NOTE: may return null */

/* FIXME: what if a texture used as render target is still bound, should we
   unbind all currently bound textures in begin pass? */

/* can be 0 */

/* number of color attachments */

/* bind the render pass framebuffer */

/* offscreen pass */

/* default pass */

/* clear color and depth-stencil attachments if needed */

/* we messed with the state cache directly, need to clear cached
   pipeline to force re-evaluation in next sg_apply_pipeline() */

/* if this was an offscreen pass, and MSAA rendering was used, need
   to resolve into the pass images */

/* check if the pass object is still valid */

/* update depth-stencil state */

/* update blend state */

/* update rasterizer state */

/* according to ANGLE's D3D11 backend:
    D3D11 SlopeScaledDepthBias ==> GL polygonOffsetFactor
    D3D11 DepthBias ==> GL polygonOffsetUnits
    DepthBiasClamp has no meaning on GL
*/

/* bind shader program */

/* bind textures */

/* index buffer (can be 0) */

/* vertex attributes */

/* attribute is enabled */

/* attribute is disabled */

/* indexed rendering */

/* non-indexed rendering */

/* "soft" clear bindings (only those that are actually bound) */

/* only one update per buffer per frame allowed */

/* NOTE: this is a requirement from WebGPU, but we want identical behaviour across all backend */

/* only one update per image per frame allowed */

/*== D3D11 BACKEND IMPLEMENTATION ============================================*/

/*-- D3D11 C/C++ wrappers ----------------------------------------------------*/

/*-- enum translation functions ----------------------------------------------*/

/* invalid value for mag filter */

/* see: https://docs.microsoft.com/en-us/windows/win32/direct3d11/overviews-direct3d-11-resources-limits#resource-limits-for-feature-level-11-hardware */

/* see: https://docs.microsoft.com/en-us/windows/win32/api/d3d11/ne-d3d11-d3d11_format_support */

/* assume _sg.d3d11 already is zero-initialized */

/* clear all the device context state, so that resource refs don't keep stuck in the d3d device context */

/* just clear the d3d11 device context state */

/* empty */

/* FIXME? const int mip_depth = ((img->depth>>mip_index)>0) ? img->depth>>mip_index : 1; */

/* special case depth-stencil buffer? */

/* create only a depth-texture */

/* create (or inject) color texture and shader-resource-view */

/* prepare initial content pointers */

/* 2D-, cube- or array-texture */
/* if this is an MSAA render target, the following texture will be the 'resolve-texture' */

/* first check for injected texture and/or resource view */

/* if only a shader-resource-view was provided, but no texture, lookup
   the texture from the shader-resource-view, this also bumps the refcount
*/

/* if not injected, create texture */

/* trying to create a texture format that's not supported by D3D */

/* ...and similar, if not injected, create shader-resource-view */

/* 3D texture - same procedure, first check if injected, than create non-injected */

/* trying to create a texture format that's not supported by D3D */

/* also need to create a separate MSAA render target texture? */

/* sampler state object, note D3D11 implements an internal shared-pool for sampler objects */

/* all 0.0f */

/* opaque black */

/* on UWP, don't do anything (not tested) */

/* load DLL on demand */

/* don't attempt to load missing DLL in the future */

/* look up function pointers */

/* pSrcData */
/* SrcDataSize */
/* pSourceName */
/* pDefines */
/* pInclude */
/* pEntryPoint */
/* pTarget (vs_5_0 or ps_5_0) */
/* Flags1 */
/* Flags2 */
/* ppCode */
/* ppErrorMsgs */

/* just in case, usually output is NULL here */

/* copy vertex attribute semantic names and indices */

/* shader stage uniform blocks and image slots */

/* create a D3D constant buffer for each uniform block */

/* create from shader byte code */

/* compile from shader source code */

/* create the D3D vertex- and pixel-shader objects */

/* need to store the vertex shader byte code, this is needed later in sg_create_pipeline */

/* create input layout object */

/* pInputElementDesc */
/* NumElements */
/* pShaderByteCodeWithInputSignature */
/* BytecodeLength */

/* create rasterizer state */

/* create depth-stencil state */

/* create blend state */

/* create D3D11 render-target-view */

/* optional depth-stencil image */

/* create D3D11 depth-stencil-view */

/* NOTE: may return null */

/* NOTE: may return null */

/* render to default frame buffer */

/* apply the render-target- and depth-stencil-views */

/* set viewport and scissor rect to cover whole screen */

/* perform clear action */

/* D3D11CalcSubresource only exists for C++ */

/* need to resolve MSAA render target into texture? */

/* FIXME: support MSAA resolve into 3D texture */

/* pDstResource */
/* DstSubresource */
/* pSrcResource */
/* SrcSubresource */

/* gather all the D3D11 resources into arrays */

/* NOTE: this is a requirement from WebGPU, but we want identical behaviour across all backend */

/* FIXME: need to handle difference in depth-pitch for 3D textures as well! */

/*== METAL BACKEND IMPLEMENTATION ============================================*/

/*-- enum translation functions ----------------------------------------------*/

/* clamp-to-border not supported on iOS, fall back to clamp-to-edge */

/*-- a pool for all Metal resource objects, with deferred release queue -------*/

/* a queue of currently free slot indices */

/* pool slot 0 is reserved! */

/* a circular queue which holds release items (frame index
   when a resource is to be released, and the resource's
   pool index
*/

/* get a new free resource pool slot */

/* put a free resource pool slot back into the free-queue */

/*  add an MTLResource to the pool, return pool index or 0 if input was 'nil' */

/*  mark an MTLResource for release, this will put the resource into the
    deferred-release queue, and the resource will then be released N frames later,
    the special pool index 0 will be ignored (this means that a nil
    value was provided to _sg_mtl_add_resource()
*/

/* wrap-around */

/* release queue full? */

/* run garbage-collection pass on all resources in the release-queue */

/* don't need to check further, release-items past this are too young */

/* safe to release this resource */

/* put the now free pool index back on the free queue */

/* reset the release queue slot and advance the back index */

/* wrap-around */

/* destroy the sampler cache, and release all sampler objects */

/*
    create and add an MTLSamplerStateObject and return its resource pool index,
    reuse identical sampler state if one exists
*/

/* reuse existing sampler */

/* create a new Metal sampler state object and add to sampler cache */

/* https://developer.apple.com/metal/Metal-Feature-Set-Tables.pdf */

/* newer iOS devices support 16k textures */

/*-- main Metal backend state and functions ----------------------------------*/

/* assume already zero-initialized */

/* wait for the last frame to finish */

/* semaphore must be "relinquished" before destruction */

/* NOTE: MTLCommandBuffer and MTLRenderCommandEncoder are auto-released */

/* need to restore the uniform buffer binding (normally happens in
   _sg_mtl_begin_pass()
*/

/* empty */

/* it's valid to call release resource with '0' */

/* special case PVRTC formats: bytePerRow must be 0 */

/* FIXME: apparently the minimal bytes_per_image size for 3D texture
 is 4 KByte... somehow need to handle this */

/*
    FIXME: METAL RESOURCE STORAGE MODE FOR macOS AND iOS

    For immutable textures on macOS, the recommended procedure is to create
    a MTLStorageModeManaged texture with the immutable content first,
    and then use the GPU to blit the content into a MTLStorageModePrivate
    texture before the first use.

    On iOS use the same one-time-blit procedure, but from a
    MTLStorageModeShared to a MTLStorageModePrivate texture.

    It probably makes sense to handle this in a separate 'resource manager'
    with a recycable pool of blit-source-textures?
*/

/* initialize MTLTextureDescritor with common attributes */

/* macOS: use managed textures */

/* iOS: use CPU/GPU shared memory */

/* initialize MTLTextureDescritor with rendertarget attributes */

/* reset the cpuCacheMode to 'default' */

/* render targets are only visible to the GPU */

/* non-MSAA render targets are shader-readable */

/* initialize MTLTextureDescritor with MSAA attributes */

/* reset the cpuCacheMode to 'default' */

/* render targets are only visible to the GPU */

/* MSAA render targets are not shader-readable (instead they are resolved) */

/* first initialize all Metal resource pool slots to 'empty' */

/* initialize a Metal texture descriptor with common attributes */

/* special case depth-stencil-buffer? */

/* depth-stencil buffer texture must always be a render target */

/* create the color texture
    In case this is a render target without MSAA, add the relevant
    render-target descriptor attributes.
    In case this is a render target *with* MSAA, the color texture
    will serve as MSAA-resolve target (not as render target), and rendering
    will go into a separate render target texture of type
    MTLTextureType2DMultisample.
*/

/* if MSAA color render target, create an additional MSAA render-surface texture */

/* create (possibly shared) sampler state */

/* it's valid to call release resource with a 'null resource' */

/* NOTE: sampler state objects are shared and not released until shutdown */

/* create metal libray objects and lookup entry functions */

/* separate byte code provided */

/* separate sources provided */

/* it is legal to call _sg_mtl_add_resource with a nil value, this will return a special 0xFFFFFFFF index */

/* it is valid to call _sg_mtl_release_resource with a 'null resource' */

/* create vertex-descriptor */

/* render-pipeline descriptor */

/* FIXME: this only works on macOS 10.13!
for (int i = 0; i < (SG_MAX_SHADERSTAGE_UBS+SG_MAX_SHADERSTAGE_BUFFERS); i++) {
    rp_desc.vertexBuffers[i].mutability = MTLMutabilityImmutable;
}
for (int i = 0; i < SG_MAX_SHADERSTAGE_UBS; i++) {
    rp_desc.fragmentBuffers[i].mutability = MTLMutabilityImmutable;
}
*/

/* depth-stencil-state */

/* it's valid to call release resource with a 'null resource' */

/* copy image pointers */

/* NOTE: may return null */

/* NOTE: may return null */

/* if this is the first pass in the frame, create a command buffer */

/* block until the oldest frame in flight has finished */

/* if this is first pass in frame, get uniform buffer base pointer */

/* initialize a render pass descriptor */

/* offscreen render pass */

/* default render pass, call user-provided callback to provide render pass descriptor */

/* default pass descriptor will not be valid if window is minimized,
   don't do any rendering in this case */

/* setup pass descriptor for offscreen rendering */

/* setup pass descriptor for default rendering */

/* create a render command encoder, this might return nil if window is minimized */

/* bind the global uniform buffer, this only happens once per pass */

/* NOTE: MTLRenderCommandEncoder is autoreleased */

/* present, commit and signal semaphore when done */

/* garbage-collect resources pending for release */

/* rotate uniform buffer slot */

/* NOTE: MTLCommandBuffer is autoreleased */

/* clip against framebuffer rect */

/* store index buffer binding, this will be needed later in sg_draw() */

/* apply vertex buffers */

/* apply vertex shader images */

/* apply fragment shader images */

/* copy to global uniform buffer, record offset into cmd encoder, and advance offset */

/* indexed rendering */

/* non-indexed rendering */

/* NOTE: this is a requirement from WebGPU, but we want identical behaviour across all backend */

/*== WEBGPU BACKEND IMPLEMENTATION ===========================================*/

/* NOTE: there's no WGPUIndexFormat_None */

/* FIXME! UINT10_N2 */

/* NOT SUPPORTED */

/*
FIXME ??? this isn't needed anywhere?
_SOKOL_PRIVATE WGPUTextureAspect _sg_wgpu_texture_aspect(sg_pixel_format fmt) {
    if (_sg_is_valid_rendertarget_depth_format(fmt)) {
        if (!_sg_is_depth_stencil_format(fmt)) {
            return WGPUTextureAspect_DepthOnly;
        }
    }
    return WGPUTextureAspect_All;
}
*/

/* FIXME: separate blend alpha value not supported? */

/* FIXME: max images size??? */

/* FIXME FIXME FIXME: need to check if BC texture compression is
    actually supported, currently the WebGPU C-API doesn't allow this
*/

/*
    WGPU uniform buffer pool implementation:

    At start of frame, a mapped buffer is grabbed from the pool,
    or a new buffer is created if there is no mapped buffer available.

    At end of frame, the current buffer is unmapped before queue submit,
    and async-mapped immediately again.

    UNIFORM BUFFER FIXME:

    - As per WebGPU spec, it should be possible to create a Uniform|MapWrite
      buffer, but this isn't currently allowed in Dawn.
*/

/* Add the max-uniform-update size (64 KB) to the requested buffer size,
   this is to prevent validation errors in the WebGPU implementation
   if the entire buffer size is used per frame. 64 KB is the allowed
   max uniform update size on NVIDIA
*/

// FIXME FIXME FIXME FIXME: HACK FOR VALIDATION BUG IN DAWN

/* FIXME: better handling for this */

/* immediately request a new mapping for the last frame's current staging buffer */

/* rewind per-frame offsets */

/* check if a mapped staging buffer is available, otherwise create one */

/* no mapped uniform buffer available, create one */

/* unmap staging buffer and copy to uniform buffer */

/* helper function to compute number of bytes needed in staging buffer to copy image data */

/* row-pitch must be 256-aligend */

/* helper function to copy image data into a texture via a staging buffer, returns number of
   bytes copied
*/

/* copy content into mapped staging buffer */

/* can do a single memcpy */

/* src/dst pitch doesn't match, need to copy row by row */

/* record the staging copy operation into command encoder */

/*
    The WGPU staging buffer implementation:

    Very similar to the uniform buffer pool, there's a pool of big
    per-frame staging buffers, each must be big enough to hold
    all data uploaded to dynamic resources for one frame.

    Staging buffers are created on demand and reused, because the
    'frame pipeline depth' of WGPU isn't predictable.

    The difference to the uniform buffer system is that there isn't
    a 1:1 relationship for source- and destination for the
    data-copy operation. There's always one staging buffer as copy-source
    per frame, but many copy-destinations (regular vertex/index buffers
    or images). Instead of one big copy-operation at the end of the frame,
    multiple copy-operations will be written throughout the frame.
*/

/* there's actually nothing more to do here */

/* FIXME: better handling for this */

/* immediately request a new mapping for the last frame's current staging buffer */

/* rewind staging-buffer offset */

/* check if mapped staging buffer is available, otherwise create one */

/* no mapped buffer available, create one */

/* Copy a chunk of data into the staging buffer, and record a blit-operation into
    the command encoder, bump the offset for the next data chunk, return 0 if there
    was not enough room in the staging buffer, return the number of actually
    copied bytes on success.

    NOTE: that the number of staging bytes to be copied must be a multiple of 4.

*/

/* similar to _sg_wgpu_staging_copy_to_buffer(), but with image data instead */

/* called at end of frame before queue-submit */

/*--- WGPU sampler cache functions ---*/

/* reuse existing sampler */

/* create a new WGPU sampler and add to sampler cache */
/* FIXME: anisotropic filtering not supported? */

/*--- WGPU backend API functions ---*/

/* setup WebGPU features and limits */

/* setup the sampler cache, uniform and staging buffer pools */

/* create an empty bind group for shader stages without bound images */

/* create initial per-frame command encoders */

/* NOTE: a depth-stencil texture will never be MSAA-resolved, so there
   won't be a separate MSAA- and resolve-texture
*/

/* NOTE: in the MSAA-rendertarget case, both the MSAA texture *and*
   the resolve texture need OutputAttachment usage
*/

/* copy content into texture via a throw-away staging buffer */

/* create texture view object */

/* if render target and MSAA, then a separate texture in MSAA format is needed
   which will be resolved into the regular texture at the end of the
   offscreen-render pass
*/

/* create sampler via shared-sampler-cache */

/* NOTE: do *not* destroy the sampler from the shared-sampler-cache */

/*
    How BindGroups work in WebGPU:

    - up to 4 bind groups can be bound simultanously
    - up to 16 bindings per bind group
    - 'binding' slots are local per bind group
    - in the shader:
        layout(set=0, binding=1) corresponds to bind group 0, binding 1

    Now how to map this to sokol-gfx's bind model:

    Reduce SG_MAX_SHADERSTAGE_IMAGES to 8, then:

        1 bind group for all 8 uniform buffers
        1 bind group for vertex shader textures + samplers
        1 bind group for fragment shader textures + samples

    Alternatively:

        1 bind group for 8 uniform buffer slots
        1 bind group for 8 vs images + 8 vs samplers
        1 bind group for 12 fs images
        1 bind group for 12 fs samplers

    I guess this means that we need to create BindGroups on the
    fly during sg_apply_bindings() :/
*/

/* create image/sampler bind group for the shader stage */

/* texture- and sampler-bindings */

/* NOTE: WebGPU has no support for vertex step rate (because that's
   not supported by Core Vulkan
*/

/* FIXME: ??? */

/* copy image pointers and create render-texture views */

/* create a render-texture-view to render into the right sub-surface */

/* ... and if needed a separate resolve texture view */

/* create a render-texture view */

/* NOTE: may return null */

/* NOTE: may return null */

/* default render pass */

/* null if no MSAA rendering */

/* initial uniform buffer binding (required even if no uniforms are set in the frame) */

/* groupIndex 0 is reserved for uniform buffers */

/* finish and submit this frame's work */

/* create a new render- and staging-command-encoders for next frame */

/* grab new staging buffers for uniform- and vertex/image-updates */

/* clip against framebuffer rect */

/* index buffer */

/* vertex buffers */

/* need to create throw-away bind groups for images */

/* groupIndex 0 is reserved for uniform buffers */

/*== BACKEND API WRAPPERS ====================================================*/

/*== RESOURCE POOLS ==========================================================*/

/* slot 0 is reserved for the 'invalid id', so bump the pool size by 1 */

/* generation counters indexable by pool slot index, slot 0 is reserved */

/* it's not a bug to only reserve 'num' here */

/* never allocate the zero-th pool item since the invalid id is 0 */

/* pool exhausted */

/* debug check against double-free */

/* note: the pools here will have an additional item, since slot 0 is reserved */

/* allocate the slot at slot_index:
    - bump the slot's generation counter
    - create a resource id from the generation counter and slot index
    - set the slot's id to this id
    - set the slot's state to ALLOC
    - return the resource id
*/

/* FIXME: add handling for an overflowing generation counter,
   for now, just overflow (another option is to disable
   the slot)
*/

/* extract slot index from id */

/* returns pointer to resource by id without matching id check */

/* returns pointer to resource with matching id check, may return 0 */

/*  this is a bit dumb since it loops over all pool slots to
    find the occupied slots, on the other hand it is only ever
    executed at shutdown
    NOTE: ONLY EXECUTE THIS AT SHUTDOWN
          ...because the free queues will not be reset
          and the resource slots not be cleared!
*/

/*== VALIDATION LAYER ========================================================*/

/* return a human readable string for an _sg_validate_error */

/* buffer creation validation errors */

/* image creation validation errros */

/* shader creation */

/* pipeline creation */

/* pass creation */

/* sg_begin_pass */

/* sg_apply_pipeline */

/* sg_apply_bindings */

/* sg_apply_uniforms */

/* sg_update_buffer */

/* sg_append_buffer */

/* sg_update_image */

/* defined(SOKOL_DEBUG) */

/*-- validation checks -------------------------------------------------------*/

/* on GLES2, sample count for render targets is completely ignored */

/* FIXME: should use the same "expected size" computation as in _sg_validate_update_image() here */

/* on GL, must provide shader source code */

/* on Metal or D3D11, must provide shader source code or byte code */

/* on WGPU byte code must be provided */

/* Dummy Backend, don't require source or bytecode */

/* if shader byte code, the size must also be provided */

/* on GLES2, vertex attribute names must be provided */

/* on D3D11, semantic names (and semantic indices) must be provided */

/* the pipeline object must be alive and valid */

/* the pipeline's shader must be alive and valid */

/* check that pipeline attributes match current pass attributes */

/* an offscreen pass */

/* default pass */

/* a pipeline object must have been applied */

/* has expected vertex buffers, and vertex buffers still exist */

/* buffers in vertex-buffer-slots must be of type SG_BUFFERTYPE_VERTEXBUFFER */

/* vertex buffer provided in a slot which has no vertex layout in pipeline */

/* index buffer expected or not, and index buffer still exists */

/* pipeline defines non-indexed rendering, but index buffer provided */

/* pipeline defines indexed rendering, but no index buffer provided */

/* buffer in index-buffer-slot must be of type SG_BUFFERTYPE_INDEXBUFFER */

/* has expected vertex shader images */

/* has expected fragment shader images */

/* check that there is a uniform block at 'stage' and 'ub_index' */

/* check that the provided data size doesn't exceed the uniform block size */

/*== fill in desc default values =============================================*/

/* resolve vertex layout strides and offsets */

/* to use computed offsets, *all* attr offsets must be 0 */

/* compute vertex strides if needed */

/* FIXME: no values to replace in sg_pass_desc? */

/*== allocate/initialize resource private functions ==========================*/

/* pool is exhausted */

/* pool is exhausted */

/* pool is exhausted */

/* pool is exhausted */

/* pool is exhausted */

/* lookup pass attachment image pointers */

/* FIXME: this shouldn't be an assertion, but result in a SG_RESOURCESTATE_FAILED pass */

/* FIXME: this shouldn't be an assertion, but result in a SG_RESOURCESTATE_FAILED pass */

/*== PUBLIC API FUNCTIONS ====================================================*/

// this is ARC compatible

/* replace zero-init items with their default values
    NOTE: on WebGPU, the default color pixel format MUST be provided,
    cannot be a default compile-time constant.
*/

/* can only delete resources for the currently set context here, if multiple
contexts are used, the app code must take care of properly releasing them
(since only the app code can switch between 3D-API contexts)
*/

/* pool is exhausted */

/* NOTE: ctx can be 0 here if the context is no longer valid */

/*-- set allocated resource to failed state ----------------------------------*/

/*-- get resource state */

/*-- allocate and initialize resource ----------------------------------------*/

/*-- destroy resource --------------------------------------------------------*/

/* attempting to draw with zero elements or instances is not technically an
   error, but might be handled as an error in the backend API (e.g. on Metal)
*/

/* only one update allowed per buffer and frame */

/* update and append on same buffer in same frame not allowed */

/* rewind append cursor in a new frame */

/* update and append on same buffer in same frame not allowed */

/* FIXME: should we return -1 here? */

/* SOKOL_IMPL */
