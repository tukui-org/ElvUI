local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin

local GetCritChance = GetCritChance
local GetRangedCritChance = GetRangedCritChance
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CRIT_ABBR = CRIT_ABBR

local displayString, lastPanel = ''
local spellCrit, rangedCrit, meleeCrit = 0, 0, 0
local critChance = 0

local function OnEvent(self)
	rangedCrit = GetRangedCritChance()
	meleeCrit = GetCritChance()

	if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
		critChance = spellCrit
	elseif (rangedCrit >= meleeCrit) then
		critChance = rangedCrit
	else
		critChance = meleeCrit
	end

	if E.global.datatexts.settings.Crit.NoLabel then
		self.text:SetFormattedText(displayString, critChance)
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.Crit.Label ~= '' and E.global.datatexts.settings.Crit.Label or CRIT_ABBR..': ', critChance)
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.Crit.NoLabel and '' or '%s', hex, '%.'..E.global.datatexts.settings.Crit.decimalLength..'f%%|r')

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Crit', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS'}, OnEvent, nil, nil, nil, nil, _G.STAT_CRITICAL_STRIKE, nil, ValueColorUpdate)
