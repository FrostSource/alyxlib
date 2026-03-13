# Player Data

> scripts/vscripts/alyxlib/player/data.lua

## Functions

### SyncEquippedWeaponState

Syncs the equipped weapon state of the player with the given weapon classname.

If no classname is given, the weapon classname will be determined from the player's criteria.

**This is used internally on weapon switch to determine equipped weapons.**

```lua
SyncEquippedWeaponState(classname, handle)
```

**Parameters**

- **`classname`** *(optional)*  
  `string`  
  The classname of the weapon to sync
- **`handle`** *(optional)*  
  `EntityHandle`  
  The entity handle of the weapon to sync

**Returns**

- **`EntityHandle?`**  
   *`weaponHandle`*  
The entity handle of the weapon that was equipped

- **`CPropVRHand?`**  
   *`handHandle`*  
The entity handle of the hand that the weapon was equipped to

### RestorePreviouslyEquippedWeaponState

Restores the previously equipped weapon state.

```lua
RestorePreviouslyEquippedWeaponState(fireEvent)
```

**Parameters**

- **`fireEvent`** *(optional)*  
  `boolean`  
  `true` to force-fire the `weapon_switch` event

### PauseWeaponStateSync

Pauses weapon state synching. This will prevent the `weapon_switch` player event from firing.

```lua
PauseWeaponStateSync()
```

### ResumeWeaponStateSync

Resumes weapon state synching. This will allow the `weapon_switch` player event to fire.

```lua
ResumeWeaponStateSync()
```

### WeaponStateSyncPaused

Checks if weapon state synching is paused.

```lua
WeaponStateSyncPaused()
```

### GetDefaultWeaponOffset

Returns the default weapon offset for the given weapon classname and hand.

```lua
GetDefaultWeaponOffset(classname, hand)
```

**Parameters**

- **`classname`**  
  `string`  
  The classname of the weapon
- **`hand`**  
  `CPropVRHand`, `number`  
  The hand to get the offset for

**Returns**
- **`Vector`**
The default weapon offset, or `(0, 0, 0)` if not found
