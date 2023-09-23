local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local GetParryChance = GetParryChance

local PARRY = PARRY
local STAT_CATEGORY_DEFENSE = STAT_CATEGORY_DEFENSE

local displayString, db = ''

local function OnEvent(self)
	self.text:SetFormattedText(displayString, PARRY, GetParryChance())
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', '%s: ', hex, '%.'..db.decimalLength..'f%%|r')
end

DT:RegisterDatatext('Parry', STAT_CATEGORY_DEFENSE, { 'UNIT_STATS', 'UNIT_AURA', 'SKILL_LINES_CHANGED' }, OnEvent, nil, nil, nil, nil, PARRY, nil, ApplySettings)
