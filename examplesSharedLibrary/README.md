# Plugins that make use of shared libraries

## Build & Install

In each of the following directories you can run the following commands to build/install the plugins:

```sh
# Install Linux
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$HOME/.config/xournalpp/plugins" -DCMAKE_INSTALL_PREFIX_ICONS="$HOME/.local/share/icons"
cmake --build build -j$(nproc)
cmake --install build
# Build local plugin directory:
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="./dist"
cmake --build build -j$(nproc)
cmake --install build
```

## Structure

```text
--+ PluginName
  |
  +--plugin         (The usual plugin information)
  |  +--plugin.in
  |  +--main.lua
  |
  +--src            (C++ sources)
  +--include        (C++ headers)
  +--CMakeLists.txt (C++ build & install instructions)
```

## TODO

- Add luacheck
- Add CMake check
- Add C++ source code
- Verify Windows Support and add Install Windows section
- Add GitHub Actions
- Add example plugin that links to a program that can rasterize vector graphics / PDFs and inserts high quality raster graphics
