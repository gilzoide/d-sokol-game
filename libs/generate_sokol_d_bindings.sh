#!/bin/sh

pushd sokol

dstep --alias-enum-members *.h -o ../d_wrappers
# Fix anonymous enum aliases like "alias SAPP_MAX_TOUCHPOINTS = .SAPP_MAX_TOUCHPOINTS;"
sed -i '/alias \w* = \.\w*;/d' ../d_wrappers/*.d

cat > ../d_wrappers/sokol_glue.d <<EOL
import sokol_gfx;

extern(C):

sg_context_desc sapp_sgcontext();
EOL

sed -i -E 's/^(\s*float[^;]+)/\1 = 0/g' ../d_wrappers/*.d

popd
