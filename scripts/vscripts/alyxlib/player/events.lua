--[[
    v2.1.2
    https://github.com/FrostSource/alyxlib

    
]]

local version = "v2.1.2"

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

local playerActivated = false

---@alias PLAYER_EVENTS_ALL "novr_player"|"player_activate"|"vr_player_ready"|"item_pickup"|"item_released"|"primary_hand_changed"|"player_drop_ammo_in_backpack"|"player_retrieved_backpack_clip"|"player_stored_item_in_itemholder"|"player_removed_item_from_itemholder"|"player_drop_resin_in_backpack"|"weapon_switch"

---Register a callback function with for a player event.
---@param event PLAYER_EVENTS_ALL # Name of the event
---@param callback function # The function that will be called when the event is fired
---@param context? table # Optional: The context to pass to the function as `self`. If omitted the context will not passed to the callback.
---@return integer eventID # ID used to unregister
function ListenToPlayerEvent(event, callback, context)
    if playerActivated and (event == "novr_player" or event == "player_activate" or event == "vr_player_ready") then
        warn("Player has already spawned so this event won't fire at "..Debug.GetSourceLine(3))
    end
    devprint2("Listening to player event", event, callback)
    registered_event_callbacks[event][registered_event_index] = { callback = callback, context = context}
    registered_event_index = registered_event_index + 1
    return registered_event_index - 1
end

---Unregisters a callback with a name.
---@param eventID integer
function StopListeningToPlayerEvent(eventID)
    for _, event in pairs(registered_event_callbacks) do
        event[eventID] = nil
    end
end


---@type {entity:EntityHandle, callback:function, context:any}[]
local entityPickupEvents = {}

local entityPickupIndex = 1

---
---Listen to the pickup of a specific entity.
---
---@param entity EntityHandle # The entity to listen for
---@param callback function # The function that will be called when the entity is picked up
---@param context? any # Optional context passed into the callback as the first value
---@return integer # ID used to unregister
function ListenToEntityPickup(entity, callback, context)
    entityPickupEvents[entityPickupIndex] = {
        entity = entity,
        callback = callback,
        context = context
    }
    entityPickupIndex = entityPickupIndex + 1
    return entityPickupIndex - 1
end

---
---Stop listening to an entity pickup
---
---@param eventID integer # ID returned from [ListenToEntityPickup](lua://ListenToEntityPickup)
function StopListeningToEntityPickup(eventID)
    entityPickupEvents[eventID] = nil
end

-----------------
-- Events --
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

---
---Save the Player.Items table
---
local function savePlayerData()
    Storage.SaveTable(Player, "PlayerItems", Player.Items)
    if Player and Player.LeftHand then
        Storage.SaveEntity(Player, "LeftWristItem", Player.LeftHand.WristItem)
    end
    if Player and Player.RightHand then
        Storage.SaveEntity(Player, "RightWristItem", Player.RightHand.WristItem)
    end
end

local function loadPlayerData()
    Player.Items = Storage.LoadTable(Player, "PlayerItems", Player.Items)
end

---Callback logic for every player event.
---@param eventName string # Name of the event, data.game_event_name
---@param newdata table # Data to send to callbacks
local function eventCallback(eventName, newdata)
    for id, event_data in pairs(registered_event_callbacks[eventName]) do
        if event_data.context ~= nil then
            event_data.callback(event_data.context, newdata)
        else
            event_data.callback(newdata)
        end
    end
end

---@class PlayerEventPlayerActivate : GameEventBase
---@field player CBasePlayer # The entity handle of the player.
---@field type "spawn"|"load"|"transition" # Type of player activate.

---@class PlayerEventVRPlayerReady : PlayerEventPlayerActivate
---@field hmd_avatar CPropHMDAvatar # The hmd avatar entity handle.

---@alias PlayerEventNoVRPlayer PlayerEventPlayerActivate

-- Setting up player values.
local listenEventPlayerActivateID
local function listenEventPlayerActivate(data)
    playerActivated = true
    Player = GetListenServerHost()
    loadPlayerData()
    local previous_map = Storage.LoadString(Player, "PlayerPreviousMap", "")
    Storage.SaveString(Player, "PlayerPreviousMap", GetMapName())

    ---@cast data PlayerEventPlayerActivate
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
end
listenEventPlayerActivateID = ListenToGameEvent("player_activate", listenEventPlayerActivate, nil)

---@type EntityHandle
local lastPickedUpEntity = nil
---@type number
local lastPickedUpTime = 0

---Track the last picked up entity to accurately determine the entity in later events.
---@param params GameEventPhysgunPickup
ListenToGameEvent("physgun_pickup", function (params)
    -- print("\nPHYSGUN_PICKUP:")
    -- Debug.PrintTable(params)
    -- print("\n")

    if params.entindex then
        local ent = EntIndexToHScript(params.entindex)
        if IsValidEntity(ent) then
            lastPickedUpEntity = ent
            lastPickedUpTime = Time()
        end
    end
end, nil)

