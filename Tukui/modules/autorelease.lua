--------------------------------------------------------------------------
-- Auto-Release when dead in Wintergrasp or Battleground.
--------------------------------------------------------------------------

if TukuiCF["others"].pvpautorelease ~= true then return end

local WINTERGRASP
WINTERGRASP = tukuilocal.mount_wintergrasp

local autoreleasepvp = CreateFrame("frame")
autoreleasepvp:RegisterEvent("PLAYER_DEAD")
autoreleasepvp:SetScript("OnEvent", function(self, event)
	local soulstone = GetSpellInfo(20707)
	if (TukuiDB.myclass ~= "SHAMAN") or not (soulstone and UnitBuff("player", soulstone)) then
		if (tostring(GetZoneText()) == WINTERGRASP) then
			RepopMe()
		end

		if MiniMapBattlefieldFrame.status == "active" then
			RepopMe()
		end
	end
end)