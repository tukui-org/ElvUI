local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local IsFalling = IsFalling
local IsFlying = IsFlying
local IsSwimming = IsSwimming
local GetUnitSpeed = GetUnitSpeed
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS
local BASE_MOVEMENT_SPEED = BASE_MOVEMENT_SPEED
local STAT_MOVEMENT_SPEED = STAT_MOVEMENT_SPEED

local displayString, lastPanel = ''
local beforeFalling, wasFlying

local delayed
local function DelayUpdate()
	if not lastPanel then return end

	local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed('player')
	local speed

	if IsSwimming() then
		speed = swimSpeed
		wasFlying = false
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

	local percent = speed / BASE_MOVEMENT_SPEED * 100
	if E.global.datatexts.settings.MovementSpeed.NoLabel then
		lastPanel.text:SetFormattedText(displayString, percent)
	else
		lastPanel.text:SetFormattedText(displayString, E.global.datatexts.settings.MovementSpeed.Label ~= '' and E.global.datatexts.settings.MovementSpeed.Label or STAT_MOVEMENT_SPEED, percent)
	end

	delayed = nil
end

local function OnEvent(self)
	if not delayed then
		delayed = E:Delay(0.05, DelayUpdate)
	end

	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.MovementSpeed.NoLabel and '' or '%s: ', hex, '%.'..E.global.datatexts.settings.MovementSpeed.decimalLength..'f%%|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('MovementSpeed', STAT_CATEGORY_ENHANCEMENTS, {'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE', 'UNIT_SPELL_HASTE'}, OnEvent, nil, nil, nil, nil, STAT_MOVEMENT_SPEED, nil, ValueColorUpdate)
