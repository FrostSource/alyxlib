--[[
    v1.1.1
    https://github.com/FrostSource/alyxlib

    Provides a system for tracking simple hand poses and gestures.

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "alyxlib.input.gesture"
    ```

    ======================================== Usage ========================================

    Gestures are added with a unique name and a [0-1] curl range for each finger, or nil if
    the finger shouldn't be taken into consideration.

    ```lua
    Gesture:AddGesture("AllFingersNoThumb", 1, 1, 1, 1, 0)
    ```
   
    Built-in gestures can be removed to lower a small amount of processing cost, however
    this might produce undesirable results for other mods using the same gesture script if
    you plan to use a system like Scalable Init.

    ```lua
    Gesture:RemoveGestures({"OpenHand", "ClosedFist"})
    ```

    Recommended usage for tracking gestures is to register a callback function with a given
    set of conditions:

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

]]

---@TODO: Create start/stop system functions.
---@TODO: Refine finger tracking positions, especially thumb.
---@TODO: Allow range of finger pose to be defined separate to discrepancy tolerance.
---@TODO: Track duration.

---@alias GestureNames
---| string
---| "OpenHand"
---| "ClosedFist"
---| "ThumbsUp"
---| "DevilHorns"
---| "Point"
---| "FingerGun"
---| "PinkyOut"
---| "Shaka"
---| "MiddleFinger"
---| "TheShocker"
---| "Peace"
-- Custom gesture names can be appended here to improve writing.

---@class GestureTable
---@field name GestureNames # Name of the gesture.
---@field index number|nil # [0-1] range of the index finger position.
---@field middle number|nil # [0-1] range of the middle finger position.
---@field ring number|nil # [0-1] range of the ring finger position.
---@field pinky number|nil # [0-1] range of the pinky finger position.
---@field thumb number|nil # [0-1] range of the thumb finger position.

Gesture = {}
Gesture.__index = Gesture
Gesture.version = "v1.1.1"

---
---If the gesture system should start automatically on player spawn.
---Set this to false soon after require to stop it.
---
Gesture.AutoStart = true

Gesture.DebugEnabled = false

---
---Number of seconds a pose must be held to register.
---
Gesture.Duration = 0.3

---
---Gestures that are tracked by the gesture engine.
---
---@type table<string, GestureTable>
Gesture.Gestures = {}

---
---Current gesture that each hand is performing.
---
---@type table<integer,GestureTable|nil>
Gesture.CurrentGesture = {
    [0] = nil,
    [1] = nil,
}

---
---Previous gesture that each hand has performed.
---
---@type table<integer,GestureTable|nil>
Gesture.PreviousGesture = {
    [0] = nil,
    [1] = nil,
}

Gesture.DiscrepancyTolerance = 0.25

---
---Create a new gesture table.
---If finger position is nil then the finger isn't taken into consideration.
---
---@param name? string
---@param index number|nil
---@param middle number|nil
---@param ring number|nil
---@param pinky number|nil
---@param thumb number|nil
---@return GestureTable
local function getGestureTable(name, index, middle, ring, pinky, thumb)
    return
    {
        name = name or "",
        index = index,
        middle = middle,
        ring = ring,
        pinky = pinky,
        thumb = thumb,
    }
end

---@type table<integer,GestureTable>
local gesture_raw = {
    [0] = getGestureTable("gesture_raw_left");
    [1] = getGestureTable("gesture_raw_right");
}

local callbacks = {
    [0] = {
        start = {},
        stop = {},
    },
    [1] = {
        start = {},
        stop = {},
    },
}

---
---Add a new gesture to watch for.
---
---If a finger position is nil then the finger isn't taken into consideration.
---
---@param name string # Name of the gesture. If not unique it will overwrite the previous gesture with this name.
---@param index number|nil # [0-1] range of the index finger position.
---@param middle number|nil # [0-1] range of the middle finger position.
---@param ring number|nil # [0-1] range of the ring finger position.
---@param pinky number|nil # [0-1] range of the pinky finger position.
---@param thumb number|nil # [0-1] range of the thumb finger position.
function Gesture:AddGesture(name, index, middle, ring, pinky, thumb)
    Gesture.Gestures[name] = getGestureTable(name, index, middle, ring, pinky, thumb)
    callbacks[0].start[name] = {}
    callbacks[0].stop[name] = {}
    callbacks[1].start[name] = {}
    callbacks[1].stop[name] = {}
end

---
---Remove an existing gesture.
---
---Any callbacks registered with the gesture will be unregistered.
---
---@param name string # Name of the gesture.
function Gesture:RemoveGesture(name)
    Gesture.Gestures[name] = nil
    callbacks[0].start[name] = nil
    callbacks[0].stop[name] = nil
    callbacks[1].start[name] = nil
    callbacks[1].stop[name] = nil
end

---
---Remove a list of gestures.
---
---@param names GestureNames[]
function Gesture:RemoveGestures(names)
    for _,name in ipairs(names) do
        self:RemoveGesture(name)
    end
end

-- Add default gestures...
-- For users who are not scripting and just using the prefab you can add your custom gestures here.
Gesture:AddGesture("OpenHand", 1, 1, 1, 1, 1)
Gesture:AddGesture("ClosedFist", 0, 0, 0, 0, 0)
Gesture:AddGesture("ThumbsUp", 0, 0, 0, 0, 1)
Gesture:AddGesture("DevilHorns", 1, 0, 0, 1, nil)
Gesture:AddGesture("Point", 1, 0, 0, 0, nil)
Gesture:AddGesture("FingerGun", 1, 0, 0, 0, 1)
Gesture:AddGesture("PinkyOut", 0, 0, 0, 1, 0)
Gesture:AddGesture("Shaka", 0, 0, 0, 1, 1)
Gesture:AddGesture("MiddleFinger", 0, 1, 0, 0, nil)
Gesture:AddGesture("TheShocker", 1, 1, 0, 1, nil)
Gesture:AddGesture("Peace", 1, 1, 0, 0, nil)

---
---Gets the current gesture name of a given hand.
---
---E.g.
---
---     local g = Gesture:GetGesture(Player.PrimaryHand)
---     if g.name == "ThumbsUp" then
---         do_something()
---     end
---
---@param hand CPropVRHand|0|1
---@return GestureNames
function Gesture:GetGesture(hand)
    if type(hand) ~= "number" then
        hand = hand:GetHandID()
    end
    local g = self.CurrentGesture[hand]
    if g == nil then return "" end
    return g.name
end

---
---Gets the current [0-1] finger curl values of a given hand.
---
---@param hand CPropVRHand|0|1
---@return GestureTable
function Gesture:GetGestureRaw(hand)
    if type(hand) ~= "number" then
        hand = hand:GetHandID()
    end
    return gesture_raw[hand]
end

---
---Register a callback for a specific gesture start/stop.
---
---@param kind "start"|"stop" # If the callback is registered for gesture start or stop.
---@param hand CPropVRHand|-1|0|1 # The ID of the hand to register for (-1 means both).
---@param gesture GestureNames # Name of the gesture.
---@param duration unknown # Not implemented
---@param callback function # The function that will be called when conditions are met.
---@param context? any
function Gesture:RegisterCallback(kind, hand, gesture, duration, callback, context)

    -- Quick way to register both hands.
    if type(hand) ~= "number" then
        hand = hand:GetHandID()
    elseif hand == -1 then
        self:RegisterCallback(kind, 0, gesture, duration, callback, context)
        self:RegisterCallback(kind, 1, gesture, duration, callback, context)
        return
    end

    callbacks[hand][kind][gesture][callback] = context or true

end

---
---Unregister a callback function.
---
---@param callback function
function Gesture:UnregisterCallback(callback)
    for _, kinds in pairs(callbacks) do
        for _, names in pairs(kinds) do
            for _, cllbcks in pairs(names) do
                for cllbck, _ in pairs(cllbcks) do
                    if cllbck == callback then
                        cllbcks[cllbck] = nil
                        break
                    end
                end
            end
        end
    end
end

-- Attachment indexes
-- NOTE: The left hand increases these by 1 because of the flashlight attachment
local hand_fingertip_index = 6
local hand_fingertip_middle = 7
local hand_fingertip_ring = 8
local hand_fingertip_pinky = 9
local hand_fingertip_thumb = 10
local hand_vr_hand_origin = 14

-- Pre-calculated min/max values.
local thumb_max = 4.0799
local index_max = 4.7260
local middle_max = 4.9076
local ring_max = 4.3258
local pinky_max = 3.5965

local thumb_min = 2.3926
local index_min = 1.1494
local middle_min = 0.6369
local ring_min = 0.7918
local pinky_min = 1.3178

-- Cache for faster lookup...
local gestures = Gesture.Gestures

---@class GESTURE_CALLBACK
---@field kind "start"|"stop" # If the gesture was started or stopped.
---@field name GestureNames # The name of the gesture performed.
---@field hand CPropVRHand # The hand the gesture was performed on.
---@field time number # Server time the gesture occurred.

local function GestureThink()
    local hmd = Entities:GetLocalPlayer():GetHMDAvatar()--[[@as CPropHMDAvatar]]
    local discrepancy_tolerance = Gesture.DiscrepancyTolerance
    local debug_enabled = Gesture.DebugEnabled

    for i = 0, 1 do
        local hand = hmd:GetVRHand(i)
        local origin_attach = hand:GetAttachmentOrigin(hand_vr_hand_origin + (1-i))
        local index_attach = hand:GetAttachmentOrigin(hand_fingertip_index + (1-i))
        local middle_attach = hand:GetAttachmentOrigin(hand_fingertip_middle + (1-i))
        local ring_attach = hand:GetAttachmentOrigin(hand_fingertip_ring + (1-i))
        local pinky_attach = hand:GetAttachmentOrigin(hand_fingertip_pinky + (1-i))
        local thumb_attach = hand:GetAttachmentOrigin(hand_fingertip_thumb + (1-i))

        local index_dist = VectorDistance(origin_attach, index_attach)
        local middle_dist = VectorDistance(origin_attach, middle_attach)
        local ring_dist = VectorDistance(origin_attach, ring_attach)
        local pinky_dist = VectorDistance(origin_attach, pinky_attach)
        local thumb_dist = VectorDistance(origin_attach, thumb_attach)

        local index_val = RemapValClamped(index_dist, index_min, index_max, 0, 1)
        local middle_val = RemapValClamped(middle_dist, middle_min, middle_max, 0, 1)
        local ring_val = RemapValClamped(ring_dist, ring_min, ring_max, 0, 1)
        local pinky_val = RemapValClamped(pinky_dist, pinky_min, pinky_max, 0, 1)
        local thumb_val = RemapValClamped(thumb_dist, thumb_min, thumb_max, 0, 1)

        if debug_enabled then
            local r = 0.4
            local nodepth = true
            -- local f = 'raw: %.2f\nval: %.2f\nmin: %.2f\nmax: %.2f'
            local f = '%.3f'
            DebugDrawSphere(index_attach, Vector(255,0,0), 255, r, nodepth, 0)
            DebugDrawLine(index_attach, origin_attach, 255, 0, 0, nodepth, 0)
            DebugDrawText(index_attach + ((origin_attach - index_attach):Normalized() * (index_dist / 2)), f:format(index_val), nodepth, 0)

            DebugDrawSphere(middle_attach, Vector(0,255,0), 255, r, nodepth, 0)
            DebugDrawLine(middle_attach, origin_attach, 0, 255, 0, nodepth, 0)
            DebugDrawText(middle_attach + ((origin_attach - middle_attach):Normalized() * (middle_dist / 2)), f:format(middle_val), nodepth, 0)

            DebugDrawSphere(ring_attach, Vector(0,0,255), 255, r, nodepth, 0)
            DebugDrawLine(ring_attach, origin_attach, 0, 0, 255, nodepth, 0)
            DebugDrawText(ring_attach + ((origin_attach - ring_attach):Normalized() * (ring_dist / 2)), f:format(ring_val), nodepth, 0)

            DebugDrawSphere(pinky_attach, Vector(255,255,0), 255, r, nodepth, 0)
            DebugDrawLine(pinky_attach, origin_attach, 255, 255, 0, nodepth, 0)
            DebugDrawText(pinky_attach + ((origin_attach - pinky_attach):Normalized() * (pinky_dist / 2)), f:format(pinky_val), nodepth, 0)

            DebugDrawSphere(thumb_attach, Vector(255,0,255), 255, r, nodepth, 0)
            DebugDrawLine(thumb_attach, origin_attach, 255, 0, 255, nodepth, 0)
            DebugDrawText(thumb_attach + ((origin_attach - thumb_attach):Normalized() * (thumb_dist / 2)), f:format(thumb_val), nodepth, 0)

            DebugDrawSphere(origin_attach, Vector(0,255,255), 255, r, nodepth, 0)
        end

        gesture_raw[i].index = index_val
        gesture_raw[i].middle = middle_val
        gesture_raw[i].ring = ring_val
        gesture_raw[i].pinky = pinky_val
        gesture_raw[i].thumb = thumb_val

        for name, gesture in pairs(gestures) do
            if (gesture.index == nil or math.abs(index_val - gesture.index) <= discrepancy_tolerance)
            and (gesture.middle == nil or math.abs(middle_val - gesture.middle) <= discrepancy_tolerance)
            and (gesture.ring == nil or math.abs(ring_val - gesture.ring) <= discrepancy_tolerance)
            and (gesture.pinky == nil or math.abs(pinky_val - gesture.pinky) <= discrepancy_tolerance)
            and (gesture.thumb == nil or math.abs(thumb_val - gesture.thumb) <= discrepancy_tolerance)
            then
                if Gesture.CurrentGesture[i] ~= gesture then
                    -- gesture_time[i] = Time() - Gesture.Duration
                    Gesture.CurrentGesture[i] = gesture
                    -- print("Gesture posed on hand "..tostring(i)..": "..gesture.name)

                    ---@type GESTURE_CALLBACK
                    local data = {
                        kind = "start",
                        name = name,
                        hand = hand,
                        time = Time()
                    }
                    for callback, context in pairs(callbacks[i].start[name]) do
                        if context == true then
                            callback(data)
                        else
                            callback(context, data)
                        end
                    end
                end

                -- Early exit when finding a gesture
                break

            -- If gesture isn't active, but current gesture is this gesture,
            -- then the current gesture has stopped
            elseif Gesture.CurrentGesture[i] == gesture then
                Gesture.PreviousGesture[i] = Gesture.CurrentGesture[i]
                Gesture.CurrentGesture[i] = nil

                ---@type GESTURE_CALLBACK
                local data = {
                    kind = "stop",
                    name = name,
                    hand = hand,
                    time = Time()
                }
                for callback, context in pairs(callbacks[i].stop[name]) do
                    if context == true then
                        callback(data)
                    else
                        callback(context, data)
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
---@type EntityHandle|nil
local tracking_ent = nil

---
---Starts the gesture system.
---
---@param on EntityHandle? # Optional entity to do the tracking on. This is the player by default.
function Gesture:Start(on)
    if on == nil then on = Entities:GetLocalPlayer() end
    tracking_ent = on
    tracking_ent:SetContextThink("GestureThink", GestureThink, 0)
    print("Gesture system starting...")
end

---
---Stops the gesture system.
---
function Gesture:Stop()
    if tracking_ent then
        tracking_ent:SetContextThink("GestureThink", nil, 0)
    end
end

local listenFor = "player_spawn"
local listenFunc = ListenToGameEvent
if package.loaded["player"] then
    listenFunc = RegisterPlayerEventCallback
    listenFor = "player_activate"
end

listenFunc(listenFor, function(params)
    if Gesture.AutoStart then
        -- Delay init to get hmd
        local player = Entities:GetLocalPlayer()
        player:SetContextThink("GestureInit", function()
            if not player:GetHMDAvatar() then
                Warning("Gesture engine could not find HMD, make sure VR mode is enabled. Disabling Gestures...\n")
                return nil
            end
            Gesture:Start(player)
        end, 0)
    end
end, nil)


print("gesture.lua ".. Gesture.version .." initialized...")

return Gesture