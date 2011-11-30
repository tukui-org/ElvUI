local E, L, DF = unpack(select(2, ...)); --Engine
local DT = E:GetModule('DataTexts')

local base, posBuff, negBuff, effective, Rbase, RposBuff, RnegBuff, Reffective, pwr
local int = 5
local displayModifierString = ''
local LastPanel;

local function OnUpdate(self, t)
	int = int - t
	if int > 0 then return end
	
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
	int = 2
	LastPanel = self
end

local function ValueColorUpdate(hex, r, g, b)
	displayNumberString = string.join("", "%s: ", hex, "%d|r")
	
	if LastPanel ~= nil then
		OnUpdate(LastPanel, 200000)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc)
	
	name - name of the datatext (required)
	events - must be a table with string values of event names to register 
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
]]
DT:RegisterDatatext('Attack Power', nil, nil, OnUpdate, nil, nil)

