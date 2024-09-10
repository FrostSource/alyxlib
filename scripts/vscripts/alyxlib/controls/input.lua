--[[
    v1.3.0
    https://github.com/FrostSource/alyxlib

    Simplifies the tracking of button presses/releases. This system will automatically
    start when the player spawns unless told not to before the player spawns.

    ```lua
    Input.AutoStart = false
    ```

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:

    ```lua
    require "alyxlib.controls.input"
    ```

    ======================================== Usage ========================================

    The system can be told to track all buttons or individual buttons for those who are
    performant conscious:

    ```lua
    Input:TrackAllButtons()
    Input:TrackButtons({7, 17})
    ```

    Common usage is to register a callback function which will fire whenever the passed
    conditions are met. `press`/`release` can be individually registered, followed by which
    hand to check (or -1 for both), the digital button to check, number of presses
    (if `press` kind), and the function to call.

    ```lua
    Input:RegisterCallback("press", 1, 7, 1, function(data)
        ---@cast data INPUT_PRESS_CALLBACK
        print(("Button %s pressed at %.2f on %s"):format(
            Input:GetButtonDescription(data.button),
            data.press_time,
            Input:GetHandName(data.hand)
        ))
    end)
    ```
    
    ```lua
    Input:RegisterCallback("release", -1, 17, nil, function(data)
        ---@cast data INPUT_RELEASE_CALLBACK
        if data.held_time >= 5 then
            print(("Button %s charged for %d seconds on %s"):format(
                Input:GetButtonDescription(data.button),
                data.held_time, 
                Input:GetHandName(data.hand)
            ))
        end
    end)
    ```

    Other general use functions exist for checking presses and are extended to the hand class for ease of use:

    ```lua
    if Player.PrimaryHand:Pressed(3) then end
    if Player.PrimaryHand:Released(3) then end
    if Player.PrimaryHand:Button(3) then end
    if Player.PrimaryHand:ButtonTime(3) >= 5 then end
    ```

]]
---@TODO: Allow context to be passed to the callbacks.

---
---The input class simplifies button tracking.
---
Input = {}
Input.__index = Input
Input.version = "v1.3.0"

---
---If the input system should start automatically on player spawn.
---Set this to false soon after require to stop it.
---
Input.AutoStart = true

---
---Number of seconds after a press in which it can still be detected as a single press.
---Set this to 0 if your think functions use a 0 return.
---
---This is not used with callback events.
---
---@type number
Input.PressedTolerance = 0.5

---
---Number of seconds after a released in which it can still be detected as a single release.
---Set this to 0 if your think functions use a 0 return.
---
---This is not used with callback events.
---
---@type number
Input.ReleasedTolerance = 0.5

---
---Number of seconds after a press in which another press can be considered a double/triple (etc) press.
---
---@type number
Input.MultiplePressInterval = 0.35

---Example layout:
---{
---    -- Button literal
---    3 =
---    {
---        -- Hand ID
---        0 =
---        {
---            -- if the button is held
---            is_held = false,
---            -- Time() when the button was pressed
---            press_time = 0,
---            -- Time() when the button was released
---            release_time = 0,
---
---            press_callbacks = {}
---            release_callbacks = {}
---        }
---    }
---    
---}

-- ---@type table<integer, table>
---@type table<integer, table<integer, InputButtonTable>>
local trackedButtons = {}

---@class InputButtonTable
---@field is_held boolean
---@field press_time number
---@field prev_press_time number
---@field release_time number
---@field press_locked boolean
---@field release_locked boolean
---@field multiple_press_count number

---@class InputCallbackTable
---@field presses integer
---@field func function
---@field context any # Value passed into first argument of callback.
---@field handkind InputHandKind # Left, right, primary, secondary.
---@field actualhandid 0|1 # This needs to be updated whenver hands change.
---@field button ENUM_DIGITAL_INPUT_ACTIONS # The button for this event.

---@class AnalogCallbackTable
---@field analog ENUM_ANALOG_INPUT_ACTIONS
---@field value { x: number?, y: number? }
---@field checkGreaterThan boolean
---@field func function
---@field context any # Value passed into first argument of callback.
---@field handkind InputHandKind # Left, right, primary, secondary.
---@field actualhandid 0|1 # This needs to be updated whenver hands change.
---@field literalhandtype 0|1 # The literal value of the hand which is usually the opposite of Id

