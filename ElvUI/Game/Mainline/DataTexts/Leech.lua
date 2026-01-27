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

local displayString, db = ''

local function OnEnter()
	DT.tooltip:ClearLines()

	local text = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_LIFESTEAL)..' '..format('%.2f%%', GetLifesteal())..FONT_COLOR_CODE_CLOSE
	local tooltip = format(CR_LIFESTEAL_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_LIFESTEAL)), GetCombatRatingBonus(CR_LIFESTEAL))

	DT.tooltip:AddDoubleLine(text, nil, 1, 1, 1)
	DT.tooltip:AddLine(tooltip, nil, nil, nil, true)
	DT.tooltip:Show()
end

local function OnEvent(self)
	local lifesteal = GetLifesteal()
	if db.NoLabel then
		self.text:SetFormattedText(displayString, lifesteal)
	else
		self.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or STAT_LIFESTEAL..': ', lifesteal)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s', hex, '%.'..db.decimalLength..'f%%|r')
end

DT:RegisterDatatext('Leech', STAT_CATEGORY_ENHANCEMENTS, {'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS'}, OnEvent, nil, nil, OnEnter, nil, STAT_LIFESTEAL, nil, ApplySettings)
