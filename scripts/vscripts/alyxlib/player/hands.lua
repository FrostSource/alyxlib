--[[
    v1.3.1
    https://github.com/FrostSource/alyxlib

    Code for player hands.
    
    If not using `alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.player.hands"
]]

local version = "v1.3.1"

---
---Merges an existing prop with this hand.
---
---@param prop EntityHandle|string # The prop handle or targetname
---@param hide_hand boolean # `true` if the hand should turn invisible after merging
function CPropVRHand:MergeProp(prop, hide_hand)
    if type(prop) == "string" then
        prop = Entities:FindByName(nil, prop)
    end
    if IsValidEntity(prop) then
        local glove = self:GetGlove()
        if not glove then
            Warning("Trying to merge prop with glove but glove was not found!\n")
            return
        end
        -- don't use FollowEntity
        prop:SetParent(glove, "!bonemerge")
        if hide_hand then glove:SetRenderAlpha(0) end
    else
        Warning("Could not find prop '"..tostring(prop).."' to merge with hand.\n")
    end
end

---
---Checks if this hand is currently holding a prop.
---
---@return boolean # `true` if the hand is holding a prop
function CPropVRHand:IsHoldingItem()
    return IsEntity(self.ItemHeld, true)
end

---
---Drops the item held by this hand.
---
---@return EntityHandle? # The entity that was dropped
function CPropVRHand:Drop()
    if self.ItemHeld ~= nil then
        Player:DropByHandle(self.ItemHeld)
        ---@TODO: Make sure this doesn't return nil
        return self.ItemHeld
    end
end

---
---Forces this hand to grab an entity.
---
---@param ent EntityHandle|string # The entity or targetname to grab
function CPropVRHand:Grab(ent)
    if type(ent) == "string" then
        local name = ent
        ent = Entities:FindByName(nil, name)
        if ent == nil then
            return warn("Could not find entity to grab with name " .. name)
        end
    end

    ent:Grab(self)
end

---
---Gets the rendered glove entity for this hand,
---i.e. the first `hlvr_prop_renderable_glove` class.
---
---@return EntityHandle? # The glove entity
function CPropVRHand:GetGlove()
    return self:GetFirstChildWithClassname("hlvr_prop_renderable_glove")
end

---
---Gets grabbity glove entity for this hand (the animated part on the glove).
---
---@return EntityHandle|nil # The grabbity glove
function CPropVRHand:GetGrabbityGlove()
    return self:GetFirstChildWithClassname("prop_grabbity_gloves")
end

---
---Checks if a digital action is on for this hand.
---
---Note: Only reports input when headset is awake. Will still transmit input when controller loses tracking.
---
---@see DigitalInputAction
---@param digitalAction DigitalInputAction # The action to check
---@return boolean # `true` if the action is on
function CPropVRHand:IsButtonPressed(digitalAction)
    return Player:IsDigitalActionOnForHand(self.Literal, digitalAction)
end

---
---Gets the position of the palm of this hand.
---
---Returns the palm of the glove if it exists, otherwise the palm of the invisible hand.
---
---Sometimes the glove becomes desynchronized with the hand, such as interacting with a handpose or holding a weapon,
---so this function will try to return the position of the visible palm whenever possible.
---
---@return Vector # The palm position
function CPropVRHand:GetPalmPosition()
    local glove = self:GetGlove()
    if glove then
        return glove:GetAttachmentOrigin(glove:ScriptLookupAttachment("vr_palm"))
    else
        return self:GetAttachmentOrigin(self:ScriptLookupAttachment("vr_hand_origin"))
    end
end

---
---Gets the 'hand_use_controller' entity associated with this hand.
---
---@return EntityHandle # The hand_use_controller
function CPropVRHand:GetHandUseController()
    for _, controller in ipairs(Entities:FindAllByClassname("hand_use_controller")) do
        if controller:GetOwner() == self then
            return controller
        end
---@diagnostic disable-next-line: missing-return
    end
end

---
---Forces the player to drop this entity if held.
---
function CBaseEntity:Drop()
    Player:DropByHandle(self)
end
Expose(CBaseEntity.Drop, "Drop", CBaseEntity)

---
---Forces the player to grab this entity with a hand.
---
---If no hand is supplied then the nearest hand will be used.
---
---@param hand? CPropVRHand|0|1 # Hand to grab with
function CBaseEntity:Grab(hand)
    Player:GrabByHandle(self, hand)
end
Expose(CBaseEntity.Grab, "Grab", CBaseEntity)

return version