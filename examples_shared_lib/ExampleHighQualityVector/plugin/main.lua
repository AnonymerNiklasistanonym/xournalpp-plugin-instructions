-- Import functions from external files
getDocumentCenter = require("getDocumentCenter")
mmInXournalUnit = require("mmInXournalUnit")
getLibPath = require("getLibPath")

-- Register all Toolbar actions and initialize all UI stuff
function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Load vector image with high quality", -- menu bar entry/tooltip text
        ["callback"] = "run", -- function to run on click
        ["toolbarId"] = "EXAMPLE_HIGH_QUALITY_VECTOR", -- toolbar ID
        ["iconName"] = "icon-example-high-quality-vector", -- the icon ID
    })
end

local function mmToPixels(mm, dpi) return (mm / mmInXournalUnit) * dpi / 25.4 end

-- Callback if the menu item is executed
function run()
    -- API check
    if not app.addImages then
        -- Not available in the stable version yet
        error(
            "This version of Xournal++ does not support the API app.addImages!")
    end

    -- Load shared library
    local libPath = getLibPath("libExampleHighQualityVector")
    local rasterizeVectorImage = assert(package.loadlib(libPath,
                                                        "luaopen_rasterizeVectorImage"))

    -- Calculate target resolution for vector image
    local document = app:getDocumentStructure()
    local currentPage = document["pages"][document["currentPage"]]
    local pageWidth = currentPage["pageWidth"]
    local pageHeight = currentPage["pageHeight"]
    -- Convert the width and height to pixels
    local dpi = 200
    local pageWidthPixels = mmToPixels(pageWidth, dpi)
    local pageHeightPixels = mmToPixels(pageHeight, dpi)
    print("Target resolution: " .. pageWidthPixels .. "x" .. pageHeightPixels)

    -- Select image file
    local path = app.getFilePath({'*.svg'})
    if path == nil then
        -- Exit if no file was selected
        return
    end
    print("Selected image file: " .. path)

    -- Rasterize and add image
    local rasterizedImageFilePath = rasterizeVectorImage(path, pageWidthPixels)
    print("Output file: " .. rasterizedImageFilePath)

    local centerX, centerY = getDocumentCenter()
    app.addImages {
        images = {{path = rasterizedImageFilePath, x = centerX, y = centerY}},
    }
end
