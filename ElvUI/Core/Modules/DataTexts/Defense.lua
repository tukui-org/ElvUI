local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local UnitDefense = UnitDefense

local DEFENSE = DEFENSE
local STAT_CATEGORY_DEFENSE = STAT_CATEGORY_DEFENSE

local displayString, db = ''

local function OnEvent(self)
	local baseDefense, armorDefense = UnitDefense('player')
	local defense = (baseDefense or 0) + (armorDefense or 0)
	if db.NoLabel then
		self.text:SetFormattedText(displayString, defense)
	else
		local separator = (db.LabelSeparator ~= '' and db.LabelSeparator) or DT.db.labelSeparator or ': '
		self.text:SetFormattedText(displayString, (db.Label ~= '' and db.Label or DEFENSE)..separator, defense)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.f|r')
end

DT:RegisterDatatext('Defense', STAT_CATEGORY_DEFENSE, { 'UNIT_STATS', 'UNIT_AURA', 'SKILL_LINES_CHANGED' }, OnEvent, nil, nil, nil, nil, DEFENSE, nil, ApplySettings)
