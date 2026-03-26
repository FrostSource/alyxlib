--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Default AlyxLib tab.
]]

local version = "v1.0.0"

local cheats = require("alyxlib.debug.menus.debug_menu_cheats")

RegisterAlyxLibConvar("debug_menu_cheats", "0", "Enables the cheats tab", 0, function()
    if Convars:GetBool("debug_menu_cheats") then
        cheats.createTab()
    else
        cheats.removeTab()
    end
end)

local extras = require("alyxlib.debug.menus.debug_menu_extras")

RegisterAlyxLibConvar("debug_menu_extras", "0", "Enables the extras tab", 0, function()
    if Convars:GetBool("debug_menu_extras") then
        extras.createTab()
    else
        extras.removeTab()
    end
end)

-- Add extras and cheats to settings page
if DebugMenu:GetCategory("settings") then
    DebugMenu:AddToggle("settings", "menu_cheats", "Cheats tab", "debug_menu_cheats")
    DebugMenu:AddToggle("settings", "menu_extras", "Developer tab", "debug_menu_extras")
else
    warn("Cannot add extras and cheats to settings tab: Settings tab does not exist!")
end


local categoryId = "alyxlib"

DebugMenu:AddCategory(categoryId, "AlyxLib")

DebugMenu:AddSeparator(categoryId, nil, "Basic")

if IsVREnabled() then
    DebugMenu:AddToggle(categoryId, "noclip_vr", "NoClip VR", "noclip_vr", nil, function()
        return Convars:GetBool("noclip_vr_enabled")
    end)
    DebugMenu:AddLabel(categoryId, "noclip_vr_label", "Hold movement trigger to boost")
    DebugMenu:AddSlider(categoryId, "noclip_vr_speed", "NoClip VR Speed", "noclip_vr_speed", 0.5, 10, false, 2)
    DebugMenu:AddSlider(categoryId, "noclip_vr_boost_speed", "NoClip VR Boost Speed", "noclip_vr_boost_speed", 0.5, 10, false, 2)
end

DebugMenu:AddToggle(categoryId, "gameinstructor", "Game Instructor Hints", nil,
function(on)
    Convars:SetBool("gameinstructor_enable", on)
    Convars:SetBool("sv_gameinstructor_disable", not on)
end,
function()
    return Convars:GetBool("gameinstructor_enable") and not Convars:GetBool("sv_gameinstructor_disable")
end)

DebugMenu:AddSeparator(categoryId, nil, "Session")

local isRecordingDemo = false
local currentDemo = ""

DebugMenu:AddLabel(categoryId, "demo_recording_label", "Last Demo: N/A")

DebugMenu:AddButton(categoryId, "demo_recording", "Start Recording Demo", function()
    if isRecordingDemo then
        SendToConsole("stop")
        currentDemo = ""
        isRecordingDemo = false
        DebugMenu:SetItemText(categoryId, "demo_recording", "Start Recording Demo")
    else
        local localtime = LocalTime()
        -- remove all whitespace and slashes
        local sanitizedMap = GetMapName():gsub("%s+", ""):gsub("/", "_")
        currentDemo = "demo_" .. sanitizedMap .. "_" .. localtime.Hours .. "-" .. localtime.Minutes .. "-" .. localtime.Seconds
        SendToConsole("record " .. currentDemo)
        DebugMenu:SetItemText(categoryId, "demo_recording_label", "Last Demo: " .. currentDemo .. ".dem")
        isRecordingDemo = true
        DebugMenu:SetItemText(categoryId, "demo_recording", "Stop Recording Demo")
    end
end)

return version