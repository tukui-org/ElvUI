local E, L, DF = unpack(select(2, ...)); --Engine
local DT = E:GetModule('DataTexts')

local LastPanel
local armorString = ARMOR..": "
local chanceString = "%.2f%%";
local format = string.format
local displayString = ''; 
local baseArmor, effectiveArmor, armor, posBuff, negBuff
local int = 5	

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

local function Update(self, t)
	int = int - t
	
	if int > 0 then return end
	
	LastPanel = self
	
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
	
	if LastPanel ~= nil then
		Update(LastPanel, 200000)
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
DT:RegisterDatatext('Armor', nil, nil, Update, nil, OnEnter)

