function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Change tool to blue pen", -- menu bar entry/tooltip text
        ["callback"] = "run",                 -- function to run on click
        ["accelerator"] = "<Ctrl>F1",         -- keyboard shortcut
        ["toolbarId"] = "EXAMPLETOOLBARICON", -- toolbar ID
        ["iconName"] = "xopp-tool-pencil",    -- the icon ID
    });
end

function run()
    -- switch action tool to pen and color to red
    app.uiAction({["action"]="ACTION_TOOL_PEN"});
    app.changeToolColor({["color"] = 0x0000ff, ["selection"] = true});
end
