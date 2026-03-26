--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Allows debug menu additions with a 'debug_menu.cfg' file or through the console.
]]

local version = "v1.0.0"

local currentUserCategory = ""

RegisterAlyxLibCommand("debug_menu_add_category", function (_, name)
    currentUserCategory = DoUniqueString("category")
    DebugMenu:AddCategory(currentUserCategory, name or "New Category")
    DebugMenu:Refresh()
end, "Adds a new category to the debug menu")

RegisterAlyxLibCommand("debug_menu_add_button", function (_, text, command)
    if currentUserCategory == nil or currentUserCategory == "" then
        return warn("debug_menu_add_button: No category defined with debug_menu_add_category")
    end
    DebugMenu:AddButton(currentUserCategory, DoUniqueString("button"), text or "Button", command or "echo Button pressed")
    DebugMenu:Refresh()
end, "Adds a new button to the current category")

RegisterAlyxLibCommand("debug_menu_add_toggle", function (_, text, commandOff, commandOn, default)
    if currentUserCategory == nil or currentUserCategory == "" then
        return warn("debug_menu_add_toggle: No category defined with debug_menu_add_category")
    end

    if default == nil then
        if commandOn ~= nil and vlua.find({"off","on","0","1"}, string.lower(commandOn)) then
            default = string.lower(commandOn)
            commandOn = nil
        end
    else
        default = string.lower(default)
    end

    default = (default == "on" or default == "1")

    local callback
    local convar

    if string.find(commandOff, "%s") then
        -- commandOff is a convar with a value
        callback = function(on)
            SendToConsole(commandOff)
        end
        convar = string.sub(commandOff, 1, string.find(commandOff, "%s")-1)
    else
        -- commandOff is just a convar
        convar = commandOff
    end

    if commandOn ~= nil then
        callback = function(isOn)
            if isOn then
                SendToConsole(commandOn)
            else
                SendToConsole(commandOff)
            end
        end
    end

    DebugMenu:AddToggle(currentUserCategory, DoUniqueString("toggle"), text or "Toggle", convar, callback, default)
    DebugMenu:Refresh()
end, "Adds a new toggle to the current category")

RegisterAlyxLibCommand("debug_menu_add_slider", function (_, text, command, min, max, ...)
    if currentUserCategory == nil or currentUserCategory == "" then
        return warn("debug_menu_add_slider: No category defined with debug_menu_add_category")
    end

    local isPercentage = false
    local truncate = nil
    local increment = nil
    local default = nil

    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        if arg == "%" then isPercentage = true
        else
            local prefix = arg:sub(1,1)
            local value = tonumber(arg:sub(2))
            if prefix == "." then truncate = value
            elseif prefix == "+" then increment = value
            elseif prefix == "@" then default = value
            end
        end
    end

    min = tonumber(min) assert(type(min) == "number", "debug_menu_add_slider: min must be a number")
    max = tonumber(max) assert(type(max) == "number", "debug_menu_add_slider: max must be a number")
    assert(type(truncate) == "nil" or type(truncate) == "number", "debug_menu_add_slider: truncate must be a number")
    assert(type(truncate) == "nil" or type(increment) == "number", "debug_menu_add_slider: increment must be a number")

    DebugMenu:AddSlider(currentUserCategory, DoUniqueString("slider"), text or "Slider", command, min or 0, max or 1, isPercentage or false, truncate, increment, nil, default)
    DebugMenu:Refresh()
end, "Adds a new slider to the current category")

RegisterAlyxLibCommand("debug_menu_add_cycle", function (_, title, ...)
    if currentUserCategory == nil or currentUserCategory == "" then
        return warn("debug_menu_add_cycle: No category defined with debug_menu_add_category")
    end

    local rawValues = {...}
    local parsedValues = {}

    if title == nil then
        return warn("debug_menu_add_cycle: No title specified")
    end

    -- parse each text:cmd pair
    local i = 0
    for _, pair in pairs(rawValues) do
        i = i + 1
        local text,value = pair:match("([^:]+):(.+)")
        if text == nil or value == nil then
            break
        end
        table.insert(parsedValues, {text = text, value = value})
    end

    if #parsedValues == 0 then
        return warn("debug_menu_add_cycle: No values specified")
    end

    -- parse any leftover default
    local default = tonumber(rawValues[i])
    if default ~= nil and parsedValues[default] ~= nil then
        default = parsedValues[default].value
    end

    DebugMenu:AddCycle(currentUserCategory, DoUniqueString("cycle"), title or "Cycle", nil, parsedValues, function (index, item, cycle)
        SendToConsole(item.value)
    end, default)
    DebugMenu:Refresh()
end, "Adds a new cycle to the current category")

