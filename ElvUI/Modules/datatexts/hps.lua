local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local time = time
local max = math.max
local join = string.join
--WoW API / Variables
local UnitGUID = UnitGUID
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo

local events = {SPELL_HEAL = true, SPELL_PERIODIC_HEAL = true}
local playerID, petID
local healTotal = 0
local combatTime = 0
local timeStamp = 0
local lastSegment = 0
local lastPanel
local displayString = '';

local function Reset()
	timeStamp = 0
	combatTime = 0
	healTotal = 0
end

local function GetHPS(self)
	local hps
	if healTotal == 0 or combatTime == 0 then
		hps = 0
	else
		hps = healTotal / combatTime
	end
	self.text:SetFormattedText(displayString, L["HPS"], E:ShortValue(hps))
end

local function OnEvent(self, event)
	lastPanel = self

	if event == 'PLAYER_ENTERING_WORLD' then
		playerID = E.myguid
	elseif event == 'PLAYER_REGEN_DISABLED' or event == "PLAYER_LEAVE_COMBAT" then
		local now = time()
		if now - lastSegment > 20 then
			Reset()
		end
		lastSegment = now
	elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		local timestamp, Event, _, sourceGUID, _, _, _, _, _, _, _, _, _, _, lastHealAmount, overHeal = CombatLogGetCurrentEventInfo()
		if not events[Event] then return end

		if sourceGUID == playerID or sourceGUID == petID then
			if timeStamp == 0 then timeStamp = timestamp end
			lastSegment = timeStamp
			combatTime = timestamp - timeStamp
			healTotal = healTotal + max(0, lastHealAmount - overHeal)
		end
	elseif event == "UNIT_PET" then
		petID = UnitGUID("pet")
	end

	GetHPS(self)
end

local function OnClick(self)
	Reset()
	GetHPS(self)
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%s")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true;

DT:RegisterDatatext('HPS', {'PLAYER_ENTERING_WORLD', 'COMBAT_LOG_EVENT_UNFILTERED', "PLAYER_LEAVE_COMBAT", 'PLAYER_REGEN_DISABLED', 'UNIT_PET'}, OnEvent, nil, OnClick, nil, nil, L["HPS"])
