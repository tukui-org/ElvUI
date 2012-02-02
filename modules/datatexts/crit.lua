local E, L, DF = unpack(select(2, ...)); --Engine
local DT = E:GetModule('DataTexts')

local critRating
local displayModifierString = ''
local lastPanel;

local function OnEvent(self, event, unit)
	if event == "UNIT_AURA" and unit ~= 'player' then return end
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

	lastPanel = self
end

local function ValueColorUpdate(hex, r, g, b)
	displayModifierString = string.join("", "%s: ", hex, "%.2f%%|r")
	
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
DT:RegisterDatatext('Crit Chance', {"UNIT_STATS", "UNIT_AURA", "FORGE_MASTER_ITEM_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE"}, OnEvent)

