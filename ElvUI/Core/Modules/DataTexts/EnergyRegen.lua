local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin

local GetPowerRegen = GetPowerRegen

local STAT_ENERGY_REGEN = STAT_ENERGY_REGEN
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString = ''

local function OnEvent(self)
	self.text:SetFormattedText(displayString, STAT_ENERGY_REGEN, GetPowerRegen())
end

local function ApplySettings(_, hex)
	displayString = strjoin('', '%s: ', hex, '%.f|r')
end

DT:RegisterDatatext('EnergyRegen', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, STAT_ENERGY_REGEN, nil, ApplySettings)
