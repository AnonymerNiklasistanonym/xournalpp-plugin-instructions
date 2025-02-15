#include <plugin/plugin.hpp>
#include <customObject.hpp>
#include <string_view>
#include <memory>
#include <plugin/util.hpp>


constexpr std::string_view LUA_METATABLE_ENTRY_CUSTOM_OBJECT = "CustomObject";

inline CustomObject* checkLuaObject(lua_State* L, int index = 1) {
    auto obj = reinterpret_cast<CustomObject**>(luaL_checkudata(L, index, LUA_METATABLE_ENTRY_CUSTOM_OBJECT.data()));
    return *obj;
}

static int luaBinding_customObject_new(lua_State* L) {
    logToLuaPrint(L, "plugin: [Shared Library Call] luaBinding_customObject_new()");

    auto valueBool = lua_toboolean(L, 1);
    auto valueNumber = luaL_checknumber(L, 2);
    auto valueString = luaL_checkstring(L, 3);

    luaL_checktype(L, 4, LUA_TTABLE);
    std::unordered_map<int, std::string> valueTable;
    lua_pushnil(L);
    while (lua_next(L, 4) != 0) {
        int key = luaL_checkinteger(L, -2);
        const char* val = luaL_checkstring(L, -1);
        valueTable[key] = val;
        // Remove value, keep key for next iteration
        lua_pop(L, 1);
    }

    CustomObject* obj = new CustomObject(valueBool, valueNumber, valueString, valueTable);
    logToLuaPrint(L, "plugin: [Shared Library Call] new CustomObject()=" + obj->debugString());

    // Push the object onto the Lua stack
    *reinterpret_cast<CustomObject**>(lua_newuserdata(L, sizeof(CustomObject*))) =
        obj;
    luaL_setmetatable(L, LUA_METATABLE_ENTRY_CUSTOM_OBJECT.data());

    // Return the new object
    return 1;
}

static int luaBinding_customObject_delete(lua_State* L) {
    logToLuaPrint(L, "plugin: [Shared Library Call] luaBinding_customObject_delete()");

    // Delete memory
    delete *reinterpret_cast<CustomObject**>(lua_touserdata(L, 1));
    return 0;
}

static int luaBinding_customObject_getBoolean(lua_State* L) {
    logToLuaPrint(L, "plugin: [Shared Library Call] luaBinding_customObject_getBoolean()");

    auto obj = checkLuaObject(L);
    auto value = obj->getBoolean();
    logToLuaPrint(L, "=> value: " + std::string(value ? "true" : "false"));
    lua_pushboolean(L, value);
    // Return 1 value
    return 1;
}

static int luaBinding_customObject_getNumber(lua_State* L) {
    logToLuaPrint(L, "plugin: [Shared Library Call] luaBinding_customObject_getNumber()");

    auto obj = checkLuaObject(L);
    auto value = obj->getNumber();
    logToLuaPrint(L, "=> value: " + std::to_string(value));
    lua_pushnumber(L, value);
    // Return 1 value
    return 1;
}

static int luaBinding_customObject_getString(lua_State* L) {
    logToLuaPrint(L, "plugin: [Shared Library Call] luaBinding_customObject_getString()");

    auto obj = checkLuaObject(L);
    auto value = obj->getString();
    logToLuaPrint(L, "=> value: " + value);
    lua_pushstring(L, value.c_str());
    // Return 1 value
    return 1;
}

static int luaBinding_customObject_getTable(lua_State* L) {
    logToLuaPrint(L, "plugin: [Shared Library Call] luaBinding_customObject_getTable()");

    auto obj = checkLuaObject(L);
    // Create a new table for the result
    lua_newtable(L);
    int i = 1;
    for (const auto& entry : obj->getTable()) {
        lua_pushinteger(L, i++);
        lua_pushstring(L, entry.second.c_str());
        lua_settable(L, -3);
    }
    return 1;
}

static int luaBinding_customObject_getTuple(lua_State* L) {
    logToLuaPrint(L, "plugin: [Shared Library Call] luaBinding_customObject_getTuple()");

    auto obj = checkLuaObject(L);
    auto tuple = obj->getTuple();
    logToLuaPrint(L, "=> value: (" + std::to_string(tuple.first) + "," + std::to_string(tuple.second) + ")");
    lua_pushnumber(L, tuple.first);
    lua_pushnumber(L, tuple.second);
    // Return 2 values
    return 2;
}

