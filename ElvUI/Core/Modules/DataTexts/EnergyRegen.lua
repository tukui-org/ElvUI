local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local GetPowerRegen = GetPowerRegen

local STAT_ENERGY_REGEN = STAT_ENERGY_REGEN
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString, db = ''

local function OnEvent(self)
	local energyRegen = GetPowerRegen()
	if db.NoLabel then
		self.text:SetFormattedText(displayString, energyRegen)
	else
		local separator = (db.LabelSeparator ~= '' and db.LabelSeparator) or DT.db.labelSeparator or ': '
		self.text:SetFormattedText(displayString, (db.Label ~= '' and db.Label or STAT_ENERGY_REGEN)..separator, energyRegen)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.f|r')
end

DT:RegisterDatatext('EnergyRegen', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, STAT_ENERGY_REGEN, nil, ApplySettings)
