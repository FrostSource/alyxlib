--[[
    v3.2.0
    https://github.com/FrostSource/alyxlib

    Helps with saving/loading values for persistency between game sessions.
    Data is saved on a specific entity and if the entity is killed the values
    cannot be retrieved during that game session.

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "alyxlib.storage"
    ```

    ======================================== Usage ==========================================
    
    

    Functions are accessed through the global 'Storage' table.
    When using dot notation (Storage.SaveNumber) you must provide the entity handle to save on.
    When using colon notation (Storage:SaveNumber) the script will find the best handle to save on (usually the player).

    Examples of storing and retrieving the following local values that might be defined
    at the top of the file:

    ```lua
    -- Getting the values to save
    local origin = thisEntity:GetOrigin()
    local hp     = thisEntity:GetHealth()
    local name   = thisEntity:GetName()

    -- Saving the values:

    Storage:SaveVector("origin", origin)
    Storage:SaveNumber("hp", hp)
    Storage:SaveString("name", name)

    -- Loading the values:

    origin = Storage:LoadVector("origin")
    hp     = Storage:LoadNumber("hp")
    name   = Storage:LoadString("name")
    ```

    This script also provides functions Storage.Save/Storage.Load for general purpose
    type inference storage. It is still recommended that you use the explicit type
    functions to keep code easily understandable, but it can help with prototyping:

    ```lua
    Storage:Save("origin", origin)
    Storage:Save("hp", hp)
    Storage:Save("name", name)

    origin = Storage:Load("origin", origin)
    hp     = Storage:Load("hp", hp)
    name   = Storage:Load("name", name)
    ```

    Entity versions of the functions exist to make saving to a specific entity easier:

    ```lua
    thisEntity:SaveNumber("hp", thisEntity:GetHealth())
    thisEntity:SetHealth(thisEntity:LoadNumber("hp"))
    ```

    ======================================= Complex Tables ========================================

    Since Lua allows tables to have keys and values to be virtually any value, `Storage.SaveTable`
    attempts to save and restore both using their native Storage functions, and does so recursively
    meaning nested tables can be saved.

    An example of safely restoring a class instance (assuming the class has a `new` method)
    where an instance is created and then the saved values are restored and added to the instance:

    ```lua
    vlua.tableadd(MyClass:new(), thisEntity:LoadTable("MyClass", {}))
    ```

    Alternatively if the class uses a metatable and you have access to it:

    ```lua
    setmetatable(thisEntity:LoadTable("MyClass", {}), MyClass)
    ```

    Functions for both key and value are currently not supported and will fail to save but will not
    block the rest of the table from being saved. This means you can save whole class tables and
    restore them with only the relevant saved data.

    =================================== Delegate Save Functions ===================================

    Tables can utilize __save/__load functions to handle their specific saving needs.
    The table with these functions needs to be registered with the Storage module and any instances
    must have an `__index` key pointing to the base table:

    ```lua
    MyClass.__index = MyClass
    Storage.RegisterType("MyClass", MyClass)
    ```

    The functions may handle the data saving however they want but should generally use the base
    Storage functions to keep things safe and consistent. The below template functions may be
    copied to your script as a starting point.
    See `data/stack.lua` for an example of these functions in action.

    ```lua
    ---@param handle EntityHandle # The entity to save on.
    ---@param name string # The name to save as.
    ---@param object MyClass # The object to save.
    ---@return boolean # If the save was successful.
    function MyClass.__save(handle, name, object)
        return Storage.SaveTableCustom(handle, name, object, "MyClass")
    end

    ---@param handle EntityHandle # Entity to load from.
    ---@param name string # Name to load.
    ---@return MyClass|nil # The loaded value. nil on fail.
    function MyClass.__load(handle, name)
        local object = Storage.LoadTableCustom(handle, name, "MyClass")
        if object == nil then return nil end
        return setmetatable(object, MyClass)
    end
    ```

    Storage.Save and Storage.Load will now invoke these functions when appropriate.

    =========================================== Notes =============================================

    Strings longer than 62 characters are split up into multiple saves to work around the 64 character limit.
    This is handled automatically but should be taken into consideration when saving long strings.
    This limit does not apply to names.
]]

if thisEntity then
    require "storage"
    return
end

local debug_allowed = true
---Show a warning message in the console if `developer` is greater than 2.
---@param msg any
local function Warn(msg)
    if debug_allowed and Convars:GetInt( 'developer' ) > 2 then
    -- if debug_allowed then
        print(msg.."\n")
    end
end

---
---Resolve a given handle.
---
---@param handle EntityHandle # Handle to resolve.
---@return EntityHandle # Resolved save handle.
local function resolveHandle(handle)
    -- Keep given handle if valid entity
    if handle ~= nil and handle ~= Storage and IsValidEntity(handle) then
        return handle
    end

    -- Otherwise save on player
    local player = GetListenServerHost()
    if not player then
        Warn("Trying to save a global value before player has spawned!")
        ---Let it fall through and error to signal dev
        ---@diagnostic disable-next-line: return-type-mismatch
        return nil
    end
    return player
end


local separator = "::"

Storage = {}
Storage.version = "v3.2.0"
---Collection of type names associated with a class table.
---The table should have both __save() and __load() functions.
---@type table<string,table>
Storage.type_to_class = {}
Storage.class_to_type = {}

---
---Register a class table type with a name.
---
---@param name string # Name that the type will be saved as.
---@param T table # Class table.
function Storage.RegisterType(name, T)
    Storage.type_to_class[name] = T
    Storage.class_to_type[T] = name
end

---
---Unregister a class type.
---
---@param name string # Name to unregister.
---@param T table # Class to unregister.
function Storage.UnregisterType(name, T)
    Storage.type_to_class[name] = nil
    Storage.class_to_type[T] = nil
end

---
---Join a list of values by the hidden separator.
---
---@param ... any # Values to join.
---@return string # Joined string.
function Storage.Join(...)
    return table.concat({...}, separator)
end

---
---Helper function for saving the type correctly.
---No failsafes are provided in this function, you must be sure you are saving correctly.
---
---@param handle EntityHandle # Entity to save on.
---@param name string # Name prefix to save as.
---@param T string # String name of `T`.
function Storage.SaveType(handle, name, T)
    handle:SetContext(Storage.Join(name, "type"), T, 0)
end

------------
-- SAVING --
------------

---
---Save a string.
---
---@param handle EntityHandle # Entity to save on.
---@param name string # Name to save as.
---@param value string|nil # String to save.
---@return boolean # If the save was successful.
function Storage.SaveString(handle, name, value)
    handle = resolveHandle(handle)
    if not handle then
        Warn("Invalid save handle ("..tostring(handle)..")!")
        return false
    end

    -- Handle clearing with nil first
    if value == nil then
        handle:SetContext(name, nil, 0)
        handle:SetContext(name..separator.."type", nil, 0)
        handle:SetContext(name..separator.."splits", nil, 0)
    -- Then handle saving
    elseif #value > 62 then
        local index = 0
        while #value > 0 do
            index = index + 1
            local split_point = math.min(62, #value)
            handle:SetContext(name..separator.."split"..index, ":"..value:sub(1, split_point), 0)
            value = value:sub(split_point+1, #value)
        end
        handle:SetContextNum(name..separator.."splits", index, 0)
        handle:SetContext(name..separator.."type", "splitstring", 0)
    else
        handle:SetContext(name, ":"..value, 0)
        handle:SetContext(name..separator.."type", "string", 0)
    end
    return true
end

---
---Save a number.
---
---@param handle EntityHandle # Entity to save on.
---@param name string # Name to save as.
---@param value number # Number to save.
---@return boolean # If the save was successful.
function Storage.SaveNumber(handle, name, value)
    handle = resolveHandle(handle)
    if not handle then
        Warn("Invalid save handle ("..tostring(handle)..")!")
        return false
    end
    handle:SetContextNum(name, value, 0)
    handle:SetContext(name..separator.."type", "number", 0)
    return true
end

---
---Save a boolean.
---
---@param handle EntityHandle # Entity to save on.
---@param name string # Name to save as.
---@param bool boolean # Boolean to save.
---@return boolean # If the save was successful.
function Storage.SaveBoolean(handle, name, bool)
    handle = resolveHandle(handle)
    if not handle then
        Warn("Invalid save handle ("..tostring(handle)..")!")
        return false
    end
    handle:SetContextNum(name, bool and 1 or 0, 0)
    handle:SetContext(name..separator.."type", "boolean", 0)
    return true
end

---
---Save a Vector.
---
---@param handle EntityHandle # Entity to save on.
---@param name string # Name to save as.
---@param vector Vector # Vector to save.
---@return boolean # If the save was successful.
function Storage.SaveVector(handle, name, vector)
    handle = resolveHandle(handle)
    if not handle then
        Warn("Invalid save handle ("..tostring(handle)..")!")
        return false
    end
    handle:SetContext(name, "", 0)
    handle:SetContext(name..separator.."type", "vector", 0)
    Storage.SaveNumber(handle, name..separator.."x", vector.x)
    Storage.SaveNumber(handle, name..separator.."y", vector.y)
    Storage.SaveNumber(handle, name..separator.."z", vector.z)
    return true
end

---
---Save a QAngle.
---
---@param handle EntityHandle # Entity to save on.
---@param name string # Name to save as.
---@param qangle QAngle # QAngle to save.
---@return boolean # If the save was successful.
function Storage.SaveQAngle(handle, name, qangle)
    handle = resolveHandle(handle)
    if not handle then
        Warn("Invalid save handle ("..tostring(handle)..")!")
        return false
    end
    handle:SetContext(name, "", 0)
    handle:SetContext(name..separator.."type", "qangle", 0)
    Storage.SaveNumber(handle, name..separator.."x", qangle.x)
    Storage.SaveNumber(handle, name..separator.."y", qangle.y)
    Storage.SaveNumber(handle, name..separator.."z", qangle.z)
    return true
end

---
---Save a table with a custom type.
---Should be used with custom save functions.
---
---If trying to save a normal table use `Storage.SaveTable`.
---
---@param handle EntityHandle # Entity to save on.
---@param name string # Name to save as.
---@param tbl table<any,any> # Table to save.
---@param T string # Type to save as.
---@param save_meta? boolean # If keys starting with '__' should be saved.
---@return boolean # If the save was successful.
function Storage.SaveTableCustom(handle, name, tbl, T, save_meta)
    handle = resolveHandle(handle)
    if not handle then
        Warn("Invalid save handle ("..tostring(handle)..")!")
        return false
    end
    local key_count = 0
    local name_sep = name..separator
    local key_concat = name_sep.."key"..separator
    local actual_saves = 0
    for key, value in pairs(tbl) do
        key_count = key_count + 1
        if save_meta or tostring(key):sub(1,2) ~= "__" then
            -- Only add the key if the value was successfully saved (up to individual functions).
            if  Storage.Save(handle, name_sep..actual_saves, value)
            and Storage.Save(handle, key_concat..actual_saves, key)
            then
                actual_saves = actual_saves + 1
            else
                Warn("Failing to save table value ("..tostring(key).." = "..tostring(value)..")")
            end
        end
    end
    handle:SetContextNum(name, actual_saves, 0)
    handle:SetContext(name_sep.."type", T, 0)
    return true
end

---
---Save a table.
---
---May be ordered, unordered or mixed.
---
---May have nested tables.
---
---@param handle EntityHandle # Entity to save on.
---@param name string # Name to save as.
---@param tbl table<any,any> # Table to save.
---@return boolean # If the save was successful.
function Storage.SaveTable(handle, name, tbl)
    return Storage.SaveTableCustom(handle, name, tbl, "table")
end

---
---Save an entity reference.
---
---Entity handles change between game sessions so this function
---modifies the passed entity to make sure it can keep track of it.
---
---@param handle EntityHandle # Entity to save on.
---@param name string # Name to save as.
---@param entity EntityHandle|nil # Entity to save.
---@return boolean # If the save was successful.
function Storage.SaveEntity(handle, name, entity, useClassname)
    handle = resolveHandle(handle)

    -- Remove unique key from previous entity
    -- This isn't strictly necessary and can be disabled for slight performance gain
    local prevUniqueKey = handle:GetContext(name) --[[@as string]]
    if prevUniqueKey then
        local previouslySavedEnt = handle:LoadEntity(name)
        if IsEntity(previouslySavedEnt, true) then
            previouslySavedEnt:DeleteAttribute(prevUniqueKey)
        end
    end

    if entity == nil then
        Storage.SaveString(handle, name..separator.."targetname", "")
        Storage.SaveString(handle, name..separator.."classname", "")
        handle:SetContext(name..separator.."unique", "", 0)
        handle:SetContext(name..separator.."type", "entity", 0)
        return true
    elseif not entity or not IsValidEntity(entity) then
        return false
    end

    -- Setting attribute on saved entity, used to find correct entity on load
    local uniqueKey = DoUniqueString("saved_entity")
    entity:Attribute_SetIntValue(uniqueKey, 1)

    Storage.SaveString(handle, name..separator.."targetname", entity:GetName())
    Storage.SaveString(handle, name..separator.."classname", entity:GetClassname())

    handle:SetContext(name, uniqueKey, 0)
    handle:SetContext(name..separator.."type", "entity", 0)
    return true
end

local _vector = getmetatable(Vector())
local _qangle = getmetatable(QAngle())

---
---Save a value.
---
---Uses type inference to save the value.
---If you are experiencing errors consider saving with one of the explicit type saves.
---
---@param handle EntityHandle # Entity to save on.
---@param name string # Name to save as.
---@param value any # Value to save.
---@return boolean # If the save was successful.
function Storage.Save(handle, name, value)
    local t = type(value)
    if t=="function" then Warn("Functions are not supported for saving yet.") return false
    elseif t=="nil" then Storage.SaveType(handle, name, "nil") return true
    elseif t=="string" then return Storage.SaveString(handle, name, value)
    elseif t=="number" then return Storage.SaveNumber(handle, name, value)
    elseif t=="boolean" then return Storage.SaveBoolean(handle, name, value)
    elseif t=="table" then
        if type(value.__self) == "userdata" then
            return Storage.SaveEntity(handle, name, value)
        elseif Storage.class_to_type[getmetatable(value)] then
            return value.__save(handle, name, value)
        else
            return Storage.SaveTable(handle, name, value)
        end
    elseif getmetatable(value)==_vector then return Storage.SaveVector(handle, name, value)
    elseif getmetatable(value)==_qangle then return Storage.SaveQAngle(handle, name, value)
    else
        Warn("Value ["..tostring(value)..","..type(value).."] is not supported. Please open at issue on the github.")
        return false
    end
end

-------------
-- LOADING --
-------------

---
---Load a string.
---
---@generic T
---@param handle EntityHandle # Entity to load from.
---@param name string # Name the string was saved as.
---@param default? T # Optional default value.
---@return string|T # Saved string or `default`.
function Storage.LoadString(handle, name, default)
    handle = resolveHandle(handle)
    local t = handle:GetContext(name..separator.."type")
    if t == "string" then
        local value = handle:GetContext(name)
        if value == nil then return default end
        return value:sub(2)
    elseif t == "splitstring" then
        local splits = handle:GetContext(name..separator.."splits")
        local str = ""
        for index = 1, splits do
            str = str .. (handle:GetContext(name..separator.."split"..index):sub(2))
        end
        return str
    end
    Warn("String " .. name .. " could not be loaded!")
    return default
end

---
---Load a number.
---
---@generic T
---@param handle EntityHandle # Entity to load from.
---@param name string # Name the number was saved as.
---@param default? T # Optional default value.
---@return number|T # Saved number or `default`.
function Storage.LoadNumber(handle, name, default)
    handle = resolveHandle(handle)
    local t = handle:GetContext(name..separator.."type")
    local value = handle:GetContext(name)
    if not value or t ~= "number" then
        Warn("Number " .. name .. " could not be loaded! ("..type(value)..", "..tostring(value)..")")
        return default
    end
    if type(value) == "number" then return value end
    return default
end

---
---Load a boolean value.
---
---@generic T
---@param handle EntityHandle # Entity to load from.
---@param name string # Name the boolean was saved as.
---@param default? T # Optional default value.
---@return boolean|T # Saved boolean or `default`.
function Storage.LoadBoolean(handle, name, default)
    handle = resolveHandle(handle)
    local t = handle:GetContext(name..separator.."type")
    local value = handle:GetContext(name)
    if t ~= "boolean" or value == nil then
        Warn("Boolean " .. name .. " could not be loaded! ("..type(value)..", "..tostring(value)..")")
        return default
    end
    return value == 1
end

---
---Load a Vector.
---
---@generic T
---@param handle EntityHandle # Entity to load from.
---@param name string # Name the Vector was saved as.
---@param default? T # Optional default value.
---@return Vector|T # Saved Vector or `default`.
function Storage.LoadVector(handle, name, default)
    handle = resolveHandle(handle)
    local t = handle:GetContext(name..separator.."type")
    if t ~= "vector" then
        Warn("Vector " .. name .. " could not be loaded!")
        return default
    end
    local x = handle:GetContext(name..separator.."x") or 0
    local y = handle:GetContext(name..separator.."y") or 0
    local z = handle:GetContext(name..separator.."z") or 0
    ---@diagnostic disable-next-line: param-type-mismatch
    return Vector(x, y, z)
end

---
---Load a QAngle.
---
---@generic T
---@param handle EntityHandle # Entity to load from.
---@param name string # Name the QAngle was saved as.
---@param default? T # Optional default value.
---@return QAngle|T # Saved QAngle or `default`.
function Storage.LoadQAngle(handle, name, default)
    handle = resolveHandle(handle)
    local t = handle:GetContext(name..separator.."type")
    if t ~= "qangle" then
        Warn("QAngle " .. name .. " could not be loaded!")
        return default
    end
    local x = handle:GetContext(name..separator.."x") or 0
    local y = handle:GetContext(name..separator.."y") or 0
    local z = handle:GetContext(name..separator.."z") or 0
    ---@diagnostic disable-next-line: param-type-mismatch
    return QAngle(x, y, z)
end

---
---Load a table with a custom type.
---Should be used with custom load functions.
---
---If trying to load a normal table use `Storage.LoadTable`.
---
---@generic T
---@param handle EntityHandle # Entity to load from.
---@param name string # Name the table was saved as.
---@param T string # Type to save as.
---@param default? T # Optional default value.
---@return table|T # Saved table or `default`.
function Storage.LoadTableCustom(handle, name, T, default)
    handle = resolveHandle(handle)
    local name_sep = name..separator
    local t = handle:GetContext(name_sep.."type")
    local key_count = handle:GetContext(name)
    if t ~= T or not key_count  then
        Warn("Table " .. name .. " could not be loaded!")
        return default
    end
    key_count = key_count - 1

    local key_concat = name_sep.."key"..separator
    local tbl = {}
    for i = 0, key_count do
        local key = Storage.Load(handle, key_concat..i)
        local value = Storage.Load(handle, name_sep..i)
        tbl[key] = value
    end
    return tbl
end

---
---Load a table with a custom type.
---
---@generic T
---@param handle EntityHandle # Entity to load from.
---@param name string # Name the table was saved as.
---@param default? T # Optional default value.
---@return table|T # Saved table or `default`.
function Storage.LoadTable(handle, name, default)
    return Storage.LoadTableCustom(handle, name, "table", default)
end

---
---Load an entity.
---
---@generic T
---@param handle EntityHandle # Entity to load from.
---@param name string # Name to save as.
---@param default? T # Optional default value.
---@return EntityHandle|T # Saved entity or `default`.
function Storage.LoadEntity(handle, name, default)
    handle = resolveHandle(handle)
    local t = handle:GetContext(name..separator.."type")
    local uniqueKey = handle:GetContext(name) ---@cast uniqueKey string
    local ent_name = Storage.LoadString(handle, name..separator.."targetname")
    local ent_class = Storage.LoadString(handle, name..separator.."classname")
    if t ~= "entity" or (not ent_name and not ent_class) then
        Warn("Entity '" .. name .. "' could not be loaded! ("..type(ent_name)..", "..tostring(ent_name)..")")
        return default
    end

    local ents
    if ent_name == nil or ent_name == "" then
        ents = Entities:FindAllByClassname(ent_class)
        if #ents == 0 then
            Warn("No entities of '" .. name .. "' found with saved class '" .. ent_class .. "', returning default.")
            return default
        end
    else
        ents = Entities:FindAllByName(ent_name)
        if #ents == 0 then
            Warn("No entities of '" .. name .. "' found with saved name '" .. ent_name .. "', returning default.")
            return default
        end
    end

    for _, ent in ipairs(ents) do
        if ent:HasAttribute(uniqueKey) then
            return ent
        end
    end
    -- Return default if no entities with saved value.
    Warn("No entities of '" .. name .. "' have saved attribute! Returning default.")
    return default
end

---
---Load a value.
---
---@param handle EntityHandle # Entity to load from.
---@param name string # Name the value was saved as.
---@param default? any # Optional default value.
---@return any # Saved value or `default`.
function Storage.Load(handle, name, default)
    handle = resolveHandle(handle)
    local t = handle:GetContext(name..separator.."type")
    if not t then
        Warn("Value " .. name .. " could not be loaded!")
        return default
    end
    -- Consider registering these types instead of hardcoding here
    if t=="nil" then return nil
    elseif t=="string" or t=="splitstring" then return Storage.LoadString(handle, name, default)
    elseif t=="number" then return Storage.LoadNumber(handle, name, default)
    elseif t=="boolean" then return Storage.LoadBoolean(handle, name, default)
    elseif t=="vector" then return Storage.LoadVector(handle, name, default)
    elseif t=="qangle" then return Storage.LoadQAngle(handle, name, default)
    elseif t=="table" then return Storage.LoadTable(handle, name, default)
    elseif t=="entity" then return Storage.LoadEntity(handle, name, default)
    elseif Storage.type_to_class[t] then
        local result = Storage.type_to_class[t].__load(handle, name)
        if result == nil then return default end
        return result
    else
        Warn("Unknown type '"..t.."' for name '"..name.."'")
        return default
    end
end

---Load all values saved to an entity.
---@param handle EntityHandle # Entity to load from.
---@param direct? boolean # Optionally load values directly into `handle` instead of a new table.
---@return table # Table of loaded values (or `handle` if `direct` is true).
function Storage.LoadAll(handle, direct)
    local tbl = direct and handle or {}
    handle = resolveHandle(handle)
    ---@type table<string,any>
    local criteria = {}
    handle:GatherCriteria(criteria)
    for key, value in pairs(criteria) do
        if not key:find(separator, 1, true) then
            local result = Storage.Load(handle, key)
            if result then
                tbl[key] = result
            end
        end
    end
    return tbl
end

-- Done one by one for code hint purposes
CBaseEntity.SaveString  = Storage.SaveString
CBaseEntity.SaveNumber  = Storage.SaveNumber
CBaseEntity.SaveBoolean = Storage.SaveBoolean
CBaseEntity.SaveVector  = Storage.SaveVector
CBaseEntity.SaveQAngle  = Storage.SaveQAngle
CBaseEntity.SaveTable   = Storage.SaveTable
CBaseEntity.SaveEntity  = Storage.SaveEntity
CBaseEntity.Save        = Storage.Save

CBaseEntity.LoadString  = Storage.LoadString
CBaseEntity.LoadNumber  = Storage.LoadNumber
CBaseEntity.LoadBoolean = Storage.LoadBoolean
CBaseEntity.LoadVector  = Storage.LoadVector
CBaseEntity.LoadQAngle  = Storage.LoadQAngle
CBaseEntity.LoadTable   = Storage.LoadTable
CBaseEntity.LoadEntity  = Storage.LoadEntity
CBaseEntity.Load        = Storage.Load

CBaseEntity.LoadAll     = function(self) Storage.LoadAll(self, true) end

return Storage.version