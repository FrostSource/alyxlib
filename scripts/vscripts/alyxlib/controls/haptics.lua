--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Haptic sequences allow for more complex vibrations than the one-shot pulses that the base API provides.

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "alyxlib.input.haptics"
    ```

    This script was adapted from PeterSHollander's haptics.lua
    https://github.com/PeterSHollander/glorious_gloves/blob/master/scripts/vscripts/device/haptics.lua

    ======================================== Usage ========================================

    A HapticSequence is created with a total duration, vibration strength, and pulse interval.
    The following sequence lasts for 1 second and vibrates every 10th of a second at half strength.
    This theoretically pulses 10 times in total.

    ```lua
    local hapticSeq = HapticSequence(1, 0.5, 0.1)
    ```

    After creating the sequence we can fire it at any point.
    If the sequence is fired again before finishing it will cancel the currently running sequence
    and start again.

    ```lua
    hapticSeq:Fire()
    ```
    
]]

local MIN_PULSE_WIDTH = 1
local MAX_PULSE_WIDTH = 30

---@class HapticSequence
local HapticSequenceClass = {
    ---@type string
    IDENTIFIER = UniqueString(),
    ---@type number
    duration = 0.5,
    ---@type number
    pulseInterval = 0.01,

    ---@type number
    pulseWidth_us = 0,
}
HapticSequenceClass.__index = HapticSequenceClass
HapticSequenceClass.version = "v1.0.0"

---
---Start the haptic sequence on a given hand.
---
---@param hand CPropVRHand|number # The hand entity handle or ID number.
function HapticSequenceClass:Fire(hand)
    if type(hand) == "number" then
        hand = Entities:GetLocalPlayer():GetHMDAvatar():GetVRHand(hand)
    end

    local ref = {
        increment = 0,
        prevTime = Time(),
    }

    hand:SetThink(function()
        hand:FireHapticPulsePrecise(self.pulseWidth_us)
        if ref.increment < self.duration then
            local currentTime = Time()
            ref.increment = ref.increment + (currentTime - ref.prevTime)
            ref.prevTime = currentTime
            return self.pulseInterval
        else
            return nil
        end
    end, "Fire" .. self.IDENTIFIER .. "Haptic", 0)
end

---
---Create a new haptic sequence.
---
---@param duration number # Length of the sequence in seconds.
---@param pulseStrength number # Strength of the vibration in range [0-1].
---@param pulseInterval number # Interval between each vibration during the sequence, in seconds.
---@return HapticSequence
function HapticSequence(duration, pulseStrength, pulseInterval)
    local inst = {
        duration = duration,
        pulseInterval = pulseInterval,

        IDENTIFIER = UniqueString(),
        pulseWidth_us = 0,
    }

    pulseStrength = pulseStrength or 0.1
    pulseStrength = Clamp(pulseStrength, 0, 1)
    pulseStrength = pulseStrength * pulseStrength

    if pulseStrength > 0 then
        inst.pulseWidth_us = Lerp(pulseStrength, MIN_PULSE_WIDTH, MAX_PULSE_WIDTH)
    end

    return setmetatable(inst, HapticSequenceClass)
end

print("haptics.lua ".. HapticSequenceClass.version .." initialized...")

return HapticSequenceClass