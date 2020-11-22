#!/bin/sh

maybewipe() {
    dir="$1"
    wipeflag=$([ -d "$dir" ] && echo --wipe)
    echo "$dir" $wipeflag
}

env DC=gdc meson setup $(maybewipe build)
env DC=ldc meson setup $(maybewipe build.betterC)
env DC=ldc meson setup --buildtype release $(maybewipe build.release)
meson setup --cross-file cross-web.ini --buildtype release $(maybewipe build.web)
