-- Register plugin menu bar entries, toolbar icons and initialize stuff
function initUi()
    -- e.g. register menu bar entry
    app.registerUi({
        ["menu"] = "Change tool to red pen", -- menu bar entry text
        ["callback"] = "run",                -- function to run on click
        ["accelerator"] = "<Alt>F1",         -- keyboard shortcut
    });
end

function run()
    -- e.g. switch action tool to pen and color to red
    app.uiAction({["action"]="ACTION_TOOL_PEN"});
    app.changeToolColor({["color"] = 0xff0000, ["selection"] = true});
end
