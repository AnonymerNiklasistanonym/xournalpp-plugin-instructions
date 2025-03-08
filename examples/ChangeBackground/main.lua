-- can be found in resources-templates/pagetemplates.ini.in
local defaultBackgroundValues = {
    "plain", "lined", "ruled", "graph", "dotted", "isodotted", "isograph",
}

function initUi()
    -- register menu bar entries and toolbar icons

    for _, bgValue in ipairs(defaultBackgroundValues) do
        local toolbarId = "CHANGE_BACKGROUND_TO_" .. string.upper(bgValue) ..
                              "_SHORTCUT"
        local iconName = "icon-change-background-to-" .. bgValue

        app.registerUi({
            ["menu"] = "Update background to " .. bgValue, -- menu bar entry/tooltip text
            ["callback"] = "run_" .. bgValue,
            ["toolbarId"] = toolbarId, -- toolbar ID
            ["iconName"] = iconName, -- the icon ID
        })
    end
end

local function run(bgValue)
    -- set the background to dots of current page
    app.changeCurrentPageBackground(bgValue)
end

function run_dotted() run("dotted") end

function run_plain() run("plain") end

function run_lined() run("lined") end

function run_ruled() run("ruled") end

function run_graph() run("graph") end

function run_isodotted() run("isodotted") end

function run_isograph() run("isograph") end
