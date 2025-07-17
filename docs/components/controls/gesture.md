## gesture.lua

> Provides a system for tracking simple hand poses and gestures.

Gestures are added with a unique name and a [0-1] curl range for each finger, or nil if the finger shouldn't be taken into consideration.

``` lua
Gesture:AddGesture("AllFingersNoThumb", 1, 1, 1, 1, 0)
-- asdaf (1)
```

1. :man_raising_hand: I'm a code annotation! I can contain `code`, __formatted
    text__, images, ... basically anything that can be written in Markdown.

Gestures can be removed, including built-in gestures, can be removed to lower a small amount of processing cost, however this might produce undesirable results for other mods using the same gesture script if you plan to use a system like Scalable Init.

```lua
Gesture:RemoveGestures({"OpenHand", "ClosedFist"})
```

Recommended usage for tracking gestures is to register a callback function with a given set of conditions:

```lua
Gesture:RegisterCallback("start", 1, "ThumbsUp", nil, function(gesture)
    ---@cast gesture GESTURE_CALLBACK
    print(("Player made %s gesture at %d"):format(gesture.name, gesture.time))
end)
```

Generic gesture functions exist for all other times:

```lua
local g = Gesture:GetGesture(Player.PrimaryHand)
if g.name == "ThumbsUp" then
    print("Player did thumbs up")
end

local g = Gesture:GetGestureRaw(Player.PrimaryHand)
if g.index > 0.5 then
    print("Player has index more than half extended")
end
```