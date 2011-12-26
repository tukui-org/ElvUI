local E, L, DF = unpack(ElvUI); --Engine
local DT = E:GetModule('DataTexts')

local events = {SPELL_HEAL = true, SPELL_PERIODIC_HEAL = true}
local playerID, petID
local healTotal, lastHealAmount = 0, 0
local combatTime = 0
local timeStamp = 0
local lastSegment = 0
local lastPanel
local displayString = '';
local max_single_hps = 0
local max_rhps = 0
local max_who = ' '
local _hex

local function Reset()
	timeStamp = 0
	combatTime = 0
	healTotal = 0
	lastHealAmount = 0
	max_single_hps = 0
	max_rhps = 0
	max_who = ' '
end	

-- add comma to separate thousands
-- 
function comma_value(amount)
	local formatted = string.format("%.1f",amount)
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end


local function GetRHPS(self)
	local HPS
	if healTotal == 0 or combatTime == 0 then
		HPS = 0.0
	else
		HPS = healTotal / combatTime
	end
	
	if HPS > max_rhps then
		max_rhps = HPS
	end
	self.text:SetFormattedText(displayString, 'RHPS: ', comma_value(HPS))
end

local function OnEvent(self, event, ...)
	lastPanel = self
	
	if not _hex then return end
	if not event then return end
	
	if event == 'PLAYER_ENTERING_WORLD' then
		playerID = UnitGUID('player')
	elseif event == 'PLAYER_REGEN_DISABLED' or event == "PLAYER_LEAVE_COMBAT" then
		local now = time()
--		if now - lastSegment > 60 then
--			Reset()
--		end
		lastSegment = now
	elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		if not events[select(2, ...)] then return end
		
		local id = select(4, ...)
		local name = select(5, ...)
		local target = select(9, ...)

		local inInstance, instanceType = IsInInstance()
		if true then -- instanceType == 'party' or instanceType == 'raid' then
			if UnitInParty(name) or UnitInRaid(name) and inInstance then 

				if timeStamp == 0 then timeStamp = select(1, ...) end
				local overHeal = select(16, ...)
				lastSegment = timeStamp
				combatTime = select(1, ...) - timeStamp
				lastHealAmount = select(15, ...)
				healTotal = healTotal + math.max(0, lastHealAmount - overHeal)
				
				if lastHealAmount > max_single_hps then
					max_single_hps = lastHealAmount
					max_who = ' |rName: '.._hex..name..' |rHeal: '.._hex..select(13, ...)..' |rTarget: '.._hex..target
				end
				GetRHPS(self)				
			end
		end
	elseif event == UNIT_PET then
		petID = UnitGUID("pet")
	end
end

local function OnClick(self)
	Reset()
	GetRHPS(self)
end

local function OnEnter(self)
	DT:SetupTooltip(self)
	
	GameTooltip:AddDoubleLine('"Raid Healing Done:')
	GameTooltip:AddDoubleLine(' ')
	GameTooltip:AddDoubleLine('|rMax Raid HPS: '.._hex..comma_value(max_rhps) )
	GameTooltip:AddDoubleLine(tostring("Max Single: ".._hex..comma_value(max_single_hps)..max_who.."|r"))
	GameTooltip:Show()
end


local function ValueColorUpdate(hex, r, g, b)
	_hex = hex
	displayString = string.join("", "%s", hex, "%s|r", hex)

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true;

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc)

	name - name of the datatext (required)
	events - must be a table with string values of event names to register
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
]]
DT:RegisterDatatext('Raid-HPS', {'PLAYER_ENTERING_WORLD', 'COMBAT_LOG_EVENT_UNFILTERED', "PLAYER_LEAVE_COMBAT", 'PLAYER_REGEN_DISABLED', 'UNIT_PET', "ZONE_CHANGED", 'ZONE_CHANGED_NEW_AREA', "ZONE_CHANGED_INDOORS"}, OnEvent, nil, OnClick, OnEnter)
