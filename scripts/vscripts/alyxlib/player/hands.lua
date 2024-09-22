--[[
    v1.0.1
    https://github.com/FrostSource/alyxlib

    Code for player hands.
    
]]

local version = "v1.0.1"

---Merge an existing prop with this hand.
---@param prop EntityHandle|string # The prop handle or targetname.
---@param hide_hand boolean # If the hand should turn invisible after merging.
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

---Return true if this hand is currently holding a prop.
---@return boolean
function CPropVRHand:IsHoldingItem()
    return IsEntity(self.ItemHeld, true)
end

---Drop the item held by this hand.
---@return EntityHandle?
function CPropVRHand:Drop()
    if self.ItemHeld ~= nil then
        Player:DropByHandle(self.ItemHeld)
        ---@TODO: Make sure this doesn't return nil
        return self.ItemHeld
    end
end

---Get the rendered glove entity for this hand, i.e. the first `hlvr_prop_renderable_glove` class.
---@return EntityHandle|nil
function CPropVRHand:GetGlove()
    return self:GetFirstChildWithClassname("hlvr_prop_renderable_glove")
end

---Get the entity for this hands grabbity glove (the animated part on the glove).
---@return EntityHandle|nil
function CPropVRHand:GetGrabbityGlove()
    return self:GetFirstChildWithClassname("prop_grabbity_gloves")
end

---Returns true if the digital action is on for this. See `ENUM_DIGITAL_INPUT_ACTIONS` for action index values.
---Note: Only reports input when headset is awake. Will still transmit input when controller loses tracking.
---@param digitalAction ENUM_DIGITAL_INPUT_ACTIONS
---@return boolean
function CPropVRHand:IsButtonPressed(digitalAction)
    return Player:IsDigitalActionOnForHand(self.Literal, digitalAction)
end

---Forces the player to drop this entity if held.
---@param self CBaseEntity
function CBaseEntity:Drop()
    Player:DropByHandle(self)
end
Expose(CBaseEntity.Drop, "Drop", CBaseEntity)

---Force the player to grab this entity with a hand.
---If no hand is supplied then the nearest hand will be used.
---@param hand? CPropVRHand|0|1
function CBaseEntity:Grab(hand)
    Player:GrabByHandle(self, hand)
end
Expose(CBaseEntity.Grab, "Grab", CBaseEntity)

return version