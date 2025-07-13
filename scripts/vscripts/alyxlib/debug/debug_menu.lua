--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    The debug menu allows for easier VR testing by offering a customizable in-game menu.
]]

RegisterAlyxLibCommand("alyxlib_debug_menu_show", function (name, ...)
    DebugMenu:ShowMenu()
end, "Forces the debug menu to show")

RegisterAlyxLibConvar("alyxlib_debug_menu_hand", "1", "Hand to attach the debug menu to, 0 = Secondary : 1 = Primary")

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
---@field id string # The unique ID for this category.
---@field name string # The display name for this category.
---@field items DebugMenuItem[] # The items in this category.

---
---An item in the debug menu.
---
---@class DebugMenuItem
---@field categoryId string # The ID of the category this item is in.
---@field id string # The unique ID for this item.
---@field text string # The text to display for this item (if applicable).
---@field callback function # The function to call when this item is clicked.
---@field type "button"|"toggle"|"separator"|"slider"|"cycle" # Type of menu element this item is.
---@field default any|function # The default value sent to the menu. If this is a function the return value will be used.
---@field min number # Minimum value of this slider.
---@field max number # Maxmimum value of this slider.
---@field isPercentage boolean # If true, this slider displays its value as a percentage of min/max.
---@field convar string # The console variable associated with this element. 
---@field values {text:string,value:any}[] # Text/value pairs for this cycler.
---@field truncate number # The number of decimal places to truncate the slider value to (-1 for no truncating).
---@field increment number  # The increment value to snap the slider value to (0 for no snapping).

---The panel entity.
---@type CPointClientUIWorldPanel
DebugMenu.panel = nil

---@type DebugMenuCategory[]
DebugMenu.categories = {}

local debugMenuOpen = false
local handChangedListener = nil

---Command to test trace button presses
if not IsVREnabled() then
    Convars:RegisterCommand("_debug_menu_test_button_press", function()
        DebugMenu:ClickHoveredButton()
    end, "", FCVAR_HIDDEN)
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
            item.callback()
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
        if item.default ~= nil and type(item.default) ~= "function" then
            item.default = on
        end

        if item.callback then
            item.callback(on)
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
    end
}

---
---Updates the physical menu by attaching it to the correct hand.
---
function DebugMenu:UpdateMenuAttachment()
    local hand = Convars:GetBool("alyxlib_debug_menu_hand") and Player.PrimaryHand or Player.SecondaryHand
    if hand == Player.RightHand then
        self.panel:SetParent(hand, "constraint1")
        self.panel:ResetLocal()
        self.panel:SetLocalAngles(0, 180, 0)
        self.panel:SetLocalOrigin(Vector(4, -9, 0))
    else
        self.panel:SetParent(hand, "constraint1")
        self.panel:ResetLocal()
        self.panel:SetLocalAngles(0, 0, 0)
        self.panel:SetLocalOrigin(Vector(4, 9, 0))
    end
end

---
---Creates and displays the debug menu panel on the player's chosen hand.
---
function DebugMenu:ShowMenu()

    self.panel = SpawnEntityFromTableSynchronous("point_clientui_world_panel", {
        targetname = "alyxlib_debug_menu",
        dialog_layout_name = "file://{resources}/layout/custom_game/alyxlib_debug_menu.xml",
        width = 16,--24,
        height = 12,--16
        panel_dpi = 64,
        ignore_input = 0,
        lit = 0,
        interact_distance = 12,

        vertical_align = "1",
        -- orientation = "0",
        horizontal_align = "1",
    })

    if not Player.HMDAvatar or IsFakeVREnabled() then
        local localPlayer = Entities:GetLocalPlayer()
        local eyePos = localPlayer:EyePosition()
        local dir = localPlayer:EyeAngles():Forward()
        local a = VectorToAngles(dir)
        a = RotateOrientation(a, QAngle(0,-90,90))
        self.panel:SetQAngle(a)
        self.panel:SetOrigin(eyePos + dir * 16)

        SendToConsole("bind r _debug_menu_test_button_press")
    else
        self:UpdateMenuAttachment()

        -- Cough handpose gets in the way for close menus
        Player:SetCoughHandEnabled(false)

        -- Handle distant button presses
        Input:ListenToButton("press",
            Convars:GetInt("alyxlib_debug_menu_hand") == 1 and InputHandSecondary or InputHandPrimary,
            DIGITAL_INPUT_MENU_INTERACT, 1,
            function (params)
                self:ClickHoveredButton()
            end, self)

        handChangedListener = ListenToPlayerEvent("primary_hand_changed", function()
            self:UpdateMenuAttachment()
        end)

    end

    self.panel:AddCSSClasses("Visible")

    local scope = self.panel:GetOrCreatePrivateScriptScope()
    vlua.tableadd(scope, debugPanelScriptScope)

    self.panel:AddOutput("CustomOutput0", "!self", "RunScriptCode")

    Panorama:InitPanel(self.panel, "alyxlib_debug_menu")

    self.panel:Delay(function()
        debugMenuOpen = true
    end, 0.2)

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

        if Player.HMDAvatar then
            self:StartListeningForMenuActivation()
        else
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
---Get a debug menu item by id.
---
---@param id string # The item ID
---@return DebugMenuItem? # The item if it exists
function DebugMenu:GetItem(id)
    for _, category in ipairs(self.categories) do
        for _, item in ipairs(category.items) do
            if item.id == id then
                return item
            end
        end
    end
