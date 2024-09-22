--[[
    v1.0.1
    https://github.com/FrostSource/alyxlib

    Haptic sequences allow for more complex vibrations than the one-shot pulses that the base API provides.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.input.haptics"

    This script was adapted from PeterSHollander's haptics.lua
    https://github.com/PeterSHollander/glorious_gloves/blob/master/scripts/vscripts/device/haptics.lua
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
HapticSequenceClass.version = "v1.0.1"

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

return HapticSequenceClass.version