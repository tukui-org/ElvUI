local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local min = min
local strjoin = strjoin
local GetSpellCritChance = GetSpellCritChance
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CRIT_ABBR = CRIT_ABBR

local displayString, lastPanel = ''

local function OnEvent(self)
	local minCrit = GetSpellCritChance(2)
	for i = 3, 7 do
		local spellCrit = GetSpellCritChance(i)
		minCrit = min(minCrit, spellCrit)
	end

	self.text:SetFormattedText(displayString, CRIT_ABBR, minCrit)

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', '%s: ', hex, '%.2f%%|r')

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Spell Crit Chance', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS' }, OnEvent, nil, nil, nil, nil, 'Spell Crit Chance')
