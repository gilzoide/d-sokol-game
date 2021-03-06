#!/bin/sh

script_root=$(dirname $(realpath $0))

build_dir="$script_root/../build/release/web"
destiny_dir="$script_root/.."

cp "$build_dir"/*.html "$destiny_dir/index.html"
cp "$build_dir"/*.{js,wasm} "$destiny_dir"
jsfile=$(ls $destiny_dir/*.js -1)
uglifyjs $jsfile -o $jsfile
