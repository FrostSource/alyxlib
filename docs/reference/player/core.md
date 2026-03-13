# Player Core

> scripts/vscripts/alyxlib/player/core.lua

## Global variables

| PLAYER WEAPON |  |
| -------------------- | ----- |
| `PLAYER_WEAPON_HAND` | `"hand_use_controller"` |
| `PLAYER_WEAPON_ENERGYGUN` | `"hlvr_weapon_energygun"` |
| `PLAYER_WEAPON_RAPIDFIRE` | `"hlvr_weapon_rapidfire"` |
| `PLAYER_WEAPON_SHOTGUN` | `"hlvr_weapon_shotgun"` |
| `PLAYER_WEAPON_MULTITOOL` | `"hlvr_multitool"` |
| `PLAYER_WEAPON_GENERIC_PISTOL` | `"hlvr_weapon_generic_pistol"` |

## Properties

### HMDAvatar

```lua
CBasePlayer.HMDAvatar = value
```

**Default value**
  `nil`

### HMDAnchor

```lua
CBasePlayer.HMDAnchor = value
```

**Default value**
  `nil`

### Hands

```lua
CBasePlayer.Hands = value
```

**Default value**
  `table`

### LeftHand

```lua
CBasePlayer.LeftHand = value
```

**Default value**
  `nil`

### RightHand

```lua
CBasePlayer.RightHand = value
```

**Default value**
  `nil`

### PrimaryHand

```lua
CBasePlayer.PrimaryHand = value
```

**Default value**
  `nil`

### SecondaryHand

```lua
CBasePlayer.SecondaryHand = value
```

**Default value**
  `nil`

### IsLeftHanded

```lua
CBasePlayer.IsLeftHanded = value
```

**Default value**
  `false`

### LastItemDropped

```lua
CBasePlayer.LastItemDropped = value
```

**Default value**
  `nil`

### LastClassDropped

```lua
CBasePlayer.LastClassDropped = value
```

**Default value**
  `""`

### LastItemGrabbed

```lua
CBasePlayer.LastItemGrabbed = value
```

**Default value**
  `nil`

### LastClassGrabbed

```lua
CBasePlayer.LastClassGrabbed = value
```

**Default value**
  `""`

### CurrentlyEquipped

```lua
CBasePlayer.CurrentlyEquipped = value
```

**Default value**
  `PLAYER_WEAPON_HAND`

### PreviouslyEquipped

```lua
CBasePlayer.PreviouslyEquipped = value
```

**Default value**
  `PLAYER_WEAPON_HAND`

### Items

```lua
CBasePlayer.Items = value
```

**Default value**
  `table`

### ItemHeld

```lua
CPropVRHand.ItemHeld = value
```

**Default value**
  `nil`

### LastItemDropped

```lua
CPropVRHand.LastItemDropped = value
```

**Default value**
  `nil`

### LastClassDropped

```lua
CPropVRHand.LastClassDropped = value
```

**Default value**
  `""`

### LastItemGrabbed

```lua
CPropVRHand.LastItemGrabbed = value
```

**Default value**
  `nil`

### LastClassGrabbed

```lua
CPropVRHand.LastClassGrabbed = value
```

**Default value**
  `""`

### Literal

```lua
CPropVRHand.Literal = value
```

**Default value**
  `nil`

### WristItem

```lua
CPropVRHand.WristItem = value
```

**Default value**
  `nil`

### Opposite

```lua
CPropVRHand.Opposite = value
```

**Default value**
  `nil`

## Methods

### DropByHandle

Forces the player to drop an entity if held.

```lua
CBasePlayer:DropByHandle(handle)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Handle of the entity to drop

### DropLeftHand

Forces the player to drop any item held in their left hand.

```lua
CBasePlayer:DropLeftHand()
```

### DropRightHand

Forces the player to drop any item held in their right hand.

```lua
CBasePlayer:DropRightHand()
```

### DropPrimaryHand

Forces the player to drop any item held in their primary hand.

```lua
CBasePlayer:DropPrimaryHand()
```

### DropSecondaryHand

Forces the player to drop any item held in their secondary/off hand.

```lua
CBasePlayer:DropSecondaryHand()
```

### DropCaller

Forces the player to drop the caller entity if held.

```lua
CBasePlayer:DropCaller(data)
```

**Parameters**

- **`data`**  
  `IOParams`  
  The IOParams table

### DropActivator

Forces the player to drop the activator entity if held.

```lua
CBasePlayer:DropActivator(data)
```

**Parameters**

- **`data`**  
  `IOParams`  
  The IOParams table

### GrabByHandle

Forces the player to grab `handle` with `hand`.

```lua
CBasePlayer:GrabByHandle(handle, hand)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Handle of the entity to grab
- **`hand`** *(optional)*  
  `CPropVRHand`, `0`, `1`  
  Hand to grab with

