# d-sokol-game
An experimental game made using [D](https://dlang.org/) + [sokol_gfx](https://github.com/floooh/sokol).

Currently using [GLFW](https://www.glfw.org/) for windowing with [OpenGL](https://www.opengl.org/) backend
and [Meson](https://mesonbuild.com/) for building.


## Building
First, ensure git submodules are initialized:

    $ git submodule update --init

Running `sh setup-all.sh` will setup the following build configurations with Meson:

- **build**: debug build, using GDC because it's currently the only compiler with support
  for Makefile-style dependecy files, so incremental rebuilds are done correctly.
- **build/release**: release native build, using LDC with the `betterC` flag and
  linking the executable as C, so there is no link-time or runtime dependency on
  `libphobos` or `druntime`.
- **build/web**: emscripten powered WebAssembly build, using LDC with the `betterC` flag
  for D code. If you encounter a compile error with the message `Error: version identifier WASI is reserved and cannot be set`,
  run `sh libs/remove_wasi_version_gambi.sh` for editing some druntime files as a workaround.

For building them:

    $ meson compile -C build
    $ meson compile -C build/release
    $ meson compile -C build/web

## Running
For native desktop targets, just run the executable files generated by the builds.

For the web build, open a HTTP server on `build/web`, for example with [http-server](https://www.npmjs.com/package/http-server):

    $ http-server build/web

Then access your server address and open the HTML file.