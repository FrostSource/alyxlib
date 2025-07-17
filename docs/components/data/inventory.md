## inventory.lua

> An inventory is a table where each key has an integer value assigned to it. When a value hits 0 the key is removed from the table.
>
> This class registers with `Storage` for easy saving/loading

```lua
-- The inventory table may use any type that Lua allows as a key, including other tables, but the value part MUST be a number type
-- Create an inventory with 2 initial keys.
local inv = Inventory({
    gun = 1,
    metal = 4
})

-- Remove 1 from metal, returns the new value after removal
print(inv:Remove("metal")) -- Prints "3"

-- Add 3 to gun, returns the new value after adding
print(inv:Add("gun", 3)) -- Prints "4"

-- Get the highest key/value pair in the inventory
local key, val = inv:Highest()
print(key, val) -- Prints "gun  4"

-- To loop over the items you can reference the inventory `items` property directly
for key, value in pairs(inv.items) do
    print(key, value)
end

-- Or use the `pairs` helper method:
for key, value in inv:pairs() do
    print(key, value)
end
```

This class supports `storage` with `Storage.SaveInventory`
Inventories are also natively saved using `Storage.Save()` or if encountered in a table being saved.

```lua
Storage:SaveInventory('inv', inv)
inv = Storage:LoadInventory('inv')
```