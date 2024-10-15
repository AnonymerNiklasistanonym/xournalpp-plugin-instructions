local a4PageHeightXournal = 842;
local a4PageHeightMm = 297;
local mmInXournalUnit = a4PageHeightXournal / a4PageHeightMm * 0.1;
-- Scale factor for z-axis depth (isometric projections)
local z_axis_scale = math.sqrt(2) / 2

function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Draw a Gaussian coordinate system in the middle of the page", -- menu bar entry/tooltip text
        ["callback"] = "run", -- function to run on click
        ["toolbarId"] = "DRAW_GAUSSIAN_COORDINATE_SYSTEM_SHORTCUT", -- toolbar ID
        ["iconName"] = "icon-gaussian-coordinate-system", -- the icon ID
    })
end

-- Function to create a stroke for a line between two points (x1, y1) and (x2, y2)
-- (x1, y1) ---------- (x2, y2)
local function create_line_stroke(x1, y1, x2, y2, width, color)
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

local function degrees_to_radians(degrees) return degrees * (math.pi / 180) end

local function rotate_point(x, y, cx, cy, theta)
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

-- Function to create an arrow at the end of an axis (at 0 degree roation it's an up arrow)
local function create_arrow_strokes(x, y, rotationDegrees, size, width, color)
    local arrow_strokes = {}

    -- Arrow pointing upwards at 0 rotationDegrees (y-axis)
    --                    (x,y)                     +
    --                      ^                       |
    --                     / \                      | size
    --                    /   \                     |
    -- (x-size/2,y+size) /     \ (x+size/2,y+size)  +
    --                   +-----+
    --                    size

    local x1, y1 = rotate_point(x - size / 2, y + size, x, y,
                                degrees_to_radians(rotationDegrees))
    local x2, y2 = rotate_point(x + size / 2, y + size, x, y,
                                degrees_to_radians(rotationDegrees))
    table.insert(arrow_strokes, create_line_stroke(x1, y1, x, y, width, color))
    table.insert(arrow_strokes, create_line_stroke(x2, y2, x, y, width, color))

    return arrow_strokes
end

-- Function to draw the Gaussian grid with axes, tick marks, and arrows centered on the page
-- type: Type of graph (2D, 2DN, 3D, 3DN)
-- step: Distance between tick marks
-- rangesMax = {["X"] = range,["Y"] = range,["Z"] = range}
-- rangesMin = {["X"] = -range,["Y"] = -range,["Z"] = -range,}
local function create_gaussian_grid(type, step, rangesMax, rangesMin)
    local color = 0x000000
    -- Line thickness
    local widthAxis = 2
    local widthTick = 1
    local widthArrow = widthAxis
    -- Arrow
    local arrowSize = 5
    local arrowSpacing = 3
    -- Ticks
    local tickLength = 1.5

    -- Calculate the center of the page <=> (0,0)
    local docStructure = app.getDocumentStructure()
    local pageWidth =
        docStructure["pages"][docStructure["currentPage"]]["pageWidth"]
    local pageHeight =
        docStructure["pages"][docStructure["currentPage"]]["pageHeight"]
    local centerX = pageWidth / 2
    local centerY = pageHeight / 2

    -- Table to hold all the strokes
    local strokes = {}

    -- luacheck: push ignore
    --                                      (centerX,centerY-range-arrowSize*arrowSpacing)
    --                                                             |                                                              +
    --                                                             |                                                              |
    --                                                             |                                                              | range
    -- (centerX-range-arrowSize*arrowSpacing,centerY) -----(centerX,centerY)----- (centerX+range+arrowSize*arrowSpacing,centerY)  +
    --                                                             |
    --                                                             |
    --                                                             |
    --                                      (centerX,centerY+range+arrowSize*arrowSpacing)
    --
    --                                                             +-------------+
    --                                                                range
    -- luacheck: pop

    -- Add the x-axis
    -- (positive axis stroke)
    table.insert(strokes, create_line_stroke(centerX, centerY, centerX +
                                                 rangesMax["X"] * step +
                                                 arrowSize * arrowSpacing,
                                             centerY, widthAxis, color))
    if type == "2DN" or type == "3DN" then
        -- (negative axis stroke)
        table.insert(strokes,
                     create_line_stroke(
                         centerX - rangesMin["X"] * -step - arrowSize *
                             arrowSpacing, centerY, centerX, centerY, widthAxis,
                         color))
    end
    -- Add the y-axis
    -- (positive axis stroke)
    table.insert(strokes, create_line_stroke(centerX,
                                             centerY - rangesMax["Y"] * step -
                                                 arrowSize * arrowSpacing,
                                             centerX, centerY, widthAxis, color))
    if type == "2DN" or type == "3DN" then
        -- (negative axis stroke)
        table.insert(strokes, create_line_stroke(centerX, centerY, centerX,
                                                 centerY + rangesMin["Y"] *
                                                     -step + arrowSize *
                                                     arrowSpacing, widthAxis,
                                                 color))
    end

    -- If the graph type is 3D, add the z-axis
    if type == "3D" or type == "3DN" then
        -- (positive axis stroke)
        table.insert(strokes, create_line_stroke(centerX, centerY, centerX +
                                                     (rangesMax["Z"] * step +
                                                         arrowSize *
                                                         arrowSpacing) *
                                                     z_axis_scale, centerY -
                                                     (rangesMax["Z"] * step +
                                                         arrowSize *
                                                         arrowSpacing) *
                                                     z_axis_scale, widthAxis,
                                                 color))
    end
    if type == "3DN" then
        -- (negative axis stroke)
        table.insert(strokes, create_line_stroke(centerX -
                                                     (-rangesMin["Z"] * step +
                                                         arrowSize *
                                                         arrowSpacing) *
                                                     z_axis_scale, centerY +
                                                     (-rangesMin["Z"] * step +
                                                         arrowSize *
                                                         arrowSpacing) *
                                                     z_axis_scale, centerX,
                                                 centerY, widthAxis, color))
    end

    -- Add arrows to the positive end of the axes
    local arrowStrokesY = create_arrow_strokes(centerX,
                                               centerY - rangesMax["Y"] * step -
                                                   arrowSize * arrowSpacing, 0,
                                               arrowSize, widthArrow, color)
    local arrowStrokesX = create_arrow_strokes(
                              centerX + rangesMax["X"] * step + arrowSize *
                                  arrowSpacing, centerY, 90, arrowSize,
                              widthArrow, color)
    for _, stroke in ipairs(arrowStrokesY) do table.insert(strokes, stroke) end
    for _, stroke in ipairs(arrowStrokesX) do table.insert(strokes, stroke) end

    -- Add z-axis arrow if 3D
    if type == "3D" or type == "3DN" then
        local arrowStrokesZ = create_arrow_strokes(centerX +
                                                       (rangesMax["Z"] * step +
                                                           arrowSize *
                                                           arrowSpacing) *
                                                       z_axis_scale, centerY -
                                                       (rangesMax["Z"] * step +
                                                           arrowSize *
                                                           arrowSpacing) *
                                                       z_axis_scale, 45,
                                                   arrowSize, widthArrow, color)
        for _, stroke in ipairs(arrowStrokesZ) do
            table.insert(strokes, stroke)
        end
    end

    -- Add tick marks
    local axes = {"X", "Y", "Z"}
    if type == "2DN" or type == "2D" then axes = {"X", "Y"} end
    for _, axis in ipairs(axes) do
        local indexRangeStart = 0
        if type == "2DN" or type == "3DN" then
            indexRangeStart = rangesMin[axis]
        end
        for index = indexRangeStart, rangesMax[axis], 1 do
            if index ~= 0 then -- Skip the center of the axis (origin)
                if axis == "X" then
                    -- Tick mark x-axis
                    table.insert(strokes,
                                 create_line_stroke(centerX + (index * step),
                                                    centerY - tickLength,
                                                    centerX + (index * step),
                                                    centerY + tickLength,
                                                    widthTick, color))
                elseif axis == "Y" then
                    -- Tick mark y-axis
                    table.insert(strokes,
                                 create_line_stroke(centerX - tickLength,
                                                    centerY - (index * step),
                                                    centerX + tickLength,
                                                    centerY - (index * step),
                                                    widthTick, color))
                elseif axis == "Z" then
                    -- Tick mark z-axis
                    if type == "3D" or type == "3DN" then
                        table.insert(strokes,
                                     create_line_stroke(
                                         centerX + (index * step) * z_axis_scale -
                                             tickLength * z_axis_scale,
                                         centerY - (index * step) * z_axis_scale -
                                             tickLength * z_axis_scale,
                                         centerX + (index * step) * z_axis_scale +
                                             tickLength * z_axis_scale,
                                         centerY - (index * step) * z_axis_scale +
                                             tickLength * z_axis_scale,
                                         widthTick, color))
                    end
                end
            end
        end
    end

    -- Add all the strokes to the Xournal++ document in one grouped action that can be undone
    app.addStrokes({["strokes"] = strokes, ["allowUndoRedoAction"] = "grouped"})
end

local function create_range_dialog(axis, isMax)
    local multiplier = 1
    if not isMax then multiplier = -1 end
    local options = {
        [1] = "" .. (1 * multiplier),
        [2] = "" .. (2 * multiplier),
        [3] = "" .. (3 * multiplier),
        [4] = "" .. (4 * multiplier),
        [5] = "" .. (5 * multiplier),
        [6] = "" .. (6 * multiplier),
        [7] = "" .. (7 * multiplier),
        [8] = "" .. (8 * multiplier),
        [9] = "" .. (9 * multiplier),
        [10] = "" .. (10 * multiplier),
        [15] = "" .. (15 * multiplier),
        [20] = "" .. (20 * multiplier),
    }
    local messageRange = "[0...max]"
    if not isMax then messageRange = "[min...0]" end
    return app.msgbox("Select " .. axis .. " axis range " .. messageRange,
                      options)
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
    local step = app.msgbox("Select step size", {
        [25] = "0.25cm",
        [50] = "0.5cm",
        [100] = "1cm",
        [200] = "2cm",
        [400] = "3cm",
        [300] = "4cm",
        [500] = "5cm",
    })
    if step < 1 then
        -- If a step size of less than 1mm is given exit (also -4 if dialog is exited)
        return -1
    end
    local range = app.msgbox("Select range [min...0...max]", {
        [0] = "Custom",
        [1] = "1",
        [2] = "2",
        [4] = "4",
        [5] = "5",
        [10] = "10",
        [15] = "15",
        [20] = "20",
    })
    local rangesMax = {["X"] = range, ["Y"] = range, ["Z"] = range}
    local rangesMin = {["X"] = -range, ["Y"] = -range, ["Z"] = -range}
    if range < 0 then
        -- If a range of less than 0 is given exit (also -4 if dialog is exited)
        return -1
    elseif range == 0 then
        -- If custom is selected create custom dialogs for each axis
        local axes = {"X", "Y", "Z"}
        if type == "2DN" or type == "2D" then axes = {"X", "Y"} end
        for _, axis in ipairs(axes) do
            rangesMax[axis] = create_range_dialog(axis, true)
            if rangesMax[axis] < 1 then return -1 end
            if type ~= "2D" and type ~= "3D" then
                rangesMin[axis] = create_range_dialog(axis, false)
                if rangesMin[axis] < 1 then
                    return -1
                else
                    -- Fix negative value
                    rangesMin[axis] = -rangesMin[axis]
                end
            end
        end
    end

    -- Add all strokes and then refresh the page so that the changes get rendered
    create_gaussian_grid(type, step * mmInXournalUnit, rangesMax, rangesMin)
    app.refreshPage()
end
