# ExampleSharedLibraryObject

This plugin is a demo on how to load C++ code from a shared library inside the Lua plugin code.

```lua
local helloWorld = assert(package.loadlib(libPath, "luaopen_helloWorld"))
-- return "Hello World!"
print(helloWorld())

local loadCustomObject = assert(package.loadlib(libPath, loadCustomObjectC))
loadCustomObject()
-- registers the class CustomObject
local customObject = CustomObject()
local value = customObject:getValue()
customObject:setValue(newValue)
```

Additionally a persistent C++ object can be created from the Lua plugin code that can be interacted with as if it is a normal lua object.

```lua
local loadCustomObject = assert(package.loadlib(libPath, "luaopen_loadCustomObject"))
loadCustomObject()

local customObject = CustomObject()
local value = customObject:getValue()
customObject:setValue(newValue)
```
