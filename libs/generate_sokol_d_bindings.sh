#!/bin/sh

pushd sokol
dstep --alias-enum-members *.h -o ../sokol_d
# Fix anonymous enum aliases like "alias SAPP_MAX_TOUCHPOINTS = .SAPP_MAX_TOUCHPOINTS;"
sed -i '/alias \w* = \.\w*;/d' ../sokol_d/*.d
popd
