local function run()
    -- switch action tool to pen and color to cyan
    app.uiAction({["action"] = "ACTION_TOOL_PEN"})
    app.changeToolColor({["color"] = 0x00ffff, ["selection"] = true})
end

return run
