--[[
    v1.8.0
    https://github.com/FrostSource/alyxlib

    Extensions for the `Entities` class.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.extensions.entities"
]]
require "alyxlib.extensions.entity"

local version = "v1.8.0"


---
---Finds the entity in a given list that is closest to a specified position.
---Uses 0`CalcClosestPointOnEntityOBB` to determine the nearest point on each entity's bounding box.
---
--- @param ents EntityHandle[] # A list of entities to check
--- @param pos Vector # The position to compare distances against
--- @return EntityHandle? # The closest entity to the given position, or nil if no entities are found
local function testNearest(ents, pos)
    -- print(#ents, Debug.SimpleVector(pos))
    local closestEnt = nil
    local closestLen = math.huge
    for index, ent in ipairs(ents) do
        local calcpos = CalcClosestPointOnEntityOBB(ent, pos)
        -- debugoverlay:Sphere(calcpos, 0.5, 255,255,255,255,false,5)
        local len = VectorDistance(pos, calcpos)
        -- print(ent, len)
        if len < closestLen then
            closestLen = len
            closestEnt = ent
        end
    end
    -- debugoverlay:Sphere(pos, 0.9, 255,0,255,255,false,5)
    -- print(closestLen)
    return closestEnt
end

---
---Finds the best matching entity based on a given unique name (if provided),
---classname, position, and search radius. 
---
---If a name is provided, it attempts to find an exact match by name first.  
--- - If only one entity with that name exists, it is returned immediately.  
--- - If multiple entities share the name, the one closest to the given position is chosen.  
---
---If no name is provided, the function falls back to finding the nearest entity of the given classname.  
---
---@param name string # The unique name of the entity (if available, "" if not)
---@param class string # The classname of the entity (fallback if name isn't available)
---@param position Vector # The position to search around
---@param radius? number # The max search radius (default: 128)
---@return EntityHandle # The best-matching entity found, or nil if none found
function Entities:FindBestMatching(name, class, position, radius)
    radius = radius or 128
    local ent
    if name ~= "" then
        local found_ents = Entities:FindAllByName(name)
        -- If only one with this name exists then we can get the exact handle.
        if #found_ents == 1 then
            ent = found_ents[1]
        else
            -- If multiple exist then we need to estimate the entity that was grabbed.
            -- ent = Entities:FindByNameNearest(name, position, radius)
            return testNearest(Entities:FindAllByNameWithin(name, position, radius), position)
        end
    else
        -- Entity without name (hopefully doesn't happen) is found by nearest class type.
        -- ent = Entities:FindByClassnameNearest(class, position, radius)
        return testNearest(Entities:FindAllByClassnameWithin(class, position, radius), position)
    end
    return ent
end

---
---Gets an array of every entity that currently exists.
---
---@return EntityHandle[]
function Entities:All()
    local ents = {}
    local e = Entities:First()
    while e ~= nil do
        table.insert(ents, e)
        e = Entities:Next(e)
    end
    return ents
end

---
---Gets a random entity in the map.
---
---@return EntityHandle
function Entities:Random()
    local all = Entities:All()
    return all[RandomInt(1, #all)]
end

---
---Find an entity within the same prefab as another entity.
---
---Will have issues in nested prefabs.
---
---@param entity EntityHandle
---@param name string
---@return EntityHandle? # The found entity, nil if not found.
---@return string # Prefab part of the name.
function Entities:FindInPrefab(entity, name)
    local myname = entity:GetName()
    for _,ent in ipairs(Entities:FindAllByName('*' .. name)) do
        local prefab_part = ent:GetName():sub(1, #ent:GetName() - #name)
        if prefab_part == myname:sub(1, #prefab_part) then
            return ent, prefab_part
        end
    end
    return nil, ""
end

---
---Find an entity within the same prefab as this entity.
---
---Will have issues in nested prefabs.
---
---@param name string
---@return EntityHandle?
---@return string # Prefab part of the name.
function CEntityInstance:FindInPrefab(name)
    return Entities:FindInPrefab(self, name)
end

---
---Find all entities with a cone.
---
---@param origin Vector # Origin of the cone in worldspace.
---@param direction Vector # Normalized direction vector.
---@param maxDistance number # Max distance the cone will extend towards `direction`.
---@param maxAngle number # Field-of-view in degrees that the cone can see, [0-180].
---@param checkEntityBounds boolean # If true the entity bounding box will be tested as well as the origin.
---@return EntityHandle[] # List of entities found within the cone.
function Entities:FindAllInCone(origin, direction, maxDistance, maxAngle, checkEntityBounds)
    local cosMaxAngle = math.cos(math.rad(maxAngle))
    local entitiesInSphere = Entities:FindAllInSphere(origin, maxDistance)

    -- Filter the entities based on whether they fall within the cone
    local entitiesInCone = {}
    for i = 1, #entitiesInSphere do
        local entity = entitiesInSphere[i]
        local directionToEntity = (entity:GetAbsOrigin() - origin):Normalized()
        local dotProduct = direction:Dot(directionToEntity)
        -- If the dot product is greater than or equal to the cosine of the max angle, the entity is within the cone
        if dotProduct >= cosMaxAngle then
            table.insert(entitiesInCone, entity)
        elseif checkEntityBounds then
            -- Check bounding corners too
            local corners = entity:GetBoundingCorners()
            for j = 1, #corners do
                directionToEntity = (corners[j] - origin):Normalized()
                dotProduct = direction:Dot(directionToEntity)
                if dotProduct >= cosMaxAngle then
                    table.insert(entitiesInCone, entity)
                    break
                end
            end
        end
    end

    return entitiesInCone
end

---
---Find all entities within `mins` and `maxs` bounding box.
---
---@param mins Vector # Mins vector in world-space.
---@param maxs Vector # Maxs vector in world-space.
---@param checkEntityBounds? boolean # If true the entity bounding boxes will be used for the check instead of the origin.
---@return EntityHandle[] # List of entities found.
function Entities:FindAllInBounds(mins, maxs, checkEntityBounds)
    local center = (mins + maxs) / 2
    local maxRadius = (maxs - center):Length()

    local entitiesInBounds = {}
    local potentialEntities = Entities:FindAllInSphere(center, maxRadius)

    for i = 1, #potentialEntities do
        local ent = potentialEntities[i]

        if ent:IsWithinBounds(mins, maxs, checkEntityBounds)
        then
            table.insert(entitiesInBounds, ent)
        end
    end

    return entitiesInBounds
end

---
---Find all entities within an `origin` centered box.
---
---@param width number # Size of the box on the X axis.
---@param length number # Size of the box on the Y axis.
---@param height number # Size of the box on the Z axis.
---@return EntityHandle[] # List of entities found.
function Entities:FindAllInBox(origin, width, length, height)
    return Entities:FindAllInBounds(
        Vector(origin - width, origin - length, origin - height),
        Vector(origin + width, origin + length, origin + height)
    )
end

---
---Find all entities within an `origin` centered cube of a given `size.`
---
---@param origin Vector # World space cube position.
---@param size number # Size of the cube in all directions.
---@return EntityHandle[] # List of entities found.
function Entities:FindAllInCube(origin, size)
    return Entities:FindAllInBox(origin, size, size, size)
end

---
---Find the nearest entity to a world position.
---
---@param origin Vector # Position to check from.
---@param maxRadius number # Maximum radius to check from `origin`.
---@return EntityHandle? # The nearest entity found, or nil if none found.
function Entities:FindNearest(origin, maxRadius)
    local nearestEnt = nil
    local nearestDistanceSq = math.huge
    local maxRadiusSq = maxRadius * maxRadius

    for _, ent in ipairs(Entities:FindAllInSphere(origin, maxRadius)) do
        local distanceSq = VectorDistanceSq(ent:GetOrigin(), origin)
        if distanceSq <= maxRadiusSq and distanceSq < nearestDistanceSq then
            nearestEnt = ent
            nearestDistanceSq = distanceSq
        end
    end

    return nearestEnt
end

---
---Finds all entities in the map from a list of classnames.
---
---@param classes string[]
---@return EntityHandle[]
function Entities:FindAllByClassnameList(classes)
    local ents = {}
    for _, class in ipairs(classes) do
        vlua.extend(ents, Entities:FindAllByClassname(class))
    end
    return ents
end

---
---Finds all entities within a radius from a list of classnames.
---
---@param classes string[]
---@param origin Vector
---@param maxRadius number
---@return EntityHandle[]
function Entities:FindAllByClassnameListWithin(classes, origin, maxRadius)
    local ents = {}
    for _, class in ipairs(classes) do
        vlua.extend(ents, Entities:FindAllByClassnameWithin(class, origin, maxRadius))
    end
    return ents
end

---
---Find the entity from a list of possible classnames which is closest to a world position.
---
---@param classes string[]
---@param origin Vector
---@param maxRadius number
---@return EntityHandle?
function Entities:FindByClassnameListNearest(classes, origin, maxRadius)
    local nearestEnt = nil
    local nearestDistanceSq = math.huge

    for _, class in ipairs(classes) do
        local ent = Entities:FindByClassnameNearest(class, origin, maxRadius)
        if ent then
            local distanceSq = VectorDistanceSq(ent:GetOrigin(), origin)
            if distanceSq < nearestDistanceSq then
                nearestEnt = ent
                nearestDistanceSq = distanceSq
            end
        end
    end

    return nearestEnt
end

---
---Finds all NPCs within the map.
---
---@return CAI_BaseNPC[]
function Entities:FindAllNPCs()
    local npcs = {}
    local ent = Entities:First()
    while ent ~= nil do
        if ent:IsNPC() then
            table.insert(npcs, ent)
        end
        ent = Entities:Next(ent)
    end
    return npcs
end

---
---Returns an iterator to loop over all NPC entities in the map using a `for` loop.
---
---E.g.
---
---    for npc in Entities:IterateAllNPCs() do
---        print(npc:GetClassname())
---    end
---
---@return fun():CAI_BaseNPC? # Iterator
function Entities:IterateAllNPCs()
    local ent = Entities:First()
    return function()
        -- This should be fine because the first entity will never be NPC?
        ent = Entities:Next(ent)

        while ent ~= nil and not ent:IsNPC() do
            ent = Entities:Next(ent)
        end
        return ent
    end
end

---
---Find all entities by model name within a radius.
---
---@param modelName string
---@param origin Vector
---@param maxRadius number
---@return EntityHandle[]
function Entities:FindAllByModelWithin(modelName, origin, maxRadius)
    local ents = {}
    local currentEnt = Entities:FindByModelWithin(nil, modelName, origin, maxRadius)
    while currentEnt ~= nil do
        table.insert(ents, currentEnt)
        currentEnt = Entities:FindByModelWithin(currentEnt, modelName, origin, maxRadius)
    end
    return ents
end

---
---Find the entity by model name nearest to a point.
---
---@param modelName string
---@param origin Vector
---@param maxRadius number
---@return EntityHandle?
function Entities:FindByModelNearest(modelName, origin, maxRadius)
    local closestEnt = nil
    local closestDist = math.huge
    local currentEnt = Entities:FindByModelWithin(nil, modelName, origin, maxRadius)
    while currentEnt ~= nil do
        local dist = VectorDistanceSq(origin, currentEnt:GetAbsOrigin())
        if dist < closestDist then
            closestDist = dist
            closestEnt = currentEnt
        end
        currentEnt = Entities:FindByModelWithin(currentEnt, modelName, origin, maxRadius)
    end
    return closestEnt
end

---
---Find the first entity whose model name contains `namePattern`.
---
---This works by searching every entity in the map and may incur a performance hit in large maps if used often.
---
---@param namePattern string
---@return EntityHandle?
function Entities:FindByModelPattern(namePattern)
    local ent = Entities:First()
    while ent ~= nil do
        if ent:GetModelName():find(namePattern) then
            return ent
        end
        ent = Entities:Next(ent)
    end
end

---
---Find all entities whose model name contains `namePattern`.
---
---This works by searching every entity in the map and may incur a performance hit in large maps if used often.
---
---@param namePattern string
---@return EntityHandle[]
function Entities:FindAllByModelPattern(namePattern)
    local ents = {}
    local ent = Entities:First()
    while ent ~= nil do
        if ent:GetModelName():find(namePattern) then
            table.insert(ents, ent)
        end
        ent = Entities:Next(ent)
    end
    return ents
end

return version