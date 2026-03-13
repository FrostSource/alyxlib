# Player Wrist_attachments

> scripts/vscripts/alyxlib/player/wrist_attachments.lua

## Global variables

| Name | Value |
| -------------------- | ----- |
| `WristAttachments` | `table` |

## Methods

### Add

Adds a new entity as a wrist attachment.

```lua
WristAttachments:Add(entity, hand, length, priority, offset, angles)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity which will become a wrist attachment
- **`hand`** *(optional)*  
  `WristAttachmentHandType`  
  The hand type to attach to initially
- **`length`**  
  `number`  
  Physical length of the entity to make sure it will not overlap with other wrist attachments
- **`priority`**  
  `number?`  
  Priority for the entity when there are other wrist attacments - lower number is higher priority, cannot specify a value lower than 0
- **`offset`**  
  `Vector?`  
  Optional origin offset for the entity (x component is ignored)
- **`angles`**  
  `QAngle?`  
  Optional angles offset for the entity

### SetHand

Sets the hand that the entity should be attached to.

```lua
WristAttachments:SetHand(entity, hand, offset, angles)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity to change data for
- **`hand`**  
  `WristAttachmentHandType`  
  The type of hand to attach to
- **`offset`** *(optional)*  
  `Vector`  
  Optional origin offset for the entity (x component is ignored)
- **`angles`** *(optional)*  
  `QAngle`  
  Optional angles offset for the entity

### GetHand

Gets the hand that the entity is attached to.

```lua
WristAttachments:GetHand(entity)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity to get the hand for

**Returns**
- **`CPropVRHand?`**
The hand that the entity is attached to

### GetEntityAttachment

Gets the attachment data related to an attach entity.

```lua
WristAttachments:GetEntityAttachment(entity)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity to get the data for

**Returns**
- **`WristAttachmentData?`**
The attachment data for the entity, or `nil` if not found

### IsEntityAttached

Checks if an entity is attached to a wrist using this system.

```lua
WristAttachments:IsEntityAttached(entity)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity to check

**Returns**
- **`boolean`**
`true` if attached, `false` otherwise.

### Update

Updates the attachments.

This is called automatically when an attachment is added or removed
or when the player's primary hand changes.

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
