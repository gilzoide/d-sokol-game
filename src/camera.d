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
    private static List!(CameraUniform*, cameraStackSize) stack = [&identity];

    void draw()
    {
        assert(stack.push(&uniform) == 0, "Couldn't push Camera, stack is too little!");
    }
    void lateDraw()
    {
        stack.pop!false();
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
