-- Import functions from external files
getDocumentCenter = require("getDocumentCenter")
getCurrentToolColor = require("getCurrentToolColor")
mmInXournalUnit = require("mmInXournalUnit")
drawGaussianCoordinateSystem = require("drawGaussianCoordinateSystem")

-- Input option list: axes
local inputListAxes = {"X", "Y", "Z"}
-- Input option list: range
local inputListRange = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20}
-- Input option list: tick spacing
local inputListTickSpacingInMm = {2.5, 5, 7.5, 10, 15, 20, 30, 40, 50}

function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Draw a Gaussian coordinate system in the middle of the page", -- menu bar entry/tooltip text
        ["callback"] = "run", -- global function to run on click
        ["toolbarId"] = "DRAW_GAUSSIAN_COORDINATE_SYSTEM_SHORTCUT", -- toolbar ID
        ["iconName"] = "icon-gaussian-coordinate-system", -- the icon ID
    })
end

local function createRangeDialog(axis, isMax)
    local multiplier = 1
    if not isMax then multiplier = -1 end
    local options = {}
    for _, inputRange in ipairs(inputListRange) do
        options[inputRange] = inputRange * multiplier
    end
    local messageRange = "[0...max]"
    if not isMax then messageRange = "[min...0]" end
    return app.msgbox("Select " .. axis .. " axis range " .. messageRange,
                      options)
end

local function roundToTwoOrNoDecimals(num)
    -- round to two decimal places
    local rounded = math.floor(num * 100 + 0.5) / 100
    -- remove trailing zeros if they exist
    if rounded == math.floor(rounded) then
        return string.format("%d", rounded) -- no decimal places
    else
        return string.format("%.2f", rounded) -- two decimal places
    end
end

local inputCoordinateSystemType = nil
local inputTickSpacing = nil
local inputRangesMax = nil
local inputRangesMin = nil

local function drawGaussianCoordinateSystemUsingInputs()
    assert(inputCoordinateSystemType, "No coordinate system type selected")
    assert(inputTickSpacing, "No tick spacing selected")
    assert(inputRangesMax, "No max ranges selected")
    assert(inputRangesMin, "No min ranges selected")
    -- add all strokes and then refresh the page so that the changes get rendered
    drawGaussianCoordinateSystem(inputCoordinateSystemType,
                                 inputTickSpacing * mmInXournalUnit,
                                 inputRangesMax, inputRangesMin,
                                 getCurrentToolColor())
    app.refreshPage()
end

local function selectRangeMinMaxCustom()
    for _, axis in ipairs(inputListAxes) do
        if axis == "Z" and inputCoordinateSystemType ~= "3D" and
            inputCoordinateSystemType ~= "3DN" then goto continue end
        inputRangesMax[axis] = createRangeDialog(axis, true)
        if inputRangesMax[axis] < 1 then return -1 end
        if inputCoordinateSystemType ~= "2D" and inputCoordinateSystemType ~=
            "3D" then
            inputRangesMin[axis] = createRangeDialog(axis, false)
            if inputRangesMin[axis] < 1 then
                return -1
            else
                -- fix negative value (ask for positive values to catch -4 escape)
                inputRangesMin[axis] = -inputRangesMin[axis]
            end
        end
        ::continue::
    end
end

function setCoordinateSystemType(selectedCoordinateSystemType)
    inputCoordinateSystemType = selectedCoordinateSystemType
    if inputCoordinateSystemType == 1 then
        inputCoordinateSystemType = "2D"
    elseif inputCoordinateSystemType == 2 then
        inputCoordinateSystemType = "2DN"
    elseif inputCoordinateSystemType == 3 then
        inputCoordinateSystemType = "3D"
    elseif inputCoordinateSystemType == 4 then
        inputCoordinateSystemType = "3DN"
    else
        -- if a unsupported type is given exit (also -4 if dialog is exited)
        return -1
    end

    local tickSpacingOptions = {}
    for _, inputTickSpacingInMm in ipairs(inputListTickSpacingInMm) do
        tickSpacingOptions[inputTickSpacingInMm] =
            roundToTwoOrNoDecimals(inputTickSpacingInMm / 10) .. "cm"
    end
    app.openDialog("Select tick spacing", tickSpacingOptions, "setTickSpacing")
end

function setTickSpacing(selectedTickSpacing)
    inputTickSpacing = selectedTickSpacing
    if inputTickSpacing < 1 then
        -- if a tick spacing of less than 1mm is given exit (also -4 if dialog is exited)
        return -1
    end
    local rangeOptions = {[0] = "Custom"}
    for _, inputRange in ipairs(inputListRange) do
        rangeOptions[inputRange] = inputRange
    end
    app.openDialog("Select axes ranges [min...0...max]", rangeOptions,
                   "setRange")
end

function setRange(selectedRange)
    inputRangesMax = {}
    inputRangesMin = {}
    for _, inputAxis in ipairs(inputListAxes) do
        inputRangesMax[inputAxis] = selectedRange
        inputRangesMin[inputAxis] = -selectedRange
    end
    if selectedRange < 0 then
        -- if a range of less than 0 is given exit (also -4 if dialog is exited)
        return -1
    elseif selectedRange == 0 then
        -- if custom is selected create custom dialogs for each axis
        selectRangeMinMaxCustom()
    else
        drawGaussianCoordinateSystemUsingInputs()
    end
end

function run()
    if app.openDialog ~= nil then
        app.openDialog("Select coordinate system type", {
            [1] = "2D (no negative axes)",
            [2] = "2D",
            [3] = "3D (no negative axes)",
            [4] = "3D",
        }, "setCoordinateSystemType")
    else
        inputCoordinateSystemType = app.msgbox("Select coordinate system type",
                                               {
            [1] = "2D (no negative axes)",
            [2] = "2D",
            [3] = "3D (no negative axes)",
            [4] = "3D",
        })
        if inputCoordinateSystemType == 1 then
            inputCoordinateSystemType = "2D"
        elseif inputCoordinateSystemType == 2 then
            inputCoordinateSystemType = "2DN"
        elseif inputCoordinateSystemType == 3 then
            inputCoordinateSystemType = "3D"
        elseif inputCoordinateSystemType == 4 then
            inputCoordinateSystemType = "3DN"
        else
            -- if a unsupported type is given exit (also -4 if dialog is exited)
            return -1
        end
        local tickSpacingOptions = {}
        for _, inputTickSpacingInMm in ipairs(inputListTickSpacingInMm) do
            tickSpacingOptions[inputTickSpacingInMm] =
                roundToTwoOrNoDecimals(inputTickSpacingInMm / 10) .. "cm"
        end
        inputTickSpacing = app.msgbox("Select tick spacing", tickSpacingOptions)
        if inputTickSpacing < 1 then
            -- if a tick spacing of less than 1mm is given exit (also -4 if dialog is exited)
            return -1
        end
        local rangeOptions = {[0] = "Custom"}
        for _, inputRange in ipairs(inputListRange) do
            rangeOptions[inputRange] = inputRange
        end
        local range = app.msgbox("Select axes ranges [min...0...max]",
                                 rangeOptions)
        inputRangesMax = {}
        inputRangesMin = {}
        for _, inputAxis in ipairs(inputListAxes) do
            inputRangesMax[inputAxis] = range
            inputRangesMin[inputAxis] = -range
        end
        if range < 0 then
            -- if a range of less than 0 is given exit (also -4 if dialog is exited)
            return -1
        elseif range == 0 then
            -- if custom is selected create custom dialogs for each axis
            selectRangeMinMaxCustom()
        end

        drawGaussianCoordinateSystemUsingInputs()
    end
end
