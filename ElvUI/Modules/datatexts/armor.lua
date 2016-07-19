local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local format = string.format
local join = string.join
--WoW API / Variables
local UnitArmor = UnitArmor
local UnitLevel = UnitLevel
local PaperDollFrame_GetArmorReduction = PaperDollFrame_GetArmorReduction

local lastPanel
local armorString = ARMOR..": "
local chanceString = "%.2f%%";
local displayString = '';
local baseArmor, effectiveArmor, armor, posBuff, negBuff

local function OnEvent(self, event, unit)
	baseArmor, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");

	self.text:SetFormattedText(displayString, armorString, effectiveArmor)
	lastPanel = self
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	DT.tooltip:AddLine(L["Mitigation By Level: "])
	DT.tooltip:AddLine(' ')

	local playerlvl = UnitLevel('player') + 3
	for i = 1, 4 do
		local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, playerlvl);
		DT.tooltip:AddDoubleLine(playerlvl,format(chanceString, armorReduction),1,1,1)
		playerlvl = playerlvl - 1
	end
	local lv = UnitLevel("target")
	if lv and lv > 0 and (lv > playerlvl + 3 or lv < playerlvl) then
		local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, lv);
		DT.tooltip:AddDoubleLine(lv, format(chanceString, armorReduction),1,1,1)
	end

	DT.tooltip:Show()
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
DT:RegisterDatatext('Armor', {"UNIT_STATS", "UNIT_RESISTANCES", "FORGE_MASTER_ITEM_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE"}, OnEvent, nil, nil, OnEnter)

