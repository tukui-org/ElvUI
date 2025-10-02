local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local strjoin = strjoin
local format = format

local GetCombatRating = GetCombatRating
local GetHitModifier = GetHitModifier
local GetCombatRatingBonus = GetCombatRatingBonus
local GetArmorPenetration = GetArmorPenetration

local STAT_HIT_CHANCE = STAT_HIT_CHANCE
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CR_HIT_MELEE_TOOLTIP = CR_HIT_MELEE_TOOLTIP
local CR_HIT_RANGED_TOOLTIP = CR_HIT_RANGED_TOOLTIP

local CR_HIT_MELEE = CR_HIT_MELEE or 6
local CR_HIT_RANGED = CR_HIT_RANGED or 7
local CR_ARMOR_PENETRATION = CR_ARMOR_PENETRATION

local ratingIndex = E.myclass == 'HUNTER' and CR_HIT_RANGED or CR_HIT_MELEE

local displayString, db = ''
local hitValue, hitPercent, hitPercentFromTalents = 0, 0, 0

local function OnEvent(self)
	hitValue = GetCombatRating(ratingIndex)
	hitPercent = GetCombatRatingBonus(ratingIndex)
	hitPercentFromTalents = ratingIndex == CR_HIT_MELEE and GetHitModifier() or 0

	if db.NoLabel then
		self.text:SetFormattedText(displayString, hitPercent + hitPercentFromTalents)
	else
		local separator = (db.LabelSeparator ~= '' and db.LabelSeparator) or DT.db.labelSeparator or ': '
		self.text:SetFormattedText(displayString, (db.Label ~= '' and db.Label or STAT_HIT_CHANCE)..separator, hitPercent + hitPercentFromTalents)
	end
end

local function OnEnter()
	DT.tooltip:ClearLines()

	DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %s', _G['COMBAT_RATING_NAME'..ratingIndex], hitValue))

	local ratingTooltip = ratingIndex == CR_HIT_MELEE and CR_HIT_MELEE_TOOLTIP or CR_HIT_RANGED_TOOLTIP
	if E.Classic then
		DT.tooltip:AddLine(format(ratingTooltip, E.mylevel, hitPercent))
	else
		DT.tooltip:AddLine(format(ratingTooltip, E.mylevel, hitPercent, GetCombatRating(CR_ARMOR_PENETRATION), GetArmorPenetration()))
	end

	DT.tooltip:Show()
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.'..db.decimalLength..'f%%|r')
end

DT:RegisterDatatext('Hit', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_EQUIPMENT_CHANGED' }, OnEvent, nil, nil, OnEnter, nil, STAT_HIT_CHANCE, nil, ApplySettings)
