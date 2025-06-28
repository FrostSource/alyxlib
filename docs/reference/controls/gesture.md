# Controls Gesture

> scripts/vscripts/alyxlib/controls/gesture.lua

## Properties

### version

```lua
Gesture.version = value
```

**Default value**
  `"v1.2.0"`

### AutoStart

```lua
Gesture.AutoStart = value
```

**Default value**
  `false`

### DebugEnabled

```lua
Gesture.DebugEnabled = value
```

**Default value**
  `false`

### Duration

```lua
Gesture.Duration = value
```

**Default value**
  `0.3`

### Gestures

```lua
Gesture.Gestures = value
```

**Default value**
  `{}`

### CurrentGesture

```lua
Gesture.CurrentGesture = value
```

**Default value**
  `{`

### PreviousGesture

```lua
Gesture.PreviousGesture = value
```

**Default value**
  `{`

### DicrepancyTolerance

```lua
Gesture.DicrepancyTolerance = value
```

## Methods

### AddGesture

Add a new gesture to watch for.

If a finger position is nil then the finger isn't taken into consideration.

```lua
Gesture:AddGesture(name, index, middle, ring, pinky, thumb)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the gesture. If not unique it will overwrite the previous gesture with this name.
- **`index`**  
  `number`, `nil`  
  [0-1] range of the index finger position.
- **`middle`**  
  `number`, `nil`  
  [0-1] range of the middle finger position.
- **`ring`**  
  `number`, `nil`  
  [0-1] range of the ring finger position.
- **`pinky`**  
  `number`, `nil`  
  [0-1] range of the pinky finger position.
- **`thumb`**  
  `number`, `nil`  
  [0-1] range of the thumb finger position.

### RemoveGesture

Remove an existing gesture.

Any callbacks registered with the gesture will be unregistered.

```lua
Gesture:RemoveGesture(name)
```

**Parameters**

- **`name`**  
  `string`  
  Name of the gesture.

### RemoveGestures

Remove a list of gestures.

```lua
Gesture:RemoveGestures(names)
```

**Parameters**

- **`names`**  
  `GestureNames[]`  

### GetGesture

Gets the current gesture name of a given hand.

E.g.

`local g = Gesture:GetGesture(Player.PrimaryHand)`
if g.name == "ThumbsUp" then
do_something()
end

```lua
Gesture:GetGesture(hand)
```

**Parameters**

- **`hand`**  
  `CPropVRHand`, `0`, `1`  

**Returns**
- **`GestureNames`**

### GetGestureRaw

Gets the current [0-1] finger curl values of a given hand.

```lua
Gesture:GetGestureRaw(hand)
```

**Parameters**

- **`hand`**  
  `CPropVRHand`, `0`, `1`  

**Returns**
- **`GestureTable`**

### RegisterCallback

Register a callback for a specific gesture start/stop.

```lua
Gesture:RegisterCallback(kind, hand, gesture, duration, callback, context)
```

**Parameters**

- **`kind`**  
  `"start"`, `"stop"`  
  If the callback is registered for gesture start or stop.
- **`hand`**  
  `CPropVRHand`, `-1`, `0`, `1`  
  The ID of the hand to register for (-1 means both).
- **`gesture`**  
  `GestureNames`  
  Name of the gesture.
- **`duration`**  
  Not implemented
- **`callback`**  
  `function`  
  The function that will be called when conditions are met.
- **`context`** *(optional)*  
  `any`  

### UnregisterCallback

Unregister a callback function.

```lua
Gesture:UnregisterCallback(callback)
```

**Parameters**

- **`callback`**  
  `function`  

### Start

Starts the gesture system.

```lua
Gesture:Start(on)
```

**Parameters**

- **`on`**  
  `EntityHandle?`  
  Optional entity to do the tracking on. This is the player by default.

### Stop

Stops the gesture system.

```lua
Gesture:Stop()
```

## Types

### GestureTable

| Field | Type | Description |
| ---- | ---- | ----------- |
| name | `GestureNames` | Name of the gesture. |
| index | `number|nil` | [0-1] range of the index finger position. |
| middle | `number|nil` | [0-1] range of the middle finger position. |
| ring | `number|nil` | [0-1] range of the ring finger position. |
| pinky | `number|nil` | [0-1] range of the pinky finger position. |
| thumb | `number|nil` | [0-1] range of the thumb finger position. |

### GESTURE_CALLBACK

| Field | Type | Description |
| ---- | ---- | ----------- |
| kind | `"start"|"stop"` | If the gesture was started or stopped. |
| name | `GestureNames` | The name of the gesture performed. |
| hand | `CPropVRHand` | The hand the gesture was performed on. |
| time | `number` | Server time the gesture occurred. |

## Aliases

### GestureNames

| Value | Description |
| ----- | ----------- |
| `string` |  |
| `"OpenHand"` |  |
| `"ClosedFist"` |  |
| `"ThumbsUp"` |  |
| `"DevilHorns"` |  |
| `"Point"` |  |
| `"FingerGun"` |  |
| `"PinkyOut"` |  |
| `"Shaka"` |  |
| `"MiddleFinger"` |  |
| `"TheShocker"` |  |
| `"Peace"` |  |
