--------------------------------------------------------------------------
-- Auto-Release when dead in Wintergrasp or Battleground.
--------------------------------------------------------------------------
local ElvCF = ElvCF
local ElvDB = ElvDB

if ElvCF["others"].pvpautorelease ~= true then return end

local WINTERGRASP
WINTERGRASP = ElvL.mount_wintergrasp

local autoreleasepvp = CreateFrame("frame")
autoreleasepvp:RegisterEvent("PLAYER_DEAD")
autoreleasepvp:SetScript("OnEvent", function(self, event)
	local soulstone = GetSpellInfo(20707)
	if (ElvDB.myclass ~= "SHAMAN") and not (soulstone and UnitBuff("player", soulstone)) then
		if (tostring(GetZoneText()) == WINTERGRASP) then
			RepopMe()
		end

		if MiniMapBattlefieldFrame.status == "active" then
			RepopMe()
		end
	end
end)