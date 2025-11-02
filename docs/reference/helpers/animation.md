# Helpers Animation

> scripts/vscripts/alyxlib/helpers/animation.lua

## Methods

### CreateAnimation

Creates a new animation function.

The returned function should be called with a time value between 0 and 1.

```lua
Animation:CreateAnimation(entity, getter, setter, targetValue, curveFunc)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  Entity to animate
- **`getter`**  
  `function`  
  Function to get the current value
- **`setter`**  
  `function`  
  Function to set the new value
- **`targetValue`**  
  `T`  
  Value to animate to
- **`curveFunc`**  
  `function`  
  Animation curve

**Returns**
- **`function`**
New animation function

### Animate

Animates a value over time on an entity.

```lua
Animation:Animate(entity, getter, setter, targetValue, curveFunc, time, finishCallback)
```

**Parameters**

- **`entity`**  
  `EntityHandle`  
  Entity to animate
- **`getter`**  
  `function`  
  Function to get the current value
- **`setter`**  
  `function`  
  Function to set the new value
- **`targetValue`**  
  `T`  
  Value to animate to
- **`curveFunc`**  
  `Animation.Curves`, `function`  
  Animation curve
- **`time`**  
  `number`  
  Total time of the animation
- **`finishCallback`** *(optional)*  
  `function`  
  Callback that is called when the animation is finished

### Animate

Animates a value over time on this entity.

```lua
CBaseEntity:Animate(getter, setter, targetValue, curveFunc, time, finishCallback)
```

**Parameters**

- **`getter`**  
  `function`  
  Function to get the current value
- **`setter`**  
  `function`  
  Function to set the new value
- **`targetValue`**  
  `T`  
  Value to animate to
- **`curveFunc`**  
  `Animation.Curves`, `function`  
  Animation curve
- **`time`**  
  `number`  
  Total time of the animation
- **`finishCallback`** *(optional)*  
  `function`  
  Callback that is called when the animation is finished
