local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local IsFalling = IsFalling
local IsFlying = IsFlying
local IsSwimming = IsSwimming
local GetUnitSpeed = GetUnitSpeed
local AbbreviateNumbers = AbbreviateNumbers
local GetGlidingInfo = C_PlayerInfo.GetGlidingInfo

local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local BASE_MOVEMENT_SPEED = BASE_MOVEMENT_SPEED

local data = {
	breakpoint = 0,
	abbreviation = '',
	fractionDivisor = 1,
	significandDivisor = BASE_MOVEMENT_SPEED * 0.01, -- scaled = speed * 100 / BASE_MOVEMENT_SPEED
	abbreviationIsGlobal = false,
}

local breakpoint = { breakpointData = { data } }
local beforeFalling, wasFlying
local displayString, db = ''

local delayed
local function DelayUpdate(panel)
	local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed('player')
	local speed, isGliding, forwardSpeed

	if E.Retail or E.Forever then
		isGliding, _, forwardSpeed = GetGlidingInfo()
	end

	if IsSwimming() then
		speed = swimSpeed
		wasFlying = false
	elseif isGliding then
		speed = forwardSpeed
		wasFlying = true
	elseif IsFlying() then
		speed = flightSpeed
		wasFlying = true
	else
		speed = runSpeed
		wasFlying = false
	end

	if IsFalling() and wasFlying and beforeFalling then
		speed = beforeFalling
	else
		beforeFalling = speed
	end

	local percent = (E.Retail or E.Forever) and AbbreviateNumbers(speed, breakpoint) or (speed / BASE_MOVEMENT_SPEED * 100)
	if db.NoLabel then
		panel.text:SetFormattedText(displayString, percent)
	else
		panel.text:SetFormattedText(displayString, db.Label ~= '' and db.Label or L["Mov. Speed"], percent)
	end

	delayed = nil
end

local function OnEvent(panel)
	if not delayed then
		delayed = E:Delay(0.05, DelayUpdate, panel)
	end
end

local function ApplySettings(panel, hex)
	if not db then
		db = E.global.datatexts.settings[panel.name]
	end

	if E.Retail or E.Forever then
		data.fractionDivisor = 10 ^ (db.decimalLength or 0)
		data.significandDivisor = (BASE_MOVEMENT_SPEED * 0.01) / data.fractionDivisor

		displayString = strjoin('', db.NoLabel and '' or '%s: ', hex, '%s%%|r')
	else
		displayString = strjoin('', db.NoLabel and '' or '%s: ', hex, '%.'..db.decimalLength..'f%%|r')
	end
end

DT:RegisterDatatext('MovementSpeed', STAT_CATEGORY_ENHANCEMENTS, { 'UNIT_STATS', 'UNIT_AURA', 'UNIT_SPELL_HASTE' }, OnEvent, nil, nil, nil, nil, _G.STAT_MOVEMENT_SPEED, nil, ApplySettings)
