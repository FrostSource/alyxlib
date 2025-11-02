This script simplifies the tracking of button presses and releases.

## Listening to buttons

!!! note
    As of version v3.0.0 you no longer need to track buttons in order to listen to them.

Common usage is to register a callback function which will fire whenever the conditions are met.

=== "Press"

    Print a message every time the primary hand presses the grenade arm button 3 times in a row.

    ```lua
    ---@param params InputPressCallback
    Input:ListenToButton("press",
        InputHandPrimary, -- (1)!
        DIGITAL_INPUT_ARM_GRENADE, -- (3)!
        3,
        function(params) -- (2)!
            print(("Button %s pressed at %.2f on %s"):format(
                Input:GetButtonDescription(params.button),
                params.press_time,
                Input:GetHandName(params.hand)
            ))
        end)
    ```

    1. Primary and secondary hands are tracked internally and updated whenever the player changes their setting so you don't have to worry about managing this.

    2. Passing an anonymous function minimizes the amount of code you have to write. `---@param` can be defined anywhere near the function declaration for better code completion.

    3. Digital actions have a different naming style because Valve uses this style for their 'enum' values. I am aware it clashes with the rest of AlyxLib's naming convention (which is a bit all over the place as-is) but changing it would break addons relying on these names. It *is* being considered.

