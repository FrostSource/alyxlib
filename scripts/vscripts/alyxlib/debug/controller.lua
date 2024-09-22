--[[
    v1.0.1
    https://github.com/FrostSource/alyxlib

    Allows quick debugging of VR controllers.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.debug.controller"
]]
-- Used for button descriptions
require "alyxlib.controls.input"

local version = "v1.0.1"


Convars:RegisterCommand("alyxlib_start_print_controller_button_presses", function (_)
    local player = Entities:GetLocalPlayer()
    if not player then
        warn("Cannot print controller buttons while player does not exist!")
        return
    end

    if not IsVREnabled() then
        warn("Cannot print controller buttons outside of VR mode!")
        return
    end

    local buttonsPressed = {[0]={},[1]={}}

    player:SetContextThink("DebugPrintControllerButtonPresses", function()

        local msgPrinted = false
        for h = 0, 1 do
            if player:GetHMDAvatar():GetVRHand(1 - h) then
                local desc = (h == 1 and "Left" or "Right")
                for i = 0, 27 do
                    -- local hand = player:GetHMDAvatar():GetVRHand(h)
                    if player:IsDigitalActionOnForHand(h, i) then
                        if not buttonsPressed[h][i] then
                            buttonsPressed[h][i] = true
                            Msg(desc .. " controller: [".. i .."] " .. Input:GetButtonDescription(i) .. "\n")
                            msgPrinted = true
                        end
                    else
                        if buttonsPressed[h][i] ~= nil then
                            buttonsPressed[h][i] = nil
                            Msg(desc .. " controller: [".. i .."] " .. Input:GetButtonDescription(i) .. " Released\n")
                        end
                    end
                end
            end
        end

        if msgPrinted then
            Msg("\n")
        end

        return 0
    end, 0)

    Msg("Started printing controller button presses. Use alyxlib_stop_print_controller_button_presses to stop...\n")
end, "", 0)

Convars:RegisterCommand("alyxlib_stop_print_controller_button_presses", function (_)
    local player = Entities:GetLocalPlayer()
    if not player then
        warn("Cannot stop printing controller buttons while player does not exist!")
        return
    end

    player:SetContextThink("DebugPrintControllerButtonPresses", nil, 0)
    Msg("Stopped printing controller button presses...\n")
end, "", 0)


Convars:RegisterCommand("alyxlib_start_print_controller_analog_positions", function (_)
    local player = Entities:GetLocalPlayer()
    if not player then
        warn("Cannot print controller buttons while player does not exist!")
        return
    end

    local analogPositions = {[0]={},[1]={}}

    player:SetContextThink("DebugPrintControllerAnalogPositions", function()

        local msgPrinted = false
        for h = 0, 1 do
            if player:GetHMDAvatar():GetVRHand(1 - h) then
                local desc = (h == 1 and "Left" or "Right")
                for i = 0, 4 do
                    local pos = Player:GetAnalogActionPositionForHand(h, i)
                    if not pos:IsSimilarTo(analogPositions[h][i]) then
                        analogPositions[h][i] = pos
                        Msg(desc .. " controller: [".. i .."] " .. Input:GetAnalogDescription(i) .. " : " .. Debug.SimpleVector(pos) .. "\n")
                    end
                end
            end
        end

        -- if msgPrinted then
        --     Msg("\n")
        -- end

        return 0
    end, 0)

    Msg("Started printing controller analog positions. Use alyxlib_stop_print_controller_analog_positions to stop...\n")
end, "", 0)

Convars:RegisterCommand("alyxlib_stop_print_controller_analog_positions", function (_)
    local player = Entities:GetLocalPlayer()
    if not player then
        warn("Cannot stop printing controller analog positions while player does not exist!")
        return
    end

    player:SetContextThink("DebugPrintControllerAnalogPositions", nil, 0)
    Msg("Stopped printing controller analog positions...\n")
end, "", 0)

return version