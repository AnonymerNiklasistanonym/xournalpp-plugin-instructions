#include <plugin/plugin.hpp>
#include <plugin/util.hpp>
#include <rasterizeVectorImage.hpp>

#include <format>

#ifdef _WIN32
#include <fixWin32Filesystem.hpp>
#endif


extern "C" {
    // Returns hello world string
    WINEXPORT int luaopen_rasterizeVectorImage(lua_State* L) {
        logToLuaPrint(L, "plugin: [Shared Library Call] luaopen_rasterizeVectorImage()");

        const auto valuePath = luaL_checkstring(L, 1);
        const auto valueResolution = luaL_checknumber(L, 2);

        try
        {
            logToLuaPrint(L, std::format("=> load: '{}' ({})", valuePath, valueResolution));
            const auto outPath = rasterizeVectorImage(valuePath, valueResolution);
            logToLuaPrint(L, std::format("=> outPath: '{}'", outPath.string()));
            #ifdef _WIN32
            lua_pushstring(L, pathToUtf8(outPath).c_str());
            #else
            lua_pushstring(L, outPath.c_str());
            #endif
        }
        catch(const std::exception& e)
        {
            logToLuaError(L, e.what());
            return 0;
        }

        // Tell Lua that there is one return value on the stack
        return 1;
    }
}
