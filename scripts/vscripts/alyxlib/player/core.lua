--[[
    v4.1.1
    https://github.com/FrostSource/alyxlib

    Player script allows for more advanced player manipulation and easier
    entity access for player related entities by extending the player class.

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:

    ```lua
    require "alyxlib.player.core"
    ```

    This module returns the version string.

    ======================================== Usage ========================================

    Common method for referencing the player and related entities is:

    ```lua
    local player = Entities:GetLocalPlayer()
    local hmd_avatar = player:GetHMDAvatar()
    local left_hand = hmd_avatar:GetVRHand(0)
    local right_hand = hmd_avatar:GetVRHand(1)
    ```

    This script simplifies the above code significantly by automatically
    caching player entity handles when the player spawns and introducing
    the global variable 'Player' which references the base player entity:

    ```lua
    local player = Player
    local hmd_avatar = Player.HMDAvatar
    local left_hand = Player.LeftHand
    local right_hand = Player.RightHand
    ```

    Since this script extends the player entity class directly you can mix and match your scripting style
    without worrying that you're referencing the wrong player table.

    ```lua
    Entities:GetLocalPlayer() == Player
    ```
    
    ======================================== Player Callbacks ========================================

    Many game events related to the player are used to track player activity and callbacks can be
    registered to hook into them the same way you would a game event:

    ```lua
    RegisterPlayerEventCallback("vr_player_ready", function(params)
        ---@cast params PLAYER_EVENT_VR_PLAYER_READY
        if params.game_loaded then
            -- Load params
        end
    end)
    ```

    Although most of the player events are named after the same game events, the data that is passed to
    the callback is pre-processed and extended to provide better context for the event:

    ```lua
    ---@param params PLAYER_EVENT_ITEM_PICKUP
    RegisterPlayerEventCallback("item_pickup", function(params)
        if params.hand == Player.PrimaryHand and params.item_name == "@gun" then
            params.item:DoNotDrop(true)
        end
    end)
    ```

    ======================================== Tracking Items ========================================

    The script attempts to track player items, both inventory and physically held objects.
    These can be accessed through several new player tables and variables.
    
    Below are a few of the new variables that point an entity handle that the player has interacted with:

    ```lua
    Player.PrimaryHand.WristItem
    Player.PrimaryHand.ItemHeld
    Player.PrimaryHand.LastItemDropped
    ```

    The player might not be holding anything so remember to nil check:

    ```lua
    local item = Player.PrimaryHand.ItemHeld
    if item then
        local primary_held_name = item:GetName()
    end
    ```

    The `Player.Items` table keeps track of the ammo and resin the player has in the backpack.
    One addition value tracked is `resin_found` which is the amount of resin the player has
    collected regardless of removing from backpack or spending on upgrades.

]]
require "alyxlib.utils.common"
require "alyxlib.globals"
require "alyxlib.extensions.entity"
require "alyxlib.storage"

local version = "v4.1.1"

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
---@type CEntityInstance
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

---@alias PLAYER_WEAPON_HAND           "hand"
---@alias PLAYER_WEAPON_ENERGYGUN      "energygun"
---@alias PLAYER_WEAPON_RAPIDFIRE      "rapidfire"
---@alias PLAYER_WEAPON_SHOTGUN        "shotgun"
---@alias PLAYER_WEAPON_MULTITOOL      "multitool"
---@alias PLAYER_WEAPON_GENERIC_PISTOL "generic_pistol"
PLAYER_WEAPON_HAND           = "hand"
PLAYER_WEAPON_ENERGYGUN      = "energygun"
PLAYER_WEAPON_RAPIDFIRE      = "rapidfire"
PLAYER_WEAPON_SHOTGUN        = "shotgun"
PLAYER_WEAPON_MULTITOOL      = "multitool"
PLAYER_WEAPON_GENERIC_PISTOL = "generic_pistol"

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

---**The classname of the weapon/item attached to hand.
---@type string|PLAYER_WEAPON_HAND|PLAYER_WEAPON_ENERGYGUN|PLAYER_WEAPON_RAPIDFIRE|PLAYER_WEAPON_SHOTGUN|PLAYER_WEAPON_MULTITOOL|PLAYER_WEAPON_GENERIC_PISTOL
CBasePlayer.CurrentlyEquipped = PLAYER_WEAPON_HAND
---**The classname of the weapon/item previously attached to hand.
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
        generic_pistol = 0,
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

---Force the player to drop an entity if held.
---@param handle EntityHandle # Handle of the entity to drop
function CBasePlayer:DropByHandle(handle)
    if IsValidEntity(handle) then
        local dmg = CreateDamageInfo(handle, handle, Vector(), Vector(), 0, 2)
        handle:TakeDamage(dmg)
        DestroyDamageInfo(dmg)
    end
