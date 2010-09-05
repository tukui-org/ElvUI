--------------------------------------------------------------------------
-- auto-dez (priority) or auto-greed green item at max level
-- yes... you are right... i'm totally lazy
-- auto-greed Frozen Orbs
--------------------------------------------------------------------------

if TukuiCF["loot"].autogreed == true then
	local autogreed = CreateFrame("frame")
	autogreed:RegisterEvent("START_LOOT_ROLL")
	autogreed:SetScript("OnEvent", function(self, event, id)
		local name = select(2, GetLootRollItemInfo(id))
		if (name == select(1, GetItemInfo(43102))) then
			RollOnLoot(id, 2)
		end
		if TukuiDB.level ~= MAX_PLAYER_LEVEL then return end
		if(id and select(4, GetLootRollItemInfo(id))==2 and not (select(5, GetLootRollItemInfo(id)))) then
			if RollOnLoot(id, 3) then
				RollOnLoot(id, 3)
			else
				RollOnLoot(id, 2)
			end
		end
	end)
end