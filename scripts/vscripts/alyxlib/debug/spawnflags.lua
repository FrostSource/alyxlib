--[[
    v1.0.0
    https://github.com/FrostSource/alyxlib

    Attach this script to an entity by setting the Entity Scripts field to alyxlib/debug/spawnflags

    Prints the spawnflags property value to the console when the entity spawns.
    Filter for SpawnFlags to quickly find.
]]

---@param spawnkeys CScriptKeyValues
function Spawn(spawnkeys)
    local flags = spawnkeys:GetValue("spawnflags")

    print()
    print("SpawnFlags " .. thisEntity:GetName() .. "," .. thisEntity:GetClassname() .. " : " .. tostring(flags))
    print()

end
