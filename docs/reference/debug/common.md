# Debug Common

> scripts/vscripts/alyxlib/debug/common.lua

## Properties

### version

```lua
Debug.version = value
```

**Default value**
  `"v2.2.0"`

## Methods

### FindEntityByPattern

Finds the first entity whose name, class or model matches `pattern`.

`pattern` can also be an entity handle string, e.g. `0x0026caf8`

```lua
Debug:FindEntityByPattern(pattern, exact)
```

**Parameters**

- **`pattern`**  
  `string`  
  The search pattern to look for.
- **`exact`**  
  `boolean?`  
  If true the pattern must match exactly, otherwise wildcards will be used.

**Returns**
- **`EntityHandle?`**
The found entity, or nil if not found.

### FindAllEntitiesByPattern

Finds all entities whose name, class or model match `pattern`.

`pattern` can also be an entity handle string, e.g. `0x0026caf8`

```lua
Debug:FindAllEntitiesByPattern(pattern, exact)
```

**Parameters**

- **`pattern`**  
  `string`  
  The search pattern to look for.
- **`exact`**  
  `boolean?`  
  If true the pattern must match exactly, otherwise wildcards will be used.

**Returns**
- **`EntityHandle[]`**

### PrintEntityList

Prints a formated indexed list of entities with custom property information.
Also links children with their parents by displaying the index alongside the parent for easy look-up.

??? example
    ```lua
    Debug.PrintEntityList(ents, {"getclassname", "getname", "getname"})
    ```

If no properties are supplied the default properties are used: GetClassname, GetName, GetModelName
If an empty property table is supplied only the base values are shown: Index, Handle, Parent
Property patterns do not need to be functions.

```lua
Debug:PrintEntityList(list, properties)
```

**Parameters**

- **`list`**  
  `EntityHandle[]`  
  List of entities to print.
- **`properties`** *(optional)*  
  `string[]`  
  List of property patterns to search for.

### PrintAllEntities

Prints information about all existing entities.

```lua
Debug:PrintAllEntities(properties)
```

**Parameters**

- **`properties`** *(optional)*  
  `string[]`  
  List of property patterns to search for when displaying entity information.

### PrintDiffEntities

Prints information about any new entities since the last time `Debug.PrintAllEntities` was called.

```lua
Debug:PrintDiffEntities(properties)
```

**Parameters**

- **`properties`** *(optional)*  
  `string[]`  
  List of property patterns to search for when displaying entity information.

### PrintEntities

Print entities matching a search string.

Searches name, classname and model name.

```lua
Debug:PrintEntities(search, exact, dont_include_parents, properties)
```

**Parameters**

- **`search`**  
  `string`  
  Search string, may include `*`.
- **`exact`**  
  `boolean`  
  If the search should match exactly or part of the name.
- **`dont_include_parents`**  
  `boolean`  
  Parents won't be included in the results.
- **`properties`** *(optional)*  
  `string[]`  
  List of property patterns to search for when displaying entity information.

### PrintAllEntitiesInSphere

Prints information about all entities within a sphere.

```lua
Debug:PrintAllEntitiesInSphere(origin, radius, properties)
```

**Parameters**

- **`origin`**  
  `Vector`  
  Position to search for entities at.
- **`radius`**  
  `number`  
  Max radius to find entities within.
- **`properties`** *(optional)*  
  `string[]`  
  List of property patterns to search for when displaying entity information.

### PrintTable

Prints the keys/values of a table and any tested tables.

This is different from `DeepPrintTable` in that it will not print members of entity handles.

```lua
Debug:PrintTable(tbl, prefix, ignore, meta, customIterator)
```

**Parameters**

- **`tbl`**  
  `table`  
  Table to print
- **`prefix`** *(optional)*  
  `string`  
  Optional prefix for each line
- **`ignore`** *(optional)*  
  `any[]`  
  Optional nested tables to ignore
- **`meta`** *(optional)*  
  `boolean`  
  If meta tables should be printed