end

---Force the player to drop any item held in their left hand.
function CBasePlayer:DropLeftHand()
    self:DropByHandle(self.LeftHand.ItemHeld)
end
Expose(CBasePlayer.DropLeftHand, "DropLeftHand", CBasePlayer)

---Force the player to drop any item held in their right hand.
function CBasePlayer:DropRightHand()
    self:DropByHandle(self.RightHand.ItemHeld)
end
Expose(CBasePlayer.DropRightHand, "DropRightHand", CBasePlayer)

---Force the player to drop any item held in their primary hand.
function CBasePlayer:DropPrimaryHand()
    self:DropByHandle(self.PrimaryHand.ItemHeld)
end
Expose(CBasePlayer.DropPrimaryHand, "DropPrimaryHand", CBasePlayer)

---Force the player to drop any item held in their secondary/off hand.
function CBasePlayer:DropSecondaryHand()
    self:DropByHandle(self.SecondaryHand.ItemHeld)
end
Expose(CBasePlayer.DropSecondaryHand, "DropSecondaryHand", CBasePlayer)

---Force the player to drop the caller entity if held.
---@param data IOParams
function CBasePlayer:DropCaller(data)
    self:DropByHandle(data.caller)
end
Expose(CBasePlayer.DropCaller, "DropCaller", CBasePlayer)

---Force the player to drop the activator entity if held.
---@param data IOParams
function CBasePlayer:DropActivator(data)
    self:DropByHandle(data.activator)
end
Expose(CBasePlayer.DropActivator, "DropActivator", CBasePlayer)

---Force the player to grab `handle` with `hand`.
---@param handle EntityHandle
---@param hand? CPropVRHand|0|1
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

---Force the player to grab the caller entity.
---@param data IOParams
function CBasePlayer:GrabCaller(data)
    self:GrabByHandle(data.caller)
end
Expose(CBasePlayer.GrabCaller, "GrabCaller", CBasePlayer)

---Force the player to grab the activator entity.
---@param data IOParams
function CBasePlayer:GrabActivator(data)
    self:GrabByHandle(data.activator)
end
Expose(CBasePlayer.GrabActivator, "GrabActivator", CBasePlayer)

---@enum PLAYER_MOVETYPE
PLAYER_MOVETYPE = {
    TELEPORT_BLINK = 0,
    TELEPORT_SHIFT = 1,
    CONTINUOUS_HEAD = 2,
    CONTINUOUS_HAND = 3,
}

---Get VR movement type.
---@return PLAYER_MOVETYPE
function CBasePlayer:GetMoveType()
    return Convars:GetInt('hlvr_movetype_default') --[[@as PLAYER_MOVETYPE]]
end

---Returns the entity the player is looking at directly.
---@param maxDistance? number # Max distance the trace can search.
---@return EntityHandle?
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

---Disables fall damage for the player.
---@TODO: Change to entity save.
function CBasePlayer:DisableFallDamage()
    local name = Storage.LoadString(self, "FallDamageFilterName", DoUniqueString("__player_fall_damage_filter"))
    Storage.SaveString(self, "FallDamageFilterName", name)
    local filter = Entities:FindByName(nil, name) or SpawnEntityFromTableSynchronous("filter_damage_type",{
        targetname = name,
        damagetype = "32"
    })
    DoEntFireByInstanceHandle(self, "SetDamageFilter", name, 0, self, self)
end
Expose(CBasePlayer.DisableFallDamage, "DisableFallDamage", CBasePlayer)

---Enables fall damage for the player.
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

---Adds resources to the player.
---@param pistol_ammo? number
---@param rapidfire_ammo? number
---@param shotgun_ammo? number
---@param resin? number
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
        nil,nil,nil,
        self.Items.resin + resin
    )
end

---Sets resources for the player.
---@param pistol_ammo? number
---@param rapidfire_ammo? number
---@param shotgun_ammo? number
---@param resin? number
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
        nil,nil,nil,
        resin or self.Items.resin
    )
end

