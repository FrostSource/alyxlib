# Data Inventory

> scripts/vscripts/alyxlib/data/inventory.lua

## Methods

### Add

Increases value amount to a key.

If the key does not exist, it will be created.
If no value is provided, it will default to 1.

```lua
Inventory:Add(key, value)
```

**Parameters**

- **`key`**  
  `any`  
  The key to increment
- **`value`** *(optional)*  
  `integer`  
  Value to increment by

**Returns**
- **`number`**
Value of the key after increment

### Remove

Decreases the value of a key.

```lua
Inventory:Remove(key, value)
```

**Parameters**

- **`key`**  
  `any`  
  The key to decrement
- **`value`** *(optional)*  
  `integer`  
  Value to decrement by

**Returns**
- **`number`**
Value of the key after decrement

### Get

Gets the value associated with a key.
If the key does not exist, 0 is returned.

```lua
Inventory:Get(key)
```

**Parameters**

- **`key`**  
  `any`  
  The key to get

**Returns**
- **`integer`**
Value of the key

### Highest

Gets the key with the highest value and its value.

```lua
Inventory:Highest()
```

**Returns**

- **`any`**  
    
The key with the highest value

- **`integer`**  
    
The value associated with the key

### Lowest

Gets the key with the lowest value and its value.

```lua
Inventory:Lowest()
```

**Returns**

- **`any`**  
    
The key with the lowest value

- **`integer`**  
    
The value associated with the key

### Contains

Gets if the inventory contains `key` with a value greater than 0.

```lua
Inventory:Contains(key)
```

**Parameters**

- **`key`**  
  `any`  

**Returns**
- **`boolean`**

### Length

Returns the number of items in the inventory.

```lua
Inventory:Length()
```

**Returns**

- **`integer`**  
   *`key_sum`*  
Total number of keys in the inventory

- **`integer`**  
   *`value_sum`*  
Total number of values assigned to all keys

### IsEmpty

Gets if the inventory is empty.

```lua
Inventory:IsEmpty()
```

**Returns**
- **`boolean`**
True if the inventory is empty

### pairs

Helper method for looping.

```lua
Inventory:pairs()
```

**Returns**

- **`function`**  
    

- **`table<any,integer>`**  
    

## Functions

### Inventory

Creates a new [Inventory](lua://Inventory) object.

```lua
Inventory(startingInventory)
```

**Parameters**

- **`startingInventory`** *(optional)*  
  `table<any,integer>`  
  Starting inventory

**Returns**
- **`Inventory`**
The new [Inventory](lua://Inventory)

## Types

### Inventory

Inventory data structure.
