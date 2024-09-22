--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Provides functionality for animating getter/setter entity methods using curves.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.helpers.animation"
]]

---
---Animation library for animating entity properties and values.
---
---@diagnostic disable: undefined-field
---@class Animation
Animation = {}

local localBounceOut = function(a, b, t)
    local normalizedT = t
    if normalizedT < (1 / 2.75) then
        return a + (b - a) * 7.5625 * normalizedT * normalizedT
    elseif normalizedT < (2 / 2.75) then
        normalizedT = normalizedT - (1.5 / 2.75)
        return a + (b - a) * (7.5625 * normalizedT * normalizedT + 0.75)
    elseif normalizedT < (2.5 / 2.75) then
        normalizedT = normalizedT - (2.25 / 2.75)
        return a + (b - a) * (7.5625 * normalizedT * normalizedT + 0.9375)
    else
        normalizedT = normalizedT - (2.625 / 2.75)
        return a + (b - a) * (7.5625 * normalizedT * normalizedT + 0.984375)
    end
end

local localBounceIn = function(a, b, t)
    return a + (b - a) * (1 - localBounceOut(0, 1, 1 - t))
end

---@enum Animation.Curves
Animation.Curves = {
    linear = function(a, b, t)
        return a * (1 - t) + b * t
    end,

    -- Ease In curve function
    easeIn = function(a, b, t)
        return a + (b - a) * t * t
    end,

    -- Ease Out curve function
    easeOut = function(a, b, t)
        t = 1 - t
        return a + (b - a) * (1 - t * t)
    end,

    -- Ease In Out curve function
    easeInOut = function(a, b, t)
        if t < 0.5 then
            return a + (b - a) * (2 * t * t)
        else
            t = 1 - (2 * t - 1)
            return a + (b - a) * (1 - 2 * t * t)
        end
    end,

    -- Elastic In curve function
    elasticIn = function(a, b, t)
        local c = b - a
        local p = 0.3
        local s = p / 4

        if t == 0 then
            return a
        elseif t == 1 then
            return b
        else
            local postFix = 2 ^ (10 * (t - 1)) * math.sin((t - 1 + s) * (2 * math.pi) / p)
            return a + c * postFix
        end
    end,

    -- Elastic Out curve function
    elasticOut = function(a, b, t)
        local c = b - a
        local p = 0.3
        local s = p / 4

        if t == 0 then
            return a
        elseif t == 1 then
            return b
        else
            local postFix = 2 ^ (-10 * t) * math.sin((t - s) * (2 * math.pi) / p)
            return a + c * (postFix + 1)
        end
    end,

    -- Elastic In Out curve function
    elasticInOut = function(a, b, t)
        local c = b - a
        local p = 0.3
        local s = p / 4

        if t == 0 then
            return a
        elseif t == 1 then
            return b
        elseif t < 0.5 then
            local t2 = t * 2
            local postFix = 2 ^ (10 * (t2 - 1)) * math.sin((t2 - 1 + s) * (2 * math.pi) / p)
            return a + c * 0.5 * postFix
        else
            local t2 = t * 2 - 1
            local postFix = 2 ^ (-10 * t2) * math.sin((t2 - s) * (2 * math.pi) / p)
            return a + c * 0.5 * (postFix + 2)
        end
    end,

    -- Bounce Out curve function
    bounceOut = localBounceOut,

    -- Bounce In curve function
    bounceIn = localBounceIn,

    -- Bounce In Out curve function
    bounceInOut = function(a, b, t)
        if t < 0.5 then
            return a + (b - a) * 0.5 * localBounceIn(0, 1, t * 2)
        else
            return a + (b - a) * 0.5 * localBounceOut(0, 1, t * 2 - 1) + (b - a) * 0.5
        end
    end,

}

---
---Creates a new animation function.
---
---The returned function should be called with a time value between 0 and 1.
---
---@generic T
---@param entity EntityHandle # Entity to animate
---@param getter fun(self:EntityHandle):T # Function to get the current value
---@param setter fun(self:EntityHandle,vec:T) # Function to set the new value
---@param targetValue T # Value to animate to
---@param curveFunc fun(startValue:T,endValue:T,time:number):T # Animation curve
---@return fun(time:number):boolean # New animation function
function Animation:CreateAnimation(entity, getter, setter, targetValue, curveFunc)
    local startValue = getter(entity)

    local special = nil
    if IsVector(targetValue) then
        special = Vector
    elseif IsQAngle(targetValue) then
        special = QAngle
    end

    return function(t)
        local currentValue = getter(entity)
        if not special then
            currentValue = curveFunc(startValue, targetValue, t)
        else
            currentValue = special(
                curveFunc(startValue.x, targetValue.x, t),
                curveFunc(startValue.y, targetValue.y, t),
                curveFunc(startValue.z, targetValue.z, t)
            )
        end
        setter(entity, currentValue)

        if t >= 1 then
            setter(entity, targetValue)
            return true
        end
        return false
    end
end

---
---Animates a value over time on an entity.
---
---@generic T
---@param entity EntityHandle # Entity to animate
---@param getter fun(self:EntityHandle):T # Function to get the current value
---@param setter fun(self:EntityHandle,vec:T) # Function to set the new value
---@param targetValue T # Value to animate to
---@param curveFunc Animation.Curves|fun(startValue:T,endValue:T,time:number):T # Animation curve
---@param time number # Total time of the animation
---@param finishCallback? function # Callback that is called when the animation is finished
function Animation:Animate(entity, getter, setter, targetValue, curveFunc, time, finishCallback)
    local anim = self:CreateAnimation(entity, getter, setter, targetValue, curveFunc)
    local startTime = Time()

    entity:QuickThink(function()
        local t = RemapValClamped(Time(), startTime, startTime + time, 0, 1)
        if anim(t) then
            if finishCallback then
                finishCallback()
            end
            -- End think
            return
        else
            -- Continue think
            return 0
        end
    end)
end

---
---Animates a value over time on this entity.
---
---@generic T
---@param getter fun(self:EntityHandle):T # Function to get the current value
---@param setter fun(self:EntityHandle,vec:T) # Function to set the new value
---@param targetValue T # Value to animate to
---@param curveFunc Animation.Curves|fun(startValue:T,endValue:T,time:number):T # Animation curve
---@param time number # Total time of the animation
---@param finishCallback? function # Callback that is called when the animation is finished
function CBaseEntity:Animate(getter, setter, targetValue, curveFunc, time, finishCallback)
    Animation:Animate(self, getter, setter, targetValue, curveFunc, time, finishCallback)
end

return Animation.version