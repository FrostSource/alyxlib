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

### IterateChildren

Returns a `function` that iterates over all children of this entity.
The `function` returns the next child every time it is called until no more children exist,
in which case `nil` is returned.

Useful in `for` loops:

??? example
    ```lua
    for child in thisEntity:IterateChildren() do
        print(Debug.EntStr(child))
    end
    ```

This function is memory safe.

```lua
CBaseEntity:IterateChildren()
```

**Returns**
- **`function`**
The new iterator function

### IterateChildrenBreadthFirst

Returns a `function` that iterates over all children of this entity in **breadth-first order**.
The `function` returns the next child every time it is called until no more children exist,
in which case `nil` is returned.

Useful in `for` loops:

??? example
    ```lua
    for child in thisEntity:IterateChildrenBreadthFirst() do
        print(Debug.EntStr(child))
    end
    ```

Unlike [IterateChildren](lua://CBaseEntity.IterateChildren), this visits all immediate children first,
then their children, and so on.

This function is memory safe.

```lua
CBaseEntity:IterateChildrenBreadthFirst()
```

**Returns**
- **`function`**
The new iterator function

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

Get the first child in this entity's hierarchy with a given `classname`.
Searches using **breadth-first traversal**, so it finds the closest matching child first.

This function is memory safe.

```lua
CBaseEntity:GetFirstChildWithClassname(classname)
```

**Parameters**

- **`classname`**  
  `string`  
  Classname to search for.

**Returns**
- **`EntityHandle?`**
The first matching child found, or `nil` if none exists.

### GetFirstChildWithName

Get the first child in this entity's hierarchy with a given `name`.
Searches using **breadth-first traversal**, so it finds the closest matching child first.

This function is memory safe.

```lua
CBaseEntity:GetFirstChildWithName(name)
```

**Parameters**

- **`name`**  
  `string`  
  Targetname to search for.

**Returns**
- **`EntityHandle?`**
The first matching child found, or `nil` if none exists.

### SetQAngle

Set entity pitch, yaw, roll from a `QAngle`.

```lua
CBaseEntity:SetQAngle(qangle)
```

**Parameters**

- **`qangle`**  
  `QAngle`  
  The rotation to set (pitch, yaw, roll).

### SetLocalQAngle

Set entity local pitch, yaw, roll from a `QAngle`.

```lua
CBaseEntity:SetLocalQAngle(qangle)
```

**Parameters**

- **`qangle`**  
  `QAngle`  
  The rotation to set (pitch, yaw, roll).

### SetAngle

Set entity pitch, yaw or roll. Supply `nil` for any parameter to leave it unchanged.

```lua
CBaseEntity:SetAngle(pitch, yaw, roll)
```

**Parameters**

- **`pitch`** *(optional)*  
  `number`  
  Pitch angle, or nil to leave unchanged.
- **`yaw`** *(optional)*  
  `number`  
  Pitch angle, or nil to leave unchanged.
- **`roll`** *(optional)*  
  `number`  
  Pitch angle, or nil to leave unchanged.

### ResetLocal

Resets local origin and angle to [0,0,0].

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
Bounding size of the entity as a Vector.

### GetBiggestBounding

Get the biggest bounding box axis of the entity.
This will be `size.x`, `size.y` or `size.z`.

```lua
CBaseEntity:GetBiggestBounding()
```

**Returns**
- **`number`**
The largest bounding value.

### GetRadius

Get the radius of the entity's bounding box.
This is half the size of the bounding box along its largest axis.

```lua
CBaseEntity:GetRadius()
```

**Returns**
- **`number`**
The bounding radius value.

### GetVolume

Get the volume of the entity bounds in cubic inches.

```lua
CBaseEntity:GetVolume()
```

**Returns**
- **`number`**
The volume of the entity bounds.

### GetBoundingCorners

Get each corner of the entity's bounding box.

```lua
CBaseEntity:GetBoundingCorners(rotated)
```

**Parameters**

- **`rotated`** *(optional)*  
  `boolean`  
  If true, corners are rotated by the entity's angles.

**Returns**
- **`Vector[]`**
List of 8 corner positions.

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
  `function`  
  The function to delay.
- **`delay`** *(optional)*  
  `number`  
  Optional delay in seconds (default 0).

### GetParents

Get all parents in the hierarchy upwards.

```lua
CBaseEntity:GetParents()
```

**Returns**
- **`EntityHandle[]`**
List of parent entities, from immediate parent up to the root.

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

Get all criteria on this entity as a table.

```lua
CBaseEntity:GetCriteria()
```

**Returns**
- **`CriteriaTable`**
A table of criteria key-value pairs.

### GetOwnedEntities

Get all entities owned by this entity.

**Note:** This searches all entities in the map and should be used sparingly.

```lua
CBaseEntity:GetOwnedEntities()
```

**Returns**
- **`EntityHandle[]`**
List of owned entities.

### SetRenderAlphaAll

Set the alpha modulation of this entity, plus any children that support [SetRenderAlpha](lua://CBaseModelEntity.SetRenderAlpha).

```lua
CBaseModelEntity:SetRenderAlphaAll(alpha)
```

**Parameters**

- **`alpha`**  
  `integer`  
  Alpha value (0 = fully transparent, 255 = fully opaque).

### SetCenter

Moves the entity so that its center is at the given position.

```lua
CBaseEntity:SetCenter(position)
```

**Parameters**

- **`position`**  
  `Vector`  
  The new center position.

### SetOriginByAttachment

Set the entity's origin so that the specified attachment point aligns with the given world position.

```lua
CBaseAnimating:SetOriginByAttachment(position, attachment)
```

**Parameters**

- **`position`**  
  `Vector`  
  The target world position for the attachment point.
- **`attachment`**  
  `string`  
  The name of the attachment point to align.

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
  `function`  
  Property function to track, e.g. GetRenderAlpha.
- **`onChangeFunction`**  
  `function`  
  Function to call when a change is detected.
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
  `function`  
  Property function to untrack, e.g. GetRenderAlpha.

### QuickThink

Quickly start a think function on the entity with a random name and no delay.

```lua
CBaseEntity:QuickThink(func, delay)
```

**Parameters**

- **`func`**  
  `function`  
  The think function.
- **`delay`** *(optional)*  
  `number`  
  Delay before starting the think.

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

Gets the position in front of the entity’s eyes at the specified distance.

```lua
CBaseEntity:DistanceFromEyes(distance)
```

**Parameters**

- **`distance`**  
  `number`  
  How far in front of the eyes to get the position.

**Returns**
- **`Vector`**
The world position in front of the eyes.

### GetAttachmentNameOrigin

Gets the world origin position of a named attachment point.

```lua
CBaseAnimating:GetAttachmentNameOrigin(name)
```

**Parameters**

- **`name`**  
  `string`  
  The name of the attachment.

**Returns**
- **`Vector`**
The world position of the attachment.

### GetAttachmentNameAngles

Gets the world angles (rotation) of a named attachment point.

```lua
CBaseAnimating:GetAttachmentNameAngles(name)
```

**Parameters**

- **`name`**  
  `string`  
  The name of the attachment.

**Returns**
- **`Vector`**
The world rotation angles of the attachment.

### GetAttachmentNameForward

Gets the forward direction vector of a named attachment.

```lua
CBaseAnimating:GetAttachmentNameForward(name)
```

**Parameters**

- **`name`**  
  `string`  
  The name of the attachment.

**Returns**
- **`Vector`**
The forward unit vector of the attachment in world space.

### ClearParent

Unparents this entity if it is parented.

```lua
CBaseEntity:ClearParent()
```

### SetAbsVelocity

Sets the absolute world velocity of the entity.

```lua
CBaseEntity:SetAbsVelocity(velocity)
```

**Parameters**

- **`velocity`**  
  `Vector`  
  The target velocity in units/second.

### OBBvsOBB

Tests if the OBB of this entity intersects with the OBB of another entity.

```lua
CBaseEntity:OBBvsOBB(other)
```

**Parameters**

- **`other`**  
  `EntityHandle`  
  The other entity.

**Returns**
- **`boolean`**
True if the OBB of this entity intersects with the OBB of another entity.

### AABBvsOBB

Tests if the AABB of this entity intersects with the OBB of another entity.

The AABB is defined by the entity's bounding mins/maxs and its current origin/angles.

```lua
CBaseEntity:AABBvsOBB(other)
```

**Parameters**

- **`other`**  
  `EntityHandle`  
  The other entity.

**Returns**
- **`boolean`**
True if the AABB of this entity intersects with the OBB of another entity.

### AABBvsAABB

Tests if the AABB of this entity intersects with the AABB of another entity.

The AABB is defined by the entity's bounding mins/maxs and its current origin/angles.

```lua
CBaseEntity:AABBvsAABB(other)
```

**Parameters**

- **`other`**  
  `EntityHandle`  
  The other entity.

**Returns**
- **`boolean`**
True if the AABB of this entity intersects with the AABB of another entity.
