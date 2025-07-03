--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Extra debug menu category which can be enabled via the AlyxLib debug menu tab.
]]

local version = "v1.0.0"

require "alyxlib.debug.debug_menu"

local id = "alyxlib_extras"

DebugMenu:AddCategory(id, "AlyxLib Extras")

DebugMenu:AddToggle(id, id.."_showtriggers", "Show Triggers", "showtriggers")

DebugMenu:AddToggle(id, id.."_luxels", "Mat Luxels", "mat_luxels")

DebugMenu:AddToggle(id, id.."_fullbright", "Fullbright", "mat_fullbright")

DebugMenu:AddToggle(id, id.."_visfreeze", "Freeze Vis", function(on)
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