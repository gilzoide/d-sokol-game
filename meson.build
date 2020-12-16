project('d-sokol-game', 'c', 'd',
  default_options: ['c_std=c99', 'default_library=static'],
)

cc = meson.get_compiler('c')
dc = meson.get_compiler('d')
is_debug = get_option('debug')
is_gdc = dc.get_id() == 'gcc'
is_web = host_machine.system() == 'emscripten'

c_args = []
d_args = []
link_args = []
d_dependencies = []
exe_dependencies = []
name_suffix = []

if is_debug
  if not is_gdc
    add_global_arguments('-gc', language: 'd')
  endif
else
  add_global_arguments( '-DNDEBUG', language: 'c')
endif

if is_gdc
  add_global_arguments('-fdiagnostics-color', language: 'd')
  link_language = 'd'
else
  add_global_arguments('--enable-color', '-betterC', language: 'd')
  link_language = 'c'
endif

subdir('tools')
bettercmath = subproject('bettercmath')
flyweightbyid = subproject('flyweightbyid')
glad = subproject('glad')
cmake = import('cmake')

exe_dependencies += [
  bettercmath.get_variable('bettercmath_dep'),
  flyweightbyid.get_variable('flyweightbyid_dep'),
  glad.get_variable('glad_dep'),
]

# GLFW dependency
if is_web
  link_args += [
    '-s', 'USE_GLFW=3',
    '-lGL', '-lglfw3',
  ]
  glad_api = 'gles2='
else
  # GLFW CMake subproject
  glfw_opts = cmake.subproject_options()
  glfw_opts.add_cmake_defines({
    'GLFW_BUILD_EXAMPLES': 'OFF',
    'GLFW_BUILD_TESTS': 'OFF',
    'GLFW_BUILD_DOCS': 'OFF',
    'GLFW_INSTALL': 'OFF',
  })
  glfw = cmake.subproject('glfw', options: glfw_opts)
  exe_dependencies += glfw.dependency('glfw')
  glad_api = 'gl=3.3'
endif


# Compile shaders
generated_c_shader_files = []
generated_d_headers = []
foreach shader : [
  #'src/shader/hexagrid.glsl',
  'src/shader/standard.glsl',
]
  generated_c_shader_files += [
    shdc.process(shader),
    shader_impl.process(shader),
  ]
  generated_d_headers += shader_to_d.process(shader)
endforeach
shader_dependency = declare_dependency(sources: generated_c_shader_files)

# D dependencies from DUB
dub = find_program('dub')
dub_compiler_flag = '--compiler=' + dc.cmd_array()[0]
foreach depname : []
  dep = dependency(depname, method: 'dub', required: false)
  if not dep.found()
    message('Building ' + depname + ' from DUB (' + dub_compiler_flag + ')')
    run_command(dub, 'fetch', depname)
    run_command(dub, 'build', depname, dub_compiler_flag)
    dep = dependency(depname, method: 'dub', required: true)
  endif
  d_dependencies += dep
endforeach

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
    #dependency('GL'),
    #cc.find_library('m'),
    dependency('threads'),
    #dependency('X11'),
    #dependency('xi'),
    #dependency('xcursor'),
  ]
elif host_machine.system() == 'emscripten'
  if is_debug
    c_args += '-g4'
    link_args += [
      '-g4',
      '-s', 'ASSERTIONS=2',
    ]
  else
    link_args += [
      '--closure=1',
      '-s', 'SUPPORT_ERRNO=0',
      '-s', 'FILESYSTEM=0',
    ]
  endif
  c_args += [
    '-s', 'DEFAULT_TO_CXX=0',
    '-s', 'STRICT=1',
  ]
  link_args += [
    '-s', 'DEFAULT_TO_CXX=0',
    '-s', 'STRICT=1',
    '-s', 'ENVIRONMENT=web',
    '-s', 'MAX_WEBGL_VERSION=2',
  ]
  name_suffix = 'html'
  d_args += ['--mtriple=wasm32', '--output-bc']
endif

c_include_directories = include_directories(
  'src',
  'libs/sokol',
)
c_sources = [
  'src/sokol_impl.c',
]
d_include_directories = include_directories(
  'src',
  'libs/d_wrappers',
  'libs/druntime/src',
)
d_sources = [
  'src/app.d',
  'src/cdefs.d',
  'src/checkers.d',
  'src/constants.d',
  'src/game.d',
  'src/gfx.d',
  'src/globals.d',
  'src/glstuff.d',
  #'src/hexagon.d',
  #'src/hexagrid.d',
  'src/input.d',
  'src/keyboard.d',
  'src/mathtypes.d',
  'src/memory.d',
  'src/mesh.d',
  'src/node.d',
  'src/pipelines.d',
  'src/regular_polygon.d',
  'src/shaders.d',
  'src/texture.d',
  'src/timer.d',
  'src/tween.d',
  'src/uniforms.d',
  #'libs/d_wrappers/sokol_app.d',
  #'libs/d_wrappers/sokol_args.d',
  #'libs/d_wrappers/sokol_audio.d',
  #'libs/d_wrappers/sokol_fetch.d',
  'libs/d_wrappers/sokol_gfx.d',
  #'libs/d_wrappers/sokol_glue.d',
  #'libs/d_wrappers/sokol_time.d',
]

#d_lib = static_library('d_lib',
  #d_sources, generated_d_headers,
  #d_args: d_args,
  #include_directories: d_include_directories,
  #dependencies: d_dependencies,
#)

#exe = executable('teclado-harmonico-game',
  #c_sources, generated_c_shader_files,
  #c_args: c_args,
  #link_language: 'c',
  #link_with: d_lib,
  #include_directories: c_include_directories,
  #dependencies: exe_dependencies,
  #name_suffix: name_suffix,
#)

unity_exe = executable('d-sokol-game',
  c_sources, generated_c_shader_files,
  d_sources, generated_d_headers,
  c_args: c_args,
  d_args: d_args,
  link_args: link_args,
  link_language: link_language,
  include_directories: [c_include_directories, d_include_directories],
  dependencies: [d_dependencies, exe_dependencies],
  name_suffix: name_suffix,
)
