--[[
    v1.0.2
    https://github.com/FrostSource/alyxlib

    Precaching can only be done with an entity attached script, so this script collects a list of assets to be automatically
    precached when the player spawns, allowing you to precache assets from your global scripts.

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "alyxlib.precache"
    ```

    ======================================== Usage ========================================
    
    Add assets to be precached in the following way:

    ```lua
    GlobalPrecache("model", "models/weapons/vr_alyxgun/vr_alyxgun_clip.vmdl")
    GlobalPrecache("entity", "prop_dynamic", {
        model = "models/weapons/vr_alyxgun/vr_alyxgun_clip.vmdl"
    })
    ```
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

---@class AlyxLibGlobalPrecacheItem
---@field type AlyxLibGlobalPrecacheType # The type of asset to precache.
---@field path string # The asset path to precache (or the classname if type is entity).
---@field spawnkeys table? # The spawnkeys table if type is entity.

---@type AlyxLibGlobalPrecacheItem[]
_G.AlyxLibGlobalPrecacheList = {}

---
---Add an asset to be precached when the player spawns.
---
---If you are precaching *after* the player has spawned, then you must also call [GlobalPrecacheFlush](lua://GlobalPrecacheFlush).
---
---@param type AlyxLibGlobalPrecacheType # The type of asset to precache.
---@param path string # The asset path to precache (or the classname if type is entity).
---@param spawnkeys table? # The spawnkeys table if type is entity.
function GlobalPrecache(type, path, spawnkeys)
    table.insert(AlyxLibGlobalPrecacheList, {
        type = type,
        path = path,
        spawnkeys = spawnkeys
    })
end

---Starts the precache process.
---@param callback? function # The function to call when the precaching is complete.
local function precacheAsync(callback)
    SpawnEntityFromTableAsynchronous("logic_script", {
        vscripts = "alyxlib/precache",
    }, function (spawnedEnt)
        if type(callback) == "function" then
            callback()
        end
        spawnedEnt:Kill()
    end, nil)
end

---
---Flushes the global precache list and precaches the assets.
---
---This is an asynchronous process; the assets will not be immediately available after calling this function.
---
---If you are precaching *after* the player has spawned, call this function after preceding [GlobalPrecache](lua://GlobalPrecache) calls.
---
---@param callback? function # The function to call when the precaching is complete.
function GlobalPrecacheFlush(callback)
    precacheAsync(function()
        AlyxLibGlobalPrecacheList = {}
        if type(callback) == "function" then
            callback()
        end
    end)
end

---
---Internal function used to start the precache process.
---
---**This should only be called manually if you know what you're doing!**
---@param context CScriptPrecacheContext
function _PrecacheGlobalItems(context)
    if #AlyxLibGlobalPrecacheList > 0 then
        devprints("Globally precaching", #AlyxLibGlobalPrecacheList, "resources...")
        for _, item in ipairs(AlyxLibGlobalPrecacheList) do
            devprints2("\tPrecaching", item.type, item.path)
            if item.type == "model" then
                PrecacheModel(item.path, context)
            elseif item.type == "entity" then
                PrecacheEntityFromTable(item.path, item.spawnkeys, context)
            else
                PrecacheResource(item.type, item.path, context)
            end
        end
    end
end

---player_spawn seems to be the soonest time to async spawn without crashing.
---@param params GameEventPlayerSpawn
ListenToGameEvent("player_spawn", function (params)
    precacheAsync()
end, nil)

return version