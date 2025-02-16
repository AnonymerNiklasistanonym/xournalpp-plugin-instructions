#pragma once

#include <lua.hpp>
#include <string>

static void logToLuaPrint(lua_State* L, const std::string& message) {
    // Push the `print` function onto the stack
    lua_getglobal(L, "print");

    // Push the message onto the stack
    lua_pushstring(L, message.c_str());

    // Call print(message)
    if (lua_pcall(L, 1, 0, 0) != LUA_OK) {
        // Handle any Lua errors
        const char* error = lua_tostring(L, -1);
        fprintf(stderr, "Error during logToLuaPrint: %s\n", error);
        // Pop the error message from Lua stack
        lua_pop(L, 1);
    }
}

static void logToLuaError(lua_State* L, const std::string& message) {
    luaL_error(L, "plugin-error: %s", message.c_str());
}
