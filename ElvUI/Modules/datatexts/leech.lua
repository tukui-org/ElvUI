local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local format, join = string.format, string.join
--WoW API / Variables
local GetLifesteal = GetLifesteal
local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT
local STAT_LIFESTEAL = STAT_LIFESTEAL
local CR_LIFESTEAL_TOOLTIP = CR_LIFESTEAL_TOOLTIP
local CR_LIFESTEAL = CR_LIFESTEAL

local lifesteal
local displayModifierString = ''
local lastPanel;

local function OnEnter(self)
	DT:SetupTooltip(self)

	local text, tooltip;
	text = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_LIFESTEAL).." "..format("%.2F%%", GetLifesteal())..FONT_COLOR_CODE_CLOSE
	tooltip = format(CR_LIFESTEAL_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_LIFESTEAL)), GetCombatRatingBonus(CR_LIFESTEAL))

	DT.tooltip:AddDoubleLine(text, nil, 1, 1, 1);
	DT.tooltip:AddLine(tooltip, nil, nil, nil, true);
	DT.tooltip:Show()
end

local function OnEvent(self)
	lifesteal = GetLifesteal()
	self.text:SetFormattedText(displayModifierString, STAT_LIFESTEAL, lifesteal)
	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayModifierString = join("", "%s: ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Leech', {"UNIT_STATS", "UNIT_AURA", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE", "PLAYER_DAMAGE_DONE_MODS"}, OnEvent, nil, nil, OnEnter, nil, STAT_LIFESTEAL)
