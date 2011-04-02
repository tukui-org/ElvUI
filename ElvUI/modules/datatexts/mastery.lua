-----------------------------------------
-- Mastery Rating
-----------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["datatext"].mastery or C["datatext"].mastery == 0 then return end

local Stat = CreateFrame("Frame")
Stat:SetFrameStrata("MEDIUM")
Stat:SetFrameLevel(3)

local Text  = ElvuiInfoLeft:CreateFontString(nil, "LOW")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
E.PP(C["datatext"].mastery, Text)

local _G = getfenv(0)
local format = string.format
local displayNumberString = string.join("", "%s", E.ValColor, "%d|r")
local displayFloatString = string.join("", "%s", E.ValColor, "%.2f%%|r")
local displayModifierString = string.join("", "%s", E.ValColor, "%d (+%.2f%%)|r")

local function UpdateCaster(self)
	local spellMastery = GetCombatRatingBonus(CR_HASTE_SPELL)

	Text:SetFormattedText(displayFloatString, L.datatext_playermastery, spellMastery)
end

local function UpdateMelee(self)
	local meleeMastery = GetCombatRatingBonus(CR_HASTE_MELEE)
	local rangedMastery = GetCombatRatingBonus(CR_HASTE_RANGED)
	local masteryRating

	if E.myclass == "HUNTER" then
		masteryRating = rangedMastery
	else
		masteryRating = meleeMastery
	end

	Text:SetFormattedText(displayFloatString, L.datatext_playermastery, masteryRating)
end

-- initial delay for update (let the ui load)
local int = 5
local function Update(self, t)
	int = int - t
	if int > 0 then return end

	--STAT_MASTERY
	local masteryspell, masteryTag
	if GetCombatRating(CR_MASTERY) ~= 0 and GetPrimaryTalentTree() then
		if C["datatext"].masteryspell then
			if E.myclass == "DRUID" then
				if E.Role == "Melee" then
					masteryspell = select(2, GetTalentTreeMasterySpells(GetPrimaryTalentTree()))
				elseif E.Role == "Tank" then
					masteryspell = select(1, GetTalentTreeMasterySpells(GetPrimaryTalentTree()))
				else
					masteryspell = GetTalentTreeMasterySpells(GetPrimaryTalentTree())
				end
			else
				masteryspell = GetTalentTreeMasterySpells(GetPrimaryTalentTree())
			end

			local masteryName, _, _, _, _, _, _, _, _ = GetSpellInfo(masteryspell)

			if masteryName then
				masteryTag = STAT_MASTERY.." ("..masteryName.."): "
			else
				masteryTag = STAT_MASTERY..": "
			end
		else
			masteryTag = STAT_MASTERY..": "
		end
		Text:SetFormattedText(displayModifierString, masteryTag, GetCombatRating(CR_MASTERY), GetCombatRatingBonus(CR_MASTERY))
	end
	int = 2
end

Stat:SetScript("OnUpdate", Update)
Update(Stat, 6)