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

c_include_directories = include_directories('libs/sokol')
d_include_directories = include_directories('libs/sokol_d', 'libs/gl3n')
libs_sources = ['src/sokol.c']

sources = 'src/app.d' # ['src/main.c', 'src/hexagrid.c']
exe = executable('zig-sokol', sources, libs_sources,
  generated_shader_headers,
  c_args: c_args,
  d_args: d_args,
  link_language: 'c',
  include_directories: [d_include_directories, c_include_directories],
  dependencies: dependencies,
  name_suffix: name_suffix,
)
