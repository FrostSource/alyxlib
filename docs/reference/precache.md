# Precache

> scripts/vscripts/alyxlib/precache.lua

## Methods

### Add

Adds an asset to be precached when the player activates.

If you are precaching *after* the player has activated,
then you must also call [GlobalPrecache:Flush](lua://GlobalPrecache.Flush)
after adding assets to be precached.

```lua
GlobalPrecache:Add(type, path, spawnkeys)
```

**Parameters**

- **`type`**  
  `AlyxLibGlobalPrecacheType`  
  The type of asset to precache
- **`path`**  
  `string`  
  The asset path to precache (or the classname if `type` is an entity)
- **`spawnkeys`**  
  `table?`  
  The spawnkeys table if type is entity

### IsPending

Returns whether assets are waiting to be precached.

```lua
GlobalPrecache:IsPending()
```

### OnFinished

Arrange to call the provided functions once all assets are precached.
If none are currently pending, call immediately. Otherwise, store the callback
to be called once [GlobalPrecache:Flush()](lua://GlobalPrecache.Flush) is finished.

```lua
GlobalPrecache:OnFinished(callback)
```

**Parameters**

- **`callback`**  
  `function`  
  The function to call when the precaching is complete

### Flush

Flushes the global precache list and precaches the assets.

This function must be called following any calls to [GlobalPrecache:Add()](lua://GlobalPrecache.Add)
if you are precaching *after* the player has activated.

This is an asynchronous process; the assets will not be immediately available after calling this function.

```lua
GlobalPrecache:Flush(callback)
```

**Parameters**

- **`callback`** *(optional)*  
  `function`  
  The function to call when the precaching is complete

### _PrecacheGlobalItems

Internal function used to start the precache process.

**This should only be called manually if you know what you're doing!**

```lua
GlobalPrecache:_PrecacheGlobalItems(context)
```

**Parameters**

- **`context`**  
  `CScriptPrecacheContext`  

## Types

### A

An asset to be globally precached.

| Field | Type | Description |
| ---- | ---- | ----------- |
| type | `AlyxLibGlobalPrecacheType` | The type of asset to precache |
| path | `string` | The asset path to precache (or the classname if type is entity) |
| spawnkeys | `table?` | The spawnkeys table if type is entity |

### G

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
