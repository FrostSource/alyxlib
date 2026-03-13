--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Extra debug menu category for developers.
]]

local version = "v1.0.0"

-- Simple require can cause loop with debug_menu.lua
if package.loaded["alyxlib.debug.debug_menu"] == nil then
    require "alyxlib.debug.debug_menu"
end

local categoryId = "alyxlib_extras"

---
---Creates the AlyxLib Extras tab in the debug menu.
---
local function createTab()
    if DebugMenu:GetCategory(categoryId) then
        return
    end

    DebugMenu:AddCategory(categoryId, "Developer")

    DebugMenu:AddSeparator(categoryId, nil, "Display")

    -- Using a callback avoids convar warning in console
    DebugMenu:AddToggle(categoryId, "showtriggers", "Show Triggers", nil, function(on) SendToConsole("showtriggers " .. (on and 1 or 0)) end)

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

    DebugMenu:AddToggle(categoryId, "lefthanded", "Left Handed", "hlvr_left_hand_primary")

    DebugMenu:SendCategoryToPanel(DebugMenu:GetCategory(categoryId))
    DebugMenu:SetCategoryIndex(categoryId, 3)

end

---
---Removes the AlyxLib Extras tab from the debug menu.
---
local function removeTab()
    if not DebugMenu:GetCategory(categoryId) then
        return
    end

    DebugMenu:RemoveCategory(categoryId)
    DebugMenu:Refresh()
end

return {
    version = version,
    createTab = createTab,
    removeTab = removeTab
}