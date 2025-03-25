local urls = {
    -- add custom entries to this list (provide a 'icon-$ID.png/.svg' file as icon!)
    -- { url = "https://www.github.com", id = "github", name = "GitHub" },
    {url = "https://www.google.com", id = "bookshelf", name = "Google"},
}

local function openUrl(url)
    -- open URL in the default browser

    local command
    if package.config:sub(1, 1) == "\\" then
        -- Windows
        command = "start " .. url
    else
        -- Linux
        command = "xdg-open " .. url
    end

    os.execute(command)
end

function initUi()
    -- register menu bar entries and toolbar icons
    for i, site in ipairs(urls) do
        -- dynamically create a global function for each site
        _G["run_" .. i] = function() openUrl(site.url) end

        -- register menu bar entry and toolbar icon
        app.registerUi({
            ["menu"] = "Open " .. site.name .. " in browser", -- menu bar entry/tooltip text
            ["callback"] = "run_" .. i, -- function to run on click
            ["toolbarId"] = "BROWSER_" .. site.id:upper() .. "_SHORTCUT", -- toolbar ID
            ["iconName"] = "icon-" .. site.id, -- the icon ID
        })
    end
end
