local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local format = format
local strjoin = strjoin
local GetCritChance = GetCritChance
local GetRangedCritChance = GetRangedCritChance
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local BreakUpLargeNumbers = BreakUpLargeNumbers
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local STAT_CRITICAL_STRIKE = STAT_CRITICAL_STRIKE
local CRIT_ABBR = CRIT_ABBR

local displayString = ''
local spellCrit, rangedCrit, meleeCrit = 0, 0, 0
local critChance = 0

local function OnEnter()
	DT.tooltip:ClearLines()
	local text = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE)..' '..format('%.2F%%', critChance)..FONT_COLOR_CODE_CLOSE
	local classTooltip = _G['STAT_CRITICAL_STRIKE_'..E.myclass..'_TOOLTIP']
	if not classTooltip then classTooltip = STAT_CRITICAL_STRIKE_TOOLTIP end
	DT.tooltip:AddLine(format('%s: %s [+%.2f%%]', STAT_CRITICAL_STRIKE, BreakUpLargeNumbers(GetCombatRating(CR_HASTE_MELEE)), GetCombatRatingBonus(CR_HASTE_MELEE)))
	DT.tooltip:Show()
end

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
end

local function ValueColorUpdate(self, hex)
	displayString = strjoin('', E.global.datatexts.settings.Crit.NoLabel and '' or '%s', hex, '%.'..E.global.datatexts.settings.Crit.decimalLength..'f%%|r')

	OnEvent(self)
end

DT:RegisterDatatext('Crit', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS'}, OnEvent, nil, nil, not E.Classic and OnEnter, nil, _G.STAT_CRITICAL_STRIKE, nil, ValueColorUpdate)
