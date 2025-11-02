# Globals

> scripts/vscripts/alyxlib/globals.lua

## Global variables

| Name | Value |
| -------------------- | ----- |
| `AlyxLibAddons` | `table` |

## Functions

### RegisterAlyxLibAddon

Registers an addon with AlyxLib.

```lua
RegisterAlyxLibAddon(name, version, workshopID, shortName, minAlyxLibVersion, maxAlyxLibVersion)
```

**Parameters**

- **`name`**  
  `string`  
  Full display name of the addon, e.g. "My New Addon"
- **`version`**  
  `string`  
  SemVer version string of the addon, e.g. "v1.2.3"
- **`workshopID`** *(optional)*  
  `string`  
  The ID of the addon on the Steam workshop
- **`shortName`** *(optional)*  
  `string`  
  Short unique name of the addon without spaces, e.g. "myaddon". Defaults to `name` without spaces and converted to lowercase\
- **`minAlyxLibVersion`** *(optional)*  
  `string`  
  Minimum AlyxLib version that this addon works with, defaults to "v1.0.0"
- **`maxAlyxLibVersion`** *(optional)*  
  `string`  
  Maximum AlyxLib version that this addon works with, defaults to `ALYXLIB_VERSION`

**Returns**
- **`integer`**
The index of the addon for use in other AlyxLib functions

### RegisterAlyxLibDiagnostic

Registers a diagnostic function for an addon to help users describe issues back to the developer.

The diagnostic function should return two values:

  - `true` if the addon is working as expected, `false` otherwise

  - An array of strings or a string containing diagnostic messages

Common AlyxLib and game information will be printed alongside the diagnostic messages for users to copy.

```lua
RegisterAlyxLibDiagnostic(addonIndex, func)
```

**Parameters**

- **`addonIndex`**  
  `integer`  
  The index of the addon for use in other AlyxLib functions
- **`func`**  
  `function`  
  Diagnostic function to check if the addon is working, and any diagnostic messages

### CompareVersions

Compares two semantic version strings and returns an integer indicating their relative order.

It compares the versions based on their `major`, `minor`, and `patch` components.
If a version is incomplete, the missing components are assumed to be 0.



  - `-1` if `v1` is older than `v2`.

  - `1` if `v1` is newer than `v2`.

  - `0` if both versions are equal.

```lua
CompareVersions(v1, v2)
```

**Parameters**

- **`v1`**  
  `string`  
  The first version string to compare. May include leading "v" and whitespace, and may have missing `minor` or `patch` components.
- **`v2`**  
  `string`  
  The second version string to compare. Similar format and rules to `v1`.

**Returns**
- **`-1|0|1`**

### GetScriptFile

Get the file name of the current script without folders or extension. E.g. `util.util`

```lua
GetScriptFile(sep, level)
```

**Parameters**

- **`sep`** *(optional)*  
  `string`  
  Separator character, default is '.'
