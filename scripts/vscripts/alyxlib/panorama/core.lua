--[[
    v1.0.0
]]

Panorama = {}
Panorama.version = "v1.0.0"

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
---@param panelEntity EntityHandle # The entity to initialize.
---@param customId? string # If nil the id will be generated automatically.
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

---
---Send data to a panorama panel.
---
---@param panelEntity EntityHandle # The entity to send data to.
---@param ... any # The data to send. Each value will be converted to a string.
function Panorama:Send(panelEntity, ...)
    ---@diagnostic disable-next-line: undefined-field
    local id = panelEntity.__panoid
    if not id then
        warn(Debug.EntStr(panelEntity), "has not been initialized with a panorama id!")
        return
    end

    local dataString = id .. "|"
    local data = {...}
    local i = 1
    local dataLength = #data

    -- Flatten nested tables into data
    while i <= dataLength do
        if type(data[i]) == "table" then
            data = vlua.extend(vlua.slice(data, 1, dataLength), data[i])
        end
        i = i + 1
    end

    -- Put all values into a single pipe separated string
    for index, value in ipairs(data) do
        dataString = dataString .. tostring(value)
        if index < dataLength then dataString = dataString .. "|" end
    end

    dataString = FilterText(dataString)
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
---Get the panorama id from an entity if it has one.
---
---@param entityPanel EntityHandle
---@return string?
function Panorama:GetId(entityPanel)
---@diagnostic disable-next-line: undefined-field
    return entityPanel.__panoid
end

print("panorama/core.lua ".. Panorama.version .." initialized...")

return Panorama.version
