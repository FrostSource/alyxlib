# No-VR Commands

!!! info
    These commands are only available when VR is disabled.

**How to read the syntax:**

* The **first word** is always the command name; everything after it is a parameter.
* **Required parameters** are wrapped in `<angle brackets>`.
* **Optional parameters** are wrapped in `[square brackets]`.
* Parameters followed by `...` mean you can supply as many as you want.

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

- `buddha 1`
- `impulse 101`
- Binds keyboard V to noclip.
- Enables enhanced entity interactions.

## novr_disable_all_debugging

Syntax: `novr_disable_all_debugging`

Undoes everything applied by `novr_enable_all_debugging` except removing weapons.