---@type table<integer, InputCallbackTable>
local pressCallbacks = {}

---@type table<integer, InputCallbackTable>
local releaseCallbacks = {}

---@type table<integer, AnalogCallbackTable>
local analogCallbacks = {}

local callbackId = 0

local function createButtonTable()
    return {
        is_held = false,
        press_time = -1,
        prev_press_time = -1,
        -- Must not be -1, to avoid triggering all buttons on start
        release_time = 0,
        press_locked = false,
        release_locked = false,
        multiple_press_count = 0,
    }
end

---
---Set a button to be tracked.
---
---@param button ENUM_DIGITAL_INPUT_ACTIONS
function Input:TrackButton(button)
    if trackedButtons[button] ~= nil then
        warn("Button", button, "is already tracked!")
        return
    end

    trackedButtons[button] = {
        [0] = createButtonTable(), -- Left
        [1] = createButtonTable(), -- Right
    }
end

---
---Set an array of buttons to be tracked.
---
---@param buttons ENUM_DIGITAL_INPUT_ACTIONS[]
function Input:TrackButtons(buttons)
    for _, button in ipairs(buttons) do
        self:TrackButton(button)
    end
end

---
---Stop all buttons from being tracked.
---
function Input:StopTrackingAllButtons()
    trackedButtons = {}
    pressCallbacks = {}
    releaseCallbacks = {}
    callbackId = 0
end

---
---Set all buttons to be tracked.
---
function Input:TrackAllButtons()
    self:TrackButtons({
        0,1,2,3,4,5,6,7,8,9,10,
        11,12,13,14,15,16,17,18,19,
        20,21,22,23,24,25,26,27
    })
end

---
---Stop tracking a button.
---
---@param button ENUM_DIGITAL_INPUT_ACTIONS
function Input:StopTrackingButton(button)
    trackedButtons[button] = nil
    pressCallbacks[button] = nil
    releaseCallbacks[button] = nil
end

---
---Stop tracking an array of buttons.
---
---@param buttons ENUM_DIGITAL_INPUT_ACTIONS[]
function Input:StopTrackingButtons(buttons)
    for _,button in ipairs(buttons) do
        self:StopTrackingButton(button)
    end
end


local currentPrimaryHandId = 1
local currentSecondaryHandId = 0

---@alias InputHandKind
---| 0  # Left Hand.
---| 1  # Right Hand.
---| 2  # Primary Hand.
---| 3  # Secondary Hand.

---Convert a hand kind integer to a hand Id integer.
---@param kind InputHandKind
---@return 0|1
local function convertHandKindToHandId(kind)
    if kind == 2 then return currentPrimaryHandId
    elseif kind == 3 then return currentSecondaryHandId
    else
        return kind
    end
end

---Sets the current primary hand that the player is using.
---@param primary 0|1 # 0 = Left, 1 = Right
local function updatePrimaryHandId(primary)
    currentPrimaryHandId = primary
    currentSecondaryHandId = 1 - primary

    for _id, tbl in pairs(pressCallbacks) do
        tbl.actualhandid = convertHandKindToHandId(tbl.handkind)
    end

    for _id, tbl in pairs(releaseCallbacks) do
        tbl.actualhandid = convertHandKindToHandId(tbl.handkind)
    end

    for _, tbl in pairs(analogCallbacks) do
        tbl.actualhandid = convertHandKindToHandId(tbl.handkind)
        tbl.literalhandtype = 1 - tbl.actualhandid
    end
end

ListenToGameEvent("primary_hand_changed", function(data)
    ---@cast data GAME_EVENT_PRIMARY_HAND_CHANGED
    updatePrimaryHandId(data.is_primary_left and 0 or 1)
end, nil)

--#region General requests

---
---Get if a button has just been pressed for a given hand.
---Optionally lock the button press so it can't be detected by other scripts until it is released.
---
---@param hand CPropVRHand|0|1
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@param lock? boolean
---@return boolean
function Input:Pressed(hand, button, lock)
    local b = trackedButtons[button]
    if type(hand) ~= "number" then hand = hand:GetHandID() end
    local h = b[hand]
    if h and not h.press_locked and h.is_held and (Time() - h.press_time) <= self.PressedTolerance then
        if lock then h.press_locked = true end
        return true
    end
    return false
