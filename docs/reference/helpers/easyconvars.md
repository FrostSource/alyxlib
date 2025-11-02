# Helpers Easyconvars

> scripts/vscripts/alyxlib/helpers/easyconvars.lua

## Global variables

| EASYCONVARS |  |
| -------------------- | ----- |
| `EASYCONVARS_CONVAR` | `"convar"` |
| `EASYCONVARS_COMMAND` | `"command"` |
| `EASYCONVARS_TOGGLE` | `"toggle"` |

## Properties

### version

```lua
EasyConvars.version = value
```

**Default value**
  `"v2.0.0"`

### registered

```lua
EasyConvars.registered = value
```

**Default value**
  `table`

## Methods

### Register

Creates a convar of any type.

For simple creation use one of the following:

 - [EasyConvars:RegisterConvar](lua://EasyConvars.RegisterConvar)

 - [EasyConvars:RegisterToggle](lua://EasyConvars.RegisterToggle)

 - [EasyConvars:RegisterCommand](lua://EasyConvars.RegisterCommand)

```lua
EasyConvars:Register(ctype, name, defaultValue, onUpdate, helpText, flags)
```

**Parameters**

- **`ctype`**  
  `EasyConvarsType`  
  Type of the convar.
- **`name`**  
  `string`  
  Name of the convar
- **`defaultValue`**  
  `any`, `function`  
  Will be converted to a string. If given a function, the value will be determined on player spawn.
- **`onUpdate`** *(optional)*  
  `(function`  
  Optional callback function.
- **`helpText`** *(optional)*  
  `string`  
  Description of the convar
- **`flags`** *(optional)*  
  `CVarFlags`, `integer`  
  Flag for the convar

**Returns**
- **`EasyConvarsRegisteredData`**
The new registered cvar data

### Warn

Prints a warning to the console except during internal handling.

```lua
EasyConvars:Warn(msg)
```

**Parameters**

- **`msg`**  
  `any`  
  Warning to print

### Msg

Prints a message to the console except during internal handling.

```lua
EasyConvars:Msg(msg)
```

**Parameters**

- **`msg`**  
  `any`  
  Message to print

### Save

Manually saves the current value of the convar with a given name.

This is done automatically when the value is changed if SetPersistent is set to true.

```lua
EasyConvars:Save(name)
```

**Parameters**

- **`name`**  
  `string`  
  The name of the convar to save.

### Load

Manually loads the saved value of the convar with a given name.

This is done automatically when the player spawns for any previously saved convar.

```lua
EasyConvars:Load(name)
```

**Parameters**

- **`name`**  
  `string`  
  The name of the convar to load.

**Returns**
- **`boolean`**
Returns true if the convar was loaded successfully.

### SetPersistent

Sets the convar as persistent.

It will be saved to the player when changed and load its previous state when the player spawns.

```lua
EasyConvars:SetPersistent(name, persistent)
```

**Parameters**

- **`name`**  
  `string`  
  The name of the convar.
- **`persistent`**  
  `boolean`  
  Whether the convar should be persistent.

### RegisterConvar

Registers a new convar.

```lua
EasyConvars:RegisterConvar(name, defaultValue, helpText, flags, postUpdate)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar
- **`defaultValue`** *(optional)*  
  `"0"`, `any`, `function`  
  Default value of the convar, or an initializer function
- **`helpText`** *(optional)*  
  `string`  
  Description of the convar
- **`flags`** *(optional)*  
  `CVarFlags`, `integer`  
  Flags for the convar
- **`postUpdate`** *(optional)*  
  `function`  
  Update function called after the value has been changed

### RegisterCommand

Registers a new command.

```lua
EasyConvars:RegisterCommand(name, callback, helpText, flags)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the command
- **`callback`**  
  `function`  
  Callback function
- **`helpText`** *(optional)*  
  `string`  
  Description of the command
- **`flags`** *(optional)*  
  `CVarFlags`, `integer`  
  Flags for the command

### RegisterToggle

Registers a new toggle convar.

This is a command that has an on/off state like `god` or `notarget`.

```lua
EasyConvars:RegisterToggle(name, defaultValue, helpText, flags, postUpdate, displayFunc)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar
- **`defaultValue`** *(optional)*  
  `"0"`, `any`, `function`  
  Default value of the convar
- **`helpText`** *(optional)*  
  `string`  
  Description of the convar
- **`flags`** *(optional)*  
  `nil`, `CVarFlags`, `integer`  
  Flags for the convar
- **`postUpdate`** *(optional)*  
  `function`  
  Update function called after the value has been changed
- **`displayFunc`** *(optional)*  
  `function`  
  Optional custom display function

### GetConvarData

Gets the [EasyConvarsRegisteredData](lua://EasyConvarsRegisteredData) table for a given cvar name.

```lua
EasyConvars:GetConvarData(name)
```

**Parameters**

- **`name`**  
  `string`  
  The name of the registered EasyConvar to get the data for

**Returns**
- **`EasyConvarsRegisteredData?`**
The data associated with `name`

### Exists

Checks if an easy convar exists.

```lua
EasyConvars:Exists(name)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar

**Returns**
- **`boolean`**
Returns true if the convar exists

### GetStr

Returns the convar as a string.

```lua
EasyConvars:GetStr(name)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar

**Returns**
- **`string?`**
The value of the convar as a string or nil if convar does not exist

### GetBool

Returns the convar as a boolean.

```lua
EasyConvars:GetBool(name)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar

**Returns**
- **`boolean?`**
The value of the convar as a boolean or nil if convar does not exist

### GetFloat

Returns the convar as a float.

```lua
EasyConvars:GetFloat(name)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar

**Returns**
- **`number?`**
The value of the convar as a number or nil if convar does not exist

### GetInt

Returns the convar as an integer.

```lua
EasyConvars:GetInt(name)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar

**Returns**
- **`integer?`**
The value of the convar as a truncated number or nil if convar does not exist

### SetStr

Sets the value of the convar to a string and calls the update.

```lua
EasyConvars:SetStr(name, value)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar
- **`value`**  
  `string`  
  The value to set

### SetBool

Sets the value of the convar to a boolean and calls the update.

```lua
EasyConvars:SetBool(name, value)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar
- **`value`**  
  `boolean`  
  The value to set

### SetFloat

Sets the value of the convar to a float and calls the update.

```lua
EasyConvars:SetFloat(name, value)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar
- **`value`**  
  `number`  
  The value to set

### SetInt

Sets the value of the convar to an integer and calls the update.

```lua
EasyConvars:SetInt(name, value)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar
- **`value`**  
  `integer`  
  The value to set

### SetRaw

Sets the raw value of the convar without calling the update.

```lua
EasyConvars:SetRaw(name, value)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar
- **`value`**  
  `any`  
  The value to set

### WasChangedByUser

Get if the convar was changed by the user in the console.

```lua
EasyConvars:WasChangedByUser(name)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar

### SetWasChanged

Forces the convar to be considered changed by the user.

This can be useful if you want to stop a convar from initializing because you're setting its value early.
Or if you're setting the value by some unusual means for the user.

```lua
EasyConvars:SetWasChanged(name, wasChanged)
```

**Parameters**

- **`name`**  
  `string`  
- **`wasChanged`**  
  `boolean`  

### SetIfUnchanged

Sets the value of the convar if it hasn't been changed by the user.

```lua
EasyConvars:SetIfUnchanged(name, value)
```

**Parameters**

- **`name`**  
  `string`  
- **`value`**  
  `any`  
  The value to set. Will be converted to a string representation.

### SetPostInitializer

Sets the function to be called after all convars have been initialized.

```lua
EasyConvars:SetPostInitializer(func)
```

**Parameters**

- **`func`**  
  `function`  

## Types

### EasyConvarsRegisteredData

Data of a registered convar.

| Field | Type | Description |
| ---- | ---- | ----------- |
| type | `EasyConvarsType` | Type of the convar. |
| name | `string` | Name of the convar |
| desc? | `string` | Description of the convar/command. Is displayed below the current value when called without a parameter. |
| value | `string` | Raw value of the convar. |
| prevValue | `string` | Previous raw value of the convar. |
| callback? | `function` | Optional callback function whenever the convar is changed. |
| initializer? | `function` | Optional initializer function which will set the default value on player spawn. |
| persistent | `boolean` | If the value is saved to player on change. |
| wasChangedByUser | `boolean` | Whether the value was changed by the user. |
| displayFunc? | `function` | The function called when the convar is called without any parameters. By default it just prints the value. |
| defaultValue? | `string` | The default value of the convar given by the registration. Not the value set in cfg or launch options. |

## Aliases

### EasyConvarsType

Types of convars.

| Value | Description |
| ----- | ----------- |
| `EASYCONVARS_CONVAR` |  |
| `EASYCONVARS_COMMAND` |  |
| `EASYCONVARS_TOGGLE` |  |
