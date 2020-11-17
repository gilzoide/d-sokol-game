import core.stdc.stdint;

extern (C):

/*
    sokol_app.h -- cross-platform application wrapper

    Project URL: https://github.com/floooh/sokol

    Do this:
        #define SOKOL_IMPL
    before you include this file in *one* C or C++ file to create the
    implementation.

    In the same place define one of the following to select the 3D-API
    which should be initialized by sokol_app.h (this must also match
    the backend selected for sokol_gfx.h if both are used in the same
    project):

        #define SOKOL_GLCORE33
        #define SOKOL_GLES2
        #define SOKOL_GLES3
        #define SOKOL_D3D11
        #define SOKOL_METAL
        #define SOKOL_WGPU

    Optionally provide the following defines with your own implementations:

        SOKOL_ASSERT(c)     - your own assert macro (default: assert(c))
        SOKOL_LOG(msg)      - your own logging function (default: puts(msg))
        SOKOL_UNREACHABLE() - a guard macro for unreachable code (default: assert(false))
        SOKOL_ABORT()       - called after an unrecoverable error (default: abort())
        SOKOL_WIN32_FORCE_MAIN  - define this on Win32 to use a main() entry point instead of WinMain
        SOKOL_NO_ENTRY      - define this if sokol_app.h shouldn't "hijack" the main() function
        SOKOL_API_DECL      - public function declaration prefix (default: extern)
        SOKOL_API_IMPL      - public function implementation prefix (default: -)
        SOKOL_CALLOC        - your own calloc function (default: calloc(n, s))
        SOKOL_FREE          - your own free function (default: free(p))

    Optionally define the following to force debug checks and validations
    even in release mode:

        SOKOL_DEBUG         - by default this is defined if _DEBUG is defined

    If sokol_app.h is compiled as a DLL, define the following before
    including the declaration or implementation:

        SOKOL_DLL

    On Windows, SOKOL_DLL will define SOKOL_API_DECL as __declspec(dllexport)
    or __declspec(dllimport) as needed.

    If you use sokol_app.h together with sokol_gfx.h, include both headers
    in the implementation source file, and include sokol_app.h before
    sokol_gfx.h since sokol_app.h will also include the required 3D-API
    headers.

    On Windows, a minimal 'GL header' and function loader is integrated which
    contains just enough of GL for sokol_gfx.h. If you want to use your own
    GL header-generator/loader instead, define SOKOL_WIN32_NO_GL_LOADER
    before including the implementation part of sokol_app.h.

    To make use of the integrated GL loader, simply include the sokol_app.h
    implementation before the sokol_gfx.h implementation.

    For example code, see https://github.com/floooh/sokol-samples/tree/master/sapp

    Portions of the Windows and Linux GL initialization and event code have been
    taken from GLFW (http://www.glfw.org/)

    iOS onscreen keyboard support 'inspired' by libgdx.

    Link with the following system libraries:

    - on macOS with Metal: Cocoa, QuartzCore, Metal, MetalKit
    - on macOS with GL: Cocoa, QuartzCore, OpenGL
    - on iOS with Metal: UIKit, Metal, MetalKit
    - on iOS with GL: UIKit, OpenGLES, GLKit
    - on Linux: X11, Xi, Xcursor, GL, dl, pthread, m(?)
    - on Android: GLESv3, EGL, log, android
    - on Windows: no action needed, libs are defined in-source via pragma-comment-lib

    On Linux, you also need to use the -pthread compiler and linker option, otherwise weird
    things will happen, see here for details: https://github.com/floooh/sokol/issues/376

    Building for UWP requires a recent Visual Studio toolchain and Windows SDK
    (at least VS2019 and Windows SDK 10.0.19041.0). When the UWP backend is
    selected, the sokol_app.h implementation must be compiled as C++17.

    On macOS and iOS, the implementation must be compiled as Objective-C.

    FEATURE OVERVIEW
    ================
    sokol_app.h provides a minimalistic cross-platform API which
    implements the 'application-wrapper' parts of a 3D application:

    - a common application entry function
    - creates a window and 3D-API context/device with a 'default framebuffer'
    - makes the rendered frame visible
    - provides keyboard-, mouse- and low-level touch-events
    - platforms: MacOS, iOS, HTML5, Win32, Linux, Android (TODO: RaspberryPi)
    - 3D-APIs: Metal, D3D11, GL3.2, GLES2, GLES3, WebGL, WebGL2

    FEATURE/PLATFORM MATRIX
    =======================
                        | Windows | macOS | Linux |  iOS  | Android | UWP  | Raspi | HTML5
    --------------------+---------+-------+-------+-------+---------+------+-------+-------
    gl 3.x              | YES     | YES   | YES   | ---   | ---     | ---  | ---   | ---
    gles2/webgl         | ---     | ---   | ---   | YES   | YES     | ---  | TODO  | YES
    gles3/webgl2        | ---     | ---   | ---   | YES   | YES     | ---  | ---   | YES
    metal               | ---     | YES   | ---   | YES   | ---     | ---  | ---   | ---
    d3d11               | YES     | ---   | ---   | ---   | ---     | YES  | ---   | ---
    KEY_DOWN            | YES     | YES   | YES   | SOME  | TODO    | YES  | TODO  | YES
    KEY_UP              | YES     | YES   | YES   | SOME  | TODO    | YES  | TODO  | YES
    CHAR                | YES     | YES   | YES   | YES   | TODO    | YES  | TODO  | YES
    MOUSE_DOWN          | YES     | YES   | YES   | ---   | ---     | YES  | TODO  | YES
    MOUSE_UP            | YES     | YES   | YES   | ---   | ---     | YES  | TODO  | YES
    MOUSE_SCROLL        | YES     | YES   | YES   | ---   | ---     | YES  | TODO  | YES
    MOUSE_MOVE          | YES     | YES   | YES   | ---   | ---     | YES  | TODO  | YES
    MOUSE_ENTER         | YES     | YES   | YES   | ---   | ---     | YES  | TODO  | YES
    MOUSE_LEAVE         | YES     | YES   | YES   | ---   | ---     | YES  | TODO  | YES
    TOUCHES_BEGAN       | ---     | ---   | ---   | YES   | YES     | TODO | ---   | YES
    TOUCHES_MOVED       | ---     | ---   | ---   | YES   | YES     | TODO | ---   | YES
    TOUCHES_ENDED       | ---     | ---   | ---   | YES   | YES     | TODO | ---   | YES
    TOUCHES_CANCELLED   | ---     | ---   | ---   | YES   | YES     | TODO | ---   | YES
    RESIZED             | YES     | YES   | YES   | YES   | YES     | YES  | ---   | YES
    ICONIFIED           | YES     | YES   | YES   | ---   | ---     | YES  | ---   | ---
    RESTORED            | YES     | YES   | YES   | ---   | ---     | YES  | ---   | ---
    SUSPENDED           | ---     | ---   | ---   | YES   | YES     | YES  | ---   | TODO
    RESUMED             | ---     | ---   | ---   | YES   | YES     | YES  | ---   | TODO
    QUIT_REQUESTED      | YES     | YES   | YES   | ---   | ---     | ---  | TODO  | YES
    UPDATE_CURSOR       | YES     | YES   | TODO  | ---   | ---     | TODO | ---   | TODO
    IME                 | TODO    | TODO? | TODO  | ???   | TODO    | ---  | ???   | ???
    key repeat flag     | YES     | YES   | YES   | ---   | ---     | YES  | TODO  | YES
    windowed            | YES     | YES   | YES   | ---   | ---     | YES  | TODO  | YES
    fullscreen          | YES     | YES   | YES   | YES   | YES     | YES  | TODO  | ---
    mouse hide          | YES     | YES   | YES   | ---   | ---     | YES  | TODO  | TODO
    mouse lock          | YES     | YES   | YES   | ---   | ---     | TODO | TODO  | YES
    screen keyboard     | ---     | ---   | ---   | YES   | TODO    | TODO | ---   | YES
    swap interval       | YES     | YES   | YES   | YES   | TODO    | ---  | TODO  | YES
    high-dpi            | YES     | YES   | TODO  | YES   | YES     | YES  | TODO  | YES
    clipboard           | YES     | YES   | TODO  | ---   | ---     | TODO | ---   | YES
    MSAA                | YES     | YES   | YES   | YES   | YES     | TODO | TODO  | YES
    drag'n'drop         | YES     | YES   | YES   | ---   | ---     | TODO | TODO  | YES

    TODO
    ====
    - Linux:
        - clipboard support
    - UWP:
        - clipboard, mouselock
    - sapp_consume_event() on non-web platforms?

    STEP BY STEP
    ============
    --- Add a sokol_main() function to your code which returns a sapp_desc structure
        with initialization parameters and callback function pointers. This
        function is called very early, usually at the start of the
        platform's entry function (e.g. main or WinMain). You should do as
        little as possible here, since the rest of your code might be called
        from another thread (this depends on the platform):

            sapp_desc sokol_main(int argc, char* argv[]) {
                return (sapp_desc) {
                    .width = 640,
                    .height = 480,
                    .init_cb = my_init_func,
                    .frame_cb = my_frame_func,
                    .cleanup_cb = my_cleanup_func,
                    .event_cb = my_event_func,
                    ...
                };
            }

        There are many more setup parameters, but these are the most important.
        For a complete list search for the sapp_desc structure declaration
        below.

        DO NOT call any sokol-app function from inside sokol_main(), since
        sokol-app will not be initialized at this point.

        The .width and .height parameters are the preferred size of the 3D
        rendering canvas. The actual size may differ from this depending on
        platform and other circumstances. Also the canvas size may change at
        any time (for instance when the user resizes the application window,
        or rotates the mobile device).

        All provided function callbacks will be called from the same thread,
        but this may be different from the thread where sokol_main() was called.

        .init_cb (void (*)(void))
            This function is called once after the application window,
            3D rendering context and swap chain have been created. The
            function takes no arguments and has no return value.
        .frame_cb (void (*)(void))
            This is the per-frame callback, which is usually called 60
            times per second. This is where your application would update
            most of its state and perform all rendering.
        .cleanup_cb (void (*)(void))
            The cleanup callback is called once right before the application
            quits.
        .event_cb (void (*)(const sapp_event* event))
            The event callback is mainly for input handling, but is also
            used to communicate other types of events to the application. Keep the
            event_cb struct member zero-initialized if your application doesn't require
            event handling.
        .fail_cb (void (*)(const char* msg))
            The fail callback is called when a fatal error is encountered
            during start which doesn't allow the program to continue.
            Providing a callback here gives you a chance to show an error message
            to the user. The default behaviour is SOKOL_LOG(msg)

        As you can see, those 'standard callbacks' don't have a user_data
        argument, so any data that needs to be preserved between callbacks
        must live in global variables. If keeping state in global variables
        is not an option, there's an alternative set of callbacks with
        an additional user_data pointer argument:

        .user_data (void*)
            The user-data argument for the callbacks below
        .init_userdata_cb (void (*)(void* user_data))
        .frame_userdata_cb (void (*)(void* user_data))
        .cleanup_userdata_cb (void (*)(void* user_data))
        .event_cb (void(*)(const sapp_event* event, void* user_data))
        .fail_cb (void(*)(const char* msg, void* user_data))
            These are the user-data versions of the callback functions. You
            can mix those with the standard callbacks that don't have the
            user_data argument.

        The function sapp_userdata() can be used to query the user_data
        pointer provided in the sapp_desc struct.

        You can also call sapp_query_desc() to get a copy of the
        original sapp_desc structure.

        NOTE that there's also an alternative compile mode where sokol_app.h
        doesn't "hijack" the main() function. Search below for SOKOL_NO_ENTRY.

    --- Implement the initialization callback function (init_cb), this is called
        once after the rendering surface, 3D API and swap chain have been
        initialized by sokol_app. All sokol-app functions can be called
        from inside the initialization callback, the most useful functions
        at this point are:

        int sapp_width(void)
        int sapp_height(void)
            Returns the current width and height of the default framebuffer in pixels,
            this may change from one frame to the next, and it may be different
            from the initial size provided in the sapp_desc struct.

        int sapp_color_format(void)
        int sapp_depth_format(void)
            The color and depth-stencil pixelformats of the default framebuffer,
            as integer values which are compatible with sokol-gfx's
            sg_pixel_format enum (so that they can be plugged directly in places
            where sg_pixel_format is expected). Possible values are:

                23 == SG_PIXELFORMAT_RGBA8
                27 == SG_PIXELFORMAT_BGRA8
                41 == SG_PIXELFORMAT_DEPTH
                42 == SG_PIXELFORMAT_DEPTH_STENCIL

        int sapp_sample_count(void)
            Return the MSAA sample count of the default framebuffer.

        bool sapp_gles2(void)
            Returns true if a GLES2 or WebGL context has been created. This
            is useful when a GLES3/WebGL2 context was requested but is not
            available so that sokol_app.h had to fallback to GLES2/WebGL.

        const void* sapp_metal_get_device(void)
        const void* sapp_metal_get_renderpass_descriptor(void)
        const void* sapp_metal_get_drawable(void)
            If the Metal backend has been selected, these functions return pointers
            to various Metal API objects required for rendering, otherwise
            they return a null pointer. These void pointers are actually
            Objective-C ids converted with a (ARC) __bridge cast so that
            the ids can be tunnel through C code. Also note that the returned
            pointers to the renderpass-descriptor and drawable may change from one
            frame to the next, only the Metal device object is guaranteed to
            stay the same.

        const void* sapp_macos_get_window(void)
            On macOS, get the NSWindow object pointer, otherwise a null pointer.
            Before being used as Objective-C object, the void* must be converted
            back with a (ARC) __bridge cast.

        const void* sapp_ios_get_window(void)
            On iOS, get the UIWindow object pointer, otherwise a null pointer.
            Before being used as Objective-C object, the void* must be converted
            back with a (ARC) __bridge cast.

        const void* sapp_win32_get_hwnd(void)
            On Windows, get the window's HWND, otherwise a null pointer. The
            HWND has been cast to a void pointer in order to be tunneled
            through code which doesn't include Windows.h.

        const void* sapp_d3d11_get_device(void)
        const void* sapp_d3d11_get_device_context(void)
        const void* sapp_d3d11_get_render_target_view(void)
        const void* sapp_d3d11_get_depth_stencil_view(void)
            Similar to the sapp_metal_* functions, the sapp_d3d11_* functions
            return pointers to D3D11 API objects required for rendering,
            only if the D3D11 backend has been selected. Otherwise they
            return a null pointer. Note that the returned pointers to the
            render-target-view and depth-stencil-view may change from one
            frame to the next!

        const void* sapp_wgpu_get_device(void)
        const void* sapp_wgpu_get_render_view(void)
        const void* sapp_wgpu_get_resolve_view(void)
        const void* sapp_wgpu_get_depth_stencil_view(void)
            These are the WebGPU-specific functions to get the WebGPU
            objects and values required for rendering. If sokol_app.h
            is not compiled with SOKOL_WGPU, these functions return null.

        const void* sapp_android_get_native_activity(void);
            On Android, get the native activity ANativeActivity pointer, otherwise
            a null pointer.

    --- Implement the frame-callback function, this function will be called
        on the same thread as the init callback, but might be on a different
        thread than the sokol_main() function. Note that the size of
        the rendering framebuffer might have changed since the frame callback
        was called last. Call the functions sapp_width() and sapp_height()
        each frame to get the current size.

    --- Optionally implement the event-callback to handle input events.
        sokol-app provides the following type of input events:
            - a 'virtual key' was pressed down or released
            - a single text character was entered (provided as UTF-32 code point)
            - a mouse button was pressed down or released (left, right, middle)
            - mouse-wheel or 2D scrolling events
            - the mouse was moved
            - the mouse has entered or left the application window boundaries
            - low-level, portable multi-touch events (began, moved, ended, cancelled)
            - the application window was resized, iconified or restored
            - the application was suspended or restored (on mobile platforms)
            - the user or application code has asked to quit the application
            - a string was pasted to the system clipboard

        To explicitly 'consume' an event and prevent that the event is
        forwarded for further handling to the operating system, call
        sapp_consume_event() from inside the event handler (NOTE that
        this behaviour is currently only implemented for some HTML5
        events, support for other platforms and event types will
        be added as needed, please open a github ticket and/or provide
        a PR if needed).

        NOTE: Do *not* call any 3D API rendering functions in the event
        callback function, since the 3D API context may not be active when the
        event callback is called (it may work on some platforms and 3D APIs,
        but not others, and the exact behaviour may change between
        sokol-app versions).

    --- Implement the cleanup-callback function, this is called once
        after the user quits the application (see the section
        "APPLICATION QUIT" for detailed information on quitting
        behaviour, and how to intercept a pending quit - for instance to show a
        "Really Quit?" dialog box). Note that the cleanup-callback isn't
        guaranteed to be called on the web and mobile platforms.

    MOUSE LOCK (AKA POINTER LOCK, AKA MOUSE CAPTURE)
    ================================================
    In normal mouse mode, no mouse movement events are reported when the
    mouse leaves the windows client area or hits the screen border (whether
    it's one or the other depends on the platform), and the mouse move events
    (SAPP_EVENTTYPE_MOUSE_MOVE) contain absolute mouse positions in
    framebuffer pixels in the sapp_event items mouse_x and mouse_y, and
    relative movement in framebuffer pixels in the sapp_event items mouse_dx
    and mouse_dy.

    To get continuous mouse movement (also when the mouse leaves the window
    client area or hits the screen border), activate mouse-lock mode
    by calling:

        sapp_lock_mouse(true)

    When mouse lock is activated, the mouse pointer is hidden, the
    reported absolute mouse position (sapp_event.mouse_x/y) appears
    frozen, and the relative mouse movement in sapp_event.mouse_dx/dy
    no longer has a direct relation to framebuffer pixels but instead
    uses "raw mouse input" (what "raw mouse input" exactly means also
    differs by platform).

    To deactivate mouse lock and return to normal mouse mode, call

        sapp_lock_mouse(false)

    And finally, to check if mouse lock is currently active, call

        if (sapp_mouse_locked()) { ... }

    On native platforms, the sapp_lock_mouse() and sapp_mouse_locked()
    functions work as expected (mouse lock is activated or deactivated
    immediately when sapp_lock_mouse() is called, and sapp_mouse_locked()
    also immediately returns the new state after sapp_lock_mouse()
    is called.

    On the web platform, sapp_lock_mouse() and sapp_mouse_locked() behave
    differently, as dictated by the limitations of the HTML5 Pointer Lock API:

        - sapp_lock_mouse(true) can be called at any time, but it will
          only take effect in a 'short-lived input event handler of a specific
          type', meaning when one of the following events happens:
            - SAPP_EVENTTYPE_MOUSE_DOWN
            - SAPP_EVENTTYPE_MOUSE_UP
            - SAPP_EVENTTYPE_MOUSE_SCROLL
            - SAPP_EVENTYTPE_KEY_UP
            - SAPP_EVENTTYPE_KEY_DOWN
        - The mouse lock/unlock action on the web platform is asynchronous,
          this means that sapp_mouse_locked() won't immediately return
          the new status after calling sapp_lock_mouse(), instead the
          reported status will only change when the pointer lock has actually
          been activated or deactivated in the browser.
        - On the web, mouse lock can be deactivated by the user at any time
          by pressing the Esc key. When this happens, sokol_app.h behaves
          the same as if sapp_lock_mouse(false) is called.

    For things like camera manipulation it's most straightforward to lock
    and unlock the mouse right from the sokol_app.h event handler, for
    instance the following code enters and leaves mouse lock when the
    left mouse button is pressed and released, and then uses the relative
    movement information to manipulate a camera (taken from the
    cgltf-sapp.c sample in the sokol-samples repository
    at https://github.com/floooh/sokol-samples):

        static void input(const sapp_event* ev) {
            switch (ev->type) {
                case SAPP_EVENTTYPE_MOUSE_DOWN:
                    if (ev->mouse_button == SAPP_MOUSEBUTTON_LEFT) {
                        sapp_lock_mouse(true);
                    }
                    break;

                case SAPP_EVENTTYPE_MOUSE_UP:
                    if (ev->mouse_button == SAPP_MOUSEBUTTON_LEFT) {
                        sapp_lock_mouse(false);
                    }
                    break;

                case SAPP_EVENTTYPE_MOUSE_MOVE:
                    if (sapp_mouse_locked()) {
                        cam_orbit(&state.camera, ev->mouse_dx * 0.25f, ev->mouse_dy * 0.25f);
                    }
                    break;

                default:
                    break;
            }
        }

    CLIPBOARD SUPPORT
    =================
    Applications can send and receive UTF-8 encoded text data from and to the
    system clipboard. By default, clipboard support is disabled and
    must be enabled at startup via the following sapp_desc struct
    members:

        sapp_desc.enable_clipboard  - set to true to enable clipboard support
        sapp_desc.clipboard_size    - size of the internal clipboard buffer in bytes

    Enabling the clipboard will dynamically allocate a clipboard buffer
    for UTF-8 encoded text data of the requested size in bytes, the default
    size is 8 KBytes. Strings that don't fit into the clipboard buffer
    (including the terminating zero) will be silently clipped, so it's
    important that you provide a big enough clipboard size for your
    use case.

    To send data to the clipboard, call sapp_set_clipboard_string() with
    a pointer to an UTF-8 encoded, null-terminated C-string.

    NOTE that on the HTML5 platform, sapp_set_clipboard_string() must be
    called from inside a 'short-lived event handler', and there are a few
    other HTML5-specific caveats to workaround. You'll basically have to
    tinker until it works in all browsers :/ (maybe the situation will
    improve when all browsers agree on and implement the new
    HTML5 navigator.clipboard API).

    To get data from the clipboard, check for the SAPP_EVENTTYPE_CLIPBOARD_PASTED
    event in your event handler function, and then call sapp_get_clipboard_string()
    to obtain the pasted UTF-8 encoded text.

    NOTE that behaviour of sapp_get_clipboard_string() is slightly different
    depending on platform:

        - on the HTML5 platform, the internal clipboard buffer will only be updated
          right before the SAPP_EVENTTYPE_CLIPBOARD_PASTED event is sent,
          and sapp_get_clipboard_string() will simply return the current content
          of the clipboard buffer
        - on 'native' platforms, the call to sapp_get_clipboard_string() will
          update the internal clipboard buffer with the most recent data
          from the system clipboard

    Portable code should check for the SAPP_EVENTTYPE_CLIPBOARD_PASTED event,
    and then call sapp_get_clipboard_string() right in the event handler.

    The SAPP_EVENTTYPE_CLIPBOARD_PASTED event will be generated by sokol-app
    as follows:

        - on macOS: when the Cmd+V key is pressed down
        - on HTML5: when the browser sends a 'paste' event to the global 'window' object
        - on all other platforms: when the Ctrl+V key is pressed down

    DRAG AND DROP SUPPORT
    =====================
    PLEASE NOTE: the drag'n'drop feature works differently on WASM/HTML5
    and on the native desktop platforms (Win32, Linux and macOS) because
    of security-related restrictions in the HTML5 drag'n'drop API. The
    WASM/HTML5 specifics are described at the end of this documentation
    section:

    Like clipboard support, drag'n'drop support must be explicitly enabled
    at startup in the sapp_desc struct.

        sapp_desc sokol_main() {
            return (sapp_desc) {
                .enable_dragndrop = true,   // default is false
                ...
            };
        }

    You can also adjust the maximum number of files that are accepted
    in a drop operation, and the maximum path length in bytes if needed:

        sapp_desc sokol_main() {
            return (sapp_desc) {
                .enable_dragndrop = true,               // default is false
                .max_dropped_files = 8,                 // default is 1
                .max_dropped_file_path_length = 8192,   // in bytes, default is 2048
                ...
            };
        }

    When drag'n'drop is enabled, the event callback will be invoked with an
    event of type SAPP_EVENTTYPE_FILES_DROPPED whenever the user drops files on
    the application window.

    After the SAPP_EVENTTYPE_FILES_DROPPED is received, you can query the
    number of dropped files, and their absolute paths by calling separate
    functions:

        void on_event(const sapp_event* ev) {
            if (ev->type == SAPP_EVENTTYPE_FILES_DROPPED) {

                // the mouse position where the drop happened
                float x = ev->mouse_x;
                float y = ev->mouse_y;

                // get the number of files and their paths like this:
                const int num_dropped_files = sapp_get_num_dropped_files();
                for (int i = 0; i < num_dropped_files; i++) {
                    const char* path = sapp_get_dropped_file_path(i);
                    ...
                }
            }
        }

    The returned file paths are UTF-8 encoded strings.

    You can call sapp_get_num_dropped_files() and sapp_get_dropped_file_path()
    anywhere, also outside the event handler callback, but be aware that the
    file path strings will be overwritten with the next drop operation.

    In any case, sapp_get_dropped_file_path() will never return a null pointer,
    instead an empty string "" will be returned if the drag'n'drop feature
    hasn't been enabled, the last drop-operation failed, or the file path index
    is out of range.

    Drag'n'drop caveats:

        - if more files are dropped in a single drop-action
          than sapp_desc.max_dropped_files, the additional
          files will be silently ignored
        - if any of the file paths is longer than
          sapp_desc.max_dropped_file_path_length (in number of bytes, after UTF-8
          encoding) the entire drop operation will be silently ignored (this
          needs some sort of error feedback in the future)
        - no mouse positions are reported while the drag is in
          process, this may change in the future

    Drag'n'drop on HTML5/WASM:

    The HTML5 drag'n'drop API doesn't return file paths, but instead
    black-box 'file objects' which must be used to load the content
    of dropped files. This is the reason why sokol_app.h adds two
    HTML5-specific functions to the drag'n'drop API:

        uint32_t sapp_html5_get_dropped_file_size(int index)
            Returns the size in bytes of a dropped file.

        void sapp_html5_fetch_dropped_file(const sapp_html5_fetch_request* request)
            Asynchronously loads the content of a dropped file into a
            provided memory buffer (which must be big enough to hold
            the file content)

    To start loading the first dropped file after an SAPP_EVENTTYPE_FILES_DROPPED
    event is received:

        sapp_html5_fetch_dropped_file(&(sapp_html5_fetch_request){
            .dropped_file_index = 0,
            .callback = fetch_cb
            .buffer_ptr = buf,
            .buffer_size = buf_size,
            .user_data = ...
        });

    Make sure that the memory pointed to by 'buf' stays valid until the
    callback function is called!

    As result of the asynchronous loading operation (no matter if succeeded or
    failed) the 'fetch_cb' function will be called:

        void fetch_cb(const sapp_html5_fetch_response* response) {
            // IMPORTANT: check if the loading operation actually succeeded:
            if (response->succeeded) {
                // the size of the loaded file:
                const uint32_t num_bytes = response->fetched_size;
                // and the pointer to the data (same as 'buf' in the fetch-call):
                const void* ptr = response->buffer_ptr;
            }
            else {
                // on error check the error code:
                switch (response->error_code) {
                    case SAPP_HTML5_FETCH_ERROR_BUFFER_TOO_SMALL:
                        ...
                        break;
                    case SAPP_HTML5_FETCH_ERROR_OTHER:
                        ...
                        break;
                }
            }
        }

    Check the droptest-sapp example for a real-world example which works
    both on native platforms and the web:

    https://github.com/floooh/sokol-samples/blob/master/sapp/droptest-sapp.c

    HIGH-DPI RENDERING
    ==================
    You can set the sapp_desc.high_dpi flag during initialization to request
    a full-resolution framebuffer on HighDPI displays. The default behaviour
    is sapp_desc.high_dpi=false, this means that the application will
    render to a lower-resolution framebuffer on HighDPI displays and the
    rendered content will be upscaled by the window system composer.

    In a HighDPI scenario, you still request the same window size during
    sokol_main(), but the framebuffer sizes returned by sapp_width()
    and sapp_height() will be scaled up according to the DPI scaling
    ratio. You can also get a DPI scaling factor with the function
    sapp_dpi_scale().

    Here's an example on a Mac with Retina display:

    sapp_desc sokol_main() {
        return (sapp_desc) {
            .width = 640,
            .height = 480,
            .high_dpi = true,
            ...
        };
    }

    The functions sapp_width(), sapp_height() and sapp_dpi_scale() will
    return the following values:

    sapp_width      -> 1280
    sapp_height     -> 960
    sapp_dpi_scale  -> 2.0

    If the high_dpi flag is false, or you're not running on a Retina display,
    the values would be:

    sapp_width      -> 640
    sapp_height     -> 480
    sapp_dpi_scale  -> 1.0

    APPLICATION QUIT
    ================
    Without special quit handling, a sokol_app.h application will quit
    'gracefully' when the user clicks the window close-button unless a
    platform's application model prevents this (e.g. on web or mobile).
    'Graceful exit' means that the application-provided cleanup callback will
    be called before the application quits.

    On native desktop platforms sokol_app.h provides more control over the
    application-quit-process. It's possible to initiate a 'programmatic quit'
    from the application code, and a quit initiated by the application user can
    be intercepted (for instance to show a custom dialog box).

    This 'programmatic quit protocol' is implemented trough 3 functions
    and 1 event:

        - sapp_quit(): This function simply quits the application without
          giving the user a chance to intervene. Usually this might
          be called when the user clicks the 'Ok' button in a 'Really Quit?'
          dialog box
        - sapp_request_quit(): Calling sapp_request_quit() will send the
          event SAPP_EVENTTYPE_QUIT_REQUESTED to the applications event handler
          callback, giving the user code a chance to intervene and cancel the
          pending quit process (for instance to show a 'Really Quit?' dialog
          box). If the event handler callback does nothing, the application
          will be quit as usual. To prevent this, call the function
          sapp_cancel_quit() from inside the event handler.
        - sapp_cancel_quit(): Cancels a pending quit request, either initiated
          by the user clicking the window close button, or programmatically
          by calling sapp_request_quit(). The only place where calling this
          function makes sense is from inside the event handler callback when
          the SAPP_EVENTTYPE_QUIT_REQUESTED event has been received.
        - SAPP_EVENTTYPE_QUIT_REQUESTED: this event is sent when the user
          clicks the window's close button or application code calls the
          sapp_request_quit() function. The event handler callback code can handle
          this event by calling sapp_cancel_quit() to cancel the quit.
          If the event is ignored, the application will quit as usual.

    On the web platform, the quit behaviour differs from native platforms,
    because of web-specific restrictions:

    A `programmatic quit` initiated by calling sapp_quit() or
    sapp_request_quit() will work as described above: the cleanup callback is
    called, platform-specific cleanup is performed (on the web
    this means that JS event handlers are unregisters), and then
    the request-animation-loop will be exited. However that's all. The
    web page itself will continue to exist (e.g. it's not possible to
    programmatically close the browser tab).

    On the web it's also not possible to run custom code when the user
    closes a brower tab, so it's not possible to prevent this with a
    fancy custom dialog box.

    Instead the standard "Leave Site?" dialog box can be activated (or
    deactivated) with the following function:

        sapp_html5_ask_leave_site(bool ask);

    The initial state of the associated internal flag can be provided
    at startup via sapp_desc.html5_ask_leave_site.

    This feature should only be used sparingly in critical situations - for
    instance when the user would loose data - since popping up modal dialog
    boxes is considered quite rude in the web world. Note that there's no way
    to customize the content of this dialog box or run any code as a result
    of the user's decision. Also note that the user must have interacted with
    the site before the dialog box will appear. These are all security measures
    to prevent fishing.

    The Dear ImGui HighDPI sample contains example code of how to
    implement a 'Really Quit?' dialog box with Dear ImGui (native desktop
    platforms only), and for showing the hardwired "Leave Site?" dialog box
    when running on the web platform:

        https://floooh.github.io/sokol-html5/wasm/imgui-highdpi-sapp.html

    FULLSCREEN
    ==========
    If the sapp_desc.fullscreen flag is true, sokol-app will try to create
    a fullscreen window on platforms with a 'proper' window system
    (mobile devices will always use fullscreen). The implementation details
    depend on the target platform, in general sokol-app will use a
    'soft approach' which doesn't interfere too much with the platform's
    window system (for instance borderless fullscreen window instead of
    a 'real' fullscreen mode). Such details might change over time
    as sokol-app is adapted for different needs.

    The most important effect of fullscreen mode to keep in mind is that
    the requested canvas width and height will be ignored for the initial
    window size, calling sapp_width() and sapp_height() will instead return
    the resolution of the fullscreen canvas (however the provided size
    might still be used for the non-fullscreen window, in case the user can
    switch back from fullscreen- to windowed-mode).

    To toggle fullscreen mode programmatically, call sapp_toggle_fullscreen().

    To check if the application window is currently in fullscreen mode,
    call sapp_is_fullscreen().

    ONSCREEN KEYBOARD
    =================
    On some platforms which don't provide a physical keyboard, sokol-app
    can display the platform's integrated onscreen keyboard for text
    input. To request that the onscreen keyboard is shown, call

        sapp_show_keyboard(true);

    Likewise, to hide the keyboard call:

        sapp_show_keyboard(false);

    Note that on the web platform, the keyboard can only be shown from
    inside an input handler. On such platforms, sapp_show_keyboard()
    will only work as expected when it is called from inside the
    sokol-app event callback function. When called from other places,
    an internal flag will be set, and the onscreen keyboard will be
    called at the next 'legal' opportunity (when the next input event
    is handled).

    OPTIONAL: DON'T HIJACK main() (#define SOKOL_NO_ENTRY)
    ======================================================
    In its default configuration, sokol_app.h "hijacks" the platform's
    standard main() function. This was done because different platforms
    have different main functions which are not compatible with
    C's main() (for instance WinMain on Windows has completely different
    arguments). However, this "main hijacking" posed a problem for
    usage scenarios like integrating sokol_app.h with other languages than
    C or C++, so an alternative SOKOL_NO_ENTRY mode has been added
    in which the user code provides the platform's main function:

    - define SOKOL_NO_ENTRY before including the sokol_app.h implementation
    - do *not* provide a sokol_main() function
    - instead provide the standard main() function of the platform
    - from the main function, call the function ```sapp_run()``` which
      takes a pointer to an ```sapp_desc``` structure.
    - ```sapp_run()``` takes over control and calls the provided init-, frame-,
      shutdown- and event-callbacks just like in the default model, it
      will only return when the application quits (or not at all on some
      platforms, like emscripten)

    NOTE: SOKOL_NO_ENTRY is currently not supported on Android.

    TEMP NOTE DUMP
    ==============
    - onscreen keyboard support on Android requires Java :(, should we even bother?
    - sapp_desc needs a bool whether to initialize depth-stencil surface
    - GL context initialization needs more control (at least what GL version to initialize)
    - application icon
    - the UPDATE_CURSOR event currently behaves differently between Win32 and OSX
      (Win32 sends the event each frame when the mouse moves and is inside the window
      client area, OSX sends it only once when the mouse enters the client area)
    - the Android implementation calls cleanup_cb() and destroys the egl context in onDestroy
      at the latest but should do it earlier, in onStop, as an app is "killable" after onStop
      on Android Honeycomb and later (it can't be done at the moment as the app may be started
      again after onStop and the sokol lifecycle does not yet handle context teardown/bringup)


    LICENSE
    =======
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
enum SOKOL_APP_INCLUDED = 1;

enum
{
    SAPP_MAX_TOUCHPOINTS = 8,
    SAPP_MAX_MOUSEBUTTONS = 3,
    SAPP_MAX_KEYCODES = 512
}


enum sapp_event_type
{
    SAPP_EVENTTYPE_INVALID = 0,
    SAPP_EVENTTYPE_KEY_DOWN = 1,
    SAPP_EVENTTYPE_KEY_UP = 2,
    SAPP_EVENTTYPE_CHAR = 3,
    SAPP_EVENTTYPE_MOUSE_DOWN = 4,
    SAPP_EVENTTYPE_MOUSE_UP = 5,
    SAPP_EVENTTYPE_MOUSE_SCROLL = 6,
    SAPP_EVENTTYPE_MOUSE_MOVE = 7,
    SAPP_EVENTTYPE_MOUSE_ENTER = 8,
    SAPP_EVENTTYPE_MOUSE_LEAVE = 9,
    SAPP_EVENTTYPE_TOUCHES_BEGAN = 10,
    SAPP_EVENTTYPE_TOUCHES_MOVED = 11,
    SAPP_EVENTTYPE_TOUCHES_ENDED = 12,
    SAPP_EVENTTYPE_TOUCHES_CANCELLED = 13,
    SAPP_EVENTTYPE_RESIZED = 14,
    SAPP_EVENTTYPE_ICONIFIED = 15,
    SAPP_EVENTTYPE_RESTORED = 16,
    SAPP_EVENTTYPE_SUSPENDED = 17,
    SAPP_EVENTTYPE_RESUMED = 18,
    SAPP_EVENTTYPE_UPDATE_CURSOR = 19,
    SAPP_EVENTTYPE_QUIT_REQUESTED = 20,
    SAPP_EVENTTYPE_CLIPBOARD_PASTED = 21,
    SAPP_EVENTTYPE_FILES_DROPPED = 22,
    _SAPP_EVENTTYPE_NUM = 23,
    _SAPP_EVENTTYPE_FORCE_U32 = 0x7FFFFFFF
}

alias SAPP_EVENTTYPE_INVALID = sapp_event_type.SAPP_EVENTTYPE_INVALID;
alias SAPP_EVENTTYPE_KEY_DOWN = sapp_event_type.SAPP_EVENTTYPE_KEY_DOWN;
alias SAPP_EVENTTYPE_KEY_UP = sapp_event_type.SAPP_EVENTTYPE_KEY_UP;
alias SAPP_EVENTTYPE_CHAR = sapp_event_type.SAPP_EVENTTYPE_CHAR;
alias SAPP_EVENTTYPE_MOUSE_DOWN = sapp_event_type.SAPP_EVENTTYPE_MOUSE_DOWN;
alias SAPP_EVENTTYPE_MOUSE_UP = sapp_event_type.SAPP_EVENTTYPE_MOUSE_UP;
alias SAPP_EVENTTYPE_MOUSE_SCROLL = sapp_event_type.SAPP_EVENTTYPE_MOUSE_SCROLL;
alias SAPP_EVENTTYPE_MOUSE_MOVE = sapp_event_type.SAPP_EVENTTYPE_MOUSE_MOVE;
alias SAPP_EVENTTYPE_MOUSE_ENTER = sapp_event_type.SAPP_EVENTTYPE_MOUSE_ENTER;
alias SAPP_EVENTTYPE_MOUSE_LEAVE = sapp_event_type.SAPP_EVENTTYPE_MOUSE_LEAVE;
alias SAPP_EVENTTYPE_TOUCHES_BEGAN = sapp_event_type.SAPP_EVENTTYPE_TOUCHES_BEGAN;
alias SAPP_EVENTTYPE_TOUCHES_MOVED = sapp_event_type.SAPP_EVENTTYPE_TOUCHES_MOVED;
alias SAPP_EVENTTYPE_TOUCHES_ENDED = sapp_event_type.SAPP_EVENTTYPE_TOUCHES_ENDED;
alias SAPP_EVENTTYPE_TOUCHES_CANCELLED = sapp_event_type.SAPP_EVENTTYPE_TOUCHES_CANCELLED;
alias SAPP_EVENTTYPE_RESIZED = sapp_event_type.SAPP_EVENTTYPE_RESIZED;
alias SAPP_EVENTTYPE_ICONIFIED = sapp_event_type.SAPP_EVENTTYPE_ICONIFIED;
alias SAPP_EVENTTYPE_RESTORED = sapp_event_type.SAPP_EVENTTYPE_RESTORED;
alias SAPP_EVENTTYPE_SUSPENDED = sapp_event_type.SAPP_EVENTTYPE_SUSPENDED;
alias SAPP_EVENTTYPE_RESUMED = sapp_event_type.SAPP_EVENTTYPE_RESUMED;
alias SAPP_EVENTTYPE_UPDATE_CURSOR = sapp_event_type.SAPP_EVENTTYPE_UPDATE_CURSOR;
alias SAPP_EVENTTYPE_QUIT_REQUESTED = sapp_event_type.SAPP_EVENTTYPE_QUIT_REQUESTED;
alias SAPP_EVENTTYPE_CLIPBOARD_PASTED = sapp_event_type.SAPP_EVENTTYPE_CLIPBOARD_PASTED;
alias SAPP_EVENTTYPE_FILES_DROPPED = sapp_event_type.SAPP_EVENTTYPE_FILES_DROPPED;
alias _SAPP_EVENTTYPE_NUM = sapp_event_type._SAPP_EVENTTYPE_NUM;
alias _SAPP_EVENTTYPE_FORCE_U32 = sapp_event_type._SAPP_EVENTTYPE_FORCE_U32;

/* key codes are the same names and values as GLFW */
enum sapp_keycode
{
    SAPP_KEYCODE_INVALID = 0,
    SAPP_KEYCODE_SPACE = 32,
    SAPP_KEYCODE_APOSTROPHE = 39, /* ' */
    SAPP_KEYCODE_COMMA = 44, /* , */
    SAPP_KEYCODE_MINUS = 45, /* - */
    SAPP_KEYCODE_PERIOD = 46, /* . */
    SAPP_KEYCODE_SLASH = 47, /* / */
    SAPP_KEYCODE_0 = 48,
    SAPP_KEYCODE_1 = 49,
    SAPP_KEYCODE_2 = 50,
    SAPP_KEYCODE_3 = 51,
    SAPP_KEYCODE_4 = 52,
    SAPP_KEYCODE_5 = 53,
    SAPP_KEYCODE_6 = 54,
    SAPP_KEYCODE_7 = 55,
    SAPP_KEYCODE_8 = 56,
    SAPP_KEYCODE_9 = 57,
    SAPP_KEYCODE_SEMICOLON = 59, /* ; */
    SAPP_KEYCODE_EQUAL = 61, /* = */
    SAPP_KEYCODE_A = 65,
    SAPP_KEYCODE_B = 66,
    SAPP_KEYCODE_C = 67,
    SAPP_KEYCODE_D = 68,
    SAPP_KEYCODE_E = 69,
    SAPP_KEYCODE_F = 70,
    SAPP_KEYCODE_G = 71,
    SAPP_KEYCODE_H = 72,
    SAPP_KEYCODE_I = 73,
    SAPP_KEYCODE_J = 74,
    SAPP_KEYCODE_K = 75,
    SAPP_KEYCODE_L = 76,
    SAPP_KEYCODE_M = 77,
    SAPP_KEYCODE_N = 78,
    SAPP_KEYCODE_O = 79,
    SAPP_KEYCODE_P = 80,
    SAPP_KEYCODE_Q = 81,
    SAPP_KEYCODE_R = 82,
    SAPP_KEYCODE_S = 83,
    SAPP_KEYCODE_T = 84,
    SAPP_KEYCODE_U = 85,
    SAPP_KEYCODE_V = 86,
    SAPP_KEYCODE_W = 87,
    SAPP_KEYCODE_X = 88,
    SAPP_KEYCODE_Y = 89,
    SAPP_KEYCODE_Z = 90,
    SAPP_KEYCODE_LEFT_BRACKET = 91, /* [ */
    SAPP_KEYCODE_BACKSLASH = 92, /* \ */
    SAPP_KEYCODE_RIGHT_BRACKET = 93, /* ] */
    SAPP_KEYCODE_GRAVE_ACCENT = 96, /* ` */
    SAPP_KEYCODE_WORLD_1 = 161, /* non-US #1 */
    SAPP_KEYCODE_WORLD_2 = 162, /* non-US #2 */
    SAPP_KEYCODE_ESCAPE = 256,
    SAPP_KEYCODE_ENTER = 257,
    SAPP_KEYCODE_TAB = 258,
    SAPP_KEYCODE_BACKSPACE = 259,
    SAPP_KEYCODE_INSERT = 260,
    SAPP_KEYCODE_DELETE = 261,
    SAPP_KEYCODE_RIGHT = 262,
    SAPP_KEYCODE_LEFT = 263,
    SAPP_KEYCODE_DOWN = 264,
    SAPP_KEYCODE_UP = 265,
    SAPP_KEYCODE_PAGE_UP = 266,
    SAPP_KEYCODE_PAGE_DOWN = 267,
    SAPP_KEYCODE_HOME = 268,
    SAPP_KEYCODE_END = 269,
    SAPP_KEYCODE_CAPS_LOCK = 280,
    SAPP_KEYCODE_SCROLL_LOCK = 281,
    SAPP_KEYCODE_NUM_LOCK = 282,
    SAPP_KEYCODE_PRINT_SCREEN = 283,
    SAPP_KEYCODE_PAUSE = 284,
    SAPP_KEYCODE_F1 = 290,
    SAPP_KEYCODE_F2 = 291,
    SAPP_KEYCODE_F3 = 292,
    SAPP_KEYCODE_F4 = 293,
    SAPP_KEYCODE_F5 = 294,
    SAPP_KEYCODE_F6 = 295,
    SAPP_KEYCODE_F7 = 296,
    SAPP_KEYCODE_F8 = 297,
    SAPP_KEYCODE_F9 = 298,
    SAPP_KEYCODE_F10 = 299,
    SAPP_KEYCODE_F11 = 300,
    SAPP_KEYCODE_F12 = 301,
    SAPP_KEYCODE_F13 = 302,
    SAPP_KEYCODE_F14 = 303,
    SAPP_KEYCODE_F15 = 304,
    SAPP_KEYCODE_F16 = 305,
    SAPP_KEYCODE_F17 = 306,
    SAPP_KEYCODE_F18 = 307,
    SAPP_KEYCODE_F19 = 308,
    SAPP_KEYCODE_F20 = 309,
    SAPP_KEYCODE_F21 = 310,
    SAPP_KEYCODE_F22 = 311,
    SAPP_KEYCODE_F23 = 312,
    SAPP_KEYCODE_F24 = 313,
    SAPP_KEYCODE_F25 = 314,
    SAPP_KEYCODE_KP_0 = 320,
    SAPP_KEYCODE_KP_1 = 321,
    SAPP_KEYCODE_KP_2 = 322,
    SAPP_KEYCODE_KP_3 = 323,
    SAPP_KEYCODE_KP_4 = 324,
    SAPP_KEYCODE_KP_5 = 325,
    SAPP_KEYCODE_KP_6 = 326,
    SAPP_KEYCODE_KP_7 = 327,
    SAPP_KEYCODE_KP_8 = 328,
    SAPP_KEYCODE_KP_9 = 329,
    SAPP_KEYCODE_KP_DECIMAL = 330,
    SAPP_KEYCODE_KP_DIVIDE = 331,
    SAPP_KEYCODE_KP_MULTIPLY = 332,
    SAPP_KEYCODE_KP_SUBTRACT = 333,
    SAPP_KEYCODE_KP_ADD = 334,
    SAPP_KEYCODE_KP_ENTER = 335,
    SAPP_KEYCODE_KP_EQUAL = 336,
    SAPP_KEYCODE_LEFT_SHIFT = 340,
    SAPP_KEYCODE_LEFT_CONTROL = 341,
    SAPP_KEYCODE_LEFT_ALT = 342,
    SAPP_KEYCODE_LEFT_SUPER = 343,
    SAPP_KEYCODE_RIGHT_SHIFT = 344,
    SAPP_KEYCODE_RIGHT_CONTROL = 345,
    SAPP_KEYCODE_RIGHT_ALT = 346,
    SAPP_KEYCODE_RIGHT_SUPER = 347,
    SAPP_KEYCODE_MENU = 348
}

