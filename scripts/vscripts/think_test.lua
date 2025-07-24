---@class ThinkExample : EntityClass
local base = entity("ThinkExample")

base.lastPrintedSecond = -1
base.elapsedTime = 0

---Start thinking only on first spawn
---@param spawnkeys CScriptKeyValues
function base:OnSpawn(spawnkeys)
    print("Save and load within 20 seconds to see think state persistence")
    self:ResumeThink()

    -- Debug.PrintMetaClasses()
    -- print(getmetatable(getvalvemeta(self).__index))
    -- Debug.PrintTable(getvalvemeta(self), nil, nil, true)
    Debug.PrintTable(getinherits(self))
end

function base:Think()
    self.elapsedTime = self.elapsedTime + FrameTime()
    local seconds = math.floor(self.elapsedTime)

    if seconds % 2 == 0 and seconds ~= self.lastPrintedSecond then
        print("Server time is even: " .. seconds)
        self.lastPrintedSecond = seconds
    end

    if seconds > 20 then -- (2)!
        print("Stopping Think after 20 seconds")
        return self:PauseThink()
    end

    return 0 -- (1)!
end



-- ---@param enemy EntityHandle
-- function base:Attack(enemy)
--     local dmg = CreateDamageInfo(self, self,
--         self:GetForwardVector() * self.damage,
--         self:GetAttachmentNameOrigin("mouth"),
--         self.damage,
--         DMG_SLASH
--     )

--     enemy:TakeDamage(dmg)

--     DestroyDamageInfo(dmg)
-- end

-- ---@param self ThinkExample
-- ---@param params GameEventPlayerDropResinInBackpack
-- base:GameEvent("player_drop_resin_in_backpack", function(self, params)
--     -- self:UpdateDisplay(Player:GetResin())
    
-- end)

-- ---@param params IOParams
-- base:Output("OnHealingPlayerStart", function(self, params)
--     ---@cast self ThinkExample
--     self:StartCountdownAndExplode()
-- end)

-- ---@param params PlayerEventItemPickup
-- base:PlayerEvent("item_pickup", function(self, params)
--     ---@cast self SpecialDevice
--     if params.item == self then
--         self:ResumeThink()
--     end
-- end)

-- ---@param params PlayerEventItemReleased
-- base:PlayerEvent("item_released", function(self, params)
--     ---@cast self SpecialDevice
--     if params.item == self then
--         self:PauseThink()
--     end
-- end)

