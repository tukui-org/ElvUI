local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local UnitStat = UnitStat

local ITEM_MOD_AGILITY_SHORT = ITEM_MOD_AGILITY_SHORT
local LE_UNIT_STAT_AGILITY = LE_UNIT_STAT_AGILITY
local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES

local displayString, lastPanel = ''

local function OnEvent(self)
	if E.global.datatexts.settings.Agility.NoLabel then
		self.text:SetFormattedText(displayString, UnitStat('player', LE_UNIT_STAT_AGILITY))
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.Agility.Label ~= '' and E.global.datatexts.settings.Agility.Label or ITEM_MOD_AGILITY_SHORT..': ', UnitStat('player', LE_UNIT_STAT_AGILITY))
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.Agility.NoLabel and '' or '%s', hex, '%d|r')

	if lastPanel then OnEvent(lastPanel) end
end

E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Agility', STAT_CATEGORY_ATTRIBUTES, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, ITEM_MOD_AGILITY_SHORT, nil, ValueColorUpdate)
