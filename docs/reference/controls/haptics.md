# Controls Haptics

> scripts/vscripts/alyxlib/controls/haptics.lua

## Methods

### Fire

Start the haptic sequence on a given hand.

```lua
HapticSequence:Fire(hand)
```

**Parameters**

- **`hand`**  
  `CPropVRHand`, `number`  
  The hand entity handle or ID number.

## Functions

### HapticSequence

Create a new haptic sequence.

```lua
HapticSequence(duration, pulseStrength, pulseInterval)
```

**Parameters**

- **`duration`**  
  `number`  
  Length of the sequence in seconds.
- **`pulseStrength`**  
  `number`  
  Strength of the vibration in range [0-1].
- **`pulseInterval`**  
  `number`  
  Interval between each vibration during the sequence, in seconds.

**Returns**
- **`HapticSequence`**
