--[[
    v1.2.2
    https://github.com/FrostSource/alyxlib

    An inventory is a table where each key has an integer value assigned to it.
    When a value hits 0 the key is removed from the table.

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "alyxlib.data.inventory"
    ```

    ======================================== Usage ========================================

    ```lua
    -- Create an inventory with 2 initial keys.
    local inv = Inventory({
        gun = 1,
        metal = 4
    })

    -- Remove 1 from metal
    -- Prints "3"
    print(inv:Remove("metal"))

    -- Add 3 to gun
    -- Prints "4"
    print(inv:Add("gun", 3))

    -- Get the highest value key
    -- Prints "gun  4"
    print(inv:Highest())

    -- To loop over the items, reference queue.items directly
    for key, value in pairs(inv.items) do
        print(key, value)
    end

    -- Or use the `pairs` helper function:
    for key, value in inv:pairs() do
        print(key, value)
    end
    ```

    =========================================== Notes =============================================

    This class supports `storage` with `Storage.SaveInventory()`:

    ```lua
    Storage:SaveInventory('inv', inv)
    inv = Storage:LoadInventory('inv')
    ```
    
    Inventories are also natively saved using `Storage.Save()` or if encountered in a table being saved.
]]

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
    ---@param handle EntityHandle # The entity to save on.
    ---@param name string # The name to save as.
    ---@param inventory Inventory # The inventory to save.
    ---@return boolean # If the save was successful.
    ---@luadoc-ignore
    function InventoryClass.__save(handle, name, inventory)
        -- Storage.SaveTable(handle, Storage.Join(name, "items"), inventory.items)
        -- Storage.SaveType(handle, name, "util.Inventory")
        -- return true
        return Storage.SaveTableCustom(handle, name, inventory, "Inventory")
    end

    ---
    ---**Static Function**
    ---
    ---Helper function for loading the `inventory`.
    ---
    ---@param handle EntityHandle # Entity to load from.
    ---@param name string # Name to load.
    ---@return Inventory|nil
    ---@luadoc-ignore
    function InventoryClass.__load(handle, name)
        -- local items = Storage.LoadTable(handle, Storage.Join(name, "items"))
        -- if items ~= nil then
        --     local _inventory = Inventory()
        --     _inventory.items = items
        --     return _inventory
        -- end
        -- return nil
        local inventory = Storage.LoadTableCustom(handle, name, "Inventory")
        if inventory == nil then return nil end
        return setmetatable(inventory, InventoryClass)
    end

    Storage.SaveInventory = InventoryClass.__save
    CBaseEntity.SaveInventory = Storage.SaveInventory

    ---
    ---Load an Inventory.
    ---
    ---@generic T
    ---@param handle EntityHandle # Entity to load from.
    ---@param name string # Name the Inventory was saved as.
    ---@param default? T # Optional default value.
    ---@return Inventory|T
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
---Add a number of values to a key.
---
---@param key any
---@param value? integer # Default is 1.
---@return number # The value of the key after adding.
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
---Remove a number of values from a key.
---
---@param key any
---@param value? integer # Default is 1.
---@return number # The value of the key after removal.
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
---Get the value associated with a key. This is *not* the same as `inv.items[key]`.
---
---@param key any
---@return integer
function InventoryClass:Get(key)
    local val = self.items[key]
    if val then
        return val
    end
    return 0
end

---
---Get the key with the highest value and its value.
---
---@return any # The key with the highest value.
---@return integer # The value associated with the key.
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
---Get the key with the lowest value and its value.
---
---@return any # The key with the lowest value.
---@return integer # The value associated with the key.
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
---Get if the inventory contains a key with a value greater than 0.
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
---Return the number of items in the inventory.
---
---@return integer key_sum # Total number of keys in the inventory.
---@return integer value_sum # Total number of values assigned to all keys.
function InventoryClass:Length()
    local key_sum,value_sum = 0,0
    for _,value in pairs(self.items) do
        key_sum = key_sum + 1
        value_sum = value_sum + value
    end
    return key_sum,value_sum
end

---
---Get if the inventory is empty.
---
---@return boolean
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
---Create a new `Inventory` object.
---
---@param starting_inventory? table<any,integer>
---@return Inventory
function Inventory(starting_inventory)
    return setmetatable({
        items = starting_inventory or {}
    },
    InventoryClass)
end