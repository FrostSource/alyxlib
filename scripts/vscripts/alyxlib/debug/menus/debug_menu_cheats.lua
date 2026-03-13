--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Cheats debug menu category for players.
]]

local version = "v1.0.0"

-- Simple require can cause loop with debug_menu.lua
if package.loaded["alyxlib.debug.debug_menu"] == nil then
    require "alyxlib.debug.debug_menu"
end

local categoryId = "alyxlib_cheats"

---
---Creates the AlyxLib Extras tab in the debug menu.
---
local function createTab()
    if DebugMenu:GetCategory(categoryId) then
        return
    end

    DebugMenu:AddCategory(categoryId, "Cheats")

    DebugMenu:AddToggle(categoryId, "buddha", "Buddha Mode", "buddha")

    DebugMenu:AddToggle(categoryId, "notarget", "No Target", "notarget")

    DebugMenu:AddButton(categoryId, "heal", "Heal", function()
        Entities:GetLocalPlayer():SetHealth(100)
    end)

    DebugMenu:AddSeparator(categoryId, nil, "Equipment")

    if IsVREnabled() or IsFakeVREnabled() then
        DebugMenu:AddButton(categoryId, "givegrabbity", "Give Grabbity Gloves", "hlvr_give_grabbity_gloves")
    end

    DebugMenu:AddToggle(categoryId, "infiniteammo", "Infinite Ammo", "sv_infinite_ammo")

    DebugMenu:AddButton(categoryId, "giveammo", "Give 999 Ammo", function()
        SendToConsole("hlvr_setresources 999 999 999 " .. Player:GetResin())
    end)

    DebugMenu:AddButton(categoryId, "giveresin", "Give 999 Resin", function()
        SendToConsole("hlvr_addresources 0 0 0 " .. (999 - Player:GetResin()))
    end)

    DebugMenu:SendCategoryToPanel(DebugMenu:GetCategory(categoryId))
    DebugMenu:SetCategoryIndex(categoryId, 2)

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