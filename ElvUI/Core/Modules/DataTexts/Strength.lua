local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local UnitStat = UnitStat

local ITEM_MOD_STRENGTH_SHORT = ITEM_MOD_STRENGTH_SHORT
local LE_UNIT_STAT_STRENGTH = LE_UNIT_STAT_STRENGTH
local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES

local displayString, db = ''

local function OnEvent(self)
	local stat = UnitStat('player', LE_UNIT_STAT_STRENGTH)

	if db.NoLabel then
		self.text:SetFormattedText(displayString, stat)
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or ITEM_MOD_STRENGTH_SHORT..': ', stat)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%d|r')
end

DT:RegisterDatatext('Strength', STAT_CATEGORY_ATTRIBUTES, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, ITEM_MOD_STRENGTH_SHORT, nil, ApplySettings)
