function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Make screenshot (Spectacle)", -- menu bar entry/tooltip text
        ["callback"] = "run", -- function to run on click
        ["toolbarId"] = "SPECTACLE_SHORTCUT", -- toolbar ID
        ["iconName"] = "icon-screenshot-selection", -- the icon ID
    })
    app.registerUi({
        ["menu"] = "Make screenshot of region (Spectacle)", -- menu bar entry/tooltip text
        ["callback"] = "run_region", -- function to run on click
        ["toolbarId"] = "SPECTACLE_REGION_SHORTCUT", -- toolbar ID
        ["iconName"] = "icon-screenshot-selection", -- the icon ID
    })
end

function run()
    -- start Spectacle region select process (works on all monitors)
    os.execute("spectacle --launchonly --nonotify")
end

function run_region()
    -- start Spectacle region select process (works on all monitors)
    os.execute("spectacle --region --background --nonotify")
end
