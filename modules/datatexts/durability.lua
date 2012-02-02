local E, L, DF = unpack(select(2, ...)); --Engine
local DT = E:GetModule('DataTexts')

local displayString = ""
local tooltipString = "%d%%"
local total, totalDurability, totalPerc = 0, 0, 0
local current, max, lastPanel
local invDurability = {}
local slots = {
	["RangedSlot"] = L['Ranged'],
	["SecondaryHandSlot"] = L['Offhand'],
	["MainHandSlot"] = L['Main Hand'],
	["FeetSlot"] = L['Feet'],
	["LegsSlot"] = L['Legs'],
	["HandsSlot"] = L['Hands'],
	["WristSlot"] = L['Wrist'],
	["WaistSlot"] = L['Waist'],
	["ChestSlot"] = L['Chest'],
	["ShoulderSlot"] = L['Shoulder'],
	["HeadSlot"] = L['Head'],
}

local function OnEvent(self, event, ...)
	lastPanel = self
	total = 0
	totalDurability = 0
	totalPerc = 0
	
	for index, value in pairs(slots) do
		local slot = GetInventorySlotInfo(index)
		current, max = GetInventoryItemDurability(slot)
		
		if current then
			totalDurability = totalDurability + current
			invDurability[value] = (current/max)*100
			totalPerc = totalPerc + (current/max)*100
			total = total + 1
		end
	end
	
	if total > 0 then
		self.text:SetFormattedText(displayString, totalPerc/total)
	end
end

local function Click()
	ToggleCharacter("PaperDollFrame")
end

local function OnEnter(self)
	DT:SetupTooltip(self)
	
	for slot, durability in pairs(invDurability) do
		GameTooltip:AddDoubleLine(slot, format(tooltipString, durability), 1, 1, 1, E:ColorGradient(durability * 0.01, 1, 0, 0, 1, 1, 0, 0, 1, 0))
	end
		
	GameTooltip:Show()
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = string.join("", DURABILITY, ": ", hex, "%d%%|r")
	
	if lastPanel ~= nil then
		OnEvent(lastPanel, 'ELVUI_COLOR_UPDATE')
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
DT:RegisterDatatext('Durability', {'PLAYER_ENTERING_WORLD', "UPDATE_INVENTORY_DURABILITY", "MERCHANT_SHOW"}, OnEvent, nil, Click, OnEnter)

