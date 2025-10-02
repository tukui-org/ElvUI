local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local UnitStat = UnitStat
local ITEM_MOD_SPIRIT_SHORT = ITEM_MOD_SPIRIT_SHORT
local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES

local displayString, db = ''

local function OnEvent(self)
	local spirit = UnitStat('player', 5)
	if db.NoLabel then
		self.text:SetFormattedText(displayString, spirit)
	else
		local separator = (db.LabelSeparator ~= '' and db.LabelSeparator) or DT.db.labelSeparator or ': '
		self.text:SetFormattedText(displayString, (db.Label ~= '' and db.Label or ITEM_MOD_SPIRIT_SHORT)..separator, spirit)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.f|r')
end

DT:RegisterDatatext('Spirit', STAT_CATEGORY_ATTRIBUTES, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, ITEM_MOD_SPIRIT_SHORT, nil, ApplySettings)
