function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Change tool to purple pen", -- menu bar entry/tooltip text
        ["callback"] = "run", -- function to run on click
        ["accelerator"] = "<Ctrl>F4", -- keyboard shortcut
        ["toolbarId"] = "EXAMPLETOOLBARICONCUSTOM", -- toolbar ID
        ["iconName"] = "icon-example-toolbar-icon-custom", -- the icon ID
    })
end

function run()
    -- switch action tool to pen and color to red
    app.uiAction({["action"] = "ACTION_TOOL_PEN"})
    app.changeToolColor({["color"] = 0x80039c, ["selection"] = true})
end
