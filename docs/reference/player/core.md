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
  `{}`

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
  `{`

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

Force the player to drop an entity if held.

```lua
CBasePlayer:DropByHandle(handle)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
  Handle of the entity to drop

### DropLeftHand

Force the player to drop any item held in their left hand.

```lua
CBasePlayer:DropLeftHand()
```

### DropRightHand

Force the player to drop any item held in their right hand.

```lua
CBasePlayer:DropRightHand()
```

### DropPrimaryHand

Force the player to drop any item held in their primary hand.

```lua
CBasePlayer:DropPrimaryHand()
```

### DropSecondaryHand

Force the player to drop any item held in their secondary/off hand.

```lua
CBasePlayer:DropSecondaryHand()
```

### DropCaller

Force the player to drop the caller entity if held.

```lua
CBasePlayer:DropCaller(data)
```

**Parameters**

- **`data`**  
  `IOParams`  

### DropActivator

Force the player to drop the activator entity if held.

```lua
CBasePlayer:DropActivator(data)
```

**Parameters**

- **`data`**  
  `IOParams`  

### GrabByHandle

Force the player to grab `handle` with `hand`.

```lua
CBasePlayer:GrabByHandle(handle, hand)
```

**Parameters**

- **`handle`**  
  `EntityHandle`  
- **`hand`** *(optional)*  
  `CPropVRHand`, `0`, `1`  

### GrabCaller

Force the player to grab the caller entity.

```lua
CBasePlayer:GrabCaller(data)
```

**Parameters**

- **`data`**  
  `IOParams`  

### GrabActivator

Force the player to grab the activator entity.

```lua
CBasePlayer:GrabActivator(data)
```

**Parameters**

- **`data`**  
  `IOParams`  

!!! exposed "Exposed To Hammer as `GrabActivator` [:material-link:](PUT LINK HERE)"

### GetMoveType

Get VR movement type.

```lua
CBasePlayer:GetMoveType()
```

**Returns**
- **`PlayerMoveType`**

### SetMoveType

Sets the VR movement type.

```lua
CBasePlayer:SetMoveType(movetype)
```

**Parameters**

- **`movetype`**  
  `PlayerMoveType`  

### GetLookingAt

Returns the entity the player is looking at directly.

```lua
CBasePlayer:GetLookingAt(maxDistance)
```

**Parameters**

- **`maxDistance`** *(optional)*  
  `number`  
  Max distance the trace can search.

**Returns**
- **`EntityHandle?`**

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
- **`rapidfire_ammo`** *(optional)*  
  `number`  
- **`shotgun_ammo`** *(optional)*  
  `number`  
- **`resin`** *(optional)*  
  `number`  

### SetResources

Sets resources for the player.

```lua
CBasePlayer:SetResources(pistol_ammo, rapidfire_ammo, shotgun_ammo, resin)
```

**Parameters**

- **`pistol_ammo`** *(optional)*  
  `number`  
- **`rapidfire_ammo`** *(optional)*  
  `number`  
- **`shotgun_ammo`** *(optional)*  
  `number`  
- **`resin`** *(optional)*  
  `number`  

### SetItems

Set the items that player has manually.
This is purely for scripting and does not modify the actual items the player has in game.
Use `Player:AddResources` to modify in-game items.

```lua
CBasePlayer:SetItems(energygun_ammo, generic_pistol_ammo, rapidfire_ammo, shotgun_ammo, frag_grenades, xen_grenades, healthpens, resin)
```

**Parameters**

- **`energygun_ammo`** *(optional)*  
  `integer`  
- **`generic_pistol_ammo`** *(optional)*  
  `integer`  
- **`rapidfire_ammo`** *(optional)*  
  `integer`  
- **`shotgun_ammo`** *(optional)*  
  `integer`  
- **`frag_grenades`** *(optional)*  
  `integer`  
- **`xen_grenades`** *(optional)*  
  `integer`  
- **`healthpens`** *(optional)*  
  `integer`  
- **`resin`** *(optional)*  
  `integer`  

### AddPistolAmmo

Add pistol ammo to the player.

```lua
CBasePlayer:AddPistolAmmo(amount)
```

**Parameters**

- **`amount`**  
  `number`  

### AddShotgunAmmo

Add shotgun ammo to the player.

```lua
CBasePlayer:AddShotgunAmmo(amount)
```

**Parameters**

- **`amount`**  
  `number`  

### AddRapidfireAmmo

Add rapidfire ammo to the player.

```lua
CBasePlayer:AddRapidfireAmmo(amount)
```

**Parameters**

- **`amount`**  
  `number`  

### AddResin

Add resin to the player.

```lua
CBasePlayer:AddResin(amount)
```

**Parameters**

- **`amount`**  
  `number`  

### GetImmediateItems

Gets the items currently held or in wrist pockets.

```lua
CBasePlayer:GetImmediateItems()
```

**Returns**
- **`EntityHandle[]`**

### GetGrenades

Gets the grenades currently held or in wrist pockets.

Use `#Player:GetGrenades()` to get number of grenades player has access to.

