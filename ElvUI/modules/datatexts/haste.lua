
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


--------------------------------------------------------------------
-- player haste
--------------------------------------------------------------------

if C["datatext"].haste and C["datatext"].haste > 0 then
	local Stat = CreateFrame("Frame")
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)

	local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(E.mult, -E.mult)
	Text:SetShadowColor(0, 0, 0, 0.4)
	E.PP(C["datatext"].haste, Text)

	local int = 1
	
	local haste
	local function Update(self, t)
		local spellHaste = GetCombatRating(20)
		local rangedHaste = GetCombatRating(19)
		local attackHaste = GetCombatRating(18)
		
		if attackHaste > spellHaste and E.class ~= "HUNTER" then
			haste = attackHaste
		elseif E.class == "HUNTER" then
			haste = rangedHaste
		else
			haste = spellHaste
		end
		
		int = int - t
		if int < 0 then
			Text:SetText(SPELL_HASTE_ABBR..": "..E.ValColor..haste)
			int = 1
		end     
	end

	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end