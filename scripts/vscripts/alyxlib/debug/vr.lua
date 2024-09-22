--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Adds console commands to help debugging VR specific features.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.debug.vr"
]]

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

Convars:RegisterCommand("alyxlib_print_hand_attachments", function (_, handName)
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

Convars:RegisterCommand("alyxlib_set_hand_attachment", function (_, classname, handName)
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

Convars:RegisterCommand("alyxlib_remove_hand_attachment", function (_, classname, handName)
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

Convars:RegisterCommand("alyxlib_add_hand_attachment", function (_, classname, handName)
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

return version