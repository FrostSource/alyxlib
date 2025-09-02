--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Advanced player-specific data management and logic handling.

    This module is designed as a library component and is not
    automatically loaded into the global scope.
    
    Usage:
        local PlayerData = require("alyxlib.player.data")
]]

local version = "v1.0.0"

---
---Forces all persistent player data to save.
---
---[CBasePlayer.Items](lua://CBasePlayer.Items)\
---[CBasePlayer.CurrentlyEquipped](lua://CBasePlayer.CurrentlyEquipped)\
---[CBasePlayer.LeftHand.WristItem](lua://CPropVRHand.WristItem)\
---[CBasePlayer.RightHand.WristItem](lua://CPropVRHand.WristItem)
---
local function savePlayerData()
    Storage.SaveTable(Player, "PlayerItems", Player.Items)

    -- Weapons aren't re-equipped on load so we need to save this
    Storage.SaveString(Player, "PlayerCurrentlyEquipped", Player.CurrentlyEquipped)

    if Player and Player.LeftHand then
        Storage.SaveEntity(Player, "LeftWristItem", Player.LeftHand.WristItem)
    end
    if Player and Player.RightHand then
        Storage.SaveEntity(Player, "RightWristItem", Player.RightHand.WristItem)
    end
end

---
---Loads all persistent player data.
---
local function loadPlayerData()
    Player.Items = Storage.LoadTable(Player, "PlayerItems", Player.Items)

    Player.CurrentlyEquipped = Storage.LoadString(Player, "PlayerCurrentlyEquipped", Player.CurrentlyEquipped)

    if Player and Player.LeftHand then
        Player.LeftHand.WristItem = Storage.LoadEntity(Player, "LeftWristItem", Player.LeftHand.WristItem)
    end
    if Player and Player.RightHand then
        Player.RightHand.WristItem = Storage.LoadEntity(Player, "RightWristItem", Player.RightHand.WristItem)
    end
end

local previouslyEquipped = nil
local currentlyEquipped = nil
local previousHandle = nil
local currentHandle = nil

local syncPaused = false

---
---Sync the equipped weapon state of the player with the given weapon classname.
---
---If no classname is given, the weapon classname will be determined from the player's criteria.
---
---@param classname? string # The classname of the weapon to sync.
---@return EntityHandle? weaponHandle # The entity handle of the weapon that was equipped.
local function SyncEquippedWeaponState(classname, handle)
    if syncPaused then return end

    if classname == nil then
        local criteria = Player:GetCriteria()
        classname = criteria.primaryhand_active_attachment
    end

    -- print("Swapping from", Player.CurrentlyEquipped, "to", classname)

    -- Cache current state so it can be restored later
    -- print("Saving equipped", Player.PreviouslyEquipped, Player.CurrentlyEquipped)
    previouslyEquipped = Player.PreviouslyEquipped
    currentlyEquipped = Player.CurrentlyEquipped
    previousHandle = currentHandle

    Player.PreviouslyEquipped = Player.CurrentlyEquipped

    ---@type EntityHandle
    local weaponHandle = nil

    if classname == "hand_use_controller" then
        Player.CurrentlyEquipped = PLAYER_WEAPON_HAND
        weaponHandle = Player.PrimaryHand
        currentHandle = nil
    else
        weaponHandle = handle or Entities:FindBestMatching("", classname, Player.PrimaryHand:GetPalmPosition(), 64)
        -- if weaponHandle then
        --     print("Setting new weapon for", classname, weaponHandle)
        --     Debug.Sphere(weaponHandle:GetOrigin(), 2, 10)
        -- end

        if not IsValidEntity(weaponHandle) then
            warn("Could not find weapon entity for equipped weapon: " .. classname)
        end

        currentHandle = weaponHandle

        if classname == "hlvr_weapon_energygun" then
            Player.CurrentlyEquipped = PLAYER_WEAPON_ENERGYGUN
            if not IsValidEntity(Player.Items.weapons.energygun) then
                Player.Items.weapons.energygun = weaponHandle
            else
                weaponHandle = Player.Items.weapons.energygun
            end
        elseif classname == "hlvr_weapon_rapidfire" then
            Player.CurrentlyEquipped = PLAYER_WEAPON_RAPIDFIRE
            if not IsValidEntity(Player.Items.weapons.rapidfire) then
                Player.Items.weapons.rapidfire = weaponHandle
            else
                weaponHandle = Player.Items.weapons.rapidfire
            end
        elseif classname == "hlvr_weapon_shotgun" then
            Player.CurrentlyEquipped = PLAYER_WEAPON_SHOTGUN
            if not IsValidEntity(Player.Items.weapons.shotgun) then
                Player.Items.weapons.shotgun = weaponHandle
            else
                weaponHandle = Player.Items.weapons.shotgun
            end
        elseif classname == "hlvr_multitool" then
            Player.CurrentlyEquipped = PLAYER_WEAPON_MULTITOOL
            if not IsValidEntity(Player.Items.weapons.multitool) then
                Player.Items.weapons.multitool = weaponHandle
            else
                weaponHandle = Player.Items.weapons.multitool
            end
        elseif classname == "hlvr_weapon_generic_pistol" then
            Player.CurrentlyEquipped = PLAYER_WEAPON_GENERIC_PISTOL
            Player.Items.weapons.generic_pistol = weaponHandle

            -- Add this custom pistol if this is the first time encountering it
            if not vlua.find(Player.Items.weapons.genericpistols, weaponHandle) then
                table.insert(Player.Items.weapons.genericpistols, weaponHandle)
            end
        end
    end

    Player:UpdateWeaponsExistence()

    -- This event can fire before the player has a hand
    if Player.PrimaryHand then
        Player.PrimaryHand.ItemHeld = weaponHandle
    end

    savePlayerData()

    return weaponHandle
end

---
---Restore the previously equipped weapon state.
---
---@param fireEvent? boolean # Forces the `weapon_switch` event to be fired when restoring.
local function RestorePreviouslyEquippedWeaponState(fireEvent)
    Player.CurrentlyEquipped = previouslyEquipped
    if fireEvent then
        ---@type GameEventWeaponSwitch
        FireGameEvent("weapon_switch", {
            item = currentlyEquipped,
        })
    else
        SyncEquippedWeaponState(currentlyEquipped, previousHandle)
    end
end

---
---Pause weapon state synching. This will prevent the `weapon_switch` player event from firing.
---
local function PauseWeaponStateSync()
    syncPaused = true
end

---
---Resume weapon state synching. This will allow the `weapon_switch` player event to fire.
---
local function ResumeWeaponStateSync()
    syncPaused = false
end

return {
    version = version,
    SyncEquippedWeaponState = SyncEquippedWeaponState,
    RestorePreviouslyEquippedWeaponState = RestorePreviouslyEquippedWeaponState,
    PauseWeaponStateSync = PauseWeaponStateSync,
    ResumeWeaponStateSync = ResumeWeaponStateSync,
    SavePlayerData = savePlayerData,
    LoadPlayerData = loadPlayerData
}