end

---
---Get if a button has just been released for a given hand.
---Optionally lock the button release so it can't be detected by other scripts until it is pressed.
---
---@param hand CPropVRHand|0|1
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@param lock boolean?
---@return boolean
function Input:Released(hand, button, lock)
    local b = trackedButtons[button]
    if type(hand) ~= "number" then hand = hand:GetHandID() end
    local h = b[hand]
    if h and not h.release_locked and not h.is_held and (Time() - h.release_time) <= self.ReleasedTolerance then
        if lock then h.release_locked = true end
        return true
    end
    return false
end

---
---Get if a button is currently being held down for a given hand.
---
---@param hand CPropVRHand|0|1
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@return boolean
function Input:Button(hand, button)
    local b = trackedButtons[button]
    if type(hand) ~= "number" then hand = hand:GetHandID() end
    local h = b[hand]
    if h and h.is_held then
        return true
    end
    return false
end

---
---Get the amount of seconds a button has been held for a given hand.
---
---@param hand CPropVRHand|0|1
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@return number
function Input:ButtonTime(hand, button)
    local b = trackedButtons[button]
    if type(hand) ~= "number" then hand = hand:GetHandID() end
    local h = b[hand]
    if h and h.is_held then
        return Time() - h.press_time
    end
    return 0
end

---
---Button index pointing to its description.
---
local DIGITAL_DESCS =
{
    [0] = "Menu > Toggle Menu",
    [1] = "Menu > Menu Interact",
    [2] = "Menu > Menu Dismiss",
    [3] = "Interact > Use",
    [4] = "Interact > Use Grip",
    [5] = "Weapon > Show inventory",
    [6] = "Interact > Grav Glove Lock",
    [7] = "Weapon > Fire",
    [8] = "Weapon > Alt Fire",
    [9] = "Weapon > Reload",
    [10] = "Weapon > Eject Magazine",
    [11] = "Weapon > Slide Release",
    [12] = "Weapon > Open Chamber",
    [13] = "Weapon > Toggle Laser Sight",
    [14] = "Weapon > Toggle Burst Fire",
    [15] = "Interact > Toggle Health Pen",
    [16] = "Interact > Arm Grenade",
    [17] = "Interact > Arm Xen Grenade",
    [18] = "Move > Teleport",
    [19] = "Move > Turn Left",
    [20] = "Move > Turn Right",
    [21] = "Move > Move Back",
    [22] = "Move > Walk",
    [23] = "Move > Jump",
    [24] = "Move > Mantle",
    [25] = "Move > Crouch Toggle",
    [26] = "Move > Stand toggle",
    [27] = "Move > Adjust Height",
}

local ANALOG_DESCS =
{
    [0] = "Hand Curl",
    [1] = "Trigger Pull",
    [2] = "Squeeze Xen Grenade",
    [3] = "Teleport Turn",
    [4] = "Continuous Turn",
}

---
---Get the description of a given button.
---Useful for debugging or hint display.
---
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@return string
function Input:GetButtonDescription(button)
    return DIGITAL_DESCS[button]
end

---
---Get the description of a given analog action.
---Useful for debugging or hint display.
---
---@param analog ENUM_ANALOG_INPUT_ACTIONS
---@return string
function Input:GetAnalogDescription(analog)
    return ANALOG_DESCS[analog]
end

---
---Get the name of a hand.
---
---@param hand CPropVRHand|0|1
---@param use_operant boolean? # If true, will return primary/secondary instead of left/right
function Input:GetHandName(hand, use_operant)
    if type(hand) ~= "number" then
        hand = hand:GetHandID()
    end
    if use_operant then
        if Convars:GetBool("hlvr_left_hand_primary") then
            return hand == 0 and "Primary Hand" or "Secondary Hand"
        else
            return hand == 0 and "Secondary Hand" or "Primary Hand"
        end
    else
        return hand == 0 and "Left Hand" or "Right Hand"
    end
end

--#endregion General requests

