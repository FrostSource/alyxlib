--[[
    v4.0.0
    https://github.com/FrostSource/alyxlib

    Simplifies the tracking of digital action presses/releases and analog values.
    
    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:

    require "alyxlib.controls.input"
]]

---
---The input class simplifies button tracking.
---
---@class Input
Input = {}
Input.__index = Input
Input.version = "v4.0.0"

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

---@class InputCallbackTable
---@field presses integer
---@field func function
---@field context any # Value passed into first argument of callback.
---@field handkind InputHandKind # Left, right, primary, secondary.
---@field actualhandid 0|1 # This needs to be updated whenver hands change.
---@field button DigitalInputAction # The button for this event.
---@field kind "press"|"release"
---@field press_time number
---@field prev_press_time number
---@field release_time number
---@field multiple_press_count number

---@class AnalogCallbackTable
---@field analog AnalogInputAction
---@field value { x: number?, y: number? }
---@field checkGreaterThan boolean
---@field func function
---@field context any # Value passed into first argument of callback.
---@field handkind InputHandKind # Left, right, primary, secondary.
---@field actualhandid 0|1 # This needs to be updated whenver hands change.
---@field literalhandtype 0|1 # The literal value of the hand which is usually the opposite of Id

---@type table<integer, InputCallbackTable>
local buttonCallbacks = {}

---@type table<integer, AnalogCallbackTable>
local analogCallbacks = {}

local callbackId = 0


local currentPrimaryHandId = 1
local currentSecondaryHandId = 0

