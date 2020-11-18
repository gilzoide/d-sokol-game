project('zig-sokol', 'c', 'd')

cc = meson.get_compiler('c')
dc = meson.get_compiler('d')

subdir('tools')

# Compile shaders
generated_shader_headers = []
generated_d_headers = []
foreach shader : ['src/shader/hexagrid.glsl']
  generated_shader_headers += shdc.process(shader)
  generated_d_headers += shader_to_d.process(shader)
endforeach
shader_dependency = declare_dependency(sources: generated_shader_headers)

# D dependencies from DUB
dub = find_program('dub')
dub_compiler_flag = '--compiler=' + dc.cmd_array()[0]
d_dependencies = []
foreach depname : []
  dep = dependency(depname, method: 'dub', required: false)
  if not dep.found()
    message('Building ' + depname + ' from DUB')
    run_command(dub, 'fetch', depname)
    run_command(dub, 'build', depname, dub_compiler_flag)
    dep = dependency(depname, method: 'dub', required: true)
  endif
  d_dependencies += dep
endforeach


name_suffix = meson.get_external_property('name_suffix', [])
c_args = ['-Wno-missing-braces']
d_args = ['-betterC']
exe_dependencies = []
if host_machine.system() == 'darwin'
  c_args += '-ObjC'
  exe_dependencies += [
    dependency('Cocoa'),
    dependency('QuartzCore'),
    dependency('Metal'),
    dependency('MetalKit'),
    dependency('AudioToolbox'),
  ]
elif host_machine.system() == 'linux'
  exe_dependencies += [
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
c_sources = ['src/sokol.c', 'src/shaders_impl.c']
d_include_directories = include_directories('src', 'libs/d_wrappers', 'libs/druntime/src')
d_sources = [
  'src/app.d',
  'src/constants.d',
  'src/game.d',
  'src/gfx.d',
  'src/hexagon.d',
  'src/hexagrid.d',
  'src/mathtypes.d',
  'src/mesh.d',
  'src/node.d',
  'libs/d_wrappers/sokol_app.d',
  'libs/d_wrappers/sokol_args.d',
  'libs/d_wrappers/sokol_audio.d',
  'libs/d_wrappers/sokol_fetch.d',
  'libs/d_wrappers/sokol_gfx.d',
  'libs/d_wrappers/sokol_glue.d',
  'libs/d_wrappers/sokol_time.d',
  generated_d_headers,
]

#d_lib = static_library('d_lib',
  #d_sources,
  #d_args: d_args,
  #include_directories: d_include_directories,
  #dependencies: d_dependencies,
#)

#exe = executable('zig-sokol',
  #c_sources, generated_shader_headers,
  #c_args: c_args,
  #link_language: 'c',
  #link_with: d_lib,
  #include_directories: c_include_directories,
  #dependencies: exe_dependencies,
  #name_suffix: name_suffix,
#)

unity_exe = executable('unity-exe',
  c_sources, generated_shader_headers,
  d_sources,
  c_args: c_args,
  d_args: d_args,
  link_language: 'c',
  include_directories: [c_include_directories, d_include_directories],
  dependencies: [d_dependencies, exe_dependencies],
  name_suffix: name_suffix,
)
