local bgDotted = "dotted";

function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Update background to " .. bgDotted,       -- menu bar entry/tooltip text
        ["callback"] = "run",                                 -- function to run on click
        ["toolbarId"] = "CHANGE_BACKGROUND_TO_DOTS_SHORTCUT", -- toolbar ID
        ["iconName"] = "icon-change-background-to-dots",      -- the icon ID
    });
end

function run()
    -- set the background to dots of cuurent page
    app.changeCurrentPageBackground(bgDotted)
end
