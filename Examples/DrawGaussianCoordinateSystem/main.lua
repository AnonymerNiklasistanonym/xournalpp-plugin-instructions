-- TODO All widths seem to be ignore for some reason
-- Height of a A4 page in xournal units
local a4PageHeightXournal = 842
-- Height of a A4 page in mm
local a4PageHeightMm = 297
-- Conversion factor of 1mm in xournal units
local mmInXournalUnit = a4PageHeightXournal / a4PageHeightMm
-- Scale factor for z-axis depth (isometric projections)
local zAxisIsometricScale = math.sqrt(2) / 2
-- Input option list: axes
local inputListAxes = {"X", "Y", "Z"}
-- Input option list: range
local inputListRange = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20}
-- Input option list: tick spacing
local inputListTickSpacingInMm = {2.5, 5, 7.5, 10, 15, 20, 30, 40, 50}

function initUi()
    -- Register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Draw a Gaussian coordinate system in the middle of the page", -- Menu bar entry/tooltip text
        ["callback"] = "run", -- Global function to run on click
        ["toolbarId"] = "DRAW_GAUSSIAN_COORDINATE_SYSTEM_SHORTCUT", -- Toolbar ID
        ["iconName"] = "icon-gaussian-coordinate-system", -- The icon ID
    })
end

-- Function to create a stroke for a line between two points (x1, y1) and (x2, y2)
-- (x1, y1) ---------- (x2, y2)
local function createLineStroke(x1, y1, x2, y2, width, color)
    return {
        ["x"] = {[1] = x1, [2] = x2}, -- X coordinates of the stroke
        ["y"] = {[1] = y1, [2] = y2}, -- Y coordinates of the stroke
        ["pressure"] = {[1] = 1.0, [2] = 1.0}, -- Constant pressure for simplicity
        ["tool"] = "pen", -- Use pen tool
        ["width"] = width, -- Line width
        ["color"] = color, -- Stroke color
        ["fill"] = 0, -- No fill needed
        ["lineStyle"] = "solid", -- Solid line
    }
end

local function degreesToRadians(degrees) return degrees * (math.pi / 180) end

local function rotatePoint(x, y, cx, cy, theta)
    -- Translate the point to the origin (relative to the center)
    local translated_x = x - cx
    local translated_y = y - cy
    -- Apply the rotation matrix
    local rotated_x = translated_x * math.cos(theta) - translated_y *
                          math.sin(theta)
    local rotated_y = translated_x * math.sin(theta) + translated_y *
                          math.cos(theta)
    -- Translate the point back to its original position
    local final_x = rotated_x + cx
    local final_y = rotated_y + cy

    return final_x, final_y
end

