# Debug Commands

> scripts/vscripts/alyxlib/debug/commands.lua

## Functions

### RegisterAlyxLibCommand

Registers a command for the AlyxLib library.

```lua
RegisterAlyxLibCommand(name, func, helpText, flags)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the command that will be given in the console.
- **`func`**  
  `function`  
  Function to run when the command is called.
- **`helpText`** *(optional)*  
  `string`  
  Description of the command.
- **`flags`** *(optional)*  
  `number`  
  Flags for the command.

### RegisterAlyxLibConvar

Registers a new AlyxLib console variable.

```lua
RegisterAlyxLibConvar(name, defaultValue, helpText, flags, callback)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar that will be given in the console.
- **`defaultValue`**  
  `string`, `function`  
  Default value of the convar or initializer function.
- **`helpText`** *(optional)*  
  `string`  
  Description of the convar.
- **`flags`** *(optional)*  
  `integer`  
  Flags for the convar.
- **`callback`** *(optional)*  
  `function`  
  Update function called after the value has been changed.

### RegisterAlyxLibEasyConvar

Registers a new AlyxLib console variable.

```lua
RegisterAlyxLibEasyConvar(name, defaultValue, helpText, flags, postUpdate, persistent)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the convar that will be given in the console.
- **`defaultValue`**  
  `string`  
  Default value of the convar.
- **`helpText`** *(optional)*  
  `string`  
  Description of the convar.
- **`flags`** *(optional)*  
  `integer`  
  Flags for the convar.
- **`postUpdate`** *(optional)*  
  `function`  
  Update function called after the value has been changed.
- **`persistent`** *(optional)*  
  `boolean`  
  Whether the convar should be persistent.
