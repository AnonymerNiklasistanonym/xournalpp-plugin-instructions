local fontSize = 12
local fontColor = 0x000000

local function getCurrentDate() return os.date('%Y.%m.%d') end

function initUi()
    local description = "Add current date at the top right (" ..
                            getCurrentDate() .. ")"
    if app.addTexts ~= nil then -- check if the xournalpp supports adding text
        description =
            "Copy current date to the clipboard (" .. getCurrentDate() .. ")"
    end
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = description, -- menu bar entry/tooltip text
        ["callback"] = "run", -- function to run on click
        ["toolbarId"] = "GET_CURRENT_DATE_SHORTCUT", -- toolbar ID
        ["iconName"] = "icon-current-date", -- the icon ID
    })
end

local function addTextToClipboard(text)
    -- Linux
    os.execute("echo '" .. text .. "' | xclip -selection clipboard")
    -- Windows
    os.execute("echo " .. text .. " | clip.exe")
end

function run()
    local dateString = getCurrentDate()

    -- add the current date to the current page (at the top right)
    if app.addTexts ~= nil then -- check if the xournalpp supports adding text
        local docStructure = app.getDocumentStructure()
        local toolInfoText = app.getToolInfo("text")

        app.addTexts({
            texts = {
                {
                    text = dateString,
                    font = {
                        name = toolInfoText["font"]["name"],
                        size = fontSize,
                    },
                    color = fontColor,
                    x = docStructure["pages"][docStructure["currentPage"]]["pageWidth"] -
                        string.len(dateString) * fontSize,
                    y = fontSize * 2,
                },
            },
        })
    end

    app.refreshPage()

    -- copy the current date to the clipboard
    addTextToClipboard(dateString)
end
