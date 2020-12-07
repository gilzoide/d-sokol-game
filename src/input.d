import glfw;

import globals;
import mathtypes;

Vec2 getMousePos()
{
    double x = void, y = void;
    window.glfwGetCursorPos(&x, &y);
    return Vec2(cast(float) x, cast(float) y);
}