---@class PlayerEventItemPickup : GameEventItemPickup
---@field item EntityHandle # The entity handle of the item that was picked up.
---@field item_class string # Classname of the entity that was picked up.
---@field hand CPropVRHand # The entity handle of the hand that picked up the item.
---@field otherhand CPropVRHand # The entity handle of the opposite hand.

---Tracking player held items.
---@param data GameEventItemPickup
local function listenEventItemPickup(data)
    -- print("\nITEM PICKUP:")
    -- Debug.PrintTable(data)
    -- print("\n")

    if data.vr_tip_attachment == nil then return end
    -- 1=primary,2=secondary converted to 0=left,1=right
    local handId = Util.GetHandIdFromTip(data.vr_tip_attachment)
    local hand = Player.Hands[handId + 1]
    local otherhand = Player.Hands[(1 - handId) + 1]

    ---@type EntityHandle
    local ent_held

    -- These kind of checks probably aren't necessary but just in case
    -- events sometimes fire late or out of order, this ensures
    -- we don't get unexpected errors or wildly inaccurate entities

    -- This will fail with weapon_switch pickups
    if lastPickedUpEntity and lastPickedUpTime == Time() then
        ent_held = lastPickedUpEntity
    else
        -- Hopefully this code is never reached but just in case
        local palmPosition = hand:GetPalmPosition()
        ent_held = Entities:FindBestMatching(data.item_name, data.item, palmPosition)
    end

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
    local newdata = vlua.clone(data)--[[@as PlayerEventItemPickup]]
    newdata.item_class = data.item
    newdata.item = ent_held
    newdata.hand = hand
    newdata.otherhand = otherhand

    eventCallback(data.game_event_name, newdata)

    if #entityPickupEvents > 0 then
        for _, event in pairs(entityPickupEvents) do
            if event.entity == ent_held then
                if event.context ~= nil then
                    event.callback(event.context, newdata)
                else
                    event.callback(newdata)
                end
            end
        end
    end
end
ListenToGameEvent("item_pickup", listenEventItemPickup, nil)

---@class PlayerEventItemReleased : GameEventItemReleased
---@field item EntityHandle # The entity handle of the item that was dropped.
---@field item_class string # Classname of the entity that was dropped.
---@field hand CPropVRHand # The entity handle of the hand that dropped the item.
---@field otherhand CPropVRHand # The entity handle of the opposite hand.

-- ---@type "item_hlvr_crafting_currency_small"|"item_hlvr_crafting_currency_large"|nil
---@type EntityHandle|nil
local last_resin_dropped

---Item released event
---@param data GameEventItemReleased
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
    local newdata = vlua.clone(data)--[[@as PlayerEventItemReleased]]
    newdata.item_class = data.item
    newdata.item = hand.LastItemDropped
    newdata.hand = hand
    newdata.otherhand = otherhand
    eventCallback(data.game_event_name, newdata)
end
ListenToGameEvent("item_released", listenEventItemReleased, nil)

---@class PlayerEventPrimaryHandChanged : GameEventPrimaryHandChanged
---@field is_primary_left boolean

---Tracking handedness.
---@param data GameEventPrimaryHandChanged
local function listenEventPrimaryHandChanged(data)
    local newdata = vlua.clone(data)--[[@as PlayerEventPrimaryHandChanged]]
    newdata.is_primary_left = (data.is_primary_left == 1)

    -- Update quick-access player variables
    if newdata.is_primary_left then
        Player.PrimaryHand = Player.LeftHand
        Player.SecondaryHand = Player.RightHand
    else
        Player.PrimaryHand = Player.RightHand
        Player.SecondaryHand = Player.LeftHand
    end

    Player.IsLeftHanded = Convars:GetBool("hlvr_left_hand_primary") --[[@as boolean]]

    -- Registered callback
    eventCallback(data.game_event_name, newdata)
end
ListenToGameEvent("primary_hand_changed", listenEventPrimaryHandChanged, nil)

-- Inherit from base instead of event to remove 'ammoType'
---@class PlayerEventPlayerDropAmmoInBackpack : GameEventBase
---@field ammotype "Pistol"|"SMG1"|"Buckshot"|"AlyxGun" # Type of ammo that was stored.
---@field ammo_amount 0|1|2|3|4 # Amount of ammo stored for the given type (1 clip, 2 shells).

---Ammo tracking
---@param data GameEventPlayerDropAmmoInBackpack
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
        warn("Couldn't figure out ammo for "..tostring(ammotype))
    end
    savePlayerData()

    -- Registered callback
    local newdata = vlua.clone(data)--[[@as PlayerEventPlayerDropAmmoInBackpack]]
    newdata.ammotype = ammotype
    newdata.ammo_amount = ammo_amount
    eventCallback(data.game_event_name, newdata)
