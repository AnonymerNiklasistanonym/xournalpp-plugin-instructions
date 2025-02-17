#include <plugin/plugin.hpp>
#include <plugin/util.hpp>

extern "C" {
    // Returns hello world string
    WINEXPORT int luaopen_helloWorld(lua_State* L) {
        logToLuaPrint(L, "plugin: [Shared Library Call] luaopen_helloWorld()");
        // Push a string onto the Lua stack
        lua_pushstring(L, "Hello World!");
        // Tell Lua that there is one return value on the stack
        return 1;
    }
}
