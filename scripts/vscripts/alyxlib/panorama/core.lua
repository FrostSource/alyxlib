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
---@param entityPanel EntityHandle # The entity to initialize.
---@param customId? string # If nil the id will be generated automatically.
function Panorama:InitPanel(entityPanel, customId)
    local id = customId

    if not id or id == "" then
        if entityPanel:GetName() ~= "" then
            id = DoUniqueString(entityPanel:GetName() .. "_panoid")
        else
            id = DoUniqueString(entityPanel:GetClassname() .. "_panoid")
        end
    end

    entityPanel.__panoid = id
    DoEntFireByInstanceHandle(entityPanel, "AddCSSClass", id, 0, nil, nil)
end

---
---Send data to a panorama panel.
---
---@param entityPanel EntityHandle
---@param ... any
function Panorama:Send(entityPanel, ...)
    ---@diagnostic disable-next-line: undefined-field
    local id = entityPanel.__panoid
    if not id then
        warn(Debug.EntStr(entityPanel), "has not been initialized with a panorama id!")
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
