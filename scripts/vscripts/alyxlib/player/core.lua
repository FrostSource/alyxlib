--[[
    v4.2.2
    https://github.com/FrostSource/alyxlib

    Player script allows for more advanced player manipulation and easier
    entity access for player related entities by extending the player class.

    If not using `alyxlib/init.lua`, load this file at game start using the following line:

    require "alyxlib.player.core"
]]
require "alyxlib.utils.common"
require "alyxlib.globals"
require "alyxlib.extensions.entity"
require "alyxlib.storage"

local version = "v4.2.2"

-----------------------------
-- Class extension members --
-----------------------------

---**The base player entity.**
---@type CBasePlayer
Player = nil
---**The entity handle of the VR headset (if in VR mode).**
---@type CPropHMDAvatar
CBasePlayer.HMDAvatar = nil
---**The entity handle of the VR anchor (if in VR mode).**
---@type CBaseEntity
CBasePlayer.HMDAnchor = nil
---**1 = Left hand, 2 = Right hand.**
---@type CPropVRHand[]
CBasePlayer.Hands = {}
---**Player's left hand.**
---@type CPropVRHand
CBasePlayer.LeftHand = nil
---**Player's right hand.**
---@type CPropVRHand
CBasePlayer.RightHand = nil
---**Player's primary hand.**
---@type CPropVRHand
CBasePlayer.PrimaryHand = nil
---**Player's secondary hand.**
---@type CPropVRHand
CBasePlayer.SecondaryHand = nil
---**If the player is left handed.**
---@type boolean
CBasePlayer.IsLeftHanded = false
---**The last entity that was dropped by the player.**
---@type EntityHandle
CBasePlayer.LastItemDropped = nil
---**The classname of the last entity dropped by the player. In case the entity no longer exists.**
---@type string
CBasePlayer.LastClassDropped = ""
---**The last entity that was grabbed by the player.**
---@type EntityHandle
CBasePlayer.LastItemGrabbed = nil
---**The classname of the last entity grabbed by the player. In case the entity no longer exists.**
---@type string
CBasePlayer.LastClassGrabbed = ""
---**The player hand that last grabbed an object.**
---@type CPropVRHand
CBasePlayer.LastGrabHand = nil

---@alias PLAYER_WEAPON_HAND           "hand_use_controller"
---@alias PLAYER_WEAPON_ENERGYGUN      "hlvr_weapon_energygun"
---@alias PLAYER_WEAPON_RAPIDFIRE      "hlvr_weapon_rapidfire"
---@alias PLAYER_WEAPON_SHOTGUN        "hlvr_weapon_shotgun"
---@alias PLAYER_WEAPON_MULTITOOL      "hlvr_multitool"
---@alias PLAYER_WEAPON_GENERIC_PISTOL "hlvr_weapon_generic_pistol"
PLAYER_WEAPON_HAND           = "hand_use_controller"
PLAYER_WEAPON_ENERGYGUN      = "hlvr_weapon_energygun"
PLAYER_WEAPON_RAPIDFIRE      = "hlvr_weapon_rapidfire"
PLAYER_WEAPON_SHOTGUN        = "hlvr_weapon_shotgun"
PLAYER_WEAPON_MULTITOOL      = "hlvr_multitool"
PLAYER_WEAPON_GENERIC_PISTOL = "hlvr_weapon_generic_pistol"

---@alias PlayerPistolUpgrades
---|"pistol_upgrade_laser_sight"
---|"pistol_upgrade_reflex_sight"
---|"pistol_upgrade_bullet_hopper"
---|"pistol_upgrade_burst_fire"

---@alias PlayerRapidfireUpgrades
---|"rapidfire_upgrade_reflex_sight"
---|"rapidfire_upgrade_laser_right"
---|"rapidfire_upgrade_extended_magazine"

---@alias PlayerShotgunUpgrades
---|"shotgun_upgrade_autoloader"
---|"shotgun_upgrade_grenade_launcher"
---|"shotgun_upgrade_laser_sight"
---|"shotgun_upgrade_quick_fire"

---@alias PlayerWeaponUpgrades PlayerPistolUpgrades|PlayerRapidfireUpgrades|PlayerShotgunUpgrades

---
---The classname of the weapon/item attached to the primary hand.
---
---@type string|PLAYER_WEAPON_HAND|PLAYER_WEAPON_ENERGYGUN|PLAYER_WEAPON_RAPIDFIRE|PLAYER_WEAPON_SHOTGUN|PLAYER_WEAPON_MULTITOOL|PLAYER_WEAPON_GENERIC_PISTOL
CBasePlayer.CurrentlyEquipped = PLAYER_WEAPON_HAND
---
---The classname of the weapon/item previously attached to the primary hand.
---
---@type string|PLAYER_WEAPON_HAND|PLAYER_WEAPON_ENERGYGUN|PLAYER_WEAPON_RAPIDFIRE|PLAYER_WEAPON_SHOTGUN|PLAYER_WEAPON_MULTITOOL|PLAYER_WEAPON_GENERIC_PISTOL
CBasePlayer.PreviouslyEquipped = PLAYER_WEAPON_HAND