```lua
CBasePlayer:GetGrenades()
```

**Returns**
- **`EntityHandle[]`**

### GetHealthPens

Gets the health pens currently held or in wrist pockets.

Use `#Player:GetHealthPens()` to get number of health pens player has access to.

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
  The hand handle or index.
- **`prop`**  
  `EntityHandle`, `string`  
  The prop handle or targetname.
- **`hide_hand`**  
  `boolean`  
  If the hand should turn invisible after merging.

### HasWeaponEquipped

Return if the player has a gun equipped.

```lua
CBasePlayer:HasWeaponEquipped()
```

**Returns**
- **`boolean`**

### GetCurrentWeaponReserves

Get the amount of ammo stored in the backpack for the currently equipped weapon.

This is not accurate if ammo was given through special means like info_hlvr_equip_player.

```lua
CBasePlayer:GetCurrentWeaponReserves()
```

**Returns**
- **`number`**
  The amount of ammo, or 0 if no weapon equipped

### HasItemHolder

Player has item holder equipped.

```lua
CBasePlayer:HasItemHolder()
```

**Returns**
- **`boolean`**

### HasGrabbityGloves

Player has grabbity gloves equipped.

```lua
CBasePlayer:HasGrabbityGloves()
```

**Returns**
- **`boolean`**

### GetFlashlight

```lua
CBasePlayer:GetFlashlight()
```

### GetFlashlightPointedAt

Get the first entity the flashlight is pointed at (if the flashlight exists).
If flashlight does not exist, both returns will be `nil`.

```lua
CBasePlayer:GetFlashlightPointedAt(maxDistance)
```

**Parameters**

- **`maxDistance`**  
  `number`  
  Max tracing distance, default is 2048.

**Returns**
- **`EntityHandle|nil`**
  The entity that was hit, or nil.
- **`Vector|nil`**
  The position the trace hit, regardless of entity found.

### GetResin

Gets the current resin from the player.
This is can be more accurate than `Player.Items.resin`
Calling this will update `Player.Items.resin`

```lua
CBasePlayer:GetResin()
```

**Returns**
- **`number`**

### IsHolding

Gets if player is holding an entity in either hand.

