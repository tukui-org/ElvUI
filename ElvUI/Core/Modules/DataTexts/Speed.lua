local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format, strjoin = format, strjoin

local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetSpeed = GetSpeed

local CR_SPEED = CR_SPEED
local CR_SPEED_TOOLTIP = CR_SPEED_TOOLTIP
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local STAT_SPEED = STAT_SPEED

local displayString, db = ''

local function OnEnter()
	DT.tooltip:ClearLines()
	DT.tooltip:AddDoubleLine(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPEED)..' '..format('%.2f%%', GetSpeed())..FONT_COLOR_CODE_CLOSE, nil, 1, 1, 1)
	DT.tooltip:AddLine(format(CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED)), GetCombatRatingBonus(CR_SPEED)), nil, nil, nil, true)
	DT.tooltip:Show()
end

local function OnEvent(self)
	local speed = GetSpeed()
	if db.NoLabel then
		self.text:SetFormattedText(displayString, speed)
	else
		local separator = (db.LabelSeparator ~= '' and db.LabelSeparator) or DT.db.labelSeparator or ': '
		self.text:SetFormattedText(displayString, (db.Label ~= '' and db.Label or STAT_SPEED)..separator, speed)
	end
end

local function ApplySettings(self, hex)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end

	displayString = strjoin('', db.NoLabel and '' or '%s:', hex, '%.'..db.decimalLength..'f%%|r')
end

DT:RegisterDatatext('Speed', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS' }, OnEvent, nil, nil, OnEnter, nil, STAT_SPEED, nil, ApplySettings)
