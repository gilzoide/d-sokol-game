project('zig-sokol', 'c', 'd')

cc = meson.get_compiler('c')
dc = meson.get_compiler('d')

subdir('tools')

# Compile shaders
shader_files = ['src/shader/hexagrid.glsl']
generated_shader_headers = []
foreach shader : shader_files
  generated_shader_headers += shdc.process(shader)
endforeach
shader_dependency = declare_dependency(sources: generated_shader_headers)

name_suffix = meson.get_external_property('name_suffix', [])
c_args = ['-Wno-missing-braces']
d_args = ['-betterC']
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

d_include_directories = include_directories('libs/sokol_d')
d_app = static_library('d_app', 'src/app.d',
  d_args: d_args,
  include_directories: d_include_directories,
)

libs_include_directories = include_directories('libs/sokol', 'libs/Handmade-Math')
libs_sources = ['src/sokol.c', 'src/HandmadeMath.c']

sources = ['src/main.c', 'src/hexagrid.c']
exe = executable('zig-sokol', libs_sources,
  generated_shader_headers,
  c_args: c_args,
  link_language: 'c',
  link_with: d_app,
  include_directories: libs_include_directories,
  dependencies: dependencies,
  name_suffix: name_suffix,
)
