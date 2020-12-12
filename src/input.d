import glfw;

import globals;
import mathtypes;

void setInputCallbacks(GLFWwindow* window)
{
    window.glfwSetWindowSizeCallback(&windowSizeCallback);
    window.glfwSetCursorPosCallback(&cursorPosCallback);
    window.glfwSetMouseButtonCallback(&mouseButtonCallback);

    window.glfwGetWindowSize(&windowSize[0], &windowSize[1]);
    window.glfwGetFramebufferSize(&framebufferSize[0], &framebufferSize[1]);
}

enum PressState
{
    idle,
    pressed,
    released,
}

struct MouseButton
{
    PressState state;
    int mods;

    bool pressed() const
    {
        return state == PressState.pressed;
    }
    bool released() const
    {
        return state == PressState.released;
    }
}

struct MouseState
{
    enum buttonCount = 3;
    Vec2 position;
    MouseButton[buttonCount] buttons;

    ref inout(MouseButton) left() inout
    {
        return buttons[0];
    }
    ref inout(MouseButton) right() inout
    {
        return buttons[1];
    }
    ref inout(MouseButton) middle() inout
    {
        return buttons[2];
    }
}

extern(C):
__gshared Vec2i windowSize;
__gshared Vec2i framebufferSize;
__gshared MouseState Mouse;

void windowSizeCallback(GLFWwindow* window, int width, int height)
{
    windowSize = [width, height];
    window.glfwGetFramebufferSize(&framebufferSize[0], &framebufferSize[1]);
}

void cursorPosCallback(GLFWwindow* window, double x, double y)
{
    Mouse.position = Vec2(cast(float) x, cast(float) y);
}

void mouseButtonCallback(GLFWwindow* window, int button, int action, int _mods)
{
    if (button < Mouse.buttons.length)
    {
        if (action == GLFW_PRESS)
        {
            with (Mouse.buttons[button])
            {
                state = PressState.pressed;
                mods = _mods;
            }
        }
        else
        {
            with (Mouse.buttons[button])
            {
                state = PressState.released;
                mods = 0;
            }
        }
    }
}
