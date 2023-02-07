local E, L, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local min = min
local strjoin = strjoin
local format = format

local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetMaxCombatRatingBonus = GetMaxCombatRatingBonus

local STAT_RESILIENCE = STAT_RESILIENCE
local RESILIENCE_TOOLTIP = RESILIENCE_TOOLTIP
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local CR_RESILIENCE_CRIT_TAKEN = CR_RESILIENCE_CRIT_TAKEN
local RESILIENCE_CRIT_CHANCE_TO_DAMAGE_REDUCTION_MULTIPLIER = RESILIENCE_CRIT_CHANCE_TO_DAMAGE_REDUCTION_MULTIPLIER
local RESILIENCE_CRIT_CHANCE_TO_CONSTANT_DAMAGE_REDUCTION_MULTIPLIER = RESILIENCE_CRIT_CHANCE_TO_CONSTANT_DAMAGE_REDUCTION_MULTIPLIER

local displayString = ''
local bonus, maxBonus = 0, 0

local function OnEvent(self)
	local resilience = GetCombatRating(CR_RESILIENCE_CRIT_TAKEN)
	bonus = GetCombatRatingBonus(CR_RESILIENCE_CRIT_TAKEN)
	maxBonus = GetMaxCombatRatingBonus(CR_RESILIENCE_CRIT_TAKEN)

	self.text:SetFormattedText(displayString, resilience)
end

local function OnEnter()
	DT.tooltip:ClearLines()

	DT.tooltip:AddLine(format(RESILIENCE_TOOLTIP, bonus, min(bonus * RESILIENCE_CRIT_CHANCE_TO_DAMAGE_REDUCTION_MULTIPLIER, maxBonus), bonus * RESILIENCE_CRIT_CHANCE_TO_CONSTANT_DAMAGE_REDUCTION_MULTIPLIER))

	DT.tooltip:Show()
end

local function ApplySettings(_, hex)
	displayString = strjoin('', STAT_RESILIENCE, ': ', hex, '%d|r')
end

DT:RegisterDatatext('Resilience', STAT_CATEGORY_ENHANCEMENTS, { 'COMBAT_RATING_UPDATE' }, OnEvent, nil, nil, OnEnter, nil, STAT_RESILIENCE, nil, ApplySettings)
