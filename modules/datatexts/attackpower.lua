local E, L, DF = unpack(select(2, ...)); --Engine
local DT = E:GetModule('DataTexts')

local base, posBuff, negBuff, effective, Rbase, RposBuff, RnegBuff, Reffective, pwr
local displayModifierString = ''
local lastPanel;

local function OnEvent(self, event, unit)	
	if event == "UNIT_AURA" and unit ~= 'player' then return end
	if E.myclass == "HUNTER" then
		Rbase, RposBuff, RnegBuff = UnitRangedAttackPower("player");
		Reffective = Rbase + RposBuff + RnegBuff;
		pwr = Reffective
	else
		base, posBuff, negBuff = UnitAttackPower("player");
		effective = base + posBuff + negBuff;	
		pwr = effective
	end
	
	self.text:SetFormattedText(displayNumberString, L['AP'], pwr) 	
	lastPanel = self
end

local function ValueColorUpdate(hex, r, g, b)
	displayNumberString = string.join("", "%s: ", hex, "%d|r")
	
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
DT:RegisterDatatext('Attack Power', {"UNIT_STATS", "UNIT_AURA", "FORGE_MASTER_ITEM_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE"}, OnEvent)

