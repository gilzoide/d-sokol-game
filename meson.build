project('zig-sokol', 'c')

cc = meson.get_compiler('c')

zig = find_program('zig')

subdir('tools')


shader_files = ['src/triangle.glsl']
generated_shader_headers = []
foreach shader : shader_files
  generated_shader_headers += shdc.process(shader)
endforeach
shader_dependency = declare_dependency(sources: generated_shader_headers)

zig_args = []
c_args = ['-Wno-missing-braces']
dependencies = []
if host_machine.system() == 'darwin'
  zig_args += ['-fno-stack-check']
  c_args += '-ObjC'
  dependencies += [
    dependency('Cocoa'),
    dependency('QuartzCore'),
    dependency('Metal'),
    dependency('MetalKit'),
    dependency('AudioToolbox'),
    dependency('OpenGL'),
  ]
elif host_machine.system() == 'linux'
  dependencies += [
    dependency('alsa'),
    cc.find_library('dl'),
    dependency('GL'),
    cc.find_library('m'),
    dependency('threads'),
    dependency('X11'),
    dependency('xi'),
    dependency('xcursor'),
  ]
endif

libs_include_directories = include_directories('libs/sokol', 'libs/Handmade-Math')
libs_sources = ['src/sokol.c', 'src/HandmadeMath.c']

sources = ['src/main.c', 'src/hexagrid.c']
exe = executable('zig-sokol', sources, libs_sources,
  generated_shader_headers,
  c_args: c_args,
  include_directories: libs_include_directories,
  dependencies: dependencies,
)
