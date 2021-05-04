local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local time, max, strjoin = time, max, strjoin
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local UnitGUID = UnitGUID

local timeStamp, combatTime, healTotal = 0, 0, 0
local lastSegment, petGUID = 0
local displayString, lastPanel = ''
local events = {SPELL_HEAL = true, SPELL_PERIODIC_HEAL = true}

local function Reset()
	timeStamp, combatTime, healTotal = 0, 0, 0
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

	if event == 'UNIT_PET' then
		petGUID = UnitGUID('pet')
	elseif event == 'PLAYER_REGEN_DISABLED' or event == 'PLAYER_LEAVE_COMBAT' then
		local now = time()
		if now - lastSegment > 20 then
			Reset()
		end
		lastSegment = now
	elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		local timestamp, Event, _, sourceGUID, _, _, _, _, _, _, _, _, _, _, lastHealAmount, overHeal = CombatLogGetCurrentEventInfo()
		if not events[Event] then return end

		if sourceGUID == E.myguid or sourceGUID == petGUID then
			if timeStamp == 0 then timeStamp = timestamp end
			lastSegment = timeStamp
			combatTime = timestamp - timeStamp
			healTotal = healTotal + max(0, lastHealAmount - overHeal)
		end
	end

	GetHPS(self)
end

local function OnClick(self)
	Reset()
	GetHPS(self)
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', '%s: ', hex, '%s')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('HPS', nil, {'UNIT_PET', 'COMBAT_LOG_EVENT_UNFILTERED', 'PLAYER_LEAVE_COMBAT', 'PLAYER_REGEN_DISABLED'}, OnEvent, nil, OnClick, nil, nil, L["HPS"], nil, ValueColorUpdate)
