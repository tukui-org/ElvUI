local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format, strjoin = format, strjoin

local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetLifesteal = GetLifesteal

local CR_LIFESTEAL = CR_LIFESTEAL
local CR_LIFESTEAL_TOOLTIP = CR_LIFESTEAL_TOOLTIP
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local STAT_LIFESTEAL = STAT_LIFESTEAL

local displayString = ''

local function OnEnter()
	DT.tooltip:ClearLines()

	local text = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_LIFESTEAL)..' '..format('%.2F%%', GetLifesteal())..FONT_COLOR_CODE_CLOSE
	local tooltip = format(CR_LIFESTEAL_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_LIFESTEAL)), GetCombatRatingBonus(CR_LIFESTEAL))

	DT.tooltip:AddDoubleLine(text, nil, 1, 1, 1)
	DT.tooltip:AddLine(tooltip, nil, nil, nil, true)
	DT.tooltip:Show()
end

local function OnEvent(self)
	local lifesteal = GetLifesteal()
	self.text:SetFormattedText(displayString, STAT_LIFESTEAL, lifesteal)
end

local function ApplySettings(_, hex)
	displayString = strjoin('', '%s: ', hex, '%.2f%%|r')
end

DT:RegisterDatatext('Leech', STAT_CATEGORY_ENHANCEMENTS, {'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS'}, OnEvent, nil, nil, OnEnter, nil, STAT_LIFESTEAL, nil, ApplySettings)
