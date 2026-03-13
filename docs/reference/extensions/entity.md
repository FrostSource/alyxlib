# Extensions Entity

> scripts/vscripts/alyxlib/extensions/entity.lua

## Methods

### GetChildrenMemSafe

Gets the entities parented to this entity. Including children of children.

This is a memory safe version of [GetChildren](lua://CBaseEntity.GetChildren) which causes a memory leak when called.
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
        print(entstr(child))
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
        print(entstr(child))
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

Gets the top level entities parented to this entity. *Not* children of children.

This function is memory safe.

```lua
CBaseEntity:GetTopChildren()
```

**Returns**
- **`EntityHandle[]`**

### EntFire

Sends an input to this entity.

```lua
CBaseEntity:EntFire(action, value, delay, activator, caller)
```

**Parameters**

- **`action`**  
  `string`  
  Input name
- **`value`** *(optional)*  
  `any`  
  Parameter override for the input
- **`delay`** *(optional)*  
  `number`  
  Delay in seconds
- **`activator`** *(optional)*  
  `EntityHandle`  
  IO activator
- **`caller`** *(optional)*  
  `EntityHandle`  
  IO caller

### GetFirstChildWithClassname

Gets the first child in this entity's hierarchy with a given `classname`.
Searches using **breadth-first traversal**, so it finds the closest matching child first.

This function is memory safe.

```lua
CBaseEntity:GetFirstChildWithClassname(classname)
```

**Parameters**

- **`classname`**  
  `string`  
  Classname to search for

**Returns**
- **`EntityHandle?`**
The first matching child found, or `nil` if none exists

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
  Targetname to search for

**Returns**
- **`EntityHandle?`**
The first matching child found, or `nil` if none exists

### SetQAngle

Sets entity pitch, yaw, roll from a `QAngle`.

```lua
CBaseEntity:SetQAngle(qangle)
```

**Parameters**

- **`qangle`**  
  `QAngle`  
  The QAngle rotation to set

### SetLocalQAngle

Sets entity local pitch, yaw, roll from a `QAngle`.

```lua
CBaseEntity:SetLocalQAngle(qangle)
```

**Parameters**

- **`qangle`**  
  `QAngle`  
  The QAngle rotation to set

### SetAngle

Sets entity pitch, yaw or roll. Supply `nil` for any parameter to leave it unchanged.

```lua
CBaseEntity:SetAngle(pitch, yaw, roll)
```

**Parameters**

- **`pitch`** *(optional)*  
  `number`  
  Pitch angle
- **`yaw`** *(optional)*  
  `number`  
  Yaw angle
- **`roll`** *(optional)*  
  `number`  
  Roll angle

### ResetLocal

Resets local origin and angles to (0, 0, 0).

```lua
CBaseEntity:ResetLocal()
```

### GetSize

Gets the bounding size of the entity.

```lua
CBaseEntity:GetSize()
```

**Returns**
- **`Vector`**
Bounding size of the entity as a Vector

### GetBiggestBounding

Gets the biggest bounding box axis of the entity.
This will be either `size.x`, `size.y` or `size.z`.

```lua
CBaseEntity:GetBiggestBounding()
```

**Returns**
- **`number`**
The largest bounding value

### GetRadius

Gets the radius of the entity's bounding box.
This is half the size of the bounding box along its largest axis.

```lua
CBaseEntity:GetRadius()
```

**Returns**
- **`number`**
The bounding radius value

### GetVolume

Gets the volume of the entity bounds in cubic inches.

```lua
CBaseEntity:GetVolume()
```

**Returns**
- **`number`**
The volume of the entity bounds

### GetBoundingCorners

Gets each corner of the entity's bounding box.

```lua
CBaseEntity:GetBoundingCorners(rotated)
```

**Parameters**

- **`rotated`** *(optional)*  
  `boolean`  
  If `true`, corners are rotated by the entity's angles

**Returns**
- **`Vector[]`**
List of 8 corner positions

### IsWithinBounds

Checks if entity is within the given worldspace bounds.

```lua
CBaseEntity:IsWithinBounds(mins, maxs, checkEntityBounds)
```

**Parameters**

- **`mins`**  
  `Vector`  
  Worldspace minimum vector for the bounds
- **`maxs`**  
  `Vector`  
  Worldspace maximum vector for the bounds
- **`checkEntityBounds`** *(optional)*  
  `boolean`  
  If `true` the entity bounding box will be used for the check instead of its origin

**Returns**
- **`boolean`**
`true` if the entity is within the bounds, `false` otherwise.

### DisablePickup

Sends the `DisablePickup` input to the entity.

```lua
CBaseEntity:DisablePickup()
```

### EnablePickup

Sends the `EnablePickup` input to the entity.

```lua
CBaseEntity:EnablePickup()
```

### Delay

Delays some code, using this entity as the context.

```lua
CBaseEntity:Delay(func, delay)
```

**Parameters**

- **`func`**  
  `function`  
  The function to delay
- **`delay`** *(optional)*  
  `number`  
  Delay in seconds (default 0)

### GetParents

Gets all parents in the hierarchy upwards, from immediate parent up to the root.

```lua
CBaseEntity:GetParents()
```

**Returns**
- **`EntityHandle[]`**
List of parent entities

### DoNotDrop

Sets if the prop is not allowed to be dropped. Only works for physics based props.

```lua
CBaseEntity:DoNotDrop(enabled)
```

**Parameters**

- **`enabled`**  
  `boolean`  
  `true` if the prop is not allowed to be dropped

### GetCriteria

Gets all criteria for this entity as a table.

```lua
CBaseEntity:GetCriteria()
```

**Returns**
- **`CriteriaTable`**
Criteria key-value pairs

### GetOwnedEntities

Gets all entities owned by this entity.

**Note:** This searches all entities in the map and should be used sparingly.

```lua
CBaseEntity:GetOwnedEntities()
```

**Returns**
- **`EntityHandle[]`**
List of owned entities

### SetRenderAlphaAll

Sets the alpha modulation of this entity, plus any children that support [SetRenderAlpha](lua://CBaseModelEntity.SetRenderAlpha).

```lua
CBaseModelEntity:SetRenderAlphaAll(alpha)
```

**Parameters**

- **`alpha`**  
  `integer`  
  Alpha value (0 = fully transparent, 255 = fully opaque)

### SetCenter

Moves the entity so that its center is at the given position.

```lua
CBaseEntity:SetCenter(position)
```

**Parameters**

- **`position`**  
  `Vector`  
  The new center position

### SetOriginByAttachment

Sets the entity's origin so that the specified attachment point aligns with the given world position.

```lua
CBaseAnimating:SetOriginByAttachment(position, attachment)
```

**Parameters**

- **`position`**  
  `Vector`  
  The target world position for the attachment point
- **`attachment`**  
  `string`  
  The name of the attachment point to align

### TrackProperty

Tracks a property function and calls a callback when a change is detected.


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
  Property function to track
- **`onChangeFunction`**  
  `function`  
  Function to call when a change is detected
- **`interval`** *(optional)*  
  `number`  
  Think interval (default: 0)
- **`context`** *(optional)*  
  `EntityHandle`  
  Entity to run the thinker on, or the calling entity if `nil`

**Returns**
- **`string`**
The name of the think for stopping later

### UntrackProperty

Untracks a property function which was set to be tracked using [TrackProperty](lua://CBaseEntity.TrackProperty).

```lua
CBaseEntity:UntrackProperty(propertyFunction)
```

**Parameters**

- **`propertyFunction`**  
  `function`  
  Property function to untrack

### QuickThink

Quickly starts a think function on the entity with a random name.

```lua
CBaseEntity:QuickThink(func, delay)
```

**Parameters**

- **`func`**  
  `function`  
  The think function
- **`delay`** *(optional)*  
  `number`  
  Delay before starting the think (default: 0)

**Returns**
- **`string`**
The name of the think for stopping later if desired

### SetRenderingEnabled

Sets whether the entity is rendered or not.

```lua
CBaseEntity:SetRenderingEnabled(renderingEnabled)
```

**Parameters**

- **`renderingEnabled`**  
  `boolean`  
  `true` to enable rendering, `false` to disable

### SetCastShadow

Sets whether the entity casts a shadow or not.

```lua
CBaseEntity:SetCastShadow(shadowEnabled)
```

**Parameters**

- **`shadowEnabled`**  
  `boolean`  
  `true` to enable shadow casting, `false` to disable

### DistanceFromEyes

Gets the position in front of the entity’s eyes at the specified distance.

```lua
CBaseEntity:DistanceFromEyes(distance)
```

**Parameters**

- **`distance`**  
  `number`  
  How far in front of the eyes

**Returns**
- **`Vector`**
The world position in front of the eyes

### GetAttachmentNameOrigin

Gets the world origin position of a named attachment point.

```lua
CBaseAnimating:GetAttachmentNameOrigin(name)
```

**Parameters**

- **`name`**  
  `string`  
  The name of the attachment

**Returns**
- **`Vector`**
The world position of the attachment

### GetAttachmentNameAngles

Gets the world angles (rotation) of a named attachment point.

```lua
CBaseAnimating:GetAttachmentNameAngles(name)
```

**Parameters**

- **`name`**  
  `string`  
  The name of the attachment

**Returns**
- **`Vector`**
The world rotation angles of the attachment

### GetAttachmentNameForward

Gets the forward direction vector of a named attachment.

```lua
CBaseAnimating:GetAttachmentNameForward(name)
```

**Parameters**

- **`name`**  
  `string`  
  The name of the attachment

**Returns**
- **`Vector`**
The forward unit vector of the attachment in world space

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
  The target velocity in units/second

### OBBvsOBB

Tests if the OBB of this entity intersects with the OBB of another entity.

```lua
CBaseEntity:OBBvsOBB(other)
```

**Parameters**

- **`other`**  
  `EntityHandle`  
  The other entity

**Returns**
- **`boolean`**
`true` if the OBB of this entity intersects with the OBB of the other entity

### AABBvsOBB

Tests if the AABB of this entity intersects with the OBB of another entity.

The AABB is defined by the entity's bounding mins/maxs and its current origin/angles.

```lua
CBaseEntity:AABBvsOBB(other)
```

**Parameters**

- **`other`**  
  `EntityHandle`  
  The other entity

**Returns**
- **`boolean`**
`true` if the AABB of this entity intersects with the OBB of the other entity

### AABBvsAABB

Tests if the AABB of this entity intersects with the AABB of another entity.

The AABB is defined by the entity's bounding mins/maxs and its current origin/angles.

```lua
CBaseEntity:AABBvsAABB(other)
```

**Parameters**

- **`other`**  
  `EntityHandle`  
  The other entity

**Returns**
- **`boolean`**
`true` if the AABB of this entity intersects with the AABB of the other entity