---**Table of items player currently has possession of.**
CBasePlayer.Items = {
    -- grenades = {
    --     ---Frag grenades.
    --     frag = 0,
    --     ---Xen grenades.
    --     xen = 0,
    -- },
    -- ---Healthpen syringes.
    -- healthpen = 0,

    ---Ammo in the backpack.
    ammo = {
        ---Ammo for the main pistol. This is number of magazines, not bullets. Multiply by 10 to get bullets.
        energygun = 0,
        ---Ammo for the rapidfire pistol. This is number of magazines, not bullets. Multiply by 30 to get bullets.
        rapidfire = 0,
        ---Ammo for the shotgun. This is number of shells.
        shotgun = 0,
        ---Ammo for the generic pistol. This is number of magazines, not bullets.
        ---@TODO Try to track for individual generic pistols
        generic_pistol = 0,
    },

    ---Weapons in the inventory
    weapons = {
        ---The hlvr_weapon_energygun
        ---@type EntityHandle
        energygun = nil,
        ---The hlvr_weapon_rapidfire
        ---@type EntityHandle
        rapidfire = nil,
        ---The hlvr_weapon_shotgun
        ---@type EntityHandle
        shotgun = nil,
        ---The hlvr_multitool
        ---@type EntityHandle
        multitool = nil,
        ---The current hlvr_weapon_generic_pistol equipped
        ---@type EntityHandle
        generic_pistol = nil,
        ---List of generic pistols the player has
        ---@type EntityHandle[]
        genericpistols = {},
    },

    ---Crafting currency the player has.
    ---@type integer
    resin = nil,

    ---Total number of resin player has had in inventory, regardless of upgrades.
    ---@type integer
    resin_found = nil,
}

---**The entity handle of the item held by this hand.**
---@type EntityHandle
CPropVRHand.ItemHeld = nil
---**The last entity that was dropped by this hand.**
---@type EntityHandle
CPropVRHand.LastItemDropped = nil
---**The classname of the last entity dropped by this hand. In case the entity no longer exists.**
---@type string
CPropVRHand.LastClassDropped = ""
---**The last entity that was grabbed by this hand.**
---@type EntityHandle
CPropVRHand.LastItemGrabbed = nil
---**The classname of the last entity grabbed by this hand. In case the entity no longer exists.**
---@type string
CPropVRHand.LastClassGrabbed = ""
---**The literal type of this hand.**
---@type integer|0|1
CPropVRHand.Literal = nil
---**The entity handle of the item in the wrist pocket.**
---@type EntityHandle?
CPropVRHand.WristItem = nil
---**The opposite hand to this one.**
---@type CPropVRHand
CPropVRHand.Opposite = nil


-------------------------------
-- Class extension functions --
-------------------------------

---
---Forces the player to drop an entity if held.
---
---@param handle EntityHandle # Handle of the entity to drop
function CBasePlayer:DropByHandle(handle)
    if IsValidEntity(handle) then
        local dmg = CreateDamageInfo(handle, handle, Vector(), Vector(), 0, 2)
        handle:TakeDamage(dmg)
        DestroyDamageInfo(dmg)
    end
end

---
---Forces the player to drop any item held in their left hand.
---
function CBasePlayer:DropLeftHand()
    self:DropByHandle(self.LeftHand.ItemHeld)
end
Expose(CBasePlayer.DropLeftHand, "DropLeftHand", CBasePlayer)

---
---Forces the player to drop any item held in their right hand.
---
function CBasePlayer:DropRightHand()
    self:DropByHandle(self.RightHand.ItemHeld)
end
Expose(CBasePlayer.DropRightHand, "DropRightHand", CBasePlayer)

---
---Forces the player to drop any item held in their primary hand.
---
function CBasePlayer:DropPrimaryHand()
    self:DropByHandle(self.PrimaryHand.ItemHeld)
end
Expose(CBasePlayer.DropPrimaryHand, "DropPrimaryHand", CBasePlayer)

---
---Forces the player to drop any item held in their secondary/off hand.
---
function CBasePlayer:DropSecondaryHand()
    self:DropByHandle(self.SecondaryHand.ItemHeld)
end
Expose(CBasePlayer.DropSecondaryHand, "DropSecondaryHand", CBasePlayer)

---
---Forces the player to drop the caller entity if held.
---
---@param data IOParams # The IOParams table
function CBasePlayer:DropCaller(data)
    self:DropByHandle(data.caller)
end
Expose(CBasePlayer.DropCaller, "DropCaller", CBasePlayer)

---
---Forces the player to drop the activator entity if held.
---
---@param data IOParams # The IOParams table
function CBasePlayer:DropActivator(data)
    self:DropByHandle(data.activator)
