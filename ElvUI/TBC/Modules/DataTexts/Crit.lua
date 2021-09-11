local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local min = min
local strjoin = strjoin

local GetCritChance = GetCritChance
local GetRangedCritChance = GetRangedCritChance
local GetSpellCritChance = GetSpellCritChance
local CRIT_ABBR = CRIT_ABBR
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString, lastPanel = ''
local spellCrit, rangedCrit, meleeCrit = 0, 0, 0
local critChance = 0

local function OnEvent(self)
	local minCrit = GetSpellCritChance(2)
	for i = 3, 7 do
		spellCrit = GetSpellCritChance(i);
		minCrit = min(minCrit, spellCrit);
	end
	spellCrit = minCrit
	rangedCrit = GetRangedCritChance();
	meleeCrit = GetCritChance();

	if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
		critChance = spellCrit;
	elseif (rangedCrit >= meleeCrit) then
		critChance = rangedCrit;
	else
		critChance = meleeCrit;
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

DT:RegisterDatatext('Crit', STAT_CATEGORY_ENHANCEMENTS, {'UNIT_STATS', 'UNIT_AURA', 'PLAYER_TALENT_UPDATE', 'PLAYER_DAMAGE_DONE_MODS'}, OnEvent, nil, nil, nil, nil, _G.STAT_CRITICAL_STRIKE, nil, ValueColorUpdate)
