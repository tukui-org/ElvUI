local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local UnitStat = UnitStat
local ITEM_MOD_STRENGTH_SHORT = ITEM_MOD_STRENGTH_SHORT
local LE_UNIT_STAT_STRENGTH = LE_UNIT_STAT_STRENGTH
local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES

local displayString = ''

local function OnEvent(self)
	if E.global.datatexts.settings.Strength.NoLabel then
		self.text:SetFormattedText(displayString, UnitStat('player', LE_UNIT_STAT_STRENGTH))
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.Strength.Label ~= '' and E.global.datatexts.settings.Strength.Label or ITEM_MOD_STRENGTH_SHORT..': ', UnitStat('player', LE_UNIT_STAT_STRENGTH))
	end
end

local function ValueColorUpdate(self, hex)
	displayString = strjoin('', E.global.datatexts.settings.Strength.NoLabel and '' or '%s', hex, '%d|r')

	OnEvent(self)
end

DT:RegisterDatatext('Strength', STAT_CATEGORY_ATTRIBUTES, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, ITEM_MOD_STRENGTH_SHORT, nil, ValueColorUpdate)