end

---
---Get a debug menu category by id.
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
---Add a category to the debug menu.
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
---Add a separator line to a category.
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
---Add a button to a category.
---
---@param categoryId string # The category ID to add the button to
---@param buttonId string # The unique ID for this button
---@param text string # The text to display on this button
---@param command string|function # The console command or function to run when this button is pressed
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
---Add a toggle to a category.
---
---@param categoryId string # The category ID to add the toggle to
---@param toggleId string # The unique ID for this toggle
---@param text string # The text to display on this toggle
---@param command string|function # The console command or function to run when this toggle is toggled (will run with 1 if it's on, 0 if it's off)
---@param startsOn? boolean|fun():boolean # Whether the toggle is on by default
function DebugMenu:AddToggle(categoryId, toggleId, text, command, startsOn)
    local category = self:GetCategory(categoryId)
    if not category then
        warn("Cannot add toggle '"..toggleId.."': Category '"..categoryId.."' does not exist!")
        return
    end

    local callback
    if type(command) == "string" then
        startsOn = startsOn or Convars:GetBool(command) or false
        callback = function(on)
            SendToConsole(command .. " " .. (on and 1 or 0))
        end
    elseif type(command) == "function" then
        callback = command
    end

    table.insert(category.items, {
        categoryId = categoryId,
        id = toggleId,
        text = text,
        callback = callback,
        type = "toggle",
        default = startsOn or false,
    })
end

---
---Add a center aligned label to a category.
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
---Add value slider to a category.
---
---@param categoryId string # The ID of the category to add this slider to
---@param sliderId string # A unique ID for this slider
---@param text string # Display text for the slider
---@param min number # Minimum allowed value
---@param max number # Maximum allowed value
---@param isPercentage boolean # If true, value will be displayed as a percentage (0-100)
---@param command string|fun(value:number,slider:DebugMenuItem) # Convar name or callback function
---@param truncate? number # Number of decimal places (0 = integer, -1 = no truncating)
---@param increment? number # Snap increment (0 disables snapping)
---@param defaultValue? number|fun():number # Starting value. Set nil to use the convar value whenever the menu opens
function DebugMenu:AddSlider(categoryId, sliderId, text, min, max, isPercentage, command, truncate, increment, defaultValue)
    local category = self:GetCategory(categoryId)
    if not category then
        warn("Cannot add toggle '"..sliderId.."': Category '"..categoryId.."' does not exist!")
        return
    end

    local callback
    local convar = ""
    if type(command) == "string" then
        if command == "" then
            error("Command must not be a blank string", 2)
        end
        convar = command

        ---@param value number
        ---@param slider DebugMenuItem
        callback = function(value, slider)
            Convars:SetStr(slider.convar, tostring(value))
        end
    elseif type(command) == "function" then
        callback = command
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
        truncate = truncate or -1,
        increment = increment or 0
    })
end

---
---Add a value cycler to a category.
---
---Cyclers allow users to choose from a set of values.
---
---@param categoryId string # The id of the category to add this cycle to
---@param cycleId string # The unique id for this new cycle
---@param values {text:string,value:any}[] # List of text/value pairs for this cycle
---@param command string|fun(index:number, item:{text:string,value:any?}, cycle:DebugMenuItem) # Convar name or function callback
---@param defaultValue? any|fun():any # Value for this cycle to start with
function DebugMenu:AddCycle(categoryId, cycleId, values, command, defaultValue)
    local category = self:GetCategory(categoryId)
    if not category then
        warn("Cannot add toggle '"..cycleId.."': Category '"..categoryId.."' does not exist!")
        return
    end

    if type(values) ~= "table" or #values == 0 then
        error("Cycle values must be a table with at least 1 value", 2)
    end

    for k,v in ipairs(values) do
        v.value = tostring(v.value or (k - 1))
    end

    local callback
    local convar = ""
    if type(command) == "string" then
        if command == "" then
            error("Command must not be a blank string", 2)
        end
        convar = command

        ---@param index number
        ---@param item {text:string,value:any?}
        ---@param cycle DebugMenuItem
        callback = function(index, item, cycle)
            Convars:SetStr(cycle.convar, tostring(item.value))
        end
    elseif type(command) == "function" then
        callback = command
    end

    table.insert(category.items, {
        categoryId = categoryId,
        id = cycleId,
        callback = callback,
        type = "cycle",
        values = values,
        default = defaultValue,
        convar = convar
    })
