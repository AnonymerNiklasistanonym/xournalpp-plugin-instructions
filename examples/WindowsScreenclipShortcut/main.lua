function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Make screenshot (Screenclip)", -- menu bar entry/tooltip text
        ["callback"] = "run", -- function to run on click
        ["toolbarId"] = "WINDOWS_SCREENCLIP_SHORTCUT", -- toolbar ID
        ["iconName"] = "icon-screenshot-selection", -- the icon ID
    })
end

function run()
    -- OS check
    if package.config:sub(1, 1) ~= "\\" then
        error("Screenclip is only available on Windows!")
    end

    -- start Windows 11 screenclip process
    os.execute("explorer.exe ms-screenclip:")
end
