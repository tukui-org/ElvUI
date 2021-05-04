local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local time, max, strjoin = time, max, strjoin
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local UnitGUID = UnitGUID

local lastSegment, petGUID = 0
local timeStamp, combatTime, DMGTotal, lastDMGAmount = 0, 0, 0, 0
local displayString, lastPanel = ''
local events = {
	SWING_DAMAGE = true,
	RANGE_DAMAGE = true,
	SPELL_DAMAGE = true,
	SPELL_PERIODIC_DAMAGE = true,
	DAMAGE_SHIELD = true,
	DAMAGE_SPLIT = true,
	SPELL_EXTRA_ATTACKS = true
}

local function Reset()
	timeStamp, combatTime, DMGTotal, lastDMGAmount = 0, 0, 0, 0
end

local function GetDPS(self)
	local DPS
	if DMGTotal == 0 or combatTime == 0 then
		DPS = 0
	else
		DPS = DMGTotal / combatTime
	end
	self.text:SetFormattedText(displayString, L["DPS"], E:ShortValue(DPS))
end

local function OnEvent(self, event)
	lastPanel = self

	if event == 'UNIT_PET' then
		petGUID = UnitGUID('pet')
	elseif event == 'PLAYER_REGEN_DISABLED' or event == 'PLAYER_LEAVE_COMBAT' then
		local now = time()
		if now - lastSegment > 20 then --time since the last segment
			Reset()
		end
		lastSegment = now
	elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		local timestamp, Event, _, sourceGUID, _, _, _, _, _, _, _, arg12, _, _, arg15, arg16 = CombatLogGetCurrentEventInfo()
		if not events[Event] then return end

		-- only use events from the player
		local overKill

		if sourceGUID == E.myguid or sourceGUID == petGUID then
			if timeStamp == 0 then timeStamp = timestamp end
			lastSegment = timeStamp
			combatTime = timestamp - timeStamp
			if Event == 'SWING_DAMAGE' then
				lastDMGAmount = arg12
			else
				lastDMGAmount = arg15
			end
			if arg16 == nil then overKill = 0 else overKill = arg16 end
			DMGTotal = DMGTotal + max(0, lastDMGAmount - overKill)
		end
	end

	GetDPS(self)
end

local function OnClick(self)
	Reset()
	GetDPS(self)
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', '%s: ', hex, '%s')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('DPS', nil, {'UNIT_PET', 'COMBAT_LOG_EVENT_UNFILTERED', 'PLAYER_LEAVE_COMBAT', 'PLAYER_REGEN_DISABLED'}, OnEvent, nil, OnClick, nil, nil, _G.STAT_DPS_SHORT, nil, ValueColorUpdate)
