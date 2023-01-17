local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local min = min
local strjoin = strjoin
local GetSpellCritChance = GetSpellCritChance
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CRIT_ABBR = CRIT_ABBR

local displayString = ''

local function OnEvent(self)
	local minCrit = GetSpellCritChance(2)
	for i = 3, 7 do
		local spellCrit = GetSpellCritChance(i)
		minCrit = min(minCrit, spellCrit)
	end

	self.text:SetFormattedText(displayString, CRIT_ABBR, minCrit)
end

local function ValueColorUpdate(self, hex)
	displayString = strjoin('', '%s: ', hex, '%.2f%%|r')

	OnEvent(self)
end

DT:RegisterDatatext('Spell Crit Chance', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS' }, OnEvent, nil, nil, nil, nil, 'Spell Crit Chance', nil, ValueColorUpdate)
