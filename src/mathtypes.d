import std.math;

struct Vector(T, int N)
{
    T[N] elements = 0;
    alias elements this;

    ref inout(T) get_(int i)() inout
    in(i >= 0 && i <= N, "Index out of bounds")
    {
        return elements[i];
    }
    ref inout(T[to - from]) get_(int from, int to)() inout
    in(from >= 0 && to <= N, "Index out of bounds")
    {
        return elements[from .. to];
    }

    alias x = get_!(0);
    alias r = x;
    alias u = x;
    alias s = x;

    alias y = get_!(1);
    alias g = y;
    alias v = y;
    alias t = y;

    static if (N > 2)
    {
        alias z = get_!(2);
        alias b = z;
        alias p = z;

        alias xy = get_!(0, 2);
        alias rg = xy;
        alias uv = xy;
        alias st = xy;

        alias yz = get_!(1, 3);
        alias gb = yz;
        alias tp = yz;
    }
    static if (N > 3)
    {
        alias w = get_!(3);
        alias a = w;
        alias q = w;

        alias zw = get_!(2, 4);
        alias ba = zw;
        alias pq = zw;

        alias xyz = get_!(0, 3);
        alias rgb = xyz;
        alias stp = xyz;

        alias yzw = get_!(1, 4);
        alias gba = yzw;
        alias tpq = yzw;
    }
}

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
