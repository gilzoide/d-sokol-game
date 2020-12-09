#!/bin/sh

script_root=$(dirname $(realpath $0))

maybewipe() {
    dir="$script_root/../$1"
    wipeflag=$([ -d "$dir" ] && echo --wipe)
    echo "$dir" $wipeflag
}

env DC=gdc meson setup $(maybewipe build)
env DC=ldc meson setup --buildtype release $(maybewipe build/release)
meson setup --cross-file cross-web.ini $(maybewipe build/web)
meson setup --cross-file cross-web.ini -Ddebug=false -Doptimization=s $(maybewipe build/release/web)
