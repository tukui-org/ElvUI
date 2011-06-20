-----------------------------------------
-- Crit Rating
-----------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["datatext"].crit or C["datatext"].crit == 0 then return end

local Stat = CreateFrame("Frame")
Stat:SetFrameStrata("MEDIUM")
Stat:SetFrameLevel(3)

local Text  = ElvuiInfoLeft:CreateFontString(nil, "LOW")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
E.PP(C["datatext"].crit, Text)
Stat:SetParent(Text:GetParent())

local _G = getfenv(0)
local format = string.format
local displayNumberString = string.join("", "%s", E.ValColor, "%d|r")
local displayFloatString = string.join("", "%s", E.ValColor, "%.2f%%|r")
local displayModifierString = string.join("", "%s", E.ValColor, "%.2f%%|r")

-- initial delay for update (let the ui load)
local int = 5
local function Update(self, t)
	int = int - t
	if int > 0 then return end

	local critRating
	if E.Role == "Caster" then
		critRating = GetSpellCritChance(1)
	else
		if E.myclass == "HUNTER" then
			critRating = GetRangedCritChance()
		else
			critRating = GetCritChance()
		end
	end
	Text:SetFormattedText(displayModifierString, L.datatext_playercrit, critRating)
	int = 2
end

Stat:SetScript("OnUpdate", Update)
Update(Stat, 6)