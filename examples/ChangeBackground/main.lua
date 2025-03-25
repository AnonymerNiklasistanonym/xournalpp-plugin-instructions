-- can be found in resources-templates/pagetemplates.ini.in
local defaultBackgroundValues = {
    "plain", "lined", "ruled", "graph", "dotted", "isodotted", "isograph",
}

local function changeBg(bgValue)
    -- set the background to dots of current page
    app.changeCurrentPageBackground(bgValue)
end

function initUi()
    -- register menu bar entries and toolbar icons
    for _, bgValue in ipairs(defaultBackgroundValues) do
        -- dynamically create a global function for each background
        _G["run_" .. bgValue] = function() changeBg(bgValue) end

        -- register menu bar entry and toolbar icon
        app.registerUi({
            ["menu"] = "Update background to " .. bgValue, -- menu bar entry/tooltip text
            ["callback"] = "run_" .. bgValue, -- function to run on click
            ["toolbarId"] = "CHANGE_BACKGROUND_TO_" .. bgValue:upper() ..
                "_SHORTCUT", -- toolbar ID
            ["iconName"] = "icon-change-background-to-" .. bgValue, -- the icon ID
        })
    end
end
