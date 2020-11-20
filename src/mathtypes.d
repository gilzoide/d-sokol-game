import bettercmath.vector;
import std.math;

alias Vec2 = Vector!(float, 2);
alias Vec3 = Vector!(float, 3);
alias Vec4 = Vector!(float, 4);

union Mat4
{
    float[16] elements = 0;
    alias elements this;

    float[4][4] columns;

    static Mat4 Orthographic(float Left, float Right, float Bottom, float Top, float Near, float Far)
    {
        Mat4 result = {};

        result.columns[0][0] = 2.0f / (Right - Left);
        result.columns[1][1] = 2.0f / (Top - Bottom);
        result.columns[2][2] = 2.0f / (Near - Far);
        result.columns[3][3] = 1.0f;

        result.columns[3][0] = (Left + Right) / (Left - Right);
        result.columns[3][1] = (Bottom + Top) / (Bottom - Top);
        result.columns[3][2] = (Far + Near) / (Near - Far);

        return result;
    }
}

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
