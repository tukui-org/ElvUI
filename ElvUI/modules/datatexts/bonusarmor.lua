local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local select = select
local format, join = string.format, string.join
--WoW API / Variables
local UnitArmor = UnitArmor
local UnitBonusArmor = UnitBonusArmor
local PaperDollFrame_GetArmorReduction = PaperDollFrame_GetArmorReduction
local UnitLevel = UnitLevel
local GetBladedArmorEffect = GetBladedArmorEffect
local HIGHLIGHT_FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
local FONT_COLOR_CODE_CLOSE = FONT_COLOR_CODE_CLOSE
local PAPERDOLLFRAME_TOOLTIP_FORMAT = PAPERDOLLFRAME_TOOLTIP_FORMAT
local BONUS_ARMOR = BONUS_ARMOR
local STAT_ARMOR_BONUS_ARMOR_BLADED_ARMOR_TOOLTIP = STAT_ARMOR_BONUS_ARMOR_BLADED_ARMOR_TOOLTIP
local STAT_ARMOR_TOTAL_TOOLTIP = STAT_ARMOR_TOTAL_TOOLTIP
local STAT_NO_BENEFIT_TOOLTIP = STAT_NO_BENEFIT_TOOLTIP

local bonusArmorString = STAT_BONUS_ARMOR..": "
local chanceString = "%.2f%%";
local displayString = ''
local lastPanel;
local effectiveArmor, bonusArmor, isNegatedForSpec, armorReduction, hasAura, percent

local function OnEnter(self)
	DT:SetupTooltip(self)

	local text, tooltip;
	effectiveArmor = select(2, UnitArmor('player'));
	bonusArmor, isNegatedForSpec = UnitBonusArmor('player');
	armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitLevel('player'));
	hasAura, percent = GetBladedArmorEffect();

	text = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, BONUS_ARMOR).." "..format("%s", bonusArmor)..FONT_COLOR_CODE_CLOSE

	if (hasAura) then
		tooltip = format(STAT_ARMOR_BONUS_ARMOR_BLADED_ARMOR_TOOLTIP, armorReduction, (bonusArmor * (percent / 100)))
	elseif (not isNegatedForSpec) then
		tooltip = format(STAT_ARMOR_TOTAL_TOOLTIP, armorReduction)
	else
		tooltip = STAT_NO_BENEFIT_TOOLTIP
	end

	DT.tooltip:AddDoubleLine(text, nil, 1, 1, 1);
	DT.tooltip:AddLine(tooltip, nil, nil, nil, true);

	if (hasAura) or (not isNegatedForSpec) then
		DT.tooltip:AddLine(' ')
		DT.tooltip:AddLine(L["Mitigation By Level: "])

		local playerlvl = UnitLevel('player') + 3
		for i = 1, 4 do
			armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, playerlvl);
			DT.tooltip:AddDoubleLine(playerlvl,format(chanceString, armorReduction),1,1,1)
			playerlvl = playerlvl - 1
		end
		local lv = UnitLevel("target")
		if lv and lv > 0 and (lv > playerlvl + 3 or lv < playerlvl) then
			armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, lv);
			DT.tooltip:AddDoubleLine(lv, format(chanceString, armorReduction),1,1,1)
		end
	end
	DT.tooltip:Show()
end

local function OnEvent(self, event, unit)
	bonusArmor = UnitBonusArmor('player');
	self.text:SetFormattedText(displayString, bonusArmorString, bonusArmor)
	lastPanel = self
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", "%s", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc)

	name - name of the datatext (required)
	events - must be a table with string values of event names to register
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
]]


DT:RegisterDatatext('Bonus Armor', {"UNIT_STATS", "UNIT_AURA", "FORGE_MASTER_ITEM_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE", "PLAYER_DAMAGE_DONE_MODS"}, OnEvent, nil, nil, OnEnter)
