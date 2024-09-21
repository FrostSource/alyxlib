--[[
    v1.2.1
    https://github.com/FrostSource/alyxlib

    Provides Vector class extension methods.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.extensions.vector"
]]
require "alyxlib.math.common"

local version = "v1.2.1"

---@class Vector
local meta = getmetatable(Vector())

local zero = Vector(0, 0, 0)
-- local up = Vector(0, 0, 1)
-- local right = Vector(0, 1, 0)

---
---Calculates the perpendicular vector to the current vector.
---
---@return Vector # The perpendicular vector.
function meta:Perpendicular()
    if self.y == 0 and self.z == 0 then
        if self.x == 0 then
            return Vector()
        else
            -- If the vector is parallel to the YZ plane, calculate the cross product with the Y-axis.
            return self:Cross(Vector(0, 1, 0))
        end
    end
    -- If the vector is not parallel to the YZ plane, calculate the cross product with the X-axis.
    return self:Cross(Vector(1, 0, 0))
end

---
---Check if the current vector is perpendicular to another vector.
---
---@param vector Vector # The other vector to check perpendicularity against.
---@param tolerance? number # (optional) The tolerance value for the dot product comparison. Default is 1e-8.
---@return boolean # True if the vectors are perpendicular, false otherwise.
function meta:IsPerpendicularTo(vector, tolerance)
    tolerance = tolerance or 1e-8
    return math.abs(self:Dot(vector)) <= tolerance
end

---
---Checks if the current vector is parallel to the given vector.
---
---@param vector Vector # The vector to compare with.
---@return boolean # True if the vectors are parallel, false otherwise.
function meta:IsParallelTo(vector)
    -- Treat zero vectors as parallel to any vector
    if self == zero or vector == zero then
        return true
    end

    return self:Normalized() == vector:Normalized() or self:Normalized() == -vector:Normalized()
end

---
---Spherical linear interpolation between the calling vector and the target vector over t = [0, 1].
---
---@param target Vector # The target vector to interpolate towards.
---@param t number # The interpolation factor, ranging from 0 to 1.
---@return Vector # The resulting vector after spherical linear interpolation.
function meta:Slerp(target, t)
    local dot = self:Dot(target)
    dot = math.max(-1, math.min(1, dot))

    local theta = math.acos(dot) * t
    local relative = target - (self * dot)
    relative = relative:Normalized()

    local a = self * math.cos(theta)
    local b = relative * math.sin(theta)

    return a + b
end

---
---Translates the vector in a local coordinate system.
---
---@param offset Vector # The translation offset vector.
---@param forward Vector # The forward direction of the local coordinate system.
---@param right Vector # The right direction of the local coordinate system.
---@param up Vector # The up direction of the local coordinate system.
---@return Vector # The translated 3D vector.
function meta:LocalTranslate(offset, forward, right, up)
    local x = self.x + offset.x * forward.x + offset.y * right.x + offset.z * up.x
    local y = self.y + offset.x * forward.y + offset.y * right.y + offset.z * up.y
    local z = self.z + offset.x * forward.z + offset.y * right.z + offset.z * up.z
    -- local x = self.x + offset.x * right.x + offset.y * up.x + offset.z * forward.x
    -- local y = self.y + offset.x * right.y + offset.y * up.y + offset.z * forward.y
    -- local z = self.y + offset.x * right.z + offset.y * up.z + offset.z * forward.z
    return Vector(x, y, z)
end

---
---Calculates the angle difference between the calling vector and the given vector. This is always the smallest angle.
---
---@param vector Vector # The vector to calculate the angle difference with.
---@return number # Angle difference in degrees.
function meta:AngleDiff(vector)
    local denominator = math.sqrt(self:Length() * vector:Length())
    if denominator < 1e-15 then
        return 0
    end
    local dot = Clamp(self:Dot(vector) / denominator, -1, 1)
    return Rad2Deg(math.acos(dot))
end

---
---Calculates the signed angle difference between the calling vector and the given vector around the specified axis.
---
---@param vector Vector # The vector to calculate the angle difference with.
---@param axis? Vector # The axis of rotation around which the angle difference is calculated.
---@return number # The signed angle difference in degrees.
function meta:SignedAngleDiff(vector, axis)
    axis = axis or Vector(0, 0, 1)
    local unsignedAngle = self:AngleDiff(vector)

    local cross = self:Cross(vector)
    local sign = math.sign(axis:Dot(cross))

    return unsignedAngle * sign
end

---
---Unpacks the x, y, z components as 3 return values.
---
---@return number # x component
---@return number # y component
---@return number # z component
function meta:Unpack()
    return self.x, self.y, self.z
end

---
---Returns the squared length of the vector, without using sqrt.
---
---@return number
function meta:LengthSquared()
    return self.x * self.x + self.y * self.y + self.z * self.z
end

---
---Checks if this vector is similar to another vector within a given tolerance.
---
---@param vector Vector # The vector to compare against.
---@param tolerance? number # The tolerance within which the vectors are considered similar. Default is 1e-5. See [math.isclose](lua://math.isclose)
---@return boolean # Returns `true` if the vectors are similar within the tolerance, otherwise `false`.
function meta:IsSimilarTo(vector, tolerance)
    tolerance = tolerance or 1e-5
    return IsVector(vector)
        and math.isclose(self.x, vector.x, nil, tolerance)
        and math.isclose(self.y, vector.y, nil, tolerance)
        and math.isclose(self.z, vector.z, nil, tolerance)
end

---
---Creates a copy of the vector.
---
---@return Vector # A new vector with the same components as the original.
function meta:Clone()
    return Vector(self.x, self.y, self.y)
end

return version