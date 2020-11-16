source_root = meson.project_source_root()

shdc_folder_dict = {
  'windows': 'win32',
  'linux': 'linux',
  'darwin': 'osx',
}
slang_dict = {
  'windows': 'hlsl4',
  'linux': 'glsl330',
  'darwin': 'metal_macos:glsl330',
  'emscripten': 'glsl300es:glsl100',
}
sokol_shdc = find_program('sokol-shdc', 'sokol-shdc.exe',
  dirs: source_root / 'tools/sokol-tools-bin/bin' / shdc_folder_dict.get(build_machine.system())
)
shdc = generator(sokol_shdc,
  output: '@PLAINNAME@.h',
  arguments: [
    '--input', '@INPUT@',
    '--output', '@OUTPUT@',
    '-l', slang_dict.get(host_machine.system(), 'glsl330'),
    '@EXTRA_ARGS@',
  ],
)
