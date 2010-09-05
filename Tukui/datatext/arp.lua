--------------------------------------------------------------------
-- player arp
--------------------------------------------------------------------

if TukuiCF["datatext"].arp and TukuiCF["datatext"].arp > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	local Text  = TukuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize)
	TukuiDB.PP(TukuiCF["datatext"].arp, Text)
   
	local int = 1

	local function Update(self, t)
	  int = int - t
	  if int < 0 then
		 Text:SetText(GetCombatRating(25) .. " " .. tukuilocal.datatext_playerarp)
		 int = 1
	  end     
	end

	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end