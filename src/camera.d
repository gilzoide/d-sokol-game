import std.range;

import betterclist;

import constants;
import node;
import mathtypes;
import uniforms;

struct Camera
{
    mixin Node;

    CameraUniform uniform;
    alias uniform this;

    this(const Mat4 matrix)
    {
        uniform.projection_matrix = matrix;
    }

    private __gshared CameraUniform identity = {{
        projection_matrix: Mat4.ortho(
            0, initialWindowWidth,
            -initialWindowHeight, 0,
            -1, 1,
        ),
    }};
    private __gshared List!(CameraUniform*, cameraStackSize) stack = [&identity];

    void draw()
    {
        auto result = stack.push(&uniform);
        assert(result == 0, "Couldn't push Camera, stack is too little!");
    }
    void lateDraw()
    {
        stack.pop();
        Rebind.draw();
    }

    struct Rebind
    {
        static void draw()
        {
            stack[].back.draw();
        }
    }
}
