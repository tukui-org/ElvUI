local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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
local STAT_SPEED = STAT_SPEED
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString, lastPanel = ''

local function OnEnter()
	DT.tooltip:ClearLines()

	local text = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPEED)..' '..format('%.2F%%', GetSpeed())..FONT_COLOR_CODE_CLOSE
	local tooltip = format(CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED)), GetCombatRatingBonus(CR_SPEED))

	DT.tooltip:AddDoubleLine(text, nil, 1, 1, 1)
	DT.tooltip:AddLine(tooltip, nil, nil, nil, true)
	DT.tooltip:Show()
end

local function OnEvent(self)
	local speed = GetSpeed()
	if E.global.datatexts.settings.Speed.NoLabel then
		self.text:SetFormattedText(displayString, speed)
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.Speed.Label ~= '' and E.global.datatexts.settings.Speed.Label or STAT_SPEED, speed)
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.Speed.NoLabel and '' or '%s:', hex, '%.'..E.global.datatexts.settings.Speed.decimalLength..'f%%|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Speed', STAT_CATEGORY_ENHANCEMENTS, {"UNIT_STATS", "UNIT_AURA", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE", "PLAYER_DAMAGE_DONE_MODS"}, OnEvent, nil, nil, OnEnter, nil, STAT_SPEED, nil, ValueColorUpdate)
