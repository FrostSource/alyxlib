# Storage

> scripts/vscripts/alyxlib/storage.lua

## Properties

### version

```lua
Storage.version = value
```

**Default value**
  `"v3.3.0"`

## Methods

### RegisterType

Registers a class table type with a name.

```lua
Storage:RegisterType(name, T)
```

**Parameters**

- **`name`**  
  `string`  
  Name that the type will be saved as
- **`T`**  
  `table`  
  Class table

### UnregisterType

Unregisters a class type.

```lua
Storage:UnregisterType(name, T)
```

**Parameters**

- **`name`**  
  `string`  
  Name to unregister
- **`T`**  
  `table`  
  Class to unregister

### Join

Joins a list of values by the hidden separator.

```lua
Storage:Join(...)
```

**Parameters**

- **`...`**  

**Returns**
- **`string`**
Joined string

### SaveType

Helper function for saving the type correctly.

No failsafes are provided in this function, you must be sure you are saving correctly.

```lua
Storage:SaveType(handle, name, T)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to save on
- **`name`**  
  `string`  
  Name prefix to save as
- **`T`**  
  `string`  
  String name of `T`

### SaveString

Saves a string.

```lua
Storage:SaveString(handle, name, value)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to save on
- **`name`**  
  `string`  
  Name to save as
- **`value`**  
  `string`, `nil`  
  String to save

**Returns**
- **`boolean`**
If the save was successful

### SaveNumber

Saves a number.

```lua
Storage:SaveNumber(handle, name, value)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to save on
- **`name`**  
  `string`  
  Name to save as
- **`value`**  
  `number`, `nil`  
  Number to save

**Returns**
- **`boolean`**
If the save was successful

### SaveBoolean

Saves a boolean.

```lua
Storage:SaveBoolean(handle, name, bool)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to save on
- **`name`**  
  `string`  
  Name to save as
- **`bool`**  
  `boolean`, `nil`  
  Boolean to save

**Returns**
- **`boolean`**
If the save was successful

### SaveVector

Saves a Vector.

```lua
Storage:SaveVector(handle, name, vector)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to save on
- **`name`**  
  `string`  
  Name to save as
- **`vector`**  
  `Vector`, `nil`  
  Vector to save

**Returns**
- **`boolean`**
If the save was successful

### SaveQAngle

Saves a QAngle.

```lua
Storage:SaveQAngle(handle, name, qangle)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to save on
- **`name`**  
  `string`  
  Name to save as
- **`qangle`**  
  `QAngle`, `nil`  
  QAngle to save

**Returns**
- **`boolean`**
If the save was successful

### SaveTableCustom

Saves a table with a custom type.
Should be used with custom save functions.

If trying to save a normal table use `Storage.SaveTable`.

```lua
Storage:SaveTableCustom(handle, name, tbl, T, save_meta)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to save on
- **`name`**  
  `string`  
  Name to save as
- **`tbl`**  
  `table<any,any>`  
  Table to save
- **`T`**  
  `string`  
  Type to save as
- **`save_meta`** *(optional)*  
  `boolean`  
  If keys starting with '__' should be saved

**Returns**
- **`boolean`**
If the save was successful

### SaveTable

Saves a table.

May be ordered, unordered or mixed.

May have nested tables.

```lua
Storage:SaveTable(handle, name, tbl)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to save on
- **`name`**  
  `string`  
  Name to save as
- **`tbl`**  
  `table<any,any>`  
  Table to save

**Returns**
- **`boolean`**
If the save was successful

### SaveEntity

Saves an entity reference.

Entity handles change between game sessions so this function
modifies the passed entity to make sure it can keep track of it.

```lua
Storage:SaveEntity(handle, name, entity)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to save on
- **`name`**  
  `string`  
  Name to save as
- **`entity`**  
  `EntityHandle`, `nil`  
  Entity to save

**Returns**
- **`boolean`**
If the save was successful

### Save

Saves a value.

Uses type inference to save the value.
If you are experiencing errors consider saving with one of the explicit type saves.

```lua
Storage:Save(handle, name, value)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to save on
- **`name`**  
  `string`  
  Name to save as
- **`value`**  
  `any`  
  Value to save

**Returns**
- **`boolean`**
If the save was successful

### LoadString

Loads a string.

```lua
Storage:LoadString(handle, name, default)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to load from
- **`name`**  
  `string`  
  Name the string was saved as
- **`default`** *(optional)*  
  `T`  
  Optional default value

**Returns**
- **`string|T`**
Saved string or `default`

### LoadNumber

Loads a number.

```lua
Storage:LoadNumber(handle, name, default)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to load from
- **`name`**  
  `string`  
  Name the number was saved as
- **`default`** *(optional)*  
  `T`  
  Optional default value

**Returns**
- **`number|T`**
Saved number or `default`

### LoadBoolean

Loads a boolean value.

```lua
Storage:LoadBoolean(handle, name, default)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to load from
- **`name`**  
  `string`  
  Name the boolean was saved as
- **`default`** *(optional)*  
  `T`  
  Optional default value

**Returns**
- **`boolean|T`**
Saved boolean or `default`

### LoadVector

Loads a Vector.

```lua
Storage:LoadVector(handle, name, default)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to load from
- **`name`**  
  `string`  
  Name the Vector was saved as
- **`default`** *(optional)*  
  `T`  
  Optional default value

**Returns**
- **`Vector|T`**
Saved Vector or `default`

### LoadQAngle

Loads a QAngle.

```lua
Storage:LoadQAngle(handle, name, default)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to load from
- **`name`**  
  `string`  
  Name the QAngle was saved as
- **`default`** *(optional)*  
  `T`  
  Optional default value

**Returns**
- **`QAngle|T`**
Saved QAngle or `default`

### LoadTableCustom

Loads a table with a custom type.
Should be used with custom load functions.

If trying to load a normal table use `Storage.LoadTable`.

```lua
Storage:LoadTableCustom(handle, name, T, default)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to load from
- **`name`**  
  `string`  
  Name the table was saved as
- **`T`**  
  `string`  
  Type to save as
- **`default`** *(optional)*  
  `T`  
  Optional default value

**Returns**
- **`table|T`**
Saved table or `default`

### LoadTable

Loads a table with a custom type.

```lua
Storage:LoadTable(handle, name, default)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to load from
- **`name`**  
  `string`  
  Name the table was saved as
- **`default`** *(optional)*  
  `T`  
  Optional default value

**Returns**
- **`table|T`**
Saved table or `default`

### LoadEntity

Loads an entity.

```lua
Storage:LoadEntity(handle, name, default)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to load from
- **`name`**  
  `string`  
  Name to save as
- **`default`** *(optional)*  
  `T`  
  Optional default value

**Returns**
- **`EntityHandle|T`**
Saved entity or `default`

### Load

Loads a value.

```lua
Storage:Load(handle, name, default)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to load from
- **`name`**  
  `string`  
  Name the value was saved as
- **`default`** *(optional)*  
  `any`  
  Optional default value

**Returns**
- **`any`**
Saved value or `default`

### LoadAll

Loads all values saved to an entity.

```lua
Storage:LoadAll(handle, direct)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Entity to load from
- **`direct`** *(optional)*  
  `boolean`  
  Optionally load values directly into `handle` instead of a new table

**Returns**
- **`table`**
Table of loaded values (or `handle` if `direct` is true)
