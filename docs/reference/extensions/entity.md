# Extensions Entity

> scripts/vscripts/alyxlib/extensions/entity.lua

## Methods

### GetChildrenMemSafe

Get the entities parented to this entity. Including children of children.

This is a memory safe version of GetChildren() which causes a memory leak when called.
If you need to get children often you should use this function instead.

```lua
CBaseEntity:GetChildrenMemSafe()
```

**Returns**
- **`EntityHandle[]`**

### GetTopChildren

Get the top level entities parented to this entity. Not children of children.

This function is memory safe.

```lua
CBaseEntity:GetTopChildren()
```

**Returns**
- **`EntityHandle[]`**

### EntFire

Send an input to this entity.

```lua
CBaseEntity:EntFire(action, value, delay, activator, caller)
```

**Parameters**

- **`action`**  
  `string`  
  Input name.
- **`value`** *(optional)*  
  `any`  
  Parameter override for the input.
- **`delay`** *(optional)*  
  `number`  
  Delay in seconds.
- **`activator`** *(optional)*  
  `EntityHandle`  
- **`caller`** *(optional)*  
  `EntityHandle`  

### GetFirstChildWithClassname

Get the first child in this entity's hierarchy with a given classname.

This function is memory safe.

```lua
CBaseEntity:GetFirstChildWithClassname(classname)
```

**Parameters**

- **`classname`**  
  `string`  
  Classname to find.

**Returns**
- **`EntityHandle|nil`**
  The child found.

### GetFirstChildWithName

Get the first child in this entity's hierarchy with a given target name.

```lua
CBaseEntity:GetFirstChildWithName(name)
```

**Parameters**

- **`name`**  
  `string`  
  Targetname to find.

**Returns**
- **`EntityHandle|nil`**
  The child found.

### SetQAngle

Set entity pitch, yaw, roll from a `QAngle`.

```lua
CBaseEntity:SetQAngle(qangle)
```

**Parameters**

- **`qangle`**  
  `QAngle`  

### SetAngle

Set entity pitch, yaw or roll. Supply `nil` for any parameter to leave it unchanged.

```lua
CBaseEntity:SetAngle(pitch, yaw, roll)
```

**Parameters**

- **`pitch`**  
  `number`, `nil`  
- **`yaw`**  
  `number`, `nil`  
- **`roll`**  
  `number`, `nil`  

### ResetLocal

Resets local origin and angle to [0,0,0]

```lua
CBaseEntity:ResetLocal()
```

### GetSize

Get the bounding size of the entity.

```lua
CBaseEntity:GetSize()
```

**Returns**
- **`Vector`**

### GetBiggestBounding

Get the biggest bounding box axis of the entity.
This will be `size.x`, `size.y` or `size.z`.

```lua
CBaseEntity:GetBiggestBounding()
```

**Returns**
- **`number`**

### GetRadius

Get the radius of the entity bounding box. This is half the size of the sphere.

```lua
CBaseEntity:GetRadius()
```

**Returns**
- **`number`**

### GetVolume

Get the volume of the entity bounds in inches cubed.

```lua
CBaseEntity:GetVolume()
```

**Returns**
- **`number`**

### GetBoundingCorners

Get each corner of the entity's bounding box.

```lua
CBaseEntity:GetBoundingCorners(rotated)
```

**Parameters**

- **`rotated`** *(optional)*  
  `boolean`  
  If the corners should be rotated with the entity angle.

**Returns**
- **`Vector[]`**

### IsWithinBounds

Check if entity is within the given worldspace bounds.

```lua
CBaseEntity:IsWithinBounds(mins, maxs, checkEntityBounds)
```

**Parameters**

- **`mins`**  
  `Vector`  
  Worldspace minimum vector for the bounds.
- **`maxs`**  
  `Vector`  
  Worldspace minimum vector for the bounds.
- **`checkEntityBounds`** *(optional)*  
  `boolean`  
  If true the entity bounding box will be used for the check instead of its origin.

