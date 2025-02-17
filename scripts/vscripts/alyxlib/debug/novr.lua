--[[
    v1.1.0
    https://github.com/FrostSource/alyxlib

    Adds functions and console commands to help debugging outside VR mode.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:

    require "alyxlib.debug.novr"
]]

local version = "v1.1.0"

---@class NoVR
NoVR = {}

---If the game starts in tools mode, [NoVR:EnableAllDebugging](lua://NoVR.EnableAllDebugging) is called.
NoVR.AutoStartInToolsMode = false

--#region Interactions

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

---
---Add an interaction class for the NoVR player to interact with.
---
---@param title string # Text to show in-game on the entity
---@param class string # Class to interact with
---@param mustBeHeld boolean # If the player must hold the use button, to avoid accidental activation
---@param input? string # Input to fire
---@param output? string|string[] # Output(s) to fire, if no input is specified
function NoVR:AddInteraction(title, class, mustBeHeld, input, output)
    table.insert(interactClasses, {
        title = title,
        class = class,
        hold = mustBeHeld,
        input = input,
        output = output,
    })
end

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

local function interactThink()

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

--#endregion Interactions

local cl_forwardspeed, cl_backspeed, cl_sidespeed

---
---Does the following:
---
---* Enables `buddha` mode
---* Gives all weapons and ammo `impulse 101`
---* Binds V to noclip toggling
---* Enables novr entity interaction
---
function NoVR:EnableAllDebugging()
    SendToConsole("buddha 1; impulse 101")
    NoVR:BindKey("V", "noclip")
    Player:SetContextThink("novrInteractThink", interactThink, 0)
end

---
---Undoes all operations performed by [NoVR:EnableAllDebugging](lua://NoVR.EnableAllDebugging)
---
---Except removing weapons.
---
function NoVR:DisableAllDebugging()
    SendToConsole("buddha 0")
    SendToConsole("unbind V")
    Player:SetContextThink("novrInteractThink", nil, 0)
end

ListenToPlayerEvent("novr_player", function (params)
    cl_forwardspeed = Convars:GetFloat("cl_forwardspeed")
    cl_backspeed = Convars:GetFloat("cl_backspeed")
    cl_sidespeed = Convars:GetFloat("cl_sidespeed")

    if NoVR.AutoStartInToolsMode and IsInToolsMode() then
        NoVR:EnableAllDebugging()
    end
end)

RegisterAlyxLibCommand("novr_enable_all_debugging", function (_)
    NoVR:EnableAllDebugging()
end, "Enables all novr debugging commands and bindings, like buddha, impulse 101 and V=noclip", 0)

RegisterAlyxLibCommand("novr_disable_all_debugging", function (_)
    NoVR:DisableAllDebugging()
end, "Undoes everything by novr_enable_all_debugging", 0)

local novr_vr_speed_on = false

RegisterAlyxLibCommand("novr_player_use_vr_speed", function (_, on)
    if on == nil then
        on = not novr_vr_speed_on
    end
    novr_vr_speed_on = truthy(on)

    if novr_vr_speed_on then
        Convars:SetFloat("cl_forwardspeed", 40)
        Convars:SetFloat("cl_backspeed", 40)
        Convars:SetFloat("cl_sidespeed", 40)
        Msg("NoVR->VR Move Speed ON")
    else
        Convars:SetFloat("cl_forwardspeed", cl_forwardspeed)
        Convars:SetFloat("cl_backspeed", cl_backspeed)
        Convars:SetFloat("cl_sidespeed", cl_sidespeed)
        Msg("NoVR->VR Move Speed OFF")
    end
end, "", 0)

---@alias KeyboardKey
---|"mouse1"
---|"mouse2"
---|"mouse3"
---|"mouse4"
---|"mouse5"
---|"A"
---|"B"
---|"C"
---|"D"
---|"E"
---|"F"
---|"G"
---|"H"
---|"I"
---|"J"
---|"K"
---|"L"
---|"M"
---|"N"
---|"O"
---|"P"
---|"Q"
---|"R"
---|"S"
---|"T"
---|"U"
---|"V"
---|"W"
---|"X"
---|"Y"
---|"Z"
---|"1"
---|"2"
---|"3"
---|"4"
---|"5"
---|"6"
---|"7"
---|"8"
---|"9"
---|"0"
---|"F1"
---|"F2"
---|"F3"
---|"F4"
---|"F5"
---|"F6"
---|"F7"
---|"F8"
---|"F9"
---|"F10"
---|"F11"
---|"F12"
---|"F13"
---|"F14"
---|"F15"
---|"F16"
---|"F17"
---|"F18"
---|"F19"
---|"F20"
---|"F21"
---|"F22"
---|"F23"
---|"F24"
---|"SPACE"
---|"ENTER"
---|"ESCAPE"
---|"LEFT"
---|"UP"
---|"RIGHT"
---|"DOWN"
---|"INS"
---|"DEL"
---|"HOME"
---|"END"
---|"PGUP"
---|"PGDN"
---|"CAPSLOCK"
---|"TAB"
---|"NUMLOCK"
---|"SCROLLLOCK"
---|"SEMICOLON"
---|"SHIFT"
---|"RSHIFT"
---|"CTRL"
---|"RCTRL"
---|"ALT"
---|"RALT"
---|"BACKSPACE"
---|"PAUSE"
---|"'"
---|"["
---|"]"
---|","
---|"."
---|"\\"
---|"/"
---|"KP_0"
---|"KP_1"
---|"KP_2"
---|"KP_3"
---|"KP_4"
---|"KP_5"
---|"KP_6"
---|"KP_7"
---|"KP_8"
---|"KP_9"
---|"KP_MULTIPLY"
---|"KP_DIVIDE"
---|"KP_MINUS"
---|"KP_PLUS"
---|"KP_ENTER"
---|"KP_DEL"

---@type { name: string, callback: function, key: string }[]
local novrBindings = {}

---
---Unbind all keys bound by [NoVR:BindKey](lua://NoVR.BindKey)
---
function NoVR:UnbindKeys()
    -- for _, binding in ipairs(novrBindings) do
    --     SendToConsole("unbind " .. binding.key)
    -- end

    -- For now just default binds to avoid unbinding standard keys
    SendToConsole("binddefaults")
end

---
---Bind a keyboard key to a callback function.
---
---@param key KeyboardKey
---@param callback fun()|string # Callback function or command string
---@param name? string # Optional name for the callback command
function NoVR:BindKey(key, callback, name)
    if type(callback) == "string" then
        SendToConsole("bind " .. key .. " " .. callback)
    else
        name = name or ("novr_keybind_" .. UniqueString())
        Convars:RegisterCommand(name, callback, "", 0)
        SendToConsole("bind " .. key .. " " .. name)
    end

    table.insert(novrBindings, {
        name = name,
        callback = callback,
        key = key
    })
end

ListenToGameEvent("server_shutdown", function()
    if #novrBindings > 0 then
        devprint2("Unbinding " .. #novrBindings .. " novr keys")
        NoVR:UnbindKeys()
    end
end, nil)

return version