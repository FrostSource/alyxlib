--[[
    v1.0.2
    https://github.com/FrostSource/alyxlib

    Precaching can only be done with an entity attached script, so this script collects a list of assets to be automatically
    precached when the player spawns, allowing you to precache assets from your global scripts.

    If not using `alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.precache"
]]
if thisEntity then
    ---@param context CScriptPrecacheContext
    function Precache(context)
        GlobalPrecache:_PrecacheGlobalItems(context)
    end

    return
end

---@class GlobalPrecache
---@overload fun(type: AlyxLibGlobalPrecacheType, path: string, spawnkeys: table?): nil
GlobalPrecache = {}
GlobalPrecache.version = "v1.0.3"

---@alias AlyxLibGlobalPrecacheType
---| "model_folder"
---| "sound"
---| "soundfile"
---| "particle"
---| "particle_folder"
---| "model"
---| "entity"

---
---An asset to be globally precached.
---
---@class AlyxLibGlobalPrecacheItem
---@field type AlyxLibGlobalPrecacheType # The type of asset to precache
---@field path string # The asset path to precache (or the classname if type is entity)
---@field spawnkeys table? # The spawnkeys table if type is entity

---
---List of assets waiting to be precached.
---
---@type AlyxLibGlobalPrecacheItem[]
GlobalPrecache._assets = {}

---
---List of precache callbacks.
---
---@type function[]
GlobalPrecache._callbacks = {}

---
---Adds an asset to be precached when the player activates.
---
---If you are precaching *after* the player has activated,
---then you must also call [GlobalPrecache:Flush](lua://GlobalPrecache.Flush)
---after adding assets to be precached.
---
---@param type AlyxLibGlobalPrecacheType # The type of asset to precache
---@param path string # The asset path to precache (or the classname if `type` is an entity)
---@param spawnkeys table? # The spawnkeys table if type is entity
function GlobalPrecache:Add(type, path, spawnkeys)
    table.insert(self._assets, {
        type = type,
        path = path,
        spawnkeys = spawnkeys
    })
end

-- Backwards compatibility, allow GlobalPrecache()
setmetatable(GlobalPrecache, {
    __call=function(_, type, path, spawnkeys)
        Warning(("Use GlobalPrecache:Add(...) instead of GlobalPrecache(%q, %q).\n"):format(type, path))
        GlobalPrecache:Add(type, path, spawnkeys)
    end
})

---Starts the precache process.
local function precacheAsync()
    SpawnEntityFromTableAsynchronous("logic_script", {
        vscripts = "alyxlib/precache",
    }, function (spawnedEnt)
        spawnedEnt:Kill()
    end, nil)
end

---
---Returns whether assets are waiting to be precached.
---
function GlobalPrecache:IsPending()
    return #self._assets > 0
end

---
---Arrange to call the provided functions once all assets are precached.
---If none are currently pending, call immediately. Otherwise, store the callback
---to be called once [GlobalPrecache:Flush()](lua://GlobalPrecache.Flush) is finished.
---
---@param callback function # The function to call when the precaching is complete
function GlobalPrecache:OnFinished(callback)
    if GlobalPrecache:IsPending() then
        table.insert(self._callbacks, callback)
    else
        callback()
    end
end

---
---Flushes the global precache list and precaches the assets.
---
---This function must be called following any calls to [GlobalPrecache:Add()](lua://GlobalPrecache.Add)
---if you are precaching *after* the player has activated.
---
---This is an asynchronous process; the assets will not be immediately available after calling this function.
---
---@param callback? function # The function to call when the precaching is complete
function GlobalPrecache:Flush(callback)
    -- Guard against non-existant player crash
    if not Entities:GetLocalPlayer() then
        Warning("Cannot flush precache while player does not exist!\n")
        return
    end

    if type(callback) == "function" then
        -- Unconditionally insert, precacheAsync will call this.
        table.insert(self._callbacks, callback)
    end
    precacheAsync()
end

---
---Internal function used to start the precache process.
---
---**This should only be called manually if you know what you're doing!**
---
---@param context CScriptPrecacheContext
function GlobalPrecache:_PrecacheGlobalItems(context)
    devprints("Globally precaching", #self._assets, "resources...")
    -- Use a while loop and pop here, so any errors don't discard items.
    while #self._assets > 0 do
        local item = table.remove(self._assets)
        devprints2("\tPrecaching", item.type, item.path)
        if item.type == "model" then
            PrecacheModel(item.path, context)
        elseif item.type == "entity" then
            PrecacheEntityFromTable(item.path, item.spawnkeys, context)
        else
            PrecacheResource(item.type, item.path, context)
        end
    end
    -- Protect against callbacks added by a callback.
    while #self._callbacks > 0 do
        local cback = table.remove(self._callbacks)
        cback()
    end
end

require "alyxlib.player.events"

local listento = ListenToPlayerEvent or ListenToGameEvent

---player_activate seems to be the soonest time to async spawn
---in all circumstances without crashing.
---@param event GameEventPlayerSpawn
listento("player_activate", function (event)
    precacheAsync()
end, nil)

return GlobalPrecache.version