alias SAPP_KEYCODE_INVALID = sapp_keycode.SAPP_KEYCODE_INVALID;
alias SAPP_KEYCODE_SPACE = sapp_keycode.SAPP_KEYCODE_SPACE;
alias SAPP_KEYCODE_APOSTROPHE = sapp_keycode.SAPP_KEYCODE_APOSTROPHE;
alias SAPP_KEYCODE_COMMA = sapp_keycode.SAPP_KEYCODE_COMMA;
alias SAPP_KEYCODE_MINUS = sapp_keycode.SAPP_KEYCODE_MINUS;
alias SAPP_KEYCODE_PERIOD = sapp_keycode.SAPP_KEYCODE_PERIOD;
alias SAPP_KEYCODE_SLASH = sapp_keycode.SAPP_KEYCODE_SLASH;
alias SAPP_KEYCODE_0 = sapp_keycode.SAPP_KEYCODE_0;
alias SAPP_KEYCODE_1 = sapp_keycode.SAPP_KEYCODE_1;
alias SAPP_KEYCODE_2 = sapp_keycode.SAPP_KEYCODE_2;
alias SAPP_KEYCODE_3 = sapp_keycode.SAPP_KEYCODE_3;
alias SAPP_KEYCODE_4 = sapp_keycode.SAPP_KEYCODE_4;
alias SAPP_KEYCODE_5 = sapp_keycode.SAPP_KEYCODE_5;
alias SAPP_KEYCODE_6 = sapp_keycode.SAPP_KEYCODE_6;
alias SAPP_KEYCODE_7 = sapp_keycode.SAPP_KEYCODE_7;
alias SAPP_KEYCODE_8 = sapp_keycode.SAPP_KEYCODE_8;
alias SAPP_KEYCODE_9 = sapp_keycode.SAPP_KEYCODE_9;
alias SAPP_KEYCODE_SEMICOLON = sapp_keycode.SAPP_KEYCODE_SEMICOLON;
alias SAPP_KEYCODE_EQUAL = sapp_keycode.SAPP_KEYCODE_EQUAL;
alias SAPP_KEYCODE_A = sapp_keycode.SAPP_KEYCODE_A;
alias SAPP_KEYCODE_B = sapp_keycode.SAPP_KEYCODE_B;
alias SAPP_KEYCODE_C = sapp_keycode.SAPP_KEYCODE_C;
alias SAPP_KEYCODE_D = sapp_keycode.SAPP_KEYCODE_D;
alias SAPP_KEYCODE_E = sapp_keycode.SAPP_KEYCODE_E;
alias SAPP_KEYCODE_F = sapp_keycode.SAPP_KEYCODE_F;
alias SAPP_KEYCODE_G = sapp_keycode.SAPP_KEYCODE_G;
alias SAPP_KEYCODE_H = sapp_keycode.SAPP_KEYCODE_H;
alias SAPP_KEYCODE_I = sapp_keycode.SAPP_KEYCODE_I;
alias SAPP_KEYCODE_J = sapp_keycode.SAPP_KEYCODE_J;
alias SAPP_KEYCODE_K = sapp_keycode.SAPP_KEYCODE_K;
alias SAPP_KEYCODE_L = sapp_keycode.SAPP_KEYCODE_L;
alias SAPP_KEYCODE_M = sapp_keycode.SAPP_KEYCODE_M;
alias SAPP_KEYCODE_N = sapp_keycode.SAPP_KEYCODE_N;
alias SAPP_KEYCODE_O = sapp_keycode.SAPP_KEYCODE_O;
alias SAPP_KEYCODE_P = sapp_keycode.SAPP_KEYCODE_P;
alias SAPP_KEYCODE_Q = sapp_keycode.SAPP_KEYCODE_Q;
alias SAPP_KEYCODE_R = sapp_keycode.SAPP_KEYCODE_R;
alias SAPP_KEYCODE_S = sapp_keycode.SAPP_KEYCODE_S;
alias SAPP_KEYCODE_T = sapp_keycode.SAPP_KEYCODE_T;
alias SAPP_KEYCODE_U = sapp_keycode.SAPP_KEYCODE_U;
alias SAPP_KEYCODE_V = sapp_keycode.SAPP_KEYCODE_V;
alias SAPP_KEYCODE_W = sapp_keycode.SAPP_KEYCODE_W;
alias SAPP_KEYCODE_X = sapp_keycode.SAPP_KEYCODE_X;
alias SAPP_KEYCODE_Y = sapp_keycode.SAPP_KEYCODE_Y;
alias SAPP_KEYCODE_Z = sapp_keycode.SAPP_KEYCODE_Z;
alias SAPP_KEYCODE_LEFT_BRACKET = sapp_keycode.SAPP_KEYCODE_LEFT_BRACKET;
alias SAPP_KEYCODE_BACKSLASH = sapp_keycode.SAPP_KEYCODE_BACKSLASH;
alias SAPP_KEYCODE_RIGHT_BRACKET = sapp_keycode.SAPP_KEYCODE_RIGHT_BRACKET;
alias SAPP_KEYCODE_GRAVE_ACCENT = sapp_keycode.SAPP_KEYCODE_GRAVE_ACCENT;
alias SAPP_KEYCODE_WORLD_1 = sapp_keycode.SAPP_KEYCODE_WORLD_1;
alias SAPP_KEYCODE_WORLD_2 = sapp_keycode.SAPP_KEYCODE_WORLD_2;
alias SAPP_KEYCODE_ESCAPE = sapp_keycode.SAPP_KEYCODE_ESCAPE;
alias SAPP_KEYCODE_ENTER = sapp_keycode.SAPP_KEYCODE_ENTER;
alias SAPP_KEYCODE_TAB = sapp_keycode.SAPP_KEYCODE_TAB;
alias SAPP_KEYCODE_BACKSPACE = sapp_keycode.SAPP_KEYCODE_BACKSPACE;
alias SAPP_KEYCODE_INSERT = sapp_keycode.SAPP_KEYCODE_INSERT;
alias SAPP_KEYCODE_DELETE = sapp_keycode.SAPP_KEYCODE_DELETE;
alias SAPP_KEYCODE_RIGHT = sapp_keycode.SAPP_KEYCODE_RIGHT;
alias SAPP_KEYCODE_LEFT = sapp_keycode.SAPP_KEYCODE_LEFT;
alias SAPP_KEYCODE_DOWN = sapp_keycode.SAPP_KEYCODE_DOWN;
alias SAPP_KEYCODE_UP = sapp_keycode.SAPP_KEYCODE_UP;
alias SAPP_KEYCODE_PAGE_UP = sapp_keycode.SAPP_KEYCODE_PAGE_UP;
alias SAPP_KEYCODE_PAGE_DOWN = sapp_keycode.SAPP_KEYCODE_PAGE_DOWN;
alias SAPP_KEYCODE_HOME = sapp_keycode.SAPP_KEYCODE_HOME;
alias SAPP_KEYCODE_END = sapp_keycode.SAPP_KEYCODE_END;
alias SAPP_KEYCODE_CAPS_LOCK = sapp_keycode.SAPP_KEYCODE_CAPS_LOCK;
alias SAPP_KEYCODE_SCROLL_LOCK = sapp_keycode.SAPP_KEYCODE_SCROLL_LOCK;
alias SAPP_KEYCODE_NUM_LOCK = sapp_keycode.SAPP_KEYCODE_NUM_LOCK;
alias SAPP_KEYCODE_PRINT_SCREEN = sapp_keycode.SAPP_KEYCODE_PRINT_SCREEN;
alias SAPP_KEYCODE_PAUSE = sapp_keycode.SAPP_KEYCODE_PAUSE;
alias SAPP_KEYCODE_F1 = sapp_keycode.SAPP_KEYCODE_F1;
alias SAPP_KEYCODE_F2 = sapp_keycode.SAPP_KEYCODE_F2;
alias SAPP_KEYCODE_F3 = sapp_keycode.SAPP_KEYCODE_F3;
alias SAPP_KEYCODE_F4 = sapp_keycode.SAPP_KEYCODE_F4;
alias SAPP_KEYCODE_F5 = sapp_keycode.SAPP_KEYCODE_F5;
alias SAPP_KEYCODE_F6 = sapp_keycode.SAPP_KEYCODE_F6;
alias SAPP_KEYCODE_F7 = sapp_keycode.SAPP_KEYCODE_F7;
alias SAPP_KEYCODE_F8 = sapp_keycode.SAPP_KEYCODE_F8;
alias SAPP_KEYCODE_F9 = sapp_keycode.SAPP_KEYCODE_F9;
alias SAPP_KEYCODE_F10 = sapp_keycode.SAPP_KEYCODE_F10;
alias SAPP_KEYCODE_F11 = sapp_keycode.SAPP_KEYCODE_F11;
alias SAPP_KEYCODE_F12 = sapp_keycode.SAPP_KEYCODE_F12;
alias SAPP_KEYCODE_F13 = sapp_keycode.SAPP_KEYCODE_F13;
alias SAPP_KEYCODE_F14 = sapp_keycode.SAPP_KEYCODE_F14;
alias SAPP_KEYCODE_F15 = sapp_keycode.SAPP_KEYCODE_F15;
alias SAPP_KEYCODE_F16 = sapp_keycode.SAPP_KEYCODE_F16;
alias SAPP_KEYCODE_F17 = sapp_keycode.SAPP_KEYCODE_F17;
alias SAPP_KEYCODE_F18 = sapp_keycode.SAPP_KEYCODE_F18;
alias SAPP_KEYCODE_F19 = sapp_keycode.SAPP_KEYCODE_F19;
alias SAPP_KEYCODE_F20 = sapp_keycode.SAPP_KEYCODE_F20;
alias SAPP_KEYCODE_F21 = sapp_keycode.SAPP_KEYCODE_F21;
alias SAPP_KEYCODE_F22 = sapp_keycode.SAPP_KEYCODE_F22;
alias SAPP_KEYCODE_F23 = sapp_keycode.SAPP_KEYCODE_F23;
alias SAPP_KEYCODE_F24 = sapp_keycode.SAPP_KEYCODE_F24;
alias SAPP_KEYCODE_F25 = sapp_keycode.SAPP_KEYCODE_F25;
alias SAPP_KEYCODE_KP_0 = sapp_keycode.SAPP_KEYCODE_KP_0;
alias SAPP_KEYCODE_KP_1 = sapp_keycode.SAPP_KEYCODE_KP_1;
alias SAPP_KEYCODE_KP_2 = sapp_keycode.SAPP_KEYCODE_KP_2;
alias SAPP_KEYCODE_KP_3 = sapp_keycode.SAPP_KEYCODE_KP_3;
alias SAPP_KEYCODE_KP_4 = sapp_keycode.SAPP_KEYCODE_KP_4;
alias SAPP_KEYCODE_KP_5 = sapp_keycode.SAPP_KEYCODE_KP_5;
alias SAPP_KEYCODE_KP_6 = sapp_keycode.SAPP_KEYCODE_KP_6;
alias SAPP_KEYCODE_KP_7 = sapp_keycode.SAPP_KEYCODE_KP_7;
alias SAPP_KEYCODE_KP_8 = sapp_keycode.SAPP_KEYCODE_KP_8;
alias SAPP_KEYCODE_KP_9 = sapp_keycode.SAPP_KEYCODE_KP_9;
alias SAPP_KEYCODE_KP_DECIMAL = sapp_keycode.SAPP_KEYCODE_KP_DECIMAL;
alias SAPP_KEYCODE_KP_DIVIDE = sapp_keycode.SAPP_KEYCODE_KP_DIVIDE;
alias SAPP_KEYCODE_KP_MULTIPLY = sapp_keycode.SAPP_KEYCODE_KP_MULTIPLY;
alias SAPP_KEYCODE_KP_SUBTRACT = sapp_keycode.SAPP_KEYCODE_KP_SUBTRACT;
alias SAPP_KEYCODE_KP_ADD = sapp_keycode.SAPP_KEYCODE_KP_ADD;
alias SAPP_KEYCODE_KP_ENTER = sapp_keycode.SAPP_KEYCODE_KP_ENTER;
alias SAPP_KEYCODE_KP_EQUAL = sapp_keycode.SAPP_KEYCODE_KP_EQUAL;
alias SAPP_KEYCODE_LEFT_SHIFT = sapp_keycode.SAPP_KEYCODE_LEFT_SHIFT;
alias SAPP_KEYCODE_LEFT_CONTROL = sapp_keycode.SAPP_KEYCODE_LEFT_CONTROL;
alias SAPP_KEYCODE_LEFT_ALT = sapp_keycode.SAPP_KEYCODE_LEFT_ALT;
alias SAPP_KEYCODE_LEFT_SUPER = sapp_keycode.SAPP_KEYCODE_LEFT_SUPER;
alias SAPP_KEYCODE_RIGHT_SHIFT = sapp_keycode.SAPP_KEYCODE_RIGHT_SHIFT;
alias SAPP_KEYCODE_RIGHT_CONTROL = sapp_keycode.SAPP_KEYCODE_RIGHT_CONTROL;
alias SAPP_KEYCODE_RIGHT_ALT = sapp_keycode.SAPP_KEYCODE_RIGHT_ALT;
alias SAPP_KEYCODE_RIGHT_SUPER = sapp_keycode.SAPP_KEYCODE_RIGHT_SUPER;
alias SAPP_KEYCODE_MENU = sapp_keycode.SAPP_KEYCODE_MENU;