-- Function to create an arrow at the end of an axis
-- (at 0 rotationDegrees it's an upwards arrow => y-axis)
--                    (x,y)                     +
--                      ^                       |
--                     / \                      | size
--                    /   \                     |
-- (x-size/2,y+size) /     \ (x+size/2,y+size)  +
--                   +-----+
--                    size
local function createArrowStrokes(x, y, rotationDegrees, size, width, color)
    local arrow_strokes = {}
    local x1, y1 = rotatePoint(x - size / 2, y + size, x, y,
                               degreesToRadians(rotationDegrees))
    local x2, y2 = rotatePoint(x + size / 2, y + size, x, y,
                               degreesToRadians(rotationDegrees))
    table.insert(arrow_strokes, createLineStroke(x1, y1, x, y, width, color))
    table.insert(arrow_strokes, createLineStroke(x2, y2, x, y, width, color))

    return arrow_strokes
end

local function getDocumentCenter()
    local docStructure = app.getDocumentStructure()
    local pageWidth =
        docStructure["pages"][docStructure["currentPage"]]["pageWidth"]
    local pageHeight =
        docStructure["pages"][docStructure["currentPage"]]["pageHeight"]
    return pageWidth / 2, pageHeight / 2
end

local function getCurrentToolColor() return app.getToolInfo("active")["color"] end

-- Function to draw the Gaussian grid with axes, tick marks, and arrows centered on the page
-- type: Type of graph (2D, 2DN, 3D, 3DN)
-- tickSpacing: Space between tick marks
-- rangesMax = {["X"] = range,["Y"] = range,["Z"] = range}
-- rangesMin = {["X"] = -range,["Y"] = -range,["Z"] = -range,}
-- color (the color code e.g. 0x000000 for black)
local function drawGaussianCoordinateSystem(type, tickSpacing, rangesMax,
                                            rangesMin, color)
    -- TODO Use current tool size as width
    -- app.msgbox("Active tool size value " .. app.getToolInfo("active")["size"]["value"] * 10, {})
    -- Line thickness
    local widthAxis = 2
    local widthTick = 10
    local widthArrow = widthAxis
    -- Arrow
    local arrowSize = 5
    local arrowSpacing = 3
    -- Ticks
    local tickLength = 1.5
    -- Center of the page <=> (0,0) of coordinate system
    local centerX, centerY = getDocumentCenter()
    -- Table to hold all the strokes
    local strokes = {}

    -- luacheck: push ignore
    --                         (centerX,centerY-range-arrowSize*arrowSpacing)                                        +
    --                                                |                                                              |
    --                                                |                                                              | range
    --                                                |                                                              |
    -- (centerX-range-arrowSize,centerY) -----(centerX,centerY)----- (centerX+range+arrowSize*arrowSpacing,centerY)  +
    --                                                |
    --                                                |
    --                                                |
    --                              (centerX,centerY+range+arrowSize)
    --
    --                                                +--------------------------------------------------------------+
    --                                                                             range
    -- luacheck: pop

    -- Add axes
    local strokePosXAxis = createLineStroke(centerX, centerY, centerX +
                                                rangesMax["X"] * tickSpacing +
                                                arrowSize * arrowSpacing,
                                            centerY, widthAxis, color)
    table.insert(strokes, strokePosXAxis)
    if type == "2DN" or type == "3DN" then
        local strokeNegXAxis = createLineStroke(
                                   centerX - rangesMin["X"] * -tickSpacing -
                                       arrowSize, centerY, centerX, centerY,
                                   widthAxis, color)
        table.insert(strokes, strokeNegXAxis)
    end
    local strokePosYAxis = createLineStroke(centerX, centerY - rangesMax["Y"] *
                                                tickSpacing - arrowSize *
                                                arrowSpacing, centerX, centerY,
                                            widthAxis, color)
    table.insert(strokes, strokePosYAxis)
    if type == "2DN" or type == "3DN" then
        local strokeNegYAxis = createLineStroke(centerX, centerY, centerX,
                                                centerY + rangesMin["Y"] *
                                                    -tickSpacing + arrowSize,
                                                widthAxis, color)
        table.insert(strokes, strokeNegYAxis)
    end
    if type == "3D" or type == "3DN" then
        local strokePosZAxis = createLineStroke(centerX, centerY,
                                                centerX +
                                                    (rangesMax["Z"] *
                                                        tickSpacing + arrowSize *
                                                        arrowSpacing) *
                                                    zAxisIsometricScale,
                                                centerY -
                                                    (rangesMax["Z"] *
                                                        tickSpacing + arrowSize *
                                                        arrowSpacing) *
                                                    zAxisIsometricScale,
                                                widthAxis, color)
        table.insert(strokes, strokePosZAxis)
    end
    if type == "3DN" then
        local strokeNegZAxis = createLineStroke(centerX -
                                                    (-rangesMin["Z"] *
                                                        tickSpacing + arrowSize) *
                                                    zAxisIsometricScale,
                                                centerY +
                                                    (-rangesMin["Z"] *
                                                        tickSpacing + arrowSize) *
                                                    zAxisIsometricScale,
                                                centerX, centerY, widthAxis,
                                                color)
        table.insert(strokes, strokeNegZAxis)
    end

    -- Add arrows to the positive end of the axes
    local arrowStrokesY = createArrowStrokes(centerX,
                                             centerY - rangesMax["Y"] *
                                                 tickSpacing - arrowSize *
                                                 arrowSpacing, 0, arrowSize,
                                             widthArrow, color)
    for _, stroke in ipairs(arrowStrokesY) do table.insert(strokes, stroke) end
    local arrowStrokesX = createArrowStrokes(
                              centerX + rangesMax["X"] * tickSpacing + arrowSize *
                                  arrowSpacing, centerY, 90, arrowSize,
                              widthArrow, color)
    for _, stroke in ipairs(arrowStrokesX) do table.insert(strokes, stroke) end
    if type == "3D" or type == "3DN" then
        local arrowStrokesZ = createArrowStrokes(centerX +
                                                     (rangesMax["Z"] *
                                                         tickSpacing + arrowSize *
                                                         arrowSpacing) *
                                                     zAxisIsometricScale,
                                                 centerY -
                                                     (rangesMax["Z"] *
                                                         tickSpacing + arrowSize *
                                                         arrowSpacing) *
                                                     zAxisIsometricScale, 45,
                                                 arrowSize, widthArrow, color)
        for _, stroke in ipairs(arrowStrokesZ) do
            table.insert(strokes, stroke)
        end
    end

    -- Add ticks
    for _, axis in ipairs(inputListAxes) do
        local indexRangeStart = 0
        if type == "2DN" or type == "3DN" then
            indexRangeStart = rangesMin[axis]
        end
        for index = indexRangeStart, rangesMax[axis], 1 do
            if index ~= 0 then -- Skip the center of the axis (origin)
                if axis == "X" then
                    table.insert(strokes,
                                 createLineStroke(
                                     centerX + (index * tickSpacing),
                                     centerY - tickLength,
                                     centerX + (index * tickSpacing),
                                     centerY + tickLength, widthTick, color))
                elseif axis == "Y" then
                    table.insert(strokes,
                                 createLineStroke(centerX - tickLength,
                                                  centerY -
                                                      (index * tickSpacing),
                                                  centerX + tickLength,
                                                  centerY -
                                                      (index * tickSpacing),
                                                  widthTick, color))
                elseif axis == "Z" and (type == "3D" or type == "3DN") then
                    table.insert(strokes,
                                 createLineStroke(
                                     centerX + (index * tickSpacing) *
                                         zAxisIsometricScale - tickLength *
                                         zAxisIsometricScale,
                                     centerY - (index * tickSpacing) *
                                         zAxisIsometricScale - tickLength *
                                         zAxisIsometricScale,
                                     centerX + (index * tickSpacing) *
                                         zAxisIsometricScale + tickLength *
                                         zAxisIsometricScale,
                                     centerY - (index * tickSpacing) *
                                         zAxisIsometricScale + tickLength *
                                         zAxisIsometricScale, widthTick, color))
                end
            end
        end
    end

    -- Add all the strokes to the Xournal++ document in one grouped action that can be undone
    app.addStrokes({["strokes"] = strokes, ["allowUndoRedoAction"] = "grouped"})
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
    -- Round to two decimal places
    local rounded = math.floor(num * 100 + 0.5) / 100
    -- Remove trailing zeros if they exist
    if rounded == math.floor(rounded) then
        return string.format("%d", rounded) -- No decimal places
    else
        return string.format("%.2f", rounded) -- Two decimal places
    end
end

function run()
    local type = app.msgbox("Coordinate system type", {
        [1] = "2D (no negative axes)",
        [2] = "2D",
        [3] = "3D (no negative axes)",
        [4] = "3D",
    })
    if type == 1 then
        type = "2D"
    elseif type == 2 then
        type = "2DN"
    elseif type == 3 then
        type = "3D"
    elseif type == 4 then
        type = "3DN"
    else
        -- If a unsupported type is given exit (also -4 if dialog is exited)
        return -1
    end
    local tickSpacingOptions = {}
    for _, inputTickSpacingInMm in ipairs(inputListTickSpacingInMm) do
        tickSpacingOptions[inputTickSpacingInMm] =
            roundToTwoOrNoDecimals(inputTickSpacingInMm / 10) .. "cm"
    end
    local tickSpacing = app.msgbox("Select tick spacing", tickSpacingOptions)
    if tickSpacing < 1 then
        -- If a tick spacing of less than 1mm is given exit (also -4 if dialog is exited)
        return -1
    end
    local rangeOptions = {[0] = "Custom"}
    for _, inputRange in ipairs(inputListRange) do
        rangeOptions[inputRange] = inputRange
    end
    local range = app.msgbox("Select axes ranges [min...0...max]", rangeOptions)
    local rangesMax = {}
    local rangesMin = {}
    for _, inputAxis in ipairs(inputListAxes) do
        rangesMax[inputAxis] = range
        rangesMin[inputAxis] = -range
    end
    if range < 0 then
        -- If a range of less than 0 is given exit (also -4 if dialog is exited)
        return -1
    elseif range == 0 then
        -- If custom is selected create custom dialogs for each axis
        for _, axis in ipairs(inputListAxes) do
            if axis == "Z" and type ~= "3D" and type ~= "3DN" then
                goto continue
            end
            rangesMax[axis] = createRangeDialog(axis, true)
            if rangesMax[axis] < 1 then return -1 end
            if type ~= "2D" and type ~= "3D" then
                rangesMin[axis] = createRangeDialog(axis, false)
                if rangesMin[axis] < 1 then
                    return -1
                else
                    -- Fix negative value (ask for positive values to catch -4 escape)
                    rangesMin[axis] = -rangesMin[axis]
                end
            end
            ::continue::
        end
    end

    -- Add all strokes and then refresh the page so that the changes get rendered
    drawGaussianCoordinateSystem(type, tickSpacing * mmInXournalUnit, rangesMax,
                                 rangesMin, getCurrentToolColor())
    app.refreshPage()
end