---
---Register a callback for a specific button press/release.
---
---@param kind string # The kind of button interaction.
---| '"press"' # Button is pressed.
---| '"release"' # Button is released.
---@param hand CPropVRHand|InputHandKind # The ID of the hand to register for.
---| -1 # Both hands.
---@param button ENUM_DIGITAL_INPUT_ACTIONS # The button to check.
---@param presses integer|nil # Number of times the button must be pressed in quick succession. E.g. 2 for double click. Only applicable for `kind` press.
---@param callback fun(params:INPUT_PRESS_CALLBACK|INPUT_RELEASE_CALLBACK) # The function that will be called when conditions are met.
---@param context? any # Optional context passed into the callback as the first value. Is also used when unregistering.
function Input:ListenToButton(kind, hand, button, presses, callback, context)

    if type(hand) ~= "number" then
        hand = hand:GetHandID()
    -- Quick way to register both hands.
    elseif hand == -1 then
        self:ListenToButton(kind, 0, button, presses, callback)
        self:ListenToButton(kind, 1, button, presses, callback)
        return
    end

    local buttonTable = trackedButtons[button]

    assert(buttonTable ~= nil, "Button " .. button .. " is not being tracked! Please use Input:TrackButton("..button..")")

    local callbackTable = kind == "press" and pressCallbacks or releaseCallbacks

    callbackId = callbackId + 1
    callbackTable[callbackId] = {
        func = callback,
        context = context,
        handkind = hand,
        actualhandid = convertHandKindToHandId(hand),
        presses = presses or 1,
        button = button
    }

    return callbackId

end

---@alias AnalogValueType Vector|{ x:number?, y:number? }|{[1]:number?,[2]:number?}|number

---Converts any of the possible inputs to the specific type used for analog events.
---@param analogValue AnalogValueType
---@return { x: number?, y: number? }
local function getCorrectAnalogValue(analogValue)
    ---@type { x: number?, y: number? }
    local value
    local analogValueType = type(analogValue)
    if IsVector(analogValue) then
        value = { x = analogValue.x, y = analogValue.y }
    elseif analogValueType == "table" then
        if analogValue[1] ~= nil or analogValue[2] ~= nil then
            value = { x = analogValue[1], y = analogValue[2] }
        elseif analogValue.x ~= nil or analogValue.y ~= nil then
            value = { x = analogValue.x, y = analogValue.y }
        else
            error("analogValue must have an x or y component!")
        end
    elseif analogValueType == "number" then
        value = { x = analogValue }
    else
        error("Type " .. analogValueType .. " for analogValue is invalid!")
    end
    return value
end

---
---Listen to a specific analog value reaching a certain value.
---
---@param kind "up"|"down" # `up` means listen for the value moving above `analogValue`, `down` means listen for it moving below.
---@param hand CPropVRHand|InputHandKind # The hand entity or kind of hand to listen to.
---@param analogAction ENUM_ANALOG_INPUT_ACTIONS # The specific analog action to listen for.
---@param analogValue AnalogValueType # The value(s) to listen for.
---@param callback fun(params:ANALOG_CALLBACK) # The function that will be called when conditions are met.
---@param context? any # Optional context passed into the callback as the first value. Is also used when unregistering.
function Input:ListenToAnalog(kind, hand, analogAction, analogValue, callback, context)
    local handid = convertHandKindToHandId(hand)

    local value = getCorrectAnalogValue(analogValue)

    callbackId = callbackId + 1
    analogCallbacks[callbackId] = {
        checkGreaterThan = kind == "up",
        actualhandid = handid,
        func = callback,
        context = context,
        literalhandtype = 1 - handid,
        analog = analogAction,
        value = value,
        handkind = hand
    }

    return callbackId
end

---
---Allows changing some data which was defined in `ListenToAnalog` for a specific ID.
---
---@param id integer # The ID of the analog event you want to modify.
---@param analogAction? ENUM_ANALOG_INPUT_ACTIONS # The new action to listen for, or nil to leave unchanged.
---@param analogValue AnalogValueType # The new value to listen for, or nil to leave unchanged.
---@return boolean # True if the ID was found, false otherwise.
function Input:ModifyAnalogCallback(id, analogAction, analogValue)
    for _id, analogCallbackData in pairs(analogCallbacks) do
        if _id == id then
            if analogAction ~= nil then
                analogCallbackData.analog = analogAction
            end
            if analogValue ~= nil then
                local value = getCorrectAnalogValue(analogValue)
                analogCallbackData.value = value
            end
            return true
        end
    end
    return false
