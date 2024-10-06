function initUi()
    -- register menu bar entry
    app.registerUi({
        ["menu"] = "Dialog to run external commands", -- menu bar entry text
        ["callback"] = "run", -- function to run on click
        ["accelerator"] = "<Ctrl>F5", -- keyboard shortcut
    })
end

function run()
    -- open a message box
    local result = app.msgbox("What external command do you want to run?", {
        [1] = "URL",
        [2] = "Snipping Tool",
        [3] = "Rectangular Screenshot",
        [4] = "Nothing",
    })
    if result == 1 then
        -- Windows
        os.execute("start https://www.google.com/")
        -- Linux
        os.execute("xdg-open https://www.google.com/")
    end
    if result == 2 then
        -- Windows
        os.execute("SnippingTool.exe")
    end
    if result == 3 then
        -- Windows
        os.execute("explorer.exe ms-screenclip:")
    end
end
