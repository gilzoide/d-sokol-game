project('zig-sokol', 'cpp')

zig = find_program('zig')
sokol_shdc = find_program('sokol-shdc')

slang_dict = {
  'windows': 'hlsl4',
  'linux': 'glsl330',
  'darwin': 'metal_macos:glsl330',
}
shdc = generator(sokol_shdc,
  output: '@PLAINNAME@.h',
  arguments: [
    '--input', '@INPUT@',
    '--output', '@OUTPUT@',
    '-l', slang_dict.get(host_machine.system(), 'glsl330'),
    '@EXTRA_ARGS@',
  ],
)

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
endif

source_root = meson.project_source_root()
zig_lib = custom_target('zig-sokol.a',
  output: 'zig-sokol.a',
  input: ['src/main.zig'] + generated_shader_headers,
  command: [zig, 'build-lib', '@INPUT0@',
    '-I', source_root,
    '-I', source_root / 'libs/sokol',
    '-I', '@PRIVATE_DIR@',
    '-femit-bin=@OUTPUT@',
    '--pkg-begin', 'sokol', source_root / 'libs/sokol-zig/src/sokol/sokol.zig',
  ] + zig_args,
)

sokol_lib = static_library('sokol', 'src/sokol.c',
  include_directories: 'libs/sokol',
  c_args: c_args,
)

exe = executable('zig-sokol', 'src/main.c',
  generated_shader_headers,
  include_directories: 'libs/sokol',
  link_with: [sokol_lib],
  dependencies: dependencies,
)