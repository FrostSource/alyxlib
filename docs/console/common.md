# Common Commands

**How to read the syntax:**

* The **first word** is always the command name; everything after it is a parameter.
* **Required parameters** are wrapped in `<angle brackets>`.
* **Optional parameters** are wrapped in `[square brackets]`.
* Parameters followed by `...` mean you can supply as many as you want.

## print_all_ents

Syntax: `print_all_ents [propertyPattern...]`

Prints all entities in the map, along with any supplied property patterns.

A property pattern is the name or name-part that the command will search for on each entity to get its value. The property must be a variable or function which takes no arguments and returns a value.

* 'GetOrigin' is **valid** because it takes no arguments and returns a printable value.
* 'SetOrigin' is ***invalid*** because it takes an argument and does not return a value.
* 'GetContext' is ***invalid*** because it takes an argument.

A name-part is a segment of the name that the command will search for if you don't know the full name or just want to reduce typing.
The first property that matches the name-part will be used.
For example, a name-part pattern of 'name' might return 'GetName' or 'GetClassname' depending on which it finds first.

Child entities display their parent as an index number and classname so you can easily find it in the list.

This command also works for any variables and functions added to entities through scripts, including the AlyxLib entity classes.

Example usage:
```
print_all_ents
print_all_ents getname getorigin
print_all_ents Gethealth CustomVariable
```

Example output:
![image](https://github.com/user-attachments/assets/051ea73c-8430-4c0f-9342-d63f0ef1d800)

## print_diff_ents

Syntax: `print_diff_ents [propertyPattern...]`

Prints all new entities in the map since `print_all_ents` was last called, along with any supplied property patterns (see [print_all_ents](#print_all_ents) for a description of property patterns).

This command can be used to quickly check which entities have been spawned since `print_all_ents` was called, as long as they are still alive.

## print_nearby_ents

Syntax: `print_nearby_ents [radius] [propertyPattern...]`

Prints all entities within a given radius around the player, along with any supplied property patterns (see [print_all_ents](#print_all_ents) for a description of property patterns).

If no radius is supplied a default value of 256 is used.

Example usage:
```
print_nearby_ents
print_nearby_ents 100
print_nearby_ents 2000 getname getorigin
```

## print_ents

Syntax: `print_ents pattern [propertyPattern...]`

Prints any entities whose name, class or model name contain the `pattern` parameter, along with any supplied property patterns (see [print_all_ents](#print_all_ents) for a description of property patterns).

For example, a pattern of "physics" might match all 'prop_physics', 'prop_physics_override' and any entity with "physics" in the name.

Example usage:
```
print_ents grenade_frag getname getorigin
print_ents "my model.vmdl" getclass
```

## ent_show

Syntax: `ent_show <pattern>`

Shows the position of an entity in the world by drawing a line to it from the player, if its name, class or model name contain the `pattern` parameter.

## ent_mass

Syntax: `ent_mass <pattern>`

Prints the mass of the entity to the console, if its name, class or model name contain the `pattern` parameter.

## sphere

Syntax: `sphere [x] [y] [z] [radius]`

Draws a sphere in the game world at given position with a given size.

## print_ent_criteria

Syntax: `print_ent_criteria <pattern>`

Prints all criteria for an entity, if its name, class or model name contain the `pattern` parameter.
These are the same values you would get by doing `ent:GatherCriteria()`

## print_ent_base_criteria

Syntax: `print_ent_base_criteria <pattern>`

Prints all base criteria for an entity, if its name, class or model name contain the `pattern` parameter.

Base criteria is any criteria which was not added by the `Storage` library when saving. This helps reduce clutter when checking for a specific criteria value.

## healme

Syntax: `healme <amount>`

Heals the player by the amount given, as an inverse function for `hurtme`.

## goto_transition

Teleports the player inside the furthest trigger_changelevel or the next one found for subsequent calls.

!!! bug
	This can cause missing hands if player is forced away from transition immediately after, such as if used during the opening train ride in a2_quarantine_entrance due to the triggers surrounding the train forcing the player back in the train.

## force_nearest_transition

Fires the `ChangeLevel` input on the nearest `trigger_changelevel` to the player.

!!! danger
	This may crash the game if the nearest `trigger_changelevel` goes to a previous map.

## ent_find_by_address

Syntax: `ent_find_by_address <"table"/address> [":"] [address]`

Finds an entity by its "table address" which is the value shown when turning the entity table into a string.

When printing an entity you will see a value similar to: `table: 0x00237bd8` which is the hexadecimal address of the table in memory. Sometimes you only have this entity address but know nothing about else the entity like its name.  
For example you might come across the entity in a print-out with `Debug.PrintTable`.  
With `ent_find_by_address` you can use the address to discover information about the entity and do further testing.

Table addresses will change every time they are created so they will be different each time a map starts even if the entity associated with it is the same.

Example output:
```
Info for table: 0x00237bd8
	Classname player
	Name 
	Parent
	Model 
```

Example usage:
```
ent_find_by_address table: 0x00237bd8
ent_find_by_address 0x00237bd8
```

## code

Syntax: `code <code_string>`

Executes arbitrary code in the global scope `_G`.

Double quotes `"` should be replaced with single quotes `'` when using strings. The console uses double quotes to group parameters with spaces into a single parameter.

If you get a parameter overflow message in the console with this command try wrapping the entire code in double quotes (see last example below).

Example usage:
```
code print('Hello world!')
code Debug.PrintTable(Player)
code local e = Entities:FindByName(nil, 'myent') e:Kill()
code "local e=SpawnEntityFromTableSynchronous('item_hlvr_grenade_frag',{origin=Player:GetOrigin()}) e:EntFire('ArmGrenade')"
```

## ent_code

Syntax: `ent_code <ent_pattern> <code_string>`

Executes arbitrary code in a specific entity's private script scope.

Double quotes `"` should be replaced with single quotes `'` when using strings. Double quotes are used to group parameters with spaces into a single parameter in the console.

If you get a parameter overflow message in the console with this command try wrapping the entire code in double quotes, see last example in "Example usage".

Example usage:
```
ent_code logic_ print(thisEntity:GetName())
ent_code player Debug.PrintTable(thisEntity)
ent_code !player "local e=SpawnEntityFromTableSynchronous('item_hlvr_grenade_frag',{origin=thisEntity:GetOrigin()}) e:EntFire('ArmGrenade')"
```



