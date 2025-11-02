!!! tip
    For example CFG files, check out the [Debug Menu component section](../components/debug_menu.md).

**How to read the syntax:**

* The **first word** is always the command name; everything after it is a parameter.
* **Required parameters** are wrapped in `<angle brackets>`.
* **Optional parameters** are wrapped in `[square brackets]`.
* Parameters followed by `...` mean you can supply as many as you want.

## debug_menu_hand

Syntax: `debug_menu_hand <0/1>`

Sets which hand the debug menu is attached to.

1 = Primary hand  
0 = Secondary hand

Example usage:
```
debug_menu_hand 1
debug_menu_hand 0
```

## debug_menu_height

Syntax: `debug_menu_height <height>`

Sets the height of the debug menu, allowing more or less options to show at once.

Must be a number range from 7 to 30.

Example usage:
```
debug_menu_height 14
```

## debug_menu_floating

Syntax: `debug_menu_floating <0/1>`

Sets whether the debug menu floats in the world instead of being attached to a hand.

If your VR headset uses inside-out tracking and you experience movement issues when using the debug menu, try setting this to 1.

1 = Floating  
0 = Attached to hand

Example usage:
```
debug_menu_floating 1
debug_menu_floating 0
```

## debug_menu_lock

Syntax: `debug_menu_lock <0/1>`

Sets whether the debug menu is locked so it cannot be dragged around.

This is recommended after you have found the desired position and orientation of the menu in-game, and want to avoid accidentally moving it.

1 = Locked  
0 = Unlocked

Example usage:
```
debug_menu_lock 1
debug_menu_lock 0
```

## debug_menu_extras

Syntax: `debug_menu_extras <0/1>`

Sets whether the extras tab is always enabled by default.

The extras tab is designed for more advanced debugging, which is why it's disabled by default. You can always access the extras tab from the debug menu by scrolling to the bottom of the menu and pressing the "Enable Extras Tab..." button.

1 = Enabled  
0 = Disabled

Example usage:
```
debug_menu_extras 1
debug_menu_extras 0
```

---

!!! tip
    For an explanation of the below offset values, check out [repositioning the menu](../components/debug_menu.md#repositioning-the-menu).

!!! note
    The below offset values have no effect if [debug_menu_floating](#debug_menu_floating) is set to 1.

!!! note ""
    Values should be set relative to the **right hand**. They are converted for the left hand automatically.

## debug_menu_offset_x

Syntax: `debug_menu_offset_x <x>`

Sets the relative x position of the debug menu attached to a hand.

Example usage:
```
debug_menu_offset_x 4
```

## debug_menu_offset_y

Syntax: `debug_menu_offset_y <y>`

Sets the relative y position of the debug menu attached to a hand.

Example usage:
```
debug_menu_offset_y -9
```

## debug_menu_offset_z

Syntax: `debug_menu_offset_z <z>`

Sets the relative z position of the debug menu attached to a hand.

Example usage:
```
debug_menu_offset_z 0
```

## debug_menu_offset_pitch

Syntax: `debug_menu_offset_pitch <pitch>`

Sets the relative pitch of the debug menu attached to a hand.

Example usage:
```
debug_menu_offset_pitch 0
```

## debug_menu_offset_yaw

Syntax: `debug_menu_offset_yaw <yaw>`

Sets the relative yaw of the debug menu attached to a hand.

Example usage:
```
debug_menu_offset_yaw 180
```

## debug_menu_offset_roll

Syntax: `debug_menu_offset_roll <roll>`

Sets the relative roll of the debug menu attached to a hand.

Example usage:
```
debug_menu_offset_roll 0
```