--[[
    v1.1.1
    https://github.com/FrostSource/alyxlib

    Allows for quick creation of convars which support persistence saving, checking GlobalSys
    for default values, and callbacks on value change.

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "alyxlib.helpers.easyconvars"
    ```

    ======================================== Usage ==========================================

    EasyConvars are useful when you need a convar that performs actions when the value is changed
    or needs to be saved and automatically saved on game load.

    For this example we will create a convar that draws a debug line to the nearest resin when turned on.

    ```lua
    EasyConvars:Register("example_debug_resin", "0", function (val)
        -- Turn the string value into a boolean
        val = truthy(val)

        local player = Entities:GetLocalPlayer()

        if not player then
            -- Player wasn't found so return false to override the user's value
            -- false automatically converts to "0"
            return false
        end

        -- Perform an action based on the value the user gave
        if val == true then
            player:SetThink(function()
                local resin = Entities:FindByClassnameNearest("item_hlvr_crafting_currency_small", player:GetOrigin(), 1000)
                if resin then
                    DebugDrawLine(player:GetOrigin(), resin:GetOrigin(), 255,255,255, true, 1)
                end
                return 1
            end, "example_debug_resin", 0)
        else
            player:StopThink("example_debug_resin")
        end

        -- No need to return a value at the end, the user's input is used
    end)
    ```

    After the convar is registered, it will be accessible in the console like any other convar.
    It will behave like a regular convar even though internally it is registered as a command.
    If the user accesses the convar without any value it will display the current value in the console.

    If we want the convar to be saved when it is changed we can call another method right after
    defining it:

    ```lua
    EasyConvars:SetPersistent("example_debug_resin", true)
    ```

    Sometimes we need to know the value of our convar in code so the standard 'get' methods
    found in the Convars class are also available in EasyConvars:

    ```lua
    -- Assuming the convar was set to 1 in the console.
    val = EasyConvars:GetString("example_debug_resin") -- "1"
    val = EasyConvars:GetBool("example_debug_resin") -- true
    val = EasyConvars:GetFloat("example_debug_resin") -- 1
    val = EasyConvars:GetInt("example_debug_resin") -- 1
    ```

    You MUST use the EasyConvars methods for retrieving the values as they are registered
    as console commands instead of normal convars.

    If you don't need a callback and just want the saving feature you can simply set
    the callback to `nil` in the `Register` method, or use the `RegisterConvar` method instead.

    ```lua
    EasyConvars:RegisterConvar("example_debug_resin", "0")
    EasyConvars:SetPersistent("example_debug_resin", true)
    ```

]]

require "alyxlib.globals"

---Allows quick creation of convars with persistence, globalsys checks, and callbacks.
---@class EasyConvars
EasyConvars = {}
EasyConvars.version = "v1.1.1"

---@class EasyConvarsRegisteredData
---@field value string # Raw value of the convar.
---@field persistent boolean # If the value is saved to player on change.
---@field callback? fun(val:string, ...):any? # Optional callback function whenever the convar is changed.
---@field initializer? fun():any # Optional initializer function which will set the default value on player spawn.

---@type table<string, EasyConvarsRegisteredData>
EasyConvars.registered = {}

---Internal variable set when convars are being loaded.
---@type boolean
EasyConvars._isLoading = true

---Converts any value to "1" or "0" depending on whether it represents true or false.
---@param val any
---@return "0"|"1"
local function valueToBoolStr(val)
    if val == true or val == 1 or val == "1" or (type(val) == "table" and #val > 0) then
        return "1"
    else
        return "0"
    end
end

---Call a registered data callback if it exists.
---@param registeredData EasyConvarsRegisteredData
---@param value string
---@param ... any
local function callCallback(registeredData, value, ...)
    if type(registeredData.callback) == "function" then
        local result = registeredData.callback(...)
        if result ~= nil then
            if type(result) == "boolean" then result = result and "1" or "0" end
            registeredData.value = tostring(result)
        else
            registeredData.value = tostring(value)
        end
    else
        registeredData.value = tostring(value)
    end
end

---Create a convar with a callback function.
---@param name string
---@param default any|fun():any # Will be converted to a string. If given a function, the value will be determined on player spawn.
---@param func? fun(val:string, ...):any? # Optional callback function.
---@param helpText? string
---@param flags? integer
function EasyConvars:Register(name, default, func, helpText, flags)

    -- GlobalSys:CommandLineStr("-"..name, GlobalSys:CommandLineCheck("-"..name) and "1" or tostring(default or "0"))
    local launchVal = GlobalSys:CommandLineStr("-"..name, GlobalSys:CommandLineCheck("-"..name) and "1" or nil)
    self.registered[name] = {
        value = launchVal,
        persistent = false
    }
    local reg = self.registered[name]

    --Assign the initializer only if no launch value is set by user
    if type(default) == "function" then
        if launchVal == nil then
            reg.initializer = default
        else
            devprints2("EasyConvars", name, "initializer won't be used because it has a launch value of", launchVal)
        end
    else
        reg.value = default or "0"
    end

    helpText = helpText or ""
    flags = flags or 0

    reg.callback = func

    Convars:RegisterCommand(name, function (_, ...)
        local args = {...}

        -- Display current value
        if #args == 0 then
            Msg(name .. " = " .. tostring(reg.value))
            return
        end

        callCallback(reg, args[1], ...)

        self:Save(name)
    end, helpText, flags)
end

---Prints a warning to the console.
---@param msg any
function EasyConvars:Warn(msg)
    if not self._isLoading then
        warn(msg)
    end
end

---Prints a message to the console.
---@param msg any
function EasyConvars:Print(msg)
    if not self._isLoading then
        Msg(msg .. "\n")
        if IsInToolsMode() then
            print(msg)
        end
    end
end

---Manually saves the current value of the convar with a given name.
---This is done automatically when the value is changed if SetPersistent is set to true.
---@param name string
function EasyConvars:Save(name)
    if not self.registered[name] then return end
    if self.registered[name].persistent == false then return end

    local saver = Player or GetListenServerHost()
    if not saver then
        if not self._isLoading then
            warn("Cannot save convar '"..name.."', player does not exist!")
        end
        return
    end

    saver:SaveString("easyconvar_"..name, self.registered[name].value)
end

---Manually loads the saved value of the convar with a given name.
---This is done automatically when the player spawns for any previously saved convar.
---@param name string
function EasyConvars:Load(name)
    if not self.registered[name] then return end

    local loader = Player or GetListenServerHost()
    if not loader then
        warn("Cannot load convar '"..name.."', player does not exist!")
        return
    end

    self._isLoading = true

    self.registered[name].value = loader:LoadString("easyconvar_"..name, self.registered[name].value)
    self.registered[name].persistent = true
    -- If it has a callback, execute to run any necessary code
    if type(self.registered[name].callback) == "function" then
        self.registered[name].callback(self.registered[name].value)
    end

    self._isLoading = false
end

---Sets the convar as persistent. It will be saved to the player when changed and load its
---previous state when the map starts.
---
---Convars with previously saved data will have persistence automatically turned on when loaded.
---@param name string
---@param persistent boolean
function EasyConvars:SetPersistent(name, persistent)
    if not self.registered[name] then return end
    self.registered[name].persistent = persistent

    -- Clear data when persistence is turned off
    if not persistent then
        local saver = Player or GetListenServerHost()
        if not saver then
            warn("Could not clear data for convar '"..name.."', player does not exist!")
            return
        end
        saver:SaveString("easyconvar_"..name, nil)
    end
end

---Calls the register function using the same syntax as the built-in convar library, for easy converting.
---@param name string
---@param defaultValue? any|fun():any
---@param helpText? string
---@param flags? integer
function EasyConvars:RegisterConvar(name, defaultValue, helpText, flags)
    self:Register(name, defaultValue, nil, helpText, flags)
end

---Calls the register function using the same syntax as the built-in convar library, for easy converting.
---@param name string
---@param callback fun(...):any?
---@param helpText? string
---@param flags? integer
function EasyConvars:RegisterCommand(name, callback, helpText, flags)
    self:Register(name, nil, callback, helpText, flags)
end

---Returns the convar as a string.
---@param name string
---@return string?
function EasyConvars:GetStr(name)
    if not self.registered[name] then return nil end
    return self.registered[name].value
end

---Returns the convar as a boolean.
---@param name string
---@return boolean?
function EasyConvars:GetBool(name)
    if not self.registered[name] then return nil end
    return truthy(self:GetStr(name))
end

---Returns the convar as a float.
---@param name string
---@return number?
function EasyConvars:GetFloat(name)
    if not self.registered[name] then return nil end
    return tonumber(self:GetStr(name)) or 0
end

---Returns the convar as an integer.
---@param name string
---@return integer?
function EasyConvars:GetInt(name)
    if not self.registered[name] then return nil end
    return math.floor(self:GetFloat(name))
end

---Sets the value of the convar to a string and calls any associated callback.
---@param name string
---@param value string
function EasyConvars:SetStr(name, value)
    local reg = self.registered[name]
    if not reg then return nil end
    callCallback(reg, value)
end

---Sets the value of the convar to a boolean and calls any associated callback.
---@param name string
---@param value boolean
function EasyConvars:SetBool(name, value)
    local reg = self.registered[name]
    if not reg then return nil end
    callCallback(reg, valueToBoolStr(value))
end

---Sets the value of the convar to a float and calls any associated callback.
---@param name string
---@param value number
function EasyConvars:SetFloat(name, value)
    local reg = self.registered[name]
    if not reg then return nil end
    callCallback(reg, tostring(value))
end

---Sets the value of the convar to an integer and calls any associated callback.
---@param name string
---@param value integer
function EasyConvars:SetInt(name, value)
    local reg = self.registered[name]
    if not reg then return nil end
    callCallback(reg, tostring(math.floor(value)))
end

---Sets the raw value of the convar. For use inside command callbacks when a value needs to be set before the return.
---@param name string
---@param value any
function EasyConvars:SetRaw(name, value)
    local reg = self.registered[name]
    if not reg then return nil end
    reg.value = tostring(value)
end


local registerer = RegisterPlayerEventCallback
if registerer == nil then
    registerer = ListenToGameEvent
end
RegisterPlayerEventCallback("player_activate", function (params)
    for name, data in pairs(EasyConvars.registered) do
        if data.initializer then
            if data.value ~= nil then
                devprints2("EasyConvars", name, "initializer won't be used because it has a user value of", tostring(data.value))
            else
                data.value = tostring(data.initializer())
                devprints("EasyConvars", name, "initializer value was", data.value)
            end
        end
        EasyConvars:Load(name)
    end
    EasyConvars._isLoading = false
end, nil)

print("easyconvars.lua ".. EasyConvars.version .." initialized...")

return EasyConvars
