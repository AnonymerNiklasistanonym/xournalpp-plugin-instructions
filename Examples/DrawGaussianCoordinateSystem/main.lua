local a4PageHeightXournal = 842;
local a4PageHeightMm = 297;
local mmInXournalUnit = a4PageHeightXournal / a4PageHeightMm * 0.1;

function initUi()
    -- register menu bar entry and toolbar icon
    app.registerUi({
        ["menu"] = "Draw a Gaussian coordinate system in the middle of the page", -- menu bar entry/tooltip text
        ["callback"] = "run",                                                     -- function to run on click
        ["toolbarId"] = "DRAW_GAUSSIAN_COORDINATE_SYSTEM_SHORTCUT",               -- toolbar ID
        ["iconName"] = "icon-gaussian-coordinate-system",                         -- the icon ID
    });
end

-- Function to create a stroke for a line between two points (x1, y1) and (x2, y2)
-- (x1, y1) ---------- (x2, y2)
function create_line_stroke(x1, y1, x2, y2, width, color)
    return {
        ["x"] = { [1] = x1, [2] = x2 },           -- X coordinates of the stroke
        ["y"] = { [1] = y1, [2] = y2 },           -- Y coordinates of the stroke
        ["pressure"] = { [1] = 1.0, [2] = 1.0 },  -- Constant pressure for simplicity
        ["tool"] = "pen",                         -- Use pen tool
        ["width"] = width,                        -- Line width
        ["color"] = color,                        -- Stroke color
        ["fill"] = 0,                             -- No fill needed
        ["lineStyle"] = "solid"                   -- Solid line
    }
end

-- Function to create an arrow at the end of an axis
function create_arrow_strokes(x, y, direction, size, width, color)
    local arrow_strokes = {}

    if direction == "right" then
        -- Arrow pointing to the right (x-axis)
        -- (x-size,y-size/2) \            +
        --                    \           |
        --                     \          |
        --                      \         |
        --                       > (x,y)  | size
        --                      /         |
        --                     /          |
        --                    /           |
        -- (x-size,y+size/2) /            +
        --                 +------+
        --                   size
        table.insert(arrow_strokes, create_line_stroke(x - size, y - size / 2, x, y, width, color))
        table.insert(arrow_strokes, create_line_stroke(x - size, y + size / 2, x, y, width, color))
    elseif direction == "up" then
        -- Arrow pointing upwards (y-axis)
        --                    (x,y)                     +
        --                      ^                       |
        --                     / \                      | size
        --                    /   \                     |
        -- (x-size/2,y+size) /     \ (x+size/2,y+size)  +
        --                   +-----+
        --                    size

        table.insert(arrow_strokes, create_line_stroke(x - size / 2, y + size, x, y, width, color))
        table.insert(arrow_strokes, create_line_stroke(x + size / 2, y + size, x, y, width, color))
    end

    return arrow_strokes
end

-- Function to draw the Gaussian grid with axes, tick marks, and arrows centered on the page
-- step: Distance between tick marks
-- rangeValues: Distance from 0 to max/min in all directions
function create_gaussian_grid(step, rangeValues)
    local color = 0x000000
    -- Line thickness
    local widthAxis = 4
    local widthTick = 2
    local widthArrow = 4
    -- Arrow
    local arrowSize = 5
    local arrowSpacing = 3
    -- Ticks
    local tickLength = 2

    -- Calculate the real length of the coordinate system lines
    local range = step * rangeValues;

    -- Calculate the center of the page
    local docStructure = app.getDocumentStructure()
    local pageWidth = docStructure["pages"][docStructure["currentPage"]]["pageWidth"]
    local pageHeight = docStructure["pages"][docStructure["currentPage"]]["pageHeight"]
    local centerX = pageWidth / 2
    local centerY = pageHeight / 2

    -- Table to hold all the strokes
    local strokes = {}

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

    -- Add the x-axis
    table.insert(strokes, create_line_stroke(centerX - range - arrowSize * arrowSpacing, centerY, centerX + range + arrowSize * arrowSpacing, centerY, widthAxis, color));
    -- Add the y-axis
    table.insert(strokes, create_line_stroke(centerX, centerY - range - arrowSize * arrowSpacing, centerX, centerY + range + arrowSize * arrowSpacing, widthAxis, color));

    -- Add arrows to the positive end of the axes
    local arrowStrokesY = create_arrow_strokes(centerX + range + arrowSize * 3, centerY, "right", arrowSize, widthArrow, color)  -- X-axis arrow
    local arrowStrokesX = create_arrow_strokes(centerX, centerY - range - arrowSize * 3, "up", arrowSize, widthArrow, color)   -- Y-axis arrow (now at negative end)
    for _, stroke in ipairs(arrowStrokesY) do table.insert(strokes, stroke) end
    for _, stroke in ipairs(arrowStrokesX) do table.insert(strokes, stroke) end

    -- Add tick marks
    for index = -rangeValues, rangeValues, 1 do
        if x ~= 0 then  -- Skip the center of the axis (origin)
            -- Tick mark: a short vertical line centered on the x-axis, with doubled length and spacing
            table.insert(strokes, create_line_stroke(centerX + (index * step), centerY - tickLength, centerX + (index * step), centerY + tickLength, widthTick, color))
            table.insert(strokes, create_line_stroke(centerX - tickLength, centerY + (index * step), centerX + tickLength, centerY + (index * step), widthTick, color))
        end
    end

    -- Add all the strokes to the Xournal++ document in one grouped action that can be undone
    app.addStrokes({["strokes"] = strokes, ["allowUndoRedoAction"] = "grouped"})
end


function run()
    step =  app.msgbox("Step size", {[25] = "0.25cm", [50] = "0.5cm", [100] = "1cm", [200] = "2cm", [400] = "3cm", [300] = "4cm", [500] = "5cm"});
    range = app.msgbox("Range [0...max/min]", {[1] = "1", [2] = "2", [4] = "4", [5] = "5", [10] = "10", [15] = "15", [20] = "20"});

    -- add all strokes and then refresh the page so that the changes get rendered
    create_gaussian_grid(step * mmInXournalUnit, range);
    app.refreshPage();
end
