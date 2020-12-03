import bettercmath.vector;
import bettercmath.matrix;
import std.math;

alias Color = Vector!(ubyte, 4);

alias Vec2i = Vector!(int, 2);
alias Vec2 = Vector!(float, 2);
alias Vec3 = Vector!(float, 3);
alias Vec4 = Vector!(float, 4);
alias Mat4 = Matrix!(float, 4);

alias vec2 = Vec2;
alias vec3 = Vec3;
alias vec4 = Vec4;
alias mat4 = Mat4;

/// Padding for uniform blocks
mixin template UniformPadding()
{
    private alias T = typeof(this);
    static if (T.sizeof % T.alignof > 0)
    {
        byte[16 - T.sizeof % T.alignof] __pad;
    }
}
