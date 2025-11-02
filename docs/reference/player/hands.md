# Player Hands

> scripts/vscripts/alyxlib/player/hands.lua

## Methods

### MergeProp

Merge an existing prop with this hand.

```lua
CPropVRHand:MergeProp(prop, hide_hand)
```

**Parameters**

- **`prop`**  
  `EntityHandle`, `string`  
  The prop handle or targetname.
- **`hide_hand`**  
  `boolean`  
  If the hand should turn invisible after merging.

### IsHoldingItem

Return true if this hand is currently holding a prop.

```lua
CPropVRHand:IsHoldingItem()
```

**Returns**
- **`boolean`**

### Drop

Drop the item held by this hand.

```lua
CPropVRHand:Drop()
```

**Returns**
- **`EntityHandle?`**

### GetGlove

Get the rendered glove entity for this hand, i.e. the first `hlvr_prop_renderable_glove` class.

```lua
CPropVRHand:GetGlove()
```

**Returns**
- **`EntityHandle|nil`**

### GetGrabbityGlove

Get the entity for this hands grabbity glove (the animated part on the glove).

```lua
CPropVRHand:GetGrabbityGlove()
```

**Returns**
- **`EntityHandle|nil`**

### IsButtonPressed

Returns true if the digital action is on for this. See `ENUM_DIGITAL_INPUT_ACTIONS` for action index values.
Note: Only reports input when headset is awake. Will still transmit input when controller loses tracking.

```lua
CPropVRHand:IsButtonPressed(digitalAction)
```

**Parameters**

- **`digitalAction`**  
  `DigitalInputAction`  

**Returns**
- **`boolean`**

### GetPalmPosition

Get the position of the palm of this hand.

Returns the palm of the glove if it exists, otherwise the palm of the invisible hand.
Sometimes the glove becomes desynchronized with the hand, such as interacting with a handpose or holding a weapon,
so this function will try to return the position of the visible palm whenever possible.

```lua
CPropVRHand:GetPalmPosition()
```

**Returns**
- **`Vector`**

### GetHandUseController

Gets the 'hand_use_controller' entity associated with this hand.

```lua
CPropVRHand:GetHandUseController()
```

**Returns**
- **`EntityHandle`**

### Drop

Forces the player to drop this entity if held.

```lua
CBaseEntity:Drop(self)
```

**Parameters**

- **`self`**  
  `CBaseEntity`  

### Grab

Force the player to grab this entity with a hand.
If no hand is supplied then the nearest hand will be used.

```lua
CBaseEntity:Grab(hand)
```

**Parameters**

- **`hand`** *(optional)*  
  `CPropVRHand`, `0`, `1`  