struct sapp_touchpoint
{
    uintptr_t identifier;
    float pos_x;
    float pos_y;
    bool changed;
}

enum sapp_mousebutton
{
    SAPP_MOUSEBUTTON_INVALID = -1,
    SAPP_MOUSEBUTTON_LEFT = 0,
    SAPP_MOUSEBUTTON_RIGHT = 1,
    SAPP_MOUSEBUTTON_MIDDLE = 2
}

alias SAPP_MOUSEBUTTON_INVALID = sapp_mousebutton.SAPP_MOUSEBUTTON_INVALID;
alias SAPP_MOUSEBUTTON_LEFT = sapp_mousebutton.SAPP_MOUSEBUTTON_LEFT;
alias SAPP_MOUSEBUTTON_RIGHT = sapp_mousebutton.SAPP_MOUSEBUTTON_RIGHT;
alias SAPP_MOUSEBUTTON_MIDDLE = sapp_mousebutton.SAPP_MOUSEBUTTON_MIDDLE;

enum
{
    SAPP_MODIFIER_SHIFT = 1 << 0,
    SAPP_MODIFIER_CTRL = 1 << 1,
    SAPP_MODIFIER_ALT = 1 << 2,
    SAPP_MODIFIER_SUPER = 1 << 3
}


struct sapp_event
{
    ulong frame_count;
    sapp_event_type type;
    sapp_keycode key_code;
    uint char_code;
    bool key_repeat;
    uint modifiers;
    sapp_mousebutton mouse_button;
    float mouse_x;
    float mouse_y;
    float mouse_dx;
    float mouse_dy;
    float scroll_x;
    float scroll_y;
    int num_touches;
    sapp_touchpoint[SAPP_MAX_TOUCHPOINTS] touches;
    int window_width;
    int window_height;
    int framebuffer_width;
    int framebuffer_height;
}

