# Data Inventory

> scripts/vscripts/alyxlib/data/inventory.lua

## Methods

### Add

Add a number of values to a key.

```lua
Inventory:Add(key, value)
```

**Parameters**

- **`key`**  
  `any`  
- **`value`** *(optional)*  
  `integer`  
  Default is 1.

**Returns**
- **`number`**
The value of the key after adding.

### Remove

Remove a number of values from a key.

```lua
Inventory:Remove(key, value)
```

**Parameters**

- **`key`**  
  `any`  
- **`value`** *(optional)*  
  `integer`  
  Default is 1.

**Returns**
- **`number`**
The value of the key after removal.

### Get

Get the value associated with a key. This is *not* the same as `inv.items[key]`.

```lua
Inventory:Get(key)
```

**Parameters**

- **`key`**  
  `any`  

**Returns**
- **`integer`**

### Highest

Get the key with the highest value and its value.

```lua
Inventory:Highest()
```

**Returns**

- **`any`**  
    
The key with the highest value.

- **`integer`**  
    
The value associated with the key.

### Lowest

Get the key with the lowest value and its value.

```lua
Inventory:Lowest()
```

**Returns**

- **`any`**  
    
The key with the lowest value.

- **`integer`**  
    
The value associated with the key.

### Contains

Get if the inventory contains a key with a value greater than 0.

```lua
Inventory:Contains(key)
```

**Parameters**

- **`key`**  
  `any`  

**Returns**
- **`boolean`**

### Length

Return the number of items in the inventory.

```lua
Inventory:Length()
```

**Returns**

- **`integer`**  
   *`key_sum`*  
Total number of keys in the inventory.

- **`integer`**  
   *`value_sum`*  
Total number of values assigned to all keys.

### IsEmpty

Get if the inventory is empty.

```lua
Inventory:IsEmpty()
```

**Returns**
- **`boolean`**

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

Create a new `Inventory` object.

```lua
Inventory(starting_inventory)
```

**Parameters**

- **`starting_inventory`** *(optional)*  
  `table<any,integer>`  

**Returns**
- **`Inventory`**

## Types

### Inventory
