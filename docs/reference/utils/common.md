# Utils Common

> scripts/vscripts/alyxlib/utils/common.lua

## Global variables

| Name | Value |
| -------------------- | ----- |
| `Util` | `{}` |

## Methods

### GetHandIdFromTip

Convert vr_tip_attachment from a game event [1,2] into a hand id [0,1] taking into account left handedness.

```lua
Util:GetHandIdFromTip(vr_tip_attachment)
```

**Parameters**

- **`vr_tip_attachment`**  
  `1`, `2`  

**Returns**
- **`0|1`**

### FindKeyFromValue

Attempt to find a key in `tbl` pointing to `value`.

```lua
Util:FindKeyFromValue(tbl, value)
```

**Parameters**

- **`tbl`**  
  `table`  
  The table to search.
- **`value`**  
  `any`  
  The value to search for.

**Returns**
- **`unknown|nil`**
  The key in `tbl` or nil if no `value` was found.

### TableSize

Returns the size of any table.

```lua
Util:TableSize(tbl)
```

**Parameters**

- **`tbl`**  
  `table`  

**Returns**
- **`integer`**

### Delay

Delay some code.

```lua
Util:Delay(func, delay)
```

**Parameters**

- **`func`**  
  `function`  
- **`delay`** *(optional)*  
  `number`  

### QAngleFromVector

Get a new `QAngle` from a `Vector`.
This simply transfers the raw values from one to the other.

```lua
Util:QAngleFromVector(vec)
```

**Parameters**

- **`vec`**  
  `Vector`  

**Returns**
- **`QAngle`**

### CreateConstraint

Create a constraint between two entity handles.

```lua
Util:CreateConstraint(entity1, entity2, class, properties)
```

**Parameters**

- **`entity1`**  
  `EntityHandle`  
  First entity to attach.
- **`entity2`**  
  `EntityHandle`, `nil`  
  Second entity to attach. Set nil to attach to world.
- **`class`** *(optional)*  
  `string`  
  Class of constraint, default is `phys_constraint`.
- **`properties`** *(optional)*  
  `table`  
  Key/value property table.

**Returns**
- **`EntityHandle`**

### CreateExplosion

Create a damaging explosion effect at a position.

```lua
Util:CreateExplosion(origin, explosionType, magnitude, radiusOverride, ignoredEntity, ignoredClass)
```

**Parameters**

- **`origin`**  
  `Vector`  
- **`explosionType`** *(optional)*  
  `ExplosionType`  
- **`magnitude`** *(optional)*  
  `number`  
- **`radiusOverride`** *(optional)*  
  `number`  
- **`ignoredEntity`** *(optional)*  
  `EntityHandle`, `string`  
  If the entity passed does not have a unique name, all entities with that name will be ignored.
- **`ignoredClass`** *(optional)*  
  `string`  

### Choose

Choose and return a random argument.

```lua
Util:Choose(...)
```

**Parameters**

- **`...`**  

**Returns**
- **`T`**

### VectorFromString

Turns a string of up to three numbers into a vector.

```lua
Util:VectorFromString(str)
```

**Parameters**

- **`str`**  
  `string`  
  Should have a format of "x y z"

**Returns**
- **`Vector`**

## Aliases

### ExplosionType

| Value | Description |
| ----- | ----------- |
| `""` | "Default" |
| `"grenade"` | "Grenade" |
| `"molotov"` | "Molotov" |
| `"fireworks"` | "Fireworks" |
| `"gascan"` | "Gasoline Can" |
| `"gascylinder"` | "Pressurized Gas Cylinder" |
| `"explosivebarrel"` | "Explosive Barrel" |
| `"electrical"` | "Electrical" |
| `"emp"` | "EMP" |
| `"shrapnel"` | "Shrapnel" |
| `"smoke"` | "Smoke Grenade" |
| `"flashbang"` | "Flashbang" |
| `"tripmine"` | "Tripmine" |
| `"ice"` | "Ice" |
| `"none"` | "None" |
| `"custom"` | "Custom" |
