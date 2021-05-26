local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local min = min
local format, strjoin = format, strjoin
local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetCritChance = GetCritChance
local GetRangedCritChance = GetRangedCritChance
local GetSpellCritChance = GetSpellCritChance
local GetCritChanceProvidesParryEffect = GetCritChanceProvidesParryEffect
local GetCombatRatingBonusForCombatRatingValue = GetCombatRatingBonusForCombatRatingValue
local CR_CRIT_MELEE = CR_CRIT_MELEE
local CR_CRIT_RANGED = CR_CRIT_RANGED
local CR_CRIT_SPELL = CR_CRIT_SPELL
local CR_PARRY = CR_PARRY
local MAX_SPELL_SCHOOLS = MAX_SPELL_SCHOOLS
local CRIT_ABBR = CRIT_ABBR
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local MELEE_CRIT_CHANCE = MELEE_CRIT_CHANCE
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT
local RANGED_CRIT_CHANCE = RANGED_CRIT_CHANCE
local SPELL_CRIT_CHANCE = SPELL_CRIT_CHANCE
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CR_CRIT_PARRY_RATING_TOOLTIP = CR_CRIT_PARRY_RATING_TOOLTIP
local CR_CRIT_TOOLTIP = CR_CRIT_TOOLTIP
local displayString, lastPanel = ''
local rating, spellCrit, rangedCrit, meleeCrit, critChance
local extraCritChance, extraCritRating

local function OnEnter()
	DT.tooltip:ClearLines()

	local tooltip, critText
	if spellCrit >= rangedCrit and spellCrit >= meleeCrit then
		critText = SPELL_CRIT_CHANCE
	elseif rangedCrit >= meleeCrit then
		critText = RANGED_CRIT_CHANCE
	else
		critText = MELEE_CRIT_CHANCE
	end

	if GetCritChanceProvidesParryEffect() then
		tooltip = format(CR_CRIT_PARRY_RATING_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance, GetCombatRatingBonusForCombatRatingValue(CR_PARRY, extraCritRating))
	else
		tooltip = format(CR_CRIT_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance)
	end

	DT.tooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, critText)..' '..format('%.2f%%', critChance)..FONT_COLOR_CODE_CLOSE, nil, 1, 1, 1)
	DT.tooltip:AddLine(tooltip, nil, nil, nil, true)
	DT.tooltip:Show()
end

local function OnEvent(self)
	local minCrit = GetSpellCritChance(2)
	for i = 3, MAX_SPELL_SCHOOLS do
		spellCrit = GetSpellCritChance(i)
		minCrit = min(minCrit, spellCrit)
	end
	spellCrit = minCrit
	rangedCrit = GetRangedCritChance()
	meleeCrit = GetCritChance()

	if spellCrit >= rangedCrit and spellCrit >= meleeCrit then
		critChance = spellCrit
		rating = CR_CRIT_SPELL
	elseif rangedCrit >= meleeCrit then
		critChance = rangedCrit
		rating = CR_CRIT_RANGED
	else
		critChance = meleeCrit
		rating = CR_CRIT_MELEE
	end

	extraCritChance, extraCritRating = GetCombatRatingBonus(rating), GetCombatRating(rating)

	if E.global.datatexts.settings.Crit.NoLabel then
		self.text:SetFormattedText(displayString, critChance)
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.Crit.Label ~= '' and E.global.datatexts.settings.Crit.Label or CRIT_ABBR..': ', critChance)
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.Crit.NoLabel and '' or '%s', hex, '%.'..E.global.datatexts.settings.Crit.decimalLength..'f%%|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Crit', STAT_CATEGORY_ENHANCEMENTS, {'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE', 'PLAYER_DAMAGE_DONE_MODS'}, OnEvent, nil, nil, OnEnter, nil, _G.STAT_CRITICAL_STRIKE, nil, ValueColorUpdate)
