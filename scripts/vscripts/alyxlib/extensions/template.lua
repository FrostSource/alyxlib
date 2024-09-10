--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Provides point_template extension methods.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    ```lua
    require "alyxlib.extensions.template"
    ```
]]

local version = "v1.0.0"

---
---Spawn the template at the IO caller position, rotated around the caller.
---
---@param params IOParams
function CPointTemplate:ForceSpawnAtCaller(params)
    self:SetSpawnCallback(function (context, entities)
        if IsEntity(context, true) then
            ---@cast context EntityHandle
            local offset = context:GetAbsOrigin() - self:GetAbsOrigin()
            for _, ent in ipairs(entities) do
                if not ent:GetMoveParent() then
                    local newPos = ent:GetAbsOrigin() + offset
                    local oldAng = ent:GetAngles()
                    local relativeRotation = RotateOrientation(oldAng, context:GetAngles())
                    local newAng = RotateOrientation(relativeRotation, oldAng)

                    ent:SetOrigin(newPos)
                    ent:SetAbsAngles(newAng.x, newAng.y, newAng.z)
                    -- DebugDrawSphere(newPos, Vector(255,0,0), 255,8,true,60)
                    -- DebugDrawLine(newPos, newPos + newAng:Forward() * 32, 255,0,0,true,60)
                end
            end
        end
    end, params.caller)
    self:ForceSpawn()
end

return version