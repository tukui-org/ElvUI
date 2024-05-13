local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format = format
local strjoin = strjoin

local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetCritChance = GetCritChance
local GetRangedCritChance = GetRangedCritChance

local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CRIT_ABBR = CRIT_ABBR

local MELEE_CRIT_CHANCE = MELEE_CRIT_CHANCE
local CR_CRIT_MELEE = CR_CRIT_MELEE
local CR_CRIT_RANGED = CR_CRIT_RANGED
local CR_CRIT_TOOLTIP = CR_CRIT_TOOLTIP

local displayString, db = ''
local meleeCrit, rangedCrit, ratingIndex = 0, 0

local function OnEnter()
	DT.tooltip:ClearLines()

	if E.Classic then
		DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %.2f%%', MELEE_CRIT_CHANCE, meleeCrit))
	else
		local critical = GetCombatRating(ratingIndex)

		DT.tooltip:AddLine(format('|cffFFFFFF%s:|r |cffFFFFFF%.2f%%|r', MELEE_CRIT_CHANCE, meleeCrit))
		DT.tooltip:AddDoubleLine(format(CR_CRIT_TOOLTIP, BreakUpLargeNumbers(critical) , GetCombatRatingBonus(ratingIndex)))
	end

	DT.tooltip:Show()
end

local function OnEvent(self)
	meleeCrit = GetCritChance()
	rangedCrit = GetRangedCritChance()

	local critChance
	if (rangedCrit > meleeCrit) then
		critChance = rangedCrit
		ratingIndex = CR_CRIT_RANGED
	else
		critChance = meleeCrit
		ratingIndex = CR_CRIT_MELEE
	end

	if db.NoLabel then
		self.text:SetFormattedText(displayString, critChance)
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or CRIT_ABBR..': ', critChance)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.'..db.decimalLength..'f%%|r')

	OnEvent(self)
end

DT:RegisterDatatext('Crit', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS'}, OnEvent, nil, nil, OnEnter, nil, MELEE_CRIT_CHANCE, nil, ApplySettings)
