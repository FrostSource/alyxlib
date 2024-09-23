--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    This script searches for, and deletes, any extension fixed-up entities that appear to be duplicates.
    
    Duplication appears to be caused by addons being enabled after the extension addon,
    with more duplication occurring as more addons are enabled.

    Duplicates are detected by checking for increments in the "ex*d_" fix-up name pattern the extensions give.

    **This file is not loaded by default, load it with the following line:

    require("alyxlib.utils.extension_duplicate_fix")
]]

if thisEntity then
    require("alyxlib.utils.extension_duplicate_fix")
    return
end

---Make sure this is only done once
if _G.already_done_duplication_fix ~= nil then
    return
end
_G.already_done_duplication_fix = true

---@TODO Add options for refined checking

---Lua string pattern to detect extension names
local extension_name_pattern = "^ex%d+d_(.*)"

---Contains the unfixed name pointing to the extension prefix
---@type table<string, string>
local duplicates = {}

---List of duplicated entities to kill
---@type EntityHandle[]
local toKill = {}

local event_id

event_id = ListenToGameEvent("player_connect_full", function (params)
    -- Check if this has been done before, load fix
    local player = Entities:GetLocalPlayer()
    if player:Attribute_GetIntValue("already_done_duplication_fix", 0) ~= 0 then
        return
    end
    player:Attribute_SetIntValue("already_done_duplication_fix", 1)

    devprint("Searching for extension duplicates...")

    -- Total duplicates found, for debugging
    local count = 0

    local ent = Entities:First()
    while ent ~= nil do
        local name = ent:GetName()

        -- Get the name without the extension part
        local match = string.match(name, extension_name_pattern)
        if match then
            -- Get the extension part
            local ext = string.sub(name, 1, #name - #match)

            -- If we've already found this name then it might be a duplicate
            if duplicates[match] ~= nil then
                -- If it has a new extension prefix then it's a duplicate
                if ext ~= duplicates[match] then
                    -- Add it to the list to kill later
                    table.insert(toKill, ent)
                    devprint("\tFound duplicate to kill", ent:GetName())
                    count = count + 1
                end
            -- Otherwise this is the "original" entity, leave it untouched
            else
                devprint("\tFound base entity", ent:GetName())
                duplicates[match] = ext
            end
        end

        -- Get the next entity and continue
        ent = Entities:Next(ent)
    end

    -- After finding all duplicates we kill them
    for _, entToKill in ipairs(toKill) do
        if IsValidEntity(entToKill) then
            entToKill:Kill()
        end
    end

    -- Stop listening to player_activate to avoid this running again
    StopListeningToGameEvent(event_id)

    devprint("...Finished fixing extension duplicates")
end, nil)
