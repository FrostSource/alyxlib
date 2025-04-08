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

local listenForMenuActivationThink = function()
    local buttonPressesToActivate = 5
    local buttonPresses = 0
    local timeToResetBetweenPresses = 0.6
    local buttonPressed = false
    local timeSinceLastButtonPress = 0

    Player:SetContextThink("debug_menu_activate", function()
        if Time() - timeSinceLastButtonPress > timeToResetBetweenPresses then
            buttonPresses = 0
            timeSinceLastButtonPress = math.huge
            print("RESET")
        end

        if Player:IsDigitalActionOnForHand(Player.SecondaryHand.Literal, DIGITAL_INPUT_TOGGLE_MENU) then
            if not buttonPressed then
                buttonPressed = true
                timeSinceLastButtonPress = Time()
                buttonPresses = buttonPresses + 1

                print(buttonPresses)
                if buttonPresses >= buttonPressesToActivate then
                    DebugMenu:ShowMenu()
                    buttonPresses = 0
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
            item.startsOn = on
        end
    end,

    _CloseMenu = function()
        DebugMenu:CloseMenu()
    end,
}

---Forces the debug menu panel to add all categories and items.
local function updateDebugMenu()
    if not DebugMenu.panel then
        return
    end

    local panel = DebugMenu.panel

    for categoryId, category in pairs(DebugMenu.categories) do
        Panorama:Send(panel, "AddCategory", category.id, category.name)

        for _, item in ipairs(category.items) do
            if item.type == "toggle" then
                Panorama:Send(panel, "AddToggle", item.categoryId, item.id, item.text, item.default)
            elseif item.type == "button" then
                Panorama:Send(panel, "AddButton", item.categoryId, item.id, item.text)
            elseif item.type == "separator" then
                Panorama:Send(panel, "AddSeparator", item.categoryId)
            else
                warn("Unknown item type '"..item.type.."'")
            end
        end
    end
end

---
---Creates and displays the debug menu panel on the player's chosen hand.
---
function DebugMenu:ShowMenu()

    local menu = SpawnEntityFromTableSynchronous("point_clientui_world_panel", {
        targetname = "spawnmenu",
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
        local hand = Convars:GetInt("alyxlib_debug_menu_hand") == 1 and Player.PrimaryHand or Player.SecondaryHand

        menu:SetParent(hand, "")
        menu:SetLocalAngles(40,-10,10)
        menu:SetLocalOrigin(Vector(0,8,-2))

        -- Cough handpose gets in the way for close menus
        Player:SetCoughHandEnabled(false)

        -- Handle distant button presses
        Input:ListenToButton("press", InputHandPrimary, DIGITAL_INPUT_MENU_INTERACT, 1, function (params)
            self:ClickHoveredButton()
        end, self)

    end

    menu:AddCSSClasses("Visible")

    local scope = menu:GetOrCreatePrivateScriptScope()
    vlua.tableadd(scope, debugPanelScriptScope)

    menu:AddOutput("CustomOutput0", "!self", "RunScriptCode")

    Panorama:InitPanel(menu, "alyxlib_debug_menu")
    self.panel = menu

    updateDebugMenu()

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
---Closes the debug menu panel.
---
function DebugMenu:CloseMenu()
    if self.panel then
        self.panel:Kill()
        self.panel = nil

        Input:StopListeningByContext(self)

        Player:SetCoughHandEnabled(true)

        listenForMenuActivationThink()
    end
end

---Get a debug menu item by id.
---@param id string
---@return DebugMenuItem?
function DebugMenu:GetItem(id)
    for _, category in ipairs(self.categories) do
        for _, item in ipairs(category.items) do
            if item.id == id then
                return item
            end
        end
    end
end

---Get a debug menu category by id.
---@param id string
---@return DebugMenuCategory?
function DebugMenu:GetCategory(id)
    for _, category in ipairs(self.categories) do
        if category.id == id then
            return category
        end
    end
end

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

---Add a separator line to a category.
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

---Add a button to a category.
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

---Add a toggle to a category.
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

ListenToPlayerEvent("player_activate", function()
    Player:Delay(function()
        listenForMenuActivationThink()
    end, 0.2)
end)

-- AlyxLib defaults

DebugMenu:AddCategory("alyxlib", "AlyxLib")

DebugMenu:AddToggle("alyxlib", "alyxlib_noclip_vr", "NoClip VR", "noclip_vr")

DebugMenu:AddToggle("alyxlib", "alyxlib_godmode", "God Mode", "god")