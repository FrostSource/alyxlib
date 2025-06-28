# Debug Novr

> scripts/vscripts/alyxlib/debug/novr.lua

## Properties

### AutoStartInToolsMode

```lua
NoVR.AutoStartInToolsMode = value
```

**Default value**
  `false`

## Methods

### AddInteraction

Add an interaction class for the NoVR player to interact with.

```lua
NoVR:AddInteraction(title, class, mustBeHeld, input, output)
```

**Parameters**

- **`title`**  
  `string`  
  Text to show in-game on the entity
- **`class`**  
  `string`  
  Class to interact with
- **`mustBeHeld`**  
  `boolean`  
  If the player must hold the use button, to avoid accidental activation
- **`input`** *(optional)*  
  `string`  
  Input to fire
- **`output`** *(optional)*  
  `string`, `string[]`  
  Output(s) to fire, if no input is specified

### EnableAllDebugging

Does the following:

* Enables `buddha` mode
* Gives all weapons and ammo `impulse 101`
* Binds V to noclip toggling
* Enables novr entity interaction

```lua
NoVR:EnableAllDebugging()
```

### DisableAllDebugging

Undoes all operations performed by [NoVR:EnableAllDebugging](lua://NoVR.EnableAllDebugging)

Except removing weapons.

```lua
NoVR:DisableAllDebugging()
```

### UnbindKeys

Unbind all keys bound by [NoVR:BindKey](lua://NoVR.BindKey)

```lua
NoVR:UnbindKeys()
```

### BindKey

Bind a keyboard key to a callback function.

```lua
NoVR:BindKey(key, callback, name)
```

**Parameters**

- **`key`**  
  `KeyboardKey`  
- **`callback`**  
  `fun()`, `string`  
  Callback function or command string
- **`name`** *(optional)*  
  `string`  
  Optional name for the callback command

## Types

### NoVrInteractClass

| Field | Type | Description |
| ---- | ---- | ----------- |
| class | `string` |  |
| hold? | `boolean` |  |
| input? | `string` |  |
| parameter? | `string` | Optional parameter for input. |
| output? | `string|string[]` |  |
| title? | `string` | Text to show in-game. |
| position? | `Vector|string|fun(ent:EntityHandle):Vector` | Offset, attachment name, function that returns world position. |
| weight? | `number` | Weight for this class to assign importance next to others. |
