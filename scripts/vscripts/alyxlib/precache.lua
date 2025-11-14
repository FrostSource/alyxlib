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
        _PrecacheGlobalItems(context)
    end

    return
end

local version = "v1.0.2"

require "alyxlib.player.core"

---@alias AlyxLibGlobalPrecacheType
---| "model_folder"
---| "sound"
---| "soundfile"
---| "particle"
---| "particle_folder"
---| "model"
---| "entity"

---
---A global asset to be precached when the player spawns.
---
---@class AlyxLibGlobalPrecacheItem
---@field type AlyxLibGlobalPrecacheType # The type of asset to precache
---@field path string # The asset path to precache (or the classname if type is entity)
---@field spawnkeys table? # The spawnkeys table if type is entity

---@type AlyxLibGlobalPrecacheItem[]
_G.AlyxLibGlobalPrecacheList = {}
---@type function[]
_G.AlyxlibGlobalPrecacheCallbacks = {}

---
---Add an asset to be precached when the player spawns.
---
---If you are precaching *after* the player has spawned, then you must also call [GlobalPrecacheFlush](lua://GlobalPrecacheFlush).
---
---@param type AlyxLibGlobalPrecacheType # The type of asset to precache
---@param path string # The asset path to precache (or the classname if type is entity)
---@param spawnkeys table? # The spawnkeys table if type is entity
function GlobalPrecache(type, path, spawnkeys)
    table.insert(AlyxLibGlobalPrecacheList, {
        type = type,
        path = path,
        spawnkeys = spawnkeys
    })
end

---Starts the precache process.
---@param callback? function # The function to call when the precaching is complete
local function precacheAsync(callback)
    SpawnEntityFromTableAsynchronous("logic_script", {
        vscripts = "alyxlib/precache",
    }, function (spawnedEnt)
        spawnedEnt:Kill()
    end, nil)
end

---Returns whether assets are waiting to be precached.
function GlobalPrecachePending()
    return #AlyxLibGlobalPrecacheList > 0
end

---
---Arrange to call the provided functions once all assets are precached.
---If none are currently pending, call immediately. Otherwise, store the callback
---to be called once [GlobalPrecacheFlush](lua://GlobalPrecacheFlush) is finished.
---
---@param callback function # The function to call when the precaching is complete
function GlobalPrecacheOnFinished(callback)
    if GlobalPrecachePending() then
        table.insert(AlyxlibGlobalPrecacheCallbacks, callback)
    else
        callback()
    end
end

---
---Flushes the global precache list and precaches the assets.
---
---This is an asynchronous process; the assets will not be immediately available after calling this function.
---
---If you are precaching *after* the player has spawned, call this function after preceding [GlobalPrecache](lua://GlobalPrecache) calls.
---
---@param callback? function # The function to call when the precaching is complete
function GlobalPrecacheFlush(callback)
    if type(callback) == "function" then
        -- Unconditionally insert, precacheAsync will call this.
        table.insert(AlyxlibGlobalPrecacheCallbacks, callback)
    end
    precacheAsync()
end

---
---Internal function used to start the precache process.
---
---**This should only be called manually if you know what you're doing!**
---
---@param context CScriptPrecacheContext
function _PrecacheGlobalItems(context)
    devprints("Globally precaching", #AlyxLibGlobalPrecacheList, "resources...")
    -- Use a while loop and pop here, so any errors don't discard items.
    while #AlyxLibGlobalPrecacheList > 0 do
        local item = table.remove(AlyxLibGlobalPrecacheList)
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
    while #AlyxlibGlobalPrecacheCallbacks > 0 do
        local cback = table.remove(AlyxlibGlobalPrecacheCallbacks)
        cback()
    end
end

---player_spawn seems to be the soonest time to async spawn without crashing.
---@param params GameEventPlayerSpawn
ListenToGameEvent("player_spawn", function (params)
    precacheAsync()
end, nil)

return version
