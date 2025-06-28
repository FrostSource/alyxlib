# Precache

> scripts/vscripts/alyxlib/precache.lua

## Functions

### GlobalPrecache

Add an asset to be precached when the player spawns.

```lua
GlobalPrecache(type, path, spawnkeys)
```

**Parameters**

- **`type`**  
  `AlyxLibGlobalPrecacheType`  
  The type of asset to precache.
- **`path`**  
  `string`  
  The asset path to precache (or the classname if type is entity).
- **`spawnkeys`**  
  `table?`  
  The spawnkeys table if type is entity.

### _PrecacheGlobalItems

Internal function used to start the precache process.

**This should only be called manually if you know what you're doing!**

```lua
_PrecacheGlobalItems(context)
```

**Parameters**

- **`context`**  
  `CScriptPrecacheContext`  

## Types

### A

| Field | Type | Description |
| ---- | ---- | ----------- |
| type | `AlyxLibGlobalPrecacheType` | The type of asset to precache. |
| path | `string` | The asset path to precache (or the classname if type is entity). |
| spawnkeys | `table?` | The spawnkeys table if type is entity. |

## Aliases

### AlyxLibGlobalPrecacheType

| Value | Description |
| ----- | ----------- |
| `"model_folder"` |  |
| `"sound"` |  |
| `"soundfile"` |  |
| `"particle"` |  |
| `"particle_folder"` |  |
| `"model"` |  |
| `"entity"` |  |
