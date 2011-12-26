local E, L, DF = unpack(ElvUI); --Engine
local DT = E:GetModule('DataTexts')

local events = {SWING_DAMAGE = true, RANGE_DAMAGE = true, SPELL_DAMAGE = true, SPELL_PERIODIC_DAMAGE = true, DAMAGE_SHIELD = true, DAMAGE_SPLIT = true, SPELL_EXTRA_ATTACKS = true}
local playerID, petID
local DMGTotal, lastDMGAmount = 0, 0
local combatTime = 0
local timeStamp = 0
local lastSegment = 0
local lastPanel
local displayString = '';
local max_single_dmg = 0
local max_rdtps = 0
local max_who = ' '
local _hex

local function Reset()
	timeStamp = 0
	combatTime = 0
	DMGTotal = 0
	lastDMGAmount = 0
	max_single_dmg = 0
	max_rdtps = 0
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

local function GetDTPS(self)
	local DTPS
	if DMGTotal == 0 or combatTime == 0 then
		DTPS = 0.0
	else
		DTPS = (DMGTotal) / (combatTime)
	end

	if DTPS > max_rdtps then
		max_rdtps = DTPS
	end
	self.text:SetFormattedText(displayString, 'RDTPS: ', comma_value(DTPS))
end

local function OnEvent(self, event, ...)
	lastPanel = self
	local dmg_type
	
	if not _hex then return end
	if not event then return end
	
	if event == "PLAYER_ENTERING_WORLD" then
		playerID = UnitGUID('player')
		self.text:SetFormattedText('No Instance')
	elseif event == 'PLAYER_REGEN_DISABLED' or event == "PLAYER_LEAVE_COMBAT" then
		local now = time()
		if now - lastSegment > 60 then --time since the last segment
			Reset()
		end
		lastSegment = now
	elseif event:match("^ZONE_.*") then	
		local inInstance, instanceType = IsInInstance()
		if not inInstance and (instanceType == 'none' or instanceType == 'pvp' or instanceType == 'arena') then 
			self.text:SetFormattedText('No Instance')
		else
			GetDTPS(self)
		end
	elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		if not events[select(2, ...)] then return end

		-- only use events from the party
		local id = select(4, ...)
		local name = select(5, ...)


		local inInstance, instanceType = IsInInstance()
		if UnitInParty(name) and inInstance and not(instanceType == 'none' or instanceType == 'pvp' or instanceType == 'arena') then 
		-- if UnitInParty(name) or id == petID then
			if timeStamp == 0 then timeStamp = select(1, ...) end
			lastSegment = timeStamp
			combatTime = select(1, ...) - timeStamp
			if select(2, ...) == "SWING_DAMAGE" then
				lastDMGAmount = select(12, ...)
				dmg_type = ' |rSpell/Ability: '.._hex..' Melee'
			else
				lastDMGAmount = select(15, ...)
				dmg_type = ' |rSpell/Ability: '.._hex..select(13, ...)
			end

			if lastDMGAmount > max_single_dmg then
				max_single_dmg = lastDMGAmount
				max_who = ' |rName: '.._hex..name..dmg_type
			end
			
			DMGTotal = DMGTotal + lastDMGAmount
			GetDTPS(self)
		else
			self.text:SetFormattedText('No Instance')
		end
	elseif event == UNIT_PET then
		petID = UnitGUID("pet")
	end
	
	
end

local function OnClick(self)
	Reset()
	local inInstance, instanceType = IsInInstance()
	if not inInstance and (instanceType == 'none' or instanceType == 'pvp' or instanceType == 'arena') then 
		self.text:SetFormattedText('No Instance')
	else
		GetDTPS(self)
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)
	
	GameTooltip:AddDoubleLine('"Raid Damage Taken:')
	GameTooltip:AddDoubleLine(' ')
	GameTooltip:AddDoubleLine(tostring("Max Single: ".._hex..comma_value(max_single_dmg)..max_who.."|r"))
	GameTooltip:AddDoubleLine('|rMax Raid DTPS: '.._hex..comma_value(max_rdtps) )
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
DT:RegisterDatatext('Raid-Damage Taken', {'PLAYER_ENTERING_WORLD', 'COMBAT_LOG_EVENT_UNFILTERED', "PLAYER_LEAVE_COMBAT", 'PLAYER_REGEN_DISABLED', 'UNIT_PET', "ZONE_CHANGED", 'ZONE_CHANGED_NEW_AREA', "ZONE_CHANGED_INDOORS"}, OnEvent, nil, OnClick, OnEnter)
