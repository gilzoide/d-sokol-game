#!/usr/bin/lua

local unpack = table.unpack or unpack
local shdc, input, header, impl, depfile = unpack(arg)

-- Generate header with sokol-shdc
local shdc_command_args = {
    shdc,
    '--input', input,
    '--output', header,
    unpack(arg, 6),
}
local shdc_command = table.concat(shdc_command_args, ' ')
assert(os.execute(shdc_command), 'Error compiling shader')

-- Generate implementation C file
if impl and impl ~= '-' then
    io.output(impl)
end
io.write(string.format([[
#include "sokol_gfx.h"

#define SOKOL_SHDC_IMPL
#include "%s"
]], header))

-- Generate depfile for @include blocks
if depfile and depfile ~= '-' then
    if input and input ~= '-' then
        io.input(input)
    end
    local shader_contents = io.read('*a')

    io.output(depfile)
    local dependencies = {}
    local path = input:match('(.-)[^/]+$')
    for f in shader_contents:gmatch('@include%s+(%S+)') do
        table.insert(dependencies, path .. f)
    end
    local deps_contents = string.format('%s: %s', header, table.concat(dependencies, ' '))
    io.write(deps_contents)
    io.close()
end

