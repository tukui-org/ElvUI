local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local GetCombatRatingBonus = GetCombatRatingBonus
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CR_HASTE_SPELL = CR_HASTE_SPELL

local displayString = ''

local function OnEvent(self)
	self.text:SetFormattedText(displayString, GetCombatRatingBonus(CR_HASTE_SPELL) or 0)
end

local function ValueColorUpdate(self, hex)
	displayString = strjoin('', L["Spell Haste"], ': ', hex, '%.2f%%|r')

	OnEvent(self)
end

DT:RegisterDatatext('Spell Haste', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, L["Spell Haste"], nil, ValueColorUpdate)
