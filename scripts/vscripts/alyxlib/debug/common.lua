--[[
    v2.1.0
    https://github.com/FrostSource/alyxlib

    Debug utility functions.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:

    require "alyxlib.debug.common"
]]
require "alyxlib.globals"
require "alyxlib.extensions.entity"
require "alyxlib.math.common"

Debug = {}
Debug.version = "v2.1.0"

---
---Finds the first entity whose name, class or model matches `pattern`.
---
---`pattern` can also be an entity handle string, e.g. `0x0026caf8`
---
---@param pattern string # The search pattern to look for.
---@param exact boolean? # If true the pattern must match exactly, otherwise wildcards will be used.
---@return EntityHandle
function Debug.FindEntityByPattern(pattern, exact)

    if Debug.IsEntityHandleString(pattern) then
        return Debug.FindEntityByHandleString(pattern)
    end

    local ent = nil
    ent = Entities:FindByName(nil, pattern)
    if ent == nil then
        ent = Entities:FindByClassname(nil, pattern)
        if ent == nil then
            ent = Entities:FindByModel(nil, pattern)
        end
    end

    if ent == nil and not exact then
        local wildpattern = "*"..pattern.."*"
        ent = Entities:FindByName(nil, wildpattern)
        if ent == nil then
            ent = Entities:FindByClassname(nil, wildpattern)
            if ent == nil then
                ent = Entities:FindByModelPattern(pattern)
            end
        end
    end

    return ent
end

---
---Finds all entities whose name, class or model match `pattern`.
---
---`pattern` can also be an entity handle string, e.g. `0x0026caf8`
---
---@param pattern string # The search pattern to look for.
---@param exact boolean? # If true the pattern must match exactly, otherwise wildcards will be used.
---@return EntityHandle[]
function Debug.FindAllEntitiesByPattern(pattern, exact)
    local ents = {}

    if Debug.IsEntityHandleString(pattern) then
        return {Debug.FindEntityByHandleString(pattern)}
    end

    ents = ArrayAppend(ents, Entities:FindAllByName(pattern))
    ents = ArrayAppend(ents, Entities:FindAllByClassname(pattern))
    ents = ArrayAppend(ents, Entities:FindAllByModel(pattern))

    if #ents == 0 and not exact then
        local wildpattern = "*"..pattern.."*"
        ents = ArrayAppend(ents, Entities:FindAllByName(wildpattern))
        ents = ArrayAppend(ents, Entities:FindAllByClassname(wildpattern))
        ents = ArrayAppend(ents, Entities:FindAllByModelPattern(pattern))
    end

    return ents
end

