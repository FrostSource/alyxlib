AlyxLib provides a simplified way of interacting with player entities and data.

## Global accessors

A number of global variables exist to let you access common player entities.

The `Player` global variable exists after the player activates (see [player events](#events)) and returns the same handle as `Entities:GetLocalPlayer()`.

```lua
-- Left and right hand entities
Player.LeftHand
Player.RightHand

-- Secondary and primary hand entities
-- These are updated automatically
Player.SecondaryHand
Player.PrimaryHand

-- Hands as a table for looping
Player.Hands[1] -- left
Player.Hands[2] -- right

-- If the player is left handed
Player.IsLeftHanded

-- Avatar and anchor entities
Player.HMDAvatar
Player.HMDAnchor

-- Pickup/drop items
Player.LastItemGrabbed
Player.LastClassGrabbed
Player.LastItemDropped
Player.LastClassDropped

-- The last hand that grabbed an item
Player.LastGrabHand
```

!!! tip
    Player and hand properties/methods exist on the classes themselves so you can still access them whether your script uses `Player` or `Entities:GetLocalPlayer()`.

## Equipment

An `Items` table is updated to keep track of the basic equipment and items the player has collected while playing.

!!! warning "Important"
    Tracked ammo only accounts for ammo picked up and stored by the player. It does not track ammo added via `info_hlvr_equip_player` entities or `hlvr_*resources` commands.  
    There is no known way to get the actual amount of ammo the player has. **If you know how to get this information, please let me know!**

```lua
Player.Items = {
    --- Ammo in the backpack.
    ammo = {
        energygun
        rapidfire
        shotgun
        generic_pistol
    },

    --- Weapons in the inventory
    weapons = {
        energygun,
        rapidfire,
        shotgun,
        multitool,
        --- List of generic pistols the player has
        genericpistols,
    },

    --- Crafting currency the player has.
    resin,

    --- Total number of resin player has had in inventory,
    --- regardless of spending it.
    resin_found,
}
```

??? example
    ```lua
    local count = 0
    for _, weapon in ipairs(Player.Items.weapons.genericpistols) do
        if isinstance(weapon, "MyCustomWeapon") then
            count = count + 1
        end
    end
    print("Player has " .. count .. " custom pistols!")
    ```

!!! warning "Important"
    The `Items` table should not be modified directly as this might break functionality.

`Player:GetResin()` can be more accurate than `Player.Items.resin`, especially if resin has been added by special means. This function also updates `Player.Items.resin` when called.

## Hands

```lua
-- The entity held by this hand
-- For primary hand, this can be the active weapon
CPropVRHand.ItemHeld

-- The last entity that was dropped by this hand
CPropVRHand.LastItemDropped

-- The classname of the last entity dropped by this hand
CPropVRHand.LastClassDropped

-- The last entity that was grabbed by this hand
CPropVRHand.LastItemGrabbed

-- The classname of the last entity grabbed by this hand
CPropVRHand.LastClassGrabbed

-- The literal type of this hand for use in inputs
CPropVRHand.Literal

-- The entity in the wrist pocket of this hand
CPropVRHand.WristItem

-- The opposite hand to this one
CPropVRHand.Opposite
```

## Useful methods

Entities can be forcefully picked up or dropped.

```lua
-- Drop an entity
Player:DropByHandle(ent)
-- or use the entity method
ent:Drop()

-- Pickup an entity with a hand
-- omit the hand to use the nearest hand
Player:GrabByHandle(ent, Player.SecondaryHand)
-- or use the entity method
ent:Grab(Player.SecondaryHand)

-- Check if an entity is being held first
if Player:IsHolding(ent) then

-- Check if a specific hand is holding an entity
Player.SecondaryHand:IsHoldingItem()
-- Which is equivalent to
IsValidEntity(Player.SecondaryHand.ItemHeld)
```

Items the player currently has in their possession, i.e. hands and wrist pockets.

Useful for checking if an item should be spawned or not without providing too many resources for the player.

```lua
-- All held and pocketed items
Player:GetImmediateItems()

-- item_hlvr_grenade_frag and item_hlvr_grenade_xen on the player
Player:GetGrenades()

-- item_healthvial on the player
Player:GetHealthPens()
```

Checking current weaponry/equipment.

```lua
-- Is the player currently holding a weapon
Player:HasWeaponEquipped()

-- You can also check for a specific weapon
if Player:GetWeapon() == Player.Items.weapons.energygun then end

-- Check if the player has wrist pockets
Player:HasItemHolder()

-- Check if the player has grabbity gloves
Player:HasGrabbityGloves()

-- Check if the player has a flashlight
-- This also returns the flashlight entity
Player:GetFlashlight()
```

Getting weapon upgrades that the player has.

!!! note ""
    Weapon upgrade names are strings. You can view the full list [here](../reference/player/core.md#playerpistolupgrades).

!!! bug ""
    You cannot check for "shotgun_upgrade_quick_fire" because there is no known way to detect this on the shotgun itself.

```lua
-- Check if the player has a specific weapon upgrade
if Player:HasWeaponUpgrade("shotgun_upgrade_quick_fire") then end

-- Or get all upgrades for a specific weapon
Player:GetPistolUpgrades()
Player:GetRapidfireUpgrades()
Player:GetShotgunUpgrades()
```

## Events

Player events are normal game events related to the player, but with more specific information about the event passed to the callback function.

To listen to a player event, use `ListenToPlayerEvent` with the event name and the callback function (and optional context).  
To stop listening to a player event, use `StopListeningToPlayerEvent` with the event ID returned from `ListenToPlayerEvent`.

```lua
---@param event PlayerEventPlayerActivate
local id = ListenToPlayerEvent("player_activate", function(event)
    if event.type == "spawn" then
        print("New map, new game")
    end
    StopListeningToPlayerEvent(id)
end) --(1)!
```

1. Unlike `ListenToGameEvent`, `ListenToPlayerEvent` does not need `nil` to be explicitly passed as the context.  
   Keep this in mind if swapping back to `ListenToGameEvent` later.

!!! tip
    This section will only go over the most common player events.  
    You can see a full list of player events and their parameters [here](../reference/player/events.md#types).

`player_activate`, `novr_player` and `vr_player_ready` are the standard player events to use when wanting to run code at game start after the player has spawned.

`player_activate` is fired after the player and other entities have been spawned. This event is also when some [global variables](#global-accessors) like `Player` are first initialized.  
`novr_player` is fired a moment later, when the game is running without a VR player, i.e. started with `-novr`.  
`vr_player_ready` is fired a moment later, when the game is running with a VR player. This event is also when the rest of the [global variables](#global-accessors) are initialized.

!!! bug ""
    It's always recommended to use `player_activate` with `ListenToPlayerEvent` instead of `ListenToGameEvent` due to a bug that can cause that specific event to fail in other addons.

---

Listening to item pickups is especially useful for scripting custom item interactions, for example listening to inputs only when the item is held.

```lua
-- Track input ids
local ids = {}

---Launch held items with the fire button
---@param event PlayerEventItemPickup
ListenToPlayerEvent("item_pickup", function(event)
    if IsPhysicsObject(event.item) then
        -- Listen for the fire button
        ids[event.hand:GetHandID()] = Input:ListenToButton(
            "press",
            event.hand,
            DIGITAL_INPUT_FIRE,
            nil,
            function (params)
                -- Launch the item
                event.item:Drop()--(1)!
                event.item:ApplyAbsVelocityImpulse(
                    event.hand:GetAttachmentNameForward("vr_controller_gg_hold") * 500
                )
            end
        )
    end
end)

---Clear inputs for the given hand
---@param event PlayerEventItemReleased
ListenToPlayerEvent("item_released", function(event)
    Input:StopListening(ids[event.hand:GetHandID()])
    ids[event.hand:GetHandID()] = nil
end)
```

1. Forcing the item to drop will cause the `item_released` event to fire.

!!! bug ""
    `item_pickup` and `item_released` are typically accurate, but may have to be estimated or not fire at all in some cases.  
    If you experience issues please [contact me](../index.md#need-help) about your use case.

## Reference

View the full reference [here](../reference/player/core.md).