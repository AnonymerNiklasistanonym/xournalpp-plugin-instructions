-- table of actions: key = id, value = {func = function, label = name, accel = keyboard shortcut}
local actions = {
    pen = {
        func = function()
            print("1")
            app.uiAction({["action"] = "ACTION_TOOL_PEN"})
            -- Find possible actions in: xournalpp/src/core/plugin/ActionBackwardCompatibilityLayer.cpp
            -- (https://github.com/xournalpp/xournalpp/blob/master/src/core/plugin/ActionBackwardCompatibilityLayer.cpp)
        end,
        label = "Pen",
        accel = "<Control><Alt>1",
    },
    eraser = {
        func = function()
            print("2")
            app.uiAction({["action"] = "ACTION_TOOL_ERASER"})
        end,
        label = "Eraser",
        accel = "<Control><Alt>2",
    },
    hand = {
        func = function()
            print("3")
            app.uiAction({["action"] = "ACTION_TOOL_HAND"})
        end,
        label = "Hand Tool",
        accel = "<Control><Alt>3",
    },
    cursor = {
        func = function()
            print("4")
            app.uiAction({["action"] = "ACTION_TOOL_SELECT_OBJECT"})
        end,
        label = "Cursor Tool",
        accel = "<Control><Alt>4",
    },
    zoomIn = {
        func = function()
            print("5")
            app.uiAction({action = "ACTION_ZOOM_IN"})
        end,
        label = "Zoom In",
        accel = "<Control><Alt>5",
    },
    zoomOut = {
        func = function()
            print("6")
            app.uiAction({action = "ACTION_ZOOM_OUT"})
        end,
        label = "Zoom Out",
        accel = "<Control><Alt>6",
    },
    zoomFit = {
        func = function()
            print("7")
            app.uiAction({["action"] = "ACTION_ZOOM_FIT"})
        end,
        label = "Zoom Fit",
        accel = "<Control><Alt>7",
    },
    selection = {
        func = function()
            print("8")
            app.uiAction({["action"] = "ACTION_TOOL_SELECT_REGION"})
        end,
        label = "Selection Tool",
        accel = "<Control><Alt>8",
    },
    undo = {
        func = function()
            print("9")
            app.uiAction({["action"] = "ACTION_UNDO"})
        end,
        label = "Undo",
        accel = "<Control><Alt>9",
    },
    redo = {
        func = function()
            print("10")
            app.uiAction({["action"] = "ACTION_REDO"})
        end,
        label = "Redo",
        accel = "<Control><Alt>0",
    },
}

function initUi()
    for actionId, data in pairs(actions) do
        -- register each action with a menu entry but no toolbar icon
        app.registerUi({
            menu = "Switch to " .. data.label,
            callback = actionId,
            accelerator = data.accel,
        })
        _G[actionId] = data.func -- set global function for callback
    end
end
