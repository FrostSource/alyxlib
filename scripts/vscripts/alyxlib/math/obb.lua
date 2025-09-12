--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Functions for drawing and testing OBB intersections.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.math.obb"
]]

local version = "v1.0.0"

---
---Projects an OBB onto an axis.
---
---@param centerLocal Vector # The center of the OBB in local space.
---@param half Vector # The half extents of the OBB in local space.
---@param origin Vector # The origin of the OBB in world space.
---@param angles QAngle # The angles of the OBB in world space.
---@param axis Vector # The axis to project on.
local function projectOBB(centerLocal, half, origin, angles, axis)
    local f, r, u = angles:Forward(), angles:Left(), angles:Up()
    local centerWorld = origin + f*centerLocal.x + r*centerLocal.y + u*centerLocal.z
    local radius = half.x*math.abs(f:Dot(axis)) +
                   half.y*math.abs(r:Dot(axis)) +
                   half.z*math.abs(u:Dot(axis))
    return centerWorld:Dot(axis) - radius, centerWorld:Dot(axis) + radius
end

---
---OBB data table for use with obb.lua functions.
---
---@class OBBData
---@field center Vector # The center of the OBB in local space.
---@field half Vector # The half extents of the OBB in local space.

---
---Returns the center and half extents of an entity's OBB in local space.
---
---@param entity EntityHandle # The entity.
---@return OBBData # The OBB data.
function GetEntityOBBData(entity)
    local mins = entity:GetBoundingMins()
    local maxs = entity:GetBoundingMaxs()
    local center = (mins + maxs) * 0.5
    local half = (maxs - mins) * 0.5
    return {
        center = center,
        half = half
    }
end

---
---Returns the world space minimum and maximum corners of an entity's OBB.
---
---@param entity EntityHandle # The entity.
---@return Vector # The world space minimum corner.
---@return Vector # The world space maximum corner.
function GetEntityAABB(entity)
    local data = GetEntityOBBData(entity)
    local origin = entity:GetOrigin()
    local ang = entity:GetAngles()

    local f, r, u = ang:Forward(), ang:Left(), ang:Up()

    -- world center of OBB
    local center = origin
                 + f * data.center.x
                 + r * data.center.y
                 + u * data.center.z

    -- half extents projected onto world axes
    local hx = math.abs(f.x) * data.half.x +
               math.abs(r.x) * data.half.y +
               math.abs(u.x) * data.half.z

    local hy = math.abs(f.y) * data.half.x +
               math.abs(r.y) * data.half.y +
               math.abs(u.y) * data.half.z

    local hz = math.abs(f.z) * data.half.x +
               math.abs(r.z) * data.half.y +
               math.abs(u.z) * data.half.z

    local halfWorld = Vector(hx, hy, hz)

    return center - halfWorld, center + halfWorld
end

---
---Tests if two AABBs intersect.
---
---@param aMin Vector # The minimum corner of the first AABB.
---@param aMax Vector # The maximum corner of the first AABB.
---@param bMin Vector # The minimum corner of the second AABB.
---@param bMax Vector # The maximum corner of the second AABB.
---@return boolean # True if the AABBs intersect.
function AABBvsAABB(aMin, aMax, bMin, bMax)
    return aMin.x <= bMax.x and aMax.x >= bMin.x and
           aMin.y <= bMax.y and aMax.y >= bMin.y and
           aMin.z <= bMax.z and aMax.z >= bMin.z
end

---
---Tests if two OBBs intersect.
---
---@param obbDataA OBBData # The data of the first OBB.
---@param originA Vector # The world space origin of the first OBB.
---@param anglesA QAngle # The angles of the first OBB.
---@param obbDataB OBBData # The data of the second OBB.
---@param originB Vector # The world space origin of the second OBB.
---@param anglesB QAngle # The angles of the second OBB.
---@return boolean # True if the OBBs intersect.
function OBBvsOBB(obbDataA, originA, anglesA, obbDataB, originB, anglesB)
    local fA, rA, uA = anglesA:Forward(), anglesA:Left(), anglesA:Up()
    local fB, rB, uB = anglesB:Forward(), anglesB:Left(), anglesB:Up()

    local axes = {fA, rA, uA, fB, rB, uB}

    for _,a in ipairs({fA, rA, uA}) do
        for _,b in ipairs({fB, rB, uB}) do
            local cross = a:Cross(b)
            if cross:Length() > 0.0001 then
                table.insert(axes, cross:Normalized())
            end
        end
    end

    for _,axis in ipairs(axes) do
        local minA,maxA = projectOBB(obbDataA.center, obbDataA.half, originA, anglesA, axis)
        local minB,maxB = projectOBB(obbDataB.center, obbDataB.half, originB, anglesB, axis)
        if minA > maxB or minB > maxA then
            return false
        end
    end

    return true