```lua
CBasePlayer:IsHolding(entity)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  

**Returns**
- **`boolean`**

### GetWeapon

Get the entity handle of the currently equipped weapon/item.
If nothing is equipped this will return the primary hand entity.

```lua
CBasePlayer:GetWeapon()
```

**Returns**
- **`EntityHandle|nil`**

### GetPistolUpgrades

Get the current upgrades for the player's pistol.

```lua
CBasePlayer:GetPistolUpgrades(weapon)
```

**Parameters**

- **`weapon`** *(optional)*  
  `EntityHandle`  
  Optional weapon to check instead of the player's weapon.

**Returns**
- **`PlayerPistolUpgrades[]`**

### GetRapidfireUpgrades

Get the current upgrades for the player's rapidfire.

```lua
CBasePlayer:GetRapidfireUpgrades(weapon)
```

**Parameters**

- **`weapon`** *(optional)*  
  `EntityHandle`  
  Optional weapon to check instead of the player's weapon.

**Returns**
- **`PlayerRapidfireUpgrades[]`**

### GetShotgunUpgrades

Get the current upgrades for the player's shotgun.

**This will NOT return "shotgun_upgrade_quick_fire" because there is no known way to detect this!**

```lua
CBasePlayer:GetShotgunUpgrades(weapon)
```

**Parameters**

- **`weapon`** *(optional)*  
  `EntityHandle`  
  Optional weapon to check instead of the player's weapon.

**Returns**
- **`PlayerShotgunUpgrades[]`**

### HasWeaponUpgrade

Check if the player has a specific weapon upgrade.

```lua
CBasePlayer:HasWeaponUpgrade(upgrade)
```

**Parameters**

- **`upgrade`**  
  `PlayerPistolUpgrades`, `PlayerRapidfireUpgrades`, `PlayerShotgunUpgrades`  

**Returns**
- **`boolean`**

### GetWorldForward

Get the forward vector of the player in world space coordinates (z is zeroed).

```lua
CBasePlayer:GetWorldForward()
```

**Returns**
- **`Vector`**

### UpdateWeapons

Update player weapon inventory, both removing and setting.

```lua
CBasePlayer:UpdateWeapons(removes, set)
```

**Parameters**

- **`removes`** *(optional)*  
  `(string|EntityHandle)[]`  
  List of classnames or handles to remove.
- **`set`** *(optional)*  
  `string`, `EntityHandle`  
  Classname or handle to set as active weapon.

**Returns**
- **`EntityHandle?`**
  The handle of the newly set weapon if given and found.

### RemoveWeapons

Remove weapons from the player inventory.

```lua
CBasePlayer:RemoveWeapons(weapons)
```

**Parameters**

- **`weapons`**  
  `(string|EntityHandle)[]`  
  List of classnames or handles to remove.

### SetWeapon

Set the weapon that the player is holding.

```lua
CBasePlayer:SetWeapon(weapon)
```

**Parameters**

- **`weapon`**  
  `string`, `EntityHandle`  
  Classname or handle to set as active weapon.

**Returns**
- **`EntityHandle?`**
  The handle of the newly set weapon if found.

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

### GetBackpack

Get the invisible player backpack.
This is will return the backpack even if it has been disabled with a `info_hlvr_equip_player`.

```lua
CBasePlayer:GetBackpack()
```

**Returns**
- **`EntityHandle?`**

### SetMovementEnabled

Enable or disable player movement. Including teleport movement.

```lua
CBasePlayer:SetMovementEnabled(enabled, delay)
```

**Parameters**

- **`enabled`**  
  `boolean`  
  True if movement should be enabled.
- **`delay`** *(optional)*  
  `number`  
  Optional delay for movement state will be changed

### SetAnchorForwardAroundPlayer

Sets the forward vector of the HMD anchor while keeping the position the same relative to the player.

Normally if the player is off-center when changing the forward vector the player may appear to move too.

```lua
CBasePlayer:SetAnchorForwardAroundPlayer(forward)
```

**Parameters**

- **`forward`**  
  `Vector`  
  Normalized forward vector

### SetAnchorAnglesAroundPlayer

Sets the angle of the HMD anchor while keeping the position the same relative to the player.

Normally if the player is off-center when changing the angle the player may appear to move too.

```lua
CBasePlayer:SetAnchorAnglesAroundPlayer(angles)
```

**Parameters**

- **`angles`**  
  `QAngle`  
  New angle of the anchor

### SetAnchorOriginAroundPlayer

Sets the origin of the HMD anchor while keeping the position the same relative to the player.

This essentially moves the player by moving the anchor and can be used in instances where setting the player origin does not work.

```lua
CBasePlayer:SetAnchorOriginAroundPlayer(pos)
```

**Parameters**

- **`pos`**  
  `Vector`  

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
