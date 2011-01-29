local ElvCF = ElvCF
local ElvDB = ElvDB
local ElvL = ElvL

--------------------------------------------------------------------
-- player haste
--------------------------------------------------------------------

if ElvCF["datatext"].haste and ElvCF["datatext"].haste > 0 then
	local Stat = CreateFrame("Frame")
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)

	local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(ElvCF.media.font, ElvCF["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(ElvDB.mult, -ElvDB.mult)
	ElvDB.PP(ElvCF["datatext"].haste, Text)

	local int = 1
	
	local haste
	local function Update(self, t)
		local spellHaste = GetCombatRating(20)
		local rangedHaste = GetCombatRating(19)
		local attackHaste = GetCombatRating(18)
		
		if attackHaste > spellHaste and ElvDB.class ~= "HUNTER" then
			haste = attackHaste
		elseif ElvDB.class == "HUNTER" then
			haste = rangedHaste
		else
			haste = spellHaste
		end
		
		int = int - t
		if int < 0 then
			Text:SetText(SPELL_HASTE_ABBR..": "..ElvDB.ValColor..haste)
			int = 1
		end     
	end

	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end