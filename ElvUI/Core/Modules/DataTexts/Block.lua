local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin

local GetBlockChance = GetBlockChance

local BLOCK = BLOCK
local STAT_CATEGORY_DEFENSE = STAT_CATEGORY_DEFENSE

local displayString = ''

local function OnEvent(self)
	local stat  = GetBlockChance()
	self.text:SetFormattedText(displayString, L['Block: '], stat)
end

local function ValueColorUpdate(self, hex)
	displayString = strjoin('', '%s', hex, '%.f|r')

	OnEvent(self)
end

DT:RegisterDatatext('Block', STAT_CATEGORY_DEFENSE, { 'UNIT_STATS', 'UNIT_AURA', 'SKILL_LINES_CHANGED' }, OnEvent, nil, nil, nil, nil, BLOCK, nil, ValueColorUpdate)

