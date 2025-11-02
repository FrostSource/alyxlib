# Math Obb

> scripts/vscripts/alyxlib/math/obb.lua

## Functions

### GetBoundingOBBData

Returns the center and half extents of an OBB in local space.

```lua
GetBoundingOBBData(mins, maxs)
```

**Parameters**

- **`mins`**  
  `Vector`  
  The local space minimum corner.
- **`maxs`**  
  `Vector`  
  The local space maximum corner.

**Returns**
- **`OBBData`**
The OBB data.

### GetEntityOBBData

Returns the center and half extents of an entity's OBB in local space.

```lua
GetEntityOBBData(entity)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity.

**Returns**
- **`OBBData`**
The OBB data.

### GetEntityAABB

Returns the world space minimum and maximum corners of an entity's OBB.

```lua
GetEntityAABB(entity)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity.

**Returns**

- **`Vector`**  
    
The world space minimum corner.

- **`Vector`**  
    
The world space maximum corner.

### AABBvsAABB

Tests if two AABBs intersect.

```lua
AABBvsAABB(aMin, aMax, bMin, bMax)
```

**Parameters**

- **`aMin`**  
  `Vector`  
  The minimum corner of the first AABB.
- **`aMax`**  
  `Vector`  
  The maximum corner of the first AABB.
- **`bMin`**  
  `Vector`  
  The minimum corner of the second AABB.
- **`bMax`**  
  `Vector`  
  The maximum corner of the second AABB.

**Returns**
- **`boolean`**
True if the AABBs intersect.

### OBBvsOBB

Tests if two OBBs intersect.

```lua
OBBvsOBB(obbDataA, originA, anglesA, obbDataB, originB, anglesB)
```

**Parameters**

- **`obbDataA`**  
  `OBBData`  
  The data of the first OBB.
- **`originA`**  
  `Vector`  
  The world space origin of the first OBB.
- **`anglesA`**  
  `QAngle`  
  The angles of the first OBB.
- **`obbDataB`**  
  `OBBData`  
  The data of the second OBB.
- **`originB`**  
  `Vector`  
  The world space origin of the second OBB.
- **`anglesB`**  
  `QAngle`  
  The angles of the second OBB.

**Returns**
- **`boolean`**
True if the OBBs intersect.

### AABBvsOBB

Tests if an AABB and an OBB intersect.

```lua
AABBvsOBB(aabbMin, aabbMax, obbData, obbOrigin, obbAngles)
```

**Parameters**

- **`aabbMin`**  
  `Vector`  
  The minimum corner of the AABB.
- **`aabbMax`**  
  `Vector`  
  The maximum corner of the AABB.
- **`obbData`**  
  `OBBData`  
  The data of the OBB.
- **`obbOrigin`**  
  `Vector`  
  The world space origin of the OBB.
- **`obbAngles`**  
  `QAngle`  
  The angles of the OBB.

**Returns**
- **`boolean`**
True if the AABB and OBB intersect.

### PointInAABB

Tests if a point is inside an AABB.

```lua
PointInAABB(aMin, aMax, point)
```

**Parameters**

- **`aMin`**  
  `Vector`  
  The minimum corner of the AABB.
- **`aMax`**  
  `Vector`  
  The maximum corner of the AABB.
- **`point`**  
  `Vector`  
  The point to test.

**Returns**
- **`boolean`**

### PointInOBB

Tests if a point is inside an OBB.

```lua
PointInOBB(obbData, origin, angles, point)
```

**Parameters**

- **`obbData`**  
  `OBBData`  
  The OBB data (center, half extents in local space).
- **`origin`**  
  `Vector`  
  The world space origin of the OBB.
- **`angles`**  
  `QAngle`  
  The world space orientation of the OBB.
- **`point`**  
  `Vector`  
  The point to test.

**Returns**
- **`boolean`**

### DebugDrawOBB

Draws an OBB in the world.

```lua
DebugDrawOBB(obbData, origin, angles, color, noDepthTest, seconds)
```

**Parameters**

- **`obbData`**  
  `OBBData`  
  The data of the OBB.
- **`origin`**  
  `Vector`  
  The world space origin of the OBB.
- **`angles`**  
  `QAngle`  
  The angles of the OBB.
- **`color`**  
  `Vector`  
  The color of the OBB.
- **`noDepthTest`**  
  `boolean`  
  True if the OBB should be drawn above all geometry.
- **`seconds`**  
  `number`  
  The number of seconds the OBB should be visible for.

### DebugDrawEntityOBB

Draws an entity's OBB in the world.

```lua
DebugDrawEntityOBB(entity, color, noDepthTest, seconds)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity to draw the OBB for.
- **`color`**  
  `Vector`  
  The color of the OBB in RGB.
- **`noDepthTest`**  
  `boolean`  
  True if the OBB should be drawn above all geometry.
- **`seconds`**  
  `number`  
  The number of seconds the OBB should be visible for.

### DebugDrawEntityAABB

Draws an entity's AABB in the world.

The AABB is defined by the entity's bounding mins/maxs and its current origin/angles.

```lua
DebugDrawEntityAABB(entity, color, noDepthTest, seconds)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity to draw the AABB for.
- **`color`**  
  `Vector`  
  The color of the AABB in RGB.
- **`noDepthTest`**  
  `boolean`  
  True if the AABB should be drawn above all geometry.
- **`seconds`**  
  `number`  
  The number of seconds the AABB should be visible for.
