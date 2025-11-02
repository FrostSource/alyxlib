# Class

> scripts/vscripts/alyxlib/class.lua

## Global variables

| Name | Value |
| -------------------- | ----- |
| `EntityClassNameMap` | `table` |
| `READY_NORMAL` | `0` |
| `READY_GAME_LOAD` | `2` |
| `READY_TRANSITION` | `3` |

## Methods

### Set
!!! danger "This method is deprecated."


Assign a new value to entity's field `name`.
This also saves the field.

```lua
EntityClass:Set(name, value)
```

**Parameters**

- **`name`**  
  `string`  
- **`value`**  
  `any`  

### Save

Save a given entity field. Call with no arguments to save all data.

```lua
EntityClass:Save(name, value)
```

**Parameters**

- **`name`** *(optional)*  
  `string`  
  Name of the field to save.
- **`value`** *(optional)*  
  `any`  
  Value to save. If not provided the value will be retrieved from the field with the same `name`.

### Think

```lua
EntityClass:Think()
```

### ResumeThink

Resume the entity think function.

```lua
EntityClass:ResumeThink()
```

### PauseThink

Pause the entity think function.

```lua
EntityClass:PauseThink()
```

### Output

Define a function to redirected to `output` on spawn.

```lua
EntityClass:Output(output, func)
```

**Parameters**

- **`output`**  
  `string`  
- **`func`**  
  `function`  

### GameEvent

Define a function for listening to a game event.

```lua
EntityClass:GameEvent(gameEvent, func)
```

**Parameters**

- **`gameEvent`**  
  `GameEventsAll`  
- **`func`**  
  `function`  

### PlayerEvent

Define a function for listening to a player event.

```lua
EntityClass:PlayerEvent(playerEvent, func)
```

**Parameters**

- **`playerEvent`**  
  `PLAYER_EVENTS_ALL`  
- **`func`**  
  `function`  

## Functions

### inherit

Inherit an existing entity class which was defined using `entity` function.

```lua
inherit(script, entity)
```

**Parameters**

- **`script`**  
  `T`  
  The script to inherit.
- **`entity`** *(optional)*  
  `EntityHandle`  
  Optional entity which will inherit the script. If not used, the entity running the code will inherit.

**Returns**

- **`T`**  
    
Base class, the newly created class.

- **`T`**  
    
Self instance, the entity inheriting `base`.

### entity

Creates a new entity class.

If this is called in an entity attached script then the entity automatically
inherits the class and the class inherits the entity's metatable.

The class is only created once so this can be called in entity attached scripts
multiple times and all subsequent calls will return the already created class.

```lua
entity(name)
```

**Parameters**

- **`name`** *(optional)*  
  `T`  
  Internal class name

**Returns**

- **`any`**  
    
Base class, the newly created class.

- **`T`**  
    
Self instance, the entity inheriting `base`.

- **`table`**  
    
Super class, the first inheritance of `base`.

- **`table`**  
    
Private table

### printinherits

Prints all classes that `ent` inherits.

```lua
printinherits(ent, nest)
```

**Parameters**

- **`ent`**  
  `EntityClass`  
- **`nest`** *(optional)*  
  `string`  

### getvalvemeta

Get the original metatable that Valve assigns to the entity.

```lua
getvalvemeta(ent)
```

**Parameters**

- **`ent`**  
  `EntityClass`  
  The entity search.

**Returns**
- **`table?`**
Metatable originally assigned to `ent`.

### getinherits

Get a list of all classes that `class` inherits.
Does not include the Valve class; use getvalvemeta() for that.

```lua
getinherits(class)
```

**Parameters**

- **`class`**  
  `EntityClass`  
  The entity or class to search.

**Returns**
- **`EntityClass[]`**
List of class tables.

### isinstance

Get if an `EntityClass` instance inherits a given `class`.

```lua
isinstance(ent, class)
```

**Parameters**

- **`ent`**  
  `EntityClass`, `EntityHandle`  
  Entity to check.
- **`class`**  
  `string`, `table`  
  Name or class table to check.

**Returns**
- **`boolean`**
True if `ent` inherits `class`, false otherwise.

### IsClassEntity

Check if an entity is using the AlyxLib class system.

```lua
IsClassEntity(ent)
```

**Parameters**

- **`ent`**  
  `EntityHandle`  
  Entity to check.

**Returns**
- **`boolean`**
True if `ent` is a class entity, false otherwise.

## Types

### EntityClass

> **Inherits from:** `CBaseEntity`, `CEntityInstance`, `CBaseModelEntity`, `CBasePlayer`, `CHL2_Player`, `CBaseAnimating`, `CBaseFlex`, `CBaseCombatCharacter`, `CAI_BaseNPC`, `CBaseTrigger`, `CEnvEntityMaker`, `CInfoWorldLayer`, `CLogicRelay`, `CMarkupVolumeTagged`, `CEnvProjectedTexture`, `CPhysicsProp`, `CSceneEntity`, `CPointClientUIWorldPanel`, `CPointTemplate`, `CPointWorldText`, `CPropHMDAvatar`, `CPropVRHand`

The top-level entity class that provides base functionality.

| Field | Type | Description |
| ---- | ---- | ----------- |
| __inherits | `table` | Table of inherited classes. |
| __name | `string` | Name of the class. |
| __outputs | `table<string,` | function> # Map of output names to functions that will be connected on spawn. |
| __game_events | `table<string,` | function> # Map of game events to functions that will be listened to on spawn. |
| __player_events | `table<string,` | function> # Map of player events to functions that will be listened to on spawn. |
| __rawget | `function` | Custom rawget function to get a value from meta.__values without checking inherits. |
| Initiated | `boolean` | If the class entity has been activated. |
| IsThinking | `boolean` | If the entity is currently thinking with `Think` function. |
| OnActivate | `function` | Called automatically on `Activate` if defined. |
| OnReady | `function` | Called automatically after `Activate`, if defined, when EasyConvars and Player are initialized. |
| OnSpawn | `function` | Called automatically on `Spawn` if defined. |
| UpdateOnRemove | `function` | Called before the entity is killed. |
| OnBreak | `function` | Called when a breakable entity is broken. |
| OnTakeDamage | `function` | Called when entity takes damage. |
| Precache | `function` | Called before Spawn for precaching. |
| Think | `function` | Entity think function. |

## Aliases

### OnReadyType

| Value | Description |
| ----- | ----------- |
| `READY_NORMAL` |  |
| `READY_GAME_LOAD` |  |
| `READY_TRANSITION` |  |
