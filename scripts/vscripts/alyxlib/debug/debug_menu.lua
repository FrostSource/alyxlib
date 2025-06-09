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

---@class DebugMenuCategory
---@field id string
---@field name string
---@field items DebugMenuItem[]

---@class DebugMenuItem
---@field categoryId string
---@field id string
---@field text string
---@field callback function
---@field type "button"|"toggle"|"separator"
---@field default any

---The panel entity.
---@type CPointClientUIWorldPanel
DebugMenu.panel = nil

---@type DebugMenuCategory[]
DebugMenu.categories = {}

local debugMenuOpen = false

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

        if item then
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

        if item then
            item.callback(on)
            -- Hack for keeping state after close
            item.default = on
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
---Creates and displays the debug menu panel on the player's chosen hand.
---
function DebugMenu:ShowMenu()

    local menu = SpawnEntityFromTableSynchronous("point_clientui_world_panel", {
        targetname = "alyxlib_debug_menu",
        dialog_layout_name = "file://{resources}/layout/custom_game/alyxlib_debug_menu.xml",
        width = 16,--24,
        height = 12,--16
        panel_dpi = 64,
        ignore_input = 0,
        lit = 0,
        interact_distance = 8,

        vertical_align = "1",
        -- orientation = "0",
        horizontal_align = "1",
    })

    if not Player.HMDAvatar then
        local localPlayer = Entities:GetLocalPlayer()
        local eyePos = localPlayer:EyePosition()
        local dir = localPlayer:EyeAngles():Forward()
        local a = VectorToAngles(dir)
        a = RotateOrientation(a, QAngle(0,-90,90))
        menu:SetQAngle(a)
        menu:SetOrigin(eyePos + dir * 16)
    else
        if Convars:GetInt("alyxlib_debug_menu_hand") == 1 then
            menu:SetParent(Player.PrimaryHand, "constraint1")
            menu:ResetLocal()
            menu:SetLocalAngles(0, 180, 0)
            menu:SetLocalOrigin(Vector(4, -9, 0))
            -- menu:SetLocalAngles(0,0,0)
            -- menu:SetLocalAngles(40,-10,10)
            -- menu:SetLocalOrigin(Vector(0,8,-2))
        else
            menu:SetParent(Player.SecondaryHand, "constraint1")
            menu:ResetLocal()
            menu:SetLocalAngles(0, 0, 0)
            menu:SetLocalOrigin(Vector(4, 9, 0))
            -- menu:SetLocalAngles(40,-10,10)
            -- menu:SetLocalOrigin(Vector(0,8,-2))
        end

        -- Cough handpose gets in the way for close menus
        Player:SetCoughHandEnabled(false)

        -- Handle distant button presses
        Input:ListenToButton("press",
            Convars:GetInt("alyxlib_debug_menu_hand") == 1 and InputHandSecondary or InputHandPrimary,
            DIGITAL_INPUT_MENU_INTERACT, 1,
            function (params)
                self:ClickHoveredButton()
            end, self)

    end

    menu:AddCSSClasses("Visible")

    local scope = menu:GetOrCreatePrivateScriptScope()
    vlua.tableadd(scope, debugPanelScriptScope)

    menu:AddOutput("CustomOutput0", "!self", "RunScriptCode")

    Panorama:InitPanel(menu, "alyxlib_debug_menu")
    self.panel = menu

    menu:Delay(function()
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

        Input:StopListeningByContext(self)

        Player:SetCoughHandEnabled(true)

        self:StartListeningForMenuActivation()
    end
end

---
---Returns whether the debug menu is currently open.
---
---@return boolean
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
function DebugMenu:AddSeparator(categoryId)
    local category = self:GetCategory(categoryId)
    if not category then
        warn("Cannot add separator: Category '"..categoryId.."' does not exist!")
        return
    end

    table.insert(category.items, {
        categoryId = categoryId,
        type = "separator",
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
---@param startsOn? boolean # Whether the toggle is on by default
function DebugMenu:AddToggle(categoryId, toggleId, text, command, startsOn)
    local category = self:GetCategory(categoryId)
    if not category then
        warn("Cannot add toggle '"..toggleId.."': Category '"..categoryId.."' does not exist!")
        return
    end

    local callback
    if type(command) == "string" then
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
---Set the text of an item.
---
---@param categoryId string # The category ID
---@param itemId any # The item ID
---@param text any # The new text
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
---@param categoryId any
---@param index any
function DebugMenu:SetCategoryIndex(categoryId, index)
    local category, currentIndex = self:GetCategory(categoryId)
    if not category then
        warn("Cannot set category index '"..categoryId.."': Category does not exist!")
        return
    end

    index = math.max(1, math.min(index, #self.categories)) -- Clamp index to valid range

    table.remove(self.categories, currentIndex)
    table.insert(self.categories, index, category)
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

    local panel = self.panel

    for categoryId, category in pairs(DebugMenu.categories) do
        Panorama:Send(panel, "AddCategory", category.id, category.name)

        for _, item in ipairs(category.items) do
            if item.type == "toggle" then
                Panorama:Send(panel, "AddToggle", item.categoryId, item.id, item.text, item.default)
            elseif item.type == "button" then
                Panorama:Send(panel, "AddButton", item.categoryId, item.id, item.text)
            elseif item.type == "label" then
                Panorama:Send(panel, "AddLabel", item.categoryId, item.id, item.text)
            elseif item.type == "separator" then
                Panorama:Send(panel, "AddSeparator", item.categoryId)
            else
                warn("Unknown item type '"..item.type.."'")
            end
        end
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
    local buttonPressesToActivate = 5
    local buttonPresses = 0
    local timeToResetBetweenPresses = 0.6
    local buttonPressed = false
    local timeSinceLastButtonPress = 0

    Player:SetContextThink("debug_menu_activate", function()
        if Time() - timeSinceLastButtonPress > timeToResetBetweenPresses then
            buttonPresses = 0
            timeSinceLastButtonPress = math.huge
        end

        if Player:IsDigitalActionOnForHand(Player.SecondaryHand.Literal, DIGITAL_INPUT_TOGGLE_MENU) then
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

ListenToPlayerEvent("vr_player_ready", function()
    Player:Delay(function()
        DebugMenu:StartListeningForMenuActivation()
    end, 0.2)
end)

-- AlyxLib defaults

DebugMenu:AddCategory("alyxlib", "AlyxLib")

DebugMenu:AddToggle("alyxlib", "alyxlib_noclip_vr", "NoClip VR", "noclip_vr")

DebugMenu:AddToggle("alyxlib", "alyxlib_godmode", "God Mode", "god")

local isRecordingDemo = false
local currentDemo = ""

DebugMenu:AddButton("alyxlib", "alyxlib_demo_recording", "Start Recording Demo", function()
    if isRecordingDemo then
        SendToConsole("stop")
        currentDemo = ""
        isRecordingDemo = false
        DebugMenu:SetItemText("alyxlib", "alyxlib_demo_recording", "Start Recording Demo")
    else
        local localtime = LocalTime()
        -- remove all whitespace and slashes
        local sanitizedMap = GetMapName():gsub("%s+", ""):gsub("/", "_")
        currentDemo = "demo_" .. sanitizedMap .. "_" .. localtime.Hours .. "-" .. localtime.Minutes .. "-" .. localtime.Seconds
        SendToConsole("record " .. currentDemo)
        isRecordingDemo = true
        DebugMenu:SetItemText("alyxlib", "alyxlib_demo_recording", "Stop Recording Demo")
    end
end)