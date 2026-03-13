# Controls Gesture

> scripts/vscripts/alyxlib/controls/gesture.lua

## Properties

### version

```lua
Gesture.version = value
```

**Default value**
  `"v1.2.1"`

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
  `table`

### CurrentGesture

```lua
Gesture.CurrentGesture = value
```

**Default value**
  `table`

### PreviousGesture

```lua
Gesture.PreviousGesture = value
```

**Default value**
  `table`

### DicrepancyTolerance

```lua
Gesture.DicrepancyTolerance = value
```

## Methods

### AddGesture

Adds a new gesture to watch for.

If a finger position is `nil`, that finger isn't considered.

```lua
Gesture:AddGesture(name, index, middle, ring, pinky, thumb)
```

**Parameters**

- **`name`**  
  `string`  
  Gesture name; overwrites existing one if not unique
- **`index`**  
  `number`, `nil`  
  [0–1] range of the index finger position.
- **`middle`**  
  `number`, `nil`  
  [0–1] range of the middle finger position.
- **`ring`**  
  `number`, `nil`  
  [0–1] range of the ring finger position.
- **`pinky`**  
  `number`, `nil`  
  [0–1] range of the pinky finger position.
- **`thumb`**  
  `number`, `nil`  
  [0–1] range of the thumb finger position.

### RemoveGesture

Removes an existing gesture.

Any callbacks registered with the gesture will be unregistered.

```lua
Gesture:RemoveGesture(name)
```

**Parameters**

- **`name`**  
  `string`  
  Gesture name

### RemoveGestures

Removes a list of gestures.

```lua
Gesture:RemoveGestures(names)
```

**Parameters**

- **`names`**  
  `GestureNames[]`  
  List of gesture names

### GetGesture

Gets the current gesture name of a given hand.

E.g.

??? example
    ```lua
    local g = Gesture:GetGesture(Player.PrimaryHand)
    if g.name == "ThumbsUp" then
        do_something()
    end
    ```

```lua
Gesture:GetGesture(hand)
```

**Parameters**

- **`hand`**  
  `CPropVRHand`, `0`, `1`  
  The hand to get the gesture of

**Returns**
- **`GestureNames`**
Gesture name

### GetGestureRaw

Gets the current [0–1] finger curl values of a given hand.

```lua
Gesture:GetGestureRaw(hand)
```

**Parameters**

- **`hand`**  
  `CPropVRHand`, `0`, `1`  
  The hand to get the gesture of

**Returns**
- **`GestureTable`**
Gesture values

### RegisterCallback

Registers a callback for a specific gesture start/stop.

```lua
Gesture:RegisterCallback(kind, hand, gesture, duration, callback, context)
```

**Parameters**

- **`kind`**  
  `"start"`, `"stop"`  
  Listen for the start or stop of the gesture
- **`hand`**  
  `CPropVRHand`, `-1`, `0`, `1`  
  The hand to listen to
- **`gesture`**  
  `GestureNames`  
  The gesture to listen for
- **`duration`**  
  Not implemented
- **`callback`**  
  `function`  
  The function to call when the gesture is triggered
- **`context`** *(optional)*  
  `any`  
  Context to pass to the callback

### UnregisterCallback

Unregisters a callback function.

```lua
Gesture:UnregisterCallback(callback)
```

**Parameters**

- **`callback`**  
  `function`  
  The function to unregister

### Start

Starts the gesture system.

```lua
Gesture:Start(on)
```

**Parameters**

- **`on`**  
  `EntityHandle?`  
  Optional entity to do the tracking on

### Stop

Stops the gesture system.

```lua
Gesture:Stop()
```

## Types

### GestureTable

Gesture table.

| Field | Type | Description |
| ---- | ---- | ----------- |
| name | `GestureNames` | Gesture name |
| index | `number|nil` | [0–1] range of the index finger position |
| middle | `number|nil` | [0–1] range of the middle finger position |
| ring | `number|nil` | [0–1] range of the ring finger position |
| pinky | `number|nil` | [0–1] range of the pinky finger position |
| thumb | `number|nil` | [0–1] range of the thumb finger position |

### GESTURE_CALLBACK

| Field | Type | Description |
| ---- | ---- | ----------- |
| kind | `"start"|"stop"` | If the gesture was started or stopped |
| name | `GestureNames` | The name of the gesture performed |
| hand | `CPropVRHand` | The hand the gesture was performed on |
| time | `number` | Server time the gesture occurred |

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
