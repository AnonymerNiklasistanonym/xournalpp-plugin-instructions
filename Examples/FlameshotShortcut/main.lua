function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Make screenshot (Flameshot)",   -- menu bar entry/tooltip text
        ["callback"] = "run",                       -- function to run on click
        ["toolbarId"] = "FLAMESHOT_SHORTCUT",       -- toolbar ID
        ["iconName"] = "icon-screenshot-selection", -- the icon ID
    });
end

function run()
    -- start flameshot launcher process
    os.execute("flameshot launcher");
end
