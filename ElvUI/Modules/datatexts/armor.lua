local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
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
local effectiveArmor, _

local function OnEvent(self)
	_, effectiveArmor = UnitArmor("player");

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

local function ValueColorUpdate(hex)
	displayString = join("", "%s", hex, "%d|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Armor', {"UNIT_STATS", "UNIT_RESISTANCES", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE"}, OnEvent, nil, nil, OnEnter, nil, ARMOR)
