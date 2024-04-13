--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Allows quick debugging of VR controllers.

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "alyxlib.debug.controller"
    ```
]]

-- Used for button descriptions
require "alyxlib.input.input"


Convars:RegisterCommand("alyxlib_start_print_controller_button_presses", function (_)
    local player = Entities:GetLocalPlayer()
    if not player then
        warn("Cannot print controller buttons while player does not exist!")
        return
    end

    local buttonsPressed = {[0]={},[1]={}}

    player:SetContextThink("DebugPrintControllerButtonPresses", function()

        local msgPrinted = false
        for h = 0, 1 do
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
                    buttonsPressed[h][i] = nil
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
