local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local time, max, strjoin = time, max, strjoin
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local UnitGUID = UnitGUID

local lastSegment, petGUID = 0
local timeStamp, combatTime, DMGTotal, lastDMGAmount = 0, 0, 0, 0
local displayString = ''
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

local function GetDPS(panel)
	local DPS = (DMGTotal == 0 or combatTime == 0) and 0 or (DMGTotal / combatTime)
	panel.text:SetFormattedText(displayString, L["DPS"], E:ShortValue(DPS))
end

local function OnEvent(panel, event)
	if event == 'UNIT_PET' then
		petGUID = UnitGUID('pet')
	elseif event == 'PLAYER_REGEN_DISABLED' or event == 'PLAYER_LEAVE_COMBAT' then
		local now = time()
		if now - lastSegment > 20 then --time since the last segment
			Reset()
		end

		lastSegment = now
	elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		local timestamp, subEvent, _, sourceGUID, _, _, _, _, _, _, _, arg12, _, _, arg15, overkill = CombatLogGetCurrentEventInfo()
		if not events[subEvent] or (sourceGUID ~= E.myguid and sourceGUID ~= petGUID) then return end

		if timeStamp == 0 then
			timeStamp = timestamp
		end

		lastSegment = timeStamp
		combatTime = timestamp - timeStamp
		lastDMGAmount = (subEvent == 'SWING_DAMAGE' and arg12) or arg15

		DMGTotal = DMGTotal + max(0, lastDMGAmount - (overkill or 0))
	end

	GetDPS(panel)
end

local function OnClick(panel)
	Reset()
	GetDPS(panel)
end

local function ApplySettings(_, hex)
	displayString = strjoin('', '%s: ', hex, '%s')
end

DT:RegisterDatatext('DPS', nil, { 'UNIT_PET', not E.Modern and 'COMBAT_LOG_EVENT_UNFILTERED' or nil, 'PLAYER_LEAVE_COMBAT', 'PLAYER_REGEN_DISABLED' }, OnEvent, nil, OnClick, nil, nil, _G.STAT_DPS_SHORT, nil, ApplySettings)
