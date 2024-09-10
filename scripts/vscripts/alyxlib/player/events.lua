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

---@alias PLAYER_EVENTS_ALL "novr_player"|"player_activate"|"vr_player_ready"|"item_pickup"|"item_released"|"primary_hand_changed"|"player_drop_ammo_in_backpack"|"player_retrieved_backpack_clip"|"player_stored_item_in_itemholder"|"player_removed_item_from_itemholder"|"player_drop_resin_in_backpack"|"weapon_switch"

---Register a callback function with for a player event.
---@param event PLAYER_EVENTS_ALL
---@param callback fun(params)
---@param context? table # Optional: The context to pass to the function as `self`. If omitted the context will not passed to the callback.
---@return integer eventID # ID used to unregister
function ListenToPlayerEvent(event, callback, context)
    devprint("Listening to player event", event, callback)
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

---@alias PLAYER_EVENT_NOVR_PLAYER PLAYER_EVENT_PLAYER_ACTIVATE

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
    data.item = hand.LastItemDropped
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
        warn("Couldn't figure out ammo for "..tostring(ammotype))
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


