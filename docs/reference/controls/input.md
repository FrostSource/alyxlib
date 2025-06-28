# Controls Input

> scripts/vscripts/alyxlib/controls/input.lua

## Global variables

| Hand |  |
| -------------------- | ----- |
| `InputHandBoth` | `-1` |
| `InputHandLeft` | `0` |
| `InputHandRight` | `1` |
| `InputHandPrimary` | `2` |
| `InputHandSecondary` | `3` |

## Properties

### version

```lua
Input.version = value
```

**Default value**
  `"v4.0.1"`

### AutoStart

```lua
Input.AutoStart = value
```

**Default value**
  `true`

### MultiplePressInterval

```lua
Input.MultiplePressInterval = value
```

**Default value**
  `0.35`

## Methods

### GetButtonDescription

Get the description of a given button.
Useful for debugging or hint display.

```lua
Input:GetButtonDescription(button)
```

**Parameters**

- **`button`**  
  `DigitalInputAction`  

**Returns**
- **`string`**

### GetAnalogDescription

Get the description of a given analog action.
Useful for debugging or hint display.

```lua
Input:GetAnalogDescription(analog)
```

**Parameters**

- **`analog`**  
  `DigitalInputAction`  

**Returns**
- **`string`**

### GetControllerTypeDescription

Get the description of a given controller type.

```lua
Input:GetControllerTypeDescription(controllerType)
```

**Parameters**

- **`controllerType`**  
  `ControllerType`  

**Returns**
- **`string`**

### GetHandName

Get the name of a hand.

```lua
Input:GetHandName(hand, use_operant)
```

**Parameters**

- **`hand`**  
  `CPropVRHand`, `0`, `1`  
- **`use_operant`**  
  `boolean?`  
  If true, will return primary/secondary instead of left/right

### ListenToButton

Register a callback for a specific button press/release.

```lua
Input:ListenToButton(kind, hand, button, presses, callback, context)
```

**Parameters**

- **`kind`**  
  `string`, `'"press"'`, `'"release"'`  
  The kind of button interaction.
- **`hand`**  
  `CPropVRHand`, `InputHandBoth`, `InputHandKind`, `-1`  
  The type of hand to listen on, or the hand itself.
- **`button`**  
  `NamedDigitalInputAction`, `DigitalInputAction`  
  The button to check.
- **`presses`**  
  `integer`, `nil`  
  Number of times the button must be pressed in quick succession. E.g. 2 for double click. Only applicable for `kind` press.
- **`callback`**  
  `fun(params:InputPressCallback|InputReleaseCallback)`, `fun(context:T,params:InputPressCallback|InputReleaseCallback)`  
  The function that will be called when conditions are met.
- **`context`** *(optional)*  
  `T`  
  Optional context passed into the callback as the first value. Is also used when unregistering.

### ListenToAnalog

Listen to a specific analog value reaching a certain value.

```lua
Input:ListenToAnalog(kind, hand, analogAction, analogValue, callback, context)
```

**Parameters**

- **`kind`**  
  `"up"`, `"down"`  
  `up` means listen for the value moving above `analogValue`, `down` means listen for it moving below.
- **`hand`**  
  `CPropVRHand`, `InputHandKind`  
  The hand entity or kind of hand to listen to.
- **`analogAction`**  
  `AnalogInputAction`  
  The specific analog action to listen for.
- **`analogValue`**  
  `AnalogValueType`  
  The value(s) to listen for.
- **`callback`**  
  `fun(params:InputAnalogCallback)`  
  The function that will be called when conditions are met.
- **`context`** *(optional)*  
  `any`  
  Optional context passed into the callback as the first value. Is also used when unregistering.

### ModifyAnalogCallback

Changes some data which was defined in `ListenToAnalog` for a specific ID.

```lua
Input:ModifyAnalogCallback(id, analogAction, analogValue)
```

**Parameters**

- **`id`**  
  `integer`  
  The ID of the analog event you want to modify.
- **`analogAction`** *(optional)*  
  `AnalogInputAction`  
  The new action to listen for, or nil to leave unchanged.
- **`analogValue`**  
  `AnalogValueType`  
  The new value to listen for, or nil to leave unchanged.

**Returns**
- **`boolean`**
  True if the ID was found, false otherwise.

### StopListening

Unregisters a listener with a specific ID.

```lua
Input:StopListening(id)
```

**Parameters**