=== "Release"

    Print a message whenever a fire trigger has been released after being held for at least 1 second.

    ```lua
    ---@param params InputReleaseCallback
    Input:ListenToButton("release",
        InputHandBoth, -- (1)!
        DIGITAL_INPUT_FIRE,
        nil, -- (2)!
        function(params)
            if params.held_time >= 1 then
                print(("Button %s charged for %d seconds on %s"):format(
                    Input:GetButtonDescription(params.button),
                    params.held_time, 
                    Input:GetHandName(params.hand)
                ))
            end
        end)
    ```

    1. InputHandBoth (or `-1`) is a short-hand way of calling `ListenToButton` twice (for each hand). It returns **two** IDs instead of one (See [Cancelling Listeners](#cancelling-listeners)).

    2. Explicitly pass `nil` - since `"release"` doesn't use number of presses but the function requires the parameter to be filled.

Listen functions accept and optional context parameter as the final argument, which will be passed into the callback function as the first parameter - moving `params` to the second parameter. The value is usually an `EntityHandle` to allow 

```lua
---Define the entity method to be used as the callback.
---@param params InputPressCallback
function thisEntity:Callback(params)
    print(self:GetName()
            .. " pressed button "
            .. Input:GetButtonDescription(params.button)
        )
end

--Pass the entity handle as the final argument.
Input:ListenToButton("press",
    InputHandBoth,
    DIGITAL_INPUT_ARM_GRENADE,
    1,
    thisEntity.Callback,-- (1)!
    thisEntity
    )
```

1. Dot notation `.` is used here because we're giving a reference to the method function, Colon notation `:` in Lua calls the function.

!!! info "Important"
    General button request functions were removed in v3.0.0
    These might return in a future update.

## Listening to analog

Analog actions are listened to in a similar way but act on a number value instead of a boolean pressed/released state.

Analog value ranges and axes depend on the action being used. You can supply the values in different ways as shown in the examples below.

??? example "Analog Values"
    | Action              | Values                                                                                           |
    |---------------------|--------------------------------------------------------------------------------------------------|
    | Hand Curl           | X axis: `0` (uncurled) → `1` (fully curled)                                                      |
    | Trigger Pull        | X axis: `0` (unpulled) → `1` (fully pulled)                                                      |
    | Squeeze Xen Grenade | X axis: `0` (unsqueezed) → `1` (fully squeezed)                                                  |
    | Teleport Turn       | X axis: `-1` (left) → `0` (neutral) → `1` (right)<br>Y axis: `-1` (up) → `0` (neutral) → `1` (down) |
    | Continuous Turn     | X axis: `-1` (left) → `0` (neutral) → `1` (right)<br>Y axis: `-1` (up) → `0` (neutral) → `1` (down) |

See [Analog Input Actions](https://developer.valvesoftware.com/wiki/Half-Life:_Alyx_Workshop_Tools/Scripting_API#Analog_Input_Actions) on the Valve wiki for more information about analog actions.

=== "Single axis"

    Actions with only a single axis (X axis) can accept a number within its value range.

    ```lua
    ---@param InputAnalogCallback
    Input:ListenToAnalog("up",
        InputHandPrimary,
        ANALOG_INPUT_TRIGGER_PULL,
        0.5, -- (1)!
        function(params)
            print(("Analog %s went above %.2f on %s"):format(
                Input:GetAnalogDescription(params.analog),
                params.value.x, -- (2)!
                Input:GetHandName(params.hand)
            ))
        end)
    ```

    1. `ANALOG_INPUT_TRIGGER_PULL` only has one axis (x axis) so we can supply a simple number value. Here we are listening to the trigger being pulled `>= 0.5`.

    2. `value` is a `Vector` so for this example we extract the X axis because we know there is no Y axis for `ANALOG_INPUT_TRIGGER_PULL`.

=== "Dual axis"

    ```lua
    ---@param InputAnalogCallback
    Input:ListenToAnalog("up",
        InputHandPrimary,
        ANALOG_INPUT_TELEPORT_TURN,
        Vector(0.3, 0.3), -- (1)!
        function(params)
            print(("Analog %s has value %.2f on %s"):format(
                Input:GetAnalogDescription(params.analog),
                Debug.SimpleVector(params.value),
                Input:GetHandName(params.hand)
            ))
        end)

    --- ListenToAnalog also accepts tables:
    -- Array
    { 0.3, 0.3 }
    -- Keys
    { x = 0.3, y = 0.3 }
    ```

    1. In this example we are listening for the teleport turn analog (usually a thumbstick) to be moved up and to the right.

=== "Omit an axis"

    ```lua
    ---@param InputAnalogCallback
    Input:ListenToAnalog("up",
        InputHandPrimary,
        ANALOG_INPUT_TELEPORT_TURN,
        { nil, 0.7 }, -- (1)!
        function(params)
            print(("Analog %s was pressed to the right on %s"):format(
                Input:GetAnalogDescription(params.analog),
                Input:GetHandName(params.hand)
            ))
        end)
    ```

    1. Since the `Vector()` function converts any `nil` values to `0` we need to use a table to omit one of the axes. Alternatively if the axis you want to omit is `Y` you can simply pass in a number value.

!!! note
    At the moment there is no way to listen for both `"up"` and `"down"` separately on different axes for an action. If you want this behaviour you will either need two listeners cooperating with each other or write the logic in your own `think` using `Player:GetAnalogActionPositionForHand()`.

## Cancelling listeners

Listen functions return a unique ID which can be used to stop listening later.

For example the button used to perform an action might be customizable so the listener needs to be stopped and updated - you can see an example of this in the [Resin Watch addon code](https://github.com/FrostSource/resin_watch/blob/ef3a82534c2977edd010661e07e1b9ef5ec00fea/scripts/vscripts/resin_watch/classes/watch.lua#L237).

```lua
-- Dummy listener to show functionality
local id = Input:ListenToButton("press", 0, 1, 1, function() end)

-- Stop the listener using the exact ID
Input:StopListening(id)
```

If you don't want to store IDs or want a more general way to stop listeners, you can use function/context pairs to stop listeners with specific data.

=== "With context"

    You can stop any listeners that have an exact function/context pair. 

    ```lua
    -- Dummy listener using an entity method and entity context
    Input:ListenToButton("press", 0, 1, 1, thisEntity.method, thisEntity)

    Input:StopListeningCallbackContext(thisEntity.method, thisEntity) -- (1)!
    ```

    1. If `thisEntity.method` is set to a different function reference at some point this will no longer work. You must supply the same function and context values that you passed into the listener.

=== "Without context"

    Listeners without any context can still be stopped using `StopListeningCallbackContext` because function/nil is still a valid function/context pair.

    ```lua
    -- Dummy listener using an entity method and no context
    Input:ListenToButton("press", 0, 1, 1, thisEntity.method)

    Input:StopListeningCallbackContext(thisEntity.method, nil) -- (1)!
    ```

    1. If you have multiple listeners routed to this function, any of them without context will be stopped.

=== "Context only"

    If you're using anonymous functions in your listener you won't have any reference to pass into `StopListeningCallbackContext` so the function `StopListeningByContext` can be used to check only for context.

    ```lua
    -- Dummy listener using an anonymous function and entity context
    Input:ListenToButton("press", 0, 1, 1, function() end, thisEntity)

    Input:StopListeningByContext(thisEntity) -- (1)!
    ```

    1. Any listener using this context will be stopped so make sure it's what you want. This can be used to quickly stop multiple listeners at once.

!!! note
    Currently there is no way to stop a listener that uses an anonymous function and no context without saving the ID and using `Input:StopListening()`.

## Turning off

The input system is set to turn on by default. If you want to turn this behaviour off you can simply set the `AutoStart` property before the player spawns in a global script.

```lua
Input.AutoStart = false
```

You can also start and stop the system at any point.

=== "On player"

    ```lua
    -- The player MUST exist when calling Start
    Input:Start()

    -- All tracking will stop immediately,
    -- but registered listeners will still exist when you start the system again
    Input:Stop()
    ```

=== "On entity"

    ```lua
    -- Any entity handle can be used
    -- if the entity is killed the system will stop
    Input:Start(thisEntity)
    ```

!!! danger
    Stopping/starting the input system affects all addons using it. Only do this if your addon truly needs full control over the input system!
    !!! abstract ""
        Removal or sandboxing of this feature is being considered and may not exist in future versions as it does now.

## Reference

View the full reference [here](../reference/controls/input.md).
