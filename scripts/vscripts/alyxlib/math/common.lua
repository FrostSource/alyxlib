--[[
    v1.2.0
    https://github.com/FrostSource/alyxlib

    Extends the math library with useful functions.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.math.common"
]]

local version = "v1.2.0"

---
---Get the sign of a number.
---
---@param x number # The input number.
---@return 1|0|-1 # Returns 1 if the number is positive, -1 if the number is negative, or 0 if the number is zero.
function math.sign(x)
    return x > 0 and 1 or (x < 0 and -1 or 0)
end

---
---Truncates a number to the specified number of decimal places.
---
---@param number number # The input number.The input number.
---@param places? integer # The number of decimal places to keep.
---@return number #  The input number truncated to the specified decimal places.
function math.trunc(number, places)
    local shift = 10 ^ (places or 1)
    return math.floor(number * shift) / shift
end

---
---Rounds a number to the specified number of decimal places.
---
---@param number number # The input number to be rounded.
---@param decimals? integer # The number of decimal places to round to. If not provided, the number will be rounded to the nearest whole number.
---@return number # The input number rounded to the specified decimal places or nearest whole number.
function math.round(number, decimals)
    local shift = 10 ^ (decimals or 0)
    return math.floor(number * shift + 0.5) / shift
end

---
---Check if two numbers are close to each other within a specified tolerance.
---
---@param a number # The first number to compare.
---@param b number # The second number to compare.
---@param rel_tol? number # The relative tolerance (optional).
---@param abs_tol? number # The absolute tolerance (optional).
---@return boolean # True if the numbers are close; false otherwise.
function math.isclose(a, b, rel_tol, abs_tol)
    rel_tol = rel_tol or 1e-8
    abs_tol = abs_tol or 0.0

    if a == b then
        return true
    end

    local diff = math.abs(b - a)
    return ((diff <= math.abs(rel_tol * b)) or (diff <= math.abs(rel_tol * a))) or (diff <= abs_tol)
end

---
---Checks if a given number has a fractional part (decimal part).
---
---@param number number # The number to check for fractional part.
---@return boolean # True if the number has a fractional part, false otherwise.
function math.has_frac(number)
    return type(number) == "number" and number ~= math.floor(number)
end


return version