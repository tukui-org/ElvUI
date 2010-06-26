--------------------------------------------------------------------------
-- Auto-Release when dead in Wintergrasp or Battleground.
--------------------------------------------------------------------------

local WINTERGRASP
WINTERGRASP = tukuilocal.mount_wintergrasp

local autoreleasepvp = CreateFrame("frame")
autoreleasepvp:RegisterEvent("PLAYER_DEAD")
autoreleasepvp:SetScript("OnEvent", function(self, event)
	if TukuiDB.myclass ~= "SHAMAN" then
		if (tostring(GetZoneText()) == WINTERGRASP) then
			RepopMe()
		end

		if MiniMapBattlefieldFrame.status == "active" then
			RepopMe()
		end
	end
end)