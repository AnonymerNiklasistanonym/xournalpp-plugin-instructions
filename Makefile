LUA_FILES := $(shell find examples -name '*.lua') $(shell find examples_shared_lib -name '*.lua')
LUA_CHECKER ?= luacheck
LUA_FORMAT ?= "${HOME}/.luarocks/bin/lua-format"
CMAKE_FILES := $(shell find examples_shared_lib -name 'CMakeLists.txt')
CMAKE_CHECKER ?= gersemi
PLUGIN_SUBDIRS := $(wildcard examples/*)

POSTFIX_PLUGIN_DESCRIPTION_TOOLBAR_PRE := \n\nIMPORTANT:\nOn xournalpp versions before 1.2.3 nightly add 'Plugin::
POSTFIX_PLUGIN_DESCRIPTION_TOOLBAR_POST := ' to a toolbar list in 'toolbar.ini' to get the toolbar icon.\n[Information on how to locate 'toolbar.ini': https://xournalpp.github.io/guide/config/toolbar-colors/]
POSTFIX_PLUGIN_DESCRIPTION := \n\nhttps://github.com/AnonymerNiklasistanonym/xournalpp-plugin-instructions

.PHONY: all
.PHONY: lua_check lua_format
.PHONY: cmake_format
.PHONY: update_plugin_descriptions

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

# Update all plugin.ini files with descriptions if found
update_plugin_descriptions:
	@for dir in $(PLUGIN_SUBDIRS); do \
		if [ -d "$$dir" ]; then \
			if [ -f "$$dir/description.txt" ] && [ -f "$$dir/plugin.ini" ]; then \
				echo "Updating $$dir plugin.ini ..."; \
				DESCRIPTION=$$(sed ':a;N;$$!ba;s/\n/\\n/g' "$$dir/description.txt"); \
				echo "Processing $$DESCRIPTION"; \
				if [ -f "$$dir/descriptionToolbar.txt" ]; then \
					DESCRIPTION_TOOLBAR="$(POSTFIX_PLUGIN_DESCRIPTION_TOOLBAR_PRE)$$(cat "$$dir/descriptionToolbar.txt")$(POSTFIX_PLUGIN_DESCRIPTION_TOOLBAR_POST)"; \
					DESCRIPTION_TOOLBAR=$$(echo "$$DESCRIPTION_TOOLBAR" | sed ':a;N;$$!ba;s/\n/\\n/g'); \
				fi; \
				DESCRIPTION=$$(printf '%s\n' "$$DESCRIPTION$$DESCRIPTION_TOOLBAR$(POSTFIX_PLUGIN_DESCRIPTION)\n" | sed 's/[&/\]/\\&/g'); \
				sed -i "/^description=/c\description=$$DESCRIPTION" "$$dir/plugin.ini"; \
			else \
				echo "Skipping $$dir (no description.txt or plugin.ini found)"; \
			fi \
		fi; \
	done
