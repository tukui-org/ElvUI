--------------------------------------------------------------------------
-- Auto-Release when dead in Battleground.
--------------------------------------------------------------------------
local ElvCF = ElvCF
local ElvDB = ElvDB

if ElvCF["others"].pvpautorelease ~= true then return end

local autoreleasepvp = CreateFrame("frame")
autoreleasepvp:RegisterEvent("PLAYER_DEAD")
autoreleasepvp:SetScript("OnEvent", function(self, event)
	local soulstone = GetSpellInfo(20707)
	if ((ElvDB.myclass ~= "SHAMAN") and not (soulstone and UnitBuff("player", soulstone))) and MiniMapBattlefieldFrame.status == "active" then
		RepopMe()
	end
end)