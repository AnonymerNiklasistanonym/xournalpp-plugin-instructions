function initUi()
    -- register menu bar entry
    app.registerUi({
        ["menu"] = "Dialog to either erase or write", -- menu bar entry text
        ["callback"] = "run",                         -- function to run on click
        ["accelerator"] = "<Ctrl>F3",                 -- keyboard shortcut
    });
end

function run()
    -- open a message box
    result = app.msgbox("What tool do you want to use?", {[1] = "Pen", [2] = "Eraser"})
    if result == 1 then
        app.uiAction({["action"]="ACTION_TOOL_PEN"})
    end
    if result == 2 then
        app.uiAction({["action"]="ACTION_TOOL_ERASER"})
    end
end
