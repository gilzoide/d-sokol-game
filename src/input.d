import glfw;

import globals;
import mathtypes;

void setInputCallbacks(GLFWwindow* window)
{
    window.glfwSetCursorPosCallback(&cursorPosCallback);
    window.glfwSetWindowSizeCallback(&windowSizeCallback);

    window.glfwGetWindowSize(&windowSize[0], &windowSize[1]);
    window.glfwGetFramebufferSize(&framebufferSize[0], &framebufferSize[1]);
}

extern(C):
__gshared Vec2 cursorPos;
__gshared Vec2i windowSize;
__gshared Vec2i framebufferSize;

void windowSizeCallback(GLFWwindow* window, int width, int height)
{
    windowSize = [width, height];
    window.glfwGetFramebufferSize(&framebufferSize[0], &framebufferSize[1]);
}

void cursorPosCallback(GLFWwindow* window, double x, double y)
{
    cursorPos = Vec2(cast(float) x, cast(float) y);
}
