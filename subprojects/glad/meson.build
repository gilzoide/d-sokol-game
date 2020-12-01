project('glad', 'c')

sources = files(
  'src/glad.c',
)
incdir = include_directories('src')

glad = library('glad',
  sources,
  include_directories: incdir,
)

glad_dep = declare_dependency(include_directories: incdir, link_with: glad)
