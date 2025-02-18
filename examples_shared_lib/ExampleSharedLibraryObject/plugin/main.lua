local isOpenDialogAvailable = app.openDialog ~= nil

-- Register all Toolbar actions and initialize all UI stuff
function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Load shared library function", -- menu bar entry/tooltip text
        ["callback"] = "run", -- function to run on click
        ["toolbarId"] = "EXAMPLE_SHARED_LIBRARY_OBJECT", -- toolbar ID
        ["iconName"] = "icon-example-shared-library-object", -- the icon ID
    })
end

local function openDialog(dialogMessage, options)
    if isOpenDialogAvailable then
        app.openDialog(dialogMessage, options)
    else
        app.msgbox(dialogMessage, options)
    end
end

local function getLibraryPath(name)
    local is_windows = package.config:sub(1, 1) == "\\"
    local script_dir = debug.getinfo(1, "S").source:sub(2)
    local plugin_dir = script_dir:match(is_windows and "(.*\\)" or "(.*/)")
    local library_path = plugin_dir .. name .. "." ..
                             (is_windows and "dll" or "so")
    return library_path
end

-- Callback if the menu item is executed
function run()
    local library_path = getLibraryPath("libExampleSharedLibraryObject")
    print("Loading library...", library_path)

    local helloWorldC = "luaopen_helloWorld"
    local helloWorld = assert(package.loadlib(library_path, helloWorldC))
    openDialog("helloWorld: " .. helloWorld(), {[1] = "OK"})

    local loadCustomObjectC = "luaopen_loadCustomObject"
    local loadCustomObject = assert(package.loadlib(library_path,
                                                    loadCustomObjectC))
    loadCustomObject()

    -- Create first object
    local customObject = CustomObject(true, -6.9, "test", {[1] = "OK"})
    local outBoolean = customObject:getBoolean()
    local outNumber = customObject:getNumber()
    local outString = customObject:getString()
    local outTable = customObject:getTable()
    local outX, outY = customObject:getTuple()
    openDialog(
        "CustomObject: outBoolean=" .. (outBoolean and "true" or "false") ..
            " outNumber=" .. outNumber .. " outString=" .. outString .. " outX=" ..
            outX .. " outY=" .. outY, outTable)

    -- Create second object
    customObject = CustomObject(false, 42, "test2", {[2] = "OKK"})
    customObject:setBoolean(true)
    customObject:setNumber(69)
    customObject:setString("new string")
    customObject:setTable({[2] = "Maybe"})
    openDialog("CustomObject (2): outString=" .. customObject:getString(),
               customObject:getTable())

    -- Manually collect garbage now which should delete the first object
    collectgarbage("collect")
    print("Collect")

    -- Manually collect garbage a second time with the second object being set
    -- to nil which should delete it
    customObject = nil -- luacheck: ignore
    collectgarbage("collect")
    print("Collect")

    -- Create third object to showcase that this one only gets cleared after the
    -- program is closed
    customObject = CustomObject(false, 3, "test3", {[3] = "OK"}) -- luacheck: ignore

    print("Unloading library...")
end
