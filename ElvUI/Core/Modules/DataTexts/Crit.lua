local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format = format
local strjoin = strjoin
local GetCritChance = GetCritChance
local GetRangedCritChance = GetRangedCritChance
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CRIT_ABBR = CRIT_ABBR

local MELEE_CRIT_CHANCE = MELEE_CRIT_CHANCE
local CR_CRIT_MELEE_TOOLTIP = CR_CRIT_MELEE_TOOLTIP
local CR_CRIT_MELEE = CR_CRIT_MELEE
local CR_CRIT_RANGED = CR_CRIT_RANGED

local displayString, db = ''
local meleeCrit, rangedCrit, ratingIndex = 0, 0

local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddLine(format('%s: %.2f%%', MELEE_CRIT_CHANCE, meleeCrit))

	if not E.Classic then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine(format(CR_CRIT_MELEE_TOOLTIP, GetCombatRating(ratingIndex), GetCombatRatingBonus(ratingIndex)))
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
