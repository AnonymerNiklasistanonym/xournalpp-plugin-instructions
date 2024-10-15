local a4PageHeightXournal = 842;
local a4PageHeightMm = 297;
local mmInXournalUnit = a4PageHeightXournal / a4PageHeightMm * 0.1;
-- Scale factor for z-axis depth (isometric projections)
local z_axis_scale = 0.7

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
-- rangeValues: Distance from 0 to max/min in all directions
local function create_gaussian_grid(type, step, rangeValues)
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

    -- Calculate the real length of the coordinate system lines
    local range = step * rangeValues;

    -- Calculate the center of the page
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
    table.insert(strokes, create_line_stroke(centerX, centerY,
                                             centerX + range + arrowSize *
                                                 arrowSpacing, centerY,
                                             widthAxis, color))
    if type == "2DN" or type == "3DN" then
        -- (negative axis stroke)
        table.insert(strokes,
                     create_line_stroke(
                         centerX - range - arrowSize * arrowSpacing, centerY,
                         centerX, centerY, widthAxis, color))
    end
    -- Add the y-axis
    -- (positive axis stroke)
    table.insert(strokes,
                 create_line_stroke(centerX,
                                    centerY - range - arrowSize * arrowSpacing,
                                    centerX, centerY, widthAxis, color))
    if type == "2DN" or type == "3DN" then
        -- (negative axis stroke)
        table.insert(strokes, create_line_stroke(centerX, centerY, centerX,
                                                 centerY + range + arrowSize *
                                                     arrowSpacing, widthAxis,
                                                 color))
    end

    -- If the graph type is 3D, add the z-axis
    if type == "3D" or type == "3DN" then
        -- (positive axis stroke)
        table.insert(strokes, create_line_stroke(centerX, centerY, centerX +
                                                     (range + arrowSize *
                                                         arrowSpacing) *
                                                     z_axis_scale, centerY -
                                                     (range + arrowSize *
                                                         arrowSpacing) *
                                                     z_axis_scale, widthAxis,
                                                 color))

        if type == "3DN" then
            -- (negative axis stroke)
            table.insert(strokes,
                         create_line_stroke(
                             centerX - (range + arrowSize * arrowSpacing) *
                                 z_axis_scale, centerY +
                                 (range + arrowSize * arrowSpacing) *
                                 z_axis_scale, centerX, centerY, widthAxis,
                             color))
        end
    end

    -- Add arrows to the positive end of the axes
    local arrowStrokesY = create_arrow_strokes(
                              centerX + range + arrowSize * arrowSpacing,
                              centerY, 90, arrowSize, widthArrow, color)
    local arrowStrokesX = create_arrow_strokes(centerX, centerY - range -
                                                   arrowSize * arrowSpacing, 0,
                                               arrowSize, widthArrow, color)
    for _, stroke in ipairs(arrowStrokesY) do table.insert(strokes, stroke) end
    for _, stroke in ipairs(arrowStrokesX) do table.insert(strokes, stroke) end

    -- Add z-axis arrow if 3D
    if type == "3D" or type == "3DN" then
        local arrowStrokesZ = create_arrow_strokes(centerX +
                                                       (range + arrowSize *
                                                           arrowSpacing) *
                                                       z_axis_scale, centerY -
                                                       (range + arrowSize *
                                                           arrowSpacing) *
                                                       z_axis_scale, 45,
                                                   arrowSize, widthArrow, color)
        for _, stroke in ipairs(arrowStrokesZ) do
            table.insert(strokes, stroke)
        end
    end

    -- Add tick marks
    local indexRangeStart = 0
    if type == "2DN" or type == "3DN" then indexRangeStart = -rangeValues end
    for index = indexRangeStart, rangeValues, 1 do
        if index ~= 0 then -- Skip the center of the axis (origin)
            -- Tick mark x-axis
            table.insert(strokes,
                         create_line_stroke(centerX + (index * step),
                                            centerY - tickLength,
                                            centerX + (index * step),
                                            centerY + tickLength, widthTick,
                                            color))
            -- Tick mark y-axis
            table.insert(strokes,
                         create_line_stroke(centerX - tickLength,
                                            centerY - (index * step),
                                            centerX + tickLength,
                                            centerY - (index * step), widthTick,
                                            color))
            -- Tick mark z-axis
            if type == "3D" or type == "3DN" then
                -- local x1, y1 = rotate_point(x - size / 2, y + size, x, y, degrees_to_radians(rotationDegrees))
                table.insert(strokes,
                             create_line_stroke(
                                 centerX + (index * step) * z_axis_scale -
                                     tickLength * z_axis_scale,
                                 centerY - (index * step) * z_axis_scale -
                                     tickLength * z_axis_scale,
                                 centerX + (index * step) * z_axis_scale +
                                     tickLength * z_axis_scale, centerY -
                                     (index * step) * z_axis_scale + tickLength *
                                     z_axis_scale, widthTick, color))
            end
        end
    end

    -- Add all the strokes to the Xournal++ document in one grouped action that can be undone
    app.addStrokes({["strokes"] = strokes, ["allowUndoRedoAction"] = "grouped"})
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
    local step = app.msgbox("Step size", {
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
    local range = app.msgbox("Range [0...max/min]", {
        [1] = "1",
        [2] = "2",
        [4] = "4",
        [5] = "5",
        [10] = "10",
        [15] = "15",
        [20] = "20",
    })
    if range < 1 then
        -- If a range of less than 1 is given exit (also -4 if dialog is exited)
        return -1
    end

    -- Add all strokes and then refresh the page so that the changes get rendered
    create_gaussian_grid(type, step * mmInXournalUnit, range)
    app.refreshPage()
end