- **`customIterator`** *(optional)*  
  `function`  
  Optional custom iterator to use (default=pairs)

### PrintTableShallow

Prints the keys/values of a table but not any tested tables.

```lua
Debug:PrintTableShallow(tbl)
```

**Parameters**

- **`tbl`**  
  `table`  
  Table to print.

### PrintList

Prints an ordered table as a numbered list in the console.

```lua
Debug:PrintList(tbl, prefix)
```

**Parameters**

- **`tbl`**  
  `table`  
  Table to print.
- **`prefix`** *(optional)*  
  `string`  
  Optional prefix for each line.

### PrintSimpleTable

Prints all the values in a table, one value per line, without any numbering or padding.

```lua
Debug:PrintSimpleTable(tbl)
```

**Parameters**

- **`tbl`**  
  `table`  
  Table to print.

### PrintValue

Prints a value and its type in an easy to read format.

```lua
Debug:PrintValue(value)
```

**Parameters**

- **`value`**  
  `any`  

### ShowEntity

Draws a debug line to an entity in game.

```lua
Debug:ShowEntity(ent, duration)
```

**Parameters**

- **`ent`**  
  `EntityHandle`, `string`  
  Handle or targetname of the entity(s) to find.
- **`duration`**  
  `number?`  
  Number of seconds the debug should display for.

**Returns**
- **`EntityHandle[]|EntityHandle?`**
Entities found, or the entity given

### PrintEntityCriteria

Prints all current context criteria for an entity.

```lua
Debug:PrintEntityCriteria(ent)
```

**Parameters**

- **`ent`**  
  `EntityHandle`  

### PrintEntityBaseCriteria

Prints current context criteria for an entity except for values saved using `storage.lua`.

```lua
Debug:PrintEntityBaseCriteria(ent)
```

**Parameters**

- **`ent`**  
  `EntityHandle`  

### GetClassname

Gets the class name of a vscript entity based on its metatable, e.g. `CBaseEntity`.

If the entity is an EntityClass entity the original Valve class name will be returned instead of the EntityClass.

```lua
Debug:GetClassname(ent)
```

**Parameters**

- **`ent`**  
  `EntityHandle`  
  The entity to get the class name of.

**Returns**
- **`string`**
The class name of the entity or "none" if not found.

### PrintMetaClasses

```lua
Debug:PrintMetaClasses()
```

### PrintGraph

Prints a visual ASCII graph showing the distribution of values between a min/max bound.

E.g.

??? example
    ```lua
    Debug.PrintGraph(6, 0, 1, {
        val1 = RandomFloat(0, 1),
        val2 = RandomFloat(0, 1),
        val3 = RandomFloat(0, 1)
    })
    ```

??? example
    ```lua
    1^ []
     | []    []
     | [] [] []
     | [] [] []
     | [] [] []
    0 ---------->
       v  v  v
       a  a  a
       l  l  l
       3  1  2
    val3 = 0.96067351102829
    val1 = 0.5374761223793
    val2 = 0.7315416932106
    ```

```lua
Debug:PrintGraph(height, min_val, max_val, name_value_pairs)
```

**Parameters**

- **`height`**  
  `integer`  
  Height of the actual graph in print rows. Heigher values give more accurate results but can overflow the console making it hard to read.
- **`min_val`** *(optional)*  
  `number`  
  Minimum expected value for `name_value_pairs`. Default is `0`.
- **`max_val`** *(optional)*  
  `number`  
  Maxmimum expected value for `name_value_pairs`. Default is `1`.
- **`name_value_pairs`**  
  `table<string,number>`  
  Values to visualize on the graph.

### PrintInheritance

Prints a nested list of entity inheritance.

```lua
Debug:PrintInheritance(ent)
```

**Parameters**

- **`ent`**  
  `EntityHandle`  

### SimpleVector

Returns a simplified vector string with decimal places truncated.

```lua
Debug:SimpleVector(vector)
```

**Parameters**

- **`vector`**  
  `Vector`, `QAngle`, `table`  

**Returns**
- **`string`**