struct sapp_desc
{
    void function () init_cb; /* these are the user-provided callbacks without user data */
    void function () frame_cb;
    void function () cleanup_cb;
    void function (const(sapp_event)*) event_cb;
    void function (const(char)*) fail_cb;

    void* user_data; /* these are the user-provided callbacks with user data */
    void function (void*) init_userdata_cb;
    void function (void*) frame_userdata_cb;
    void function (void*) cleanup_userdata_cb;
    void function (const(sapp_event)*, void*) event_userdata_cb;
    void function (const(char)*, void*) fail_userdata_cb;

    int width; /* the preferred width of the window / canvas */
    int height; /* the preferred height of the window / canvas */
    int sample_count; /* MSAA sample count */
    int swap_interval; /* the preferred swap interval (ignored on some platforms) */
    bool high_dpi; /* whether the rendering canvas is full-resolution on HighDPI displays */
    bool fullscreen; /* whether the window should be created in fullscreen mode */
    bool alpha; /* whether the framebuffer should have an alpha channel (ignored on some platforms) */
    const(char)* window_title; /* the window title as UTF-8 encoded string */
    bool user_cursor; /* if true, user is expected to manage cursor image in SAPP_EVENTTYPE_UPDATE_CURSOR */
    bool enable_clipboard; /* enable clipboard access, default is false */
    int clipboard_size; /* max size of clipboard content in bytes */
    bool enable_dragndrop; /* enable file dropping (drag'n'drop), default is false */
    int max_dropped_files; /* max number of dropped files to process (default: 1) */
    int max_dropped_file_path_length; /* max length in bytes of a dropped UTF-8 file path (default: 2048) */