end
Expose(CBasePlayer.DropActivator, "DropActivator", CBasePlayer)

---
---Forces the player to grab `handle` with `hand`.
---
---@param handle EntityHandle # Handle of the entity to grab
---@param hand? CPropVRHand|0|1 # Hand to grab with
function CBasePlayer:GrabByHandle(handle, hand)
    if IsEntity(handle, true) then
        if type(hand) ~= "number" then
            if hand ~= nil and IsEntity(hand) and hand:IsInstance(CPropVRHand) then
                hand = hand:GetHandID()
            else
                -- If no hand provided, find nearest
                local pos = handle:GetOrigin()
                if VectorDistanceSq(self.Hands[1]:GetOrigin(),pos) < VectorDistanceSq(self.Hands[2]:GetOrigin(),pos) then
                    hand = 0
                else
                    hand = 1
                end
            end
        end
        DoEntFireByInstanceHandle(handle, "Use", tostring(hand), 0, self, self)
    end
end

---
---Force the player to grab the caller entity.
---
---@param data IOParams # The IOParams table
function CBasePlayer:GrabCaller(data)
    self:GrabByHandle(data.caller)
end
Expose(CBasePlayer.GrabCaller, "GrabCaller", CBasePlayer)

---
---Force the player to grab the activator entity.
---
---@param data IOParams # The IOParams table
function CBasePlayer:GrabActivator(data)
    self:GrabByHandle(data.activator)
end
Expose(CBasePlayer.GrabActivator, "GrabActivator", CBasePlayer)

---
---Movement types for the VR player.
---
---@enum PlayerMoveType
PlayerMoveType = {
    TeleportBlink = 0,
    TeleportShift = 1,
    ContinuousHead = 2,
    ContinuousHand = 3,
}

---
---Get VR movement type.
---
---@return PlayerMoveType # The VR movement type
function CBasePlayer:GetMoveType()
    return Convars:GetInt('hlvr_movetype_default') --[[@as PlayerMoveType]]
end

---
---Get VR movement type.
---
---@return PlayerMoveType # The VR movement type
function GetPlayerMoveType()
    return Convars:GetInt('hlvr_movetype_default') --[[@as PlayerMoveType]]
end

---
---Sets the VR movement type.
---
---@param movetype PlayerMoveType # The VR movement type
function CBasePlayer:SetMoveType(movetype)
    Convars:SetInt("vr_movetype_set", movetype)
end

---
---Sets the VR movement type.
---
---@param movetype PlayerMoveType # The VR movement type
function SetPlayerMoveType(movetype)
    Convars:SetInt("vr_movetype_set", movetype)
end

---
---Returns the entity the player is looking at directly.
---
---@param maxDistance? number # Max distance the trace can search
---@return EntityHandle? # The entity the player is looking at
function CBasePlayer:GetLookingAt(maxDistance)
    maxDistance = maxDistance or 2048
    ---@type TraceTableLine
    local traceTable = {
        startpos = self:EyePosition(),
        endpos = self:EyePosition() + AnglesToVector(self:EyeAngles()) * maxDistance,
        ignore = self,
    }
    if TraceLine(traceTable) then
        return traceTable.enthit
    end
    return nil
end

---
---Disables fall damage for the player.
---
function CBasePlayer:DisableFallDamage()
    ---@TODO: Consider changing to SaveEntity.
    local name = Storage.LoadString(self, "FallDamageFilterName", DoUniqueString("__player_fall_damage_filter"))
    Storage.SaveString(self, "FallDamageFilterName", name)
    local filter = Entities:FindByName(nil, name) or SpawnEntityFromTableSynchronous("filter_damage_type",{
        targetname = name,
        damagetype = "32"
    })
    DoEntFireByInstanceHandle(self, "SetDamageFilter", name, 0, self, self)
end
Expose(CBasePlayer.DisableFallDamage, "DisableFallDamage", CBasePlayer)

---
---Enables fall damage for the player.
---
function CBasePlayer:EnableFallDamage()
    --Killing the filter is not necessary but may be helpful.
    local name = Storage.LoadString(self, "FallDamageFilterName", "")
    if name ~= "" then
        local filter = Entities:FindByName(nil, name)
        if filter then filter:Kill() end
    end
    DoEntFireByInstanceHandle(self, "SetDamageFilter", "", 0, self, self)
end
Expose(CBasePlayer.EnableFallDamage, "EnableFallDamage", CBasePlayer)