---
---Prints a formated indexed list of entities with custom property information.
---Also links children with their parents by displaying the index alongside the parent for easy look-up.
---
---    Debug.PrintEntityList(ents, {"getclassname", "getname", "getname"})
---
---If no properties are supplied the default properties are used: GetClassname, GetName, GetModelName
---If an empty property table is supplied only the base values are shown: Index, Handle, Parent
---Property patterns do not need to be functions.
---
---@param list EntityHandle[] # List of entities to print.
---@param properties string[] # List of property patterns to search for.
function Debug.PrintEntityList(list, properties)

    if #list == 0 then
        warn("No entities to print")
        return
    end

    properties = properties or {"GetClassname", "GetName", "GetModelName"}

    local lenIndex  = 0
    local lenHandle = 0
    local lenParent = #"[none]"

    ---Values of the properties found in the entities
    ---@type any[][]
    local propertyValues = {}
    ---Metadata about the properties found matching the property patterns
    ---@type { name: string, func: function?, max: number }[]
    local propertyMetaData = {}

    ---@type string[]
    local headerNames = {"","Handle"}
    local headerSeparators = {"", "------"}
    headerNames[3 + #properties] = "Parent"
    headerSeparators[3 + #properties] = "------"

    ---@param e EntityHandle
    local function generate_parent_str(e)
        local parFormat = "%-"..lenIndex.."s %s, %s"
        local i = vlua.find(list, e)
        return parFormat:format("["..(i or "/").."]", string.gsub(tostring(e), "table: ", ""), e:GetClassname())
    end

    for index, ent in ipairs(list) do
        lenIndex  = max(lenIndex, #("["..index.."]") )
        lenHandle = max(lenHandle, #string.gsub(tostring(ent), "table: ", "") )
        if ent:GetMoveParent() then
            lenParent = max(lenParent, #generate_parent_str(ent:GetMoveParent()))
        end

        -- Create new property table for this entity
        propertyValues[index] = {}

        for propertyIndex, propertyName in ipairs(properties) do
            if propertyMetaData[propertyIndex] == nil then
                propertyMetaData[propertyIndex] = { name = propertyName, func = nil, max = #propertyName }
                headerNames[2 + propertyIndex] = propertyName
                headerSeparators[2 + propertyIndex] = string.rep("-", #propertyName)
            end
            local key, value = SearchEntity(ent, propertyName)
            -- Capture the first function matching the property pattern
            if key ~= nil and propertyMetaData[propertyIndex].func == nil then
                propertyMetaData[propertyIndex] = { name = key, func = value, max = #key }
                -- Add the name and separator for property to be unpacked later
                headerNames[2 + propertyIndex] = key
                headerSeparators[2 + propertyIndex] = string.rep("-", #key)
            end

            -- Find the value of the property

            ---@type any
            local foundValueInEntity = "nil"
            if propertyMetaData[propertyIndex] ~= nil then
                if type(propertyMetaData[propertyIndex].func) == "function" then
                    local s, result = pcall(propertyMetaData[propertyIndex].func, ent)
                    if s then
                        foundValueInEntity = result
                    end
                else
                    foundValueInEntity = ent[propertyName]
                end
            end

            if IsVector(foundValueInEntity) then
                propertyValues[index][propertyIndex] = Debug.SimpleVector(foundValueInEntity)
            else
                propertyValues[index][propertyIndex] = tostring(foundValueInEntity)
            end

            -- Track the biggest value length
            propertyMetaData[propertyIndex].max = max(propertyMetaData[propertyIndex].max, #propertyValues[index][propertyIndex])
        end
    end

    -- Create the format string with correct padding
    lenHandle = lenHandle + 1
    local formatStr   = "%-"..lenIndex.."s %-"..lenHandle.."s"
    for propertyIndex, propertyTable in ipairs(propertyMetaData) do
        formatStr = formatStr .. " | %-"..propertyTable.max.."s"
    end
    formatStr = formatStr .. " | %-"..lenParent.."s"

    print()
    print(string.format(formatStr,unpack(headerNames)))
    print(string.format(formatStr,unpack(headerSeparators)))
    for index, ent in ipairs(list) do
        local parent_str = ""
        if ent:GetMoveParent() then
            parent_str = generate_parent_str(ent:GetMoveParent())
        end

        propertyValues[index][#propertyValues[index]+1] = parent_str
        print(string.format(formatStr, "["..index.."]", string.gsub(tostring(ent), "table: ", ""), unpack(propertyValues[index]) ))
    end
    print()
end

local cachedEntities = {}
---
---Prints information about all existing entities.
---
---@param properties? string[] # List of property patterns to search for when displaying entity information.
function Debug.PrintAllEntities(properties)
    properties = properties or {"GetClassname", "GetName", "GetModelName"}
    local list = {}
    local e = Entities:First()
    while e ~= nil do
        list[#list+1] = e
        e = Entities:Next(e)
    end
    cachedEntities = list
    Debug.PrintEntityList(list, properties)
end

---
---Prints information about any new entities since the last time `Debug.PrintAllEntities` was called.
---
---@param properties? string[] # List of property patterns to search for when displaying entity information.
function Debug.PrintDiffEntities(properties)
    properties = properties or {"GetClassname", "GetName", "GetModelName"}
    local list = {}
    local e = Entities:First()
    while e ~= nil do
        if not vlua.find(cachedEntities, e) then
            list[#list+1] = e
        end
        e = Entities:Next(e)
    end
    Debug.PrintEntityList(list, properties)
end

---
---Print entities matching a search string.
---
---Searches name, classname and model name.
---
---@param search string # Search string, may include `*`.
---@param exact boolean # If the search should match exactly or part of the name.
---@param dont_include_parents boolean # Parents won't be included in the results.
---@param properties? string[] # List of property patterns to search for when displaying entity information.
function Debug.PrintEntities(search, exact, dont_include_parents, properties)
    -- Get all matching ents
    local preents = {}
    for _, value in ipairs(Debug.FindAllEntitiesByPattern(search, exact)) do
        preents[#preents+1] = value
        if not dont_include_parents then
            vlua.extend(preents, value:GetParents())
        end
    end

    -- Filter duplicates
    local ents = {}
    for _, ent in pairs(preents) do
        if not vlua.find(ents, ent) then
            ents[#ents+1] = ent
        end
    end

    if #ents == 0 then
        print("No entities found with pattern '"..search.."'")
        return
    end

    Debug.PrintEntityList(ents, properties)
end

---
---Prints information about all entities within a sphere.
---
---@param origin Vector # Position to search for entities at.
---@param radius number # Max radius to find entities within.
---@param properties? string[] # List of property patterns to search for when displaying entity information.
function Debug.PrintAllEntitiesInSphere(origin, radius, properties)
    Debug.PrintEntityList(Entities:FindAllInSphere(origin, radius), properties)
end

---Turns newlines into spaces.
---@param str string
local function format_string(str)
    str = str:gsub('\n',' ')
    return str
end

---If 'FDesc' key should be be ignored in printed tables.
local ignore_fdesc = true
---Maximum number of keys Debug.PrintTable can print before force exiting.
local bailout_count = 9000

-- Used in Debug.PrintTable
local current_recursion_level = 0
local current_print_count = 0

local function printKeyValue(key, value, prefix)
    prefix = prefix or ""
    local vs = (type(value) == "string" and ("\"" .. tostring(value) .. "\"") or tostring(value))
    local ts = " ("..(IsEntity(value) and ("entity "..Debug.EntStr(value)) or type(value))..")"
    print( string.format( "\t%s%-32s %s", prefix, key, "= " .. format_string(vs) .. ts ) )
end

-- local function table_level(level, count, m)
--     local tbl = {}
--     local val
--     m = m or level
--     for i = 1, count do
--         if level == 0 then
--             val = RandomFloat(0,10000)
--         else
--             val = table_level(level - 1, count, m)
--         end
--         tbl[DoUniqueString("level"..(m - level))] = val
--     end
--     return tbl
-- end
-- local test_table = table_level(5, 10)

---
---Prints the keys/values of a table and any tested tables.
---
---This is different from `DeepPrintTable` in that it will not print members of entity handles.
---
---@param tbl table # Table to print
---@param prefix? string # Optional prefix for each line
---@param ignore? any[] # Optional nested tables to ignore
---@param meta? boolean # If meta tables should be printed
---@param customIterator? function # Optional custom iterator to use (default=pairs)
function Debug.PrintTable(tbl, prefix, ignore, meta, customIterator)
    if type(tbl) ~= "table" then return end
    prefix = prefix or ""
    ignore = ignore or {tbl}
    customIterator = customIterator or pairs
    print(prefix.."{")
    for key, value in customIterator(tbl) do
        -- Return up a level
        if current_print_count >= bailout_count or current_print_count == -1 then
            if current_print_count >= bailout_count then
                print("!! Debug.PrintTable bailing out after "..current_print_count.." occurrences! current_recursion_level = "..current_recursion_level)
                current_print_count = -1
            end
            if current_recursion_level == 0 then break end
            return
        end
        if not ignore_fdesc or key ~= "FDesc" then
            current_print_count = current_print_count + 1
            printKeyValue(key, value, prefix)
            if type(value) == "table" and not IsEntity(value) and not vlua.find(ignore, value) then
                table.insert(ignore, value)
                current_recursion_level = current_recursion_level + 1
                Debug.PrintTable(value, prefix.."\t", ignore, meta)
                current_recursion_level = current_recursion_level - 1
            end
        end
    end
    if meta then
        local foundmeta = getmetatable(tbl)
        if foundmeta then
            print( string.format( "\t%s%-32s %s", prefix, "[#metatable]", "", "" ))
            table.insert(ignore, foundmeta)
            Debug.PrintTable(foundmeta, prefix.."\t", ignore, meta)
        end
    end
    if current_print_count ~= -1 then
        print(prefix.."}")
    end
    if current_recursion_level <= 0 then
        current_recursion_level = 0
        current_print_count = 0
    end
end

---
---Prints the keys/values of a table but not any tested tables.
---
---@param tbl table # Table to print.
function Debug.PrintTableShallow(tbl)
    if type(tbl) ~= "table" then return end
    print("{")
    for key, value in pairs(tbl) do
        printKeyValue(key, value)
    end
    print("}")
end

function Debug.PrintList(tbl, prefix)
    local m = 0
    prefix = prefix or ""
    for key, value in pairs(tbl) do
        m = max(m, #tostring(key)+1)
    end
    m = 0
    local frmt = "%"..m.."s  %s"
    for key, value in pairs(tbl) do
        if type(key) == "number" then
            print(prefix..frmt:format(key..".", value))
        else
            print(prefix..frmt:format(key, value))
        end
    end
end

---
---Draws a debug line to an entity in game.
---
---@param ent EntityHandle|string # Handle or targetname of the entity(s) to find.
---@param duration number? # Number of seconds the debug should display for.
function Debug.ShowEntity(ent, duration)
    duration = duration or 20
    if type(ent) == "string" then
        local ents = Debug.FindAllEntitiesByPattern(ent)
        for _,e in ipairs(ents) do
            Debug.ShowEntity(e)
        end
        return
    end

    local from = Vector()
    if Entities:GetLocalPlayer() then
        from = Entities:GetLocalPlayer():EyePosition()
    end
    DebugDrawLine(from, ent:GetOrigin(), 255, 0, 0, true, duration)
    local radius = ent:GetBiggestBounding()/2
    if radius == 0 then radius = 16 end
    DebugDrawCircle(ent:GetOrigin(), Vector(255), 128, radius, true, duration)
    DebugDrawSphere(ent:GetCenter(), Vector(255), 128, radius, true, duration)
end
CBaseEntity.DebugFind = Debug.ShowEntity

---
---Prints all current context criteria for an entity.
---
---@param ent EntityHandle
function Debug.PrintEntityCriteria(ent)
    local c = {}
    ent:GatherCriteria(c)

    Debug.PrintTable(c, nil, nil, nil, function(tbl)
        local sorted_keys = {}
        for key in next, tbl do
            table.insert(sorted_keys, key)
        end
        table.sort(sorted_keys)
        local i = 0
        return function()
            i = i + 1
            return sorted_keys[i], tbl[sorted_keys[i]]
        end
    end)
end
CBaseEntity.PrintCriteria = Debug.PrintEntityCriteria

---
---Prints current context criteria for an entity except for values saved using `storage.lua`.
---
---@param ent EntityHandle
function Debug.PrintEntityBaseCriteria(ent)
    ---@type table<string, any>
    local c, d = {}, {}
    ent:GatherCriteria(c)
    for key, value in pairs(c) do
        if not key:find("::") then
            d[key] = value
        end
    end
    Debug.PrintTable(d)
end
CBaseEntity.PrintBaseCriteria = Debug.PrintEntityBaseCriteria

local classes = {
    [CBaseEntity] = 'CBaseEntity';
    [CAI_BaseNPC] = 'CAI_BaseNPC';
    [CBaseAnimating] = 'CBaseAnimating';
    [CBaseCombatCharacter] = 'CBaseCombatCharacter';
    [CBaseFlex] = 'CBaseFlex';
    [CBaseModelEntity] = 'CBaseModelEntity';
    [CBasePlayer] = 'CBasePlayer';
    [CBaseTrigger]='CBaseTrigger';
    [CBodyComponent] = 'CBodyComponent';
    [CEntityInstance] = 'CEntityInstance';
    [CEnvEntityMaker] = 'CEnvEntityMaker';
    [CEnvProjectedTexture] = 'CEnvProjectedTexture';
    [CEnvTimeOfDay2] = 'CEnvTimeOfDay2';
    [CHL2_Player] = 'CHL2_Player';
    [CInfoData] = 'CInfoData';
    [CInfoWorldLayer] = 'CInfoWorldLayer';
    [CLogicRelay] = 'CLogicRelay';
    [CMarkupVolumeTagged] = 'CMarkupVolumeTagged';
    [CPhysicsProp] = 'CPhysicsProp';
    [CPointClientUIWorldPanel] = 'CPointClientUIWorldPanel';
    [CPointTemplate] = 'CPointTemplate';
    [CPointWorldText] = 'CPointWorldText';
    [CPropHMDAvatar] = 'CPropHMDAvatar';
    [CPropVRHand] = 'CPropVRHand';
    [CSceneEntity] = 'CSceneEntity';
    [CScriptKeyValues] = 'CScriptKeyValues';
    [CScriptPrecacheContext] = 'CScriptPrecacheContext';

    -- Does not exist until CAI_BaseNPC:GetSquad() is called
    -- [AI_Squad] = "AI_Squad";
}

---
---Gets the class name of a vscript entity based on its metatable, e.g. `CBaseEntity`.
---
---If the entity is an EntityClass entity the original Valve class name will be returned instead of the EntityClass.
---
---@param ent EntityHandle # The entity to get the class name of.
---@return string # The class name of the entity or "none" if not found.
function Debug.GetClassname(ent)

    -- AI_Squad doesn't exist until CAI_BaseNPC:GetSquad() is called
    -- check each time to see when it's ready to be added
    ---@diagnostic disable: undefined-global
    if AI_Squad then
        classes[AI_Squad] = "AI_Squad"
    end
    ---@diagnostic enable: undefined-global

    if IsClassEntity(ent) then
        ---@cast ent EntityClass
        return classes[getvalvemeta(ent).__index] or "none"
    else
        return classes[getmetatable(ent).__index] or "none"
    end
end

function Debug.PrintMetaClasses()
    for val, name in pairs(classes) do
        print(name .. ": " .. tostring(val))
    end
end

---
---Prints a visual ASCII graph showing the distribution of values between a min/max bound.
---
---E.g.
---
---    Debug.PrintGraph(6, 0, 1, {
---        val1 = RandomFloat(0, 1),
---        val2 = RandomFloat(0, 1),
---        val3 = RandomFloat(0, 1)
---    })
---    ->
---    1^ []        
---     | []    []  
---     | [] [] []  
---     | [] [] []  
---     | [] [] []  
---    0 ---------->
---       v  v  v   
---       a  a  a   
---       l  l  l   
---       3  1  2   
---    val3 = 0.96067351102829
---    val1 = 0.5374761223793
---    val2 = 0.7315416932106
---
---@param height integer # Height of the actual graph in print rows. Heigher values give more accurate results but can overflow the console making it hard to read.
---@param min_val? number # Minimum expected value for `name_value_pairs`. Default is `0`.
---@param max_val? number # Maxmimum expected value for `name_value_pairs`. Default is `1`.
---@param name_value_pairs table<string,number> # Values to visualize on the graph.
function Debug.PrintGraph(height, min_val, max_val, name_value_pairs)
    height = height or 10
    min_val = min_val or 0
    max_val = max_val or 1
    local values = name_value_pairs
    local max_name_height = 0
    local max_gutter = max(#tostring(min_val), #tostring(max_val))
    for name in pairs(values) do
        max_name_height = max(max_name_height, #name)
    end

    ---@type string[]
    local text_rows = {}
    ---Returns a new string from a non existing key
    ---@diagnostic disable-next-line: inject-field
    text_rows.__index = function (table, key)
        return ""
    end
    setmetatable(text_rows, text_rows)

    local function repeat_char(s, n)
        local strs = {}
        for i = 1, n do
            strs[#strs+1] = s
        end
        return strs
    end

    ---Flatten any nested string arrays into one array
    ---@param tbl (string|string[])[]
    ---@return string[]
    local function flatten_table(tbl)
        local flattened = {}
        for _, value in ipairs(tbl) do
            if type(value) == "table" then
                vlua.extend(flattened, flatten_table(value))
            else
                flattened[#flattened+1] = value
            end
        end
        return flattened
    end

    ---Add a list of chars downwards
    ---@param ... string|string[]
    local function add_column(...)
        local args = {...}
        ---@type string[]
        local strs = {}

        -- Collect all arrays and strings into one string array
        for index, arg in ipairs(args) do
            if type(arg) == "table" then
                vlua.extend(strs, flatten_table(arg))
            else
                strs[#strs+1] = arg
            end
        end

        -- Append all strings downwards
        for i, value in ipairs(strs) do
            text_rows[i] = text_rows[i] .. value
        end
    end

    ---Turns a string into an array of chars
    ---@param s string
    ---@return string[]
    local function str_to_chars(s)
        local strs = {}
        for i = 1, #s do
            strs[#strs+1] = s:sub(i,i)
        end
        return strs
    end

    -- gutter numbers
    local gutter_format = "%"..max_gutter.."s"
    local max_val_str = gutter_format:format(max_val)
    local min_val_str = gutter_format:format(min_val)
    for i = 1, max_gutter do
        local top = tostring(max_val_str):sub(i,i)
        if top == "" then top = " " end
        local bot = tostring(min_val_str):sub(i,i)
        if bot == "" then bot = " " end
        add_column(top, repeat_char(" ", height-2), bot, repeat_char(" ", max_name_height))
    end
    -- Y line
    add_column("^", repeat_char("|", height-2), " ", repeat_char(" ", max_name_height))
    -- Space before first value
    add_column(repeat_char(" ", height-1), "-", repeat_char(" ", max_name_height))
    -- Values
    local separate_names = false
    local i = 0
    for name, value in pairs(values) do
        i = i + 1
        -- ceil so if above lowest bound, at least show something
        local top = math.ceil(RemapValClamped(value, min_val, max_val, 0, height-1))
        -- first half with name
        add_column(repeat_char(" ", height-1-top), repeat_char("[", top), "-", str_to_chars(name), repeat_char(" ", max_name_height-#name))
        -- second half to complete graph line
        add_column(repeat_char(" ", height-top-1), repeat_char("]", top), "-", repeat_char(" ", max_name_height))
        -- space between values
        if separate_names and i < #values-1 then
            add_column(repeat_char(" ", height-1), "-", repeat_char("|", max_name_height))
        else
            add_column(repeat_char(" ", height-1), "-", repeat_char(" ", max_name_height))
        end
    end
    -- Finish X line
    add_column(repeat_char(" ", height-1), ">", repeat_char(" ", max_name_height))

    print()
    for _, text_row in ipairs(text_rows) do
        print(text_row)
    end
    for name, value in pairs(values) do
        print(name .. " = " .. value)
    end
    print()
end

---
---Prints a nested list of entity inheritance.
---
---@param ent EntityHandle
function Debug.PrintInheritance(ent)
    print(ent:GetClassname() .. " -> " .. tostring(ent))
    local parent = getmetatable(ent)
    local new_parent = nil
    local prefix = "  "
    while parent ~= nil do
        print(prefix .. (classes[parent.__index] or "[no class name]") .. " -> " .. tostring(parent) .. "(__index:" .. tostring(parent.__index) .. ")")
        if parent.__index ~= nil and parent.__index ~= parent then
            new_parent = getmetatable(parent.__index)
        else
            new_parent = getmetatable(parent)
        end
        if new_parent == parent then
            break
        end
        parent = new_parent
        prefix = prefix .. "  "
    end
end

---
---Returns a simplified vector string with decimal places truncated.
---
---@param vector Vector
---@return string
function Debug.SimpleVector(vector)
    return "[" .. math.trunc(vector.x, 3) .. ", " .. math.trunc(vector.y, 3) .. ", " .. math.trunc(vector.z, 3) .. "]"
end

---
---Draw a simple sphere without worrying about all the properties.
---
---@param x number # X position
---@param y number # Y position
---@param z number # Z position
---@param radius? number # Radius of the sphere
---@param time? number # Lifetime in seconds, default 10
---@param color? Vector # Color vector [Red, Green, Blue]
---@overload fun(pos: Vector, radius?: number, time: number?, color: Vector?)
function Debug.Sphere(x, y, z, radius, time, color)
    if IsVector(x) then
        ---@diagnostic disable-next-line: cast-type-mismatch
        ---@cast x Vector
        ---@diagnostic disable-next-line: cast-type-mismatch
        ---@cast radius Vector

        color = radius
        radius = y
        time = z

        z = x.z
        y = x.y
        x = x.x
    end

    radius = radius or 8
    time = time or 10
    color = color or Vector(255, 255, 255)

    DebugDrawSphere(Vector(x, y, z), color, 255, radius, false, time)
end

---
---Draw a simple line without worrying about all the properties.
---
---@param startPos Vector # Start position
---@param endPos Vector # End position
---@param time? number # Lifetime in seconds, default 10
---@param color? Vector # Color vector [Red, Green, Blue]
function Debug.Line(startPos, endPos, time, color)

    time = time or 10
    color = color or Vector(255, 255, 255)

    DebugDrawLine(startPos, endPos, color.x, color.y, color.z, false, time)
end

---
---Returns a string made up of an entity's class and name in the format "[class, name]" for debugging purposes.
---
---@param ent EntityHandle
---@return string
function Debug.EntStr(ent)
    return "[" .. ent:GetClassname() .. ", " .. ent:GetName() .. "]"
end

---
---Finds an entity by its handle as a string.
---
---Certain parts of the string can be omitted and the following are all valid:
---
---    Debug.FindEntityByHandleString("table", ":", "0x0012b03")
---    Debug.FindEntityByHandleString("table:", "0x0012b03")
---    Debug.FindEntityByHandleString("table: 0x0012b03")
---    Debug.FindEntityByHandleString("table", "0x0012b03")
---    Debug.FindEntityByHandleString("0x0012b03")
--- 
---Please note that omitting the colon is not allowed in a single string, i.e. "table 0x0012b03" will not work.
---
---@param tblpart string # Entity table string
---@param colon? string # The colon part
---@param hash? string # The hash part
---@return EntityHandle?
function Debug.FindEntityByHandleString(tblpart, colon, hash)
    if tblpart == nil and colon == nil and hash == nil then
        devwarn("Must provide a valid entity table string, e.g. 'table: 0x0012b03'")
        return nil
    end

    -- table : 0x0012b03 (all 3 separate parts)
    if colon == ":" then
        hash = tblpart .. colon .. " " .. hash
    -- table: 0x0012b03 (colon embedded in tblpart)
    elseif tblpart == "table:" then
        hash = tblpart .." ".. colon
    -- table: 0x0012b03 (given as single string)
    elseif tblpart:find("table:") then
        hash = tblpart
    -- table 0x0012b03 (colon omitted)
    elseif tblpart == "table" then
        hash = "table: " .. colon
    -- 0x0012b03 (prefix omitted)
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

    return foundEnt
end

---
---Gets whether the string is in the format of an entity handle.
---
---@param handleString string # The handle string
---@return string # The hash part or nil if not an entity handle
function Debug.IsEntityHandleString(handleString)
    local mtc = handleString:match("^(table:?%s*)")
    if mtc then
        handleString = handleString:sub(#mtc+1)
    end

    return string.match(handleString, "0x[%d%a][%d%a][%d%a][%d%a][%d%a][%d%a][%d%a][%d%a]$")
end

return Debug.version