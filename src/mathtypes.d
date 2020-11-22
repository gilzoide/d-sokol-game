import bettercmath;
import std.math;

alias Vec2 = Vector!(float, 2);
alias Vec3 = Vector!(float, 3);
alias Vec4 = Vector!(float, 4);
alias Mat4 = Matrix!(float, 4);

alias vec2 = Vec2;
alias vec3 = Vec3;
alias vec4 = Vec4;
alias mat4 = Mat4;

T deg2rad(T)(T degrees)
{
    return degrees * (PI / 180);
}
T rad2deg(T)(T radians)
{
    return radians * (180 / PI);
}

/// Padding for uniform blocks
mixin template UniformPadding()
{
    private alias T = typeof(this);
    static if (T.sizeof % 16 > 0)
    {
        byte[16 - T.sizeof % 16] __pad;
    }
}
