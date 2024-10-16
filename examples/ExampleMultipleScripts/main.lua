run = require("run")

function initUi()
    -- register menu bar entry
    app.registerUi({
        ["menu"] = "Change tool to cyan pen", -- menu bar entry/tooltip text
        ["callback"] = "run", -- function to run on click
    })
end