---@type string[]
local cycleMapCmds = {}

RegisterAlyxLibCommand("debug_menu_add_cycle_cmd", function(_, ...)
    for _, cmd in ipairs({...}) do
        table.insert(cycleMapCmds, cmd)
    end
end, "Defines a command for a cycle to be added with debug_menu_add_cycle_map")

RegisterAlyxLibCommand("debug_menu_add_cycle_map", function(_, title, ...)
    if currentUserCategory == nil or currentUserCategory == "" then
        return warn("debug_menu_add_cycle_map: No category defined with debug_menu_add_category")
    end

    if #cycleMapCmds == 0 then
        return warn("debug_menu_add_cycle_map: No commands defined with debug_menu_add_cycle_cmd")
    end

    local _cycleMapCmds = cycleMapCmds
    cycleMapCmds = {}

    ---@type string[]
    local rawValues = {...}
    local parsedValues = {}

    if title == nil then
        return warn("debug_menu_add_cycle: No title specified")
    end

    -- parse each text:cmd pair
    local i = 0
    for _, pair in pairs(rawValues) do
        i = i + 1
        local text,value = pair:match("([^:]+):(.+)")
        if text == nil or value == nil then
            break
        end
        ---@cast text string
        ---@cast value string

        -- single cmd cycles use convar
        if #_cycleMapCmds == 1 then
            table.insert(parsedValues, {text = text, value = value})
        else
            local cmdValues = value:split()
            if #cmdValues ~= #_cycleMapCmds then
                return warn("debug_menu_add_cycle_map: Number of values must match number of commands")
            end

            -- build full command string from values
            local cmdStr = ""
            for j = 1, #_cycleMapCmds do
                cmdStr = cmdStr .. _cycleMapCmds[j] .. " " .. cmdValues[j]
                if j < #_cycleMapCmds then
                    cmdStr = cmdStr .. "; "
                end
            end

            table.insert(parsedValues, {text = text, value = cmdStr})
        end
    end

    if #parsedValues == 0 then
        return warn("debug_menu_add_cycle: No values specified")
    end

    -- parse any leftover default
    local default = tonumber(rawValues[i])
    if default ~= nil and parsedValues[default] ~= nil then
        default = parsedValues[default].value
    end

    if #_cycleMapCmds == 1 then
        DebugMenu:AddCycle(currentUserCategory, DoUniqueString("cycle"), title or "Cycle", _cycleMapCmds[1], parsedValues, nil, default)
    else
        DebugMenu:AddCycle(currentUserCategory, DoUniqueString("cycle"), title or "Cycle", nil, parsedValues, function (index, item, cycle)
            SendToConsole(item.value)
        end, default)
    end

    DebugMenu:Refresh()
end, "Adds a new cycle to the current category using previously defined commands")

RegisterAlyxLibCommand("debug_menu_add_label", function (_, text)
    if currentUserCategory == nil or currentUserCategory == "" then
        return warn("debug_menu_add_label: No category defined with debug_menu_add_category")
    end

    DebugMenu:AddLabel(currentUserCategory, DoUniqueString("label"), text)
    DebugMenu:Refresh()
end, "Adds a new label to the current category")

RegisterAlyxLibCommand("debug_menu_add_separator", function (_, text)
    if currentUserCategory == nil or currentUserCategory == "" then
        return warn("debug_menu_add_separator: No category defined with debug_menu_add_category")
    end

    DebugMenu:AddSeparator(currentUserCategory, nil, text)
    DebugMenu:Refresh()
end, "Adds a new separator to the current category")

---Execute the debug_menu.cfg file
ListenToPlayerEvent("player_activate", function()
    SendToConsole("exec debug_menu")
end)

return version