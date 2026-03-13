--[[
    v1.1.1
    https://github.com/FrostSource/alyxlib

    Panorama core library.

    If not using `alyxlib/init.lua`, load this file at game start using the following line:
    
    require "alyxlib.panorama.core"
]]

Panorama = {}
Panorama.version = "v1.1.1"

---Filters text string to replace problematic characters.
---@param text string
---@return string
local function FilterText(text)
    text = text:gsub("'", "U+00027")
    text = text:gsub("\n", "U+000A")
    return text
end

---
---Initializes a panorama panel with a unique id.  
---This must be done every time the entity loads, even on save game loads.
---
---The entity can be initialized if it accepts the input "AddCSSClass".
---
---@param panelEntity EntityHandle # The entity to initialize
---@param customId? string # The custom id to use, otherwise a unique id will be generated
function Panorama:InitPanel(panelEntity, customId)
    local id = customId

    if not id or id == "" then
        if panelEntity:GetName() ~= "" then
            id = DoUniqueString(panelEntity:GetName() .. "_panoid")
        else
            id = DoUniqueString(panelEntity:GetClassname() .. "_panoid")
        end
    end

    panelEntity.__panoid = id
    DoEntFireByInstanceHandle(panelEntity, "AddCSSClass", id, 0, nil, nil)
end

---Flattens a nested ordered table into a single list.
---@param tbl table # The table to flatten
---@param out? table # Optional table to flatten into
---@return table # The flattened table or `out`
local function flattenOrderedTable(tbl, out)
    out = out or {}
    for _, value in ipairs(tbl) do
        if type(value) == "table" then
            flattenOrderedTable(value, out)
        else
            table.insert(out, value)
        end
    end
    return out
end

---
---Sends data to a panorama panel.
---
---@param panelEntity EntityHandle # The entity to send data to
---@param ... any # The data to send - each value will be converted to a string
function Panorama:Send(panelEntity, ...)
    ---@diagnostic disable-next-line: undefined-field
    local id = panelEntity.__panoid
    if not id then
        warn(Debug.EntStr(panelEntity), "has not been initialized with a panorama id!")
        return
    end

    local dataString = id .. "|"
    local n = select("#", ...)

    local flattenedData = {}

    -- Flatten nested tables and convert to strings
    for i = 1, n do
        local value = select(i, ...)
        if value == nil then
            table.insert(flattenedData, "")
        elseif type(value) == "table" then
            flattenOrderedTable(value, flattenedData)
        else
            table.insert(flattenedData, tostring(value))
        end
    end
    local dataLength = #flattenedData

    -- Put all values into a single pipe separated string
    for index, value in ipairs(flattenedData) do
        dataString = dataString .. tostring(value)
        if index < dataLength then dataString = dataString .. "|" end
    end

    dataString = FilterText(dataString)

    -- above 404 it will be clamped
    -- above 462 it will be completely ignored
    if #dataString > 404 then
        warn("Panorama string length", #dataString, "exceeds 404 characters and may be truncated! Consider reducing the amount of data being sent or splitting it into multiple sends.")
        ---@TODO split into multiple sends, need a way to buffer SendToConsole calls and ensure they are sent in order
    end

    -- print("Sending to pano:", dataString)
    SendToConsole("@panorama_dispatch_event AddStyleToEachChild('"..dataString.."')")
end

---
---Converts any value to a JSON string.
---
---@param value any # The value to convert
---@return string # The JSON string
function Panorama:ToJSON(value)
    if type(value) == "nil" then return "null"
    elseif type(value) == "boolean" then return tostring(value)
    elseif type(value) == "number" then return tostring(value)
    elseif IsVector(value) or IsQAngle(value) then
        return string.format("[%.2f,%.2f,%.2f]", value.x, value.y, value.z)
    elseif type(value) == "table" then
        -- If it's an array
        if #value == 0 then
            local result = "{"
            local first = true
            for key, val in pairs(value) do
                if not first then result = result .. "," end
                result = result .. Panorama:ToJSON(key) .. ":" .. Panorama:ToJSON(val)
                first = false
            end
            return result .. "}"
        -- If it's an object
        else
            local result = "["
            local first = true
            for _, val in ipairs(value) do
                if not first then result = result .. "," end
                result = result .. Panorama:ToJSON(val)
                first = false
            end
            return result .. "]"
        end
    else
        return string.format("%q", value)
    end
end

---
---Gets the panorama id from an entity if it has one.
---
---@param entityPanel EntityHandle # The entity to get the id from
---@return string? # The panorama id
function Panorama:GetId(entityPanel)
---@diagnostic disable-next-line: undefined-field
    return entityPanel.__panoid
end

return Panorama.version
