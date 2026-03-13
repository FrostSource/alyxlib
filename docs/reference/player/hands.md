# Player Hands

> scripts/vscripts/alyxlib/player/hands.lua

## Methods

### MergeProp

Merges an existing prop with this hand.

```lua
CPropVRHand:MergeProp(prop, hide_hand)
```

**Parameters**

- **`prop`**  
  `EntityHandle`, `string`  
  The prop handle or targetname
- **`hide_hand`**  
  `boolean`  
  `true` if the hand should turn invisible after merging

### IsHoldingItem

Checks if this hand is currently holding a prop.

```lua
CPropVRHand:IsHoldingItem()
```

**Returns**
- **`boolean`**
`true` if the hand is holding a prop

### Drop

Drops the item held by this hand.

```lua
CPropVRHand:Drop()
```

**Returns**
- **`EntityHandle?`**
The entity that was dropped

### GetGlove

Gets the rendered glove entity for this hand,
i.e. the first `hlvr_prop_renderable_glove` class.

```lua
CPropVRHand:GetGlove()
```

**Returns**
- **`EntityHandle?`**
The glove entity

### GetGrabbityGlove

Gets grabbity glove entity for this hand (the animated part on the glove).

```lua
CPropVRHand:GetGrabbityGlove()
```

**Returns**
- **`EntityHandle|nil`**
The grabbity glove

### IsButtonPressed

Checks if a digital action is on for this hand.

Note: Only reports input when headset is awake. Will still transmit input when controller loses tracking.

```lua
CPropVRHand:IsButtonPressed(digitalAction)
```

**Parameters**

- **`digitalAction`**  
  `DigitalInputAction`  
  The action to check

**Returns**
- **`boolean`**
`true` if the action is on

### GetPalmPosition

Gets the position of the palm of this hand.

Returns the palm of the glove if it exists, otherwise the palm of the invisible hand.

Sometimes the glove becomes desynchronized with the hand, such as interacting with a handpose or holding a weapon,
so this function will try to return the position of the visible palm whenever possible.

```lua
CPropVRHand:GetPalmPosition()
```

**Returns**
- **`Vector`**
The palm position

### GetHandUseController

Gets the 'hand_use_controller' entity associated with this hand.

```lua
CPropVRHand:GetHandUseController()
```

**Returns**
- **`EntityHandle`**
The hand_use_controller

### Drop

Forces the player to drop this entity if held.

```lua
CBaseEntity:Drop()
```

### Grab

Forces the player to grab this entity with a hand.

If no hand is supplied then the nearest hand will be used.

```lua
CBaseEntity:Grab(hand)
```

**Parameters**

- **`hand`** *(optional)*  
  `CPropVRHand`, `0`, `1`  
  Hand to grab with