### GrabCaller

Force the player to grab the caller entity.

```lua
CBasePlayer:GrabCaller(data)
```

**Parameters**

- **`data`**  
  `IOParams`  
  The IOParams table

### GrabActivator

Force the player to grab the activator entity.

```lua
CBasePlayer:GrabActivator(data)
```

**Parameters**

- **`data`**  
  `IOParams`  
  The IOParams table

### GetMoveType

Get VR movement type.

```lua
CBasePlayer:GetMoveType()
```

**Returns**
- **`PlayerMoveType`**
The VR movement type

### SetMoveType

Sets the VR movement type.

```lua
CBasePlayer:SetMoveType(movetype)
```

**Parameters**

- **`movetype`**  
  `PlayerMoveType`  
  The VR movement type

### GetLookingAt

Returns the entity the player is looking at directly.

```lua
CBasePlayer:GetLookingAt(maxDistance)
```

**Parameters**

- **`maxDistance`** *(optional)*  
  `number`  
  Max distance the trace can search

**Returns**
- **`EntityHandle?`**
The entity the player is looking at

### DisableFallDamage

Disables fall damage for the player.

```lua
CBasePlayer:DisableFallDamage()
```

### EnableFallDamage

Enables fall damage for the player.

```lua
CBasePlayer:EnableFallDamage()
```

### AddResources

Adds resources to the player.

```lua
CBasePlayer:AddResources(pistol_ammo, rapidfire_ammo, shotgun_ammo, resin)
```

**Parameters**

- **`pistol_ammo`** *(optional)*  
  `number`  
  Amount of pistol ammo
- **`rapidfire_ammo`** *(optional)*  
  `number`  
  Amount of rapidfire ammo
- **`shotgun_ammo`** *(optional)*  
  `number`  
  Amount of shotgun ammo
- **`resin`** *(optional)*  
  `number`  
  Amount of resin

### SetResources

Sets resources for the player.

**This might give inaccurate amounts for omitted values.**

```lua
CBasePlayer:SetResources(pistol_ammo, rapidfire_ammo, shotgun_ammo, resin)
```

**Parameters**

- **`pistol_ammo`** *(optional)*  
  `number`  
  Amount of pistol ammo
- **`rapidfire_ammo`** *(optional)*  
  `number`  
  Amount of rapidfire ammo
- **`shotgun_ammo`** *(optional)*  
  `number`  
  Amount of shotgun ammo
- **`resin`** *(optional)*  
  `number`  
  Amount of resin

### SetItems

Manually sets the items that player has.

**This is purely for scripting and does not modify the actual items the player has in-game.**

