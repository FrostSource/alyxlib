--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Extension for NPC entities.
    Some functions are specific to only one entity class such as `npc_combine_s`, check the individual function descriptions.

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "alyxlib.extensions.npc"
    ```
]]

require "alyxlib.globals"
require "alyxlib.extensions.entity"
require "alyxlib.extensions.entities"

local version = "v1.0.0"

---
---Schedule enum table for use with CAI_BaseNPC:StartSchedule().
---
Schedule = {
    ---@enum ScheduleType
    Type = {
        None = 0,
        WalkToGoalEntity = 1,
        RunToGoalEntity = 2,
        SetEnemyToGoalEntity = 3,
        WalkGoalPath = 4,
        RunGoalPath = 5,
        SetEnemyToGoalEntityANDRunToGoalEntity = 6,
        SetEnemyToGoalEntityANDWalkToGoalEntity = 7,
    },
    ---@enum ScheduleState
    State = {
        None = 0,
        Idle = 1,
        Alert = 2,
        Combat = 3,
    },
    ---@enum ScheduleInterruptability
    Interruptability = {
        General = 0,
        DamageOrDeath = 1,
        Death = 2,
        Combat = 3,
    }
}

---
---Create and start a new schedule for this NPC.
---
---@param state ScheduleState # The NPC state that should be set.
---@param type ScheduleType # The type of schedule to perform.
---@param interruptability ScheduleInterruptability # What should interrupt the NPC from the schedule.
---@param reacquire boolean # If the NPC should reacquire the schedule after being interrupted.
---@param goal EntityHandle|Vector # Worldspace position or entity goal (entity origin will be used).
---@return EntityHandle # The schedule entity.
function CAI_BaseNPC:StartSchedule(state, type, interruptability, reacquire, goal)

    local goalName

    if IsVector(goal) then
        goalName = DoUniqueString("schedule_positional_target")
    else
        goalName = goal:GetName()
    end

    local schedule = SpawnEntityFromTableSynchronous("aiscripted_schedule", {
        m_iszEntity = self:GetName(),
        schedule = type,
        forcestate = state,
        interruptability = interruptability,
        resilient = reacquire,
        goalent = goalName,
    })

    if IsVector(goal) then
        local target = SpawnEntityFromTableSynchronous("info_target", {
            origin = goal,
            targetname = goalName
        })
        -- parent target to schedule so it will be killed when schedule is
        target:SetParent(schedule, "")
    end

    schedule:EntFire("StartSchedule")

    return schedule

end

---
---Stops the given schedule for this NPC.
---
---@param schedule EntityHandle # The previously created schedule.
---@param dontKill? boolean # If true the schedule will not be killed at the same time.
function CAI_BaseNPC:StopSchedule(schedule, dontKill)
    if IsEntity(schedule, true) then
        schedule:EntFire("StopSchedule")
        if not dontKill then
            schedule:EntFire("Kill")
        end
    end
end

---Set state of the NPC.
---@param state ScheduleState
function CAI_BaseNPC:SetState(state)
    local schedule = self:StartSchedule(state, 0, 0, false, self)
end

---
---Get if this NPC has an enemy target.
---
---This function only works with entities that have `enemy` or `distancetoenemy` criteria.
---
---@return boolean # True if the NPC has an enemy target.
function CAI_BaseNPC:HasEnemyTarget()
    local criteria = self:GetCriteria()
    return criteria.enemy ~= nil or criteria.distancetoenemy ~= 16384
end

---
---Estimate the enemy that this NPC is fighting using its criteria values.
---
---This function only works with entities that have `enemy` criteria; "npc_combine_s", "npc_zombine", "npc_zombie_blind".
---
---@param distanceTolerance? number # Discrepancy allowed when comparing distance to enemy. Default 1
---@return EntityHandle? # Estimated enemy target.
function CAI_BaseNPC:EstimateEnemyTarget(distanceTolerance)
    distanceTolerance = distanceTolerance or 1
    local criteria = self:GetCriteria()
    local enemyClass = criteria.enemy

    if enemyClass then
        for _, npc in ipairs(Entities:FindAllByClassnameWithin(enemyClass, self:GetOrigin(), criteria.distancetoenemy)) do
            if npc ~= self then
                local dist = VectorDistance(npc:GetOrigin(), self:GetOrigin())
                if math.abs(dist - criteria.distancetoenemy) < distanceTolerance then
                    return npc
                end
            end
        end
    end
    return nil
end

---@alias RelationshipDisposition
---| "D_HT" # Hate
---| "D_FR" # Fear
---| "D_LI" # Like
---| "D_NU" # Neutral

---Set the relationship of this NPC with a targetname or classname.
---@param target string # Targetname or classname.
---@param disposition RelationshipDisposition # Type of relationship with `target`.
---@param priority? number # How much the Subject(s) should Like/Hate/Fear the Target(s). Higher priority = stronger feeling. Default is 0.
function CAI_BaseNPC:SetRelationship(target, disposition, priority)
    priority = priority or 0
    self:EntFire("SetRelationship", target .. " " .. disposition .. " " .. priority)
end
