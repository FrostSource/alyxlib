--[[
    v1.0.0
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
        print("GLOBAL PRECACHE")
        _PrecacheGlobalItems(context)
    end

    return
end

require "alyxlib.player"

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

---Add an asset to be precached when the player spawns.
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

---Internal function used to start the precache process.
---
---**This should only be called manually if you know what you're doing!**
---@param context CScriptPrecacheContext
function _PrecacheGlobalItems(context)
    devprint("Globally precaching", #AlyxLibGlobalPrecacheList, "resources...")
    for _, item in ipairs(AlyxLibGlobalPrecacheList) do
        devprints("\nPrecaching", item.type, item.path)
        if item.type == "model" then
            PrecacheModel(item.path, context)
        elseif item.type == "entity" then
            PrecacheEntityFromTable(item.path, item.spawnkeys, context)
        else
            PrecacheResource(item.type, item.path, context)
        end
    end
end

RegisterPlayerEventCallback("player_activate", function (params)
    SpawnEntityFromTableAsynchronous("logic_script", {
        vscripts = "alyxlib/precache"
    }, function (spawnedEnt)
    end, nil)
end)

local version = "v1.0.0"

print("precache.lua ".. version .." initialized...")

return version