end

---
---Set the text of an item.
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
---@param categoryId string # Id of the category to change.
---@param index number # New index for the category.
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
---@param default any|fun():any # The default value to resolve
---@return any # The resolved value
local function resolveDefault(default)
    if type(default) == "function" then
        return default()
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
        if item.type == "toggle" then
            Panorama:Send(panel, "AddToggle", item.categoryId, item.id, item.text, resolveDefault(item.default))

        elseif item.type == "button" then
            Panorama:Send(panel, "AddButton", item.categoryId, item.id, item.text)

        elseif item.type == "label" then
            Panorama:Send(panel, "AddLabel", item.categoryId, item.id, item.text)

        elseif item.type == "separator" then
            Panorama:Send(panel, "AddSeparator", item.categoryId, item.id, item.text)

        elseif item.type == "slider" then
            local default = resolveDefault(item.default)
            if default == nil then
                default = Convars:GetFloat(item.convar) or item.min
            end
            Panorama:Send(panel, "AddSlider", item.categoryId, item.id, item.text, item.convar, item.min, item.max, default, item.isPercentage, item.truncate, item.increment)

        elseif item.type == "cycle" then
            -- Flatten values into an array of text
            local values = {}
            local index = 1
            for i = 1, #item.values do
                values[index] = item.values[i].text
                values[index+1] = item.values[i].value or (i - 1)
                index = index + 2
            end

            local default = resolveDefault(item.default)
            -- Use convar value if default isn't set
            if default == nil and item.convar ~= "" then
                default = Convars:GetStr(item.convar)
            end

            Panorama:Send(panel, "AddCycle", item.categoryId, item.id, item.convar, default, values)
        else
            warn("Unknown item type '"..item.type.."'")
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
    if self.panel then
        self:ClearMenu()
        self:SendCategoriesToPanel()
    end
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

        local hand = Convars:GetBool("alyxlib_debug_menu_hand") and Player.SecondaryHand or Player.PrimaryHand

        if Player:IsDigitalActionOnForHand(hand.Literal, DIGITAL_INPUT_TOGGLE_MENU) then
            if not buttonPressed then
                buttonPressed = true
                timeSinceLastButtonPress = Time()
                buttonPresses = buttonPresses + 1

                if buttonPresses >= buttonPressesToActivate then
                    self:ShowMenu()
                    buttonPresses = 0
                    -- Stop think
                    return nil
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

if Convars:GetInt("developer") > 0 then
    local listenFunc = ListenToPlayerEvent or ListenToGameEvent
    listenFunc("vr_player_ready", function()
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

DebugMenu:AddToggle(categoryId, "noclip_vr", "NoClip VR", "noclip_vr", function ()
    return Convars:GetBool("noclip_vr_enabled")
end)
DebugMenu:AddLabel(categoryId, "noclip_vr_label", "Hold movement trigger to boost")
DebugMenu:AddSlider(categoryId, "noclip_vr_speed", "NoClip VR Speed", 0.5, 10, false, "noclip_vr_speed", 2)
DebugMenu:AddSlider(categoryId, "noclip_vr_boost_speed", "NoClip VR Boost Speed", 0.5, 10, false, "noclip_vr_boost_speed", 2)

DebugMenu:AddToggle(categoryId, "buddha", "Buddha Mode", "buddha")

DebugMenu:AddToggle(categoryId, "lefthanded", "Left Handed", "hlvr_left_hand_primary")

DebugMenu:AddToggle(categoryId, "gameinstructor", "Game Instructor Hints",
function(on)
    Convars:SetBool("gameinstructor_enable", on)
    Convars:SetBool("sv_gameinstructor_disable", not on)
end,
function()
    return Convars:GetBool("gameinstructor_enable") and not Convars:GetBool("sv_gameinstructor_disable")
end)

DebugMenu:AddSeparator(categoryId, nil, "Equipment")

DebugMenu:AddButton(categoryId, "giveammo", "Give 999 Ammo", function()
    SendToConsole("hlvr_setresources 999 999 999 " .. Player:GetResin())
end)

DebugMenu:AddButton(categoryId, "giveresin", "Give 999 Resin", function()
    SendToConsole("hlvr_addresources 0 0 0 " .. (999 - Player:GetResin()))
end)

DebugMenu:AddSeparator(categoryId, nil, "Session")

local isRecordingDemo = false
local currentDemo = ""

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
        isRecordingDemo = true
        DebugMenu:SetItemText(categoryId, "demo_recording", "Stop Recording Demo")
    end
end)

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

return DebugMenu.version