---Set the items that player has manually.
---This is purely for scripting and does not modify the actual items the player has in game.
---Use `Player:AddResources` to modify in-game items.
---@param energygun_ammo? integer
---@param generic_pistol_ammo? integer
---@param rapidfire_ammo? integer
---@param shotgun_ammo? integer
---@param frag_grenades? integer
---@param xen_grenades? integer
---@param healthpens? integer
---@param resin? integer
function CBasePlayer:SetItems(
    energygun_ammo,
    generic_pistol_ammo,
    rapidfire_ammo,
    shotgun_ammo,
    frag_grenades,
    xen_grenades,
    healthpens,
    resin
)
    self.Items.ammo.energygun = energygun_ammo or self.Items.ammo.energygun
    self.Items.ammo.generic_pistol = generic_pistol_ammo or self.Items.ammo.generic_pistol
    self.Items.ammo.rapidfire = rapidfire_ammo or self.Items.ammo.rapidfire
    self.Items.ammo.shotgun = shotgun_ammo or self.Items.ammo.shotgun
    self.Items.grenades.frag = frag_grenades or self.Items.grenades.frag
    self.Items.grenades.xen = xen_grenades or self.Items.grenades.xen
    self.Items.healthpen = healthpens or self.Items.healthpen
    self.Items.resin = resin or self.Items.resin

    ---@TODO: Consider moving save function above this
    Storage.SaveTable(Player, "PlayerItems", Player.Items)
end


---
---Add pistol ammo to the player.
---
---@param amount number
function CBasePlayer:AddPistolAmmo(amount)
    self:AddResources(amount, nil, nil, nil)
end
---
---Add shotgun ammo to the player.
---
---@param amount number
function CBasePlayer:AddShotgunAmmo(amount)
    self:AddResources(nil, nil, amount, nil)
end
---
---Add rapidfire ammo to the player.
---
---@param amount number
function CBasePlayer:AddRapidfireAmmo(amount)
    self:AddResources(nil, amount, nil, nil)
end
---
---Add resin to the player.
---
---@param amount number
function CBasePlayer:AddResin(amount)
    self:AddResources(nil, nil, nil, amount)
end

---
---Gets the items currently held or in wrist pockets.
---
---@return EntityHandle[]
function CBasePlayer:GetImmediateItems()
    return {
        self.LeftHand.WristItem,
        self.RightHand.WristItem,
        self.LeftHand.ItemHeld,
        self.RightHand.ItemHeld
    }
end

---
---Gets the grenades currently held or in wrist pockets.
---
---Use `#Player:GetGrenades()` to get number of grenades player has access to.
---
---@return EntityHandle[]
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
---Gets the health pens currently held or in wrist pockets.
---
---Use `#Player:GetHealthPens()` to get number of health pens player has access to.
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
---@param hand CPropVRHand|0|1 # The hand handle or index.
---@param prop EntityHandle|string # The prop handle or targetname.
---@param hide_hand boolean # If the hand should turn invisible after merging.
function CBasePlayer:MergePropWithHand(hand, prop, hide_hand)
    if type(hand) == "number" then
        hand = self.Hands[hand+1]
    end
    hand:MergeProp(prop, hide_hand)
end

---
---Return if the player has a gun equipped.
---
---@return boolean
function CBasePlayer:HasWeaponEquipped()
    return self.CurrentlyEquipped == PLAYER_WEAPON_ENERGYGUN
        or self.CurrentlyEquipped == PLAYER_WEAPON_SHOTGUN
        or self.CurrentlyEquipped == PLAYER_WEAPON_RAPIDFIRE
        or self.CurrentlyEquipped == PLAYER_WEAPON_GENERIC_PISTOL
end

---Get the amount of ammo stored in the backpack for the currently equipped weapon.
---@return number # The amount of ammo, or 0 if no weapon equipped.
function CBasePlayer:GetCurrentWeaponReserves()
    return self.Items.ammo[self.CurrentlyEquipped] or 0
end

---Player has item holder equipped.
---@return boolean
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

---Player has grabbity gloves equipped.
---@return boolean
function CBasePlayer:HasGrabbityGloves()
    return self.PrimaryHand:GetGrabbityGlove() ~= nil
end

function CBasePlayer:GetFlashlight()
    return self.SecondaryHand:GetFirstChildWithClassname("hlvr_flashlight_attachment")
end

---Get the first entity the flashlight is pointed at (if the flashlight exists).
---If flashlight does not exist, both returns will be `nil`.
---@param maxDistance number # Max tracing distance, default is 2048.
---@return EntityHandle|nil # The entity that was hit, or nil.
---@return Vector|nil # The position the trace hit, regardless of entity found.
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

---Gets the current resin from the player.
---This is can be more accurate than `Player.Items.resin`
---Calling this will update `Player.Items.resin`
---@return number
function CBasePlayer:GetResin()
    local t = ({}) --[[@as CriteriaTable]]
    self:GatherCriteria(t)
    local r = t.current_crafting_currency
    if Player.Items.resin ~= r then
        Player.Items.resin = r
    end
    return r
end

---Gets if player is holding an entity in either hand.	
---@param entity EntityHandle
---@return boolean	
function CBasePlayer:IsHolding(entity)
    return self.PrimaryHand.ItemHeld == entity or self.SecondaryHand.ItemHeld == entity
end

