--[[
    v2.0.0
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
EasyConvars.version = "v2.0.0"

---Data of a registered convar.
---@class EasyConvarsRegisteredData
---@field type EasyConvarsType # Type of the convar.
---@field name string # Name of the convar
---@field desc? string # Description of the convar/command. Is displayed below the current value when called without a parameter.
---@field value string # Raw value of the convar.
---@field prevValue string # Previous raw value of the convar.
---@field callback? fun(val:string, ...):any? # Optional callback function whenever the convar is changed.
---@field initializer? fun():any # Optional initializer function which will set the default value on player spawn.
---@field persistent boolean # If the value is saved to player on change.
---@field wasChangedByUser boolean # Whether the value was changed by the user.
---@field displayFunc? fun(val:any) # The function called when the convar is called without any parameters. By default it just prints the value.
---@field defaultValue? string # The default value of the convar given by the registration. Not the value set in cfg or launch options.

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

---The table of all registered convars, (name -> data)
---@type table<string, EasyConvarsRegisteredData>
EasyConvars.registered = {}

---Internal variable set when convars are being loaded.
---@type boolean
EasyConvars._isLoading = true

---The function called after all convars have been initialized.
local postInitializer = nil

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
        if type(registeredData.callback) == "function" then
            result = registeredData.callback(value, ...)
        end
    else
        if registeredData.type == EASYCONVARS_TOGGLE and value == nil then
            registeredData.value = valueToBoolStr(not truthy(registeredData.value))
        else
            registeredData.value = convertToSafeVal(value)
        end

        if type(registeredData.callback) == "function" then
            result = registeredData.callback(registeredData.value, oldValue)
        end
    end

    if result ~= nil then
        registeredData.value = convertToSafeVal(result)
    end

    if registeredData.persistent then
        EasyConvars:Save(registeredData.name)
    end
end

---Default display function for toggles
---@param reg EasyConvarsRegisteredData
local function defaultDisplayFuncToggle(reg)
    Msg(reg.name .. (truthy(reg.value) and " ON" or " OFF") .. "\n")
end

---Standard callback for all command and toggle cvars.
---@param name string # Name of the command called
---@param ... string # Values given by the user through the console
local function commandCallback(name, ...)
    local cvar = EasyConvars.registered[name]
    if cvar == nil then
        return warn("Could not find registered data for cvar "..name)
    end

    local prevVal = cvar.value
    local args = {...}

    callCallback(cvar, args[1], vlua.slice(args, 1))

    if prevVal ~= cvar.value then
        cvar.wasChangedByUser = true
    end

    -- Display the new toggled state ON/OFF
    if cvar.type == EASYCONVARS_TOGGLE then
        if type(cvar.displayFunc) == "function" then
            cvar.displayFunc(cvar)
        end
    end
end

---Sets the value of an EasyConvar.
---@param registeredData EasyConvarsRegisteredData
---@param value string
---@param ... any
local function setCvarValue(registeredData, value, ...)
    if registeredData.type == EASYCONVARS_CONVAR then
        Convars:SetStr(registeredData.name, convertToSafeVal(value))
    else
        callCallback(registeredData, value, ...)
    end
end

---Listener for all FCVAR_NOTIFY changes.
---@param params GameEventServerCvar
ListenToGameEvent("server_cvar", function (params)
    local cvar = EasyConvars.registered[params.cvarname]
    if cvar == nil then return end

    callCallback(cvar, params.cvarvalue, cvar.prevValue)

    cvar.prevValue = cvar.value
    cvar.value = params.cvarvalue

    if cvar.prevValue ~= cvar.value then
        cvar.wasChangedByUser = true
    end
end, nil)

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
---@return EasyConvarsRegisteredData # The new registered cvar data
function EasyConvars:Register(ctype, name, defaultValue, onUpdate, helpText, flags)

    local launchVal = GlobalSys:CommandLineStr("-"..name, GlobalSys:CommandLineCheck("-"..name) and "1" or nil)
    self.registered[name] = {
        type = ctype,
        callback = onUpdate,
        value = launchVal,
        prevValue = launchVal,
        persistent = false,
        name = name,
        desc = helpText,
        wasChangedByUser = false,
    }
    local reg = self.registered[name]

    --Assign the initializer only if no launch value is set by user

    if launchVal == nil then
        if type(defaultValue) == "function" then
            reg.initializer = defaultValue
        else
            reg.value = convertToSafeVal(defaultValue) or "0"
            reg.defaultValue = reg.value
        end
    else
        -- Launch option counts as user change
        reg.wasChangedByUser = true
        devprints2("EasyConvars", name, "initializer won't be used because it has a launch value of", launchVal)
    end

    helpText = helpText or ""
    flags = flags or 0

    -- Notify is required to listen for value changes
    if bit.band(flags, FCVAR_NOTIFY) == 0 then
        flags = bit.bor(flags, FCVAR_NOTIFY)
    end

    if ctype == EASYCONVARS_COMMAND or ctype == EASYCONVARS_TOGGLE then
        Convars:RegisterCommand(name, commandCallback, helpText, flags)
    else
        Convars:RegisterConvar(name, reg.value, helpText, flags)
    end

    return reg
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
    local cvar = self.registered[name]
    if not cvar then return false end

    local loader = Player or GetListenServerHost()
    if not loader then
        warn("Cannot load convar '"..name.."', player does not exist!")
        return false
    end

    self._isLoading = true

    local loadedValue = loader:LoadString("easyconvar_"..name, nil)
    if loadedValue ~= nil then
        cvar.persistent = true
        setCvarValue(cvar, loadedValue)
    end

    self._isLoading = false

    return loadedValue ~= nil
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
---@param flags? CVarFlags|integer # Flags for the convar
---@param postUpdate? fun(newVal:string, oldVal:string): any # Update function called after the value has been changed
function EasyConvars:RegisterConvar(name, defaultValue, helpText, flags, postUpdate)
    self:Register(EASYCONVARS_CONVAR,name, defaultValue, postUpdate, helpText, flags)
end

---
---Registers a new command.
---
---@param name string # Name of the command
---@param callback fun(val:string, ...):any? # Callback function
---@param helpText? string # Description of the command
---@param flags? CVarFlags|integer # Flags for the command
function EasyConvars:RegisterCommand(name, callback, helpText, flags)
    self:Register(EASYCONVARS_COMMAND, name, nil, callback, helpText, flags)
end

---
---Registers a new toggle convar.
---
---This is a command that has an on/off state like `god` or `notarget`.
---
---@param name string # Name of the convar
---@param defaultValue? "0"|any|fun():any # Default value of the convar
---@param helpText? string # Description of the convar
---@param flags? `nil`|CVarFlags|integer # Flags for the convar
---@param postUpdate? fun(newVal:string, oldVal:string): any # Update function called after the value has been changed
---@param displayFunc? fun(reg: EasyConvarsRegisteredData) # Optional custom display function
function EasyConvars:RegisterToggle(name, defaultValue, helpText, flags, postUpdate, displayFunc)
    local cvar = EasyConvars:Register(EASYCONVARS_TOGGLE, name, defaultValue, postUpdate, helpText, flags)
    cvar.displayFunc = displayFunc or defaultDisplayFuncToggle
end

---
---Gets the [EasyConvarsRegisteredData](lua://EasyConvarsRegisteredData) table for a given cvar name.
---
---@param name string # The name of the registered EasyConvar to get the data for
---@return EasyConvarsRegisteredData? # The data associated with `name`
function EasyConvars:GetConvarData(name)
    return self.registered[name]
end

---
---Checks if an easy convar exists.
---
---@param name string # Name of the convar
---@return boolean # Returns true if the convar exists
function EasyConvars:Exists(name)
    return self.registered[name] ~= nil
end

---
---Returns the convar as a string.
---
---@param name string # Name of the convar
---@return string? # The value of the convar as a string or nil if convar does not exist
function EasyConvars:GetStr(name)
    local cvar = self.registered[name]
    if not cvar then return nil end
    -- return self.registered[name].value
    if cvar.type == EASYCONVARS_CONVAR then
        return Convars:GetStr(name)
    else
        return cvar.value
    end
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
    setCvarValue(reg, value)
end

---
---Sets the value of the convar to a boolean and calls the update.
---
---@param name string # Name of the convar
---@param value boolean # The value to set
function EasyConvars:SetBool(name, value)
    local reg = self.registered[name]
    if not reg then return nil end
    setCvarValue(reg, valueToBoolStr(value))
end

---
---Sets the value of the convar to a float and calls the update.
---
---@param name string # Name of the convar
---@param value number # The value to set
function EasyConvars:SetFloat(name, value)
    local reg = self.registered[name]
    if not reg then return nil end
    setCvarValue(reg, tostring(value))
end

---
---Sets the value of the convar to an integer and calls the update.
---
---@param name string # Name of the convar
---@param value integer # The value to set
function EasyConvars:SetInt(name, value)
    local reg = self.registered[name]
    if not reg then return nil end
    setCvarValue(reg, tostring(math.floor(value)))
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

---
---Forces the convar to be considered changed by the user.
---
---This can be useful if you want to stop a convar from initializing because you're setting its value early.
---Or if you're setting the value by some unusual means for the user.
---
---@param name string
---@param wasChanged boolean
function EasyConvars:SetWasChanged(name, wasChanged)
    local reg = self.registered[name]
    if not reg then return end
    reg.wasChangedByUser = wasChanged
end

---
---Sets the value of the convar if it hasn't been changed by the user.
---
---@param name string
---@param value any # The value to set. Will be converted to a string representation.
function EasyConvars:SetIfUnchanged(name, value)
    local reg = self.registered[name]
    if not reg then return end
    if not reg.wasChangedByUser then
        setCvarValue(reg, value)
    end
end

---@type function[]
local postInitializers = {}

---
---Adds a function to be called after all convars have been initialized.
---
---Useful for setting convars that are dependent on other convars.
---
---@param func function # The function to call
function EasyConvars:AddPostInitializer(func)
    table.insert(postInitializers, func)
end

---
---Adds a function to be called after all convars have been initialized.
---
---**Deprecated: Use [AddPostInitializer](lua://EasyConvars.AddPostInitializer) instead**
---
---@deprecated
---@param func function # The function to call
function EasyConvars:SetPostInitializer(func)
    self:AddPostInitializer(func)
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
                        data.wasChangedByUser = true
                        devprints2("EasyConvars", name, "initializer won't be used because it has a user value of", tostring(data.value))
                    else
                        setCvarValue(data, convertToSafeVal(data.initializer()))
                        data.defaultValue = data.value
                        devprints2("EasyConvars", name, "initializer value was", data.value)
                    end
                end
            end
        end
        EasyConvars._isLoading = false

        for _, func in pairs(postInitializers) do
            func()
        end

    end)
end, nil)

return EasyConvars.version
