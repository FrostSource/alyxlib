# Trigger Look Arbitrary

Attaching this script to your `trigger_look` entity will augment it to perform the "look check" from any given classname or targetname.

Normally, a `trigger_look` entity will only look from the player's eyes, but with this script, you can check where the player's flashlight is aiming - or even the eyes of an NPC.

---

Attach to your entity in `Misc > Entity Scripts` = `alyxlib/entity_mods/trigger_look_arbitrary`.

!!! warning "Important"
    Because there is no easy way to hijack the actual outputs, this script instead fires the OnUser* outputs. This means it is important to remember to **not** use the `OnStartLook`, `OnEndLook`, or `OnTrigger` outputs, as these are still tied to the player's eyes.

    However, this also means you can test from the player eyes *and* another entity at the same time.

## Keyvalues

**LookFromClass** <string\>  
:   The classname of the entity to do the "look check" from.  
    Finds the first entity of this classname at the time the trigger is activated.  
    *This may be omitted if you are using `LookFromName`.*

**LookFromName** <string\>
:   The targetname of the entity to do the "look check" from.  
    Finds the first entity with this targetname at the time the trigger is activated.  
    **This property takes precedence over `LookFromClass`.**  
    *This may be omitted if you are using `LookFromClass`.*

**LookFromAttachment** <string\>
:   The attachment name on the model of the "look from" entity to use as the origin and forward direction.  
    *This may be omitted if you are not using an attachment.*

**CheckAllTargets** <integer\>
:   Set to 1 to allow multiple targets with the same name to be checked at once.  
    The first one to be looked at will be passed as the `!activator` when `OnUser*` is fired.  
    *This may be omitted if you don't want to use it.*

## Outputs

!!! note
    Every OnUser* output is given the target entity that was looked at as `!activator`.
    This is generally only useful when you have multiple targets and are using `CheckAllTargets`.

!!! tip
    It is recommended that you untick the "Fire Once" spawnflag and disable the trigger through other means (like `OnUser1`), as the default look detection is still active. If the default behavior triggers while "Fire Once" is enabled, it will disable the `trigger_look_arbitrary` behavior.

**OnUser1**
:   Equivalent to `OnStartLook`; fired only once when the entity looks at the target.

**OnUser2**
:   Equivalent to `OnEndLook`; fired only once when the entity looks away from the target.

**OnUser3**
:   Equivalent to `OnTrigger`; fired every "Look Time" seconds while looking at the target.

## Functions

Keyvalues can be set at runtime by sending an input of `RunScriptCode` to your trigger_look with a parameter override as one of the following:

**SetLookFromClass('class_name_here')**
:   E.g. `SetLookFromClass('hlvr_flashlight_attachment')`

**SetLookFromName('target_name_here')**
:   E.g. `SetLookFromName('flashlight')`

**SetLookFromAttachment('attach_name_here')**
:   E.g. `SetLookFromAttachment('light_attach')`

**SetCheckAllTargets(true or false)**
:   E.g. `SetCheckAllTargets(true)`

---

For debugging purposes, you can toggle debug visuals for the current session by sending an input of `CallPrivateScriptFunction` to your trigger_look with a parameter override of `ToggleDebug`.
