-- Initialize Scalable Init Support for backwards compatibility
-- Must use / instead of . to ensure it does not get executed twice if SIS is enabled
require("core/scalableinit")

-- Load AlyxLib on the server
if IsServer() then
    require("alyxlib.init")
end