--[[
    v2.7.1
    https://github.com/FrostSource/alyxlib

    Provides base entity extension methods.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.extensions.entity"
]]

local version = "v2.7.1"

---
---Get the entities parented to this entity. Including children of children.
---
---This is a memory safe version of GetChildren() which causes a memory leak when called.
---If you need to get children often you should use this function instead.
---
---@return EntityHandle[]
function CBaseEntity:GetChildrenMemSafe()
    local childrenArray = {}
    for child in self:IterateChildren() do
        table.insert(childrenArray, 1, child)
    end
    return childrenArray
end

---
---Returns a `function` that iterates over all children of this entity.
---The `function` returns the next child every time it is called until no more children exist,
---in which case `nil` is returned.
---
---Useful in `for` loops:
---
---     for child in thisEntity:IterateChildren() do
---         print(Debug.EntStr(child))
---     end
---
---This function is memory safe.
---
---@return fun(...:any):EntityHandle # The new iterator function
function CBaseEntity:IterateChildren()
    local function traverse(entity)
        coroutine.yield(entity)
        local child = entity:FirstMoveChild()
        while child do
            traverse(child)
            child = child:NextMovePeer()
        end
    end

    return coroutine.wrap(function()
        local child = self:FirstMoveChild()
        while child do
            traverse(child)
            child = child:NextMovePeer()
        end
    end)
end

