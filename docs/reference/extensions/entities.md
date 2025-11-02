# Extensions Entities

> scripts/vscripts/alyxlib/extensions/entities.lua

## Methods

### FindBestMatching

Finds the best matching entity based on a given unique name (if provided),
classname, position, and search radius.

If a name is provided, it attempts to find an exact match by name first.

 - If only one entity with that name exists, it is returned immediately.

 - If multiple entities share the name, the one closest to the given position is chosen.

If no name is provided, the function falls back to finding the nearest entity of the given classname.

```lua
Entities:FindBestMatching(name, class, position, radius)
```

**Parameters**

- **`name`**  
  `string`  
  The unique name of the entity (if available, "" if not)
- **`class`**  
  `string`  
  The classname of the entity (fallback if name isn't available)
- **`position`**  
  `Vector`  
  The position to search around
- **`radius`** *(optional)*  
  `number`  
  The max search radius (default: 128)

**Returns**
- **`EntityHandle`**
The best-matching entity found, or nil if none found

### All

Gets an array of every entity that currently exists.

```lua
Entities:All()
```

**Returns**
- **`EntityHandle[]`**

### Random

Gets a random entity in the map.

```lua
Entities:Random()
```

**Returns**
- **`EntityHandle`**

### FindInPrefab

Find an entity within the same prefab as another entity.

Will have issues in nested prefabs.

```lua
Entities:FindInPrefab(entity, name)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
- **`name`**  
  `string`  

**Returns**

- **`EntityHandle?`**  
    
The found entity, nil if not found.

- **`string`**  
    
Prefab part of the name.

### FindInPrefab

Find an entity within the same prefab as this entity.

Will have issues in nested prefabs.

```lua
CEntityInstance:FindInPrefab(name)
```

**Parameters**

- **`name`**  
  `string`  

**Returns**

- **`EntityHandle?`**  
    

- **`string`**  
    
Prefab part of the name.

### FindAllInCone

Find all entities with a cone.

```lua
Entities:FindAllInCone(origin, direction, maxDistance, maxAngle, checkEntityBounds)
```

**Parameters**

- **`origin`**  
  `Vector`  
  Origin of the cone in worldspace.
- **`direction`**  
  `Vector`  
  Normalized direction vector.
- **`maxDistance`**  
  `number`  
  Max distance the cone will extend towards `direction`.
- **`maxAngle`**  
  `number`  
  Field-of-view in degrees that the cone can see, [0-180].
- **`checkEntityBounds`**  
  `boolean`  
  If true the entity bounding box will be tested as well as the origin.

**Returns**
- **`EntityHandle[]`**
List of entities found within the cone.

### FindAllInBounds

Find all entities within `mins` and `maxs` bounding box.

```lua
Entities:FindAllInBounds(mins, maxs, checkEntityBounds)
```

**Parameters**

- **`mins`**  
  `Vector`  
  Mins vector in world-space.
- **`maxs`**  
  `Vector`  
  Maxs vector in world-space.
- **`checkEntityBounds`** *(optional)*  
  `boolean`  
  If true the entity bounding boxes will be used for the check instead of the origin.

**Returns**
- **`EntityHandle[]`**
List of entities found.

### FindAllInBox

Find all entities within an `origin` centered box.

```lua
Entities:FindAllInBox(width, length, height)
```

**Parameters**

- **`width`**  
  `number`  
  Size of the box on the X axis.
- **`length`**  
  `number`  
  Size of the box on the Y axis.
- **`height`**  
  `number`  
  Size of the box on the Z axis.

**Returns**
- **`EntityHandle[]`**
List of entities found.

### FindAllInCube

Find all entities within an `origin` centered cube of a given `size.`

```lua
Entities:FindAllInCube(origin, size)
```

**Parameters**

- **`origin`**  
  `Vector`  
  World space cube position.
- **`size`**  
  `number`  
  Size of the cube in all directions.

**Returns**
- **`EntityHandle[]`**
List of entities found.

### FindNearest

Find the nearest entity to a world position.

```lua
Entities:FindNearest(origin, maxRadius)
```

**Parameters**

- **`origin`**  
  `Vector`  
  Position to check from.
- **`maxRadius`**  
  `number`  
  Maximum radius to check from `origin`.

**Returns**
- **`EntityHandle?`**
The nearest entity found, or nil if none found.

### FindAllByClassnameList

Finds all entities in the map from a list of classnames.

```lua
Entities:FindAllByClassnameList(classes)
```

**Parameters**

- **`classes`**  
  `string[]`  

**Returns**
- **`EntityHandle[]`**

### FindAllByClassnameListWithin

Finds all entities within a radius from a list of classnames.

```lua
Entities:FindAllByClassnameListWithin(classes, origin, maxRadius)
```

**Parameters**

- **`classes`**  
  `string[]`  
- **`origin`**  
  `Vector`  
- **`maxRadius`**  
  `number`  

**Returns**
- **`EntityHandle[]`**

### FindByClassnameListNearest

Find the entity from a list of possible classnames which is closest to a world position.

```lua
Entities:FindByClassnameListNearest(classes, origin, maxRadius)
```

**Parameters**

- **`classes`**  
  `string[]`  
- **`origin`**  
  `Vector`  
- **`maxRadius`**  
  `number`  

**Returns**
- **`EntityHandle?`**

### FindAllNPCs

Finds all NPCs within the map.

```lua
Entities:FindAllNPCs()
```

**Returns**
- **`CAI_BaseNPC[]`**

### IterateAllNPCs

Returns an iterator to loop over all NPC entities in the map using a `for` loop.

E.g.

??? example
    ```lua
    for npc in Entities:IterateAllNPCs() do
        print(npc:GetClassname())
    end
    ```

```lua
Entities:IterateAllNPCs()
```

**Returns**
- **`function`**
Iterator

### FindAllByModelWithin

Find all entities by model name within a radius.

```lua
Entities:FindAllByModelWithin(modelName, origin, maxRadius)
```

**Parameters**

- **`modelName`**  
  `string`  
- **`origin`**  
  `Vector`  
- **`maxRadius`**  
  `number`  

**Returns**
- **`EntityHandle[]`**

### FindByModelNearest

Find the entity by model name nearest to a point.

```lua
Entities:FindByModelNearest(modelName, origin, maxRadius)
```

**Parameters**

- **`modelName`**  
  `string`  
- **`origin`**  
  `Vector`  
- **`maxRadius`**  
  `number`  

**Returns**
- **`EntityHandle?`**

### FindByModelPattern

Find the first entity whose model name contains `namePattern`.

This works by searching every entity in the map and may incur a performance hit in large maps if used often.

```lua
Entities:FindByModelPattern(namePattern)
```

**Parameters**

- **`namePattern`**  
  `string`  

**Returns**
- **`EntityHandle?`**

### FindAllByModelPattern

Find all entities whose model name contains `namePattern`.

This works by searching every entity in the map and may incur a performance hit in large maps if used often.

```lua
Entities:FindAllByModelPattern(namePattern)
```

**Parameters**

- **`namePattern`**  
  `string`  

**Returns**
- **`EntityHandle[]`**
