# VR Commands

!!! info
    These commands are only available when vr is enabled

**How to read the syntax:**

* The **first word** is always the command name; everything after it is a parameter.
* **Required parameters** are wrapped in `<angle brackets>`.
* **Optional parameters** are wrapped in `[square brackets]`.
* Parameters followed by `...` mean you can supply as many as you want.

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

Syntax: `noclip_vr_speed <speed>`

Sets the speed the player moves when `noclip_vr` is enabled, in inches-per-frame.

Example usage:
```
noclip_vr_speed 1
noclip_vr_speed 20
```
## noclip_vr_boost_speed

Syntax: `noclip_vr_boost_speed <speed>`

Sets the speed the player moves when `noclip_vr` is enabled and the 'use' trigger is held, in inches-per-frame.

Example usage:
```
noclip_vr_boost_speed 2
noclip_vr_boost_speed 40
```

## print_hand_attachments

Syntax: `print_hand_attachments [hand]`

Prints all attachments for the given hand in the order they're found. Due to the way this works by removing and re-adding, the order may change after this command is activated.

If no hand is given, the primary hand is used as default.

Possible inputs for `hand` parameter:

* `right` - Right hand
* `left` - Left hand
* `primary` - Primary Hand
* `secondary` - Secondary/Off hand
* `0` - Left hand
* `1` - Right hand

Example usage:
```
print_hand_attachments left
print_hand_attachments 1
print_hand_attachments
```

## set_hand_attachment

Syntax: `set_hand_attachment <classname> [hand]`

Sets the top-level hand attachment to the first entity found with the given class name. This entity must already be attached to the hand.

If no hand is given, the primary hand is used as default.

!!! danger
    This might cause crashes when moving certain entities to the top-level!  
    Hand attachments are undocumented by Valve.

Example usage:
```
set_hand_attachment hlvr_weapon_energygun primary
set_hand_attachment hand_use_controller
```

## remove_hand_attachment

Syntax: `set_hand_attachment <classname> [hand]`

Removes the first entity found with the given class name from the hand if it's attached. This can be any entity in the map whether it is currently attached to the hand or not.

If no hand is given, the primary hand is used as default.

!!! danger
    This might cause crashes if you remove entities which are required to be attached, or in particular orders!

Example usage:
```
remove_hand_attachment hlvr_flashlight_attachment secondary
remove_hand_attachment hlvr_weapon_energygun primary
```

## add_hand_attachment

Syntax: `set_hand_attachment <classname> [hand]`

Adds the first entity found with the given class name to the hand as an attachment. This can be any entity in the map whether it is currently attached to the hand or not.

If no hand is given, the primary hand is used as default.

!!! danger
    This might cause crashes when using entities that are not meant to be attached!

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

!!! info ""
    This can cause "console spam" for analog inputs which change a lot such as movement.

## stop_print_controller_analog_positions

Syntax: `stop_print_controller_analog_positions`

Stops the console from printing analog input values after `start_print_controller_analog_positions` has been activated.