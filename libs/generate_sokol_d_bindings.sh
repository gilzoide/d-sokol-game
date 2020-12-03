#!/bin/sh

script_root=$(dirname $(realpath $0))

pushd "$script_root/sokol"

dstep --alias-enum-members *.h -o ../d_wrappers
# Fix anonymous enum aliases like "alias SAPP_MAX_TOUCHPOINTS = .SAPP_MAX_TOUCHPOINTS;"
sed -i '/alias \w* = \.\w*;/d' ../d_wrappers/*.d

cat > ../d_wrappers/sokol_glue.d <<EOL
import sokol_gfx;

extern(C):

sg_context_desc sapp_sgcontext();
EOL

# Fix initial float values as 0 instead of NaN
sed -i -E 's/^(\s*float[^;]+)/\1 = 0/g' ../d_wrappers/sokol*.d

# Fix incorrect handling of some sg_* structs passed by value on LDC + wasm32
lua_script='print((string.gsub(io.read("*a"), "struct (sg_%S+)%s*{%s*uint id;%s*}", "alias %1 = uint;")))'
echo "$(cat ../d_wrappers/sokol_gfx.d | lua -e "$lua_script")" > ../d_wrappers/sokol_gfx.d

popd
