local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format, strjoin = format, strjoin
local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetVersatilityBonus = GetVersatilityBonus
local CR_VERSATILITY_DAMAGE_DONE = CR_VERSATILITY_DAMAGE_DONE
local CR_VERSATILITY_DAMAGE_TAKEN = CR_VERSATILITY_DAMAGE_TAKEN
local CR_VERSATILITY_TOOLTIP = CR_VERSATILITY_TOOLTIP
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local STAT_VERSATILITY = STAT_VERSATILITY
local VERSATILITY_TOOLTIP_FORMAT = VERSATILITY_TOOLTIP_FORMAT
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString, db = ''

local function OnEnter()
	DT.tooltip:ClearLines()

	local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)
	local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
	local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN)

	local text = HIGHLIGHT_FONT_COLOR_CODE..format(VERSATILITY_TOOLTIP_FORMAT, STAT_VERSATILITY, versatilityDamageBonus, versatilityDamageTakenReduction)..FONT_COLOR_CODE_CLOSE
	local tooltip = format(CR_VERSATILITY_TOOLTIP, versatilityDamageBonus, versatilityDamageTakenReduction, BreakUpLargeNumbers(versatility), versatilityDamageBonus, versatilityDamageTakenReduction)

	DT.tooltip:AddDoubleLine(text, nil, 1, 1, 1)
	DT.tooltip:AddLine(tooltip, nil, nil, nil, true)
	DT.tooltip:Show()
end

local function OnEvent(self)
	local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
	if db.NoLabel then
		self.text:SetFormattedText(displayString, versatility)
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or STAT_VERSATILITY, versatility)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s: ', hex, '%.'..db.decimalLength..'f%%|r')
end

DT:RegisterDatatext('Versatility', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE', 'PLAYER_DAMAGE_DONE_MODS' }, OnEvent, nil, nil, OnEnter, nil, STAT_VERSATILITY, nil, ApplySettings)
