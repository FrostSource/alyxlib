--[[
    v1.0.1
    https://github.com/FrostSource/alyxlib

    Adds console commands to help debugging VR specific features.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.debug.vr"
]]

local version = "v1.0.1"

---Get a hand entity from its name.
---@param handName string
---@return CPropVRHand?
local function getHandFromName(handName)
    ---@type CPropVRHand
    local hand
    handName = handName:lower()
    if handName == "right" then hand = Player.RightHand
    elseif handName == "left" then hand = Player.LeftHand
    elseif handName == "primary" then hand = Player.PrimaryHand
    elseif handName == "secondary" then hand = Player.SecondaryHand
    elseif handName == "0" then hand = Player.Hands[0]
    elseif handName == "1" then hand = Player.Hands[1]
    end
    return hand
end

Convars:RegisterCommand("print_hand_attachments", function (_, handName)
    handName = handName or "primary"
    local hand = getHandFromName(handName)
    if hand == nil then
        warn(handName .. " is not a valid hand. Use one of the following: left,right,primary,secondary,0,1\n")
        return
    end

    local attachments = {}
    local attachment = hand:GetHandAttachment()
    local i = 1
    while attachment ~= nil do
        print("["..i.."] " .. attachment:GetClassname())
        i = i + 1

        table.insert(attachments, 1, attachment)
        hand:RemoveHandAttachmentByHandle(attachment)
        attachment = hand:GetHandAttachment()
    end

    for index, value in ipairs(attachments) do
        hand:AddHandAttachment(value)
    end
end, "", 0)

Convars:RegisterCommand("set_hand_attachment", function (_, classname, handName)
    handName = handName or "primary"
    local hand = getHandFromName(handName)
    if hand == nil then
        warn(handName .. " is not a valid hand. Use one of the following: left,right,primary,secondary,0,1\n")
        return
    end

    if not Entities:FindByClassname(nil, classname) then
        warn("No classname " .. classname .. " exists!\n")
        return
    end

    Player:SetWeapon(classname)
end, "", 0)

Convars:RegisterCommand("remove_hand_attachment", function (_, classname, handName)
    handName = handName or "primary"
    local hand = getHandFromName(handName)
    if hand == nil then
        warn(handName .. " is not a valid hand. Use one of the following: left,right,primary,secondary,0,1\n")
        return
    end

    if not Entities:FindByClassname(nil, classname) then
        warn("No classname " .. classname .. " exists!\n")
        return
    end

    Player:RemoveWeapons(classname)
end, "", 0)

Convars:RegisterCommand("add_hand_attachment", function (_, classname, handName)
    handName = handName or "primary"
    local hand = getHandFromName(handName)
    if hand == nil then
        warn(handName .. " is not a valid hand. Use one of the following: left,right,primary,secondary,0,1\n")
        return
    end

    local ent = Entities:FindByClassname(nil, classname)
    if not ent then
        warn("No classname " .. classname .. " exists!\n")
        return
    end

    hand:AddHandAttachment(ent)
end, "", 0)


local noclipVREnabled = false

---Tracks initial button press to prevent repeated logic execution while held
local quickTurnFlag = false

local function noclipVRThink()
    -- Check offhand first because it's most common, then check primary hand movement
    local moveVector = Player:GetAnalogActionPositionForHand(Player.SecondaryHand.Literal, ANALOG_INPUT_TELEPORT_TURN)
    if #moveVector == 0 then
        moveVector = Player:GetAnalogActionPositionForHand(Player.PrimaryHand.Literal, ANALOG_INPUT_TELEPORT_TURN)
    end

    if moveVector:Length() > 0 then
        local moveType = Player:GetMoveType()
        local dir

        if moveType == PlayerMoveType.ContinuousHand then
            dir = (Player.SecondaryHand:GetAngles():Left() * moveVector.x) + (Player.SecondaryHand:GetAngles():Forward() * moveVector.y)
        else
            dir = (Player:EyeAngles():Left() * moveVector.x) + (Player:EyeAngles():Forward() * moveVector.y)
        end

        local velocity = dir * (Player:IsDigitalActionOnForHand(Player.SecondaryHand.Literal, 3) and Convars:GetFloat("noclip_vr_boost_speed") or Convars:GetFloat("noclip_vr_speed"))

        Player.HMDAnchor:SetOrigin(Player.HMDAnchor:GetOrigin() + velocity)
    end

    -- Custom turning is required because turning seems to stop working above certain speeds

    local turnSign = 0
    if Player:IsDigitalActionOnForHand(0, DIGITAL_INPUT_TURN_LEFT) or Player:IsDigitalActionOnForHand(1, DIGITAL_INPUT_TURN_LEFT) then
        turnSign = 1
    elseif Player:IsDigitalActionOnForHand(0, DIGITAL_INPUT_TURN_RIGHT) or Player:IsDigitalActionOnForHand(1, DIGITAL_INPUT_TURN_RIGHT) then
        turnSign = -1
    else
        quickTurnFlag = false
    end

    if turnSign ~= 0 then
        local angles = Player.HMDAnchor:GetAngles()
        local amount = 0

        if Convars:GetBool("vr_quick_turn_continuous_enable") then
            local speed = Convars:GetFloat("vr_quick_turn_continuous_speed") or 0
            amount = speed * FrameTime() * turnSign
        elseif Convars:GetBool("vr_teleport_quick_turn_enable") and not quickTurnFlag then
            local speed = Convars:GetFloat("vr_teleport_quick_turn_angle") or 0
            amount = speed * turnSign
            quickTurnFlag = true
        end

        Player.HMDAnchor:SetAngles(angles.x, angles.y + amount, angles.z)
    end

    return 0
end

RegisterAlyxLibConvar("noclip_vr_speed", "2", "Speed of the VR noclip movement", 0)
RegisterAlyxLibConvar("noclip_vr_boost_speed", "5", "Speed of the VR noclip movement when holding trigger", 0)

---Used to track user's movement type so it can be reset
local movetype = Convars:GetInt('hlvr_movetype_default')

RegisterAlyxLibCommand("noclip_vr", function (_, on)
    if on == nil then
        noclipVREnabled = not noclipVREnabled
    else
        noclipVREnabled = truthy(on)
    end

    if noclipVREnabled then
        movetype = Convars:GetInt("hlvr_movetype_default")

        -- Movetype 2 blocks turning with movement disabled
        -- This might cause problems if the server resets before the command is turned off
        -- but the game does seem to remember the user's settings so far
        SendToConsole("vr_movetype_set 2")

        SendToConsole("god 1")
        Player:SetMovementEnabled(false)
        Player:SetContextThink("noclip_vr_think", noclipVRThink, 0.1)
    else
        SendToConsole("vr_movetype_set " .. movetype)
        SendToConsole("god 0")
        Player:SetMovementEnabled(true)
        Player:SetContextThink("noclip_vr_think", nil, 0)
    end
end, "Enables a continuous movement noclip while in VR", 0)

return version