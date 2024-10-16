local globalTime;

-- os library documentation: https://www.lua.org/pil/22.1.html
-- convert number to string: https://www.lua.org/pil/2.4.html
-- concatenate strings: https://www.lua.org/pil/3.4.html

function initUi()
    -- register menu bar entry
    app.registerUi({
        ["menu"] = "Get program run time and date", -- menu bar entry text
        ["callback"] = "run", -- function to run on click
        ["accelerator"] = "<Ctrl>F2", -- keyboard shortcut
    })
    -- initalize global variable
    globalTime = os.time()
end

function run()
    -- open a message box with the current date and the total run time
    local timeDelta = os.time() - globalTime;
    app.msgbox(
        os.date("Today is %A, in %B") .. " the program was running for " ..
            tostring(timeDelta) .. "s", {[1] = "Ok"})
end
