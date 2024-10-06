function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Get current date (" .. getCurrentDate() .. ")", -- menu bar entry/tooltip text
        ["callback"] = "run",                                       -- function to run on click
        ["toolbarId"] = "GET_CURRENT_DATE_SHORTCUT",                -- toolbar ID
        ["iconName"] = "icon-current-date",                         -- the icon ID
    });
end

function getCurrentDate()
    return os.date('%Y.%m.%d');
end

function run()
    -- Linux
    os.execute("echo '" .. getCurrentDate() .. "' | xclip -selection clipboard");
    -- Windows
    os.execute('"' .. getCurrentDate() .. '" | clip.exe');
    | clip.exe;
end
