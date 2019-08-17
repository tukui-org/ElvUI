local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Lua functions
local format, strjoin = format, strjoin
--WoW API / Variables
local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetCritChance = GetCritChance
local GetRangedCritChance = GetRangedCritChance
local GetSpellCritChance = GetSpellCritChance
local CR_CRIT_MELEE = CR_CRIT_MELEE
local CR_CRIT_MELEE_TOOLTIP = CR_CRIT_MELEE_TOOLTIP
local CR_CRIT_RANGED = CR_CRIT_RANGED
local CR_CRIT_RANGED_TOOLTIP = CR_CRIT_RANGED_TOOLTIP
local CR_CRIT_SPELL = CR_CRIT_SPELL
local CR_CRIT_SPELL_TOOLTIP = CR_CRIT_SPELL_TOOLTIP
local CRIT_ABBR = CRIT_ABBR
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local MELEE_CRIT_CHANCE = MELEE_CRIT_CHANCE
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT
local RANGED_CRIT_CHANCE = RANGED_CRIT_CHANCE
local SPELL_CRIT_CHANCE = SPELL_CRIT_CHANCE

local displayString, lastPanel = ''

local function OnEnter(self)
	DT:SetupTooltip(self)

	local text, tooltip
	if E.role == "Caster" then
		text = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, SPELL_CRIT_CHANCE).." "..format("%.2F%%", GetSpellCritChance(1))..FONT_COLOR_CODE_CLOSE
		tooltip = format(CR_CRIT_SPELL_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_CRIT_SPELL)), GetCombatRatingBonus(CR_CRIT_SPELL))
	else
		if E.myclass == "HUNTER" then
			text = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, RANGED_CRIT_CHANCE).." "..format("%.2F%%", GetRangedCritChance())..FONT_COLOR_CODE_CLOSE
			tooltip = format(CR_CRIT_RANGED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_CRIT_RANGED)), GetCombatRatingBonus(CR_CRIT_RANGED))
		else
			text = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, MELEE_CRIT_CHANCE).." "..format("%.2F%%", GetCritChance())..FONT_COLOR_CODE_CLOSE
			tooltip = format(CR_CRIT_MELEE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_CRIT_MELEE)), GetCombatRatingBonus(CR_CRIT_MELEE))
		end
	end

	DT.tooltip:AddDoubleLine(text, nil, 1, 1, 1)
	DT.tooltip:AddLine(tooltip, nil, nil, nil, true)
	DT.tooltip:Show()
end

local function OnEvent(self)
	local critRating
	if E.role == "Caster" then
		critRating = GetSpellCritChance(1)
	else
		if E.myclass == "HUNTER" then
			critRating = GetRangedCritChance()
		else
			critRating = GetCritChance()
		end
	end

	self.text:SetFormattedText(displayString, CRIT_ABBR, critRating)

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin("", "%s: ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Crit Chance', {"UNIT_STATS", "UNIT_AURA", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE", "PLAYER_DAMAGE_DONE_MODS"}, OnEvent, nil, nil, OnEnter, nil, STAT_CRITICAL_STRIKE)
