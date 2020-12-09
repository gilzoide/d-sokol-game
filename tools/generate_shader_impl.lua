#!/usr/bin/lua

local input = arg[1]
local output = arg[2]
if output and output ~= '-' then
    io.output(output)
end

io.write(string.format([[
#include "sokol_gfx.h"

#define SOKOL_SHDC_IMPL
#include "%s"
]], input))

