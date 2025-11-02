# Player Events

> scripts/vscripts/alyxlib/player/events.lua

## Functions

### ListenToPlayerEvent

Register a callback function with for a player event.

```lua
ListenToPlayerEvent(event, callback, context)
```

**Parameters**

- **`event`**  
  `PLAYER_EVENTS_ALL`  
  Name of the event
- **`callback`**  
  `function`  
  The function that will be called when the event is fired
- **`context`** *(optional)*  
  `table`  
  Optional: The context to pass to the function as `self`. If omitted the context will not passed to the callback.

**Returns**
- **`integer`** *`eventID`*
ID used to unregister

### StopListeningToPlayerEvent

Unregisters a callback with a name.

```lua
StopListeningToPlayerEvent(eventID)
```

**Parameters**

- **`eventID`**  
  `integer`  

### ListenToEntityPickup

Listen to the pickup of a specific entity.

```lua
ListenToEntityPickup(entity, callback, context)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  The entity to listen for
- **`callback`**  
  `function`  
  The function that will be called when the entity is picked up
- **`context`** *(optional)*  
  `any`  
  Optional context passed into the callback as the first value

**Returns**
- **`integer`**
ID used to unregister

### StopListeningToEntityPickup

Stop listening to an entity pickup

```lua
StopListeningToEntityPickup(eventID)
```

**Parameters**

- **`eventID`**  
  `integer`  
  ID returned from [ListenToEntityPickup](lua://ListenToEntityPickup)

## Types

### PlayerEventPlayerActivate

> **Inherits from:** `GameEventPlayerActivate`

The player event that fires after the player spawned and activated.

| Field | Type | Description |
| ---- | ---- | ----------- |
| player | `CBasePlayer` | The entity handle of the player. |
| type | `"spawn"|"load"|"transition"` | Type of player activate. |

### PlayerEventVRPlayerReady

> **Inherits from:** `PlayerEventPlayerActivate`

| Field | Type | Description |
| ---- | ---- | ----------- |
| hmd_avatar | `CPropHMDAvatar` | The hmd avatar entity handle. |

### PlayerEventItemPickup

> **Inherits from:** `GameEventItemPickup`

| Field | Type | Description |
| ---- | ---- | ----------- |
| item | `EntityHandle` | The entity handle of the item that was picked up. |
| item_class | `string` | Classname of the entity that was picked up. |
| hand | `CPropVRHand` | The entity handle of the hand that picked up the item. |
| otherhand | `CPropVRHand` | The entity handle of the opposite hand. |

### PlayerEventItemReleased

> **Inherits from:** `GameEventItemReleased`

| Field | Type | Description |
| ---- | ---- | ----------- |
| item | `EntityHandle` | The entity handle of the item that was dropped. |
| item_class | `string` | Classname of the entity that was dropped. |
| hand | `CPropVRHand` | The entity handle of the hand that dropped the item. |
| otherhand | `CPropVRHand` | The entity handle of the opposite hand. |

### PlayerEventPrimaryHandChanged

> **Inherits from:** `GameEventPrimaryHandChanged`

| Field | Type | Description |
| ---- | ---- | ----------- |
| is_primary_left | `boolean` |  |

### PlayerEventPlayerDropAmmoInBackpack

> **Inherits from:** `GameEventBase`

| Field | Type | Description |
| ---- | ---- | ----------- |
| ammotype | `"Pistol"|"SMG1"|"Buckshot"|"AlyxGun"` | Type of ammo that was stored. |
| ammo_amount | `0|1|2|3|4` | Amount of ammo stored for the given type (1 clip, 2 shells). |

### PlayerEventPlayerRetrievedBackpackClip

> **Inherits from:** `GameEventBase`

| Field | Type | Description |
| ---- | ---- | ----------- |
| ammotype | `"Pistol"|"SMG1"|"Buckshot"|"AlyxGun"` | Type of ammo that was retrieved. |
| ammo_amount | `integer` | Amount of ammo retrieved for the given type (1 clip, 2 shells). |

### PlayerEventPlayerStoredItemInItemholder

> **Inherits from:** `GameEventPlayerStoredItemInItemholder`

| Field | Type | Description |
| ---- | ---- | ----------- |
| item | `EntityHandle` | The entity handle of the item that stored. |
| item_class | `string` | Classname of the entity that was stored. |
| hand | `CPropVRHand` | Hand that the entity was stored in. |

### PlayerEventPlayerRemovedItemFromItemholder

> **Inherits from:** `GameEventPlayerRemovedItemFromItemholder`

| Field | Type | Description |
| ---- | ---- | ----------- |
| item | `EntityHandle` | The entity handle of the item that removed. |
| item_class | `string` | Classname of the entity that was removed. |
| hand | `CPropVRHand` | Hand that the entity was removed form. |

### PlayerEventPlayerDropResinInBackpack

> **Inherits from:** `GameEventPlayerDropResinInBackpack`

| Field | Type | Description |
| ---- | ---- | ----------- |
| resin_ent | `EntityHandle?` | The resin entity being dropped into the backpack. |

### PlayerEventWeaponSwitch

> **Inherits from:** `GameEventWeaponSwitch`

| Field | Type | Description |
| ---- | ---- | ----------- |
| item | `EntityHandle|nil` | The handle of the weapon being switched to or nil if no weapon. |
| item_class | `string` | Classname of the entity that was switched to. |
| hand | `CPropVRHand` | Hand that the entity was switched to. |

## Aliases

### PLAYER_EVENTS_ALL

| Value | Description |
| ----- | ----------- |
| `"novr_player"` |  |
| `"player_activate"` |  |
| `"vr_player_ready"` |  |
| `"item_pickup"` |  |
| `"item_released"` |  |
| `"primary_hand_changed"` |  |
| `"player_drop_ammo_in_backpack"` |  |
| `"player_retrieved_backpack_clip"` |  |
| `"player_stored_item_in_itemholder"` |  |
| `"player_removed_item_from_itemholder"` |  |
| `"player_drop_resin_in_backpack"` |  |
| `"weapon_switch"` |  |

### PlayerEventNoVRPlayer

| Value | Description |
| ----- | ----------- |
| `PlayerEventPlayerActivate` |  |
