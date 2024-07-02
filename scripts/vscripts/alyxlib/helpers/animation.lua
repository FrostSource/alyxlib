---@diagnostic disable: undefined-field
---@class Animation
Animation = {}

local localBounceOut = function(a, b, t)
    local c = math.abs(b - a)
    if t < (1 / 2.75) then
        return c * (7.5625 * t * t) + a
    elseif t < (2 / 2.75) then
        t = t - (1.5 / 2.75)
        return c * (7.5625 * t * t + 0.75) + a
    elseif t < (2.5 / 2.75) then
        t = t - (2.25 / 2.75)
        return c * (7.5625 * t * t + 0.9375) + a
    else
        t = t - (2.625 / 2.75)
        return c * (7.5625 * t * t + 0.984375) + a
    end
end

local localBounceIn = function(a, b, t)
    return b - localBounceOut(0, b - a, 1 - t) + a
end

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
        local c = math.abs(b - a)
        if t == 0 then return a end
        if t == 1 then return b end
        local p = 0.3 * c
        local s = p / 4
        t = t - 1
        return -(c * 2^(-10 * t) * math.sin((t - s) * (2 * math.pi) / p)) + a
    end,

    -- Elastic Out curve function
    elasticOut = function(a, b, t)
        local c = math.abs(b - a)
        if t == 0 then return a end
        if t == 1 then return b end
        local p = 0.3 * c
        local s = p / 4
        return c * 2^(-10 * t) * math.sin((t - s) * (2 * math.pi) / p) + b
    end,

    -- Elastic In Out curve function
    elasticInOut = function(a, b, t)
        local c = math.abs(b - a)
        if t == 0 then return a end
        if t == 1 then return b end
        t = t * 2
        local p = 0.3 * c
        local s = p / 4
        if t < 1 then
            t = t - 1
            return -0.5 * (c * 2^(-10 * t) * math.sin((t - s) * (2 * math.pi) / p)) + a
        else
            t = t - 1
            return c * 2^(-10 * t) * math.sin((t - s) * (2 * math.pi) / p) * 0.5 + b
        end
    end,

    -- Bounce Out curve function
    bounceOut = localBounceOut,

    -- Bounce In curve function
    bounceIn = localBounceIn,

    -- Bounce In Out curve function
    bounceInOut = function(a, b, t)
        if t < 0.5 then
            return localBounceIn(a, b, t * 2) * 0.5 + a
        else
            return localBounceOut(a, b, t * 2 - 1) * 0.5 + (b - a) * 0.5 + a
        end
    end,

}

---@generic T
---@param entity EntityHandle
---@param getter fun(self:EntityHandle):T
---@param setter fun(self:EntityHandle,vec:T)
---@param targetValue T
---@param curveFunc fun(startValue:T,endValue:T,time:number):T
---@return fun(time:number):boolean
function Animation:CreateAnimation(entity, getter, setter, targetValue, curveFunc)
    local startValue = getter(entity)
    local isNumber = type(targetValue) == "number"
    -- local _type
    -- if type(targetValue) == "number" then
    --     _type = "number"
    -- elseif IsVector(targetValue) then
    --     _type = "vector"
    -- elseif IsQAngle(targetValue) then
    --     _type = "qangle"
    -- end

    return function(t)
        local currentValue = getter(entity)
        currentValue = curveFunc(startValue, targetValue, t)
        -- if isNumber then
        --     currentValue = curveFunc(startValue, targetValue, t)
        -- else
        --     currentValue = Vector(
        --         curveFunc(currentValue.x, targetValue.x, t),
        --         curveFunc(currentValue.y, targetValue.y, t),
        --         curveFunc(currentValue.z, targetValue.z, t)
        --     )
        -- end
        setter(entity, currentValue)

        if t >= 1 then
            setter(entity, targetValue)
            return true
        end
        return false

        -- if isNumber then
        --     return abs(targetValue - currentValue) <= 0.001
        -- else
        --     return (targetValue - currentValue):Length() <= 0.001
        -- end
    end
end

---@generic T
---@param entity EntityHandle
---@param getter fun(self:EntityHandle):T
---@param setter fun(self:EntityHandle,vec:T)
---@param targetValue T
---@param curveFunc fun(startValue:T,endValue:T,time:number):T
---@param time number
---@param finishCallback? function
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

---@generic T
---@param getter fun(self:EntityHandle):T
---@param setter fun(self:EntityHandle,vec:T)
---@param targetValue T
---@param curveFunc fun(startValue:T,endValue:T,time:number):T
---@param time number
---@param finishCallback? function
function CBaseEntity:Animate(getter, setter, targetValue, curveFunc, time, finishCallback)
    Animation:Animate(self, getter, setter, targetValue, curveFunc, time, finishCallback)
end