---
---Adds resources to the player.
---
---@param pistol_ammo? number # Amount of pistol ammo
---@param rapidfire_ammo? number # Amount of rapidfire ammo
---@param shotgun_ammo? number # Amount of shotgun ammo
---@param resin? number # Amount of resin
function CBasePlayer:AddResources(pistol_ammo, rapidfire_ammo, shotgun_ammo, resin)
    pistol_ammo = pistol_ammo or 0
    rapidfire_ammo = rapidfire_ammo or 0
    shotgun_ammo = shotgun_ammo or 0
    resin = resin or 0
    SendToServerConsole("hlvr_addresources "..pistol_ammo.." "..rapidfire_ammo.." "..shotgun_ammo.." "..resin)
    self:SetItems(
        self.Items.ammo.energygun + pistol_ammo,
        nil,
        self.Items.ammo.rapidfire + rapidfire_ammo,
        self.Items.ammo.shotgun + shotgun_ammo,
        self.Items.resin + resin
    )
end

---
---Sets resources for the player.
---
---**This might give inaccurate amounts for omitted values.**
---
---@param pistol_ammo? number # Amount of pistol ammo
---@param rapidfire_ammo? number # Amount of rapidfire ammo
---@param shotgun_ammo? number # Amount of shotgun ammo
---@param resin? number # Amount of resin
function CBasePlayer:SetResources(pistol_ammo, rapidfire_ammo, shotgun_ammo, resin)
    -- Number value is different in-game (setresources uses bullets)
    SendToServerConsole("hlvr_setresources "..
        (pistol_ammo or self.Items.ammo.energygun*10).." "..
        (rapidfire_ammo or self.Items.ammo.rapidfire*30).." "..
        (shotgun_ammo or self.Items.ammo.shotgun).." "..
        (resin or self.Items.resin)
    )
    self:SetItems(
        pistol_ammo or self.Items.ammo.energygun,
        nil,
        rapidfire_ammo or self.Items.ammo.rapidfire,
        shotgun_ammo or self.Items.ammo.shotgun,
        resin or self.Items.resin
    )
end

