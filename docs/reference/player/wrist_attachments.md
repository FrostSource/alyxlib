# Player Wrist_attachments

> scripts/vscripts/alyxlib/player/wrist_attachments.lua

## Global variables

| Name | Value |
| -------------------- | ----- |
| `WristAttachments` | `{}` |

## Methods

### Add

Add a new entity as a wrist attachment.

```lua
WristAttachments:Add(entity, hand, length, priority, offset, angles)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity which will become a wrist attachment.
- **`hand`** *(optional)*  
  `WristAttachmentHandType`  
  The hand type to attach to initially.
- **`length`**  
  `number`  
  Physical length of the entity to make sure it will not overlap with other wrist attachments.
- **`priority`**  
  `number?`  
  Priority for the entity when there are other wrist attacments. Lower number is higher priority. Cannot specify a value lower than 0.
- **`offset`**  
  `Vector?`  
  Optional offset for the entity (x component is ignored).
- **`angles`**  
  `QAngle?`  
  Optional angles for the entity.

### SetHand

Set the hand that the entity should be attached to.

```lua
WristAttachments:SetHand(entity, hand, offset, angles)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity to change data for.
- **`hand`**  
  `WristAttachmentHandType`  
  The type of hand to attach to.
- **`offset`**  
  `Vector`  
  Optional offset for the entity (x component is ignored).
- **`angles`**  
  `QAngle`  
  Optional angles for the entity.

### GetHand

Get the hand that the entity is attached to.

```lua
WristAttachments:GetHand(entity)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  

**Returns**
- **`CPropVRHand?`**

### GetEntityAttachment

Get the attachment data related to an attach entity.

```lua
WristAttachments:GetEntityAttachment(entity)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity to get the data for.

**Returns**
- **`WristAttachmentData?`**
  The attachment data for the entity, if it is attached.

### IsEntityAttached

Get if an entity is attached to a wrist using this system.

```lua
WristAttachments:IsEntityAttached(entity)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity to check.

**Returns**
- **`boolean`**
  True if attached, false otherwise.

### Update

```lua
WristAttachments:Update()
```

## Types

### WristAttachmentData

| Field | Type | Description |
| ---- | ---- | ----------- |
| entity | `EntityHandle` |  |
| hand | `WristAttachmentHandType` |  |
| length | `number` |  |
| priority | `number` |  |
| offset | `Vector` |  |
| angles | `QAngle` |  |

## Aliases

### WristAttachmentHandType

| Value | Description |
| ----- | ----------- |
| `"left"` |  |
| `"right"` |  |
| `"primary"` |  |
| `"secondary"` |  |
