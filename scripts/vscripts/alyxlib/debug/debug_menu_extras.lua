--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Extra debug menu category which can be enabled via the AlyxLib debug menu tab.
]]

local version = "v1.0.0"

require "alyxlib.debug.debug_menu"

local categoryId = "alyxlib_extras"

DebugMenu:AddCategory(categoryId, "AlyxLib Extras")

DebugMenu:AddSeparator(categoryId, nil, "Display")

DebugMenu:AddToggle(categoryId, "showtriggers", "Show Triggers", "showtriggers")

DebugMenu:AddToggle(categoryId, "luxels", "Mat Luxels", "mat_luxels")

DebugMenu:AddToggle(categoryId, "fullbright", "Fullbright", "mat_fullbright")

DebugMenu:AddToggle(categoryId, "visibility", "Vis", "vis_enable")

DebugMenu:AddToggle(categoryId, "cubemapcolors", "Cubemap Colors", "r_cubemap_debug_colors")

DebugMenu:AddToggle(categoryId, categoryId.."_visfreeze", "Freeze Vis", nil, function(on)
    if on then
        SendToConsole("vis_debug_show 1")
        Player:Delay(function()
            SendToConsole("vis_debug_lock 1")
        end)
    else
        SendToConsole("vis_debug_show 0")
        SendToConsole("vis_debug_lock 0")
    end
end)

return version