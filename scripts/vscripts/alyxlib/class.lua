--[[
    v2.0.0
    https://github.com/FrostSource/alyxlib

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "alyxlib.class"
    ```

    ======================================== Entity Classes ========================================

    NOTE: Entity classes are still early in development and documentation is sparse.
    
    The new `entity` function is designed to ease the creation of entity classes and all the trouble
    that comes with complex entity scripts. Instead of defining functions and variables in the
    private script scope we define them in a shared table class which is inherited by all entities
    using this class.

    The simplest example of the entity function is:

    ```lua
    ---Define the entity class, which returns both the class (base) and entity handle (self).
    ---By "inheriting" EntityClass we get helpful code completion.
    ---@class EntityName : EntityClass
    local base, self = entity("EntityName")
    ---This stops code executing a second time after a game load.
    if self.Initiated then return end

    ---A variable is defined for the class.
    base.class_variable = 1

    ---A function is defined for the class. This specific function is called automatically.
    ---@param loaded boolean
    function base:OnReady(loaded)
        ---Reference a class variable, note that we use `self` instead of `base` here inside the function.
        self.class_variable = self.class_variable + 1
    end
    ```

    Entity scripts using this feature should *not* use `thisEntity` and instead use `self`.
    It's important to remember to define your class functions on the `base` class. Functions
    defined on `self` will not be inherited by other classes which inherit your class.

    Thinking is simplified, allowing you to define a base class think which can be paused/resumed
    and the state of which will be saved, meaning the think function will automatically resume
    after a game load:

    ```lua
    function base:OnReady(loaded)
        if not loaded then
            self:ResumeThink()
        end
    end

    function base:Think()
        if Time() > 50 then
            self:PauseThink()
            return
        end
        return 0
    end
    ```

    Like the think state, any fields defined in the `base`/`self` objects will be automatically loaded.
    Currently these values still need to be saved manually but this is done easily with the new save function:

    ```lua
    base.value = 1

    function base:ChangeValue()
        self.value = self.value + 1
        self:Save()
    end
    ```
]]
local version = "v2.0.0"

require "alyxlib.storage"
require "alyxlib.globals"
require "alyxlib.debug.common"

---@type table<string, table>
EntityClassNameMap = {}

-- look up for `k' in list of tables `plist'
local function search(k, plist)
    for i = 1, #plist do
        local v = plist[i][k]
        if v ~= nil then return v end
    end
end

READY_NORMAL = 0
READY_GAME_LOAD = 2
READY_TRANSITION = 3
---@alias OnReadyType `READY_NORMAL`|`READY_GAME_LOAD`|`READY_TRANSITION`

---Private inherit funcion which is used in both `inherit` and `entity` functions.
---@param base any
---@param self EntityClass
---@param fenv any
local function _inherit(base, self, fenv)
    -- Fix for base inheriting itself on load
    if self.__inherits and vlua.find(self.__inherits, base) then
        local class_name = tostring(base)
        for name, class in pairs(EntityClassNameMap) do
            if class == base then
                class_name = name
                break
            end
        end
        Warning("Trying to inherit an already inherited class ( "..class_name.." -> ["..tostring(self)..","..self:GetClassname()..","..self:GetName().."] )\n")
        return
    end

    -- Define variable so we can tell valve metatable apart later
    local valveMetaIntermediary = {}
    rawset(valveMetaIntermediary, "valveMeta", true)

    if not self.__inherits then
        -- Valve meta gets assigned to blank table so its metamethods work like normal
        -- take this into account when looking for the valve meta
        self.__inherits = { setmetatable(valveMetaIntermediary, getmetatable(self)) }
    end
    -- Have base take priority over Valve meta, allowing function overriding
    table.insert(self.__inherits, 1, base)

    local meta = {
        __name = self:GetDebugName().."_meta",
        -- Raw value table allows for checking when value changes
        __values = {},
    }
    -- Used to automatically save values
    meta.__newindex = function(table, key, value)
        if not key:startswith("__") and type(value) ~= "function" then
            meta.__values[key] = value
            self:Save(key, value)
        else
            rawset(table, key, value)
        end
    end
    -- Used to search inherted values
    meta.__index = function(table, key)
        -- check entity values
        if meta.__values[key] ~= nil then
            return meta.__values[key]
        end

        -- check inherits
        return search(key, self.__inherits)
    end

    -- Custom rawget function to get a value from meta.__values without checking inherits
    self.__rawget = function(table, key)
        return meta.__values[key]
    end

    setmetatable(self, meta)

    -- Special functions --

    fenv.Spawn = function(spawnkeys)
        if type(self.OnSpawn) == "function" then
            self:OnSpawn(spawnkeys)
        end
        ---@TODO Test closure solving and impact it has
        fenv.Spawn = nil
    end

    fenv.Activate = function(activateType)

        local allinherits = getinherits(self)

        for i = 1, #allinherits do
            local inherit = allinherits[i]

            -- Clone mutable data into entity so class won't get modified
            for key, value in pairs(inherit) do
                if not key:startswith("__") and self:__rawget(key) == nil then

                    if IsVector(value) then
                        self[key] = Vector(value.x, value.y, value.z)
                    elseif IsQAngle(value) then
                        self[key] = QAngle(value.x, value.y, value.z)
                    elseif type(value) == "table" then
                        self[key] = DeepCopyTable(value)
                    end

                end
            end

            -- Redirect defined output functions
            for output, func in pairs(inherit.__outputs) do
                -- Function needs a different name because some outputs do actions when called for some reason
                local newname = output .. "_Func"
                -- Define the function regardless of load state because it still needs to exist
                rawset(self, newname, func)
                -- But don't do it on a game load to avoid doubling up
                if activateType ~= 2 then
                    devprint2("Redirecting output \""..output.."\" to func ["..tostring(func).."] as '"..newname.."'")
                    self:RedirectOutput(output, newname, self)
                end
            end
        end

        if activateType ~= 0 then
            -- Load all saved entity data
            Storage.LoadAll(self, true)
        end

        -- Fire custom ready function
        if type(self.OnReady) == "function" then
            self:OnReady(activateType)
        end

        if self.IsThinking then
            self:ResumeThink()
        end

        self.Initiated = true
        self:Save()
        self:Attribute_SetIntValue("InstanceActivated", 1)

    end

    ---@TODO Consider checking for each function definition and only adding it if found.

    fenv.UpdateOnRemove = function()
        if type(self.UpdateOnRemove) == "function" then
            self:UpdateOnRemove()
        end
    end

    fenv.OnBreak = function(inflictor)
        if type(self.OnBreak) == "function" then
            self:OnBreak(inflictor)
        end
    end

    fenv.OnTakeDamage = function(damageTable)
        if type(self.OnTakeDamage) == "function" then
            self:OnTakeDamage(damageTable)
        end
    end

    ---@TODO Reasonable way to precache only once?
    fenv.Precache = function(context)
        if type(self.Precache) == "function" then
            self:Precache(context)
        end
    end

    ---@TODO Not enabled because unsure of performance, test
    -- fenv.OnEntText = function(damageTable)
    --     if type(self.OnTakeDamage) == "function" then
    --         self:OnTakeDamage(damageTable)
    --     end
    -- end

    self.Save = EntityClass.Save

    local private = self:GetPrivateScriptScope()
    for k,v in pairs(base.__privates) do
        private[k] = function(...) v(self, ...) end
    end

    if self:Attribute_GetIntValue("InstanceActivated", 0) == 1 then
        fenv.Activate(3)
    else

        self.Initiated = false
        self.IsThinking = false
    end
end

---Inherit an existing entity class which was defined using `entity` function.
---@generic T
---@param script `T`
---@return T # Base class, the newly created class.
---@return T # Self instance, the entity inheriting `base`.
---@diagnostic disable-next-line:lowercase-global
function inherit(script)
    local fenv = getfenv(2)
    if fenv.thisEntity == nil then
        fenv = getfenv(3)
        if fenv.thisEntity == nil then
            error("Could not inherit '"..script.."' because thisEntity could not be found!")
        end
    end
    local self = fenv.thisEntity
    local base = script
    if type(script) == "string" then
        if EntityClassNameMap[script] then
            -- string is class name
            base = EntityClassNameMap[script]
        else
            -- string is script
            base = require(script)
        end
    end

    _inherit(base, self, fenv)

    return base, self
end

---
---Creates a new entity class.
---
---If this is called in an entity attached script then the entity automatically
---inherits the class and the class inherits the entity's metatable.
---
---The class is only created once so this can be called in entity attached scripts
---multiple times and all subsequent calls will return the already created class.
---
---@generic      T, T2
---@param name? `T` # Internal class name
---@param ...    string|table # Any inherit classes or scripts.
---@return any # Base class, the newly created class.
---@return T # Self instance, the entity inheriting `base`.
---@return table # Super class, the first inheritance of `base`.
---@return table # Private table
---@diagnostic disable-next-line: lowercase-global
function entity(name, ...)

    local inherits = {...}

    -- If no inherits are provided then this is a top-level class
    -- and needs to inherit the main EntityClass table.
    if #inherits == 0 then
        table.insert(inherits, EntityClass)
    end

    -- Check if name is actually an inherit (class name was omitted)
    if type(name) ~= "string" and (type(name) == "table" or module_exists(name)) then
        table.insert(inherits, 1, name)
        name = nil
    end
    if name == nil then
        name = DoUniqueString("CustomEntityClass")
    end

    -- Execute any script inherits to get the class table
    for index, inherit in ipairs(inherits) do
        if type(inherit) == "string" then
            if EntityClassNameMap[inherit] then
                -- string is defined name
                inherits[index] = EntityClassNameMap[inherit]
            else
                -- string is script
                local base = require(inherit)
                inherits[index] = base
            end
        end
    end
    ---@cast inherits table[]

    -- Try to retrieve cached class
    local base = EntityClassNameMap[name]
    if not base then
        base = {
            __name = name,
            __script_file = GetScriptFile(nil, 3),
            __inherits = inherits,
            __privates = {},
            __outputs = {}
        }
        -- Meta table to search all inherits
        setmetatable(base, {
            __index = function(t,k)
                -- prints("Trying access",k,"in",t,"from base metatable __index")
                return search(k, base.__inherits)
            end
        })
        -- Base will search itself and then its metatable
        base.__index = base
        EntityClassNameMap[name] = base
    end

    -- fenv is the private script scope
    local fenv = getfenv(2)
    ---@type EntityClass?
    local self = fenv.thisEntity

    -- Add base as middleman metatable if script is attached to entity
    local super = inherits[1]
    if self then
        _inherit(base, self, fenv)
    end

    return base, self, super, base.__privates
end

--#region EntityClass Definition

---The top-level entity class that provides base functionality.
---@class EntityClass : CBaseEntity,CEntityInstance,CBaseModelEntity,CBasePlayer,CHL2_Player,CBaseAnimating,CBaseFlex,CBaseCombatCharacter,CAI_BaseNPC,CBaseTrigger,CEnvEntityMaker,CInfoWorldLayer,CLogicRelay,CMarkupVolumeTagged,CEnvProjectedTexture,CPhysicsProp,CSceneEntity,CPointClientUIWorldPanel,CPointTemplate,CPointWorldText,CPropHMDAvatar,CPropVRHand
---@field __inherits table # Table of inherited classes.
---@field __name string # Name of the class.
---@field __outputs table<string, function> # Map of output names to functions that will be connected on spawn.
---@field __rawget fun(self: EntityClass, key: string): any # Custom rawget function to get a value from meta.__values without checking inherits.
---@field Initiated boolean # If the class entity has been activated.
---@field IsThinking boolean # If the entity is currently thinking with `Think` function.
---@field OnReady fun(self: EntityClass, loaded: boolean) # Called automatically on `Activate` if defined.
---@field OnSpawn fun(self: EntityClass, spawnkeys: CScriptKeyValues) # Called automatically on `Spawn` if defined.
---@field UpdateOnRemove fun(self: EntityClass) # Called before the entity is killed.
---@field OnBreak fun(self: EntityClass, inflictor: EntityHandle) # Called when a breakable entity is broken.
---@field OnTakeDamage fun(self: EntityClass, damageTable: TypeDamageTable) # Called when entity takes damage.
---@field Precache fun(self: EntityClass, context: CScriptPrecacheContext) # Called before Spawn for precaching.
EntityClass = entity("EntityClass")

---Assign a new value to entity's field `name`.
---This also saves the field.
---@param name string
---@param value any
---@deprecated # Values are automatically saved now.
function EntityClass:Set(name, value)
    -- self[name] = value
    ---@TODO Unsure if there's a reasonable difference between this and normal assignment
    rawset(self, name, value)
    self:Save(name, value)
end

---Save a given entity field. Call with no arguments to save all data.
---@param name? string # Name of the field to save.
---@param value? any # Value to save. If not provided the value will be retrieved from the field with the same `name`.
---@luadoc-ignore
function EntityClass:Save(name, value)
    if name then
        Storage.Save(self, name, value~=nil and value or self[name])
    end
    for key, val in pairs(self) do
        if not key:startswith("__") and type(val) ~= "function" then
            Storage.Save(self, key, val)
        end
    end
end

---Main entity think function which auto resumes on game load.
---@luadoc-ignore
function EntityClass:Think()
    Warning("Trying to think on entity class with no think defined ["..self.__name.."]\n")
end

---Resume the entity think function.
---@luadoc-ignore
function EntityClass:ResumeThink()
    self:SetContextThink("__EntityThink", function() return self:Think() end, 0)
    self.IsThinking = true
end

---Pause the entity think function.
---@luadoc-ignore
function EntityClass:PauseThink()
    self:SetContextThink("__EntityThink", nil, 0)
    self.IsThinking = false
end

---Define a function to redirected to `output` on spawn.
---@param output string
---@param func function
function EntityClass:Output(output, func)
    self.__outputs[output] = func
end

--#endregion


---Prints all classes that `ent` inherits.
---@param ent EntityClass
---@param nest? string
---@diagnostic disable-next-line:lowercase-global
function printinherits(ent, nest)
    nest = nest or ''
    if ent.__inherits then
        if haskey(ent, "__name") then
            print(nest.."Name:", ent.__name, ent)
        else
            print(nest.."No name")
        end
        -- Debug.PrintList(ent.__inherits, nest)
        if not ent.__inherits or #ent.__inherits == 0 then
            print(nest.."No inherits")
        else
            for key, value in ipairs(ent.__inherits) do
                if Debug.GetClassname(value.__index) ~= "none" then
                    print(nest..tostring(value), Debug.GetClassname(value.__index))
                else
                    print(nest..tostring(value), value.__name)
                    -- Debug.PrintList(value, nest)
                    printinherits(value, nest..'   ')
                end
            end
        end
    end
end

---Get the original metatable that Valve assigns to the entity.
---@param ent EntityClass # The entity search.
---@return table? # Metatable originally assigned to `ent`.
---@diagnostic disable-next-line:lowercase-global
function getvalvemeta(ent)
    local inherits = rawget(ent, "__inherits")
    if inherits then
        for _, inherit in ipairs(inherits) do
            if rawget(inherit, "valveMeta") then
                return getmetatable(inherit)
            end
        end
    end
end

---Get a list of all classes that `class` inherits.
---Does not include the Valve class; use getvalvemeta() for that.
---@param class EntityClass # The entity or class to search.
---@return EntityClass[] # List of class tables.
---@diagnostic disable-next-line:lowercase-global
function getinherits(class)
    local foundinherits = {}
    local inherits = rawget(class, "__inherits")
    if inherits then
        for _, inherit in ipairs(inherits) do
            -- Exclude valve meta because it doesn't have fields we are looking for
            if not rawget(inherit, "valveMeta") then
                table.insert(foundinherits, inherit)
                vlua.extend(foundinherits, getinherits(inherit))
            end
        end
    end
    return foundinherits
end

---Get if an `EntityClass` instance inherits a given `class`.
---@param ent EntityClass|EntityHandle # Entity to check.
---@param class string|table # Name or class table to check.
---@return boolean # True if `ent` inherits `class`, false otherwise.
---@diagnostic disable-next-line:lowercase-global
function isinstance(ent, class)
    local inherits = rawget(ent, "__inherits")
    if inherits then
        for _, inherit in ipairs(inherits) do
            if type(class) == "string" then
                if inherit.__name == class then
                    return true
                end
            else
                if inherit == class then
                    return true
                end
            end
            -- Check recursively if no match
            if isinstance(inherit, class) then
                return true
            end
        end
    end
    return false
end

print("class.lua ".. version .." initialized...")

return version
