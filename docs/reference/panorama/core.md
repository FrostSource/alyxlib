# Panorama Core

> scripts/vscripts/alyxlib/panorama/core.lua

## Global variables

| Name | Value |
| -------------------- | ----- |
| `Panorama` | `table` |

## Methods

### InitPanel

Initializes a panorama panel with a unique id.
This must be done every time the entity loads, even on save game loads.

The entity can be initialized if it accepts the input "AddCSSClass".

```lua
Panorama:InitPanel(panelEntity, customId)
```

**Parameters**

- **`panelEntity`**  
  `EntityHandle`  
  The entity to initialize
- **`customId`** *(optional)*  
  `string`  
  The custom id to use, otherwise a unique id will be generated

### Send

Sends data to a panorama panel.

```lua
Panorama:Send(panelEntity)
```

**Parameters**

- **`panelEntity`**  
  `EntityHandle`  
  The entity to send data to

### ToJSON

Converts any value to a JSON string.

```lua
Panorama:ToJSON(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to convert

**Returns**
- **`string`**
The JSON string

### GetId

Gets the panorama id from an entity if it has one.

```lua
Panorama:GetId(entityPanel)
```

**Parameters**

- **`entityPanel`**  
  `EntityHandle`  
  The entity to get the id from

**Returns**
- **`string?`**
The panorama id
