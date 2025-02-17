#pragma once

#ifdef _WIN32
#define WINEXPORT __declspec(dllexport)
#else
#define WINEXPORT
#endif

#include <lua.hpp>

// Declare C functions that can be loaded within Lua
// > Their names are the IDs with which the shared library is loaded in Lua

extern "C" WINEXPORT int luaopen_helloWorld(lua_State* L);
extern "C" WINEXPORT int luaopen_loadCustomObject(lua_State* L);
