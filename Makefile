LUA_FILES := $(shell find Examples -name '*.lua')
LUA_CHECKER ?= luacheck
LUA_FORMAT ?= "${HOME}/.luarocks/bin/lua-format"

all: check

# Check all Lua files
check:
	@$(LUA_CHECKER) $(LUA_FILES)

# Format all Lua files
format:
	@$(LUA_FORMAT) $(LUA_FILES) -i --extra-sep-at-table-end

.PHONY: all check