- **`id`**  
  `number`  
  The number returned by ListenToButton.

### StopListeningCallbackContext

Unregisters any listeners with a specific callback/context pair.

```lua
Input:StopListeningCallbackContext(callback, context)
```

**Parameters**

- **`callback`**  
  `fun(params:InputAnalogCallback)`  
  The callback function that's listening.
- **`context`** *(optional)*  
  `any`  
  The context that was given.

### StopListeningByContext

Unregisters any listeners which have a specific context.

```lua
Input:StopListeningByContext(context)
```

**Parameters**

- **`context`**  
  `any`  
  The number returned by ListenToButton.

## Types

### InputPressCallback

| Field | Type | Description |
| ---- | ---- | ----------- |
| kind | `"press"` | The kind of event. |
| press_time | `number` | The server time at which the button was pressed. |
| hand | `CPropVRHand` | EntityHandle for the hand that pressed the button. |
| button | `DigitalInputAction` | The ID of the button that was pressed. |

### InputReleaseCallback

| Field | Type | Description |
| ---- | ---- | ----------- |
| kind | `"release"` | The kind of event. |
| release_time | `number` | The server time at which the button was released. |
| hand | `CPropVRHand` | EntityHandle for the hand that released the button. |
| button | `DigitalInputAction` | The ID of the button that was pressed. |
| held_time | `number` | Seconds the button was held for prior to being released. |

### InputAnalogCallback

| Field | Type | Description |
| ---- | ---- | ----------- |
| value | `Vector` | The vector value of the analog action at the time of detection. |
| hand | `CPropVRHand` | EntityHandle for the hand that moved the analog action. |
| analog | `AnalogInputAction` | The ID of the analog action that was moved. |

## Aliases

### NamedDigitalInputAction

| Value | Description |
| ----- | ----------- |
| `DIGITAL_INPUT_TOGGLE_MENU` |  |
| `DIGITAL_INPUT_MENU_INTERACT` |  |
| `DIGITAL_INPUT_MENU_DISMISS` |  |
| `DIGITAL_INPUT_USE` |  |
| `DIGITAL_INPUT_USE_GRIP` |  |
| `DIGITAL_INPUT_SHOW_INVENTORY` |  |
| `DIGITAL_INPUT_GRAV_GLOVE_LOCK` |  |
| `DIGITAL_INPUT_FIRE` |  |
| `DIGITAL_INPUT_ALT_FIRE` |  |
| `DIGITAL_INPUT_RELOAD` |  |
| `DIGITAL_INPUT_EJECT_MAGAZINE` |  |
| `DIGITAL_INPUT_SLIDE_RELEASE` |  |
| `DIGITAL_INPUT_OPEN_CHAMBER` |  |
| `DIGITAL_INPUT_TOGGLE_LASER_SIGHT` | = 13 |
| `DIGITAL_INPUT_TOGGLE_BURST_FIRE` |  |
| `DIGITAL_INPUT_TOGGLE_HEALTH_PEN` |  |
| `DIGITAL_INPUT_ARM_GRENADE` |  |
| `DIGITAL_INPUT_ARM_XEN_GRENADE` |  |
| `DIGITAL_INPUT_TELEPORT` |  |
| `DIGITAL_INPUT_TURN_LEFT` |  |
| `DIGITAL_INPUT_TURN_RIGHT` |  |
| `DIGITAL_INPUT_MOVE_BACK` |  |
| `DIGITAL_INPUT_WALK` |  |
| `DIGITAL_INPUT_JUMP` |  |
| `DIGITAL_INPUT_MANTLE` |  |
| `DIGITAL_INPUT_CROUCH_TOGGLE` |  |
| `DIGITAL_INPUT_STAND_TOGGLE` |  |
| `DIGITAL_INPUT_ADJUST_HEIGHT` |  |

### InputHandKind

| Value | Description |
| ----- | ----------- |
| `INPUT_HAND_LEFT` |  |
| `INPUT_HAND_RIGHT` |  |
| `INPUT_HAND_PRIMARY` |  |
| `INPUT_HAND_SECONDARY` |  |
| `0` | Left Hand. |
| `1` | Right Hand. |
| `2` | Primary Hand. |
| `3` | Secondary Hand. |

### AnalogValueType

| Value | Description |
| ----- | ----------- |
| `Vector` |  |
| `{ x:number?, y:number? }` |  |
| `{[1]:number?,[2]:number?}` |  |
| `number` |  |
