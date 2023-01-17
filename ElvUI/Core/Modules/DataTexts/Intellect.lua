local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local UnitStat = UnitStat
local ITEM_MOD_INTELLECT_SHORT = ITEM_MOD_INTELLECT_SHORT
local LE_UNIT_STAT_INTELLECT = LE_UNIT_STAT_INTELLECT
local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES

local displayString = ''

local function OnEvent(self)
	local intellect = UnitStat('player', LE_UNIT_STAT_INTELLECT)
	if E.global.datatexts.settings.Intellect.NoLabel then
		self.text:SetFormattedText(displayString, intellect)
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.Intellect.Label ~= '' and E.global.datatexts.settings.Intellect.Label or ITEM_MOD_INTELLECT_SHORT..': ', intellect)
	end
end

local function ValueColorUpdate(self, hex)
	displayString = strjoin('', E.global.datatexts.settings.Intellect.NoLabel and '' or '%s', hex, '%.f|r')

	OnEvent(self)
end

DT:RegisterDatatext('Intellect', STAT_CATEGORY_ATTRIBUTES, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, ITEM_MOD_INTELLECT_SHORT, nil, ValueColorUpdate)
