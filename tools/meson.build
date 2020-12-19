source_root = meson.project_source_root()

shdc_folder_dict = {
  'windows': 'win32',
  'linux': 'linux',
  'darwin': 'osx',
}
slang_dict = {
  #'windows': 'hlsl4',
  #'linux': 'glsl330',
  #'darwin': 'metal_macos:glsl330',
  'emscripten': 'glsl300es:glsl100',
}
sokol_shdc = find_program('sokol-shdc', 'sokol-shdc.exe',
  dirs: source_root / 'tools/sokol-tools-bin/bin' / shdc_folder_dict.get(build_machine.system())
)
compile_shader_lua = find_program('compile_shader.lua', dirs: source_root / 'tools')
compile_shader = generator(compile_shader_lua,
  output: ['@PLAINNAME@.h', '@PLAINNAME@.c'],
  depfile: '@PLAINNAME@.c.deps',
  arguments: [
    sokol_shdc.full_path(),
    '@INPUT@',
    '@OUTPUT0@',
    '@OUTPUT1@',
    '@DEPFILE@',
    '-l', slang_dict.get(host_machine.system(), 'glsl330'),
    '-f', 'sokol_impl',
    '@EXTRA_ARGS@',
  ],
)
