-- Scale factor for z-axis depth (isometric projections)
local zAxisIsometricScale = math.sqrt(2) / 2
-- Input option list: axes
local inputListAxes = {"X", "Y", "Z"}

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

-- Function to draw the Gaussian grid with axes, tick marks, and arrows centered on the page
-- type: Type of graph (2D, 2DN, 3D, 3DN)
-- tickSpacing: Space between tick marks
-- rangesMax = {["X"] = range,["Y"] = range,["Z"] = range}
-- rangesMin = {["X"] = -range,["Y"] = -range,["Z"] = -range,}
-- color (the color code e.g. 0x000000 for black)
local function drawGaussianCoordinateSystem(type, tickSpacing, rangesMax,
                                            rangesMin, color)
    assert(type == "2D" or type == "2DN" or type == "3D" or type == "3DN",
           "coordinate type " .. type .. " not supported")
    assert(tonumber(tickSpacing),
           "tick spacing " .. tickSpacing .. " not a number")
    -- TODO width seems to be ignored
    -- line thickness
    local widthAxis = 2
    local widthTick = 10
    local widthArrow = widthAxis
    -- arrow
    local arrowSize = 5
    local arrowSpacing = 3
    -- ticks
    local tickLength = 1.5
    -- center of the page <=> (0,0) of coordinate system
    local centerX, centerY = getDocumentCenter()
    -- table to hold all the strokes
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

    -- add axes
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

    -- add arrows to the positive end of the axes
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

    -- add ticks
    for _, axis in ipairs(inputListAxes) do
        local indexRangeStart = 0
        if type == "2DN" or type == "3DN" then
            indexRangeStart = rangesMin[axis]
        end
        for index = indexRangeStart, rangesMax[axis], 1 do
            if index ~= 0 then -- skip the center of the axis (origin)
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

    -- add all the strokes to the xournalpp document in one grouped action that can be undone
    app.addStrokes({["strokes"] = strokes, ["allowUndoRedoAction"] = "grouped"})
end

return drawGaussianCoordinateSystem