    const(char)* html5_canvas_name; /* the name (id) of the HTML5 canvas element, default is "canvas" */
    bool html5_canvas_resize; /* if true, the HTML5 canvas size is set to sapp_desc.width/height, otherwise canvas size is tracked */
    bool html5_preserve_drawing_buffer; /* HTML5 only: whether to preserve default framebuffer content between frames */
    bool html5_premultiplied_alpha; /* HTML5 only: whether the rendered pixels use premultiplied alpha convention */
    bool html5_ask_leave_site; /* initial state of the internal html5_ask_leave_site flag (see sapp_html5_ask_leave_site()) */
    bool ios_keyboard_resizes_canvas; /* if true, showing the iOS keyboard shrinks the canvas */
    bool gl_force_gles2; /* if true, setup GLES2/WebGL even if GLES3/WebGL2 is available */
}

/* HTML5 specific: request and response structs for
   asynchronously loading dropped-file content.
*/
enum sapp_html5_fetch_error
{
    SAPP_HTML5_FETCH_ERROR_NO_ERROR = 0,
    SAPP_HTML5_FETCH_ERROR_BUFFER_TOO_SMALL = 1,
    SAPP_HTML5_FETCH_ERROR_OTHER = 2
}

alias SAPP_HTML5_FETCH_ERROR_NO_ERROR = sapp_html5_fetch_error.SAPP_HTML5_FETCH_ERROR_NO_ERROR;
alias SAPP_HTML5_FETCH_ERROR_BUFFER_TOO_SMALL = sapp_html5_fetch_error.SAPP_HTML5_FETCH_ERROR_BUFFER_TOO_SMALL;
alias SAPP_HTML5_FETCH_ERROR_OTHER = sapp_html5_fetch_error.SAPP_HTML5_FETCH_ERROR_OTHER;

