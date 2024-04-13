--[[
    v4.1.1
    https://github.com/FrostSource/alyxlib

    Player script allows for more advanced player manipulation and easier
    entity access for player related entities by extending the player class.

    If not using `vscripts/alyxlib/core.lua`, load this file at game start using the following line:

    ```lua
    require "alyxlib.player"
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
    RegisterPlayerEventCallback("vr_player_ready", function(data)
        ---@cast data PLAYER_EVENT_VR_PLAYER_READY
        if data.game_loaded then
            -- Load data
        end
    end)
    ```

    Although most of the player events are named after the same game events, the data that is passed to
    the callback is pre-processed and extended to provide better context for the event:

    ```lua
    ---@param data PLAYER_EVENT_ITEM_PICKUP
    RegisterPlayerEventCallback("item_pickup", function(data)
        if data.hand == Player.PrimaryHand and data.item_name == "@gun" then
            data.item:DoNotDrop(true)
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
require "alyxlib.util.common"
require "alyxlib.util.globals"
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
    -- print('getting gun')
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
        if setFound:GetClassname() == "hlvr_multitool" then
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

---@class __PlayerRegisteredEventData
---@field callback function
---@field context any

local registered_event_index = 1
---@type table<string,__PlayerRegisteredEventData[]>
local registered_event_callbacks = {
    novr_player = {},
    player_activate = {},
    vr_player_ready = {},
    item_pickup = {},
    item_released = {},
    primary_hand_changed = {},
    player_drop_ammo_in_backpack = {},
    player_retrieved_backpack_clip = {},
    player_stored_item_in_itemholder = {},
    player_removed_item_from_itemholder = {},
    player_drop_resin_in_backpack = {},
    weapon_switch = {},
}

---Register a callback function with for a player event.
---@param event "novr_player"|"player_activate"|"vr_player_ready"|"item_pickup"|"item_released"|"primary_hand_changed"|"player_drop_ammo_in_backpack"|"player_retrieved_backpack_clip"|"player_stored_item_in_itemholder"|"player_removed_item_from_itemholder"|"player_drop_resin_in_backpack"|"weapon_switch"
---@param callback fun(params)
---@param context? table # Optional: The context to pass to the function as `self`. If omitted the context will not passed to the callback.
---@return integer eventID # ID used to unregister
function RegisterPlayerEventCallback(event, callback, context)
    devprint("Registering player callback", event, callback)
    registered_event_callbacks[event][registered_event_index] = { callback = callback, context = context}
    registered_event_index = registered_event_index + 1
    return registered_event_index - 1
end

---Unregisters a callback with a name.
---@param eventID integer
function UnregisterPlayerEventCallback(eventID)
    for _, event in pairs(registered_event_callbacks) do
        event[eventID] = nil
    end
end


---Merge an existing prop with this hand.
---@param prop EntityHandle|string # The prop handle or targetname.
---@param hide_hand boolean # If the hand should turn invisible after merging.
function CPropVRHand:MergeProp(prop, hide_hand)
    if type(prop) == "string" then
        prop = Entities:FindByName(nil, prop)
    end
    if IsValidEntity(prop) then
        local glove = self:GetGlove()
        if not glove then
            Warning("Trying to merge prop with glove but glove was not found!\n")
            return
        end
        -- don't use FollowEntity
        prop:SetParent(glove, "!bonemerge")
        if hide_hand then glove:SetRenderAlpha(0) end
    else
        Warning("Could not find prop '"..tostring(prop).."' to merge with hand.\n")
    end
end

---Return true if this hand is currently holding a prop.
---@return boolean
function CPropVRHand:IsHoldingItem()
    return IsEntity(self.ItemHeld, true)
end

---Drop the item held by this hand.
---@return EntityHandle?
function CPropVRHand:Drop()
    if self.ItemHeld ~= nil then
        Player:DropByHandle(self.ItemHeld)
        ---@TODO: Make sure this doesn't return nil
        return self.ItemHeld
    end
end

---Get the rendered glove entity for this hand, i.e. the first `hlvr_prop_renderable_glove` class.
---@return EntityHandle|nil
function CPropVRHand:GetGlove()
    return self.GetFirstChildWithClassname(self, "hlvr_prop_renderable_glove")
end

---Get the entity for this hands grabbity glove (the animated part on the glove).
---@return EntityHandle|nil
function CPropVRHand:GetGrabbityGlove()
    return self:GetFirstChildWithClassname("prop_grabbity_gloves")
end

---Returns true if the digital action is on for this. See `ENUM_DIGITAL_INPUT_ACTIONS` for action index values.
---Note: Only reports input when headset is awake. Will still transmit input when controller loses tracking.
---@param digitalAction ENUM_DIGITAL_INPUT_ACTIONS
---@return boolean
function CPropVRHand:IsButtonPressed(digitalAction)
    return Player:IsDigitalActionOnForHand(self.Literal, digitalAction)
end

---Forces the player to drop this entity if held.
---@param self CBaseEntity
function CBaseEntity:Drop()
    Player:DropByHandle(self)
end
Expose(CBaseEntity.Drop, "Drop", CBaseEntity)

---Force the player to grab this entity with a hand.
---If no hand is supplied then the nearest hand will be used.
---@param hand? CPropVRHand|0|1
function CBaseEntity:Grab(hand)
    Player:GrabByHandle(self, hand)
end
Expose(CBaseEntity.Grab, "Grab", CBaseEntity)


-----------------
-- Local logic --
-----------------

local shellgroup_cache = 0

local player_weapon_to_ammotype =
{
    [PLAYER_WEAPON_HAND] = "Pistol",
    [PLAYER_WEAPON_MULTITOOL] = "Pistol",
    [PLAYER_WEAPON_ENERGYGUN] = "Pistol",
    [PLAYER_WEAPON_RAPIDFIRE] = "SMG1",
    [PLAYER_WEAPON_SHOTGUN] = "Buckshot",
    [PLAYER_WEAPON_GENERIC_PISTOL] = "AlyxGun",
}

local function savePlayerData()
    Storage.SaveTable(Player, "PlayerItems", Player.Items)
    Storage.SaveEntity(Player, "LeftWristItem", Player.LeftHand.WristItem)
    Storage.SaveEntity(Player, "RightWristItem", Player.RightHand.WristItem)
end

local function loadPlayerData()
    Player.Items = Storage.LoadTable(Player, "PlayerItems", Player.Items)
end

---@class PLAYER_EVENT_PLAYER_ACTIVATE : GAME_EVENT_BASE
---@field player CBasePlayer # The entity handle of the player.
---@field type "spawn"|"load"|"transition" # Type of player activate.
---@class PLAYER_EVENT_VR_PLAYER_READY : PLAYER_EVENT_PLAYER_ACTIVATE
---@field hmd_avatar CPropHMDAvatar # The hmd avatar entity handle.

-- Setting up player values.
local listenEventPlayerActivateID
local function listenEventPlayerActivate(data)
    local base_data = vlua.clone(data)
    Player = GetListenServerHost()
    loadPlayerData()
    local previous_map = Storage.LoadString(Player, "PlayerPreviousMap", "")
    Storage.SaveString(Player, "PlayerPreviousMap", GetMapName())

    ---@cast data PLAYER_EVENT_PLAYER_ACTIVATE
    data.player = Player
    -- Determine type of player activate
    if previous_map == "" then
        data.type = "spawn"
    elseif previous_map ~= GetMapName() then
        data.type = "transition"
    else
        data.type = "load"
    end

    Player:SetContextThink("global_player_setup_delay", function()
        Player.HMDAvatar = Player:GetHMDAvatar() --[[@as CPropHMDAvatar]]
        if Player.HMDAvatar then
            Player.Hands[1] = Player.HMDAvatar:GetVRHand(0)
            Player.Hands[2] = Player.HMDAvatar:GetVRHand(1)
            Player.Hands[1].Literal = Player.Hands[1]:GetLiteralHandType()
            Player.Hands[2].Literal = Player.Hands[2]:GetLiteralHandType()
            Player.Hands[1]:SetEntityName("player_hand_left")
            Player.Hands[2]:SetEntityName("player_hand_right")
            Player.LeftHand = Player.Hands[1]
            Player.RightHand = Player.Hands[2]
            Player.LeftHand.Opposite = Player.RightHand
            Player.RightHand.Opposite = Player.LeftHand
            Player.IsLeftHanded = Convars:GetBool("hlvr_left_hand_primary") --[[@as boolean]]
            if Player.IsLeftHanded then
                Player.PrimaryHand = Player.LeftHand
                Player.SecondaryHand = Player.RightHand
            else
                Player.PrimaryHand = Player.RightHand
                Player.SecondaryHand = Player.LeftHand
            end
            Player.HMDAnchor = Player:GetHMDAnchor() --[[@as CEntityInstance]]
            -- Have to load these seperately
            Player.LeftHand.WristItem = Storage.LoadEntity(Player, "LeftWristItem")
            Player.RightHand.WristItem = Storage.LoadEntity(Player, "RightWristItem")

            -- Get resin only if it couldn't be loaded from player context
            if Player.Items.resin == nil or Player.Items.resin_found == nil then
                -- For some reason resin isn't in criteria until 0.6 seconds
                Player:SetContextThink("__resin_update", function()
                    Player:GetResin()
                    Player.Items.resin_found = Player.Items.resin
                end, 0.5)
            end

            -- Registered callback
            data.hmd_avatar = Player.HMDAvatar
            for id, event_data in pairs(registered_event_callbacks["vr_player_ready"]) do
                if event_data.context ~= nil then
                    event_data.callback(event_data.context, data)
                else
                    event_data.callback(data)
                end
            end
        -- Callback for novr player if HMD not found
        else
            for id, event_data in pairs(registered_event_callbacks["novr_player"]) do
                if event_data.context ~= nil then
                    event_data.callback(event_data.context, data)
                else
                    event_data.callback(data)
                end
            end
        end
    end, 0)

    -- Registered callback
    for id, event_data in pairs(registered_event_callbacks[data.game_event_name]) do
        if event_data.context ~= nil then
            event_data.callback(event_data.context, data)
        else
            event_data.callback(data)
        end
    end
    StopListeningToGameEvent(listenEventPlayerActivateID)
    FireGameEvent("player_activate", base_data)
end
listenEventPlayerActivateID = ListenToGameEvent("player_activate", listenEventPlayerActivate, nil)

---@class PLAYER_EVENT_ITEM_PICKUP : GAME_EVENT_ITEM_PICKUP
---@field item EntityHandle # The entity handle of the item that was picked up.
---@field item_class string # Classname of the entity that was picked up.
---@field hand CPropVRHand # The entity handle of the hand that picked up the item.
---@field otherhand CPropVRHand # The entity handle of the opposite hand.

---Tracking player held items.
---@param data GAME_EVENT_ITEM_PICKUP
local function listenEventItemPickup(data)
    -- print("\nITEM PICKUP:")
    -- Debug.PrintTable(data)
    -- print("\n")
    if data.vr_tip_attachment == nil then return end
    -- 1=primary,2=secondary converted to 0=left,1=right
    local handId = Util.GetHandIdFromTip(data.vr_tip_attachment)
    local hand = Player.Hands[handId + 1]
    local otherhand = Player.Hands[(1 - handId) + 1]
    local palmPosition = hand:GetGlove():GetAttachmentOrigin(hand:GetGlove():ScriptLookupAttachment("vr_palm"))
    local ent_held = Util.EstimateNearestEntity(data.item_name, data.item, palmPosition)

    hand.ItemHeld = ent_held
    hand.LastItemGrabbed = ent_held
    hand.LastClassGrabbed = data.item
    Player.LastItemGrabbed = ent_held
    Player.LastClassGrabbed = data.item

    if data.item == "item_hlvr_crafting_currency_small" or data.item == "item_hlvr_crafting_currency_large" then
        local resin = Player.Items.resin
        local resin_removed = resin - Player:GetResin()
        -- Determine if player has actually removed resin from backpack
        if resin_removed > 0 then
            -- Give the resin a flag so it's not counted towards found resin if stored again
            ent_held:SetContextNum("resin_taken_from_backpack", 1, 0)
        end
    end

    -- Registered callback
    ---@cast data PLAYER_EVENT_ITEM_PICKUP
    data.item_class = data.item--[[@as string]]
    ---@diagnostic disable-next-line: assign-type-mismatch
    data.item = ent_held
    data.hand = hand
    data.otherhand = otherhand
    for id, event_data in pairs(registered_event_callbacks[data.game_event_name]) do
        if event_data.context ~= nil then
            event_data.callback(event_data.context, data)
        else
            event_data.callback(data)
        end
    end
end
ListenToGameEvent("item_pickup", listenEventItemPickup, nil)

---@class PLAYER_EVENT_ITEM_RELEASED : GAME_EVENT_ITEM_RELEASED
---@field item EntityHandle # The entity handle of the item that was dropped.
---@field item_class string # Classname of the entity that was dropped.
---@field hand CPropVRHand # The entity handle of the hand that dropped the item.
---@field otherhand CPropVRHand # The entity handle of the opposite hand.

-- ---@type "item_hlvr_crafting_currency_small"|"item_hlvr_crafting_currency_large"|nil
---@type EntityHandle|nil
local last_resin_dropped

---Item released event
---@param data GAME_EVENT_ITEM_RELEASED
local function listenEventItemReleased(data)
    -- print("\nITEM RELEASED:")
    -- Debug.PrintTable(data)
    -- print("\n")
    if data.vr_tip_attachment == nil then return end
    -- 1=primary,2=secondary converted to 0=left,1=right
    local handId = Util.GetHandIdFromTip(data.vr_tip_attachment)
    local hand = Player.Hands[handId + 1]
    local otherhand = Player.Hands[(1 - handId) + 1]
    -- Hack to get the number of shells dropped
    if data.item == "item_hlvr_clip_shotgun_shellgroup" then
        shellgroup_cache = #hand.ItemHeld:GetChildren()
    elseif data.item == "item_hlvr_crafting_currency_small" or data.item == "item_hlvr_crafting_currency_large" then
        last_resin_dropped = hand.ItemHeld
    end
    Player.LastItemDropped = hand.ItemHeld
    Player.LastClassDropped = data.item
    hand.LastItemDropped = hand.ItemHeld
    hand.LastClassDropped = data.item
    hand.ItemHeld = nil

    -- Registered callback
    ---@cast data PLAYER_EVENT_ITEM_RELEASED
    data.item_class = data.item--[[@as string]]
    ---@diagnostic disable-next-line: assign-type-mismatch
    data.item = Player.LastItemDropped
    data.hand = hand
    data.otherhand = otherhand
    for id, event_data in pairs(registered_event_callbacks[data.game_event_name]) do
        if event_data.context ~= nil then
            event_data.callback(event_data.context, data)
        else
            event_data.callback(data)
        end
    end
end
ListenToGameEvent("item_released", listenEventItemReleased, nil)

---@class PLAYER_EVENT_PRIMARY_HAND_CHANGED : GAME_EVENT_PRIMARY_HAND_CHANGED
---@field is_primary_left boolean

---Tracking handedness.
---@param data GAME_EVENT_PRIMARY_HAND_CHANGED
local function listenEventPrimaryHandChanged(data)
    ---@cast data PLAYER_EVENT_PRIMARY_HAND_CHANGED
    data.is_primary_left = (data.is_primary_left == 1) and true or false

    if data.is_primary_left then
        Player.PrimaryHand = Player.LeftHand
        Player.SecondaryHand = Player.RightHand
    else
        Player.PrimaryHand = Player.RightHand
        Player.SecondaryHand = Player.LeftHand
    end
    Player.IsLeftHanded = Convars:GetBool("hlvr_left_hand_primary") --[[@as boolean]]
    -- Registered callback
    for id, event_data in pairs(registered_event_callbacks[data.game_event_name]) do
        if event_data.context ~= nil then
            event_data.callback(event_data.context, data)
        else
            event_data.callback(data)
        end
    end
end
ListenToGameEvent("primary_hand_changed", listenEventPrimaryHandChanged, nil)

-- Inherit from base instead of event to remove 'ammoType'
---@class PLAYER_EVENT_PLAYER_DROP_AMMO_IN_BACKPACK : GAME_EVENT_BASE
---@field ammotype "Pistol"|"SMG1"|"Buckshot"|"AlyxGun" # Type of ammo that was stored.
---@field ammo_amount 0|1|2|3|4 # Amount of ammo stored for the given type (1 clip, 2 shells).

---Ammo tracking
---@param data GAME_EVENT_PLAYER_DROP_AMMO_IN_BACKPACK
local function listenEventPlayerDropAmmoInBackpack(data)
    -- print("\nSTORE AMMO:")
    -- Debug.PrintTable(data)
    -- print("\n")

    --Pistol (energygun)
    --SMG1 (rapidfire)
    --Buckshot (shotgun)
    --AlyxGun (generic pistol)

    -- Sometimes for some reason the key is `ammoType` (capital T), seems to happen when shotgun shell is taken from backpack and put back.
    local ammotype = data.ammotype or data.ammoType
    local ammo_amount = 0
    -- Energygun
    if ammotype == "Pistol" then
        if Player.LastClassDropped == "item_hlvr_clip_energygun_multiple" then
            Player.Items.ammo.energygun = Player.Items.ammo.energygun + 4
            ammo_amount = 4
            -- print("Player stored 4 energygun clips")
        else
            Player.Items.ammo.energygun = Player.Items.ammo.energygun + 1
            ammo_amount = 1
            -- print("Player stored 1 energygun clip")
        end
    -- Rapidfire
    elseif ammotype == "SMG1" then
        Player.Items.ammo.rapidfire = Player.Items.ammo.rapidfire + 1
        ammo_amount = 1
        -- print("Player stored 1 rapidfire clip")
    -- Shotgun
    elseif ammotype == "Buckshot" then
        if Player.LastClassDropped == "item_hlvr_clip_shotgun_multiple" then
            Player.Items.ammo.shotgun = Player.Items.ammo.shotgun + 4
            ammo_amount = 4
            -- print("Player stored 4 shotgun shells")
        elseif Player.LastClassDropped == "item_hlvr_clip_shotgun_shellgroup" then
            -- this can be 2 or 3.. how to figure out??
            Player.Items.ammo.shotgun = Player.Items.ammo.shotgun + shellgroup_cache--2--3
            ammo_amount = shellgroup_cache
            -- print("Player stored "..shellgroup_cache .." shotgun shells")
        else
            Player.Items.ammo.shotgun = Player.Items.ammo.shotgun + 1
            ammo_amount = 1
            -- print("Player stored 1 shotgun shell")
        end
    -- Generic pistol
    elseif ammotype == "AlyxGun" then
        if Player.LastClassDropped == "item_hlvr_clip_generic_pistol_multiple" then
            Player.Items.ammo.generic_pistol = Player.Items.ammo.generic_pistol + 4
            ammo_amount = 4
            -- print("Player stored 4 generic pistol clips")
        else
            Player.Items.ammo.generic_pistol = Player.Items.ammo.generic_pistol + 1
            ammo_amount = 1
            -- print("Player stored 1 generic pistol clip")
        end
    else
        print("Couldn't figure out ammo for "..tostring(ammotype))
    end
    savePlayerData()

    -- Registered callback
    ---@diagnostic disable-next-line: cast-type-mismatch
    ---@cast data PLAYER_EVENT_PLAYER_DROP_AMMO_IN_BACKPACK
    data.ammotype = ammotype
    data.ammo_amount = ammo_amount
    for id, event_data in pairs(registered_event_callbacks[data.game_event_name]) do
        if event_data.context ~= nil then
            event_data.callback(event_data.context, data)
        else
            event_data.callback(data)
        end
    end
end
ListenToGameEvent("player_drop_ammo_in_backpack", listenEventPlayerDropAmmoInBackpack, nil)

-- Inherit from base instead of event to remove 'ammoType'

---@class PLAYER_EVENT_PLAYER_RETRIEVED_BACKPACK_CLIP : GAME_EVENT_BASE
---@field ammotype "Pistol"|"SMG1"|"Buckshot"|"AlyxGun" # Type of ammo that was retrieved.
---@field ammo_amount integer # Amount of ammo retrieved for the given type (1 clip, 2 shells).

---Ammo tracking
---@param data GAME_EVENT_PLAYER_RETRIEVED_BACKPACK_CLIP
local function listenEventPlayerRetrievedBackpackClip(data)
    -- print("\nRETRIEVE AMMO:")
    -- Debug.PrintTable(data)
    -- print("\n")

    local do_callback = true
    local ammotype = player_weapon_to_ammotype[Player.CurrentlyEquipped]
    local ammo_amount = 0
    if Player.CurrentlyEquipped == PLAYER_WEAPON_ENERGYGUN
    or Player.CurrentlyEquipped == PLAYER_WEAPON_HAND
    or Player.CurrentlyEquipped == PLAYER_WEAPON_MULTITOOL then
        Player.Items.ammo.energygun = Player.Items.ammo.energygun - 1
        ammo_amount = 1
    elseif Player.CurrentlyEquipped == PLAYER_WEAPON_RAPIDFIRE then
        Player.Items.ammo.rapidfire = Player.Items.ammo.rapidfire - 1
        ammo_amount = 1
    elseif Player.CurrentlyEquipped == PLAYER_WEAPON_SHOTGUN then
        do_callback = false
        -- Delayed think is used because item_pickup is fired after this event
        Player:SetContextThink("delay_shotgun_shellgroup", function()
            -- Player always retrieves a shellgroup even if no autoloader and single shell
            -- checking just in case
            ammo_amount = #Player.LastItemGrabbed:GetChildren()
            if Player.LastClassGrabbed == "item_hlvr_clip_shotgun_shellgroup" then
                Player.Items.ammo.shotgun = Player.Items.ammo.shotgun - ammo_amount
            end
            -- Registered callback
            ---@diagnostic disable-next-line: cast-type-mismatch
            ---@cast data PLAYER_EVENT_PLAYER_RETRIEVED_BACKPACK_CLIP
            data.ammotype = ammotype
            data.ammo_amount = ammo_amount
            for id, event_data in pairs(registered_event_callbacks[data.game_event_name]) do
                if event_data.context ~= nil then
                    event_data.callback(event_data.context, data)
                else
                    event_data.callback(data)
                end
            end
        end, 0)
    elseif Player.CurrentlyEquipped == PLAYER_WEAPON_GENERIC_PISTOL then
        Player.Items.ammo.generic_pistol = Player.Items.ammo.generic_pistol - 1
        ammo_amount = 1
    end
    savePlayerData()
    -- Registered callback
    if do_callback then
        ---@diagnostic disable-next-line: cast-type-mismatch
        ---@cast data PLAYER_EVENT_PLAYER_RETRIEVED_BACKPACK_CLIP
        data.ammotype = ammotype
        data.ammo_amount = ammo_amount
        for id, event_data in pairs(registered_event_callbacks[data.game_event_name]) do
            if event_data.context ~= nil then
                event_data.callback(event_data.context, data)
            else
                event_data.callback(data)
            end
        end
    end
end
ListenToGameEvent("player_retrieved_backpack_clip", listenEventPlayerRetrievedBackpackClip, nil)

---@class PLAYER_EVENT_PLAYER_STORED_ITEM_IN_ITEMHOLDER : GAME_EVENT_PLAYER_STORED_ITEM_IN_ITEMHOLDER
---@field item EntityHandle # The entity handle of the item that stored.
---@field item_class string # Classname of the entity that was stored.
---@field hand CPropVRHand  # Hand that the entity was stored in.

---Wrist tracking
---@param data GAME_EVENT_PLAYER_STORED_ITEM_IN_ITEMHOLDER
local function listenEventPlayerStoredItemInItemholder(data)
    -- print("\nSTORE WRIST:")
    -- Debug.PrintTable(data)
    -- print("\n")

    ---@TODO: Test the accuracy of this.
    local item = Player.LastItemDropped
    local hand
    -- Can infer wrist stored by checking which hand dropped
    if Player.LeftHand.LastItemDropped == item then
        Player.RightHand.WristItem = item
        hand = Player.RightHand
    else
        Player.LeftHand.WristItem = item
        hand = Player.LeftHand
    end

    -- if data.item == "item_hlvr_grenade_frag" then
    --     Player.Items.grenades.frag = Player.Items.grenades.frag + 1
    -- elseif data.item == "item_hlvr_grenade_xen" then
    --     Player.Items.grenades.xen = Player.Items.grenades.xen + 1
    -- elseif data.item == "item_healthvial" then
    --     Player.Items.healthpen = Player.Items.healthpen + 1
    -- end
    savePlayerData()

    -- Registered callback
    ---@cast data PLAYER_EVENT_PLAYER_STORED_ITEM_IN_ITEMHOLDER
    data.item_class = data.item--[[@as string]]
    ---@diagnostic disable-next-line: assign-type-mismatch
    data.item = item
    data.hand = hand
    for id, event_data in pairs(registered_event_callbacks[data.game_event_name]) do
        if event_data.context ~= nil then
            event_data.callback(event_data.context, data)
        else
            event_data.callback(data)
        end
    end
end
ListenToGameEvent("player_stored_item_in_itemholder", listenEventPlayerStoredItemInItemholder, nil)

---@class PLAYER_EVENT_PLAYER_REMOVED_ITEM_FROM_ITEMHOLDER : GAME_EVENT_PLAYER_REMOVED_ITEM_FROM_ITEMHOLDER
---@field item EntityHandle # The entity handle of the item that removed.
---@field item_class string # Classname of the entity that was removed.
---@field hand CPropVRHand  # Hand that the entity was removed form.

---Tracking wrist items
---@param data GAME_EVENT_PLAYER_REMOVED_ITEM_FROM_ITEMHOLDER
local function listenEventPlayerRemovedItemFromItemholder(data)
    -- print("\nREMOVE FROM WRIST:")
    -- Debug.PrintTable(data)
    -- print("\n")

    local left = Player.LeftHand
    local right = Player.RightHand
    local item, hand

    if left.ItemHeld == right.WristItem then
        item = right.WristItem
        hand = right
        right.WristItem = nil
    elseif right.ItemHeld == left.WristItem then
        item = left.WristItem
        hand = left
        left.WristItem = nil
    else
        -- Shouldn't get here, means other functions aren't accurate
        Warning("Wrist item being taken out couldn't be resolved!")
    end

    -- if data.item == "item_hlvr_grenade_frag" then
    --     Player.Items.grenades.frag = Player.Items.grenades.frag - 1
    -- elseif data.item == "item_hlvr_grenade_xen" then
    --     Player.Items.grenades.xen = Player.Items.grenades.xen - 1
    -- elseif data.item == "item_healthvial" then
    --     Player.Items.healthpen = Player.Items.healthpen - 1
    -- end
    savePlayerData()

    -- Registered callback
    ---@cast data PLAYER_EVENT_PLAYER_REMOVED_ITEM_FROM_ITEMHOLDER
    data.item_class = data.item--[[@as string]]
    ---@diagnostic disable-next-line: assign-type-mismatch
    data.item = item
    data.hand = hand
    for id, event_data in pairs(registered_event_callbacks[data.game_event_name]) do
        if event_data.context ~= nil then
            event_data.callback(event_data.context, data)
        else
            event_data.callback(data)
        end
    end
end
ListenToGameEvent("player_removed_item_from_itemholder", listenEventPlayerRemovedItemFromItemholder, nil)

-- No known way to track resin being taken out reliably.

---@class PLAYER_EVENT_PLAYER_DROP_RESIN_IN_BACKPACK : GAME_EVENT_PLAYER_DROP_RESIN_IN_BACKPACK
---@field resin_ent EntityHandle? # The resin entity being dropped into the backpack.

---Track resin
---@param data GAME_EVENT_PLAYER_DROP_RESIN_IN_BACKPACK
local function listenEventPlayerDropResinInBackpack(data)
    -- print("\nSTORE RESIN:")
    -- Debug.PrintTable(data)
    -- print("\n")

    local resin = Player.Items.resin
                        -- this updates
    local resin_added = Player:GetResin() - resin
    -- This makes sure only newly found resin is counted
    if last_resin_dropped
    and IsEntity(last_resin_dropped, true)
    and not last_resin_dropped:GetContext("resin_taken_from_backpack")
    then
        Player.Items.resin_found = Player.Items.resin_found + resin_added
    end
    last_resin_dropped = nil

    ---@cast data PLAYER_EVENT_PLAYER_DROP_RESIN_IN_BACKPACK
    data.resin_ent = last_resin_dropped

    for id, event_data in pairs(registered_event_callbacks[data.game_event_name]) do
        if event_data.context ~= nil then
            event_data.callback(event_data.context, data)
        else
            event_data.callback(data)
        end
    end
end
ListenToGameEvent("player_drop_resin_in_backpack", listenEventPlayerDropResinInBackpack, nil)

---@class PLAYER_EVENT_WEAPON_SWITCH : GAME_EVENT_WEAPON_SWITCH

---Track weapon equipped
---@param data GAME_EVENT_WEAPON_SWITCH
local function listenEventWeaponSwitch(data)
    -- print("\nWEAPON SWITCH:")
    -- Debug.PrintTable(data)
    -- print("\n")

    Player.PreviouslyEquipped = Player.CurrentlyEquipped
    if data.item == "hand_use_controller" then Player.CurrentlyEquipped = PLAYER_WEAPON_HAND
    elseif data.item == "hlvr_weapon_energygun" then Player.CurrentlyEquipped = PLAYER_WEAPON_ENERGYGUN
    elseif data.item == "hlvr_weapon_rapidfire" then Player.CurrentlyEquipped = PLAYER_WEAPON_RAPIDFIRE
    elseif data.item == "hlvr_weapon_shotgun" then Player.CurrentlyEquipped = PLAYER_WEAPON_SHOTGUN
    elseif data.item == "hlvr_multitool" then Player.CurrentlyEquipped = PLAYER_WEAPON_MULTITOOL
    elseif data.item == "hlvr_weapon_generic_pistol" then Player.CurrentlyEquipped = PLAYER_WEAPON_GENERIC_PISTOL
    end

    -- Registered callback
    for id, event_data in pairs(registered_event_callbacks[data.game_event_name]) do
        if event_data.context ~= nil then
            event_data.callback(event_data.context, data)
        else
            event_data.callback(data)
        end
    end
end
ListenToGameEvent("weapon_switch", listenEventWeaponSwitch, nil)


print("player.lua ".. version .." initialized...")

return version