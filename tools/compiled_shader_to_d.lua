#!/usr/bin/lua

local input = arg[1]
if input and input ~= '-' then
    io.input(input)
end
local output = arg[2]
if output and output ~= '-' then
    io.output(output)
end

local header_contents = io.read('*a')
local contents = {
    'import mathtypes;\nimport sokol_gfx;',
    'extern(C):',
    push = function(self, fmt, ...)
        table.insert(self, string.format(fmt, ...))
    end,
}

for binding_num, struct_name, braces in header_contents:gmatch("layout%(%s*binding%s*=%s*(%d+)%)%s*uniform%s+(%S+)%s*(%b{})") do
    contents:push('enum SLOT_%s = %s;', struct_name, binding_num)
    contents:push('struct %s %s', struct_name, braces)
end

local program_name = header_contents:match("@program%s*(%S+)")
contents:push('const(sg_shader_desc*) %s_shader_desc();', program_name)

io.write(table.concat(contents, '\n\n'))