- **`level`** *(optional)*  
  `(integer|function)?`  
  Function level, [View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-debug.getinfo"])

**Returns**
- **`string`**

### GetEnabledAddons

Get the list of enabled addons from the `default_enabled_addons_list` Convar.

```lua
GetEnabledAddons()
```

**Returns**
- **`string[]`**

### IsAddonEnabled

Checks if the addon with the given `workshopID` is enabled.

```lua
IsAddonEnabled(workshopID)
```

**Parameters**

- **`workshopID`**  
  `string`  
  The workshop ID of the addon

**Returns**
- **`boolean`**
`true` if the addon is enabled, `false` otherwise

### IsEntity

Get if the given `handle` value is an entity, regardless of if it's still alive.

A common usage is replacing the often used entity check:

??? example
    ```lua
    if entity ~= nil and IsValidEntity(entity) then
    ```

With:

??? example
    ```lua
    if IsEntity(entity, true) then
    ```

```lua
IsEntity(handle, checkValidity)
```

**Parameters**

- **`handle`**  
  `EntityHandle`, `any`  
- **`checkValidity`** *(optional)*  
  `boolean`  
  Optionally check validity with IsValidEntity.

**Returns**
- **`boolean`**

### AddOutput

Add an output to a given entity `handle`.

```lua
AddOutput(handle, output, target, input, parameter, delay, activator, caller, fireOnce)
```

**Parameters**

- **`handle`**  
  `EntityHandle`, `string`  
  The entity to add the `output` to.
- **`output`**  
  `string`  
  The output name to add.
- **`target`**  
  `EntityHandle`, `string`  
  The entity the output should target, either handle or targetname.
- **`input`**  
  `string`  
  The input name on `target`.
- **`parameter`** *(optional)*  
  `string`  
  The parameter override for `input`.
- **`delay`** *(optional)*  
  `number`  
  Delay for the output in seconds.
- **`activator`** *(optional)*  
  `EntityHandle`  
  Activator for the output.
- **`caller`** *(optional)*  
  `EntityHandle`  
  Caller for the output.
- **`fireOnce`** *(optional)*  
  `boolean`  
  If the output should only fire once.

### module_exists

Checks if the module/script exists.

```lua
module_exists(name)
```

**Parameters**

- **`name`** *(optional)*  
  `string`  

**Returns**
- **`boolean`**

### ifrequire

Loads the given module, returns any value returned by the given module(`true` when module returns nothing).

Then runs the given callback function.

If the module fails to load then the callback is not executed and no error is thrown, but a warning is displayed in the console.

```lua
ifrequire(modname, callback)
```

**Parameters**

- **`modname`**  
  `string`  
- **`callback`**  
  `function?`  

**Returns**
- **`unknown`**

### IncludeScript

Execute a script file. Included in the current scope by default.

```lua
IncludeScript(scriptFileName, scope)
```

**Parameters**

- **`scriptFileName`**  
  `string`  
- **`scope`** *(optional)*  
  `ScriptScope`  

**Returns**
- **`boolean`**

### IsVREnabled

Gets if the game was started in VR mode.

```lua
IsVREnabled()
```

**Returns**
- **`boolean`**

### prints

Prints all arguments with spaces between instead of tabs.

```lua
prints(...)
```

**Parameters**

- **`...`**  

### printn

Prints all arguments on a new line instead of tabs.

```lua
printn(...)
```

**Parameters**

- **`...`**  

### devprint

Prints all arguments if convar "developer" is greater than 0.

```lua
devprint(...)
```

**Parameters**

- **`...`**  

### devprints

Prints all arguments on a new line instead of tabs if convar "developer" is greater than 0.

```lua
devprints(...)
```

**Parameters**

- **`...`**  

### devprintn

Prints all arguments with spaces between instead of tabs if convar "developer" is greater than 0.

```lua
devprintn(...)
```

**Parameters**

- **`...`**  

### devprint2

Prints all arguments if convar "developer" is greater than 1.

```lua
devprint2(...)
```

**Parameters**

- **`...`**  

### devprints2

Prints all arguments on a new line instead of tabs if convar "developer" is greater than 1.

```lua
devprints2(...)
```

**Parameters**

- **`...`**  

### devprintn2

Prints all arguments with spaces between instead of tabs if convar "developer" is greater than 1.

```lua
devprintn2(...)
```

**Parameters**

- **`...`**  

### warn

Prints a warning in the console, along with a vscript print if inside tools mode.

```lua
warn(...)
```

**Parameters**

- **`...`**  

### devwarn

Prints a warning in the console, along with a vscript print if inside tools mode.
But only if convar "developer" is greater than 0.

```lua
devwarn(...)
```

**Parameters**

- **`...`**  

### Expose

Add a function to the calling entity's script scope with alternate casing.

Makes a function easier to call from Hammer through I/O.

E.g.

??? example
    ```lua
    local function TriggerRelay(io)
        DoEntFire("my_relay", "Trigger", "", 0, io.activator, io.caller)
    end
    Expose(TriggerRelay)

    -- Or with alternate name
    Expose(TriggerRelay, "RelayInput")
    ```

```lua
Expose(func, name, scope)
```

**Parameters**

- **`func`**  
  `function`  
  The function to expose.
- **`name`** *(optional)*  
  `string`  
  Optionally the name of the function for faster processing.
- **`scope`** *(optional)*  
  `table`  
  Optionally the explicit scope to put the exposed function in.

### IsVector

Get if a value is a `Vector`

```lua
IsVector(value)
```

**Parameters**

- **`value`**  
  `any`  

**Returns**
- **`boolean`**

### IsQAngle

Get if a value is a `QAngle`

```lua
IsQAngle(value)
```

**Parameters**

- **`value`**  
  `any`  

**Returns**
- **`boolean`**

### DeepCopyTable

Copy all keys from `tbl` and any nested tables into a brand new table and return it.
This is a good way to get a unique reference with matching data.

Any functions and userdata will be copied by reference, except for:
`Vector`,
`QAngle`

```lua
DeepCopyTable(tbl)
```

**Parameters**

- **`tbl`**  
  `table`  

**Returns**
- **`table`**

### TableRemove

Searches for `value` in `tbl` and sets the associated key to `nil`, returning the key if found.

If your table is an array you should use `ArrayRemove` instead.

```lua
TableRemove(tbl, value)
```

**Parameters**

- **`tbl`**  
  `table`  
- **`value`**  
  `any`  

**Returns**
- **`any`**

### TableRandom

Returns a random key/value pair from a unordered table.

```lua
TableRandom(tbl)
```

**Parameters**

- **`tbl`**  
  `table`  
  Table to get a random pair from.

**Returns**

- **`any`**  
   *`key`*  
Random key selected.

- **`any`**  
   *`value`*  
Value linked to the random key.

### TableKeys

Returns all the keys of a table as a new ordered array.

```lua
TableKeys(tbl)
```

**Parameters**

- **`tbl`**  
  `table<K,any>`  

**Returns**
- **`K[]`**

### TableValues

Returns all the value of a table as a new ordered array.

```lua
TableValues(tbl)
```

**Parameters**

- **`tbl`**  
  `table<any,V>`  

**Returns**
- **`V[]`**

### TableSize

Returns the size of a table by counting all keys.

```lua
TableSize(tbl)
```

**Parameters**

- **`tbl`**  
  `table`  
  The table to count.

**Returns**
- **`number`**
The size of the table.

### TablePluck

Collects all values for a specific key from a list of tables.

```lua
TablePluck(tbl, key)
```

**Parameters**

- **`tbl`**  
  `table[]`  
  List of tables.
- **`key`**  
  `any`  
  Key to get values from.

**Returns**
- **`any[]`**
List of values found for the key.

### TableFindIndex

Returns the index of the first value that matches the predicate.

```lua
TableFindIndex(list, predicate)
```

**Parameters**

- **`list`**  
  `table`  
- **`predicate`**  
  `function`  

**Returns**
- **`integer`**

### ArrayRandom

Returns a random value from an array.

```lua
ArrayRandom(array, min, max)
```

**Parameters**

- **`array`**  
  `T[]`  
  Array to get a value from.
- **`min`** *(optional)*  
  `integer`  
  Optional minimum bound.
- **`max`** *(optional)*  
  `integer`  
  Optional maximum bound.

**Returns**

- **`T`**  
   *`one`*  
The random value.

- **`integer`**  
   *`two`*  
The random index.

### ArrayShuffle

Shuffles a given array in-place.

```lua
ArrayShuffle(array)
```

**Parameters**

- **`array`**  
  `any[]`  

### ArrayRemove

Remove an item from an array at a given position.

This is exponentially faster than `table.remove` for large arrays.

```lua
ArrayRemove(array, pos)
```

**Parameters**

- **`array`**  
  `T`  
  The array to remove from.
- **`pos`**  
  `integer`  
  Position to remove at.

**Returns**
- **`T`**
The same array passed in.

### ArrayRemoveVal

Remove a value from an array.

This is exponentially faster than `table.remove` for large arrays.

```lua
ArrayRemoveVal(array, value)
```

**Parameters**

- **`array`**  
  `T`  
  The array to remove from
- **`value`**  
  `any`  
  The value to remove

**Returns**
- **`T`**
The same array passed in

### ArrayAppend

Appends `array2` onto `array1` as a new array.

Safe extend function alternative to `vlua.extend`, neither input arrays are modified.

```lua
ArrayAppend(array1, array2)
```

**Parameters**

- **`array1`**  
  `T1[]`  
  Base array
- **`array2`**  
  `T2[]`  
  Array which will be appended onto the base array.

**Returns**
- **`T1[]|T2[]`**
The new appended array.

### ArrayAppends

Appends any number of arrays onto `array` as a new array object.

Safe extend function alternative to `vlua.extend`, no input arrays are modified.

```lua
ArrayAppends(array)
```

**Parameters**

- **`array`**  
  `T[]`  
  Base array

**Returns**
- **`T[]`**
The new appended array.

### TraceLineExt

Does a raytrace along a line with extended parameters.
You ignore multiple entities as well as classes and names.
Because the trace has to be redone multiple times, a `timeout` parameter can be defined to cap the number of traces.

```lua
TraceLineExt(parameters)
```

**Parameters**

- **`parameters`**  
  `TraceTableLineExt`  

**Returns**
- **`boolean`**

### TraceLineWorld

Does a raytrace along a line until it hits the world or reaches the end of the line.

```lua
TraceLineWorld(parameters)
```

**Parameters**

- **`parameters`**  
  `TraceTableLine`  

**Returns**
- **`TraceTableLine`**

### TraceLineEntity

Does a raytrace along a line until it hits the specified entity or reaches the end of the line.

```lua
TraceLineEntity(parameters)
```

**Parameters**

- **`parameters`**  
  `TraceTableLine`  

**Returns**
- **`TraceTableLine`**

### TraceLineSimple

Performs a simple line trace and returns the trace table.

```lua
TraceLineSimple(startpos, endpos, ignore, mask)
```

**Parameters**

- **`startpos`**  
  `Vector`  
- **`endpos`**  
  `Vector`  
- **`ignore`** *(optional)*  
  `EntityHandle`  
- **`mask`** *(optional)*  
  `integer`  

**Returns**
- **`TraceTableLine`**

### IsWorld

Get if an entity is the world entity.

```lua
IsWorld(entity)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  

**Returns**
- **`boolean`**

### GetWorld

Get the world entity.

```lua
GetWorld()
```

**Returns**
- **`EntityHandle`**

### IsPhysicsObject

Get if an entity is a physical entity.

```lua
IsPhysicsObject(entity)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  

**Returns**
- **`boolean`**

### haskey

Get if a table has a key (this essentially the same as tbl[key] ~= nil).

```lua
haskey(tbl, key)
```

**Parameters**

- **`tbl`**  
  `table`  
- **`key`**  
  `any`  

**Returns**
- **`boolean`**

### truthy

Check if a value is truthy or falsy.

**falsy == `nil`|`false`|`0`|`""`|`{}`**

```lua
truthy(value)
```

**Parameters**

- **`value`**  
  `any`  
  The value to be checked.

**Returns**
- **`boolean`**
Returns true if the value is truthy, false otherwise.

### SearchEntity

Search an entity for a key using a search pattern. E.g. "getclass" will find "GetClassname"

Works with `class.lua` EntityClass entities.

```lua
SearchEntity(entity, searchPattern)
```

**Parameters**

- **`entity`**  
  `EntityHandle`, `EntityClass`  
- **`searchPattern`**  
  `string`  

**Returns**

- **`string?`**  
   *`key`*  
The full name of the first key matching `searchPattern`.

- **`any?`**  
   *`value`*  
The value of the key found.

### LerpAngle

Linearly interpolates between two angles.

```lua
LerpAngle(t, angle_start, angle_end)
```

**Parameters**

- **`t`**  
  `number`  
  The interpolation parameter, where 0 returns angle_start and 1 returns angle_end.
- **`angle_start`**  
  `number`  
  The starting angle in degrees.
- **`angle_end`**  
  `number`  
  The ending angle in degrees.

**Returns**
- **`number`**
The interpolated angle.

### CalcClosestPointOnEntityOBBAdjusted

```lua
CalcClosestPointOnEntityOBBAdjusted(entity, position)
```

**Parameters**

- **`entity`**  
- **`position`**  

### DefaultTable

Assigns a default value to a table which will be returned if an invalid key is accessed.

```lua
DefaultTable(tbl, default)
```

**Parameters**

- **`tbl`**  
  `T`  
  The table to which the default value will be assigned.
- **`default`**  
  `any`  
  The default value to be returned for invalid keys.

**Returns**
- **`T`**
The table with the default value assigned.

### Wrap

Wraps a value within a specified range.

```lua
Wrap(value, min, max)
```

**Parameters**

- **`value`**  
  `number`  
  The value to be wrapped.
- **`min`**  
  `number`  
  The minimum value of the range.
- **`max`**  
  `number`  
  The maximum value of the range.

**Returns**
- **`number`**
The wrapped value within the specified range.

### CreateToggleBehavior

This function creates a toggle behavior function that switches between two provided functions based on a condition.

Example:

??? example
    ```lua
    local alphaToggle = CreateToggleBehavior(
        function(name)
            print(name .. "Alpha went below 50%")
        end,
        function(name)
            print(name .. "Alpha went above 50%")
        end
    )
    ```

??? example
    ```lua
    thisEntity:SetThink("thinker", function()
        alphaToggle(thisEntity:GetRenderAlpha() < 128, thisEntity:GetName())
        return 0
    end, 0)
    ```

```lua
CreateToggleBehavior(on, off)
```

**Parameters**

- **`on`** *(optional)*  
  `function`  
  Function called when the condition is true.
- **`off`** *(optional)*  
  `function`  
  Function called when the condition is false.

**Returns**
- **`function`**
The created toggle function.

### CalcClosestCornerOnEntityAABB

Compute the closest corner relative to a vector on the AABB of an entity.

```lua
CalcClosestCornerOnEntityAABB(entity, position)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
- **`position`**  
  `Vector`  

### SetPhysVelocity

Sets the absolute world velocity of an entity.

```lua
SetPhysVelocity(velocity)
```

**Parameters**

- **`velocity`**  
  `Vector`  
  The target velocity in units/second.

### RandomChance

Returns one of two values based on a percentage chance.

If the random roll succeeds, returns `onTrue` (default: true).
If it fails, returns `onFalse` (default: false).

```lua
RandomChance(chance, onTrue, onFalse)
```

**Parameters**

- **`chance`**  
  `number`  
  The percentage chance of success (0-100).
- **`onTrue`** *(optional)*  
  `any`  
  Value to return if the chance succeeds (default: true).
- **`onFalse`** *(optional)*  
  `any`  
  Value to return if the chance fails (default: false).

**Returns**
- **`boolean|any`**

## Types

### AlyxLibAddon

A registered AlyxLib addon.

| Field | Type | Description |
| ---- | ---- | ----------- |
| name | `string` | Full display name of the addon, e.g. My "New Addon" |
| version | `string` | SemVer version string of the addon, e.g. "v1.2.3" |
| shortName | `string` | Short unique name of the addon without spaces, e.g. "myaddon" |
| minAlyxLibVersion | `string` | Minimum AlyxLib version that this addon works with |
| maxAlyxLibVersion | `string` | Maximum AlyxLib version that this addon works with |
| workshopID? | `string` | The ID of the addon on the Steam workshop |
| diagnosticFunction? | `function` | Diagnostic function to check if the addon is working, and any diagnostic messages |

### TraceTableLineExt

> **Inherits from:** `TraceTableLine`

| Field | Type | Description |
| ---- | ---- | ----------- |
| ignore | `(EntityHandle|EntityHandle[])?` | Entity or array of entities to ignore. |
| ignoreclass | `(string|string[])?` | Class or array of classes to ignore. |
| ignorename | `(string|string[])?` | Name or array of names to ignore. |
| timeout | `integer?` | Maxmimum number of traces before returning regardless of parameters. |
| traces | `integer` | Number of traces done. |
| dontignore | `EntityHandle` | A single entity to always hit, ignoring if it exists in `ignore`. |
