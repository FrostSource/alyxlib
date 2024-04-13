--[[
    v1.2.0
    https://github.com/FrostSource/alyxlib

    Simplifies the tracking of button presses/releases. This system will automatically
    start when the player spawns unless told not to before the player spawns.

    ```lua
    Input.AutoStart = false
    ```

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:

    ```lua
    require "alyxlib.input.input"
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
Input.version = "v1.2.0"

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
local tracked_buttons = {}

---@class InputButtonTable
---@field is_held boolean
---@field press_time number
---@field prev_press_time number
---@field release_time number
---@field press_locked boolean
---@field release_locked boolean
---@field press_callbacks table<function, InputCallbackTable>
---@field release_callbacks table<function, InputCallbackTable>
---@field multiple_press_count number

---@class InputCallbackTable
---@field presses integer
---@field context any

local function createButtonTable()
    return {
        is_held = false,
        press_time = -1,
        prev_press_time = -1,
        -- Must not be -1, to avoid triggering all buttons on start
        release_time = 0,
        press_locked = false,
        release_locked = false,
        ---@type table<function,InputCallbackTable>
        press_callbacks = {},
        ---@type table<function,InputCallbackTable>
        release_callbacks = {},
        multiple_press_count = 0,
    }
end

---
---Set a button to be tracked.
---
---@param button ENUM_DIGITAL_INPUT_ACTIONS
function Input:TrackButton(button)
    tracked_buttons[button] = {
        [0] = createButtonTable(), -- Left
        [1] = createButtonTable(), -- Right
        [2] = createButtonTable(), -- Primary
        [3] = createButtonTable(), -- Secondary
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
    tracked_buttons = {}
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
    tracked_buttons[button] = nil
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


---
---Get if a button has just been pressed for a given hand.
---Optionally lock the button press so it can't be detected by other scripts until it is released.
---
---@param hand CPropVRHand|0|1
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@param lock? boolean
---@return boolean
function Input:Pressed(hand, button, lock)
    local b = tracked_buttons[button]
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
    local b = tracked_buttons[button]
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
    local b = tracked_buttons[button]
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
    local b = tracked_buttons[button]
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
local DESCS =
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

---
---Get the description of a given button.
---Useful for debugging or hint display.
---
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@return string
function Input:GetButtonDescription(button)
    return DESCS[button]
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

---
---Register a callback for a specific button press/release.
---
---@param kind string # The kind of button interaction.
---| '"press"' # Button is pressed.
---| '"release"' # Button is released.
---@param hand CPropVRHand|integer # The ID of the hand to register for.
---| `-1` # Both hands.
---| `0`  # Left Hand.
---| `1`  # Right Hand.
---| `2`  # Primary Hand.
---| `3`  # Secondary Hand.
---@param button ENUM_DIGITAL_INPUT_ACTIONS # The button to check.
---@param presses integer|nil # Number of times the button must be pressed in quick succession. E.g. 2 for double click. Only applicable for `kind` press.
---@param callback fun(params:INPUT_PRESS_CALLBACK|INPUT_RELEASE_CALLBACK) # The function that will be called when conditions are met.
---@param context? any # Optional context passed into the callback as the first value. Is also used when unregistering.
function Input:RegisterCallback(kind, hand, button, presses, callback, context)

    if type(hand) ~= "number" then
        hand = hand:GetHandID()
    -- Quick way to register both hands.
    elseif hand == -1 then
        self:RegisterCallback(kind, 0, button, presses, callback)
        self:RegisterCallback(kind, 1, button, presses, callback)
        return
    end

    local b = tracked_buttons[button]
    if not b then
        error("Button " .. button .. " is not being tracked! Please use Input:TrackButton("..button..")")
    end
    local h = b[hand]
    if h then
        local t = h.press_callbacks
        if kind == "release" then t = h.release_callbacks end
        -- print('registering input callback', callback, 'in', t)
        -- t[callback] = presses or 1
        t[callback] = {
            presses = presses or 1,
            context = context
        }
    end

end

---
---Unregisters a specific callback from all buttons and hands.
---
---@param callback function
function Input:UnregisterCallback(callback, context)
    for button, hands in pairs(tracked_buttons) do
        for handid, data in pairs(hands) do
            for clbck, clbckData in pairs(data.press_callbacks) do
                if clbck == callback and (clbckData.context == nil or clbckData.context == context) then
                    data.press_callbacks[clbck] = nil
                end
            end
            for clbck, clbckData in pairs(data.release_callbacks) do
                if clbck == callback and (clbckData.context == nil or clbckData.context == context) then
                    data.release_callbacks[clbck] = nil
                end
            end
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

---@alias INPUT_CALLBACK INPUT_RELEASE_CALLBACK|INPUT_PRESS_CALLBACK

local primary_hand = 1
local secondary_hand = 0

local function SetPrimaryHand(primary)
    -- primary_hand = Entities:GetLocalPlayer():GetHMDAvatar():GetVRHand(primary)
    -- secondary_hand = Entities:GetLocalPlayer():GetHMDAvatar():GetVRHand(1 - primary)
    primary_hand = primary
    secondary_hand = 1 - primary
end

ListenToGameEvent("primary_hand_changed", function(data)
    ---@cast data GAME_EVENT_PRIMARY_HAND_CHANGED
    SetPrimaryHand(data.is_primary_left and 0 or 1)
end, nil)

local function InputThink()
    local player = Entities:GetLocalPlayer()
    local hmd = player:GetHMDAvatar()--[[@as CPropHMDAvatar]]

    for button, hands in pairs(tracked_buttons) do
        for handid, data in pairs(hands) do
            -- Resolve primary/secondary hand into valid hand id
            if handid == 2 then handid = primary_hand
            elseif handid == 3 then handid = secondary_hand end

            local hand = hmd:GetVRHand(handid)
            if player:IsDigitalActionOnForHand(hand:GetLiteralHandType(), button) then
                -- print("Held time", Input:ButtonTime(handid, button), Time(), data.press_time)
                if data.press_time == -1 then
                    data.is_held = true
                    data.release_locked = false
                    if Time() - data.prev_press_time <= Input.MultiplePressInterval then
                        data.multiple_press_count = data.multiple_press_count + 1
                    else
                        data.multiple_press_count = 0
                    end
                    data.press_time = Time()
                    -- This is not reset by release section
                    data.prev_press_time = data.press_time
                    ---@type INPUT_PRESS_CALLBACK
                    local send = {
                        kind = "press",
                        press_time = data.press_time,
                        hand = hand,
                        button = button,
                    }
                    data.release_time = -1
                    -- print(Input:GetButtonDescription(button).." pressed", "multiple_press: "..data.multiple_press_count)
                    -- print('doing press callbacks', data.press_callbacks, 'for hand', handid)
                    for callback, callbackData in pairs(data.press_callbacks) do
                        if data.multiple_press_count >= callbackData.presses-1 then
                            if callbackData.context then
                                callback(callbackData.context, send)
                            else
                                callback(send)
                            end
                            data.multiple_press_count = 0
                        end
                    end
                end
            elseif data.release_time == -1 then
                data.is_held = false
                data.press_locked = false
                data.release_time = Time()
                ---@type INPUT_RELEASE_CALLBACK
                local send = {
                    kind = "release",
                    release_time = data.release_time,
                    hand = hand,
                    button = button,
                    held_time = Time() - data.press_time
                }
                -- Needs to be after `send` table.
                data.press_time = -1
                -- print(Input:GetButtonDescription(button), "released")
                for callback, callbackData in pairs(data.release_callbacks) do
                    if callbackData.context then
                        callback(callbackData.context, send)
                    else
                        callback(send)
                    end
                end
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
            SetPrimaryHand(Convars:GetBool("hlvr_left_hand_primary") and 0 or 1)
            Input:Start(player)
        end, 0)
    end
end, nil)


print("input.lua ".. Input.version .." initialized...")

return Input
