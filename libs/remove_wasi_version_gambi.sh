#!/bin/sh

config_file=druntime/src/core/sys/wasi/config.d
types_file=druntime/src/core/sys/wasi/sys/types.d

lua_script='print((string.gsub(io.read("*a"), "version[^:]+:", "")))'
echo "$(cat $config_file | lua -e "$lua_script")" > $config_file
echo "$(cat $types_file | lua -e "$lua_script")" > $types_file