---
---Manually sets the items that player has.
---
---**This is purely for scripting and does not modify the actual items the player has in-game.**
---
---Use [Player:AddResources](lua://CBasePlayer.AddResources) to modify in-game items.
---
---@param energygun_ammo? integer # Amount of pistol ammo
---@param generic_pistol_ammo? integer # Amount of generic pistol ammo
---@param rapidfire_ammo? integer # Amount of rapidfire ammo
---@param shotgun_ammo? integer # Amount of shotgun ammo
---@param resin? integer # Amount of resin
function CBasePlayer:SetItems(
    energygun_ammo,
    generic_pistol_ammo,
    rapidfire_ammo,
    shotgun_ammo,
    resin
)
    self.Items.ammo.energygun = energygun_ammo or self.Items.ammo.energygun
    self.Items.ammo.generic_pistol = generic_pistol_ammo or self.Items.ammo.generic_pistol
    self.Items.ammo.rapidfire = rapidfire_ammo or self.Items.ammo.rapidfire
    self.Items.ammo.shotgun = shotgun_ammo or self.Items.ammo.shotgun
    self.Items.resin = resin or self.Items.resin

    ---@TODO: Consider moving save function above this
    Storage.SaveTable(Player, "PlayerItems", Player.Items)
end


---
---Adds pistol ammo to the player.
---
---@param amount number # Amount of pistol ammo
function CBasePlayer:AddPistolAmmo(amount)
    self:AddResources(amount, nil, nil, nil)
end
---
---Adds shotgun ammo to the player.
---
---@param amount number # Amount of shotgun ammo
function CBasePlayer:AddShotgunAmmo(amount)
    self:AddResources(nil, nil, amount, nil)
end
---
---Adds rapidfire ammo to the player.
---
---@param amount number # Amount of rapidfire ammo
function CBasePlayer:AddRapidfireAmmo(amount)
    self:AddResources(nil, amount, nil, nil)
end
---
---Adds resin to the player.
---
---@param amount number # Amount of resin
function CBasePlayer:AddResin(amount)
    self:AddResources(nil, nil, nil, amount)
end

---
---Gets the items currently held or in wrist pockets.
---
---@return EntityHandle[] # List of items
function CBasePlayer:GetImmediateItems()
    local lh, rh = self.LeftHand, self.RightHand
    local items = {}
    if lh and lh.WristItem then items[#items+1] = lh.WristItem end
    if rh and rh.WristItem then items[#items+1] = rh.WristItem end
    if lh and lh.ItemHeld then items[#items+1] = lh.ItemHeld end
    if rh and rh.ItemHeld then items[#items+1] = rh.ItemHeld end
    return items
end

---
---Gets the grenades currently held and in wrist pockets.
---
---@return EntityHandle[] # List of grenades
function CBasePlayer:GetGrenades()
    local grenades = {}
    local immediate_items = self:GetImmediateItems()
    for _, item in ipairs(immediate_items) do
        if item and (item:GetClassname() == "item_hlvr_grenade_frag" or item:GetClassname() == "item_hlvr_grenade_xen") then
            grenades[#grenades+1] = item
        end
    end
    return grenades
end

---
---Gets the health pens currently held and in wrist pockets.
---
---@return EntityHandle[]
function CBasePlayer:GetHealthPens()
    local healthpens = {}
    local immediate_items = self:GetImmediateItems()
    for _, item in ipairs(immediate_items) do
        if item and (item:GetClassname() == "item_healthvial") then
            healthpens[#healthpens+1] = item
        end
    end
    return healthpens
end

---
---Marges an existing prop with a given hand.
---
---@param hand CPropVRHand|0|1 # The hand handle or ID
---@param prop EntityHandle|string # The prop handle or targetname
---@param hide_hand boolean # If the hand should turn invisible after merging
function CBasePlayer:MergePropWithHand(hand, prop, hide_hand)
    if type(hand) == "number" then
        hand = self.Hands[hand+1]
    end
    hand:MergeProp(prop, hide_hand)
end

---
---Checks if the player has a gun equipped.
---`hlvr_multitool` is not considered a "gun"
---
---@return boolean # `true` if the player has a gun equipped
function CBasePlayer:HasWeaponEquipped()
    return self.CurrentlyEquipped == PLAYER_WEAPON_ENERGYGUN
        or self.CurrentlyEquipped == PLAYER_WEAPON_SHOTGUN
        or self.CurrentlyEquipped == PLAYER_WEAPON_RAPIDFIRE
        or self.CurrentlyEquipped == PLAYER_WEAPON_GENERIC_PISTOL
end

---
---Get the amount of ammo stored in the backpack for the currently equipped weapon.
---
---**This is not accurate if ammo was given through special means like `info_hlvr_equip_player`.**
---
---@return number # The amount of ammo, or `0` if no weapon equipped
function CBasePlayer:GetCurrentWeaponReserves()
    local currentlyEquipped = self.CurrentlyEquipped
    if currentlyEquipped == PLAYER_WEAPON_ENERGYGUN then
        return self.Items.ammo.energygun or 0
    elseif currentlyEquipped == PLAYER_WEAPON_SHOTGUN then
        return self.Items.ammo.shotgun or 0
    elseif currentlyEquipped == PLAYER_WEAPON_RAPIDFIRE then
        return self.Items.ammo.rapidfire or 0
    elseif currentlyEquipped == PLAYER_WEAPON_GENERIC_PISTOL then
        return self.Items.ammo.generic_pistol or 0
    end
    return 0
end

---
---Checks if the player has an item (wrist) holder equipped.
---
---@return boolean # `true` if the player has an item holder
function CBasePlayer:HasItemHolder()
    for _, hand in ipairs(self.Hands) do
        if hand:GetFirstChildWithClassname("hlvr_hand_item_holder") then
            return true
        end
    end
    -- For one handed players.
    if self.HMDAvatar:GetFirstChildWithClassname("hlvr_hand_item_holder") then
        return true
    end
    return false
end

---
---Checks if the player has grabbity gloves equipped.
---
---@return boolean # `true` if the player has grabbity gloves
function CBasePlayer:HasGrabbityGloves()
    return self.PrimaryHand:GetGrabbityGlove() ~= nil
end

function CBasePlayer:GetFlashlight()
    return self.SecondaryHand:GetFirstChildWithClassname("hlvr_flashlight_attachment")
end

---
---Gets the first entity the flashlight is pointed at.
---
---If flashlight does not exist, both returns will be `nil`.
---
---@param maxDistance? number # Max tracing distance (default: 2048)
---@return EntityHandle|nil # The entity that was hit
---@return Vector|nil # The position the trace hit, regardless of entity found
function CBasePlayer:GetFlashlightPointedAt(maxDistance)
    local flashlight = self:GetFlashlight()
    if flashlight then
        local attach = flashlight:ScriptLookupAttachment("light_attach")
        local origin = flashlight:GetAttachmentOrigin(attach)
        local endpoint = origin + flashlight:GetAttachmentForward(attach) * (maxDistance or 2048)
        ---@type TraceTableLine
        local traceTable = {
            startpos = origin,
            endpos = endpoint,
            ignore = flashlight,
        }
        TraceLine(traceTable)
        return traceTable.enthit, traceTable.pos
    end
end

---
---Gets the current resin count the player has.
---
---This is can be more accurate than `Player.Items.resin`.
---
---Calling this will update `Player.Items.resin`.
---
---@return number # The current resin count
function CBasePlayer:GetResin()
    local t = ({}) --[[@as CriteriaTable]]
    self:GatherCriteria(t)
    local r = t.current_crafting_currency
    if Player.Items.resin ~= r then
        Player.Items.resin = r
    end
    return r
end

---
---Gets if player is holding a given entity in either hand.	
---
---@param entity EntityHandle # The entity to check
---@return boolean # `true` if the player is holding the entity
function CBasePlayer:IsHolding(entity)
    return self.PrimaryHand.ItemHeld == entity or self.SecondaryHand.ItemHeld == entity
end

---
---Gets the entity handle of the currently equipped weapon, including `hlvr_multitool`.
---
---@return EntityHandle|nil # The equipped weapon, or `nil` if no weapon equipped
function CBasePlayer:GetWeapon()
    if self.CurrentlyEquipped == PLAYER_WEAPON_ENERGYGUN then
        return self.Items.weapons.energygun
            or Entities:FindByClassnameNearest("hlvr_weapon_energygun", self.PrimaryHand:GetPalmPosition(), 128)--[[@as EntityHandle]]
    elseif self.CurrentlyEquipped == PLAYER_WEAPON_RAPIDFIRE then
        return self.Items.weapons.rapidfire
            or Entities:FindByClassnameNearest("hlvr_weapon_rapidfire", self.PrimaryHand:GetPalmPosition(), 128)--[[@as EntityHandle]]
    elseif self.CurrentlyEquipped == PLAYER_WEAPON_SHOTGUN then
        return self.Items.weapons.shotgun
            or Entities:FindByClassnameNearest("hlvr_weapon_shotgun", self.PrimaryHand:GetPalmPosition(), 128)--[[@as EntityHandle]]
    elseif self.CurrentlyEquipped == PLAYER_WEAPON_GENERIC_PISTOL then
        return self.Items.weapons.generic_pistol
            or Entities:FindByClassnameNearest("hlvr_weapon_generic_pistol", self.PrimaryHand:GetPalmPosition(), 128)--[[@as EntityHandle]]
    elseif self.CurrentlyEquipped == PLAYER_WEAPON_MULTITOOL then
        return self.Items.weapons.multitool
            or Entities:FindByClassnameNearest("hlvr_multitool", self.PrimaryHand:GetPalmPosition(), 128)--[[@as EntityHandle]]
    else
        return nil
    end
end

---
---Gets the current upgrades for the player's pistol.
---
---@param weapon? EntityHandle # Optional weapon to check instead of the player's weapon
---@return PlayerPistolUpgrades[] # List of upgrades
function CBasePlayer:GetPistolUpgrades(weapon)
    local pistol = weapon or self.Items.weapons.energygun

    if not pistol then
        return {}
    end

    local upgrades = {}

    for _, child in ipairs(pistol:GetChildrenMemSafe()) do
        if child:GetClassname() == "reflex_sights" then
            table.insert(upgrades, "pistol_upgrade_reflex_sight")
        elseif child:GetClassname() == "hlvr_upgrade_hopper" then
            table.insert(upgrades, "pistol_upgrade_bullet_hopper")
        elseif child:GetName() == "hlvr_weapon_upgrade_burst_fire" then
            table.insert(upgrades, "pistol_upgrade_burst_fire")
        elseif child:GetModelName() == "models/weapons/vr_alyxgun/vr_alyxgun_attach_base.vmdl" or child:GetModelName() == "models/weapons/vr_alyxgun/vr_alyxgun_attach_base_lhand.vmdl" then
            table.insert(upgrades, "pistol_upgrade_laser_sight")
        end
    end

    return upgrades
end

---
---Gets the current upgrades for the player's rapidfire.
---
---@param weapon? EntityHandle # Optional weapon to check instead of the player's weapon
---@return PlayerRapidfireUpgrades[] # List of upgrades
function CBasePlayer:GetRapidfireUpgrades(weapon)
    local rapidfire = weapon or self.Items.weapons.rapidfire

    if not rapidfire then
        return {}
    end

    local upgrades = {}

    for _, child in ipairs(rapidfire:GetChildrenMemSafe()) do
        if child:GetClassname() == "reflex_sights" then
            table.insert(upgrades, "rapidfire_upgrade_reflex_sight")
        elseif child:GetName() == "rapidfire_laser_sight" then
            table.insert(upgrades, "rapidfire_upgrade_laser_sight")
        elseif child:GetName() == "rapidfire_extended_magazine" then
            table.insert(upgrades, "rapidfire_upgrade_extended_magazine")
        end
    end

    return upgrades
end

---
---Gets the current upgrades for the player's shotgun.
---
---**This will NOT return "shotgun_upgrade_quick_fire" because there is no known way to detect this!**
---
---@param weapon? EntityHandle # Optional weapon to check instead of the player's weapon
---@return PlayerShotgunUpgrades[] # List of upgrades
function CBasePlayer:GetShotgunUpgrades(weapon)
    local shotgun = weapon or self.Items.weapons.shotgun

    if not shotgun then
        return {}
    end

    local upgrades = {}

    for _, child in ipairs(shotgun:GetChildrenMemSafe()) do
        if child:GetName() == "shotgun_autoloader" then
            table.insert(upgrades, "shotgun_upgrade_autoloader")
        elseif child:GetModelName() == "models/weapons/vr_shotgun/shotgun_grenade_attach_upgrade.vmdl" or child:GetModelName() == "models/weapons/vr_shotgun/shotgun_grenade_attach_upgrade_lhand.vmdl" then
            table.insert(upgrades, "shotgun_upgrade_grenade_launcher")
        elseif child:GetName() == "shotgun_lasersight" then
            table.insert(upgrades, "shotgun_upgrade_laser_sight")
        end
    end

    return upgrades
end

---
---Checks if the player has a specific weapon upgrade.
---
---@param upgrade PlayerPistolUpgrades|PlayerRapidfireUpgrades|PlayerShotgunUpgrades # Upgrade to check
---@return boolean # `true` if the player has the upgrade
function CBasePlayer:HasWeaponUpgrade(upgrade)
    if vlua.find(self:GetPistolUpgrades(), upgrade) then
        return true
    elseif vlua.find(self:GetRapidfireUpgrades(), upgrade) then
        return true
    elseif vlua.find(self:GetShotgunUpgrades(), upgrade) then
        return true
    end
    return false
end

---
---Gets the forward vector of the player in world space coordinates (z is zeroed).
---
---@return Vector # Forward vector
function CBasePlayer:GetWorldForward()
    local f = self:GetForwardVector()
    f.z = 0
    return f
end

local specialAttachmentsOrder = {
    "hlvr_prop_renderable_glove",
    "hand_use_controller",
    "worldui_interact_controller",
    "hlvr_weaponswitch_controller",
}

---
---Updates player weapon inventory, both removing and setting.
---
---@param removes? (string|EntityHandle)[] # List of classnames or handles to remove
---@param set? string|EntityHandle # Classname or handle to set as active weapon
---@return EntityHandle? # The handle of the newly set weapon if given and found
function CBasePlayer:UpdateWeapons(removes, set)
    local hand = Player.PrimaryHand

    local setFound = nil
    local specialAttachmentsFound = {}
    local attachments = {}
    local attachment = hand:GetHandAttachment()
    while attachment ~= nil do
        if not removes or not (vlua.find(removes, attachment) or vlua.find(removes, attachment:GetClassname())) then
            if attachment == set or attachment:GetClassname() == set then
                setFound = attachment
            end

            -- Do not track multiple versions of the same entity
            if not vlua.find(attachments, attachment) and not vlua.find(specialAttachmentsFound, attachment) then
                if vlua.find(specialAttachmentsOrder, attachment:GetClassname()) then
                    specialAttachmentsFound[attachment:GetClassname()] = attachment
                else
                    table.insert(attachments, 1, attachment)
                end
            end
        end
        hand:RemoveHandAttachmentByHandle(attachment)
        -- Get next current attachment
        attachment = hand:GetHandAttachment()
    end

    -- Add special attachments back first to avoid crash
    for _, specialName in ipairs(specialAttachmentsOrder) do
        local specialAttachment = specialAttachmentsFound[specialName]
        if specialAttachment then
            hand:AddHandAttachment(specialAttachment)
        end
    end

    -- Add back attachments that weren't removed
    for _, removedAttachment in ipairs(attachments) do
        if removedAttachment ~= setFound then
            hand:AddHandAttachment(removedAttachment)
        end
    end

    -- Add back the attachment to be set last
    if setFound ~= nil then
        hand:AddHandAttachment(setFound)
        -- Multitool needs to be added twice
        -- Hand needs to be added twice to let some props work (syringe)
        if setFound:GetClassname() == "hlvr_multitool" or setFound:GetClassname() == "hand_use_controller" then
            hand:AddHandAttachment(setFound)
        end
    end

    return setFound
end

---
---Removes weapons from the player inventory.
---
---@param weapons (string|EntityHandle)[] # List of classnames or handles to remove
---@overload fun(self: CBasePlayer, weapon: string|EntityHandle)
function CBasePlayer:RemoveWeapons(weapons)
    if weapons == nil or (type(weapons) == "table" and #weapons == 0) then
        weapons = self:GetWeapon()
    end
    if type(weapons) == "string" or IsEntity(weapons) then
        weapons = {weapons}
    end
    self:UpdateWeapons(weapons, nil)
end

---
---Sets the weapon that the player is holding.
---
---@param weapon string|EntityHandle # Classname or handle to set as active weapon
---@return EntityHandle? # The handle of the newly set weapon if found
function CBasePlayer:SetWeapon(weapon)
    return self:UpdateWeapons(nil, weapon)
end

local weaponClasses = {
    "hlvr_weapon_energygun",
    "hlvr_weapon_rapidfire",
    "hlvr_weapon_shotgun",
    "hlvr_weapon_generic_pistol",
    "hlvr_multitool",
}

---
---Updates the existence of weapons in [Player.Items.weapons](lua://Player.Items.weapons) by checking weapon switch entities.
---
---This is called automatically whenever the weapon_switch event fires.
---
function CBasePlayer:UpdateWeaponsExistence()

    local weapons = Player.Items.weapons

    if weapons.energygun then
        local swt = Entities:FindByName(nil, "wpnswitch_hlvr_weapon_energygun")
        if not swt then
            weapons.energygun = nil
        end
    end

    if weapons.shotgun then
        local swt = Entities:FindByName(nil, "wpnswitch_hlvr_weapon_shotgun")
        if not swt then
            weapons.shotgun = nil
        end
    end

    if weapons.rapidfire then
        local swt = Entities:FindByName(nil, "wpnswitch_hlvr_weapon_rapidfire")
        if not swt then
            weapons.rapidfire = nil
        end
    end

    if weapons.multitool then
        local swt = Entities:FindByName(nil, "wpnswitch_hlvr_multitool")
        if not swt then
            weapons.multitool = nil
        end
    end

    if #weapons.genericpistols > 0 then
        for i = #weapons.genericpistols, 1, -1 do
            local generic = weapons.genericpistols[i]
            -- Server change seems to destroy weapons before this is run
            if IsValidEntity(generic) then
                local swt = Entities:FindByName(nil, "wpnswitch_" .. generic:GetName())
                if not swt then
                    table.remove(weapons.genericpistols, i)
                end
            end
        end
    end
end

---
---Returns [Player.Items.weapons](lua://CBasePlayer.Items) flattened into a single array.
---
---@return EntityHandle[] # List of weapon handles
function CBasePlayer:GetWeapons()

    local weapons = Player.Items.weapons
    local foundWeapons = vlua.clone(weapons.genericpistols)
    table.insert(foundWeapons, weapons.energygun)
    table.insert(foundWeapons, weapons.rapidfire)
    table.insert(foundWeapons, weapons.shotgun)
    table.insert(foundWeapons, weapons.multitool)

    return foundWeapons
end

---
---Gets the invisible player backpack.
---
---This is will return the backpack even if it has been disabled with a `info_hlvr_equip_player`.
---
---@return EntityHandle? # The backpack entity
function CBasePlayer:GetBackpack()
    return Entities:FindByClassname(nil, "player_backpack")
end

---
---Enables or disables player movement, including teleport movement.
---
---@param enabled boolean # `true` if movement should be enabled.
---@param delay? number # Delay before movement state will be changed (default: 0)
function CBasePlayer:SetMovementEnabled(enabled, delay)
    Player:EntFire("EnableTeleport", enabled and "1" or "0", delay or 0)
end

---
---Sets the forward vector of the HMD anchor while keeping the position the same relative to the player.
---
---Normally if the player is off-center from their playspace, changing the forward vector can move the player too.
---
---@param forward Vector # Normalized forward vector
function CBasePlayer:SetAnchorForwardAroundPlayer(forward)
    local oldPos = self:GetAbsOrigin()
    local relativePos = self.HMDAnchor:TransformPointWorldToEntity(oldPos)
    self.HMDAnchor:SetForwardVector(forward)
    local newPos = self.HMDAnchor:TransformPointEntityToWorld(relativePos)
    self.HMDAnchor:SetAbsOrigin(self.HMDAnchor:GetAbsOrigin() + (oldPos - newPos))
end

---
---Sets the angle of the HMD anchor while keeping the position the same relative to the player.
---
---Normally if the player is off-center from their playspace, changing the angle can move the player too.
---
---@param angles QAngle # New angle for the anchor
function CBasePlayer:SetAnchorAnglesAroundPlayer(angles)
    local oldPos = self:GetAbsOrigin()
    local relativePos = self.HMDAnchor:TransformPointWorldToEntity(oldPos)
    self.HMDAnchor:SetQAngle(angles)
    local newPos = self.HMDAnchor:TransformPointEntityToWorld(relativePos)
    self.HMDAnchor:SetAbsOrigin(self.HMDAnchor:GetAbsOrigin() + (oldPos - newPos))
end

---
---Sets the origin of the HMD anchor while keeping the position the same relative to the player.
---
---This essentially moves the player by moving the anchor and can be used in instances where
---setting the player origin does not work.
---
---@param pos Vector # New origin
function CBasePlayer:SetAnchorOriginAroundPlayer(pos)
    self.HMDAnchor:SetAbsOrigin(pos + (self.HMDAnchor:GetAbsOrigin() - self:GetAbsOrigin()))
end

---
---Sets the enabled state of the cough handpose attached to the HMD avatar.
---
---@param enabled boolean # `true` if the cough handpose should be enabled
function CBasePlayer:SetCoughHandEnabled(enabled)
    if not self.HMDAvatar then
        return
    end

    for _, child in ipairs(self.HMDAvatar:GetChildrenMemSafe()) do
        if child:GetModelName() == "models/props/handposes/handpose_cough.vmdl" then
            if enabled then
                child:EntFire("Enable")
            else
                child:EntFire("Disable")
            end
            break
        end
    end
end

-- Other player libraries
require "alyxlib.player.hands"
require "alyxlib.player.events"

return version