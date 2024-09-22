--[[
    v1.1.0
    https://github.com/FrostSource/alyxlib
]]

---@class WristAttachments
WristAttachments = {}
WristAttachments.version = "v1.1.0"

---@alias WristAttachmentHandType "left"|"right"|"primary"|"secondary"

---@class WristAttachmentData
---@field entity EntityHandle
---@field hand WristAttachmentHandType
---@field length number
---@field priority number
---@field offset Vector
---@field angles QAngle

---@type WristAttachmentData[]
WristAttachments.attachments = {}


local function sortAttachments()
    for index, value in ipairs(WristAttachments.attachments) do
        value.index = index
    end
    table.sort(WristAttachments.attachments, function (a, b)
        if a.priority < b.priority then
            return true
        elseif a.priority > b.priority then
            return false
        else
---@diagnostic disable-next-line: undefined-field
            return a.index < b.index
        end
    end)
    for _, value in ipairs(WristAttachments.attachments) do
        value.index = nil
    end
end

---Get the hand that an attachment should be attached to.
---@param attachment WristAttachmentData
---@return CPropVRHand
local function getHand(attachment)
    if attachment.hand == "left" then return Player.LeftHand
    elseif attachment.hand == "right" then return Player.RightHand
    elseif attachment.hand == "primary" then return Player.PrimaryHand
    elseif attachment.hand == "secondary" then return Player.SecondaryHand
    else
        error("WristAttachments hand type for " .. Debug.EntStr(attachment.entity) .. " is invalid '" .. attachment.hand .. "'")
    end
end


---Add a new entity as a wrist attachment.
---@param entity EntityHandle # The entity which will become a wrist attachment.
---@param hand? WristAttachmentHandType # The hand type to attach to initially.
---@param length number # Physical length of the entity to make sure it will not overlap with other wrist attachments.
---@param priority number? # Priority for the entity when there are other wrist attacments. Lower number is higher priority. Cannot specify a value lower than 0.
---@param offset Vector? # Optional offset for the entity (x component is ignored).
---@param angles QAngle? # Optional angles for the entity.
function WristAttachments:Add(entity, hand, length, priority, offset, angles)

    if self:IsEntityAttached(entity) then
        warn("WristAttachments entity "..Debug.EntStr(entity).." is already attached!")
        return
    end

    table.insert(WristAttachments.attachments, {
        entity = entity,
        hand = hand,
        length = length or entity:GetRadius(),
        priority = priority or 0,
        offset = offset or Vector(),
        angles = angles or QAngle(),
    })

    sortAttachments()
    self:Update()
end

---Set the hand that the entity should be attached to.
---@param entity EntityHandle # The entity to change data for.
---@param hand WristAttachmentHandType # The type of hand to attach to.
---@param offset Vector # Optional offset for the entity (x component is ignored).
---@param angles QAngle # Optional angles for the entity.
function WristAttachments:SetHand(entity, hand, offset, angles)
    local attachment = self:GetEntityAttachment(entity)
    if attachment then
        attachment.hand = hand
        attachment.offset = offset or attachment.offset
        attachment.angles = angles or attachment.angles
        self:Update()
    else
        warn("WristAttachments cannot SetHand for " .. Debug.EntStr(entity) .. " because it is not attached! Please use WristAttachments:Add()")
    end
end

---Get the hand that the entity is attached to.
---@param entity EntityHandle
---@return CPropVRHand?
function WristAttachments:GetHand(entity)
    for _, attachment in ipairs(self.attachments) do
        if attachment.entity == entity then
            return getHand(attachment)
        end
    end
end

---Get the attachment data related to an attach entity.
---@param entity EntityHandle # The entity to get the data for.
---@return WristAttachmentData? # The attachment data for the entity, if it is attached.
function WristAttachments:GetEntityAttachment(entity)
    for _, attachment in ipairs(self.attachments) do
        if attachment.entity == entity then
            return attachment
        end
    end
    return nil
end

---Get if an entity is attached to a wrist using this system.
---@param entity EntityHandle # The entity to check.
---@return boolean # True if attached, false otherwise.
function WristAttachments:IsEntityAttached(entity)
    return self:GetEntityAttachment(entity) ~= nil
end

function WristAttachments:Update()
    local offsets = {
        [Player.LeftHand] = 1,
        [Player.RightHand] = 1,
    }
    for _, attachment in ipairs(self.attachments) do

        local hand = getHand(attachment)

        local offset, angles, modelAttachment = attachment.offset, attachment.angles, ""
        offset.x = offsets[hand] - (attachment.length/2)

        if hand == Player.LeftHand then
            modelAttachment = "item_holder_l"
            -- offset = offset or Vector(0.6, 1.2, 0)
            -- angles = angles or QAngle(-7.07305, 0, -90)
        else
            modelAttachment = "item_holder_r"
            -- offset = offset or Vector(0.6, 1.2, 0)
            -- angles = angles or QAngle(-7.07305-180, 0, -90)
        end

        -- Add the full attachment length for the next attachment on this hand
        offsets[hand] = offsets[hand] - attachment.length


        attachment.entity:SetParent(hand:GetGlove(), modelAttachment)
        attachment.entity:SetLocalOrigin(offset)
        attachment.entity:SetLocalQAngle(angles)
    end
end

---@param params PLAYER_EVENT_PRIMARY_HAND_CHANGED
ListenToPlayerEvent("primary_hand_changed", function (params)
    WristAttachments:Update()
end)

return WristAttachments.version