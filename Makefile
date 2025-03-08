LUA_FILES := $(shell find examples -name '*.lua') $(shell find examples_shared_lib -name '*.lua')
LUA_CHECKER ?= luacheck
LUA_FORMAT ?= "${HOME}/.luarocks/bin/lua-format"
CMAKE_FILES := $(shell find examples_shared_lib -name 'CMakeLists.txt')
CMAKE_CHECKER ?= gersemi
PLUGIN_SUBDIRS := $(wildcard examples/*)

.PHONY: all
.PHONY: lua_check lua_format
.PHONY: cmake_format

all: lua_check

# Check all Lua files
lua_check:
	@$(LUA_CHECKER) $(LUA_FILES)

# Format all Lua files
lua_format:
	@$(LUA_FORMAT) $(LUA_FILES) -i --extra-sep-at-table-end

# Check all CMakeLists.txt files
cmake_format:
	@$(CMAKE_CHECKER) --in-place $(CMAKE_FILES)
