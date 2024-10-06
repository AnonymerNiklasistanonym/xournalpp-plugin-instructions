local url = "https://www.google.com/";

function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Open " .. url .. " in browser", -- menu bar entry/tooltip text
        ["callback"] = "run",                       -- function to run on click
        ["toolbarId"] = "BROWSER_SHORTCUT",         -- toolbar ID
        ["iconName"] = "icon-bookshelf",            -- the icon ID
    });
end

function run()
    -- open URL in the default browser
    -- > Windows
    os.execute("start " .. url);
    -- > Linux
    os.execute("xdg-open " .. url);
end
