#!/bin/sh

pushd sokol

dstep --alias-enum-members *.h -o ../sokol_d
# Fix anonymous enum aliases like "alias SAPP_MAX_TOUCHPOINTS = .SAPP_MAX_TOUCHPOINTS;"
sed -i '/alias \w* = \.\w*;/d' ../sokol_d/*.d

cat > ../sokol_d/sokol_glue.d <<EOL
import sokol_gfx;

extern(C):

sg_context_desc sapp_sgcontext();
EOL

popd