end

---
---Unregisters a specific callback from all buttons and hands.
---
---@param id number # The number returned by ListenToButton.
function Input:StopListening(id)
    for _id, tbl in pairs(pressCallbacks) do
        if _id == id then
            tbl[_id] = nil
            return
        end
    end

    for _id, tbl in pairs(releaseCallbacks) do
        if _id == id then
            releaseCallbacks[_id] = nil
            return
        end
    end

    for _id, value in pairs(analogCallbacks) do
        if _id == id then
            analogCallbacks[_id] = nil
            return
        end
    end
end

---
---Stops listening to any listened from all buttons and hands that have this callback/context pair.
---
---@param callback fun(params:ANALOG_CALLBACK) # The callback function that's listening.
---@param context? any # The context that was given.
function Input:StopListeningCallbackContext(callback, context)
    for _id, tbl in pairs(pressCallbacks) do
        if tbl.func == callback and tbl.context == context then
            pressCallbacks[_id] = nil
            break
        end
    end

    for _id, tbl in pairs(releaseCallbacks) do
        if tbl.func == callback and tbl.context == context then
            releaseCallbacks[_id] = nil
            break
        end
    end

    for _id, tbl in pairs(analogCallbacks) do
        if tbl.func == callback and tbl.context == context then
            analogCallbacks[_id] = nil
            break
        end
    end
end

---
---Unregisters a specific callback from all buttons and hands.
---
---@param context any # The number returned by ListenToButton.
function Input:StopListeningByContext(context)
    for _id, tbl in pairs(pressCallbacks) do
        if tbl.context == context then
            pressCallbacks[_id] = nil
        end
    end

    for _id, tbl in pairs(releaseCallbacks) do
        if tbl.context == context then
            releaseCallbacks[_id] = nil
        end
    end

    for _id, value in pairs(analogCallbacks) do
        if value.context == context then
            analogCallbacks[_id] = nil
        end
    end
end


---
---Get if a button has just been pressed for this hand.
---Optionally lock the button press so it can't be detected by other scripts until it is released.
---
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@param lock boolean?
---@return boolean
function CPropVRHand:Pressed(button, lock)
    return Input:Pressed(self:GetHandID(), button, lock)
end

---
---Get if a button has just been released for this hand.
---Optionally lock the button release so it can't be detected by other scripts until it is pressed.
---
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@param lock boolean?
---@return boolean
function CPropVRHand:Released(button, lock)
    return Input:Released(self:GetHandID(), button, lock)
end

---
---Get if a button is currently being held down for a this hand.
---
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@return boolean
function CPropVRHand:Button(button)
    return Input:Button(self:GetHandID(), button)
end

---
---Get the amount of seconds a button has been held for this hand.
---
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@return number
function CPropVRHand:ButtonTime(button)
    return Input:ButtonTime(self:GetHandID(), button)
end


---@class INPUT_PRESS_CALLBACK
---@field kind "press" # The kind of event.
---@field press_time number # The server time at which the button was pressed.
---@field hand CPropVRHand # EntityHandle for the hand that pressed the button.
---@field button ENUM_DIGITAL_INPUT_ACTIONS # The ID of the button that was pressed.

---@class INPUT_RELEASE_CALLBACK
---@field kind "release" # The kind of event.
---@field release_time number # The server time at which the button was released.
---@field hand CPropVRHand # EntityHandle for the hand that released the button.
---@field button ENUM_DIGITAL_INPUT_ACTIONS # The ID of the button that was pressed.
---@field held_time number # Seconds the button was held for prior to being released.

---@class ANALOG_CALLBACK
---@field value Vector # The vector value of the analog action at the time of detection.
---@field hand CPropVRHand # EntityHandle for the hand that moved the analog action.
---@field analog ENUM_ANALOG_INPUT_ACTIONS # The ID of the analog action that was moved.

---@alias INPUT_CALLBACK INPUT_RELEASE_CALLBACK|INPUT_PRESS_CALLBACK