---
---Returns a `function` that iterates over all children of this entity in **breadth-first order**.
---The `function` returns the next child every time it is called until no more children exist,
---in which case `nil` is returned.
---
---Useful in `for` loops:
---
---     for child in thisEntity:IterateChildrenBreadthFirst() do
---         print(Debug.EntStr(child))
---     end
---
---Unlike [IterateChildren](lua://CBaseEntity.IterateChildren), this visits all immediate children first,
---then their children, and so on.
---
---This function is memory safe.
---
---@return fun(...:any):EntityHandle # The new iterator function
function CBaseEntity:IterateChildrenBreadthFirst()
    return coroutine.wrap(function()
        local queue = {}

        -- start with direct children
        local child = self:FirstMoveChild()
        while child do
            table.insert(queue, child)
            child = child:NextMovePeer()
        end

        -- process the queue
        while #queue > 0 do
            local entity = table.remove(queue, 1) -- pop front
            coroutine.yield(entity)

            -- enqueue this entity's direct children
            local subchild = entity:FirstMoveChild()
            while subchild do
                table.insert(queue, subchild)
                subchild = subchild:NextMovePeer()
            end
        end
    end)
end


---
---Get the top level entities parented to this entity. Not children of children.
---
---This function is memory safe.
---
---@return EntityHandle[]
function CBaseEntity:GetTopChildren()
    local children = {}
    local child = self:FirstMoveChild()
    while child do
        table.insert(children, child)
        child = child:NextMovePeer()
    end
    return children
end

---
---Get the first child in the hierarchy that has targetname or classname.
---
---@param name string # The name or classname to look for, supports wildcard '*'
---@return EntityHandle?
function CBaseEntity:GetChild(name)
    local usePattern = name:find("%*") ~= nil
    local pattern

    ---@TODO Consider moving wildcard logic to a utility function
    if usePattern then
        -- Escape pattern special characters, then replace '*' with '.*'
        pattern = "^" .. name
            :gsub("([%^%$%(%)%%%.%[%]%+%-%?])", "%%%1")
            :gsub("%*", ".*") .. "$"
    end

    local child = self:FirstMoveChild()
    while IsValidEntity(child) do
        local childName = child:GetName()
        local className = child:GetClassname()

        local match = false
        if usePattern then
            match = childName:match(pattern) or className:match(pattern)
        else
            match = childName == name or className == name
        end

        if match then
            return child
        end

        -- Check children recursively
        local result = child:GetChild(name)
        if result then
            return result
        end

        child = child:NextMovePeer()
    end

    return nil
end


---
---Send an input to this entity.
---
---@param action string # Input name.
---@param value? any # Parameter override for the input.
---@param delay? number # Delay in seconds.
---@param activator? EntityHandle
---@param caller? EntityHandle
function CBaseEntity:EntFire(action, value, delay, activator, caller)
    DoEntFireByInstanceHandle(self, action, value and tostring(value) or "", delay or 0, activator or nil, caller or nil)
end

---
---Get the first child in this entity's hierarchy with a given `classname`.
---Searches using **breadth-first traversal**, so it finds the closest matching child first.
---
---This function is memory safe.
---
---@param classname string # Classname to search for.
---@return EntityHandle? # The first matching child found, or `nil` if none exists.
function CBaseEntity:GetFirstChildWithClassname(classname)
    for child in self:IterateChildrenBreadthFirst() do
        if child:GetClassname() == classname then
            return child
        end
    end

    return nil
end

---
---Get the first child in this entity's hierarchy with a given `name`.
---Searches using **breadth-first traversal**, so it finds the closest matching child first.
---
---This function is memory safe.
---
---@param name string # Targetname to search for.
---@return EntityHandle? # The first matching child found, or `nil` if none exists.
function CBaseEntity:GetFirstChildWithName(name)
    for child in self:IterateChildrenBreadthFirst() do
        if child:GetName() == name then
            return child
        end
    end

    return nil
end

---
---Set entity pitch, yaw, roll from a `QAngle`.
---
---@param qangle QAngle # The rotation to set (pitch, yaw, roll).
function CBaseEntity:SetQAngle(qangle)
    self:SetAngles(qangle.x, qangle.y, qangle.z)
end

---
---Set entity local pitch, yaw, roll from a `QAngle`.
---
---@param qangle QAngle # The rotation to set (pitch, yaw, roll).
function CBaseEntity:SetLocalQAngle(qangle)
    self:SetLocalAngles(qangle.x, qangle.y, qangle.z)
end

---
---Set entity pitch, yaw or roll. Supply `nil` for any parameter to leave it unchanged.
---
---@param pitch? number # Pitch angle, or nil to leave unchanged.
---@param yaw? number # Pitch angle, or nil to leave unchanged.
---@param roll? number # Pitch angle, or nil to leave unchanged.
function CBaseEntity:SetAngle(pitch, yaw, roll)
    local angles = self:GetAngles()
    self:SetAngles(pitch or angles.x, yaw or angles.y, roll or angles.z)
end

---
---Resets local origin and angle to [0,0,0].
---
function CBaseEntity:ResetLocal()
    self:SetLocalOrigin(Vector())
    self:SetLocalAngles(0, 0, 0)
end

---
---Get the bounding size of the entity.
---
---@return Vector # Bounding size of the entity as a Vector.
function CBaseEntity:GetSize()
    return self:GetBoundingMaxs() - self:GetBoundingMins()
end

---
---Get the biggest bounding box axis of the entity.
---This will be `size.x`, `size.y` or `size.z`.
---
---@return number # The largest bounding value.
function CBaseEntity:GetBiggestBounding()
    local size = self:GetSize()
    return math.max(size.x, size.y, size.z)
end

---
---Get the radius of the entity's bounding box.
---This is half the size of the bounding box along its largest axis.
---
---@return number # The bounding radius value.
function CBaseEntity:GetRadius()
    return self:GetSize():Length() * 0.5
end

---
---Get the volume of the entity bounds in cubic inches.
---
---@return number # The volume of the entity bounds.
function CBaseEntity:GetVolume()
    local size = self:GetSize() * self:GetAbsScale()
    return size.x * size.y * size.z
end

---
---Get each corner of the entity's bounding box.
---
---@param rotated? boolean # If true, corners are rotated by the entity's angles.
---@return Vector[] # List of 8 corner positions.
function CBaseEntity:GetBoundingCorners(rotated)
    local bounds = self:GetBounds()
    local origin = self:GetOrigin()
    local corners = {
        origin + bounds.Mins * self:GetAbsScale(),
        origin + bounds.Maxs * self:GetAbsScale(),
        origin + Vector(bounds.Mins.x, bounds.Mins.y, bounds.Maxs.z) * self:GetAbsScale(),
        origin + Vector(bounds.Maxs.x, bounds.Mins.y, bounds.Mins.z) * self:GetAbsScale(),
        origin + Vector(bounds.Mins.x, bounds.Maxs.y, bounds.Mins.z) * self:GetAbsScale(),
        origin + Vector(bounds.Maxs.x, bounds.Maxs.y, bounds.Mins.z) * self:GetAbsScale(),
        origin + Vector(bounds.Maxs.x, bounds.Mins.y, bounds.Maxs.z) * self:GetAbsScale(),
        origin + Vector(bounds.Mins.x, bounds.Maxs.y, bounds.Maxs.z) * self:GetAbsScale(),
    }

    if rotated then
        local angle = self:GetAngles()
        for k, v in pairs(corners) do
            corners[k] = RotatePosition(origin, angle, v)
        end
    end

    return corners
end

---
---Check if entity is within the given worldspace bounds.
---
---@param mins Vector # Worldspace minimum vector for the bounds.
---@param maxs Vector # Worldspace minimum vector for the bounds.
---@param checkEntityBounds? boolean # If true the entity bounding box will be used for the check instead of its origin.
---@return boolean # True if the entity is within the bounds, false otherwise.
function CBaseEntity:IsWithinBounds(mins, maxs, checkEntityBounds)
    local selfMins, selfMaxs
    if checkEntityBounds then
        selfMins = self:GetOrigin() + self:GetBoundingMins()
        selfMaxs = self:GetOrigin() + self:GetBoundingMaxs()
    else
        selfMins = self:GetOrigin()
        selfMaxs = selfMins
    end
    if selfMins.x <= maxs.x and selfMaxs.x >= mins.x
    and selfMins.y <= maxs.y and selfMaxs.y >= mins.y
    and selfMins.z <= maxs.z and selfMaxs.z >= mins.z
    then
        return true
    end
    return false
end

---
---Send the `DisablePickup` input to the entity.
---
function CBaseEntity:DisablePickup()
    DoEntFireByInstanceHandle(self, "DisablePickup", "", 0, self, self)
end

---
---Send the `EnablePickup` input to the entity.
---
function CBaseEntity:EnablePickup()
    DoEntFireByInstanceHandle(self, "EnablePickup", "", 0, self, self)
end

---
---Delay some code using this entity.
---
---@param func fun() # The function to delay.
---@param delay? number # Optional delay in seconds (default 0).
function CBaseEntity:Delay(func, delay)
    self:SetContextThink(DoUniqueString("delay"), function() func() end, delay or 0)
end

---
---Get all parents in the hierarchy upwards.
---
---@return EntityHandle[] # List of parent entities, from immediate parent up to the root.
function CBaseEntity:GetParents()
    local parents = {}
    local parent = self:GetMoveParent()
    while parent ~= nil do
        table.insert(parents, parent)
        parent = parent:GetMoveParent()
    end
    return parents
end

---
---Set if the prop is allowed to be dropped. Only works for physics based props.
---
---@param enabled boolean # True if the prop can't be dropped, false for can be dropped.
function CBaseEntity:DoNotDrop(enabled)
    if enabled then
        self:Attribute_SetIntValue("DoNotDrop", 1)
    else
        self:DeleteAttribute("DoNotDrop")
    end
end

---
---Get all criteria on this entity as a table.
---
---@return CriteriaTable # A table of criteria key-value pairs.
function CBaseEntity:GetCriteria()
    local c = {}
    self:GatherCriteria(c)
    return c
end
---
---Get all entities owned by this entity.
---
---**Note:** This searches all entities in the map and should be used sparingly.
---
---@return EntityHandle[] # List of owned entities.
function CBaseEntity:GetOwnedEntities()
    local ents = {}
    local ent = Entities:First()
    while ent ~= nil do
        if ent ~= self and ent:GetOwner() == self then
            table.insert(ents, ent)
        end
        ent = Entities:Next(ent)
    end
    return ents
end

---
---Set the alpha modulation of this entity, plus any children that support [SetRenderAlpha](lua://CBaseModelEntity.SetRenderAlpha).
---
---@param alpha integer # Alpha value (0 = fully transparent, 255 = fully opaque).
function CBaseModelEntity:SetRenderAlphaAll(alpha)
    for _, child in ipairs(self:GetChildren()) do
        if child.SetRenderAlpha then
            child:SetRenderAlpha(alpha)
        end
    end
    self:SetRenderAlpha(alpha)
end

---
---Moves the entity so that its center is at the given position.
---
---@param position Vector # The new center position.
function CBaseEntity:SetCenter(position)
    local center = self:GetCenter()
    local origin = self:GetOrigin()

    local translation = position - center

    self:SetOrigin(origin + translation)
end



---
---Set the entity's origin so that the specified attachment point aligns with the given world position.
---
---@param position Vector # The target world position for the attachment point.
---@param attachment string # The name of the attachment point to align.
function CBaseAnimating:SetOriginByAttachment(position, attachment)
    local offset = self:GetAttachmentOrigin(self:ScriptLookupAttachment(attachment))
    local origin = self:GetOrigin()

    local translation = position - offset

    self:SetOrigin(origin + translation)
end

---
---Track a property function using a callback when a change is detected.
---
---    -- Make entity fully opaque if alpha is ever detected below 255
---    thisEntity:TrackProperty(thisEntity.GetRenderAlpha, function(prevValue, newValue)
---        if newValue < 255 then
---            thisEntity:SetRenderAlpha(255)
---        end
---    end)
---
---@param propertyFunction fun(handle: EntityHandle): any # Property function to track, e.g. GetRenderAlpha.
---@param onChangeFunction fun(prevValue: any, newValue: any) # Function to call when a change is detected.
---@param interval? number # Think interval, or smallest possible if nil.
---@param context? EntityHandle # Entity to run the thinker on, or this entity if nil.
function CBaseEntity:TrackProperty(propertyFunction, onChangeFunction, interval, context)
    interval = interval or 0
    context = context or self
    local value = propertyFunction(self)
    context:SetContextThink(tostring(propertyFunction), function()
        local newValue = propertyFunction(self)
        if newValue ~= value then
            onChangeFunction(value, newValue)
        end
        return interval
    end, interval)
end

---
--- Untrack a property function which was set to be tracked using `CBaseEntity:TrackProperty`.
---
---@param propertyFunction fun(handle: EntityHandle): any # Property function to untrack, e.g. GetRenderAlpha.
function CBaseEntity:UntrackProperty(propertyFunction)
    self:SetContextThink(tostring(propertyFunction), nil, 0)
end

---
---Quickly start a think function on the entity with a random name and no delay.
---
---@param func fun(...):number? # The think function.
---@param delay? number # Delay before starting the think.
---@return string # The name of the think for stopping later if desired.
function CBaseEntity:QuickThink(func, delay)
    local name = DoUniqueString("QuickThink")
    self:SetContextThink(name, func, delay or 0)
    return name
end

---
---Sets whether the entity is rendered or not.
---
---@param renderingEnabled boolean # If false the entity will become invisible.
function CBaseEntity:SetRenderingEnabled(renderingEnabled)
    if renderingEnabled then
        self:RemoveEffects(0x020)
    else
        self:AddEffects(0x020)
    end
end

---
---Sets whether the entity casts a shadow or not.
---
---@param shadowEnabled boolean # If false the entity will not cast a dynamic shadow.
function CBaseEntity:SetCastShadow(shadowEnabled)
    if shadowEnabled then
        self:RemoveEffects(0x010)
    else
        self:AddEffects(0x010)
    end
end

---
---Adds an I/O connection that will call the function on the passed entity when the specified output fires.
---This means the redirection is persistent after game loads.
---
---@param output string # The name of the output to redirect.
---@param func function # The function to redirect to.
---@param entity? EntityHandle # The entity to redirect to, defaults to the calling entity.
function CEntityInstance:RedirectOutputFunc(output, func, entity)
    entity = entity or self

    local name = DoUniqueString(tostring(func))
    entity[name] = func
    entity:RedirectOutput(output, name, entity)

    return name
end

---
---Gets the position in front of the entity’s eyes at the specified distance.
---
---@param distance number # How far in front of the eyes to get the position.
---@return Vector # The world position in front of the eyes.
function CBaseEntity:DistanceFromEyes(distance)
    return self:EyePosition() + self:EyeAngles():Forward() * distance
end

---
---Gets the world origin position of a named attachment point.
---
---@param name string # The name of the attachment.
---@return Vector # The world position of the attachment.
function CBaseAnimating:GetAttachmentNameOrigin(name)
    return self:GetAttachmentOrigin(self:ScriptLookupAttachment(name))
end

---
---Gets the world angles (rotation) of a named attachment point.
---
---@param name string # The name of the attachment.
---@return Vector # The world rotation angles of the attachment.
function CBaseAnimating:GetAttachmentNameAngles(name)
    return self:GetAttachmentAngles(self:ScriptLookupAttachment(name))
end

---
---Gets the forward direction vector of a named attachment.
---
---@param name string # The name of the attachment.
---@return Vector # The forward unit vector of the attachment in world space.
function CBaseAnimating:GetAttachmentNameForward(name)
    return self:GetAttachmentForward(self:ScriptLookupAttachment(name))
end

---
---Unparents this entity if it is parented.
---
function CBaseEntity:ClearParent()
    self:SetParent(nil, nil)
end

---
---Sets the absolute world velocity of the entity.
---
---@param velocity Vector The target velocity in units/second.
function CBaseEntity:SetAbsVelocity(velocity)
    local currentVelocity = GetPhysVelocity(self)

    local impulse = velocity - currentVelocity

    self:ApplyAbsVelocityImpulse(impulse)
end

---
---Checks whether this entity's axis-aligned bounding box intersects
---with another entity or an explicit Mins/Maxs bounds table.
---
---If `other` is an entity, its bounds are queried with [GetBounds](lua://CBaseEntity.GetBounds).
---
---@param other EntityHandle|{ Mins: Vector, Maxs: Vector } # Entity or bounds to test against.
function CBaseEntity:TestAABBIntersect(other)
    local selfBounds = self:GetBounds()

    if IsEntity(other) then
        other = other:GetBounds()
    end

    return (
        selfBounds.Mins.x <= other.Maxs.x and selfBounds.Maxs.x >= other.Mins.x and
        selfBounds.Mins.y <= other.Maxs.y and selfBounds.Maxs.y >= other.Mins.y and
        selfBounds.Mins.z <= other.Maxs.z and selfBounds.Maxs.z >= other.Mins.z
    )
end

return version