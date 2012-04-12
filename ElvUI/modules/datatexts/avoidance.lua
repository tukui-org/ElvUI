local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--[[This file is a blank datatext example template, this file will not be loaded.]]
local displayString, lastPanel
local format = string.format
local targetlv, playerlv
local basemisschance, leveldifference, dodge, parry, block, avoidance, unhittable
local chanceString = "%.2f%%"
local modifierString = string.join("", "%d (+", chanceString, ")")

local function OnEvent(self, event, unit)
	if event == "UNIT_AURA" and unit ~= 'player' then return end
	targetlv, playerlv = UnitLevel("target"), UnitLevel("player")
			
	-- the 5 is for base miss chance
	if targetlv == -1 then
		basemisschance = (5 - (3*.2))
		leveldifference = 3
	elseif targetlv > playerlv then
		basemisschance = (5 - ((targetlv - playerlv)*.2))
		leveldifference = (targetlv - playerlv)
	elseif targetlv < playerlv and targetlv > 0 then
		basemisschance = (5 + ((playerlv - targetlv)*.2))
		leveldifference = (targetlv - playerlv)
	else
		basemisschance = 5
		leveldifference = 0
	end
	
	if select(2, UnitRace("player")) == "NightElf" then basemisschance = basemisschance + 2 end
	
	if leveldifference >= 0 then
		dodge = (GetDodgeChance()-leveldifference*.2)
		parry = (GetParryChance()-leveldifference*.2)
		block = (GetBlockChance()-leveldifference*.2)
	else
		dodge = (GetDodgeChance()+abs(leveldifference*.2))
		parry = (GetParryChance()+abs(leveldifference*.2))
		block = (GetBlockChance()+abs(leveldifference*.2))
	end
	
	if dodge <= 0 then dodge = 0 end
	if parry <= 0 then parry = 0 end
	if block <= 0 then block = 0 end
	
	if E.myclass == "DRUID" then
		parry = 0
		block = 0
	elseif E.myclass == "DEATHKNIGHT" then
		block = 0
	end
	avoidance = (dodge+parry+block+basemisschance)
	unhittable = avoidance - 102.4
	
	self.text:SetFormattedText(displayString, L['AVD: '], avoidance)

	
	lastPanel = self
end

local function OnEnter(self)
	DT:SetupTooltip(self)
	
	if targetlv > 1 then
		GameTooltip:AddDoubleLine(L["Avoidance Breakdown"], string.join("", " (", L['lvl'], " ", targetlv, ")"))
	elseif targetlv == -1 then
		GameTooltip:AddDoubleLine(L["Avoidance Breakdown"], string.join("", " (", BOSS, ")"))
	else
		GameTooltip:AddDoubleLine(L["Avoidance Breakdown"], string.join("", " (", L['lvl'], " ", playerlv, ")"))
	end
	GameTooltip:AddLine' '
	GameTooltip:AddDoubleLine(DODGE_CHANCE, format(chanceString, dodge),1,1,1)
	GameTooltip:AddDoubleLine(PARRY_CHANCE, format(chanceString, parry),1,1,1)
	GameTooltip:AddDoubleLine(BLOCK_CHANCE, format(chanceString, block),1,1,1)
	GameTooltip:AddDoubleLine(MISS_CHANCE, format(chanceString, basemisschance),1,1,1)
	GameTooltip:AddLine' '
	
	
	if unhittable > 0 then
		GameTooltip:AddDoubleLine(L['Unhittable:'], '+'..format(chanceString, unhittable), 1, 1, 1, 0, 1, 0)
	else
		GameTooltip:AddDoubleLine(L['Unhittable:'], format(chanceString, unhittable), 1, 1, 1, 1, 0, 0)
	end
	GameTooltip:Show()
end


local function ValueColorUpdate(hex, r, g, b)
	displayString = string.join("", "%s", hex, "%.2f%%|r")
	
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
DT:RegisterDatatext('Avoidance', {"UNIT_TARGET", "UNIT_STATS", "UNIT_AURA", "FORGE_MASTER_ITEM_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE"}, OnEvent, nil, nil, OnEnter)

