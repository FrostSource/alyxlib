--[[
    v1.2.2
    https://github.com/FrostSource/alyxlib

    Weighted random allows you to assign chances to tables keys.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.math.weighted_random"
]]

---
---Weighted random allows you to assign chances to tables.
---
---Should be loaded into global scope by using the following line:
---
---      require "math.weighted_random"
---
---@class WeightedRandom
local WR = {
    ---Root list containing all weighted tables.
    ---@type table[]
    ItemPool = {},
    ---If true this weighted random will use math.random().
    ---Otherwise it uses Valve's RandomFloat().
    UseRandomSeed = false,
}
WR.__index = WR

if pcall(require, "alyxlib.storage") then
    Storage.RegisterType("WeightedRandom", WR)

    ---
    ---**Static Function**
    ---
    ---Helper function for saving the `WeightedRandom`.
    ---
    ---@param handle EntityHandle # The entity to save on.
    ---@param name string # The name to save as.
    ---@param wr WeightedRandom # The stack to save.
    ---@return boolean # If the save was successful.
    ---@luadoc-ignore
    function WR.__save(handle, name, wr)
        return Storage.SaveTableCustom(handle, name, wr, "WeightedRandom")
    end

    ---
    ---**Static Function**
    ---
    ---Helper function for loading the `WeightedRandom`.
    ---
    ---@param handle EntityHandle # Entity to load from.
    ---@param name string # Name to load.
    ---@return WeightedRandom|nil
    ---@luadoc-ignore
    function WR.__load(handle, name)
        local wr = Storage.LoadTableCustom(handle, name, "WeightedRandom")
        if wr == nil then return nil end
        return setmetatable(wr, WR)
    end

    Storage.SaveWeightedRandom = WR.__save
    CBaseEntity.SaveWeightedRandom = Storage.SaveWeightedRandom

    ---
    ---Load a WeightedRandom.
    ---
    ---@generic T
    ---@param handle EntityHandle # Entity to load from.
    ---@param name string # Name the WeightedRandom was saved as.
    ---@param default? T # Optional default value.
    ---@return WeightedRandom|T
    ---@luadoc-ignore
    Storage.LoadWeightedRandom = function(handle, name, default)
        local wr = WR.__load(handle, name)
        if wr == nil then
            return default
        end
        return wr
    end
    CBaseEntity.LoadWeightedRandom = Storage.LoadWeightedRandom
end

---
---Add a table value with an associated weight.
---If `tbl` already has a weight key then `weight` parameter can be omitted.
---
---Note: The table `tbl` is not cloned, the given reference is used.
---
---@param tbl table # Table of values that will be returned.
---@param weight? number # Weight for this table.
function WR:Add(tbl, weight)
    if weight ~= nil then tbl.weight = weight end
    self.ItemPool[#self.ItemPool+1] = tbl
end
---
---Get the total weight of this weighted random object.
---
---@return number # The sum of all weights.
function WR:TotalWeight()
    local weight_sum = 0
    for _,item in ipairs(self.ItemPool) do
        weight_sum = weight_sum + item.weight
    end
    return weight_sum
end

---
---Pick a random table from the list of weighted tables.
---
---@return table
function WR:Random()
    local weight_sum = self:TotalWeight()
    local weight_remaining
    if self.UseRandomSeed then
        weight_remaining = math.random(0, weight_sum)
    else
        weight_remaining = RandomFloat(0, weight_sum)
    end
    for _,item in ipairs(self.ItemPool) do
        weight_remaining = weight_remaining - item.weight
        if weight_remaining < 0 then
            return item
        end
    end
    -- Return to last item just in case (should never reach here.)
    return self.ItemPool[#self.ItemPool]
end

---
---Create a new WeightedRandom object with given weights.
---
---E.g.
---
---    local wr = WeightedRandom({
---        { weight = 1, name = "Common" },
---        { weight = 0.75, name = "Semi-common" },
---        { weight = 0.5, name = "Uncommon" },
---        { weight = 0.25, name = "Rare" },
---        { weight = 0.1, name = "Extremely rare" },
---    })
---
---Params:
---
---@param weights table[]|`{\n\t{ weight = 1 },\n}`
---@return WeightedRandom
function WeightedRandom(weights)
    return setmetatable({ItemPool = weights or {}}, WR)
end

