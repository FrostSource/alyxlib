AlyxLib comes with custom console commands which can help development debugging. They can be used whether you are in Tools Mode or not.

**How to read the syntax:**

* The first word is always the command name, all others are parameters
* Plain parameters are required, they must be supplied
* Parameters wrapped in square brackets are [optional]
* Parameters with 3 dots mean you can supply as many as you want...

# Common Commands

## alyxlib_info

Syntax: `alyxlib_info`

Prints AlyxLib version information and number of addons registered with AlyxLib (as of v1.3.0) vs unregistered.

NOTE: "Init Addons" field may always be 0 if Scalable Init Support has priority.

## alyxlib_addons

Syntax: `alyxlib_addons`

Prints a list of addons registered with AlyxLib (as of v1.3.0) and information about them.

## alyxlib_diagnose

Syntax: `alyxlib_diagnose [addon]`

Prints information about AlyxLib and the way the use is playing (e.g. Single handed, which map, is VR enabled) which the user can then send to the developer along with their description of the issue to aid in developer debugging.

If an addon is supplied and the addon has registered a diagnose function, it will be used to diagnose specific addon issues and hopefully provide more information for the user or suggest fixes to the user.

Example usage:
```
alyxlib_diagnose
alyxlib_diagnose resin
alyxlib_diagnose Resin Watch
alyxlib_diagnose body holster
```

## alyxlib_commands

Syntax: `alyxlib_commands`

Prints all commands/convars registered using AlyxLib's `RegisterAlyxLibCommand` and `RegisterAlyxLibConvar` functions.

This is an easy way to see all commands in alphabetical order with descriptions and default values.

## print_all_ents

Syntax: `print_all_ents [propertyPattern...]`

Prints all entities in the map, along with any supplied property patterns.

A property pattern is the name or name-part that the command will search for on each entity to get its value. The property must be a variable or function which takes no arguments and returns a value.

* 'SetOrigin' is invalid because it takes an argument and does not return a value.
* 'GetContext' is invalid because it takes an argument.
* 'GetOrigin' is **valid** because it takes no arguments and returns a printable value.

A name-part is a segment of the name that the command will search for, if you don't know the full name or just want to reduce typing.

For example, a pattern of 'name' might find 'GetName' or 'GetClassname' depending on which it finds first.

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

Syntax: `print_nearby_ents [radius] [propertyPattern...]

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

Syntax: `ent_show pattern`

Shows the position of an entity in the world by drawing a line to it from the player, if its name, class or model name contain the `pattern` parameter.

## ent_mass

Syntax: `ent_mass pattern`

Prints the mass of the entity to the console, if its name, class or model name contain the `pattern` parameter.

## sphere

Syntax: `sphere [x] [y] [z] [radius]`

Draws a sphere in the game world at given position with a given size.

## print_ent_criteria

Syntax: `print_ent_criteria pattern`

Prints all criteria for an entity, if its name, class or model name contain the `pattern` parameter.
These are the same values you would get by doing `ent:GatherCriteria()`

## print_ent_base_criteria

Syntax: `print_ent_base_criteria pattern`

Prints all base criteria for an entity, if its name, class or model name contain the `pattern` parameter.

Base criteria is any criteria which was not added by the `Storage` library when saving. This helps reduce clutter when checking for a specific criteria value.

## healme

Syntax: `healme amount`

Heals the player by the amount given, as an inverse function for `hurtme`.

## goto_transition

Teleports the player inside the furthest trigger_changelevel or the next one found for subsequent calls.

This can cause missing hands if player is forced away from transition immediately after, such as if used during the opening train ride in a2_quarantine_entrance due to the triggers surrounding the train forcing the player back in the train.

## force_nearest_transition

Fires the `ChangeLevel` input on the nearest `trigger_changelevel` to the player.

**WARNING: This may crash the game if the nearest changelevel goes to a previous map.**

## ent_find_by_address

Syntax: `ent_find_by_address "table"/address [":"] [address]`

Finds an entity by its "table address" which is the value shown when turning the entity table into a string.

When printing an entity you will see a value similar to: `table: 0x00237bd8` which is the hexadecimal address of the table in memory. Sometimes you only have this entity address but know nothing about else the entity like its name, for example you might come across the entity in a print-out with `Debug.PrintTable`. Using `ent_find_by_address` you can use the address to discover information about the entity and do further testing.

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

Syntax: `code code_string`

Executes arbitrary code in the global scope `_G`.

Double quotes `"` should be replaced with single quotes `'` when using strings. The console uses double quotes to group parameters with spaces into a single parameter.

If you get a parameter overflow message in the console with this command try wrapping the entire code in double quotes, see last example in "Example usage".

Example usage:
```
code print('Hello world!')
code Debug.PrintTable(Player)
code local e = Entities:FindByName(nil, 'myent') e:Kill()
code "local e=SpawnEntityFromTableSynchronous('item_hlvr_grenade_frag',{origin=Player:GetOrigin()}) e:EntFire('ArmGrenade')"
```

## ent_code

Syntax: `ent_code target_pattern code_string`

Executes arbitrary code in a specific entity's private script scope.

