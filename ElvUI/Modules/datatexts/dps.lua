local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local time = time
local select = select
local join = string.join
--WoW API / Variables
local UnitGUID = UnitGUID

local events = {SWING_DAMAGE = true, RANGE_DAMAGE = true, SPELL_DAMAGE = true, SPELL_PERIODIC_DAMAGE = true, DAMAGE_SHIELD = true, DAMAGE_SPLIT = true, SPELL_EXTRA_ATTACKS = true}
local playerID, petID
local DMGTotal, lastDMGAmount = 0, 0
local combatTime = 0
local timeStamp = 0
local lastSegment = 0
local lastPanel
local displayString = '';

local function Reset()
	timeStamp = 0
	combatTime = 0
	DMGTotal = 0
	lastDMGAmount = 0
end

local function GetDPS(self)
	local DPS
	if DMGTotal == 0 or combatTime == 0 then
		DPS = "0.0"
	else
		DPS = (DMGTotal) / (combatTime)
	end
	self.text:SetFormattedText(displayString, L["DPS"], DPS)
end

local function OnEvent(self, event, ...)
	lastPanel = self

	if event == "PLAYER_ENTERING_WORLD" then
		playerID = UnitGUID('player')
	elseif event == 'PLAYER_REGEN_DISABLED' or event == "PLAYER_LEAVE_COMBAT" then
		local now = time()
		if now - lastSegment > 20 then --time since the last segment
			Reset()
		end
		lastSegment = now
	elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		if not events[select(2, ...)] then return end

		-- only use events from the player
		local id = select(4, ...)

		if id == playerID or id == petID then
			if timeStamp == 0 then timeStamp = select(1, ...) end
			lastSegment = timeStamp
			combatTime = select(1, ...) - timeStamp
			if select(2, ...) == "SWING_DAMAGE" then
				lastDMGAmount = select(12, ...)
			else
				lastDMGAmount = select(15, ...)
			end

			DMGTotal = DMGTotal + lastDMGAmount
		end
	elseif event == "UNIT_PET" then
		petID = UnitGUID("pet")
	end

	GetDPS(self)
end

local function OnClick(self)
	Reset()
	GetDPS(self)
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", "%s: ", hex, "%.1f|r")

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
DT:RegisterDatatext('DPS', {'PLAYER_ENTERING_WORLD', 'COMBAT_LOG_EVENT_UNFILTERED', "PLAYER_LEAVE_COMBAT", 'PLAYER_REGEN_DISABLED', 'UNIT_PET'}, OnEvent, nil, OnClick)
