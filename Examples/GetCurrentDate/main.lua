local fontSize = 12
local fontColor = 0x000000

local function getCurrentDate() return os.date('%Y.%m.%d') end

function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Get current date (" .. getCurrentDate() .. ")", -- menu bar entry/tooltip text
        ["callback"] = "run", -- function to run on click
        ["toolbarId"] = "GET_CURRENT_DATE_SHORTCUT", -- toolbar ID
        ["iconName"] = "icon-current-date", -- the icon ID
    })
end

function run()
    local dateString = getCurrentDate()

    if app.addTexts ~= nil then
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

    -- Copy the current date to the clipboard
    -- Linux
    os.execute("echo '" .. dateString .. "' | xclip -selection clipboard")
    -- Windows
    os.execute("echo " .. dateString .. " | clip.exe")
end