end

---
---Tests if an AABB and an OBB intersect.
---
---@param aabbMin Vector # The minimum corner of the AABB.
---@param aabbMax Vector # The maximum corner of the AABB.
---@param obbData OBBData # The data of the OBB.
---@param obbOrigin Vector # The world space origin of the OBB.
---@param obbAngles QAngle # The angles of the OBB.
---@return boolean # True if the AABB and OBB intersect.
function AABBvsOBB(aabbMin, aabbMax, obbData, obbOrigin, obbAngles)

    local aCenter = (aabbMin + aabbMax) * 0.5
    local aOBB = {
        center = Vector(0,0,0),
        half = (aabbMax - aabbMin) * 0.5
    }

    local aAngles = QAngle(0,0,0)

    return OBBvsOBB(
        aOBB, aCenter, aAngles,
        obbData, obbOrigin, obbAngles
    )
end

---
---Draws an OBB in the world.
---
---@param obbData OBBData # The data of the OBB.
---@param origin Vector # The world space origin of the OBB.
---@param angles QAngle # The angles of the OBB.
---@param color Vector # The color of the OBB.
---@param noDepthTest boolean # True if the OBB should be drawn above all geometry.
---@param seconds number # The number of seconds the OBB should be visible for.
function DebugDrawOBB(obbData, origin, angles, color, noDepthTest, seconds)

    local f = angles:Forward()
    local r = angles:Left()
    local u = angles:Up()

    -- world center of the OBB
    local center = origin
                 + f * obbData.center.x
                 + r * obbData.center.y
                 + u * obbData.center.z

    -- build corners
    local corners = {}
    local i = 1
    for sx = -1, 1, 2 do
        for sy = -1, 1, 2 do
            for sz = -1, 1, 2 do
                corners[i] = center
                           + f * (sx * obbData.half.x)
                           + r * (sy * obbData.half.y)
                           + u * (sz * obbData.half.z)
                i = i + 1
            end
        end
    end

    -- edge indices
    local edges = {
        {1,2}, {2,4}, {4,3}, {3,1}, -- bottom
        {5,6}, {6,8}, {8,7}, {7,5}, -- top
        {1,5}, {2,6}, {3,7}, {4,8}  -- verticals
    }

    -- draw lines
    for _,e in ipairs(edges) do
        DebugDrawLine(corners[e[1]], corners[e[2]],
            color.x, color.y, color.z,
            noDepthTest or false, seconds or 0.0)
    end
end

---
---Draws an entity's OBB in the world.
---
---@param entity EntityHandle # The entity to draw the OBB for.
---@param color Vector # The color of the OBB in RGB.
---@param noDepthTest boolean # True if the OBB should be drawn above all geometry.
---@param seconds number # The number of seconds the OBB should be visible for.
function DebugDrawEntityOBB(entity, color, noDepthTest, seconds)
    local obbData = GetEntityOBBData(entity)
    DebugDrawOBB(obbData, entity:GetOrigin(), entity:GetAngles(), color, noDepthTest, seconds)
end

---
---Draws an entity's AABB in the world.
---
---The AABB is defined by the entity's bounding mins/maxs and its current origin/angles.
---
---@param entity EntityHandle # The entity to draw the AABB for.
---@param color Vector # The color of the AABB in RGB.
---@param noDepthTest boolean # True if the AABB should be drawn above all geometry.
---@param seconds number # The number of seconds the AABB should be visible for.
function DebugDrawEntityAABB(entity, color, noDepthTest, seconds)
    local mins, maxs = GetEntityAABB(entity)
    debugoverlay:Box(mins, maxs, color.x, color.y, color.z, 255, noDepthTest or false, seconds or 0)
end

return version