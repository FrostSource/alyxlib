
---@class NoVrInteractClass
---@field class string
---@field hold? boolean
---@field input? string
---@field parameter? string # Optional parameter for input.
---@field output? string|string[]
---@field title? string # Text to show in-game.
---@field position? Vector|string|fun(ent:EntityHandle):Vector # Offset, attachment name, function that returns world position.
---@field weight? number # Weight for this class to assign importance next to others.

---@TODO Change to convar
local INTERACT_DISTANCE = 100

---@type NoVrInteractClass[]
local interactClasses =
{
    {
        title = "Unlock",
        class = "prop_door_rotating_physics",
        hold = true,
        input = "Unlock",
        position = "handle",
    },
    {
        title = "Hack",
        class = "info_hlvr_holo_hacking_plug",
        hold = true,
        output = "OnHackSuccess",--"OnPuzzleSuccess"
    },
    {
        title = "Press",
        class = "func_physical_button",
        hold = false,
        output = { "OnIn", "OnPressed" },
    },
    {
        title = "Deactivate Mine",
        class = "item_hlvr_weapon_tripmine",
        hold = true,
        input = "DeactivateMine",
        weight = 1.1
    },
    {
        title = "Hand Pose",
        class = "prop_handpose",
        hold = true,
        output = "OnHandPosed",
    },
    {
        title = "Complete Toner Puzzle",
        class = "info_hlvr_toner_port",
        hold = true,
        input = "SetComplete",
        weight = 1.1
    },
}

local isUsePressed = false
local usePressTime = 0

local HOLD_TIME = 0.8

local DISTANCE_WEIGHT = 1
local LOS_WIGHT = 1.3

---Get text that should show for an entity.
---@param data NoVrInteractClass
---@return string
local function getText(data)
    return (data.hold and "Hold to " or "") .. data.title or data.input or data.output
end

---Get position for text.
---@param entity EntityHandle
---@param data NoVrInteractClass
---@return Vector
local function getTextPosition(entity, data)
    if type(data.position) == "string" then
        return entity:GetAttachmentOrigin(entity:ScriptLookupAttachment(data.position))
    elseif type(data.position) == "function" then
        return data.position(entity)
    elseif IsVector(data.position) then
        return entity:GetAbsOrigin() + data.position
    end
    return entity:GetAbsOrigin()
end

---Activate an entity
---@param entity EntityHandle
---@param data NoVrInteractClass?
local function activateEntity(entity, data)
    if data == nil then
        for _, interactData in ipairs(interactClasses) do
            if interactData.class == entity:GetClassname() then
                data = interactData
                break
            end
        end
    end

    if data == nil then
        return
    end

    if data.input then
        entity:EntFire(data.input, data.parameter)
    else
        if type(data.output) == "table" then
            for _, output in ipairs(data.output) do
                entity:FireOutput(output, nil, nil, data.parameter, 0)
            end
        else
            entity:FireOutput(data.output, nil, nil, data.parameter, 0)
        end
    end
    debugoverlay:Text(getTextPosition(entity, data), 0, getText(data), 0, 50, 255, 50, 255, 2)
end

local function think()

    ---@type EntityHandle
    local bestEnt = nil
    ---@type number
    local bestScore = 0
    
    ---@type NoVrInteractClass
    local data = nil

    for _, interactData in ipairs(interactClasses) do
        -- local nearestEnt = Entities:FindByClassnameNearest(interactData.class, Player:EyePosition(), INTERACT_DISTANCE)
        local nearestEnts = Entities:FindAllByClassnameWithin(interactData.class, Player:EyePosition(), INTERACT_DISTANCE)

        for _, nearestEnt in ipairs(nearestEnts) do

            if nearestEnt then
                local dist = VectorDistance(nearestEnt:GetOrigin(), Player:EyePosition())
                local normalizedDist = 1 - (math.min(dist / INTERACT_DISTANCE, 1))
                local dot = Player:EyeAngles():Forward():Dot((nearestEnt:GetAbsOrigin() - Player:EyePosition()):Normalized())
                local score = (normalizedDist * DISTANCE_WEIGHT) + (dot * LOS_WIGHT) + (interactData.weight or 1)
                -- debugoverlay:Text(nearestEnt:GetAbsOrigin(), 1, tostring(score) .. " " .. tostring(dot), 0, 255, 0, 0, 255, 0.1)
                if score > bestScore then
                    bestEnt = nearestEnt
                    bestScore = score
                    data = interactData
                end
            end

        end

    end

    if bestEnt then
        local text = getText(data)
        local pos = getTextPosition(bestEnt, data)

        debugoverlay:Text(pos, 0, text, 0, 255, 255, 255, 255, 0.1)


        if Player:IsVRControllerButtonPressed(5) then
            if not isUsePressed then
                isUsePressed = true
                usePressTime = Time()

                if not data.hold then
                    activateEntity(bestEnt, data)
                end
            end

            if (Time() - usePressTime) > HOLD_TIME then
                activateEntity(bestEnt, data)
                usePressTime = math.huge
            end
        else
            if isUsePressed then
                isUsePressed = false
            end
        end

    end

    return 0.1
end

local cl_forwardspeed, cl_backspeed, cl_sidespeed

ListenToPlayerEvent("novr_player", function (params)
    SendToConsole("buddha 1; impulse 101;")
    Player:SetContextThink("think", think, 0)

    cl_forwardspeed = Convars:GetFloat("cl_forwardspeed")
    cl_backspeed = Convars:GetFloat("cl_backspeed")
    cl_sidespeed = Convars:GetFloat("cl_sidespeed")
end)

Convars:RegisterCommand("novr_player_use_vr_speed", function (_, on)
    if truthy(on) then
        Convars:SetFloat("cl_forwardspeed", 40)
        Convars:SetFloat("cl_backspeed", 40)
        Convars:SetFloat("cl_sidespeed", 40)
    else
        Convars:SetFloat("cl_forwardspeed", cl_forwardspeed)
        Convars:SetFloat("cl_backspeed", cl_backspeed)
        Convars:SetFloat("cl_sidespeed", cl_sidespeed)
    end
end, "", 0)