end
ListenToGameEvent("player_drop_ammo_in_backpack", listenEventPlayerDropAmmoInBackpack, nil)

-- Inherit from base instead of event to remove 'ammoType'

---@class PlayerEventPlayerRetrievedBackpackClip : GameEventBase
---@field ammotype "Pistol"|"SMG1"|"Buckshot"|"AlyxGun" # Type of ammo that was retrieved.
---@field ammo_amount integer # Amount of ammo retrieved for the given type (1 clip, 2 shells).

---Ammo tracking
---@param data GameEventPlayerRetrievedBackpackClip
local function listenEventPlayerRetrievedBackpackClip(data)
    -- print("\nRETRIEVE AMMO:")
    -- Debug.PrintTable(data)
    -- print("\n")

    local do_callback = true
    local ammotype = player_weapon_to_ammotype[Player.CurrentlyEquipped]
    local ammo_amount = 0

    local newdata = vlua.clone(data)--[[@as PlayerEventPlayerRetrievedBackpackClip]]
    newdata.ammotype = ammotype

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
        -- Delayed think is used because item_pickup and physgun_pickup are fired after this event
        Player:SetContextThink("delay_shotgun_shellgroup", function()
            -- Player always retrieves a shellgroup even if no autoloader and single shell
            -- checking just in case
            ammo_amount = #Player.LastItemGrabbed:GetChildren()
            if Player.LastClassGrabbed == "item_hlvr_clip_shotgun_shellgroup" then
                Player.Items.ammo.shotgun = Player.Items.ammo.shotgun - ammo_amount
            end

            savePlayerData()

            -- Registered callback
            newdata.ammo_amount = ammo_amount
            eventCallback(data.game_event_name, newdata)

        end, 0)
    elseif Player.CurrentlyEquipped == PLAYER_WEAPON_GENERIC_PISTOL then
        Player.Items.ammo.generic_pistol = Player.Items.ammo.generic_pistol - 1
        ammo_amount = 1
    end

    -- Registered callback
    if do_callback then
        savePlayerData()
        newdata.ammo_amount = ammo_amount
        eventCallback(data.game_event_name, newdata)
    end
end
ListenToGameEvent("player_retrieved_backpack_clip", listenEventPlayerRetrievedBackpackClip, nil)

---@class PlayerEventPlayerStoredItemInItemholder : GameEventPlayerStoredItemInItemholder
---@field item EntityHandle # The entity handle of the item that stored.
---@field item_class string # Classname of the entity that was stored.
---@field hand CPropVRHand  # Hand that the entity was stored in.

---Wrist tracking
---@param data GameEventPlayerStoredItemInItemholder
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
    local newdata = vlua.clone(data)--[[@as PlayerEventPlayerStoredItemInItemholder]]
    newdata.item_class = data.item
    newdata.item = item
    newdata.hand = hand
    eventCallback(data.game_event_name, newdata)
end
ListenToGameEvent("player_stored_item_in_itemholder", listenEventPlayerStoredItemInItemholder, nil)

---@class PlayerEventPlayerRemovedItemFromItemholder : GameEventPlayerRemovedItemFromItemholder
---@field item EntityHandle # The entity handle of the item that removed.
---@field item_class string # Classname of the entity that was removed.
---@field hand CPropVRHand  # Hand that the entity was removed form.

---Tracking wrist items
---@param data GameEventPlayerRemovedItemFromItemholder
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
    local newdata = vlua.clone(data)--[[@as PlayerEventPlayerRemovedItemFromItemholder]]
    newdata.item_class = data.item
    newdata.item = item
    newdata.hand = hand
    eventCallback(data.game_event_name, newdata)
end
ListenToGameEvent("player_removed_item_from_itemholder", listenEventPlayerRemovedItemFromItemholder, nil)

-- No known way to track resin being taken out reliably.

---@class PlayerEventPlayerDropResinInBackpack : GameEventPlayerDropResinInBackpack
---@field resin_ent EntityHandle? # The resin entity being dropped into the backpack.

---Track resin
---@param data GameEventPlayerDropResinInBackpack
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

    -- Registered callback
    local newdata = vlua.clone(data)--[[@as PlayerEventPlayerDropResinInBackpack]]
    newdata.resin_ent = last_resin_dropped
    eventCallback(data.game_event_name, newdata)
end
ListenToGameEvent("player_drop_resin_in_backpack", listenEventPlayerDropResinInBackpack, nil)

---@class PlayerEventWeaponSwitch : GameEventWeaponSwitch

---Track weapon equipped
---@param data GameEventWeaponSwitch
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
    -- Registered callback
    eventCallback(data.game_event_name, data)
end
ListenToGameEvent("weapon_switch", listenEventWeaponSwitch, nil)

return version