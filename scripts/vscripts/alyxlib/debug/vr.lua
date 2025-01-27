--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Adds console commands to help debugging VR specific features.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.debug.vr"
]]

local version = "v1.0.0"

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

local function noclipVRThink()
    ---@TODO Can the player choose to move with offhand? Is there a way to check?
    local moveVector = Player:GetAnalogActionPositionForHand(Player.SecondaryHand.Literal, 3)
    local moveType = Player:GetMoveType()
    -- print(moveVector)
    if moveVector:Length() > 0 then
        local dir
        if moveType == PlayerMoveType.ContinuousHand then
            dir = (Player.SecondaryHand:GetAngles():Left() * moveVector.x) + (Player.SecondaryHand:GetAngles():Forward() * moveVector.y)
        else
            dir = (Player:EyeAngles():Left() * moveVector.x) + (Player:EyeAngles():Forward() * moveVector.y)
        end
        local velocity = dir * (Player:IsDigitalActionOnForHand(Player.SecondaryHand.Literal, 3) and Convars:GetFloat("noclip_vr_boost_speed") or Convars:GetFloat("noclip_vr_speed"))
        -- print(velocity)
        Player.HMDAnchor:SetOrigin(Player.HMDAnchor:GetOrigin() + velocity)
    end
    return 0
end

RegisterAlyxLibConvar("noclip_vr_speed", "2", "Speed of the VR noclip movement", 0)
RegisterAlyxLibConvar("noclip_vr_boost_speed", "5", "Speed of the VR noclip movement when holding trigger", 0)

RegisterAlyxLibCommand("noclip_vr", function (_, on)
    if on == nil then
        noclipVREnabled = not noclipVREnabled
    else
        noclipVREnabled = truthy(on)
    end

    if noclipVREnabled then
        Player:SetMovementEnabled(false)
        Player:SetContextThink("noclip_vr_think", noclipVRThink, 0.1)
    else
        Player:SetMovementEnabled(true)
        Player:SetContextThink("noclip_vr_think", nil, 0)
    end
end)

return version