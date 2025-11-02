!!! failure
    Exposing in its current state seems to be completely pointless.

AlyxLib comes with the global [Expose](../reference/globals.md#expose) function to make it easier to call functions from Hammer.

!!! tip
    If your function does not take arguments and exists exists in either the global scope or an entity instance/private scope (i.e. [Entity Class](../components/classes.md)), you do not need to "expose" it. `CallScriptFunction` is already case-insensitive for function names.

## Calling exposed functions

Exposed functions have their casing lowercased and uppercased to try and match Hammer's I/O case-insensitivity.

To call an exposed function, use the `CallScriptFunction` input in Hammer with the name of the exposed function as the parameter override value.

## Built-in exposed functions

**Player**
:   `DropLeftHand`  
    Forces the player's left hand to drop its held item.
:   `DropRightHand`  
    Forces the player's right hand to drop its held item.
:   `DropPrimaryHand`  
    Forces the player's primary hand to drop its held item.
:   `DropSecondaryHand`  
    Forces the player's secondary hand to drop its held item.
:   `DropCaller`
    Forces the player to drop the `!caller` entity if held.
:   `DropActivator`
    Forces the player to drop the `!activator` entity if held.
:   `GrabCaller`
    Forces the player to grab the `!caller` entity with their nearest hand.
:   `GrabActivator`
    Forces the player to grab the `!activator` entity with their nearest hand.
:   `DisableFallDamage`
    Disables fall damage for the player.
:   `EnableFallDamage`
    Enables fall damage for the player.

**Entity**
:   `Drop`
    Forces the player to drop this entity if held.
:   `Grab`
    Forces the player to grab this entity with their nearest hand.

!!! exposed
    Look for the **Exposed** tag in the [reference](../reference/class.md) section.