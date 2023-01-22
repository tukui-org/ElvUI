local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin

local UnitDefense = UnitDefense

local DEFENSE = DEFENSE
local STAT_CATEGORY_DEFENSE = STAT_CATEGORY_DEFENSE

local displayString = ''

local function OnEvent(self)
	local stat  = UnitDefense('player')

	self.text:SetFormattedText(displayString, DEFENSE, stat)
end

local function ValueColorUpdate(self, hex)
	displayString = strjoin('', '%s: ', hex, '%.f|r')

	OnEvent(self)
end

DT:RegisterDatatext('Defense', STAT_CATEGORY_DEFENSE, { 'UNIT_STATS', 'UNIT_AURA', 'SKILL_LINES_CHANGED' }, OnEvent, nil, nil, nil, nil, DEFENSE, nil, ValueColorUpdate)

