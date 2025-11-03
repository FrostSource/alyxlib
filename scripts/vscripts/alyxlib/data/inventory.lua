--[[
    v1.2.3
    https://github.com/FrostSource/alyxlib

    An inventory is a table where each key has an integer value assigned to it.
    When a value hits 0 the key is removed from the table.

    If not using `alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.data.inventory"
]]

local version = "v1.2.3"

---
---Inventory data structure.
---
---@class Inventory
local InventoryClass =
{
    ---@type table<any, integer>
    items = {},
}
InventoryClass.__index = InventoryClass

if pcall(require, "alyxlib.storage") then
    Storage.RegisterType("Inventory", InventoryClass)

    ---
    ---**Static Function**
    ---
    ---Helper function for saving the `inventory`.
    ---
    ---@param handle EntityHandle # The entity to save on
    ---@param name string # The name to save as
    ---@param inventory Inventory # The inventory to save
    ---@return boolean # If the save was successful
    ---@luadoc-ignore
    function InventoryClass.__save(handle, name, inventory)
        return Storage.SaveTableCustom(handle, name, inventory, "Inventory")
    end

    ---
    ---**Static Function**
    ---
    ---Helper function for loading the `inventory`.
    ---
    ---@param handle EntityHandle # Entity to load from
    ---@param name string # Name to load
    ---@return Inventory|nil # The loaded inventory
    ---@luadoc-ignore
    function InventoryClass.__load(handle, name)
        local inventory = Storage.LoadTableCustom(handle, name, "Inventory")
        if inventory == nil then return nil end
        return setmetatable(inventory, InventoryClass)
    end

    Storage.SaveInventory = InventoryClass.__save
    CBaseEntity.SaveInventory = Storage.SaveInventory

    ---
    ---Loads an Inventory.
    ---
    ---@generic T
    ---@param handle EntityHandle # Entity to load from
    ---@param name string # Name the Inventory was saved as
    ---@param default? T # Optional default value
    ---@return Inventory|T # The loaded Inventory
    ---@luadoc-ignore
    Storage.LoadInventory = function(handle, name, default)
        local inventory = InventoryClass.__load(handle, name)
        if inventory == nil then
            return default
        end
        return inventory
    end
    CBaseEntity.LoadInventory = Storage.LoadInventory
end

---
---Increases value amount to a key.
---
---If the key does not exist, it will be created.  
---If no value is provided, it will default to 1.
---
---@param key any # The key to increment
---@param value? integer # Value to increment by
---@return number # Value of the key after increment
function InventoryClass:Add(key, value)
    value = value or 1
    local current = self.items[key]
    if current then
        self.items[key] = current + value
        return self.items[key]
    else
        self.items[key] = value
        return value
    end
end

---
---Decreases the value of a key.
---
---@param key any # The key to decrement
---@param value? integer # Value to decrement by
---@return number # Value of the key after decrement
function InventoryClass:Remove(key, value)
    value = value or 1
    local current = self.items[key]
    if current then
        self.items[key] = current - value
        if current - value <= 0 then
            self.items[key] = nil
            return 0
        end
        return self.items[key]
    else
        return 0
    end
end

---
---Gets the value associated with a key.
---If the key does not exist, 0 is returned.
---
---@param key any # The key to get
---@return integer # Value of the key
function InventoryClass:Get(key)
    local val = self.items[key]
    if val then
        return val
    end
    return 0
end

---
---Gets the key with the highest value and its value.
---
---@return any # The key with the highest value
---@return integer # The value associated with the key
function InventoryClass:Highest()
    local best_key, best_value = nil, 0
    for key, value in pairs(self.items) do
        if value > best_value then
            best_key = key
            best_value = value
        end
    end
    return best_key, best_value
end

---
---Gets the key with the lowest value and its value.
---
---@return any # The key with the lowest value
---@return integer # The value associated with the key
function InventoryClass:Lowest()
    local best_key, best_value = nil, nil
    for key, value in pairs(self.items) do
        best_value = best_value or value
        if value < best_value then
            best_key = key
            best_value = value
        end
    end
    return best_key, (best_value or 0)
end

---
---Gets if the inventory contains `key` with a value greater than 0.
---
---@param key any
---@return boolean
function InventoryClass:Contains(key)
    if self.items[key] then
        return true
    end
    return false
end

---
---Returns the number of items in the inventory.
---
---@return integer key_sum # Total number of keys in the inventory
---@return integer value_sum # Total number of values assigned to all keys
function InventoryClass:Length()
    local key_sum,value_sum = 0,0
    for _,value in pairs(self.items) do
        key_sum = key_sum + 1
        value_sum = value_sum + value
    end
    return key_sum,value_sum
end

---
---Gets if the inventory is empty.
---
---@return boolean # True if the inventory is empty
function InventoryClass:IsEmpty()
    for _, _ in pairs(self.items) do
        return false
    end
    return true
end

---
---Helper method for looping.
---
---@return fun(table: any[], i: integer):integer, any
---@return table<any,integer>
function InventoryClass:pairs()
    return pairs(self.items)
end

function InventoryClass:__tostring()
    return string.format("Inventory (%d keys, %d values)", self:Length())
end


---
---Creates a new [Inventory](lua://Inventory) object.
---
---@param startingInventory? table<any,integer> # Starting inventory
---@return Inventory # The new [Inventory](lua://Inventory)
function Inventory(startingInventory)
    return setmetatable({
        items = startingInventory or {}
    },
    InventoryClass)
end

return version