import constants;
import game;
import glfw;
import glstuff;
import hexagrid;
import sokol_gfx;

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

void init()
{
    immutable int glVersion = glfwGetWindowAttrib(window, GLFW_CONTEXT_VERSION_MAJOR);
    printf("GL %d\n", glVersion);

    sg_desc desc = {};
    desc.context.gl.force_gles2 = glVersion <= 2;
    sg_setup(&desc);
    assert(sg_isvalid());

    GAME.createObject!(Hexagrid!(keyboardGridColumns, keyboardGridRows));
}

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