---Get the entity handle of the currently equipped weapon/item.
---If nothing is equipped this will return the primary hand entity.
---@return EntityHandle|nil
function CBasePlayer:GetWeapon()
    if self.CurrentlyEquipped == PLAYER_WEAPON_ENERGYGUN then
        return Entities:FindByClassnameNearest("hlvr_weapon_energygun", self.PrimaryHand:GetOrigin(), 128)--[[@as EntityHandle]]
    elseif self.CurrentlyEquipped == PLAYER_WEAPON_RAPIDFIRE then
        return Entities:FindByClassnameNearest("hlvr_weapon_rapidfire", self.PrimaryHand:GetOrigin(), 128)--[[@as EntityHandle]]
    elseif self.CurrentlyEquipped == PLAYER_WEAPON_SHOTGUN then
        return Entities:FindByClassnameNearest("hlvr_weapon_shotgun", self.PrimaryHand:GetOrigin(), 128)--[[@as EntityHandle]]
    elseif self.CurrentlyEquipped == PLAYER_WEAPON_GENERIC_PISTOL then
        return Entities:FindByClassnameNearest("hlvr_weapon_generic_pistol", self.PrimaryHand:GetOrigin(), 128)--[[@as EntityHandle]]
    elseif self.CurrentlyEquipped == PLAYER_WEAPON_MULTITOOL then
        return Entities:FindByClassnameNearest("hlvr_multitool", self.PrimaryHand:GetOrigin(), 128)--[[@as EntityHandle]]
    else
        return nil
    end
end

---Get the current upgrades for the player's pistol.
---
---NOTE: This assumes there is only ONE hlvr_weapon_energygun in the map.
---
---@return PlayerPistolUpgrades[]
function CBasePlayer:GetPistolUpgrades()
    local pistol = Entities:FindByClassname(nil, "hlvr_weapon_energygun")

    if not pistol then
        return {}
    end

    local upgrades = {}

    for _, child in ipairs(pistol:GetChildren()) do
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

---Get the current upgrades for the player's rapidfire.
---
---NOTE: This assumes there is only ONE hlvr_weapon_rapidfire in the map.
---
---@return PlayerRapidfireUpgrades[]
function CBasePlayer:GetRapidfireUpgrades()
    local rapidfire = Entities:FindByClassname(nil, "hlvr_weapon_rapidfire")

    if not rapidfire then
        return {}
    end

    local upgrades = {}

    for _, child in ipairs(rapidfire:GetChildren()) do
        if child:GetClassname() == "reflex_sights" then
            table.insert(upgrades, "rapidfire_upgrade_reflex_sight")
        elseif child:GetName() == "rapidfire_laser_sight" then
            table.insert(upgrades, "rapidfire_upgrade_laser_right")
        elseif child:GetName() == "rapidfire_extended_magazine" then
            table.insert(upgrades, "rapidfire_upgrade_extended_magazine")
        end
    end

    return upgrades
end

---Get the current upgrades for the player's shotgun.
---
---**This will NOT return "shotgun_upgrade_quick_fire" because there is no known way to detect this!**
---
---NOTE: This assumes there is only ONE hlvr_weapon_shotgun in the map.
---
---@return PlayerRapidfireUpgrades[]
function CBasePlayer:GetShotgunUpgrades()
    local shotgun = Entities:FindByClassname(nil, "hlvr_weapon_shotgun")

    if not shotgun then
        return {}
    end

    local upgrades = {}

    for _, child in ipairs(shotgun:GetChildren()) do
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

---Get the forward vector of the player in world space coordinates (z is zeroed).
---@return Vector
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
---Update player weapon inventory, both removing and setting.
---
---@param removes? (string|EntityHandle)[] # List of classnames or handles to remove.
---@param set? string|EntityHandle # Classname or handle to set as active weapon.
---@return EntityHandle? # The handle of the newly set weapon if given and found.
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
---Remove weapons from the player inventory.
---
---@param weapons (string|EntityHandle)[] # List of classnames or handles to remove.
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
---Set the weapon that the player is holding.
---
---@param weapon string|EntityHandle # Classname or handle to set as active weapon.
---@return EntityHandle? # The handle of the newly set weapon if found.
function CBasePlayer:SetWeapon(weapon)
    return self:UpdateWeapons(nil, weapon)
end

---
---Get the invisible player backpack.
---This is will return the backpack even if it has been disabled with a `info_hlvr_equip_player`.
---
---@return EntityHandle?
function CBasePlayer:GetBackpack()
    return Entities:FindByClassname(nil, "player_backpack")
end

-- Other player libraries
require "alyxlib.player.hands"
require "alyxlib.player.events"

print("player.lua ".. version .." initialized...")

return version