struct sapp_html5_fetch_response
{
    bool succeeded; /* true if the loading operation has succeeded */
    sapp_html5_fetch_error error_code;
    int file_index; /* index of the dropped file (0..sapp_get_num_dropped_filed()-1) */
    uint fetched_size; /* size in bytes of loaded data */
    void* buffer_ptr; /* pointer to user-provided buffer which contains the loaded data */
    uint buffer_size; /* size of user-provided buffer (buffer_size >= fetched_size) */
    void* user_data; /* user-provided user data pointer */
}

alias sapp_html5_fetch_callback = void function (const(sapp_html5_fetch_response)*);

struct sapp_html5_fetch_request
{
    int dropped_file_index; /* 0..sapp_get_num_dropped_files()-1 */
    sapp_html5_fetch_callback callback; /* response callback function pointer (required) */
    void* buffer_ptr; /* pointer to buffer to load data into */
    uint buffer_size; /* size in bytes of buffer */
    void* user_data; /* optional userdata pointer */
}

/* user-provided functions */
sapp_desc sokol_main (int argc, char** argv);

/* returns true after sokol-app has been initialized */
bool sapp_isvalid ();
/* returns the current framebuffer width in pixels */
int sapp_width ();
/* returns the current framebuffer height in pixels */
int sapp_height ();
/* get default framebuffer color pixel format */
int sapp_color_format ();
/* get default framebuffer depth pixel format */
int sapp_depth_format ();
/* get default framebuffer sample count */
int sapp_sample_count ();
/* returns true when high_dpi was requested and actually running in a high-dpi scenario */
bool sapp_high_dpi ();
/* returns the dpi scaling factor (window pixels to framebuffer pixels) */
float sapp_dpi_scale ();
/* show or hide the mobile device onscreen keyboard */
void sapp_show_keyboard (bool show);
/* return true if the mobile device onscreen keyboard is currently shown */
bool sapp_keyboard_shown ();
/* query fullscreen mode */
bool sapp_is_fullscreen ();
/* toggle fullscreen mode */
void sapp_toggle_fullscreen ();
/* show or hide the mouse cursor */
void sapp_show_mouse (bool show);
/* show or hide the mouse cursor */
bool sapp_mouse_shown ();
/* enable/disable mouse-pointer-lock mode */
void sapp_lock_mouse (bool lock);
/* return true if in mouse-pointer-lock mode (this may toggle a few frames later) */
bool sapp_mouse_locked ();
/* return the userdata pointer optionally provided in sapp_desc */
void* sapp_userdata ();
/* return a copy of the sapp_desc structure */
sapp_desc sapp_query_desc ();
/* initiate a "soft quit" (sends SAPP_EVENTTYPE_QUIT_REQUESTED) */
void sapp_request_quit ();
/* cancel a pending quit (when SAPP_EVENTTYPE_QUIT_REQUESTED has been received) */
void sapp_cancel_quit ();
/* initiate a "hard quit" (quit application without sending SAPP_EVENTTYPE_QUIT_REQUSTED) */
void sapp_quit ();
/* call from inside event callback to consume the current event (don't forward to platform) */
void sapp_consume_event ();
/* get the current frame counter (for comparison with sapp_event.frame_count) */
ulong sapp_frame_count ();
/* write string into clipboard */
void sapp_set_clipboard_string (const(char)* str);
/* read string from clipboard (usually during SAPP_EVENTTYPE_CLIPBOARD_PASTED) */
const(char)* sapp_get_clipboard_string ();
/* set the window title (only on desktop platforms) */
void sapp_set_window_title (const(char)* str);
/* gets the total number of dropped files (after an SAPP_EVENTTYPE_FILES_DROPPED event) */
int sapp_get_num_dropped_files ();
/* gets the dropped file paths */
const(char)* sapp_get_dropped_file_path (int index);

/* special run-function for SOKOL_NO_ENTRY (in standard mode this is an empty stub) */
int sapp_run (const(sapp_desc)* desc);

/* GL: return true when GLES2 fallback is active (to detect fallback from GLES3) */
bool sapp_gles2 ();

/* HTML5: enable or disable the hardwired "Leave Site?" dialog box */
void sapp_html5_ask_leave_site (bool ask);
/* HTML5: get byte size of a dropped file */
uint sapp_html5_get_dropped_file_size (int index);
/* HTML5: asynchronously load the content of a dropped file */
void sapp_html5_fetch_dropped_file (const(sapp_html5_fetch_request)* request);

/* Metal: get bridged pointer to Metal device object */
const(void)* sapp_metal_get_device ();
/* Metal: get bridged pointer to this frame's renderpass descriptor */
const(void)* sapp_metal_get_renderpass_descriptor ();
/* Metal: get bridged pointer to current drawable */
const(void)* sapp_metal_get_drawable ();
/* macOS: get bridged pointer to macOS NSWindow */
const(void)* sapp_macos_get_window ();
/* iOS: get bridged pointer to iOS UIWindow */
const(void)* sapp_ios_get_window ();

/* D3D11: get pointer to ID3D11Device object */
const(void)* sapp_d3d11_get_device ();
/* D3D11: get pointer to ID3D11DeviceContext object */
const(void)* sapp_d3d11_get_device_context ();
/* D3D11: get pointer to ID3D11RenderTargetView object */
const(void)* sapp_d3d11_get_render_target_view ();
/* D3D11: get pointer to ID3D11DepthStencilView */
const(void)* sapp_d3d11_get_depth_stencil_view ();
/* Win32: get the HWND window handle */
const(void)* sapp_win32_get_hwnd ();

/* WebGPU: get WGPUDevice handle */
const(void)* sapp_wgpu_get_device ();
/* WebGPU: get swapchain's WGPUTextureView handle for rendering */
const(void)* sapp_wgpu_get_render_view ();
/* WebGPU: get swapchain's MSAA-resolve WGPUTextureView (may return null) */
const(void)* sapp_wgpu_get_resolve_view ();
/* WebGPU: get swapchain's WGPUTextureView for the depth-stencil surface */
const(void)* sapp_wgpu_get_depth_stencil_view ();

/* Android: get native activity handle */
const(void)* sapp_android_get_native_activity ();

/* extern "C" */

/* reference-based equivalents for C++ */

// this WinRT specific hack is required when wWinMain is in a static library

// SOKOL_APP_INCLUDED

/*-- IMPLEMENTATION ----------------------------------------------------------*/

/* memset */

/* check if the config defines are alright */

// see https://clang.llvm.org/docs/LanguageExtensions.html#automatic-reference-counting

/* MacOS */

/* iOS or iOS Simulator */

/* emscripten (asm.js or wasm) */

/* Windows (D3D11 or GL) */

/* Android */

/* Linux */

/*== PLATFORM SPECIFIC INCLUDES AND DEFINES ==================================*/

/* nonstandard extension used: nameless struct/union */
/* nonstandard extension used: non-constant aggregate initializer */
/* 'type cast': from function pointer */
/* 'type cast': from data pointer */
/* unreferenced local function has been removed */
/* /W4: 'ID3D11ModuleInstance': named type definition in parentheses (in d3d11.h) */

/* CommandLineToArgvW, DragQueryFileW, DragFinished */

// DXGI_SWAP_EFFECT_FLIP_DISCARD is only defined in newer Windows SDKs, so don't depend on it

/* see https://github.com/floooh/sokol/issues/138 */

/* nonstandard extension used: nameless struct/union */
/* 'type cast': from function pointer */
/* 'type cast': from data pointer */
/* unreferenced local function has been removed */
/* /W4: 'ID3D11ModuleInstance': named type definition in parentheses (in d3d11.h) */

/* CARD32 */

/* dlopen, dlsym, dlclose */
/* LONG_MAX */

/*== MACOS DECLARATIONS ======================================================*/

// SOKOL_GLCORE33

// _SAPP_MACOS

/*== IOS DECLARATIONS ========================================================*/

// _SAPP_IOS

/*== EMSCRIPTEN DECLARATIONS =================================================*/

// _SAPP_EMSCRIPTEN

/*== WIN32 DECLARATIONS ======================================================*/

/*== WIN32 DECLARATIONS ======================================================*/

/*DPI_ENUMS_DECLARED*/

// SOKOL_GLCORE33

// _SAPP_WIN32

/*== UWP DECLARATIONS ======================================================*/

// _SAPP_UWP

/*== ANDROID DECLARATIONS ====================================================*/

// _SAPP_ANDROID

/*== LINUX DECLARATIONS ======================================================*/

// GLX 1.3 functions

// GLX 1.4 and extension functions

// extension availability

// _SAPP_LINUX

/*== COMMON DECLARATIONS =====================================================*/

/* helper macros */

/* NOTE: the pixel format values *must* be compatible with sg_pixel_format */

// this is ARC compatible

/* UTF-8 */
/* UTF-32 or UCS-2 */

/*=== OPTIONAL MINI GL LOADER FOR WIN32/WGL ==================================*/

// X Macro list of GL function names and signatures

// generate GL function pointer typedefs

// generate GL function pointers

// helper function to lookup GL functions in GL DLL

// populate GL function pointers

// _SAPP_WIN32 && SOKOL_GLCORE33 && !SOKOL_WIN32_NO_GL_LOADER

/*=== PRIVATE HELPER FUNCTIONS ===============================================*/

/* Copy a string into a fixed size buffer with guaranteed zero-
   termination.

   Return false if the string didn't fit into the buffer and had to be clamped.

   FIXME: Currently UTF-8 strings might become invalid if the string
   is clamped, because the last zero-byte might be written into
   the middle of a multi-byte sequence.
*/

/* truncated? */

/* only send events when an event callback is set, and the init function was called */

