import constants;
import game;
import glfw;
import glstuff;
import hexagrid;
import sokol_app;
import sokol_gfx;
import sokol_time;
import sokol_glue;

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

///// Sokol init callback
void init()
{
    immutable int glVersion = glfwGetWindowAttrib(window, GLFW_CONTEXT_VERSION_MAJOR);
    printf("GL %d\n", glVersion);

    sg_desc desc = {};
    desc.context.gl.force_gles2 = glVersion <= 2;
    sg_setup(&desc);
    assert(sg_isvalid());

    stm_setup();

    GAME.createObject!(Hexagrid!(keyboardGridColumns, keyboardGridRows));
}

///// Sokol frame callback
//void d_frame()
//{
    //const int width = sapp_width(), height = sapp_height();
    //sg_begin_default_pass(&default_pass_action, width, height);

    //GAME.frame();

    //sg_end_pass();
    //sg_commit();
//}

///// Sokol cleanup callback
//void d_cleanup()
//{
    //sg_shutdown();
//}

///// Sokol event callback
//void d_event(const(sapp_event)* ev)
//{
    //GAME.event(ev);
//}

///// Sokol fail callback
//void d_fail(const char* msg)
//{
    //printf("ERRO: %s\n", msg);
//}

__gshared GLFWwindow *window;

void frame()
{
    int width, height;
    glfwGetFramebufferSize(window, &width, &height);
    sg_begin_default_pass(&default_pass_action, width, height);

    GAME.frame();

    sg_end_pass();
    sg_commit();

    glfwSwapBuffers(window);
    glfwPollEvents();
}

int main(int argc, const(char*)* argv)
{
    if (!glfwInit())
    {
        return -1;
    }

    hintGLVersion();

    window = glfwCreateWindow(initialWindowWidth, initialWindowHeight, windowTitle, null, null);
    if (!window)
    {
        glfwTerminate();
        return -2;
    }
    glfwSetWindowAspectRatio(window, 16, 9);
    glfwMakeContextCurrent(window);
    loadGL();

    init();

    version (WebAssembly)
    {
        emscripten_set_main_loop(&frame, 0, 1);
    }
    else
    {
        while (!window.glfwWindowShouldClose())
        {
            frame();
        }
    }

    sg_shutdown();
    glfwTerminate();

    return 0;
}
