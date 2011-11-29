local E, L, DF = unpack(select(2, ...)); --Engine
local DT = E:GetModule('DataTexts')

local spellpwr, healpwr
local int = 5
local displayModifierString = ''
local LastPanel;

local function OnUpdate(self, t)
	int = int - t
	if int > 0 then return end
	
	spellpwr = GetSpellBonusDamage(7)
	healpwr = GetSpellBonusHealing()
	
	if healpwr > spellpwr then
		self.text:SetFormattedText(displayNumberString, L['HP'], healpwr)
	else
		self.text:SetFormattedText(displayNumberString, L['SP'], spellpwr)
	end

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
DT:RegisterDatatext('Spell/Heal Power', nil, nil, OnUpdate, nil, nil)

