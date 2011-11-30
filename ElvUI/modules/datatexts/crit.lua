local E, L, DF = unpack(select(2, ...)); --Engine
local DT = E:GetModule('DataTexts')

local critRating
local int = 5
local displayModifierString = ''
local LastPanel;

local function OnUpdate(self, t)
	int = int - t
	if int > 0 then return end
	
	if E.role == "Caster" then
		critRating = GetSpellCritChance(1)
	else
		if E.myclass == "HUNTER" then
			critRating = GetRangedCritChance()
		else
			critRating = GetCritChance()
		end
	end
	self.text:SetFormattedText(displayModifierString, CRIT_ABBR, critRating)
	
	int = 2
	LastPanel = self
end

local function ValueColorUpdate(hex, r, g, b)
	displayModifierString = string.join("", "%s: ", hex, "%.2f%%|r")
	
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
DT:RegisterDatatext('Crit Chance', nil, nil, OnUpdate, nil, nil)

