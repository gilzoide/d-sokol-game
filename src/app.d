import glfw;
import sokol_gfx;

import cdefs;
import checkers;
import constants;
import game;
import globals;
import glstuff;
import input;

extern(C):


void init()
{
    immutable int glVersion = glfwGetWindowAttrib(window, GLFW_CONTEXT_VERSION_MAJOR);
    printf("GL %d\n", glVersion);

    sg_desc desc = {};
    desc.context.gl.force_gles2 = glVersion <= 2;
    sg_setup(&desc);
    assert(sg_isvalid());

    setInputCallbacks(window);

    //GAME.createObject!(Hexagrid!(keyboardGridColumns, keyboardGridRows));
    GAME.createObject!Checkers;
}

void frame()
{
    sg_begin_default_pass(&default_pass_action, framebufferSize.x, framebufferSize.y);

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
