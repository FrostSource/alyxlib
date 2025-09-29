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

---Standard local weapon offsets from hand when equipped
local weaponOffsets = {
    [0] = { -- left
        hand_use_controller = Vector(0.027, 0.012, -0.124),
        hlvr_weapon_energygun = Vector(-0.025, 0.048, 2.014),
        hlvr_weapon_shotgun = Vector(0.402, 0.103, 1.652),
        hlvr_weapon_rapidfire = Vector(0.392, 0.102, 1.658),
        hlvr_multitool = Vector(3.079, 0.016, 1.209),
        -- unsure if offsets will be different for custom models,
        -- using hlvr_weapon_energygun offset
        hlvr_weapon_generic_pistol = Vector(-0.025, 0.048, 2.014),
    },
    [1] = { -- right
        hand_use_controller = Vector(0.026, -0.009, -0.125),
        hlvr_weapon_energygun = Vector(-0.025, -0.042, 2.013),
        hlvr_weapon_shotgun = Vector(0.402, -0.097, 1.651),
        hlvr_weapon_rapidfire = Vector(0.392, -0.096, 1.657),
        hlvr_multitool = Vector(3.079, -0.006, 1.208),
        -- unsure if offsets will be different for custom models,
        -- using hlvr_weapon_energygun offset
        hlvr_weapon_generic_pistol = Vector(-0.025, -0.042, 2.013),
    },
}

---
---Returns the default weapon offset for the given weapon classname and hand.
---
---@param classname string # The classname of the weapon
---@param hand CPropVRHand|number # The hand to get the offset for
---@return Vector # The default weapon offset, or `Vector()` if not found
local function GetDefaultWeaponOffset(classname, hand)
    hand = hand or Player.PrimaryHand:GetHandID()
    if IsEntity(hand) then
        hand = hand:GetHandID()
    end

    return weaponOffsets[hand][classname] or Vector()
end

---
---Sync the equipped weapon state of the player with the given weapon classname.
---
---If no classname is given, the weapon classname will be determined from the player's criteria.
---
---@param classname? string # The classname of the weapon to sync.
---@param handle? EntityHandle # The entity handle of the weapon to sync.
---@return EntityHandle? weaponHandle # The entity handle of the weapon that was equipped.
---@return CPropVRHand? handHandle # The entity handle of the hand that the weapon was equipped to.
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

    ---@type CPropVRHand?
    local handHandle = nil

    ---@type EntityHandle?
    local weaponHandle = nil

    -- Find the weapon and hand
    if not handle then
        local bestDistance = math.huge
        local bestWeapon = nil
        for h = 0, 1 do
            local hand = h == 0 and Player.LeftHand or Player.RightHand
            local offset = weaponOffsets[h][classname] or Vector()
            for _, wpn in ipairs(Entities:FindAllByClassname(classname)) do
                if wpn ~= hand.ItemHeld then
                    local dist = VectorDistance(offset, hand:TransformPointWorldToEntity(wpn:GetOrigin()))
                    if dist < bestDistance then
                        bestDistance = dist
                        bestWeapon = wpn
                        handHandle = hand
                    end
                end
            end
        end
        handle = bestWeapon
    end

    weaponHandle = handle

    -- if weaponHandle then
    --     print("Setting new weapon for hand", entstr(handHandle), classname, entstr(weaponHandle))
    --     debugoverlay:Sphere(weaponHandle:GetOrigin(), 2, 255, 255, 255, 255, true, 100)
    --     debugoverlay:Text(weaponHandle:GetOrigin(), 0, entstr(weaponHandle).." : "..entstr(handHandle), 0, 255, 255, 255, 255, 100)
    -- end

    if not IsValidEntity(weaponHandle) then
        warn("Could not find weapon entity for equipped weapon: " .. classname)
    end

    currentHandle = weaponHandle

    if handHandle == Player.PrimaryHand then

        if classname == "hand_use_controller" then
            Player.CurrentlyEquipped = PLAYER_WEAPON_HAND
        elseif classname == "hlvr_weapon_energygun" then
            Player.CurrentlyEquipped = PLAYER_WEAPON_ENERGYGUN
            Player.Items.weapons.energygun = weaponHandle
        elseif classname == "hlvr_weapon_rapidfire" then
            Player.CurrentlyEquipped = PLAYER_WEAPON_RAPIDFIRE
            Player.Items.weapons.rapidfire = weaponHandle
        elseif classname == "hlvr_weapon_shotgun" then
            Player.CurrentlyEquipped = PLAYER_WEAPON_SHOTGUN
            Player.Items.weapons.shotgun = weaponHandle
        elseif classname == "hlvr_multitool" then
            Player.CurrentlyEquipped = PLAYER_WEAPON_MULTITOOL
            Player.Items.weapons.multitool = weaponHandle
        elseif classname == "hlvr_weapon_generic_pistol" then
            Player.CurrentlyEquipped = PLAYER_WEAPON_GENERIC_PISTOL
            Player.Items.weapons.generic_pistol = weaponHandle

            -- Add this custom pistol if this is the first time encountering it
            if not vlua.find(Player.Items.weapons.genericpistols, weaponHandle) then
                table.insert(Player.Items.weapons.genericpistols, weaponHandle)
            end
        end

        Player:UpdateWeaponsExistence()

    end

    -- This event can fire before the player has a hand
    if handHandle then
        handHandle.ItemHeld = weaponHandle
    end

    savePlayerData()

    return weaponHandle, handHandle
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

---
---Check if weapon state synching is paused.
---
local function WeaponStateSyncPaused()
    return syncPaused
end

return {
    version = version,
    SyncEquippedWeaponState = SyncEquippedWeaponState,
    RestorePreviouslyEquippedWeaponState = RestorePreviouslyEquippedWeaponState,
    PauseWeaponStateSync = PauseWeaponStateSync,
    ResumeWeaponStateSync = ResumeWeaponStateSync,
    WeaponStateSyncPaused = WeaponStateSyncPaused,
    SavePlayerData = savePlayerData,
    LoadPlayerData = loadPlayerData,
    GetDefaultWeaponOffset = GetDefaultWeaponOffset
}