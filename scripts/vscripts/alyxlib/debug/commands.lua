--[[
    v1.1.0
    https://github.com/FrostSource/alyxlib

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.debug.commands"
]]

local version = "v1.1.0"

local alyxlibCommands = {}

---
---Registers a command for the AlyxLib library.
---
---@param name string # Name of the command that will be given in the console.
---@param func fun(_:string, ...:string) # Function to run when the command is called.
---@param helpText? string # Description of the command.
---@param flags? number # Flags for the command.
function RegisterAlyxLibCommand(name, func, helpText, flags)
    helpText = helpText or "[No description]"
    Convars:RegisterCommand(name, func, helpText, flags or 0)
    alyxlibCommands[name] = helpText
end

---
---Registers a new AlyxLib console variable.
---
---@param name string # Name of the convar that will be given in the console.
---@param defaultValue string # Default value of the convar.
---@param helpText? string # Description of the convar.
---@param flags? integer # Flags for the convar.
function RegisterAlyxLibConvar(name, defaultValue, helpText, flags)
    helpText = helpText or "[No description]"
    Convars:RegisterConvar(name, defaultValue, helpText, flags or 0)
    alyxlibCommands[name] = "Default: "..tostring(defaultValue)..", "..helpText
end

Convars:RegisterCommand("alyxlib_commands", function (_, ...)
    local maxNameLen = 0
    for name in pairs(alyxlibCommands) do
        maxNameLen = math.max(maxNameLen, #name)
    end

    local names = {}
    for name in pairs(alyxlibCommands) do
        table.insert(names, name)
    end

    table.sort(names)

    for _, name in ipairs(names) do
        local desc = alyxlibCommands[name]
        local padding = ""
        for i = 1, maxNameLen - #name do
            padding = padding .. " "
        end
        Msg(name .. padding .. " - " .. desc .. "\n")
    end
end, "Displays all AlyxLib commands in the console", 0)

---
---Searches for an addon by name, short name, or workshop ID.
---
---@param searchPattern string
---@return AlyxLibAddon?
local function findAddon(searchPattern)
    for _, addon in ipairs(AlyxLibAddons) do
        if string.find(addon.name, searchPattern)
        or string.find(addon.shortName, searchPattern)
        or string.find(addon.workshopID, searchPattern) then
            return addon
        end
    end
end

RegisterAlyxLibCommand("alyxlib_info", function ()
    Msg("AlyxLib " .. ALYXLIB_VERSION .. "\n")
    Msg("Init Addons: " .. TableSize(SERVER_ADDONS) .. "\n")
    Msg("AlyxLib Addons: " .. #AlyxLibAddons .. "\n")
    Msg("Total Addons: " .. #GetEnabledAddons())
end, "Prints AlyxLib version and addon information")

RegisterAlyxLibCommand("alyxlib_addons", function ()
    if #AlyxLibAddons == 0 then
        Msg("No addons enabled are made with AlyxLib")
        return
    end

    Msg("Enabled addons made with AlyxLib:\n")

    for _, addon in ipairs(AlyxLibAddons) do
        Msg("\t" .. addon.name .. " " .. addon.version .. "\n")
    end
end, "Lists addons made and registered with AlyxLib")

RegisterAlyxLibCommand("alyxlib_diagnose", function (_, searchPattern)
    Msg("\n")

    -- Standard AlyxLib and game info
    Msg("AlyxLib " .. ALYXLIB_VERSION .. "\n")
    Msg("VR Enabled: " .. (IsVREnabled() and "Yes" or "No") .. "\n")
    Msg("Map: " .. GetMapName() .. "\n")
    if IsEntity(Player, true) then
        if IsVREnabled() then
            Msg("VR Controller Type: " .. Input:GetControllerTypeDescription(Player:GetVRControllerType()) .. "\n")
            Msg("VR Move Type: " .. vlua.find(PlayerMoveType, Player:GetMoveType()) .. "(" .. Player:GetMoveType() .. ")\n")
        end
    else
        Msg("Player does not exist!\n")
    end

    if searchPattern == nil then
        Msg("\nTo run diagnostics for an addon, type \"alyxlib_diagnose <addon_name>\"\n")
        return
    end

    local addon = findAddon(searchPattern)

    if not addon then
        warn("No addon exists matching \"" .. searchPattern .. "\"")
        return
    end

    Msg("Running diagnostics for addon \"" .. addon.name .. "\" " .. addon.version .. "\n")

    if not addon.diagnosticFunction then
        warn("Addon \"" .. addon.name .. "\" does not have a diagnostic function")
    else
        local success, result, message = pcall(addon.diagnosticFunction)

        if not success then
            warn("Failed to run diagnostics: " .. result)
        else
            local messages = nil
            if type(message) == "string" then
                messages = {message}
            elseif type(message) == "table" then
                messages = message
            else
                messages = {}
            end

            if result == true then
                -- Use custom success message if returned
                Msg("Diagnostic result: " .. (messages[1] or "Success") .. "\n")
            else
                -- Print all error messages
                Msg("Diagnostic result: Failed\n")
                for _, msg in ipairs(messages) do
                    Msg("\t" .. msg .. "\n")
                end
            end
        end

    end

    Msg("\n")

end, "Runs diagnostics for an addon")

---
---Prints all entities in the map, along with any supplied property patterns.
---
---E.g. print_all_ents getname mass health
---
---If no arguments are supplied then the default properties are used: GetClassname, GetName, GetModelName
---
RegisterAlyxLibCommand("print_all_ents", function (_, ...)
    local properties = nil
    properties = {...}
    if #properties == 0 then properties = nil end
    Debug.PrintAllEntities(properties)
end, "Prints all entities existing in the map")

---
---Prints all new entities in the map since `print_all_ents` was called, along with any supplied property patterns.
---
---E.g. print_diff_ents getname mass health
---
---If no arguments are supplied then the default properties are used: GetClassname, GetName, GetModelName
---
RegisterAlyxLibCommand("print_diff_ents", function (_, ...)
    local properties = nil
    properties = {...}
    if #properties == 0 then properties = nil end
    Debug.PrintDiffEntities(properties)
end, "Prints all new entities in the map since `print_all_ents` was called", 0)

---
---Prints all entities within a given radius around the player, along with any supplied property patterns.
---
---E.g. print_nearby_ents 100 getname mass
---
---If no radius is supplied then the default radius of 256 is used.
---If no properties are supplied then the default properties are used: GetClassname, GetName, GetModelName
---
RegisterAlyxLibCommand("print_nearby_ents", function (_, radius, ...)

    local properties = nil
    if radius == nil or tonumber(radius) then
        properties = {...}
    else
        properties = {radius, ...}
    end

    if #properties == 0 then properties = nil end
    Debug.PrintAllEntitiesInSphere(Entities:GetLocalPlayer():GetOrigin(), tonumber(radius) or 256, properties)
end, "Prints all entities within a given radius around the player", 0)

---
---Prints all entities with class, name or model matching a `pattern`, along with any supplied property patterns.
---
---E.g. print_ents physics getname mass
---E.g. print_ents box.vmdl getname mass
---
---If no properties are supplied then the default properties are used: GetClassname, GetName, GetModelName
---
RegisterAlyxLibCommand("print_ents", function (_, pattern, ...)

    if pattern == nil then
        warn("Must supply at least a pattern to search for, e.g. prints_ents prop_physics")
        return
    end

    local properties = nil
    properties = {...}
    if #properties == 0 then properties = nil end

    Debug.PrintEntities(pattern, false, false, properties)
end, "Prints all entities with class, name or model matching a pattern", 0)

---
---Show the position of an entity relative to the player using debug drawing.
---
RegisterAlyxLibCommand("ent_show", function (_, name)
    Debug.ShowEntity(name)
end, "Draws a debug line from the player to any entities with a name", 0)

---
---Print the mass of an entity.
---
RegisterAlyxLibCommand("ent_mass", function (_, pattern)
    local ent = Debug.FindEntityByPattern(pattern)
    if not ent then
        warn("Could not find entity with pattern '"..pattern.."'")
        return
    end

    prints(Debug.EntStr(ent), "mass:", ent:GetMass())
end, "Prints the mass of an entity", 0)

---
---Quickly draw a sphere at a position with a radius.
---
RegisterAlyxLibCommand("sphere", function (_, x, y, z, r)
    x = tonumber(x) or 0
    y = tonumber(y) or 0
    z = tonumber(z) or 0
    r = tonumber(r) or 16

    DebugDrawSphere(Vector(x, y, z), Vector(255, 255, 255), 255, r, false, 10)

end, "Draws a debug sphere at 3D position with a radius", 0)

---
---Prints all current context criteria for an entity
---
RegisterAlyxLibCommand("print_ent_criteria", function (_, pattern)
    local ent = Debug.FindEntityByPattern(pattern)
    if not ent then
        warn("Couldn't find entity with pattern '"..pattern.."'")
        return
    end

    ent:PrintCriteria()
end, "Prints all current context criteria for an entity", 0)

---
---Prints context criteria for an entity except for values saved using storage.lua
---
RegisterAlyxLibCommand("print_ent_base_criteria", function (_, pattern)
    local ent = Debug.FindEntityByPattern(pattern)
    if not ent then
        warn("Couldn't find entity with pattern '"..pattern.."'")
        return
    end

    ent:PrintBaseCriteria()
end, "Prints context criteria for an entity except for values saved using storage.lua", 0)

---
---Heals the player by a given amount
---
RegisterAlyxLibCommand("healme", function (_, amount)

    amount = tonumber(amount)

    if not amount then
        warn("Must provide a health amount")
        return
    end

    Player:SetHealth(amount)
end, "Heals the player by a given amount", 0)

---
---Prints info for an entity by its table address
---
RegisterAlyxLibCommand("ent_find_by_address", function (_, tblpart, colon, hash)
    if tblpart == nil and colon == nil and hash == nil then
        Msg("Must provide a valid entity table string, e.g. 'table: 0x0012b03'\n")
        return
    end

    local foundEnt = Debug.FindEntityByHandleString(tblpart, colon, hash)

    if foundEnt then
        Msg("Info for " .. tostring(foundEnt).."\n")
        Msg("\tClassname" .. foundEnt:GetClassname().."\n")
        Msg("\tName" .. foundEnt:GetName().."\n")
        Msg("\tParent" .. foundEnt:GetMoveParent().."\n")
        Msg("\tModel" .. foundEnt:GetModelName())
    else
        Msg("Could not find any entity matching '" .. hash .. "'")
    end
end, "Prints info for an entity by its table address", 0)

local symbols = {"and","break","do","else","elseif","end","false","for","function","if","in","local","nil","not","or","repeat","return","then","true","until","while"}

-- if IsInToolsMode() then

    ---Collates a string of Lua code.
    ---@param ... string
    ---@return string
    local function excode(...)

        local firstToken = true
        local firstStringChar = false
        local insideString = false
        local code = ""
        for _, token in ipairs({...}) do
            -- If the token has a space, assume it's a double quote string
            if not firstToken and token:find(" ") then
                code = code .. '"' .. token .. '"'
            else
                -- String tokens need spaces between them
                if token == "'" then
                    insideString = not insideString
                    firstStringChar = true
                    code = code .. token
                elseif insideString then
                    if firstStringChar then
                        code = code .. token
                        firstStringChar = false
                    else
                        code = code .. " " .. token
                    end
                -- Special tokens need spaces between them
                elseif (vlua.find(symbols, token) or token:sub(#token,#token):match("%d")) then
                    code = code .. " " .. token .. " "
                else
                    code = code .. token
                end
            end
            firstToken = false
        end
        return code
    end

    ---
    ---Executes Lua code.
    ---
    ---E.g. code print('Hello world!')
    ---
    ---Double quotes are not recognized.
    ---
    RegisterAlyxLibCommand("code", function(_, ...)
        local code = excode(...)

        if IsInToolsMode() then
            print("Doing code:", code)
        end

        local f,err = load(code)
        if f == nil then
            print("Invalid code:", err)
        else
            f()
        end
    end, "Executes arbitrary Lua code in global scope", 0)

    RegisterAlyxLibCommand("ent_code", function (_, name, ...)
        if not name then
            warn("Must provide entity name!")
            return
        end

        local ents = Debug.FindAllEntitiesByPattern(name, true)
        local code = excode(...)

        if IsInToolsMode() then
            print("Doing code on entities named ("..name.."):", code)
        end

        for _, ent in ipairs(ents) do
            local f,err = load(code, nil, nil, ent:GetOrCreatePrivateScriptScope())
            if f == nil then
                print("Invalid code:", err)
            else
                f()
            end
        end
    end, "Executes arbitrary Lua code on all entities with the given name", 0)

-- end

return version