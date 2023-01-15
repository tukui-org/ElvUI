local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local UnitStat = UnitStat
local ITEM_MOD_SPIRIT_SHORT = ITEM_MOD_SPIRIT_SHORT
local STAT_CATEGORY_ATTRIBUTES = STAT_CATEGORY_ATTRIBUTES

local displayString = ''

local function OnEvent(self)
	self.text:SetFormattedText(displayString, ITEM_MOD_SPIRIT_SHORT, UnitStat('player', 5))
end

local function ValueColorUpdate(self, hex)
	displayString = strjoin('', '%s: ', hex, '%.f|r')

	OnEvent(self)
end

DT:RegisterDatatext('Spirit', STAT_CATEGORY_ATTRIBUTES, { 'UNIT_STATS', 'UNIT_AURA' }, OnEvent, nil, nil, nil, nil, ITEM_MOD_SPIRIT_SHORT, nil, ValueColorUpdate)
