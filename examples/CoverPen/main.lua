function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Switch to cover pen", -- menu bar entry/tooltip text
        ["callback"] = "run", -- function to run on click
        ["toolbarId"] = "COVER_PEN_SHORTCUT", -- toolbar ID
        ["iconName"] = "icon-cover-pen", -- the icon ID
    })
end

function run()
    app.uiAction({["action"] = "ACTION_TOOL_PEN"})
    app.uiAction({["action"] = "ACTION_TOOL_DRAW_RECT"})
    app.uiAction({["action"] = "ACTION_TOOL_PEN_FILL"})
    app.changeToolColor({["color"] = 0xffffff})
end