**Returns**
- **`boolean`**
  True if the entity is within the bounds, false otherwise.

### DisablePickup

Send the `DisablePickup` input to the entity.

```lua
CBaseEntity:DisablePickup()
```

### EnablePickup

Send the `EnablePickup` input to the entity.

```lua
CBaseEntity:EnablePickup()
```

### Delay

Delay some code using this entity.

```lua
CBaseEntity:Delay(func, delay)
```

**Parameters**

- **`func`**  
  `fun()`  
- **`delay`**  
  `number?`  

### GetParents

Get all parents in the hierarchy upwards.

```lua
CBaseEntity:GetParents()
```

**Returns**
- **`EntityHandle[]`**

### DoNotDrop

Set if the prop is allowed to be dropped. Only works for physics based props.

```lua
CBaseEntity:DoNotDrop(enabled)
```

**Parameters**

- **`enabled`**  
  `boolean`  
  True if the prop can't be dropped, false for can be dropped.

### GetCriteria

Get all criteria as a table.

```lua
CBaseEntity:GetCriteria()
```

**Returns**
- **`CriteriaTable`**

### GetOwnedEntities

Get all entities which are owned by this entity

**Note:** This searches all entities in the map and should be used sparingly.

```lua
CBaseEntity:GetOwnedEntities()
```

**Returns**
- **`EntityHandle[]`**

### SetCenter

Center the entity at a new position.

```lua
CBaseEntity:SetCenter(position)
```

**Parameters**

- **`position`**  
  `Vector`  

### TrackProperty

Track a property function using a callback when a change is detected.

-- Make entity fully opaque if alpha is ever detected below 255
thisEntity:TrackProperty(thisEntity.GetRenderAlpha, function(prevValue, newValue)
if newValue < 255 then
thisEntity:SetRenderAlpha(255)
end
end)

```lua
CBaseEntity:TrackProperty(propertyFunction, onChangeFunction, interval, context)
```

**Parameters**

- **`propertyFunction`**  
  `fun(handle:`  
  EntityHandle): any # Property function to track, e.g. GetRenderAlpha.
- **`onChangeFunction`**  
  `fun(prevValue:`  
  any, newValue: any) # Function to call when a change is detected.
- **`interval`** *(optional)*  
  `number`  
  Think interval, or smallest possible if nil.
- **`context`** *(optional)*  
  `EntityHandle`  
  Entity to run the thinker on, or this entity if nil.

### UntrackProperty

Untrack a property function which was set to be tracked using `CBaseEntity:TrackProperty`.

```lua
CBaseEntity:UntrackProperty(propertyFunction)
```

**Parameters**

- **`propertyFunction`**  
  `fun(handle:`  
  EntityHandle): any # Property function to untrack, e.g. GetRenderAlpha.

### QuickThink

Quickly start a think function on the entity with a random name and no delay.

```lua
CBaseEntity:QuickThink(func)
```

**Parameters**

- **`func`**  
  `fun(...):number?`  
  The think function.

**Returns**
- **`string`**
  The name of the think for stopping later if desired.

### SetRenderingEnabled

Sets whether the entity is rendered or not.

```lua
CBaseEntity:SetRenderingEnabled(renderingEnabled)
```

**Parameters**

- **`renderingEnabled`**  
  `boolean`  
  If false the entity will become invisible.

### SetCastShadow

Sets whether the entity casts a shadow or not.

```lua
CBaseEntity:SetCastShadow(shadowEnabled)
```

**Parameters**

- **`shadowEnabled`**  
  `boolean`  
  If false the entity will not cast a dynamic shadow.

### DistanceFromEyes

Gets the position in front of the entity's eyes at the specified position.

```lua
CBaseEntity:DistanceFromEyes(distance)
```

**Parameters**

- **`distance`**  
  `number`  

**Returns**
- **`Vector`**
