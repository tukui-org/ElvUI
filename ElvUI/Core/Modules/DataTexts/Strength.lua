local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local UnitStat = UnitStat
local ITEM_MOD_STRENGTH_SHORT = ITEM_MOD_STRENGTH_SHORT
local LE_UNIT_STAT_STRENGTH = LE_UNIT_STAT_STRENGTH
local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES

local displayString, data = ''

local function OnEvent(self)
	if data.NoLabel then
		self.text:SetFormattedText(displayString, UnitStat('player', LE_UNIT_STAT_STRENGTH))
	else
		self.text:SetFormattedText(displayString, data.Label ~= '' and data.Label or ITEM_MOD_STRENGTH_SHORT..': ', UnitStat('player', LE_UNIT_STAT_STRENGTH))
	end
end

local function ValueColorUpdate(self, hex)
	if not data then
		data = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', data.NoLabel and '' or '%s', hex, '%d|r')

	OnEvent(self)
end

DT:RegisterDatatext('Strength', STAT_CATEGORY_ATTRIBUTES, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, ITEM_MOD_STRENGTH_SHORT, nil, ValueColorUpdate)
