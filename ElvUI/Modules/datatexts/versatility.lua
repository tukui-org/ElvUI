local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local format, join = string.format, string.join
--WoW API / Variables
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetVersatilityBonus = GetVersatilityBonus
local BreakUpLargeNumbers = BreakUpLargeNumbers
local CR_VERSATILITY_DAMAGE_DONE = CR_VERSATILITY_DAMAGE_DONE
local CR_VERSATILITY_DAMAGE_TAKEN = CR_VERSATILITY_DAMAGE_TAKEN
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local VERSATILITY_TOOLTIP_FORMAT = VERSATILITY_TOOLTIP_FORMAT
local STAT_VERSATILITY = STAT_VERSATILITY
local CR_VERSATILITY_TOOLTIP = CR_VERSATILITY_TOOLTIP

local displayModifierString = ''
local lastPanel;

local function OnEnter(self)
	DT:SetupTooltip(self)

	local text, tooltip;
	local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
	local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
	local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN);

	text = HIGHLIGHT_FONT_COLOR_CODE..format(VERSATILITY_TOOLTIP_FORMAT, STAT_VERSATILITY, versatilityDamageBonus, versatilityDamageTakenReduction)..FONT_COLOR_CODE_CLOSE
	tooltip = format(CR_VERSATILITY_TOOLTIP, versatilityDamageBonus, versatilityDamageTakenReduction, BreakUpLargeNumbers(versatility), versatilityDamageBonus, versatilityDamageTakenReduction)

	DT.tooltip:AddDoubleLine(text, nil, 1, 1, 1);
	DT.tooltip:AddLine(tooltip, nil, nil, nil, true);
	DT.tooltip:Show()
end

local function OnEvent(self)
	local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
	self.text:SetFormattedText(displayModifierString, STAT_VERSATILITY, versatility)
	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayModifierString = join("", "%s: ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Versatility', {"UNIT_STATS", "UNIT_AURA", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE", "PLAYER_DAMAGE_DONE_MODS"}, OnEvent, nil, nil, OnEnter, nil, STAT_VERSATILITY)