/*== MacOS/iOS ===============================================================*/

/*== MacOS ===================================================================*/

// NOTE: it's safe to call [release] on a nil object

// NOTE: [NSApp run] never returns, instead cleanup code
// must be put into applicationWillTerminate

/* MacOS entry function */

/* SOKOL_NO_ENTRY */

/* NOTE: the _sapp.fullscreen flag is also notified by the
   windowDidEnterFullscreen / windowDidExitFullscreen
   event handlers
*/

/* don't update dx/dy in the very first update */

/* NOTE: this function is only called when the mouse visibility actually changes */

/*
    NOTE that this code doesn't warp the mouse cursor to the window
    center as everybody else does it. This lead to a spike in the
    *second* mouse-moved event after the warp happened. The
    mouse centering doesn't seem to be required (mouse-moved events
    are reported correctly even when the cursor is at an edge of the screen).

    NOTE also that the hide/show of the mouse cursor should properly
    stack with calls to sapp_show_mouse()
*/

// this is necessary for proper cleanup in applicationWillTerminate

/* on GL, this already toggles a rendered frame, so set the valid flag before */

/* only give user-code a chance to intervene when sapp_quit() wasn't already called */

/* if window should be closed and event handling is enabled, give user code
   a chance to intervene via sapp_cancel_quit()
*/

/* user code hasn't intervened, quit the app */

/* NOTE: this is a hack/fix when the initial window size has been clipped by
    macOS because it didn't fit on the screen, in that case the
    frame size of the window is reported wrong if low-dpi rendering
    was requested (instead the high-dpi dimensions are returned)
    until the window is resized for the first time.

    Hooking into reshape and getting the frame dimensions seems to report
    the correct dimensions.
*/

/* don't send mouse enter/leave while dragging (so that it behaves the same as
   on Windows while SetCapture is active
*/

/* NOTE: macOS doesn't send keyUp events while the Cmd key is pressed,
    as a workaround, to prevent key presses from sticking we'll send
    a keyup event following right after the keydown if SUPER is also pressed
*/

/* if this is a Cmd+V (paste), also send a CLIPBOARD_PASTE event */

/* MacOS */

/*== iOS =====================================================================*/

// NOTE: it's safe to call [release] on a nil object

/* iOS entry function */

/* SOKOL_NO_ENTRY */

/* if not happened yet, create an invisible text field */

/* setting the text field as first responder brings up the onscreen keyboard */

/* FIXME */

/* NOTE: this method will rarely ever be called, iOS application
    which are terminated by the user are usually killed via signal 9
    by the operating system.
*/

/* query the keyboard's size, and modify the content view's size */

/* this is for the case when the screen rotation changes while the keyboard is open */

/* ignore surrogates for now */

/* this was a backspace */

/* TARGET_OS_IPHONE */

/* _SAPP_APPLE */

/*== EMSCRIPTEN ==============================================================*/

/* this function is called from a JS event handler when the user hides
    the onscreen keyboard pressing the 'dismiss keyboard key'
*/

/*  https://developer.mozilla.org/en-US/docs/Web/API/WindowEventHandlers/onbeforeunload */

/* NOTE: name is only the filename part, not a path */

/* there was an error copying the filenames */

/* extern "C" */

/* Javascript helper functions for mobile virtual keyboard input */

// FIXME? see computation of targetX/targetY in emscripten via getClientBoundingRect

// SAPP_HTML5_FETCH_ERROR_BUFFER_TOO_SMALL

// SAPP_HTML5_FETCH_ERROR_OTHER

/* called from the emscripten event handler to update the keyboard visibility
    state, this must happen from an JS input event handler, otherwise
    the request will be ignored by the browser
*/

/* create input text field on demand */

/* focus the text input field, this will bring up the keyboard */

/* unfocus the text input field */

/* actually showing the onscreen keyboard must be initiated from a JS
    input event handler, so we'll just keep track of the desired
    state, and the actual state change will happen with the next input event
*/

// lookup and store canvas object by name

/* request mouse-lock during event handler invocation (see _sapp_emsc_update_mouse_lock_state) */

/* NOTE: the _sapp.mouse_locked state will be set in the pointerlockchange callback */

/* called from inside event handlers to check if mouse lock had been requested,
   and if yes, actually enter mouse lock.
*/

/* The above method might report zero when toggling HTML5 fullscreen,
   in that case use the window's inner width reported by the
   emscripten event. This works ok when toggling *into* fullscreen
   but doesn't properly restore the previous canvas size when switching
   back from fullscreen.

   In general, due to the HTML5's fullscreen API's flaky nature it is
   recommended to use 'soft fullscreen' (stretching the WebGL canvas
   over the browser windows client rect) with a CSS definition like this:

        position: absolute;
        top: 0px;
        left: 0px;
        margin: 0px;
        border: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
        display: block;
*/

/* on WebGPU: recreate size-dependent rendering surfaces */

/* mouse lock can only be activated in mouse button events (not in move, enter or leave) */

/* see https://github.com/floooh/sokol/issues/339 */

// FIXME: this is a guess
// shouldn't happen

/* workaround to make Cmd+V work on Safari */

/* Special hack for macOS: if the Super key is pressed, macOS doesn't
    send keyUp events. As a workaround, to prevent keys from
    "sticking", we'll send a keyup event following a keydown
    when the SUPER key is pressed
*/

/* only forward a certain key ranges to the browser */

/* consume the event */

/* forward key to browser */

/* consume event via sapp_consume_event() */

/* some WebGL extension are not enabled automatically by emscripten */

/* called when the asynchronous WebGPU device + swapchain init code in JS has finished */

// extern "C"

/* embedded JS function to handle all the asynchronous WebGPU setup */

// FIXME: the extension activation must be more clever here

/*
    on WebGPU, the emscripten frame callback will already be called while
    the asynchronous WebGPU device and swapchain initialization is still
    in progress
*/

/* async JS init hasn't finished yet */

/* perform post-async init stuff */

/* a regular frame */

/* WebGL code path */

/* quit-handling */

/* start the frame loop */

/* NOT A BUG: do not call _sapp_discard_state() here, instead this is
   called in _sapp_emsc_frame() when the application is ordered to quit
 */

/* SOKOL_NO_ENTRY */
/* _SAPP_EMSCRIPTEN */

/*== MISC GL SUPPORT FUNCTIONS ================================================*/

/* -1 means "don't care" */

/* Technically, several multisampling buffers could be
    involved, but that's a lower level implementation detail and
    not important to us here, so we count them as one
*/

/* These polynomials make many small channel size differences matter
    less than one large channel size difference
    Calculate color channel size difference value
*/

/* Calculate non-color channel size difference value */

/* Figure out if the current one is better than the best one found so far
    Least number of missing buffers is the most important heuristic,
    then color buffer size match and lastly size match for other buffers
*/

/*== WINDOWS DESKTOP and UWP====================================================*/

/* input string doesn't fit into destination buffer */

/* same as GLFW */

// _SAPP_WIN32 || _SAPP_UWP

/*== WINDOWS DESKTOP===========================================================*/

/* pAdapter (use default) */
/* DriverType */
/* Software */
/* Flags */
/* pFeatureLevels */
/* FeatureLevels */
/* SDKVersion */
/* pSwapChainDesc */
/* ppSwapChain */
/* ppDevice */
/* pFeatureLevel */
/* ppImmediateContext */

/* view for the swapchain-created framebuffer */

/* common desc for MSAA and depth-stencil texture */

/* create MSAA texture and view if antialiasing requested */

/* texture and view for the depth-stencil-surface */

/* do MSAA resolve if needed */

/* SOKOL_D3D11 */

/* FIXME: DwmIsCompositionEnabled() (see GLFW) */

/* FIXME: DwmIsCompositionEnabled? (see GLFW) */

/* SOKOL_GLCORE33 */

/* NOTE: this function is only called when the mouse visibility actually changes */

/* store the current mouse position, so it can be restored when unlocked */

/* while the mouse is locked, make the mouse cursor invisible and
   confine the mouse movement to a small rectangle inside our window
   (so that we dont miss any mouse up events)
*/

/* make the mouse cursor invisible, this will stack with sapp_show_mouse() */

/* enable raw input for mouse, starts sending WM_INPUT messages to WinProc (see GLFW) */

// usUsagePage: HID_USAGE_PAGE_GENERIC
// usUsage: HID_USAGE_GENERIC_MOUSE
// dwFlags
// hwndTarget

/* in case the raw mouse device only supports absolute position reporting,
   we need to skip the dx/dy compution for the first WM_INPUT event
*/

/* disable raw input for mouse */

/* let the mouse roam freely again */

/* restore the 'pre-locked' mouse position */

/* updates current window and framebuffer size from the window's client rect, returns true if size has changed */

/* prevent a framebuffer size of 0 when window is minimized */

/* check if a CLIPBOARD_PASTED event must be sent too */

/* only give user a chance to intervene when sapp_quit() wasn't already called */

/* if window should be closed and event handling is enabled, give user code
    a change to intervene via sapp_cancel_quit()
*/

/* if user code hasn't intervened, quit the app */

/* disable screen saver and blanking in fullscreen mode */

/* user trying to access menu via ALT */

/* don't update dx/dy in the very first event */

/* raw mouse input during mouse-lock */

/* mouse only reports absolute position
   NOTE: THIS IS UNTESTED, it's unclear from reading the
   Win32 RawInput docs under which circumstances absolute
   positions are sent.
*/

/* mouse reports movement delta (this seems to be the common case) */

/* NOTE: resizing the swap-chain during resize leads to a substantial
   memory spike (hundreds of megabytes for a few seconds).

if (_sapp_win32_update_dimensions()) {
    #if defined(SOKOL_D3D11)
    _sapp_d3d11_resize_default_render_target();
    #endif
    _sapp_win32_uwp_app_event(SAPP_EVENTTYPE_RESIZED);
}
*/

/* dwExStyle */
/* lpClassName */
/* lpWindowName */
/* dwStyle */
/* X */
/* Y */
/* nWidth */
/* nHeight */
/* hWndParent */
/* hMenu */
/* hInstance */
/* lParam */

/* if the app didn't request HighDPI rendering, let Windows do the upscaling */

/* get dpi scale factor for main monitor */

/* clamp window scale to an integer factor */

/* silently ignore any errors and just return the current
   content of the local clipboard buffer
*/

/* don't laugh, but this seems to be the easiest and most robust
   way to check if we're running on Win10

   From: https://github.com/videolan/vlc/blob/232fb13b0d6110c4d1b683cde24cf9a7f2c5c2ea/modules/video_output/win32/d3d11_swapchain.c#L263
*/

/* check for window resized, this cannot happen in WM_SIZE as it explodes memory usage */

/* SOKOL_WIN32_FORCE_MAIN */
/* SOKOL_NO_ENTRY */

/* _SAPP_WIN32 */

/*== UWP ================================================================*/

// Helper functions

/* NOTE: this function is only called when the mouse visibility actually changes */

// we need to figure out ourselves what mouse buttons have been pressed and released,
// because UWP doesn't properly send down/up mouse button events when multiple buttons
// are pressed down, so we also need to check the mouse button state in other mouse events
// to track what buttons have been pressed down and released
//

/* check if a CLIPBOARD_PASTED event must be sent too */

/* Empty namespace to ensure internal linkage (same as _SOKOL_PRIVATE) */

// Controls all the DirectX device resources.

// Provides an interface for an application that owns DeviceResources to be notified of the device being lost or created.

// Swapchain Rotation Matrices (Z-rotation)

// Direct3D objects.

// Direct3D rendering objects. Required for 3D.

// Cached reference to the Window.

// Cached device properties.

// Transforms used for display orientation.

// The IDeviceNotify can be held directly as it owns the DeviceResources.

// Main entry point for our app. Connects the app with the Windows shell and handles application lifecycle events.

// IFrameworkViewSource Methods

// IFrameworkView Methods.

// Application lifecycle event handlers

// Window event handlers

// Navigation event handlers

// Input event handlers

// Pointer event handlers

// DisplayInformation event handlers.

// Cleanup Sokol Context

// This flag adds support for surfaces with a different color channel ordering
// than the API default. It is required for compatibility with Direct2D.

// If the project is in a debug build, enable debugging via SDK Layers with this flag.

// This array defines the set of DirectX hardware feature levels this app will support.
// Note the ordering should be preserved.
// Don't forget to declare your application's minimum required feature level in its
// description.  All applications are assumed to support 9.1 unless otherwise stated.

// Create the Direct3D 11 API device object and a corresponding context.

