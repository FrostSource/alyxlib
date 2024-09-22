--[[
    v1.2.0
    https://github.com/FrostSource/alyxlib

    Allows for quick creation of convars which support persistence saving, checking GlobalSys for default values, and callbacks on value change.

    If not using `vscripts/alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.helpers.easyconvars"
]]

require "alyxlib.globals"

---
---Allows quick creation of convars with persistence, globalsys checks, and callbacks.
---
---@class EasyConvars
EasyConvars = {}
EasyConvars.version = "v1.2.0"

---Data of a registered convar.
---@class EasyConvarsRegisteredData
---@field type EasyConvarsType # Type of the convar.
---@field name string # Name of the convar
---@field desc? string # Description of the convar/command. Is displayed below the current value when called without a parameter.
---@field value string # Raw value of the convar.
---@field callback? fun(val:string, ...):any? # Optional callback function whenever the convar is changed.
---@field initializer? fun():any # Optional initializer function which will set the default value on player spawn.
---@field persistent boolean # If the value is saved to player on change.
---@field wasChangedByUser boolean # Whether the value was changed by the user.
---@field displayFunc? fun(val:any) # The function called when the convar is called without any parameters. By default it just prints the value.

---Types of convars.
---@alias EasyConvarsType
---| `EASYCONVARS_CONVAR`
---| `EASYCONVARS_COMMAND`
---| `EASYCONVARS_TOGGLE`

---Convars have a value and display their value in the console.
EASYCONVARS_CONVAR = "convar"
---Commands have no value and only run a callback when called.
EASYCONVARS_COMMAND = "command"
---Toggles have a value of "1" or "0" and display their state in the console.
EASYCONVARS_TOGGLE = "toggle"

---The table of all registered convars.
---@type table<string, EasyConvarsRegisteredData>
EasyConvars.registered = {}

---Internal variable set when convars are being loaded.
---@type boolean
EasyConvars._isLoading = true

---Converts any value to "1" or "0" depending on whether it represents true or false.
---@param val any # The value to convert
---@return "0"|"1" # "0" if the value is truthy, "1" if the value is falsy
local function valueToBoolStr(val)
    return truthy(val) and "1" or "0"
end

---Converts any value to a string and infers a string representation for special values.
---@param val any # The value to convert
---@return string # The converted value
local function convertToSafeVal(val)
    if val ==  nil then return "0"
    elseif val == true then return "1"
    elseif val == false then return "0"
    else
        return tostring(val)
    end
end

---Call a registered data callback if it exists.
---@param registeredData EasyConvarsRegisteredData
---@param value string # The new value of the convar/first argument
---@param ... any # The rest of the arguments
local function callCallback(registeredData, value, ...)
    local oldValue = registeredData.value

    local result = nil
    if registeredData.type == EASYCONVARS_COMMAND then
        result = registeredData.callback(value, ...)
    else
        if registeredData.type == EASYCONVARS_TOGGLE and value == nil then
            registeredData.value = valueToBoolStr(not truthy(registeredData.value))
        else
            registeredData.value = convertToSafeVal(value)
        end

        result = registeredData.callback(registeredData.value, oldValue)
    end

    if result ~= nil then
        registeredData.value = convertToSafeVal(result)
    end
end

---Default display function for convars
---@param reg EasyConvarsRegisteredData
local function defaultDisplayFuncConvar(reg)
    Msg(reg.name .. " = " .. tostring(reg.value) .. "\n")
    if reg.desc ~= nil and reg.desc ~= "" then
        Msg(reg.desc .. "\n")
    end
end

---Default display function for toggles
---@param reg EasyConvarsRegisteredData
local function defaultDisplayFuncToggle(reg)
    Msg(reg.name .. (truthy(reg.value) and " ON" or " OFF") .. "\n")
end

---Creates a convar of any type.
---
---For simple creation use one of the following:
--- - [EasyConvars:RegisterConvar](lua://EasyConvars.RegisterConvar)
--- - [EasyConvars:RegisterToggle](lua://EasyConvars.RegisterToggle)
--- - [EasyConvars:RegisterCommand](lua://EasyConvars.RegisterCommand)
---
---@param ctype EasyConvarsType # Type of the convar.
---@param name string # Name of the convar
---@param defaultValue any|fun():any # Will be converted to a string. If given a function, the value will be determined on player spawn.
---@param onUpdate? (fun(val:string, ...):any?)|(fun(newVal:string, oldVal:string):any) # Optional callback function.
---@param helpText? string # Description of the convar
---@param flags? CVarFlags|integer # Flag for the convar
---@param displayFunc? fun(reg: EasyConvarsRegisteredData) # The function called when the convar is called without any parameters. By default it just prints the value.
---@overload fun(name: string, defaultValue: any, onUpdate: fun(newVal: string, oldVal: string):any?, helpText: string, flags: integer, displayFunc: function)
-- function EasyConvars:Register(name, default, onUpdate, helpText, flags, displayFunc, postUpdate, commandOnly)
function EasyConvars:Register(ctype, name, defaultValue, onUpdate, helpText, flags, displayFunc)

    -- GlobalSys:CommandLineStr("-"..name, GlobalSys:CommandLineCheck("-"..name) and "1" or tostring(default or "0"))
    local launchVal = GlobalSys:CommandLineStr("-"..name, GlobalSys:CommandLineCheck("-"..name) and "1" or nil)
    self.registered[name] = {
        type = ctype,
        callback = onUpdate,
        value = launchVal,
        persistent = false,
        -- isCommand = commandOnly == true,
        name = name,
        desc = helpText,
        wasChangedByUser = false,
        displayFunc = displayFunc or vlua.select(ctype == EASYCONVARS_CONVAR, defaultDisplayFuncConvar, defaultDisplayFuncToggle),
    }
    local reg = self.registered[name]

    --Assign the initializer only if no launch value is set by user
    if type(defaultValue) == "function" then
        if launchVal == nil then
            reg.initializer = defaultValue
        else
            devprints2("EasyConvars", name, "initializer won't be used because it has a launch value of", launchVal)
        end
    else
        reg.value = convertToSafeVal(defaultValue) or "0"
    end

    helpText = helpText or ""
    flags = flags or 0

    -- reg.callback = onUpdate

    Convars:RegisterCommand(name, function (_, ...)
        local args = {...}

        -- Display current value
        if reg.type == EASYCONVARS_CONVAR and #args == 0 then
            if type(reg.displayFunc) == "function" then
                reg.displayFunc(reg)
            end
            -- Early exit
            return
        end

        local prevVal = reg.value
        local prevTruthy = truthy(reg.value)

        callCallback(reg, args[1], ...)

        if prevVal ~= reg.value then
            reg.wasChangedByUser = true
        end

        -- Display the new toggled state
        if reg.type == EASYCONVARS_TOGGLE then
            if type(reg.displayFunc) == "function" then
                reg.displayFunc(reg)
            end
        end

        self:Save(name)
    end, helpText, flags)
end

---
---Prints a warning to the console except during internal handling.
---
---@param msg any # Warning to print
function EasyConvars:Warn(msg)
    if not self._isLoading then
        warn(msg)
    end
end

---
---Prints a message to the console except during internal handling.
---
---@param msg any # Message to print
function EasyConvars:Msg(msg)
    if not self._isLoading then
        Msg(msg .. "\n")
        if IsInToolsMode() then
            print(msg)
        end
    end
end

---
---Manually saves the current value of the convar with a given name.
---
---This is done automatically when the value is changed if SetPersistent is set to true.
---
---@param name string # The name of the convar to save.
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

---
---Manually loads the saved value of the convar with a given name.
---
---This is done automatically when the player spawns for any previously saved convar.
---
---@param name string # The name of the convar to load.
---@return boolean # Returns true if the convar was loaded successfully.
function EasyConvars:Load(name)
    if not self.registered[name] then return false end

    local loader = Player or GetListenServerHost()
    if not loader then
        warn("Cannot load convar '"..name.."', player does not exist!")
        return false
    end

    self._isLoading = true

    local val = loader:LoadString("easyconvar_"..name, nil)
    if val ~= nil then
        self.registered[name].persistent = true
        -- If it has a callback, execute to run any necessary code
        callCallback(self.registered[name], val)
    end

    self._isLoading = false

    return val ~= nil
end

---
---Sets the convar as persistent.
---
---It will be saved to the player when changed and load its previous state when the player spawns.
---
---@param name string # The name of the convar.
---@param persistent boolean # Whether the convar should be persistent.
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

---
---Registers a new convar.
---
---@param name string # Name of the convar
---@param defaultValue? "0"|any|fun():any # Default value of the convar, or an initializer function
---@param helpText? string # Description of the convar
---@param flags? `nil`|CVarFlags|integer # Flags for the convar
---@param postUpdate? fun(newVal:string, oldVal:string): any # Update function called after the value has been changed
---@param displayFunc? fun(reg: EasyConvarsRegisteredData) # Optional custom display function
function EasyConvars:RegisterConvar(name, defaultValue, helpText, flags, postUpdate, displayFunc)
    self:Register(EASYCONVARS_CONVAR,name, defaultValue, postUpdate, helpText, flags, displayFunc)
end

---
---Registers a new command.
---
---@param name string # Name of the command
---@param callback fun(val:string, ...):any? # Callback function
---@param helpText? string # Description of the command
---@param flags? CVarFlags|integer # Flags for the command
function EasyConvars:RegisterCommand(name, callback, helpText, flags)
    self:Register(EASYCONVARS_COMMAND, name, nil, callback, helpText, flags, nil)
end

---
---Registers a new toggle convar.
---
---@param name string # Name of the convar
---@param defaultValue? "0"|any|fun():any # Default value of the convar
---@param helpText? string # Description of the convar
---@param flags? `nil`|CVarFlags|integer # Flags for the convar
---@param postUpdate? fun(newVal:string, oldVal:string): any # Update function called after the value has been changed
---@param displayFunc? fun(reg: EasyConvarsRegisteredData) # Optional custom display function
function EasyConvars:RegisterToggle(name, defaultValue, helpText, flags, postUpdate, displayFunc)
    EasyConvars:Register(EASYCONVARS_TOGGLE, name, defaultValue, postUpdate, helpText, flags, displayFunc)
end

---
---Returns the convar as a string.
---
---@param name string # Name of the convar
---@return string? # The value of the convar as a string or nil if convar does not exist
function EasyConvars:GetStr(name)
    if not self.registered[name] then return nil end
    return self.registered[name].value
end

---
---Returns the convar as a boolean.
---
---@param name string # Name of the convar
---@return boolean? # The value of the convar as a boolean or nil if convar does not exist
function EasyConvars:GetBool(name)
    if not self.registered[name] then return nil end
    return truthy(self:GetStr(name))
end

---
---Returns the convar as a float.
---
---@param name string # Name of the convar
---@return number? # The value of the convar as a number or nil if convar does not exist
function EasyConvars:GetFloat(name)
    if not self.registered[name] then return nil end
    return tonumber(self:GetStr(name)) or 0
end

---
---Returns the convar as an integer.
---
---@param name string # Name of the convar
---@return integer? # The value of the convar as a truncated number or nil if convar does not exist
function EasyConvars:GetInt(name)
    if not self.registered[name] then return nil end
    return math.floor(self:GetFloat(name))
end

---
---Sets the value of the convar to a string and calls the update.
---
---@param name string # Name of the convar
---@param value string # The value to set
function EasyConvars:SetStr(name, value)
    local reg = self.registered[name]
    if not reg then return nil end
    callCallback(reg, value)
end

---
---Sets the value of the convar to a boolean and calls the update.
---
---@param name string # Name of the convar
---@param value boolean # The value to set
function EasyConvars:SetBool(name, value)
    local reg = self.registered[name]
    if not reg then return nil end
    callCallback(reg, valueToBoolStr(value))
end

---
---Sets the value of the convar to a float and calls the update.
---
---@param name string # Name of the convar
---@param value number # The value to set
function EasyConvars:SetFloat(name, value)
    local reg = self.registered[name]
    if not reg then return nil end
    callCallback(reg, tostring(value))
end

---
---Sets the value of the convar to an integer and calls the update.
---
---@param name string # Name of the convar
---@param value integer # The value to set
function EasyConvars:SetInt(name, value)
    local reg = self.registered[name]
    if not reg then return nil end
    callCallback(reg, tostring(math.floor(value)))
end

---
---Sets the raw value of the convar without calling the update.
---
---@param name string # Name of the convar
---@param value any # The value to set
function EasyConvars:SetRaw(name, value)
    local reg = self.registered[name]
    if not reg then return nil end
    reg.value = tostring(value)
end

---
---Get if the convar was changed by the user in the console.
---
---@param name string # Name of the convar
function EasyConvars:WasChangedByUser(name)
    local reg = self.registered[name]
    if not reg then return false end
    return reg.wasChangedByUser
end


-- Check which version of listener is available
local listener = ListenToPlayerEvent
if listener == nil then
    listener = ListenToGameEvent
end
listener("player_activate", function (params)
    Player:Delay(function ()

        for name, data in pairs(EasyConvars.registered) do
            -- Try to load convar, if fails use initializer
            if not EasyConvars:Load(name) then
                if data.initializer then
                    if data.value ~= nil then
                        devprints2("EasyConvars", name, "initializer won't be used because it has a user value of", tostring(data.value))
                    else
                        data.value = tostring(data.initializer())
                        devprints("EasyConvars", name, "initializer value was", data.value)
                    end
                end
            end
        end
        EasyConvars._isLoading = false

    end)
end, nil)

return EasyConvars.version
