--[[
    v3.1.0
    https://github.com/FrostSource/alyxlib

    This file contains utility functions to help reduce repetitive code and add general miscellaneous functionality.

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "alyxlib.utils.common"
    ```
]]

Util = {}
Util.version = "v3.1.0"

---
---Convert vr_tip_attachment from a game event [1,2] into a hand id [0,1] taking into account left handedness.
---
---@param vr_tip_attachment 1|2
---@return 0|1
function Util.GetHandIdFromTip(vr_tip_attachment)
    local handId = vr_tip_attachment - 1
    if not Convars:GetBool("hlvr_left_hand_primary") then
        handId = 1 - handId
    end
    return handId
end

---
---Attempt to find a key in `tbl` pointing to `value`.
---
---@param tbl table # The table to search.
---@param value any # The value to search for.
---@return unknown|nil # The key in `tbl` or nil if no `value` was found.
---@deprecated # Functionally the same as `vlua.find`.
function Util.FindKeyFromValue(tbl, value)
    for key, val in pairs(tbl) do
        if val == value then
            return key
        end
    end
    return nil
end

---
---Attempt to find a key in `tbl` pointing to `value` by recursively searching nested tables.
---
---@param tbl table # The table to search.
---@param value any # The value to search for.
---@param seen? table[] # List of tables that have already been searched.
---@return unknown|nil # The key in `tbl` or nil if no `value` was found.
local function _FindKeyFromValueDeep(tbl, value, seen)
    seen = seen or {}
    for key, val in pairs(tbl) do
        if val == value then
            return key
        elseif type(val) == "table" and not vlua.find(seen, val) then
            seen[#seen+1] = val
            local k = _FindKeyFromValueDeep(val, value, seen)
            if k then return k end
        end
    end
    return nil
end

---
---Attempt to find a key in `tbl` pointing to `value` by recursively searching nested tables.
---
---@param tbl table # The table to search.
---@param value any # The value to search for.
---@return unknown|nil # The key in `tbl` or nil if no `value` was found.
function Util.FindKeyFromValueDeep(tbl, value)
    return _FindKeyFromValueDeep(tbl, value)
end

---Returns the size of any table.
---@param tbl table
---@return integer
function Util.TableSize(tbl)
    local count = 0
    for _, _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

---
---Delay some code.
---
---@param func function
---@param delay? number
function Util.Delay(func, delay)
    GetListenServerHost():SetContextThink(DoUniqueString("delay"), func, delay or 0)
end

---
---Get a new `QAngle` from a `Vector`.
---This simply transfers the raw values from one to the other.
---
---@param vec Vector
---@return QAngle
function Util.QAngleFromVector(vec)
    return QAngle(vec.x, vec.y, vec.z)
end

---Create a constraint between two entity handles.
---@param entity1 EntityHandle # First entity to attach.
---@param entity2 EntityHandle|nil # Second entity to attach. Set nil to attach to world.
---@param class? string # Class of constraint, default is `phys_constraint`.
---@param properties? table # Key/value property table.
---@return EntityHandle
function Util.CreateConstraint(entity1, entity2, class, properties)
    -- Cache original names
    local name1 = entity1:GetName()
    local name2 = entity2 and entity2:GetName() or ""

    -- Assign unique names so constraint can find them on spawn
    local uname1 = DoUniqueString("")
    entity1:SetEntityName(uname1)
    local uname2 = entity2 and DoUniqueString("") or ""
    if entity2 then entity2:SetEntityName(uname2) end

    properties = vlua.tableadd({
        origin = entity1:GetAbsOrigin(),
        attach1 = uname1,
        attach2 = uname2
    }, properties or {})
    local constraint = SpawnEntityFromTableSynchronous(class or "phys_constraint", properties)

    -- Restore original names now that constraint knows their handles
    entity1:SetEntityName(name1)
    if entity2 then entity2:SetEntityName(name2) end
    return constraint
end

---@alias ExplosionType
---|"" # "Default"
---|"grenade" # "Grenade"
---|"molotov" # "Molotov"
---|"fireworks" # "Fireworks"
---|"gascan" # "Gasoline Can"
---|"gascylinder" # "Pressurized Gas Cylinder"
---|"explosivebarrel" # "Explosive Barrel"
---|"electrical" # "Electrical"
---|"emp" # "EMP"
---|"shrapnel" # "Shrapnel"
---|"smoke" # "Smoke Grenade"
---|"flashbang" # "Flashbang"
---|"tripmine" # "Tripmine"
---|"ice" # "Ice"
---|"none" # "None"
---|"custom" # "Custom"

---Create a damaging explosion effect at a position.
---@param origin Vector
---@param explosionType? ExplosionType
---@param magnitude? number
---@param radiusOverride? number
---@param ignoredEntity? EntityHandle|string # If the entity passed does not have a unique name, all entities with that name will be ignored.
---@param ignoredClass? string
function Util.CreateExplosion(origin, explosionType, magnitude, radiusOverride, ignoredEntity, ignoredClass)

    local name
    if ignoredEntity and type(ignoredEntity) ~= "string" then
        name = ignoredEntity:GetName()
    else
        name = ignoredEntity
    end

    local expl = SpawnEntityFromTableSynchronous("env_explosion",
    {
        origin = origin,
        explosion_type = explosionType or "",
        iMagnitude = magnitude or 100,
        iRadiusOverride = radiusOverride or 0,
        ignoredEntity = name,
        ignoredClass = ignoredClass or "",
    })
    expl:EntFire("Explode")
    expl:EntFire("Kill", nil, 0.1)
end

---Choose and return a random argument.
---@generic T
---@param ... T
---@return T
function Util.Choose(...)
    local args = {...}
    local numArgs = #args
    if numArgs == 0 then
        return nil
    elseif numArgs == 1 then
        return args[1]
    else
        return args[RandomInt(1, numArgs)]
    end
end

---Turns a string of up to three numbers into a vector.
---@param str string # Should have a format of "x y z"
---@return Vector
function Util.VectorFromString(str)
    if type(str) ~= "string" then
        return Vector()
    end
    local x, y, z = str:match("(%d+)[^%d]+(%d*)[^%d]+(%d*)")
    return Vector(tonumber(x), tonumber(y), tonumber(z))
end

return Util.version