--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    The debug menu allows for easier VR testing by offering a customizable in-game menu.

    If not using `alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.debug.debug_menu"
]]

RegisterAlyxLibCommand("debug_menu_show", function (name, ...)
    DebugMenu:ShowMenu()
end, "Forces the debug menu to show")

RegisterAlyxLibConvar("debug_menu_hand", "1", "Hand to attach the debug menu to, 0 = Secondary : 1 = Primary")

RegisterAlyxLibConvar("debug_menu_offset_x", "4", "X offset of the debug menu", 0)
RegisterAlyxLibConvar("debug_menu_offset_y", "-9", "Y offset of the debug menu", 0)
RegisterAlyxLibConvar("debug_menu_offset_z", "0", "Z offset of the debug menu", 0)
RegisterAlyxLibConvar("debug_menu_offset_pitch", "0", "Pitch offset of the debug menu", 0)
RegisterAlyxLibConvar("debug_menu_offset_yaw", "180", "Yaw offset of the debug menu", 0)
RegisterAlyxLibConvar("debug_menu_offset_roll", "0", "Roll offset of the debug menu", 0)

RegisterAlyxLibConvar("debug_menu_height", "14", "Height of the debug menu, min=7 : max=30", 0, function(newVal, oldVal)
    if DebugMenu:IsOpen() then
        DebugMenu:CloseMenu()
        DebugMenu:ShowMenu()
    end
end)

RegisterAlyxLibConvar("debug_menu_floating", function()
    -- Float menu for inside-out tracking
    if Player:GetVRControllerType() == 3 then
        return true
    end

    return false
end, "Menu will float in world instead of attached to hand")

RegisterAlyxLibConvar("debug_menu_lock", "0", "Prevents the debug menu from being repositioned by the player", 0)

RegisterAlyxLibConvar("debug_menu_extras", "0", "Enable the extras tab by default", 0)

---
---The debug menu allows for easier VR testing by offering a customizable in-game menu.
---
---@class DebugMenu
DebugMenu = {}
DebugMenu.version = "v1.0.0"

---
---A category of items in the debug menu.
---
---@class DebugMenuCategory
---@field id string # The unique ID for this category
---@field name string # The display name for this category
---@field items DebugMenuItem[] # The items in this category

---
---An item in the debug menu.
---
---@class DebugMenuItem
---@field categoryId string # The ID of the category this item is in
---@field id string # The unique ID for this item
---@field text string # The text to display for this item (if applicable)
---@field callback function # The function to call when this item is clicked
---@field type "button"|"toggle"|"separator"|"slider"|"cycle" # Type of menu element this item is.
---@field default any|function # The default value sent to the menu. If this is a function the return value will be used
---@field min number # Minimum value of this slider
---@field max number # Maxmimum value of this slider
---@field isPercentage boolean # If true, this slider displays its value as a percentage of min/max
---@field convar string # The console variable associated with this element
---@field values {text:string,value:any}[] # Text/value pairs for this cycler
---@field truncate number # The number of decimal places to truncate the slider value to (-1 for no truncating)
---@field increment number  # The increment value to snap the slider value to (0 for no snapping)
---@field condition? string|fun():boolean # The condition that must be met for this item to be visible

---
---The panel entity.
---
---@type CPointClientUIWorldPanel
DebugMenu.panel = nil

---
---The categories in the debug menu.
---
---@type DebugMenuCategory[]
DebugMenu.categories = {}

local debugMenuOpen = false
local handChangedListener = nil

---The last hand that clicked a button.
---@type CPropVRHand?
local lastClickHand = nil

---Command to test trace button presses
if not IsVREnabled() then
    Convars:RegisterCommand("_debug_menu_test_button_press", function()
        DebugMenu:ClickHoveredButton()
    end, "", FCVAR_HIDDEN)
end

local function empty(str)
    return type(str) ~= "string" or str == ""
end

-- Hoping these two functions find a way to be generalized later

-- Convert position and orientation to entity's local coordinate system
local function TransformToLocal(entity, position, angles)
    local localPos = entity:TransformPointWorldToEntity(position)

    -- Convert angles to local orientation using reference points
    local origin = position
    local forwardPoint = origin + angles:Forward() * 10
    local upPoint = origin + angles:Up() * 10

    local localForward = entity:TransformPointWorldToEntity(forwardPoint)
    local localUp = entity:TransformPointWorldToEntity(upPoint)

    return {
        position = localPos,
        forwardRef = localForward,
        upRef = localUp,
    }
end

-- Convert from entity's local coordinate system back to world coordinates
local function TransformToWorld(entity, localTransform)
    local worldPos = entity:TransformPointEntityToWorld(localTransform.position)

    -- Reconstruct world orientation from reference points
    local worldForwardRef = entity:TransformPointEntityToWorld(localTransform.forwardRef)
    local worldUpRef = entity:TransformPointEntityToWorld(localTransform.upRef)

    local worldForward = (worldForwardRef - worldPos):Normalized()
    local worldUp = (worldUpRef - worldPos):Normalized()

    -- Convert direction vectors back to angles
    local angles = VectorToAngles(worldForward)

    -- Calculate roll from up vector
    local expectedRight = worldForward:Cross(Vector(0, 0, 1)):Normalized()
    if expectedRight:Length() < 0.1 then
        expectedRight = Vector(1, 0, 0)
    end
    local expectedUp = expectedRight:Cross(worldForward):Normalized()

    local roll = math.atan2(worldUp:Dot(expectedRight), worldUp:Dot(expectedUp))
    angles.z = Rad2Deg(roll)

    return worldPos, angles
end

---@param dragHand CPropVRHand
local function startDraggingMenu(dragHand)

    local panel = DebugMenu.panel
    local dragent = dragHand

    local relativeTransform = TransformToLocal(dragHand, panel:GetOrigin(), panel:GetAngles())

    panel:SetParent(GetWorld(), nil)

    Player:QuickThink(function()
        if not IsValidEntity(dragHand) or
           not IsValidEntity(panel) then
            return nil
        end

        if not Player:IsDigitalActionOnForHand(dragHand.Literal, DIGITAL_INPUT_MENU_INTERACT) then
            if Convars:GetBool("debug_menu_floating") then
                return nil
            end

            local hand = Convars:GetBool("debug_menu_hand") and Player.PrimaryHand or Player.SecondaryHand
            panel:SetParent(hand, "constraint1")

            local localOrigin = panel:GetLocalOrigin()
            local localAngles = panel:GetLocalAngles()

            if hand == Player.LeftHand then
                localAngles.y = localAngles.y - 180
                localOrigin.y = -localOrigin.y
            end

            Convars:SetFloat("debug_menu_offset_x", localOrigin.x)
            Convars:SetFloat("debug_menu_offset_y", localOrigin.y)
            Convars:SetFloat("debug_menu_offset_z", localOrigin.z)
            Convars:SetFloat("debug_menu_offset_pitch", localAngles.x)
            Convars:SetFloat("debug_menu_offset_yaw", localAngles.y)
            Convars:SetFloat("debug_menu_offset_roll", localAngles.z)

            Msg("\n")
            Msg("Debug menu offsets updated:\n")
            Msg("\ndebug_menu_offset_x " .. math.trunc(Convars:GetFloat("debug_menu_offset_x"), 2))
            Msg("\ndebug_menu_offset_y " .. math.trunc(Convars:GetFloat("debug_menu_offset_y"), 2))
            Msg("\ndebug_menu_offset_z " .. math.trunc(Convars:GetFloat("debug_menu_offset_z"), 2))
            Msg("\ndebug_menu_offset_pitch " .. math.trunc(Convars:GetFloat("debug_menu_offset_pitch"), 2))
            Msg("\ndebug_menu_offset_yaw " .. math.trunc(Convars:GetFloat("debug_menu_offset_yaw"), 2))
            Msg("\ndebug_menu_offset_roll " .. math.trunc(Convars:GetFloat("debug_menu_offset_roll"), 2))
            Msg("\n\n")

            DebugMenu:UpdateMenuAttachment()

            return nil
        end

        local newOrigin, angles = TransformToWorld(dragHand, relativeTransform)

        panel:SetOrigin(newOrigin)
        panel:SetQAngle(angles)

        return 0
    end)

end

---
---The scope of the debug menu script.
---
---These functions handle Panorama callbacks.
---
local debugPanelScriptScope = {
    _DebugMenuCallbackButton = function(id)
        local item = DebugMenu:GetItem(id)
        if not item then
            warn("Unknown item for panorama callback'"..id.."'")
            return
        end

        if item.type ~= "button" then
            warn("Option '"..id.."' is not a button!")
            return
        end

        if item.callback then
            item.callback(item)
        end
    end,

    _DebugMenuCallbackToggle = function(id, on)
        local item = DebugMenu:GetItem(id)
        if not item then
            warn("Unknown item for panorama callback'"..id.."'")
            return
        end

        if item.type ~= "toggle" then
            warn("Option '"..id.."' is not a toggle!")
            return
        end

        -- Update default if user is tracking manually
        if empty(item.convar) or (item.default ~= nil and type(item.default) ~= "function") then
            item.default = on
        end

        if item.callback then
            item.callback(on, item)
        end
    end,

    _DebugMenuCallbackSlider = function(id, value)
        local item = DebugMenu:GetItem(id)
        if not item then
            warn("Unknown item for panorama callback'"..id.."'")
            return
        end

        if item.type ~= "slider" then
            warn("Option '"..id.."' is not a slider!")
            return
        end

        -- Update default if user is tracking manually
        if item.default ~= nil and type(item.default) ~= "function" then
            item.default = value
        end

        if item.callback then
            item.callback(value, item)
        end
    end,

    _DebugMenuCallbackCycle = function(id, index)
        local item = DebugMenu:GetItem(id)
        if not item then
            return warn("Unknown item for panorama callback'"..id.."'")
        end

        if item.type ~= "cycle" then
            return warn("Option '"..id.."' is not a cycle!")
        end

        local value = item.values[index]

        -- Update default if user is tracking manually
        if item.default ~= nil and type(item.default) ~= "function" then
            item.default = value
        end

        if item.callback then
            item.callback(index, value, item)
        end
    end,

    _CloseMenu = function()
        DebugMenu:CloseMenu()
    end,

    _DebugMenuReloaded = function()
        if DebugMenu:IsOpen() then
            DebugMenu:Refresh()
        end
    end,

    _DebugMenuDrag = function()
        if not Convars:GetBool("debug_menu_lock") and lastClickHand then
            startDraggingMenu(lastClickHand)
        end
    end
}

---Moves the panel with player's anchor parent so it doesn't get left behind on trains.
---Parenting causes stutters so it must be calculated manually.
---@param panel EntityHandle
local function updatePanelWithAnchorParent(panel)
    ---@type EntityHandle?
    local currentAnchorParent = nil
    local anchorRelativeTransform = nil

    panel:SetContextThink("AnchorParentUpdate", function()
        local parent = Player.HMDAnchor:GetMoveParent()
        if parent ~= currentAnchorParent then
            currentAnchorParent = Player.HMDAnchor:GetMoveParent()
            if currentAnchorParent then
                anchorRelativeTransform = TransformToLocal(currentAnchorParent, panel:GetOrigin(), panel:GetAngles())
            end
        end

        if currentAnchorParent and anchorRelativeTransform then
            local newPos, newAng = TransformToWorld(currentAnchorParent, anchorRelativeTransform)
            panel:SetOrigin(newPos)
            panel:SetQAngle(newAng)
            return 0
        end

        return 0.5
    end, 0)
end

---
---Updates the physical menu by attaching it to the correct hand.
---
function DebugMenu:UpdateMenuAttachment()
    if Convars:GetBool("debug_menu_floating") or not Player.HMDAvatar or IsFakeVREnabled() then
        local player = Entities:GetLocalPlayer()
        local eyePos = player:EyePosition()
        local fDir = player:EyeAngles():Forward()
        local fAng = VectorToAngles(fDir)
        fAng = RotateOrientation(fAng, QAngle(0, -90, 90))
        self.panel:SetQAngle(fAng)
        self.panel:SetOrigin(eyePos + fDir * 16)

        -- Panel must be parented for moving during drag to work
        self.panel:SetParent(GetWorld(), nil)

        updatePanelWithAnchorParent(self.panel)
    else
        local hand = Convars:GetBool("debug_menu_hand") and Player.PrimaryHand or Player.SecondaryHand
        if hand == Player.RightHand then
            self.panel:SetParent(hand, "constraint1")
            self.panel:SetLocalAngles(Convars:GetFloat("debug_menu_offset_pitch"), Convars:GetFloat("debug_menu_offset_yaw"), Convars:GetFloat("debug_menu_offset_roll"))
            self.panel:SetLocalOrigin(Vector(Convars:GetFloat("debug_menu_offset_x"), Convars:GetFloat("debug_menu_offset_y"), Convars:GetFloat("debug_menu_offset_z")))
        else
            self.panel:SetParent(hand, "constraint1")
            self.panel:SetLocalAngles(Convars:GetFloat("debug_menu_offset_pitch"), Convars:GetFloat("debug_menu_offset_yaw")-180, Convars:GetFloat("debug_menu_offset_roll"))
            self.panel:SetLocalOrigin(Vector(Convars:GetFloat("debug_menu_offset_x"), -Convars:GetFloat("debug_menu_offset_y"), Convars:GetFloat("debug_menu_offset_z")))
        end
    end
end

---
---Creates and displays the debug menu panel on the player's chosen hand.
---
function DebugMenu:ShowMenu()

    self.panel = SpawnEntityFromTableSynchronous("point_clientui_world_panel", {
        targetname = "alyxlib_debug_menu",
        dialog_layout_name = "file://{resources}/layout/custom_game/alyxlib_debug_menu.xml",
        width = 16,
        height = Convars:GetInt("debug_menu_height"),
        panel_dpi = 64,
        ignore_input = 0,
        lit = 0,
        interact_distance = 64,

        vertical_align = "1",
        -- orientation = "0",
        horizontal_align = "1",

        -- For some reason moving menus slow down css transitions
	    panel_class_name = Convars:GetBool("debug_menu_floating") and "InstantOpen" or ""
    })

    self:UpdateMenuAttachment()

    if not Player.HMDAvatar or IsFakeVREnabled() then
        SendToConsole("bind r _debug_menu_test_button_press")
    else
        local handType = -1
        if not Convars:GetBool("debug_menu_floating") then
            handType = Convars:GetInt("debug_menu_hand") == 1 and InputHandSecondary or InputHandPrimary

            handChangedListener = ListenToPlayerEvent("primary_hand_changed", function()
                self:UpdateMenuAttachment()
            end)
        end

        -- Cough handpose gets in the way for close menus
        Player:SetCoughHandEnabled(false)

        -- Handle distant button presses
        Input:ListenToButton("press",
            handType,
            DIGITAL_INPUT_MENU_INTERACT, 1,
            function (context, params)
                lastClickHand = params.hand
                self:ClickHoveredButton()
            end, self)

    end

    self.panel:AddCSSClasses("Visible")

    local scope = self.panel:GetOrCreatePrivateScriptScope()
    vlua.tableadd(scope, debugPanelScriptScope)

    self.panel:AddOutput("CustomOutput0", "!self", "RunScriptCode")

    Panorama:InitPanel(self.panel, "alyxlib_debug_menu")

    debugMenuOpen = true

    local panelHeight = Clamp(Convars:GetInt("debug_menu_height"), 7, 30)
    local cssHeight = (64 * panelHeight) - 111
    Panorama:Send(self.panel, "SetHeight", cssHeight)

    self:SendCategoriesToPanel()
end

---
---Closes the debug menu panel.
---
function DebugMenu:CloseMenu()
    if self.panel then
        self.panel:Kill()
        self.panel = nil

        debugMenuOpen = false

        if handChangedListener ~= nil then
            StopListeningToPlayerEvent(handChangedListener)
            handChangedListener = nil
        end

        Input:StopListeningByContext(self)

        Player:SetCoughHandEnabled(true)

        if not Player.HMDAvatar or IsFakeVREnabled() then
            SendToConsole("unbind r")
        end
    end
end

---
---Returns whether the debug menu is currently open.
---
---@return boolean # True if the debug menu is open
function DebugMenu:IsOpen()
    return self.panel ~= nil and debugMenuOpen
end

---
---Clicks the active button on the debug menu panel (the one highlighted by the finger).
---
---This is handled automatically in most cases.
---
function DebugMenu:ClickHoveredButton()
    if self.panel then
        Panorama:Send(self.panel, "ClickHoveredButton")
    end
end

---
---Gets a debug menu item by id.
---
---@param id string # The item ID
---@param categoryId? string # Optionally specify a category to look in. If not specified, will look in all categories
---@return DebugMenuItem? # The item if it exists
function DebugMenu:GetItem(id, categoryId)
    for _, category in ipairs(self.categories) do
        if not categoryId or category.id == categoryId then
            for _, item in ipairs(category.items) do
                if item.id == id then
                    return item
                end
            end
        end
    end
end

---
---Gets a debug menu category by id.
---
---@param id string # The category ID
---@return DebugMenuCategory? # The category if it exists
---@return number? # The index of the category in the categories table
function DebugMenu:GetCategory(id)
    for index, category in ipairs(self.categories) do
        if category.id == id then
            return category, index
        end
    end
end

---
---Adds a category to the debug menu.
---
---@param id string # The unique ID for this category
---@param name string # The display name for this category
function DebugMenu:AddCategory(id, name)
    if self:GetCategory(id) then
        warn("Category '"..id.."' already exists!")
        return
    end

    table.insert(self.categories, {
        id = id,
        name = name,
        items = {},
    })
end

---
---Adds a separator line to a category.
---
---@param categoryId string # The category ID to add the separator to
---@param separatorId? string # Optional ID for the separator if you want to modify it later
---@param text? string # Optional title text to display on the separator
function DebugMenu:AddSeparator(categoryId, separatorId, text)
    local category = self:GetCategory(categoryId)
    if not category then
        warn("Cannot add separator: Category '"..categoryId.."' does not exist!")
        return
    end

    table.insert(category.items, {
        categoryId = categoryId,
        type = "separator",
        id = separatorId or DoUniqueString("separator"),
        text = text or ""
    })
end

---
---Adds a button to a category.
---
---@param categoryId string # The category ID to add the button to
---@param buttonId string # The unique ID for this button
---@param text string # The text to display on this button
---@param command string|fun(button:DebugMenuItem) # The console command or function to run when this button is pressed
function DebugMenu:AddButton(categoryId, buttonId, text, command)
    local category = self:GetCategory(categoryId)
    if not category then
        warn("Cannot add button '"..buttonId.."': Category '"..categoryId.."' does not exist!")
        return
    end

    local callback
    if type(command) == "string" then
        callback = function()
            SendToConsole(command)
        end
    elseif type(command) == "function" then
        callback = command
    end

    table.insert(category.items, {
        categoryId = categoryId,
        id = buttonId,
        text = text,
        callback = callback,
        type = "button",
    })
end

---
---Adds a toggle to a category.
---
---@param categoryId string # The category ID to add the toggle to
---@param toggleId string # The unique ID for this toggle
---@param text string # The text to display on this toggle
---@param convar? string # The console variable tied to this toggle
---@param callback? fun(on:boolean,toggle:DebugMenuItem) # Function to run when this toggle is toggled
---@param startsOn? boolean|fun():boolean # Whether the toggle is on by default
function DebugMenu:AddToggle(categoryId, toggleId, text, convar, callback, startsOn)
    local category = self:GetCategory(categoryId)
    if not category then
        warn("Cannot add toggle '"..toggleId.."': Category '"..categoryId.."' does not exist!")
        return
    end

    if callback == nil and not empty(convar) then
        callback = function(on)
            SendToConsole(convar .. " " .. (on and 1 or 0))
        end
    end

    table.insert(category.items, {
        categoryId = categoryId,
        id = toggleId,
        text = text,
        callback = callback,
        type = "toggle",
        default = startsOn,
        convar = convar
    })
end

---
---Adds a center aligned label to a category.
---
---@param categoryId string # The category ID to add the label to
---@param labelId string # The unique ID for this label
---@param text string # The text to display on this label
function DebugMenu:AddLabel(categoryId, labelId, text)
    local category = self:GetCategory(categoryId)
    if not category then
        warn("Cannot add label '"..labelId.."': Category '"..categoryId.."' does not exist!")
        return
    end

    table.insert(category.items, {
        categoryId = categoryId,
        id = labelId,
        text = text,
        type = "label",
    })
end

---
---Adds value slider to a category.
---
---@param categoryId string # The ID of the category to add this slider to
---@param sliderId string # A unique ID for this slider
---@param text string # Display text for the slider
---@param convar string # The console variable to tie this slider to
---@param min number # Minimum allowed value
---@param max number # Maximum allowed value
---@param isPercentage boolean # If true, value will be displayed as a percentage (0-100)
---@param truncate? number # Number of decimal places (0 = integer, -1 = no truncating)
---@param increment? number # Snap increment (0 disables snapping)
---@param callback? fun(value:number,slider:DebugMenuItem) # Callback function
---@param defaultValue? number|fun():number # Starting value. Set nil to use the convar value whenever the menu opens
function DebugMenu:AddSlider(categoryId, sliderId, text, convar, min, max, isPercentage, truncate, increment, callback, defaultValue)
    local category = self:GetCategory(categoryId)
    if not category then
        warn("Cannot add toggle '"..sliderId.."': Category '"..categoryId.."' does not exist!")
        return
    end

    if callback == nil and type(convar) == "string" and convar ~= "" then
        ---@param value number
        ---@param slider DebugMenuItem
        callback = function(value, slider)
            Convars:SetStr(slider.convar, tostring(value))
        end
    end

    table.insert(category.items, {
        categoryId = categoryId,
        id = sliderId,
        text = text,
        callback = callback,
        type = "slider",
        default = defaultValue,
        min = min,
        max = max,
        convar = convar,
        isPercentage = isPercentage or false,
        truncate = truncate or 2,
        increment = increment or 0
    })
end

---
---Adds a value cycler to a category.
---
---Cyclers allow users to choose from a set of values.
---
---@param categoryId string # The id of the category to add this cycle to
---@param cycleId string # The unique id for this new cycle
---@param title string|nil # The text to display next to each value
---@param convar? string # The console variable tied to this cycle
---@param values {text:string,value:any}[]|string[] # List of text/value pairs for this cycle, or a list of values
---@param callback? fun(index:number, item:{text:string,value:any?}, cycle:DebugMenuItem) # Function callback
---@param defaultValue? any|fun():any # Value for this cycle to start with
function DebugMenu:AddCycle(categoryId, cycleId, title, convar, values, callback, defaultValue)
    local category = self:GetCategory(categoryId)
    if not category then
        warn("Cannot add toggle '"..cycleId.."': Category '"..categoryId.."' does not exist!")
        return
    end

    if type(values) ~= "table" or #values == 0 then
        error("Cycle values must be a table with at least 1 value", 2)
    end

    ---@type {text:string,value:any}
    local parsedValues = {}

    if type(values[1]) == "string" then
        for k,v in ipairs(values) do
            table.insert(parsedValues, {text = v, value = k - 1})
        end
    else
        for k,v in ipairs(values) do
            table.insert(parsedValues, {text = v.text, value = v.value or (k - 1)})
        end
    end

    if callback == nil and not empty(convar) then
        ---@param index number
        ---@param item {text:string,value:any?}
        ---@param cycle DebugMenuItem
        callback = function(index, item, cycle)
            Convars:SetStr(cycle.convar, tostring(item.value))
        end
    end

    table.insert(category.items, {
        categoryId = categoryId,
        id = cycleId,
        type = "cycle",
        text = title,
        convar = convar,
        callback = callback,
        values = parsedValues,
        default = defaultValue,
    })
end

---
---Sets the text of an item.
---
---Only works on the following types:
--- - button
--- - toggle
--- - slider
---
---@param categoryId string # The ID of the category that contains the item
---@param itemId string # The ID of the item to modify
---@param text string # The new text
function DebugMenu:SetItemText(categoryId, itemId, text)
    local item = self:GetItem(itemId)
    if not item then
        warn("Cannot set item text '"..itemId.."': Item does not exist!")
        return
    end

    item.text = text

    if self.panel then
        Panorama:Send(self.panel, "SetItemText", categoryId, itemId, text)
    end
end

---
---Sets the index of a category in the debug menu.  
---Categories are ordered by their index, starting from 1.
---
---This is an advanced function and should be used with caution.
---
---@param categoryId string # Id of the category to change
---@param index number # New index for the category
function DebugMenu:SetCategoryIndex(categoryId, index)
    local category, currentIndex = self:GetCategory(categoryId)
    if not category then
        warn("Cannot set category index '"..categoryId.."': Category does not exist!")
        return
    end

    index = math.max(1, math.min(index, #self.categories)) -- Clamp index to valid range

    table.remove(self.categories, currentIndex)
    table.insert(self.categories, index, category)

    if self.panel then
        Panorama:Send(self.panel, "SetCategoryIndex", categoryId, index-1)
    end
end

---Resolves the default value of an element by running any value getter functions.
---@param item DebugMenuItem # The item to resolve
---@param tFunc? `Convars.GetStr`|`Convars.GetInt`|`Convars.GetFloat`|`Convars.GetBool` # The value getter function
---@param default? any # The default value
---@return any # The resolved value
local function resolveDefault(item, tFunc, default)
    if type(item.default) == "function" then
        return item.default()
    end

    if item.default ~= nil then
        return item.default
    end

    if item.convar and item.convar ~= "" then
        tFunc = tFunc or Convars.GetStr
        return tFunc(Convars, item.convar)
    end

    return default
end

---
---Sends a category and all its elements to the panel.
---
---This should only be used if modifying the menu in a non-standard way.
---
---@param category DebugMenuCategory # The category to send
function DebugMenu:SendCategoryToPanel(category)
    if not self.panel then
        return
    end

    local panel = self.panel

    Panorama:Send(panel, "AddCategory", category.id, category.name)

    for _, item in ipairs(category.items) do

        local conditionMet = true
        if item.condition then
            if type(item.condition) == "string" then
                conditionMet = Convars:GetBool(item.condition)
            elseif type(item.condition) == "function" then
                conditionMet = item.condition()
            end
        end

        if conditionMet then
            if item.type == "button" then
                Panorama:Send(panel, "AddButton", item.categoryId, item.id, item.text)

            elseif item.type == "toggle" then
                Panorama:Send(panel, "AddToggle", item.categoryId, item.id, item.text, resolveDefault(item, Convars.GetBool, false))

            elseif item.type == "label" then
                Panorama:Send(panel, "AddLabel", item.categoryId, item.id, item.text)

            elseif item.type == "separator" then
                Panorama:Send(panel, "AddSeparator", item.categoryId, item.id, item.text)

            elseif item.type == "slider" then
                local default = resolveDefault(item, Convars.GetFloat, item.min)
                Panorama:Send(panel, "AddSlider", item.categoryId, item.id, item.text or item.convar, item.convar, item.min, item.max, default, item.isPercentage, item.truncate, item.increment)

            elseif item.type == "cycle" then

                local default = resolveDefault(item)

                if default ~= nil then
                    -- find the index of the default value
                    local index = TableFindKey(item.values, function(v) return tostring(v.value) == tostring(default) end)
                    if index > 0 then
                        default = index
                    else
                        default = nil
                    end
                end

                Panorama:Send(panel, "AddCycle", item.categoryId, item.id, item.convar, item.text, default, TablePluck(item.values, "text"))
            else
                warn("Unknown debug menu item type '"..item.type.."'")
            end
        end
    end
end

---
---Forces the debug menu panel to add all categories and items.
---
---This should only be used if modifying the menu in a non-standard way.
---
function DebugMenu:SendCategoriesToPanel()
    if not self.panel then
        return
    end

    for categoryId, category in pairs(DebugMenu.categories) do
        self:SendCategoryToPanel(category)
    end
end

---
---Clears all categories and items from the debug menu panel.
---
function DebugMenu:ClearMenu()
    if not self.panel then
        return
    end

    Panorama:Send(self.panel, "RemoveAllCategories")
end

---
---Forces the debug menu panel to refresh by removing and re-adding all categories and items.
---
function DebugMenu:Refresh()
    if self:IsOpen() then
        self:ClearMenu()
        self:SendCategoriesToPanel()
    end
end

---
---Sets the visibility condition for an item.
---
---If the condition is not met when the menu opens, the item will not appear in the menu.
---
---@param categoryId string # The category ID
---@param itemId string # The item ID
---@param condition string|fun():boolean|nil # Convar name, function, or `nil` to remove the condition
---@overload fun(self: DebugMenu, item: DebugMenuItem, condition: string|fun():boolean|nil)
function DebugMenu:SetItemVisibilityCondition(categoryId, itemId, condition)
    ---@type DebugMenuItem
    local item
    if type(categoryId) == "table" then
        item = categoryId
        condition = itemId
    else
        item = self:GetItem(itemId, categoryId)
    end

    if not item then
        warn("Cannot set item visibility condition '"..itemId.."': Item does not exist!")
        return
    end

    item.condition = condition
end

---
---Starts listening for the debug menu activation button.
---
function DebugMenu:StartListeningForMenuActivation()
    if Player.HMDAvatar == nil then return end

    local buttonPressesToActivate = 3
    local buttonPresses = 0
    local timeToResetBetweenPresses = 0.6
    local buttonPressed = false
    local timeSinceLastButtonPress = 0

    Player:SetContextThink("debug_menu_activate", function()
        if Time() - timeSinceLastButtonPress > timeToResetBetweenPresses then
            buttonPresses = 0
            timeSinceLastButtonPress = math.huge
        end

        -- Menu button is always on secondary hand (seems to be)
        if Player:IsDigitalActionOnForHand(Player.SecondaryHand.Literal, DIGITAL_INPUT_TOGGLE_MENU) then
            if not buttonPressed then
                buttonPressed = true
                timeSinceLastButtonPress = Time()
                buttonPresses = buttonPresses + 1

                if buttonPresses >= buttonPressesToActivate then
                    buttonPresses = 0
                    if self:IsOpen() then
                        self:CloseMenu()
                    else
                        self:ShowMenu()
                    end
                end
            end
        else
            if buttonPressed then
                buttonPressed = false
            end
        end
        return 0
    end, 0)
end

function DebugMenu:StopListeningForMenuActivation()
    Player:SetContextThink("debug_menu_activate", nil, 0)
end

-- Developer condition has been "disabled"
-- All players can now open the menu
if Convars:GetInt("developer") > -1 then
    ListenToPlayerEvent("vr_player_ready", function()
        -- Kill existing panel on load to avoid missing logic errors
        local panel = Entities:FindByName(nil, "alyxlib_debug_menu")
        if panel then
            panel:Kill()
        end

        Player:Delay(function()
            DebugMenu:StartListeningForMenuActivation()
        end, 0.2)
    end, nil)
end


--[[
    Default AlyxLib tab
]]
---@TODO Move to its own file

local categoryId = "alyxlib"

DebugMenu:AddCategory(categoryId, "AlyxLib")

DebugMenu:AddSeparator(categoryId, nil, "Basic")

if IsVREnabled() then
    DebugMenu:AddToggle(categoryId, "noclip_vr", "NoClip VR", "noclip_vr", nil, function()
        return Convars:GetBool("noclip_vr_enabled")
    end)
    DebugMenu:AddLabel(categoryId, "noclip_vr_label", "Hold movement trigger to boost")
    DebugMenu:AddSlider(categoryId, "noclip_vr_speed", "NoClip VR Speed", "noclip_vr_speed", 0.5, 10, false, 2)
    DebugMenu:AddSlider(categoryId, "noclip_vr_boost_speed", "NoClip VR Boost Speed", "noclip_vr_boost_speed", 0.5, 10, false, 2)
end

DebugMenu:AddToggle(categoryId, "buddha", "Buddha Mode", "buddha")

DebugMenu:AddToggle(categoryId, "lefthanded", "Left Handed", "hlvr_left_hand_primary")

DebugMenu:AddToggle(categoryId, "gameinstructor", "Game Instructor Hints", nil,
function(on)
    Convars:SetBool("gameinstructor_enable", on)
    Convars:SetBool("sv_gameinstructor_disable", not on)
end,
function()
    return Convars:GetBool("gameinstructor_enable") and not Convars:GetBool("sv_gameinstructor_disable")
end)

DebugMenu:AddSeparator(categoryId, nil, "Equipment")

if IsVREnabled() or IsFakeVREnabled() then
    DebugMenu:AddButton(categoryId, "givegrabbity", "Give Grabbity Gloves", "hlvr_give_grabbity_gloves")
end

DebugMenu:AddButton(categoryId, "giveammo", "Give 999 Ammo", function()
    SendToConsole("hlvr_setresources 999 999 999 " .. Player:GetResin())
end)

DebugMenu:AddButton(categoryId, "giveresin", "Give 999 Resin", function()
    SendToConsole("hlvr_addresources 0 0 0 " .. (999 - Player:GetResin()))
end)

DebugMenu:AddSeparator(categoryId, nil, "Session")

local isRecordingDemo = false
local currentDemo = ""

DebugMenu:AddLabel(categoryId, "demo_recording_label", "Last Demo: N/A")

DebugMenu:AddButton(categoryId, "demo_recording", "Start Recording Demo", function()
    if isRecordingDemo then
        SendToConsole("stop")
        currentDemo = ""
        isRecordingDemo = false
        DebugMenu:SetItemText(categoryId, "demo_recording", "Start Recording Demo")
    else
        local localtime = LocalTime()
        -- remove all whitespace and slashes
        local sanitizedMap = GetMapName():gsub("%s+", ""):gsub("/", "_")
        currentDemo = "demo_" .. sanitizedMap .. "_" .. localtime.Hours .. "-" .. localtime.Minutes .. "-" .. localtime.Seconds
        SendToConsole("record " .. currentDemo)
        DebugMenu:SetItemText(categoryId, "demo_recording_label", "Last Demo: " .. currentDemo .. ".dem")
        isRecordingDemo = true
        DebugMenu:SetItemText(categoryId, "demo_recording", "Stop Recording Demo")
    end
end)

if Convars:GetBool("debug_menu_extras") then
    require "alyxlib.debug.debug_menu_extras"
else
    DebugMenu:AddSeparator(categoryId)

    DebugMenu:AddButton(categoryId, "enableextras", "Enable Extras Tab...", function()
        if package.loaded["alyxlib.debug.debug_menu_extras"] == nil then
            require "alyxlib.debug.debug_menu_extras"
            -- Update the panel immediately
            local id = "alyxlib_extras"
            DebugMenu:SendCategoryToPanel(DebugMenu:GetCategory(id))
            DebugMenu:SetCategoryIndex(id, 2)
            ---@TODO Allow disabling extras tab
            DebugMenu:SetItemText(categoryId, "enableextras", "Extras Tab Enabled!")
        end
    end)
end

return DebugMenu.version