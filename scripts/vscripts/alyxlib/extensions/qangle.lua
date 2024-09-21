--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Provides QAngle class extension methods.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.extensions.qangle"
]]
-- require "alyxlib.math.common"

local version = "v1.0.0"

---@class QAngle
local meta = getmetatable(QAngle())

---
---Multiplies two QAngles together and returns the result.
---
---@param a QAngle|number|Vector
---@param b QAngle|number|Vector
---@return QAngle
function meta.__mul(a, b)
    if type(a) == "number" then
        return QAngle(a * b.x, a * b.y, a * b.z)
    elseif type(b) == "number" then
        return QAngle(b * a.x, b * a.y, b * a.z)
    else
        return QAngle(a.x * b.x, a.y * b.y, a.z * b.z)
    end
end

---
---Divides one QAngle by another and returns the result.
---
---@param a QAngle|number|Vector
---@param b QAngle|number|Vector
---@return QAngle
function meta.__div(a, b)
    if type(a) == "number" then
        return QAngle(a / b.x, a / b.y, a / b.z)
    elseif type(b) == "number" then
        return QAngle(b / a.x, b / a.y, b / a.z)
    else
        return QAngle(a.x / b.x, a.y / b.y, a.z / b.z)
    end
end

---
---Subtracts one QAngle by another and returns the result.
---
---@param a QAngle|number|Vector
---@param b QAngle|number|Vector
---@return QAngle
function meta.__sub(a, b)
    if type(a) == "number" then
        return QAngle(a - b.x, a - b.y, a - b.z)
    elseif type(b) == "number" then
        return QAngle(b - a.x, b - a.y, b - a.z)
    else
        return QAngle(a.x - b.x, a.y - b.y, a.z - b.z)
    end
end

return version