---@alias NamedDigitalInputAction
---| `DIGITAL_INPUT_TOGGLE_MENU`
---| `DIGITAL_INPUT_MENU_INTERACT`
---| `DIGITAL_INPUT_MENU_DISMISS`
---| `DIGITAL_INPUT_USE`
---| `DIGITAL_INPUT_USE_GRIP`
---| `DIGITAL_INPUT_SHOW_INVENTORY`
---| `DIGITAL_INPUT_GRAV_GLOVE_LOCK`
---| `DIGITAL_INPUT_FIRE`
---| `DIGITAL_INPUT_ALT_FIRE`
---| `DIGITAL_INPUT_RELOAD`
---| `DIGITAL_INPUT_EJECT_MAGAZINE`
---| `DIGITAL_INPUT_SLIDE_RELEASE`
---| `DIGITAL_INPUT_OPEN_CHAMBER`
---| `DIGITAL_INPUT_TOGGLE_LASER_SIGHT = 13
---| `DIGITAL_INPUT_TOGGLE_BURST_FIRE`
---| `DIGITAL_INPUT_TOGGLE_HEALTH_PEN`
---| `DIGITAL_INPUT_ARM_GRENADE`
---| `DIGITAL_INPUT_ARM_XEN_GRENADE`
---| `DIGITAL_INPUT_TELEPORT`
---| `DIGITAL_INPUT_TURN_LEFT`
---| `DIGITAL_INPUT_TURN_RIGHT`
---| `DIGITAL_INPUT_MOVE_BACK`
---| `DIGITAL_INPUT_WALK`
---| `DIGITAL_INPUT_JUMP`
---| `DIGITAL_INPUT_MANTLE`
---| `DIGITAL_INPUT_CROUCH_TOGGLE`
---| `DIGITAL_INPUT_STAND_TOGGLE`
---| `DIGITAL_INPUT_ADJUST_HEIGHT`

InputHandBoth = -1
InputHandLeft = 0
InputHandRight = 1
InputHandPrimary = 2
InputHandSecondary = 3

---@alias InputHandKind
---| `INPUT_HAND_LEFT`
---| `INPUT_HAND_RIGHT`
---| `INPUT_HAND_PRIMARY`
---| `INPUT_HAND_SECONDARY`
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

    for _id, tbl in pairs(buttonCallbacks) do
        tbl.actualhandid = convertHandKindToHandId(tbl.handkind)
    end

    for _, tbl in pairs(analogCallbacks) do
        tbl.actualhandid = convertHandKindToHandId(tbl.handkind)
        tbl.literalhandtype = 1 - tbl.actualhandid
    end
end

ListenToGameEvent("primary_hand_changed", function(data)
    ---@cast data GameEventPrimaryHandChanged
    updatePrimaryHandId(data.is_primary_left and 0 or 1)
end, nil)

---
---Button index pointing to its description.
---
local DigitalDescriptions = DefaultTable(
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
}, "Invalid digital action")

local AnalogDescriptions = DefaultTable(
{
    [0] = "Hand Curl",
    [1] = "Trigger Pull",
    [2] = "Squeeze Xen Grenade",
    [3] = "Teleport Turn",
    [4] = "Continuous Turn",
}, "Invalid analog action")

local ControllerTypeDescriptions = DefaultTable(
{
    [0] = "VR_CONTROLLER_TYPE_UNKNOWN",
    [1] = "VR_CONTROLLER_TYPE_X360",
    [2] = "VR_CONTROLLER_TYPE_VIVE",
    [3] = "VR_CONTROLLER_TYPE_TOUCH",
    [4] = "VR_CONTROLLER_TYPE_RIFT_S",
    [5] = "UNKNOWN",
    [6] = "VR_CONTROLLER_TYPE_KNUCKLES",
    [7] = "VR_CONTROLLER_TYPE_WINDOWSMR",
    [8] = "VR_CONTROLLER_TYPE_WINDOWSMR_SAMSUNG",
    [9] = "VR_CONTROLLER_TYPE_GENERIC_TRACKED",
    [10] = "VR_CONTROLLER_TYPE_COSMOS",
}, "Invalid controller type")

---
---Get the description of a given button.
---Useful for debugging or hint display.
---
---@param button DigitalInputAction
---@return string
function Input:GetButtonDescription(button)
    return DigitalDescriptions[button]
end

---
---Get the description of a given analog action.
---Useful for debugging or hint display.
---
---@param analog DigitalInputAction
---@return string
function Input:GetAnalogDescription(analog)
    return AnalogDescriptions[analog]
end

---
---Get the description of a given controller type.
---
---@param controllerType ControllerType
---@return string
function Input:GetControllerTypeDescription(controllerType)
    return ControllerTypeDescriptions[controllerType]
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
---@generic T
---@param kind string # The kind of button interaction.
---| '"press"' # Button is pressed.
---| '"release"' # Button is released.
---@param hand CPropVRHand|`InputHandBoth`|InputHandKind # The type of hand to listen on, or the hand itself.
---| -1 # Both hands
---@param button NamedDigitalInputAction|DigitalInputAction # The button to check.
---@param presses integer|nil # Number of times the button must be pressed in quick succession. E.g. 2 for double click. Only applicable for `kind` press.
---@param callback fun(params:InputPressCallback|InputReleaseCallback)|fun(context:T,params:InputPressCallback|InputReleaseCallback) # The function that will be called when conditions are met.
---@param context? T # Optional context passed into the callback as the first value. Is also used when unregistering.
function Input:ListenToButton(kind, hand, button, presses, callback, context)

    if type(hand) ~= "number" then
        hand = hand:GetHandID()
    -- Quick way to register both hands.
    elseif hand == -1 then
        local id1 = self:ListenToButton(kind, 0, button, presses, callback, context)
        local id2 = self:ListenToButton(kind, 1, button, presses, callback, context)
        return id1, id2
    end

    callbackId = callbackId + 1
    buttonCallbacks[callbackId] = {
        func = callback,
        context = context,
        handkind = hand,
        actualhandid = convertHandKindToHandId(hand),
        presses = presses or 1,
        button = button,
        kind = kind,

        multiple_press_count = 0,
        press_time = -1,
        release_time = 0,
        prev_press_time = 0,
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
---@param analogAction AnalogInputAction # The specific analog action to listen for.
---@param analogValue AnalogValueType # The value(s) to listen for.
---@param callback fun(params:InputAnalogCallback) # The function that will be called when conditions are met.
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
---Changes some data which was defined in `ListenToAnalog` for a specific ID.
---
---@param id integer # The ID of the analog event you want to modify.
---@param analogAction? AnalogInputAction # The new action to listen for, or nil to leave unchanged.
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
---Unregisters a listener with a specific ID.
---
---@param id number # The number returned by ListenToButton.
function Input:StopListening(id)
    for _id, tbl in pairs(buttonCallbacks) do
        if _id == id then
            tbl[_id] = nil
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
---Unregisters any listeners with a specific callback/context pair.
---
---@param callback fun(params:InputAnalogCallback) # The callback function that's listening.
---@param context? any # The context that was given.
function Input:StopListeningCallbackContext(callback, context)
    for _id, tbl in pairs(buttonCallbacks) do
        if tbl.func == callback and tbl.context == context then
            buttonCallbacks[_id] = nil
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
---Unregisters any listeners which have a specific context.
---
---@param context any # The number returned by ListenToButton.
function Input:StopListeningByContext(context)
    for _id, tbl in pairs(buttonCallbacks) do
        if tbl.context == context then
            buttonCallbacks[_id] = nil
        end
    end

    for _id, value in pairs(analogCallbacks) do
        if value.context == context then
            analogCallbacks[_id] = nil
        end
    end
end


---@class InputPressCallback
---@field kind "press" # The kind of event.
---@field press_time number # The server time at which the button was pressed.
---@field hand CPropVRHand # EntityHandle for the hand that pressed the button.
---@field button DigitalInputAction # The ID of the button that was pressed.

---@class InputReleaseCallback
---@field kind "release" # The kind of event.
---@field release_time number # The server time at which the button was released.
---@field hand CPropVRHand # EntityHandle for the hand that released the button.
---@field button DigitalInputAction # The ID of the button that was pressed.
---@field held_time number # Seconds the button was held for prior to being released.

---@class InputAnalogCallback
---@field value Vector # The vector value of the analog action at the time of detection.
---@field hand CPropVRHand # EntityHandle for the hand that moved the analog action.
---@field analog AnalogInputAction # The ID of the analog action that was moved.

---@alias INPUT_CALLBACK InputPressCallback|InputReleaseCallback

local function InputThink()
    ---@TODO remove these variables and use cached literal/hand entity
    local player = Entities:GetLocalPlayer()
    local hmd = player:GetHMDAvatar()--[[@as CPropHMDAvatar]]

    for id, callbackData in pairs(buttonCallbacks) do

            local hand = hmd:GetVRHand(callbackData.actualhandid)
            if player:IsDigitalActionOnForHand(hand:GetLiteralHandType(), callbackData.button) then
                if callbackData.press_time == -1 then
                    if Time() - callbackData.prev_press_time <= Input.MultiplePressInterval then
                        callbackData.multiple_press_count = callbackData.multiple_press_count + 1
                    else
                        callbackData.multiple_press_count = 0
                    end
                    callbackData.press_time = Time()
                    -- This is not reset by release section
                    callbackData.prev_press_time = callbackData.press_time

                    callbackData.release_time = -1

                    if callbackData.kind == "press" then

                        ---@type InputPressCallback
                        local send = {
                            kind = "press",
                            press_time = callbackData.press_time,
                            hand = hand,
                            button = callbackData.button,
                        }

                        if callbackData.multiple_press_count >= callbackData.presses-1 then
                            if callbackData.context then
                                callbackData.func(callbackData.context, send)
                            else
                                callbackData.func(send)
                            end
                            callbackData.multiple_press_count = 0
                        end
                    end
                end

            -- Release callbacks
            elseif callbackData.release_time == -1 then
                callbackData.release_time = Time()

                local cachePressTime = callbackData.press_time
                callbackData.press_time = -1

                if callbackData.kind == "release" then

                    ---@type InputReleaseCallback
                    local send = {
                        kind = "release",
                        release_time = callbackData.release_time,
                        hand = hand,
                        button = callbackData.button,
                        held_time = Time() - cachePressTime
                    }


                    if callbackData.context then
                        callbackData.func(callbackData.context, send)
                    else
                        callbackData.func(send)
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

return Input.version