Use [Player:AddResources](lua://CBasePlayer.AddResources) to modify in-game items.

```lua
CBasePlayer:SetItems(energygun_ammo, generic_pistol_ammo, rapidfire_ammo, shotgun_ammo, resin)
```

**Parameters**

- **`energygun_ammo`** *(optional)*  
  `integer`  
  Amount of pistol ammo
- **`generic_pistol_ammo`** *(optional)*  
  `integer`  
  Amount of generic pistol ammo
- **`rapidfire_ammo`** *(optional)*  
  `integer`  
  Amount of rapidfire ammo
- **`shotgun_ammo`** *(optional)*  
  `integer`  
  Amount of shotgun ammo
- **`resin`** *(optional)*  
  `integer`  
  Amount of resin

### AddPistolAmmo

Adds pistol ammo to the player.

```lua
CBasePlayer:AddPistolAmmo(amount)
```

**Parameters**

- **`amount`**  
  `number`  
  Amount of pistol ammo

### AddShotgunAmmo

Adds shotgun ammo to the player.

```lua
CBasePlayer:AddShotgunAmmo(amount)
```

**Parameters**

- **`amount`**  
  `number`  
  Amount of shotgun ammo

### AddRapidfireAmmo

Adds rapidfire ammo to the player.

```lua
CBasePlayer:AddRapidfireAmmo(amount)
```

**Parameters**

- **`amount`**  
  `number`  
  Amount of rapidfire ammo

### AddResin

Adds resin to the player.

```lua
CBasePlayer:AddResin(amount)
```

**Parameters**

- **`amount`**  
  `number`  
  Amount of resin

### GetImmediateItems

Gets the items currently held or in wrist pockets.

```lua
CBasePlayer:GetImmediateItems()
```

**Returns**
- **`EntityHandle[]`**
List of items

### GetGrenades

Gets the grenades currently held and in wrist pockets.

```lua
CBasePlayer:GetGrenades()
```

**Returns**
- **`EntityHandle[]`**
List of grenades

### GetHealthPens

Gets the health pens currently held and in wrist pockets.

```lua
CBasePlayer:GetHealthPens()
```

**Returns**
- **`EntityHandle[]`**

### MergePropWithHand

Marges an existing prop with a given hand.

```lua
CBasePlayer:MergePropWithHand(hand, prop, hide_hand)
```

**Parameters**

- **`hand`**  
  `CPropVRHand`, `0`, `1`  
  The hand handle or ID
- **`prop`**  
  `EntityHandle`, `string`  
  The prop handle or targetname
- **`hide_hand`**  
  `boolean`  
  If the hand should turn invisible after merging

### HasWeaponEquipped

Checks if the player has a gun equipped.
`hlvr_multitool` is not considered a "gun"

```lua
CBasePlayer:HasWeaponEquipped()
```

**Returns**
- **`boolean`**
`true` if the player has a gun equipped

### GetCurrentWeaponReserves

Get the amount of ammo stored in the backpack for the currently equipped weapon.

**This is not accurate if ammo was given through special means like `info_hlvr_equip_player`.**

```lua
CBasePlayer:GetCurrentWeaponReserves()
```

**Returns**
- **`number`**
The amount of ammo, or `0` if no weapon equipped

### HasItemHolder

Checks if the player has an item (wrist) holder equipped.

```lua
CBasePlayer:HasItemHolder()
```

**Returns**
- **`boolean`**
`true` if the player has an item holder

### HasGrabbityGloves

Checks if the player has grabbity gloves equipped.

```lua
CBasePlayer:HasGrabbityGloves()
```

**Returns**
- **`boolean`**
`true` if the player has grabbity gloves

### GetFlashlight

```lua
CBasePlayer:GetFlashlight()
```

### GetFlashlightPointedAt

Gets the first entity the flashlight is pointed at.

If flashlight does not exist, both returns will be `nil`.

```lua
CBasePlayer:GetFlashlightPointedAt(maxDistance)
```

**Parameters**

- **`maxDistance`** *(optional)*  
  `number`  
  Max tracing distance (default: 2048)

**Returns**

- **`EntityHandle|nil`**  
    
The entity that was hit

- **`Vector|nil`**  
    
The position the trace hit, regardless of entity found

### GetResin

Gets the current resin count the player has.

This is can be more accurate than `Player.Items.resin`.

Calling this will update `Player.Items.resin`.

```lua
CBasePlayer:GetResin()
```

**Returns**
- **`number`**
The current resin count

### IsHolding

Gets if player is holding a given entity in either hand.

```lua
CBasePlayer:IsHolding(entity)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity to check

**Returns**
- **`boolean`**
`true` if the player is holding the entity

### GetWeapon

Gets the entity handle of the currently equipped weapon, including `hlvr_multitool`.

```lua
CBasePlayer:GetWeapon()
```

**Returns**
- **`EntityHandle|nil`**
The equipped weapon, or `nil` if no weapon equipped

### GetPistolUpgrades

Gets the current upgrades for the player's pistol.

```lua
CBasePlayer:GetPistolUpgrades(weapon)
```

**Parameters**

- **`weapon`** *(optional)*  
  `EntityHandle`  
  Optional weapon to check instead of the player's weapon

**Returns**
- **`PlayerPistolUpgrades[]`**
List of upgrades

### GetRapidfireUpgrades

Gets the current upgrades for the player's rapidfire.

```lua
CBasePlayer:GetRapidfireUpgrades(weapon)
```

**Parameters**

- **`weapon`** *(optional)*  
  `EntityHandle`  
  Optional weapon to check instead of the player's weapon

**Returns**
- **`PlayerRapidfireUpgrades[]`**
List of upgrades

### GetShotgunUpgrades

Gets the current upgrades for the player's shotgun.

**This will NOT return "shotgun_upgrade_quick_fire" because there is no known way to detect this!**

```lua
CBasePlayer:GetShotgunUpgrades(weapon)
```

**Parameters**

- **`weapon`** *(optional)*  
  `EntityHandle`  
  Optional weapon to check instead of the player's weapon

**Returns**
- **`PlayerShotgunUpgrades[]`**
List of upgrades

### HasWeaponUpgrade

Checks if the player has a specific weapon upgrade.

```lua
CBasePlayer:HasWeaponUpgrade(upgrade)
```

**Parameters**

- **`upgrade`**  
  `PlayerPistolUpgrades`, `PlayerRapidfireUpgrades`, `PlayerShotgunUpgrades`  
  Upgrade to check

**Returns**
- **`boolean`**
`true` if the player has the upgrade

### GetWorldForward

Gets the forward vector of the player in world space coordinates (z is zeroed).

```lua
CBasePlayer:GetWorldForward()
```

**Returns**
- **`Vector`**
Forward vector

### UpdateWeapons

Updates player weapon inventory, both removing and setting.

```lua
CBasePlayer:UpdateWeapons(removes, set)
```

**Parameters**

- **`removes`** *(optional)*  
  `(string|EntityHandle)[]`  
  List of classnames or handles to remove
- **`set`** *(optional)*  
  `string`, `EntityHandle`  
  Classname or handle to set as active weapon

**Returns**
- **`EntityHandle?`**
The handle of the newly set weapon if given and found

### RemoveWeapons

Removes weapons from the player inventory.

```lua
CBasePlayer:RemoveWeapons(weapons)
```

**Parameters**

- **`weapons`**  
  `(string|EntityHandle)[]`  
  List of classnames or handles to remove

### SetWeapon

Sets the weapon that the player is holding.

```lua
CBasePlayer:SetWeapon(weapon)
```

**Parameters**

- **`weapon`**  
  `string`, `EntityHandle`  
  Classname or handle to set as active weapon

**Returns**
- **`EntityHandle?`**
The handle of the newly set weapon if found

### UpdateWeaponsExistence

Updates the existence of weapons in [Player.Items.weapons](lua://Player.Items.weapons) by checking weapon switch entities.

This is called automatically whenever the weapon_switch event fires.

```lua
CBasePlayer:UpdateWeaponsExistence()
```

### GetWeapons

Returns [Player.Items.weapons](lua://CBasePlayer.Items) flattened into a single array.

```lua
CBasePlayer:GetWeapons()
```

**Returns**
- **`EntityHandle[]`**
List of weapon handles

### GetBackpack

Gets the invisible player backpack.

This is will return the backpack even if it has been disabled with a `info_hlvr_equip_player`.

```lua
CBasePlayer:GetBackpack()
```

**Returns**
- **`EntityHandle?`**
The backpack entity

### SetMovementEnabled

Enables or disables player movement, including teleport movement.

```lua
CBasePlayer:SetMovementEnabled(enabled, delay)
```

**Parameters**

- **`enabled`**  
  `boolean`  
  `true` if movement should be enabled.
- **`delay`** *(optional)*  
  `number`  
  Delay before movement state will be changed (default: 0)

### SetAnchorForwardAroundPlayer

Sets the forward vector of the HMD anchor while keeping the position the same relative to the player.

Normally if the player is off-center from their playspace, changing the forward vector can move the player too.

```lua
CBasePlayer:SetAnchorForwardAroundPlayer(forward)
```

**Parameters**

- **`forward`**  
  `Vector`  
  Normalized forward vector

### SetAnchorAnglesAroundPlayer

Sets the angle of the HMD anchor while keeping the position the same relative to the player.

Normally if the player is off-center from their playspace, changing the angle can move the player too.

```lua
CBasePlayer:SetAnchorAnglesAroundPlayer(angles)
```

**Parameters**

- **`angles`**  
  `QAngle`  
  New angle for the anchor

### SetAnchorOriginAroundPlayer

Sets the origin of the HMD anchor while keeping the position the same relative to the player.

This essentially moves the player by moving the anchor and can be used in instances where
setting the player origin does not work.

```lua
CBasePlayer:SetAnchorOriginAroundPlayer(pos)
```

**Parameters**

- **`pos`**  
  `Vector`  
  New origin

### SetCoughHandEnabled

Sets the enabled state of the cough handpose attached to the HMD avatar.

```lua
CBasePlayer:SetCoughHandEnabled(enabled)
```

**Parameters**

- **`enabled`**  
  `boolean`  
  `true` if the cough handpose should be enabled

## Aliases

### PlayerPistolUpgrades

| Value | Description |
| ----- | ----------- |
| `"pistol_upgrade_laser_sight"` |  |
| `"pistol_upgrade_reflex_sight"` |  |
| `"pistol_upgrade_bullet_hopper"` |  |
| `"pistol_upgrade_burst_fire"` |  |

### PlayerRapidfireUpgrades

| Value | Description |
| ----- | ----------- |
| `"rapidfire_upgrade_reflex_sight"` |  |
| `"rapidfire_upgrade_laser_right"` |  |
| `"rapidfire_upgrade_extended_magazine"` |  |

### PlayerShotgunUpgrades

| Value | Description |
| ----- | ----------- |
| `"shotgun_upgrade_autoloader"` |  |
| `"shotgun_upgrade_grenade_launcher"` |  |
| `"shotgun_upgrade_laser_sight"` |  |
| `"shotgun_upgrade_quick_fire"` |  |

### PlayerWeaponUpgrades

| Value | Description |
| ----- | ----------- |
| `PlayerPistolUpgrades` |  |
| `PlayerRapidfireUpgrades` |  |
| `PlayerShotgunUpgrades` |  |
