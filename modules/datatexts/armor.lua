local E, L, DF = unpack(select(2, ...)); --Engine
local DT = E:GetModule('DataTexts')

local lastPanel
local armorString = ARMOR..": "
local chanceString = "%.2f%%";
local format = string.format
local displayString = ''; 
local baseArmor, effectiveArmor, armor, posBuff, negBuff
	
local function CalculateMitigation(level, effective)
	local mitigation
	
	if not effective then
		_, effective, _, _, _ = UnitArmor("player")
	end
	
	if level < 60 then
		mitigation = (effective/(effective + 400 + (85 * level)));
	else
		mitigation = (effective/(effective + (467.5 * level - 22167.5)));
	end
	if mitigation > .75 then
		mitigation = .75
	end
	return mitigation
end

local function OnEvent(self, event, unit)
	if event == "UNIT_RESISTANCES" and unit ~= 'player' then return end
	lastPanel = self
	
	baseArmor, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");

	self.text:SetFormattedText(displayString, armorString, effectiveArmor)
	
	int = 2
end


local function OnEnter(self)
	DT:SetupTooltip(self)
	
	GameTooltip:AddLine(L['Mitigation By Level: '])
	GameTooltip:AddLine(' ')
	
	local playerlvl = UnitLevel('player') + 3
	for i = 1, 4 do
		GameTooltip:AddDoubleLine(playerlvl,format(chanceString, CalculateMitigation(playerlvl, effectiveArmor) * 100),1,1,1)
		playerlvl = playerlvl - 1
	end
	local lv = UnitLevel("target")
	if lv and lv > 0 and (lv > playerlvl + 3 or lv < playerlvl) then
		GameTooltip:AddDoubleLine(lv, format(chanceString, CalculateMitigation(lv, effectiveArmor) * 100),1,1,1)
	end	
		
	GameTooltip:Show()
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = string.join("", "%s", hex, "%d|r")
	
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

