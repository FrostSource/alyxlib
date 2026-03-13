# Utils Common

> scripts/vscripts/alyxlib/utils/common.lua

## Global variables

| Name | Value |
| -------------------- | ----- |
| `Util` | `table` |

## Methods

### GetHandIdFromTip

Converts `vr_tip_attachment` from a game event (1,2) into a hand id (0,1) taking primary hand into account.

```lua
Util:GetHandIdFromTip(vr_tip_attachment)
```

**Parameters**

- **`vr_tip_attachment`**  
  `1`, `2`  
  The `vr_tip_attachment` value from a game event

**Returns**
- **`0|1`**
The hand id

### FindKeyFromValue
!!! danger "This method is deprecated."


Attempts to find a key in `tbl` pointing to `value`.

```lua
Util:FindKeyFromValue(tbl, value)
```

**Parameters**

- **`tbl`**  
  `table`  
  The table to search
- **`value`**  
  `any`  
  The value to search for

**Returns**
- **`unknown|nil`**
The key in `tbl`, or `nil` if no `value` was found

### TableSize
!!! danger "This method is deprecated."


Returns the size of any table.

```lua
Util:TableSize(tbl)
```

**Parameters**

- **`tbl`**  
  `table`  
  The table to get the size of

**Returns**
- **`integer`**
The size of the table

### Delay

Delays some code.

```lua
Util:Delay(func, delay)
```

**Parameters**

- **`func`**  
  `function`  
  The function to delay
- **`delay`** *(optional)*  
  `number`  
  The delay in seconds (default: 0)

### QAngleFromVector

Gets a new `QAngle` from a `Vector`.

This simply transfers the raw values from one to the other.

```lua
Util:QAngleFromVector(vec)
```

**Parameters**

- **`vec`**  
  `Vector`  
  The vector

**Returns**
- **`QAngle`**
The new QAngle

### CreateConstraint

Creates a constraint between two entity handles.

```lua
Util:CreateConstraint(entity1, entity2, class, properties)
```

**Parameters**

- **`entity1`**  
  `EntityHandle`  
  First entity to attach
- **`entity2`**  
  `EntityHandle`, `nil`  
  Second entity to attach, or `nil` to attach to world
- **`class`** *(optional)*  
  `string`  
  Class of constraint (default: `phys_constraint`)
- **`properties`** *(optional)*  
  `table`  
  Key/value property table for the constraint

**Returns**
- **`EntityHandle`**
The created constraint

### CreateExplosion

Creates a damaging explosion effect at a position.

```lua
Util:CreateExplosion(origin, explosionType, magnitude, radiusOverride, ignoredEntity, ignoredClass)
```

**Parameters**

- **`origin`**  
  `Vector`  
  Worldspace position
- **`explosionType`** *(optional)*  
  `ExplosionType`  
  Explosion type (default: "")
- **`magnitude`** *(optional)*  
  `number`  
  Explosion magnitude (default: 100)
- **`radiusOverride`** *(optional)*  
  `number`  
  Radius override (default: 0)
- **`ignoredEntity`** *(optional)*  
  `EntityHandle`, `string`  
  Targetname to ignore or entity handle with a name
- **`ignoredClass`** *(optional)*  
  `string`  
  Classname to ignore (default: "")

### Choose

Chooses a random value from the provided arguments.

```lua
Util:Choose(...)
```

**Parameters**

- **`...`**  

**Returns**
- **`T`**
Chosen value

### VectorFromString

Turns a string of up to three numbers into a vector.

Should have a format of "x y z"

```lua
Util:VectorFromString(str)
```

**Parameters**

- **`str`**  
  `string`  
  String to parse

**Returns**
- **`Vector`**
Parsed vector

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
