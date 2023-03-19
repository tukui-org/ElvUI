local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local GetSpellBonusHealing = GetSpellBonusHealing
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString = ''

local function OnEvent(self)
	self.text:SetFormattedText(displayString, L["HP"], GetSpellBonusHealing())
end

local function ApplySettings(_, hex)
	displayString = strjoin('', '%s: ', hex, '%d|r')
end

DT:RegisterDatatext('HealPower', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, L["Heal Power"], nil, ApplySettings)
