## haptics.lua

> Haptic sequences allow for more complex vibrations than the one-shot pulses that the base API provides.

A HapticSequence is created with a total duration, vibration strength, and pulse interval. The following sequence lasts for 1 second and vibrates at half strength every 10th of a second. This will pulse 10 times in total.

```lua
local hapticSeq = HapticSequence(1, 0.5, 0.1)
```

After creating the sequence we can fire it at any point. If the sequence is fired again before finishing it will cancel the currently running sequence and start again.

```lua
hapticSeq:Fire()
```