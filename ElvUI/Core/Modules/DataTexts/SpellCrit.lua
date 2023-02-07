local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local min = min
local strjoin = strjoin
local GetSpellCritChance = GetSpellCritChance

local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local MAX_SPELL_SCHOOLS = MAX_SPELL_SCHOOLS or 7
local CRIT_ABBR = CRIT_ABBR

local displayString, db = ''

local function OnEvent(self)
	local minCrit

	if db.school == 0 then
		minCrit = GetSpellCritChance(2) or 0

		for i = 3, MAX_SPELL_SCHOOLS do
			minCrit = min(minCrit, GetSpellCritChance(i) or 0)
		end
	else
		minCrit = GetSpellCritChance(db.school)
	end

	self.text:SetFormattedText(displayString, CRIT_ABBR, minCrit or 0)
end

local icon = [[Interface\PaperDollInfoFrame\SpellSchoolIcon]]
local function OnEnter()
	DT.tooltip:ClearLines()

	for i = 2, MAX_SPELL_SCHOOLS do
		local crit = GetSpellCritChance(i) or 0
		DT.tooltip:AddDoubleLine(_G['DAMAGE_SCHOOL'..i], crit)
		DT.tooltip:AddTexture(icon..i)
	end

	DT.tooltip:Show()
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', '%s: ', hex, '%.2f%%|r')
end

DT:RegisterDatatext('Spell Crit Chance', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS' }, OnEvent, nil, nil, OnEnter, nil, nil, nil, ApplySettings)