static int luaBinding_customObject_setBoolean(lua_State* L) {
    logToLuaPrint(L, "plugin: [Shared Library Call] luaBinding_customObject_setBoolean()");

    auto obj = checkLuaObject(L);
    auto value = lua_toboolean(L, 2);
    logToLuaPrint(L, "=> value: " + std::string(value ? "true" : "false"));
    obj->setBoolean(value);
    // Return nothing
    return 0;
}

static int luaBinding_customObject_setNumber(lua_State* L) {
    logToLuaPrint(L, "plugin: [Shared Library Call] luaBinding_customObject_setNumber()");

    auto obj = checkLuaObject(L);
    auto value = luaL_checknumber(L, 2);
    logToLuaPrint(L, "=> value: " + std::to_string(value));
    obj->setNumber(value);
    // Return nothing
    return 0;
}

static int luaBinding_customObject_setString(lua_State* L) {
    logToLuaPrint(L, "plugin: [Shared Library Call] luaBinding_customObject_setString()");

    auto obj = checkLuaObject(L);
    auto value = luaL_checkstring(L, 2);
    logToLuaPrint(L, "=> value: " + std::string(value));
    obj->setString(value);
    // Return nothing
    return 0;
}

static int luaBinding_customObject_setTable(lua_State* L) {
    logToLuaPrint(L, "plugin: [Shared Library Call] luaBinding_customObject_setTable()");

    auto obj = checkLuaObject(L);

    luaL_checktype(L, 2, LUA_TTABLE);
    std::unordered_map<int, std::string> valueTable;
    lua_pushnil(L);
    while (lua_next(L, 2) != 0) {
        int key = luaL_checkinteger(L, -2);
        const char* val = luaL_checkstring(L, -1);
        valueTable[key] = val;
        // Remove value, keep key for next iteration
        lua_pop(L, 1);
    }

    logToLuaPrint(L, "=> value: (table)");
    obj->setTable(valueTable);
    // Return nothing
    return 0;
}

static const luaL_Reg customObject_methods[] = {
    // Getter
    {"getBoolean", luaBinding_customObject_getBoolean},
    {"getNumber", luaBinding_customObject_getNumber},
    {"getString", luaBinding_customObject_getString},
    {"getTable", luaBinding_customObject_getTable},
    {"getTuple", luaBinding_customObject_getTuple},
    // Setter
    {"setBoolean", luaBinding_customObject_setBoolean},
    {"setNumber", luaBinding_customObject_setNumber},
    {"setString", luaBinding_customObject_setString},
    {"setTable", luaBinding_customObject_setTable},
    {NULL, NULL}  // Sentinel to indicate end of array
};

extern "C" {
    // Loads function headers into memory so Lua can access them
    WINEXPORT int luaopen_loadCustomObject(lua_State* L) {
        logToLuaPrint(L, "plugin: [Shared Library Call] luaopen_loadCustomObject()");

        // This creates a new Lua metatable associated with LUA_METATABLE_ID
        // Metatables define behavior for custom objects in Lua
        luaL_newmetatable(L, LUA_METATABLE_ENTRY_CUSTOM_OBJECT.data());

        // Set Metamethod __gc for garbage collection of Lua object
        // > obj = nil
        // > collectgarbage("collect")
        lua_pushcfunction(L, luaBinding_customObject_delete);
        lua_setfield(L, -2, "__gc");

        // Create and register the method table
        luaL_newlib(L, customObject_methods);
        lua_setfield(L, -2, "__index");

        // Pop metatable from stack
        lua_pop(L, 1);

        // Register a C function as the constructor function in the global Lua
        // namespace under the LUA_METATABLE_ID name
        // Meaning in Lua scripts it is now possible to create an object using:
        // > local obj = LUA_METATABLE_ID()
        lua_register(L, LUA_METATABLE_ENTRY_CUSTOM_OBJECT.data(), luaBinding_customObject_new);

        return 1;
    }
}
