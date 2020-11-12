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
c_args = []
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

source_root = meson.project_source_root()
# zig_lib = custom_target('zig-sokol.a',
#   output: 'zig-sokol.a',
#   input: ['src/main.zig'] + generated_shader_headers,
#   command: [zig, 'build-lib', '@INPUT0@',
#     '-I', source_root,
#     '-I', source_root / 'libs/sokol',
#     '-I', '@PRIVATE_DIR@',
#     '-femit-bin=@OUTPUT@',
#     '--pkg-begin', 'sokol', source_root / 'libs/sokol-zig/src/sokol/sokol.zig',
#   ] + zig_args,
# )

sokol_lib = static_library('sokol', 'src/sokol.c',
  include_directories: 'libs/sokol',
  c_args: c_args + ['-Wno-missing-braces'],
)

sources = ['src/main.c', 'src/hexagrid.c']
exe = executable('zig-sokol', sources,
  generated_shader_headers,
  include_directories: 'libs/sokol',
  link_with: [sokol_lib],
  dependencies: dependencies,
)