// Specify nullptr to use the default adapter.
// Create a device using the hardware graphics driver.
// Should be 0 unless the driver is D3D_DRIVER_TYPE_SOFTWARE.
// Set debug and Direct2D compatibility flags.
// List of feature levels this app can support.
// Size of the list above.
// Always set this to D3D11_SDK_VERSION for Microsoft Store apps.
// Returns the Direct3D device created.
// Returns feature level of device created.
// Returns the device immediate context.

// If the initialization fails, fall back to the WARP device.
// For more information on WARP, see:
// https://go.microsoft.com/fwlink/?LinkId=286690

// Create a WARP device instead of a hardware device.

// Store pointers to the Direct3D 11.3 API device and immediate context.

// Setup Sokol Context

// Cleanup Sokol Context (these are non-owning raw pointers)

// Clear the previous window size specific context.

// these are smart pointers, setting to nullptr will delete the objects

// The width and height of the swap chain must be based on the window's
// natively-oriented width and height. If the window is not in the native
// orientation, the dimensions must be reversed.

// If the swap chain already exists, resize it.

// Double-buffered swap chain.

// If the device was removed for any reason, a new device and swap chain will need to be created.

// Everything is set up now. Do not continue execution of this method. HandleDeviceLost will reenter this method
// and correctly set up the new device.

// Otherwise, create a new one using the same adapter as the existing Direct3D device.

// Match the size of the window.

// This is the most common swap chain format.

// Don't use multi-sampling.

// Use double-buffering to minimize latency.
// All Microsoft Store apps must use this SwapEffect.

// This sequence obtains the DXGI factory that was used to create the Direct3D device above.

// Ensure that DXGI does not queue more than one frame at a time. This both reduces latency and
// ensures that the application will only render after each VSync, minimizing power consumption.

// Setup Sokol Context

// Set the proper orientation for the swap chain, and generate 2D and
// 3D matrix transformations for rendering to the rotated swap chain.
// Note the rotation angle for the 2D and 3D transforms are different.
// This is due to the difference in coordinate spaces.  Additionally,
// the 3D matrix is specified explicitly to avoid rounding errors.

// Create a render target view of the swap chain back buffer.

// Create MSAA texture and view if needed

// arraySize
// mipLevels

// cpuAccessFlags

// Create a depth stencil view for use with 3D rendering if needed.

// This depth stencil view has only one texture.
// Use a single mipmap level.

// cpuAccessFlag

// Set sokol window and framebuffer sizes

// Setup Sokol Context

// Sokol app is now valid

// Determine the dimensions of the render target and whether it will be scaled down.

// Calculate the necessary render target size in pixels.

// Prevent zero size DirectX content from being created.

// This method is called when the CoreWindow is created (or re-created).

// This method is called in the event handler for the SizeChanged event.

// This method is called in the event handler for the DpiChanged event.

// When the display DPI changes, the logical size of the window (measured in Dips) also changes and needs to be updated.

// This method is called in the event handler for the OrientationChanged event.

// This method is called in the event handler for the DisplayContentsInvalidated event.

// The D3D Device is no longer valid if the default adapter changed since the device
// was created or if the device has been removed.

// First, get the information for the default adapter from when the device was created.

// Next, get the information for the current default adapter.

// If the adapter LUIDs don't match, or if the device reports that it has been removed,
// a new D3D device must be created.

// Release references to resources related to the old device.

// Create a new device and swap chain.

// Recreate all device resources and set them back to the current state.

// Register our DeviceNotify to be informed on device lost and creation.

// Call this method when the app suspends. It provides a hint to the driver that the app
// is entering an idle state and that temporary buffers can be reclaimed for use by other apps.

// Present the contents of the swap chain to the screen.

// MSAA resolve if needed

// The first argument instructs DXGI to block until VSync, putting the application
// to sleep until the next VSync. This ensures we don't waste any cycles rendering
// frames that will never be displayed to the screen.

// Discard the contents of the render target.
// This is a valid operation only when the existing contents will be entirely
// overwritten. If dirty or scroll rects are used, this call should be removed.

// Discard the contents of the depth stencil.

// If the device was removed either by a disconnection or a driver upgrade, we
// must recreate all device resources.

// This method determines the rotation between the display device's native orientation and the
// current display orientation.

// Note: NativeOrientation can only be Landscape or Portrait even though
// the DisplayOrientations enum has other values.

// Check for SDK Layer support.

// There is no need to create a real hardware device.

// Check for the SDK layers.
// Any feature level will do.

// Always set this to D3D11_SDK_VERSION for Microsoft Store apps.
// No need to keep the D3D device reference.
// No need to know the feature level.
// No need to keep the D3D device context reference.

// The first method called when the IFrameworkView is being created.

// Register event handlers for app lifecycle. This example includes Activated, so that we
// can make the CoreWindow active and start rendering on the window.

// At this point we have access to the device.
// We can create the device-dependent resources.

// Called when the CoreWindow object is created (or re-created).

// Initializes scene resources, or loads a previously saved app state.

// This method is called after the window becomes active.

// NOTE: UWP will simply terminate an application, it's not possible to detect when an application is being closed

// Required for IFrameworkView.
// Terminate events do not cause Uninitialize to be called. It will be called if your IFrameworkView
// class is torn down while the app is in the foreground.

// empty

// Application lifecycle event handlers.

// Disabling this since it can only append the title to the app name (Title - Appname).
// There's no way of just setting a string to be the window title.
//appView.Title(_sapp.window_title_wide);

// Run() won't start until the CoreWindow is activated.

// NOTE: for some reason this event handler is never called??

// don't update dx/dy in the very first event

// HACK for detecting multiple mouse button presses

// NOTE: UNTESTED

// NOTE: UNTESTED

// NOTE: UNTESTED

/* End empty namespace */

/* SOKOL_NO_ENTRY */
/* _SAPP_UWP */

/*== Android ================================================================*/

/* android loop thread */

/* find config with 8-bit rgb buffer if available, ndk sample does not trust egl spec */

/* TODO: set window flags */
/* ANativeActivity_setWindowFlags(activity, AWINDOW_FLAG_KEEP_SCREEN_ON, 0); */

/* create egl surface and make it current */

/* NOTE: calling ANativeWindow_setBuffersGeometry() with the same dimensions
    as the ANativeWindow size results in weird display artefacts, that's
    why it's only called when the buffer geometry is different from
    the window size
*/

/* query surface size */

/* egl context is bound, cleanup gracefully */

/* always try to cleanup by destroying egl context */

/* try to cleanup while we still have a surface and can call cleanup_cb() */

/* request exit */

/* FIXME: this should be hooked into a "really quit?" mechanism
   so the app can ask the user for confirmation, this is currently
   generally missing in sokol_app.h
*/

/* data */

/* signal "received" */

/* This seems to be broken in the NDK, but there is (a very cumbersome) workaround... */

/* or ALOOPER_PREPARE_ALLOW_NON_CALLBACKS*/

/* data */

/* signal start to main thread */

/* main loop */

/* sokol frame */

/* process all events (or stop early if app is requested to quit) */

/* cleanup thread */

/* the following causes heap corruption on exit, why??
ALooper_removeFd(_sapp.android.looper, _sapp.android.pt.read_from_main_fd);
ALooper_release(_sapp.android.looper);*/

/* signal "destroyed" */

/* android main/ui thread */

/* see android:configChanges in manifest */

/*
 * For some reason even an empty app using nativeactivity.h will crash (WIN DEATH)
 * on my device (Moto X 2nd gen) when the app is removed from the task view
 * (TaskStackView: onTaskViewDismissed).
 *
 * However, if ANativeActivity_finish() is explicitly called from for example
 * _sapp_android_on_stop(), the crash disappears. Is this a bug in NativeActivity?
 */

/* send destroy msg */

/* clean up main thread */

/* this is a bit naughty, but causes a clean restart of the app (static globals are reset) */

/* start loop thread */

/* wait until main loop has started */

/* send create msg */

/* register for callbacks */

/* activity->callbacks->onNativeWindowResized = _sapp_android_on_native_window_resized; */
/* activity->callbacks->onNativeWindowRedrawNeeded = _sapp_android_on_native_window_redraw_needed; */

/* activity->callbacks->onContentRectChanged = _sapp_android_on_content_rect_changed; */

/* NOT A BUG: do NOT call sapp_discard_state() */

/* _SAPP_ANDROID */

/*== LINUX ==================================================================*/

/* see GLFW's xkb_unicode.c */

/* XK_dead_a */
/* XK_dead_A */
/* XK_dead_e */
/* XK_dead_E */
/* XK_dead_i */
/* XK_dead_I */
/* XK_dead_o */
/* XK_dead_O */
/* XK_dead_u */
/* XK_dead_U */

/*XKB_KEY_KP_Space*/
/*XKB_KEY_KP_7*/
/*XKB_KEY_KP_4*/
/*XKB_KEY_KP_8*/
/*XKB_KEY_KP_6*/
/*XKB_KEY_KP_2*/
/*XKB_KEY_KP_9*/
/*XKB_KEY_KP_3*/
/*XKB_KEY_KP_1*/
/*XKB_KEY_KP_5*/
/*XKB_KEY_KP_0*/
/*XKB_KEY_KP_Multiply*/
/*XKB_KEY_KP_Add*/
/*XKB_KEY_KP_Separator*/
/*XKB_KEY_KP_Subtract*/
/*XKB_KEY_KP_Decimal*/
/*XKB_KEY_KP_Divide*/
/*XKB_KEY_KP_0*/
/*XKB_KEY_KP_1*/
/*XKB_KEY_KP_2*/
/*XKB_KEY_KP_3*/
/*XKB_KEY_KP_4*/
/*XKB_KEY_KP_5*/
/*XKB_KEY_KP_6*/
/*XKB_KEY_KP_7*/
/*XKB_KEY_KP_8*/
/*XKB_KEY_KP_9*/
/*XKB_KEY_KP_Equal*/

/* check Xi extension for raw mouse input */

/* from GLFW:

   NOTE: Default to the display-wide DPI as we don't currently have a policy
         for which monitor a window is considered to be on

    _sapp.x11.dpi = DisplayWidth(_sapp.x11.display, _sapp.x11.screen) *
                    25.4f / DisplayWidthMM(_sapp.x11.display, _sapp.x11.screen);

   NOTE: Basing the scale on Xft.dpi where available should provide the most
         consistent user experience (matches Qt, Gtk, etc), although not
         always the most accurate one
*/

/* HACK: This is a (hopefully temporary) workaround for Chromium
       (VirtualBox GL) not setting the window bit on any GLXFBConfigs
*/

/* Only consider RGBA GLXFBConfigs */

/* Only consider window GLXFBConfigs */

/* NOTE: this function must be called after XMapWindow (which happens in _sapp_x11_show_window()) */

// XIMaskLen is a macro

// display
// grab_window
// owner_events
// event_mask
// pointer_mode
// keyboard_mode
// confine_to
// cursor
// time

/* border width */
/* color depth */

/* announce support for drag'n'drop */

/* check if a CLIPBOARD_PASTED event must be sent too */

/* Mapped to Alt_R on many keyboards */
/* AltGr on at least some machines */

/* At least in some layouts... */

/* First check for Latin-1 characters (1:1 mapping) */

/* Also check for directly encoded 24-bit UCS characters */

/* Binary search in table */

/* No matching Unicode value found */

/*
    src is (potentially percent-encoded) string made of one or multiple paths
    separated by \r\n, each path starting with 'file://'
*/

// room for terminating 0

/* check leading 'file://' */

// skip

// too many files is not an error

// a percent-encoded byte (most like UTF-8 multibyte sequence)

// dst_end_ptr already has adjustment for terminating zero

// XLib manual says keycodes are in the range [8, 255] inclusive.
// https://tronche.com/gui/x/xlib/input/keyboard-encoding.html

/* if focus is lost for any reason, and we're in mouse locked mode, disable mouse lock */

/* might be a scroll event */

/* don't send enter/leave events while mouse button held down */

// drag was rejected

/* drag operation has moved over the window
   FIXME: we could track the mouse position here, but
   this isn't implemented on other platforms either so far
*/

/* reply that we are ready to copy the dragged data */
// accept with no rectangle

/* handle quit-requested, either from window or from sapp_request_quit() */

/* give user code a chance to intervene */

/* if user code hasn't intervened, quit the app */

/* SOKOL_NO_ENTRY */
/* _SAPP_LINUX */

/*== PUBLIC API FUNCTIONS ====================================================*/

// calling sapp_run() directly is not supported on Android)

/* this is just a stub so the linker doesn't complain */

/* likewise, in normal mode, sapp_run() is just an empty stub */

/* NOTE that sapp_show_mouse() does not "stack" like the Win32 or macOS API functions! */

/* NOTE: on HTML5, sapp_set_clipboard_string() must be called from within event handler! */

/* not implemented */

/* not implemented */

// success

// fetched_size

/* SOKOL_IMPL */