### Sphere

Draw a simple sphere without worrying about all the properties.

```lua
Debug:Sphere(x, y, z, radius, time, color)
```

**Parameters**

- **`x`**  
  `number`  
  X position
- **`y`**  
  `number`  
  Y position
- **`z`**  
  `number`  
  Z position
- **`radius`** *(optional)*  
  `number`  
  Radius of the sphere
- **`time`** *(optional)*  
  `number`  
  Lifetime in seconds, default 10
- **`color`** *(optional)*  
  `Vector`  
  Color vector [Red, Green, Blue]

### Line

Draw a simple line without worrying about all the properties.

```lua
Debug:Line(startPos, endPos, time, color)
```

**Parameters**

- **`startPos`**  
  `Vector`  
  Start position
- **`endPos`**  
  `Vector`  
  End position
- **`time`** *(optional)*  
  `number`  
  Lifetime in seconds, default 10
- **`color`** *(optional)*  
  `Vector`  
  Color vector [Red, Green, Blue]

### EntStr

Returns a string made up of an entity's class and name in the format "[class, name]" for debugging purposes.

```lua
Debug:EntStr(ent)
```

**Parameters**

- **`ent`**  
  `EntityHandle`  

**Returns**
- **`string`**

### DumpConvars

Dumps a list of convars and their values to the console.

```lua
Debug:DumpConvars(convars)
```

**Parameters**

- **`convars`**  
  `string[]`  
  List of convar names to dump

### FindEntityByHandleString

Finds an entity by its handle as a string.

Certain parts of the string can be omitted and the following are all valid:

??? example
    ```lua
    Debug.FindEntityByHandleString("table", ":", "0x0012b03")
    Debug.FindEntityByHandleString("table:", "0x0012b03")
    Debug.FindEntityByHandleString("table: 0x0012b03")
    Debug.FindEntityByHandleString("table", "0x0012b03")
    Debug.FindEntityByHandleString("0x0012b03")
    ```

Please note that omitting the colon is not allowed in a single string, i.e. "table 0x0012b03" will not work.

```lua
Debug:FindEntityByHandleString(tblpart, colon, hash)
```

**Parameters**

- **`tblpart`**  
  `string`  
  Entity table string
- **`colon`** *(optional)*  
  `string`  
  The colon part
- **`hash`** *(optional)*  
  `string`  
  The hash part

**Returns**
- **`EntityHandle?`**

### IsEntityHandleString

Gets whether the string is in the format of an entity handle.

```lua
Debug:IsEntityHandleString(handleString)
```

**Parameters**

- **`handleString`**  
  `string`  
  The handle string

**Returns**
- **`string?`**
The hash part or nil if not an entity handle

### ToOrdinalString

Converts a number to its ordinal string representation (e.g., 1 → "1st", 2 → "2nd", 3 → "3rd").

```lua
Debug:ToOrdinalString(n)
```

**Parameters**

- **`n`**  
  `integer`  
  Number to convert to ordinal representation

**Returns**
- **`string`**

### GetSourceLine

Get the script name and line number of a function or traceback level.

```lua
Debug:GetSourceLine(f)
```

**Parameters**

- **`f`**  
  `integer`, `function`  
  Level or function

**Returns**
- **`string`**

### Try

Safely calls a function while handling any errors.

If an error occurs, a warning will be printed to the console.

```lua
Debug:Try(action)
```

**Parameters**

- **`action`**  
  `function`  
  The function to call

### TableStr

Converts a table to single line string representation.

```lua
Debug:TableStr(tbl)
```

**Parameters**

- **`tbl`**  
  `table`  
  The table to convert.

**Returns**
- **`string`**
The string representation.

## Functions

### entspawn

Spawns an entity synchronously.

```lua
entspawn(classname, spawnkeys)
```

**Parameters**

- **`classname`**  
  `string`  
  The classname of the entity
- **`spawnkeys`** *(optional)*  
  `table`, `string`  
  The spawnkeys table or targetname

**Returns**
- **`EntityHandle`**
