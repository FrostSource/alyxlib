--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.debug.commands"
]]

local version = "v1.0.0"

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
    for name, help in pairs(alyxlibCommands) do
        Msg(name .. " - " .. help .. "\n")
    end
    Msg("\n")
end, "Displays all AlyxLib commands in the console", 0)

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
        print("Must provide a valid entity table string, e.g. table: 0x0012b03")
        return
    end

    if colon == ":" then
        hash = tblpart .. colon .. " " .. hash
    elseif tblpart == "table:" then
        hash = tblpart .." ".. colon
    elseif tblpart:find("table:") then
        hash = tblpart
    elseif tblpart == "table" then
        hash = "table: " .. colon
    else
        hash = "table: " .. tblpart
    end

    local foundEnt = nil
    local ent = Entities:First()
    while ent ~= nil do
        if tostring(ent) == hash then
            foundEnt = ent
            break
        end
        ent = Entities:Next(ent)
    end

    if foundEnt then
        print("Info for " .. tostring(foundEnt))
        prints("\tClassname", foundEnt:GetClassname())
        prints("\tName", foundEnt:GetName())
        prints("\tParent", foundEnt:GetMoveParent())
        prints("\tModel", foundEnt:GetModelName())
    else
        print("Could not find any entity in the world matching " .. hash)
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
    end, "", 0)

    RegisterAlyxLibCommand("ent_code", function (_, name, ...)
        if not name then
            warn("Must provide entity name!")
            return
        end

        local ents = Entities:FindAllByName(name)
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
    end, "", 0)

-- end

return version