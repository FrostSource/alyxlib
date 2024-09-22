--[[
    v1.3.0
    https://github.com/FrostSource/alyxlib

    Extends the math library with useful functions.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.math.common"
]]

local version = "v1.3.0"

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
---Checks if two numbers are close to each other within a specified tolerance.
---
---@param a number       # The first number to compare.
---@param b number       # The second number to compare.
---@param rel_tol? number # The relative tolerance (optional). Defines the maximum allowed relative difference between `a` and `b` as a percentage of the larger of the two values.
---@param abs_tol? number # The absolute tolerance (optional). Defines the maximum allowed fixed difference between `a` and `b`, regardless of their magnitudes.
---@return boolean      # Returns `true` if the numbers are considered close based on the specified tolerances; otherwise, returns `false`.
---
--- **Examples:**
---
--- 1. **Relative Tolerance (`rel_tol`)**:
---    ```lua
---    local result1 = math.isclose(1000, 1020, 0.02)
---    -- Expected Output: true
---    -- Explanation: The difference (20) is within 2% of the larger number (1020), which allows a maximum difference of 20.4.
---    ```
---
--- 2. **Absolute Tolerance (`abs_tol`)**:
---    ```lua
---    local result2 = math.isclose(1000, 1015, nil, 15)
---    -- Expected Output: true
---    -- Explanation: The difference (15) is within the fixed absolute tolerance of 15.
---    ```
---
function math.isclose(a, b, rel_tol, abs_tol)
    rel_tol = rel_tol or 1e-4
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

---
---Returns the fractional part of a number.
---
---@param number number # The number to get the fractional part of.
---@return number # The fractional part of the number.
function math.get_frac(number)
    return number - math.floor(number)
end

return version