Double quotes `"` should be replaced with single quotes `'` when using strings. Double quotes are used to group parameters with spaces into a single parameter in the console.

If you get a parameter overflow message in the console with this command try wrapping the entire code in double quotes, see last example in "Example usage".

Example usage:
```
ent_code logic_ print(thisEntity:GetName())
ent_code player Debug.PrintTable(thisEntity)
ent_code !player "local e=SpawnEntityFromTableSynchronous('item_hlvr_grenade_frag',{origin=Player:GetOrigin()}) e:EntFire('ArmGrenade')"
```

# No-VR Commands

**THESE COMMANDS WILL ONLY SHOW IN THE CONSOLE WHEN VR IS DISABLED**

## novr_player_use_vr_speed

Syntax: `novr_player_use_vr_speed [0/1]`

Attempts to replicate the default VR movement speed onto the novr player. Currently this can cause crouching to be too slow.

Example usage:
```
novr_player_use_vr_speed 1
novr_player_use_vr_speed 0
novr_player_use_vr_speed
```

## novr_enable_all_debugging

Syntax: `novr_enable_all_debugging`

Enables all standard AlyxLib NoVR debugging commands and bindings.

`buddha 1`
`impulse 101`
Binds keyboard V to noclip.
Enables enhanced entity interactions.

## novr_disable_all_debugging

Syntax: `novr_disable_all_debugging`

Undoes everything applied by `novr_enable_all_debugging` except removing weapons.

# VR Commands

**THESE COMMANDS WILL ONLY SHOW IN THE CONSOLE WHEN VR IS ENABLED**

## noclip_vr

Syntax: `noclip_vr [0/1]`

Enables a custom noclip mode for the VR player. Use the controller joystick to move through the air and walls. You can boost your move speed temporarily by holding the 'use' trigger while moving.

The type of movement is based on the current settings, i.e. Hand movement when Hand Continuous is chosen; Head movement for all others.

Example usage:
```
noclip_vr 1
noclip_vr 0
noclip_vr
```

## noclip_vr_speed

Syntax: `noclip_vr_speed speed`

Sets the speed the player moves when `noclip_vr` is enabled, in inches-per-frame.

Example usage:
```
noclip_vr_speed 1
noclip_vr_speed 20
```
## noclip_vr_boost_speed

Syntax: `noclip_vr_boost_speed speed`

Sets the speed the player moves when `noclip_vr` is enabled and the 'use' trigger is held, in inches-per-frame.

Example usage:
```
noclip_vr_speed 2
noclip_vr_speed 40
```


## print_hand_attachments

Syntax: `print_hand_attachments [hand]`

Prints all attachments for the given hand in the order they're found. Due to the way this works by removing and re-adding, the order may change after this command is activated.

If no hand is given, the primary hand is used as default.

Possible inputs for `hand` parameter:
* right - Right hand
* left - Left hand
* primary - Primary Hand
* secondary - Secondary/Off hand
* 0 - Left hand
* 1 - Right hand

Example usage:
```
print_hand_attachments left
print_hand_attachments 1
print_hand_attachments
```

## set_hand_attachment

Syntax: `set_hand_attachment classname [hand]`

Sets the top-level hand attachment to the first entity found with the given class name. This entity must already be attached to the hand.

If no hand is given, the primary hand is used as default.

**This might cause crashes when moving certain entities to the top-level! Hand attachment handling is undocumented.**

Example usage:
```
set_hand_attachment hlvr_weapon_energygun primary
set_hand_attachment hand_use_controller
```

## remove_hand_attachment

Syntax: `set_hand_attachment classname [hand]`

Removes the first entity found with the given class name from the hand if it's attached. This can be any entity in the map whether it is currently attached to the hand or not.

If no hand is given, the primary hand is used as default.

**This might cause crashes if you remove entities which are required to be attached or in particular orders!**

Example usage:
```
remove_hand_attachment hlvr_flashlight_attachment secondary
remove_hand_attachment hlvr_weapon_energygun primary
```

## add_hand_attachment

Syntax: `set_hand_attachment classname [hand]`

Adds the first entity found with the given class name to the hand as an attachment. This can be any entity in the map whether it is currently attached to the hand or not.

If no hand is given, the primary hand is used as default.

**This might cause crashes when using entities that are not meant to be attached!**

Example usage:
```
add_hand_attachment hlvr_flashlight_attachment secondary
add_hand_attachment hlvr_weapon_energygun primary
```

# VR Controller Commands

## start_print_controller_button_presses

Syntax: `start_print_controller_button_presses`

When activated the console will start printing when a button is pressed or released to aid in discovering which action is mapped to which button.

## stop_print_controller_button_presses

Syntax: `stop_print_controller_button_presses`

Stops the console from printing button presses/releases after `start_print_controller_button_presses` has been activated.

## start_print_controller_analog_positions

Syntax: `start_print_controller_analog_positions`

When activated the console will start printing the position values of controller analog inputs.

This can cause "console spam" for analog inputs which change a lot such as movement.

## stop_print_controller_analog_positions

Syntax: `stop_print_controller_analog_positions`

Stops the console from printing analog input values after `start_print_controller_analog_positions` has been activated.