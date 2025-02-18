# Plugins that make use of shared libraries

## Build & Install

In each of the following directories you can run the following commands to build/install the plugins:

```sh
# Build & Install Linux
# > Custom variables that are automatically set:
#   -DCMAKE_BUILD_TYPE=Release
#   -DCMAKE_INSTALL_PREFIX="$HOME/.config/xournalpp/plugins"
#   -DCMAKE_INSTALL_PREFIX_ICONS="$HOME/.local/share/icons"
# > For a local build to the directory 'dist' use:
#   -DCMAKE_INSTALL_PREFIX="dist"
cmake -B build -S .
cmake --build build -j$(nproc)
cmake --install build
```

(*It is also possible to run this in this directory to build/install all of them at the same time*)

### MinGW 64 Cross Compilation (Windows)

1. Install [MSYS2](https://www.msys2.org/)
2. Start *MSYS2 MinGW 64* shell
3. Navigate to project directory `cd /c/Users/$USER/...`

```sh
# Install build dependencies
pacman -S base-devel git pkg-config mingw-w64-x86_64-cmake mingw-w64-x86_64-lua mingw-w64-x86_64-toolchain
# Install plugin specific build dependencies
pacman -S mingw-w64-x86_64-cairo mingw-w64-x86_64-librsvg
# Build & Install Windows
# > Custom variables that are automatically set:
#   -DCMAKE_BUILD_TYPE=Release
#   -G "MinGW Makefiles"
#   -DCMAKE_INSTALL_PREFIX="/c/Users/$USER/AppData/Local/xournalpp/plugins"
#   -DCMAKE_INSTALL_PREFIX_ICONS="/c/Users/$USER/AppData/Local/icons"
# > For a local build to the directory 'dist' use:
#   -DCMAKE_INSTALL_PREFIX="dist"
cmake -B build -S .
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
  +--PreLoad.cmake  (C++ build & install instructions default settings)
```
