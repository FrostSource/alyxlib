# Precache

> scripts/vscripts/alyxlib/precache.lua

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
