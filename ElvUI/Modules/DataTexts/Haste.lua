local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local _G = _G
local format, strjoin = format, strjoin
local GetHaste = GetHaste
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetPVPGearStatRules = GetPVPGearStatRules
local STAT_HASTE = STAT_HASTE
local CR_HASTE_MELEE = CR_HASTE_MELEE
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT
local STAT_HASTE_TOOLTIP = STAT_HASTE_TOOLTIP
local STAT_HASTE_BASE_TOOLTIP = STAT_HASTE_BASE_TOOLTIP
local RED_FONT_COLOR_CODE = RED_FONT_COLOR_CODE
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString, lastPanel = ''

local function OnEnter()
	DT.tooltip:ClearLines()

	local rating = CR_HASTE_MELEE
	local classTooltip = _G['STAT_HASTE_'..E.myclass..'_TOOLTIP']
	local haste = GetHaste()

	local hasteFormatString
	if haste < 0 and not GetPVPGearStatRules() then
		hasteFormatString = RED_FONT_COLOR_CODE..'%s'..FONT_COLOR_CODE_CLOSE
	else
		hasteFormatString = '%s'
	end

	if not classTooltip then
		classTooltip = STAT_HASTE_TOOLTIP
	end

	DT.tooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HASTE)..' '..format(hasteFormatString, format('%.2F%%', haste))..FONT_COLOR_CODE_CLOSE)
	DT.tooltip:AddLine(classTooltip..format(STAT_HASTE_BASE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(rating)), GetCombatRatingBonus(rating)))
	DT.tooltip:Show()
end

local function OnEvent(self)
	local haste = GetHaste()

	if E.global.datatexts.settings.Haste.NoLabel then
		self.text:SetFormattedText(displayString, haste)
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.Haste.Label ~= '' and E.global.datatexts.settings.Haste.Label or STAT_HASTE..': ', haste)
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.Haste.NoLabel and '' or '%s', hex, '%.'..E.global.datatexts.settings.Haste.decimalLength..'f%%|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Haste', STAT_CATEGORY_ENHANCEMENTS, {'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE', 'UNIT_SPELL_HASTE'}, OnEvent, nil, nil, OnEnter, nil, STAT_HASTE, nil, ValueColorUpdate)
