import std.stdint;

import bettercmath.matrix;
import bettercmath.transform;
import bettercmath.valuerange;
import bettercmath.vector;

alias ColorRGB = Vector!(ubyte, 3);
alias ColorRGBA = Vector!(ubyte, 4);
alias Color = ColorRGBA;

alias Vec1 = Vector!(float, 1);
alias Vec2i = Vector!(int, 2);
alias Vec2 = Vector!(float, 2);
alias Vec3 = Vector!(float, 3);
alias Vec4 = Vector!(float, 4);
alias Mat4 = Matrix!(float, 4);

alias vec1 = Vec1;
alias vec2 = Vec2;
alias vec3 = Vec3;
alias vec4 = Vec4;
alias mat4 = Mat4;

alias Transform2D = Transform!(float, 2, false);
alias Transform2DCompact = Transform!(float, 2, true);
alias Transform3D = Transform!(float, 3, false);
alias Transform3DCompact = Transform!(float, 3, true);

alias FloatRange = ValueRange!float;
alias Vec2Range = ValueRange!Vec2;
alias Vec3Range = ValueRange!Vec3;
alias Vec4Range = ValueRange!Vec4;
