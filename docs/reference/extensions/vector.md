# Extensions Vector

> scripts/vscripts/alyxlib/extensions/vector.lua

## Methods

### Perpendicular

Calculates the perpendicular vector to the current vector.

```lua
Vector:Perpendicular()
```

**Returns**
- **`Vector`**
  The perpendicular vector.

### IsParallelTo

Checks if the current vector is parallel to the given vector.

```lua
Vector:IsParallelTo(vector)
```

**Parameters**

- **`vector`**  
  `Vector`  
  The vector to compare with.

**Returns**
- **`boolean`**
  True if the vectors are parallel, false otherwise.

### Slerp

Spherical linear interpolation between the calling vector and the target vector over t = [0, 1].

```lua
Vector:Slerp(target, t)
```

**Parameters**

- **`target`**  
  `Vector`  
  The target vector to interpolate towards.
- **`t`**  
  `number`  
  The interpolation factor, ranging from 0 to 1.

**Returns**
- **`Vector`**
  The resulting vector after spherical linear interpolation.

### LocalTranslate

Translates a vector within a local coordinate system.
This function computes a new vector by applying an offset relative to the local axes defined by the forward, right, and up direction vectors.

- `offset.x`: Translation along the forward vector.
- `offset.y`: Translation along the right vector.
- `offset.z`: Translation along the up vector.

```lua
Vector:LocalTranslate(offset, forward, right, up)
```

**Parameters**

- **`offset`**  
  `Vector`  
  The translation offset vector. This defines how much to move along the forward, right, and up directions.
- **`forward`**  
  `Vector`  
  The forward direction of the local coordinate system.
- **`right`**  
  `Vector`  
  The right direction of the local coordinate system.
- **`up`**  
  `Vector`  
  The up direction of the local coordinate system.

**Returns**
- **`Vector`**
  A new vector representing the translated position.

### AngleDiff

Calculates the angle difference in degrees between the calling vector and the given vector. This is always the smallest angle.

```lua
Vector:AngleDiff(vector)
```

**Parameters**

- **`vector`**  
  `Vector`  
  The vector to calculate the angle difference with.

**Returns**
- **`number`**
  Angle difference in degrees.

### SignedAngleDiff

Calculates the signed angle difference between the calling vector and the given vector around the specified axis.

```lua
Vector:SignedAngleDiff(vector, axis)
```

**Parameters**

- **`vector`**  
  `Vector`  
  The vector to calculate the angle difference with.
- **`axis`** *(optional)*  
  `Vector`  
  The axis of rotation around which the angle difference is calculated.

**Returns**
- **`number`**
  The signed angle difference in degrees.

### Unpack

Unpacks the x, y, z components as 3 return values.

```lua
Vector:Unpack()
```

**Returns**
- **`number`**
  x component
- **`number`**
  y component
- **`number`**
  z component

### LengthSquared

Returns the squared length (magnitude) of the vector.
More efficient than calculating the actual length as it avoids using `sqrt()`.

```lua
Vector:LengthSquared()
```

**Returns**
- **`number`**

### IsSimilarTo

Checks if this vector is similar to another vector within a given tolerance.

```lua
Vector:IsSimilarTo(vector, tolerance)
```

**Parameters**

- **`vector`**  
  `Vector`  
  The vector to compare against.
- **`tolerance`** *(optional)*  
  `number`  
  The tolerance within which the vectors are considered similar. Default is 1e-5. See [math.isclose](lua://math.isclose)

**Returns**
- **`boolean`**
  Returns `true` if the vectors are similar within the tolerance, otherwise `false`.

### Clone

Creates a copy of the vector.

```lua
Vector:Clone()
```

**Returns**
- **`Vector`**
  A new vector with the same components as the original.