local function InputThink()
    ---@TODO remove these variables and use cached literal/hand entity
    local player = Entities:GetLocalPlayer()
    local hmd = player:GetHMDAvatar()--[[@as CPropHMDAvatar]]

    for button, hands in pairs(trackedButtons) do
        for handid, buttonData in pairs(hands) do

            local hand = hmd:GetVRHand(handid)
            if player:IsDigitalActionOnForHand(hand:GetLiteralHandType(), button) then
                if buttonData.press_time == -1 then
                    buttonData.is_held = true
                    buttonData.release_locked = false
                    if Time() - buttonData.prev_press_time <= Input.MultiplePressInterval then
                        buttonData.multiple_press_count = buttonData.multiple_press_count + 1
                    else
                        buttonData.multiple_press_count = 0
                    end
                    buttonData.press_time = Time()
                    -- This is not reset by release section
                    buttonData.prev_press_time = buttonData.press_time
                    ---@type INPUT_PRESS_CALLBACK
                    local send = {
                        kind = "press",
                        press_time = buttonData.press_time,
                        hand = hand,
                        button = button,
                    }
                    buttonData.release_time = -1
                    for id, callbackData in pairs(pressCallbacks) do
                        if callbackData.actualhandid == handid and callbackData.button == button and buttonData.multiple_press_count >= callbackData.presses-1 then
                            if callbackData.context then
                                callbackData.func(callbackData.context, send)
                            else
                                callbackData.func(send)
                            end
                            buttonData.multiple_press_count = 0
                        end
                    end
                end
            elseif buttonData.release_time == -1 then
                buttonData.is_held = false
                buttonData.press_locked = false
                buttonData.release_time = Time()
                ---@type INPUT_RELEASE_CALLBACK
                local send = {
                    kind = "release",
                    release_time = buttonData.release_time,
                    hand = hand,
                    button = button,
                    held_time = Time() - buttonData.press_time
                }
                -- Needs to be after `send` table.
                buttonData.press_time = -1
                for id, callbackData in pairs(releaseCallbacks) do
                    if callbackData.actualhandid == handid then
                        if callbackData.context then
                            callbackData.func(callbackData.context, send)
                        else
                            callbackData.func(send)
                        end
                    end
                end
            end
        end
    end

    for _, analogData in pairs(analogCallbacks) do
        local value = player:GetAnalogActionPositionForHand(analogData.literalhandtype, analogData.analog)
        local send = false
        ---@TODO Is there a good way to combine duplicate code here?
        if analogData.checkGreaterThan then
            if (analogData.value.x == nil or value.x >= analogData.value.x)
            and (analogData.value.y == nil or value.y >= analogData.value.y) then
                if not analogData.wasSent then
                    analogData.wasSent = true
                    send = true
                end
            else
                analogData.wasSent = false
            end
        else
            if (analogData.value.x == nil or value.x <= analogData.value.x)
            and (analogData.value.y == nil or value.y <= analogData.value.y) then
                if analogData.wasSent == false then
                    analogData.wasSent = true
                    send = true
                end
            else
                analogData.wasSent = false
            end
        end

        if send then
            local t = {
                value = value,
                analog = analogData.analog,
                hand = hmd:GetVRHand(analogData.actualhandid)
            }
            if analogData.context then
                analogData.func(analogData.context, t)
            else
                analogData.func(t)
            end
        end

    end

    return 0
end

---
---The current entity that has the tracking think.
---This is normally the player.
---
---@type EntityHandle?
local tracking_ent = nil

---
---Starts the input system.
---
---@param on EntityHandle? # Optional entity to do the tracking on. This is the player by default.
function Input:Start(on)
    if on == nil then on = Entities:GetLocalPlayer() end
    tracking_ent = on
    tracking_ent:SetContextThink("InputThink", InputThink, 0)
    print("Input system starting...")
end

---
---Stops the input system.
---
function Input:Stop()
    if tracking_ent then
        tracking_ent:SetContextThink("InputThink", nil, 0)
    end
end

ListenToGameEvent("player_activate", function()
    if Input.AutoStart then
        -- Delay init to get hmd
        local player = Entities:GetLocalPlayer()
        player:SetContextThink("InputInit", function()
            if not player:GetHMDAvatar() then
                Warning("Input could not find HMD, make sure VR mode is enabled. Disabling Input...\n")
                return nil
            end
            updatePrimaryHandId(Convars:GetBool("hlvr_left_hand_primary") and 0 or 1)
            Input:Start(player)
        end, 0)
    end
end, nil)


print("input.lua ".. Input.version .." initialized...")

return Input
