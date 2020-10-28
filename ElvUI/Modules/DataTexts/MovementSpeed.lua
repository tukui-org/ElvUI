local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local BASE_MOVEMENT_SPEED = BASE_MOVEMENT_SPEED
local GetUnitSpeed = GetUnitSpeed
local IsFalling = IsFalling
local IsFlying = IsFlying
local IsFlyableArea = IsFlyableArea
local IsSwimming = IsSwimming
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString, lastPanel = ''
local beforeFalling, wasFlying

local function DelayUpdate(self)
	self:SetScript('OnUpdate', nil) -- only run for 1 frame

	local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed('player')
	local speed = runSpeed
	if IsSwimming('player') then
		speed = swimSpeed
	elseif IsFlying('player') then
		speed = flightSpeed
		wasFlying = true
	else
		wasFlying = false
	end

	if IsFalling('player') and wasFlying then
		speed = beforeFalling or speed
	else
		beforeFalling = speed
	end

	speed = speed/BASE_MOVEMENT_SPEED*100

	if E.global.datatexts.settings.MovementSpeed.NoLabel then
		self.text:SetFormattedText(displayString, speed)
	else
		self.text:SetFormattedText(displayString, E.global.datatexts.settings.MovementSpeed.Label ~= '' and E.global.datatexts.settings.MovementSpeed.Label or STAT_MOVEMENT_SPEED, speed)
	end
end

local function OnEvent(self, event)
	self:SetScript('OnUpdate', DelayUpdate)
	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', E.global.datatexts.settings.MovementSpeed.NoLabel and '' or '%s', hex, '%.'..E.global.datatexts.settings.MovementSpeed.decimalLength..'f%%|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('MovementSpeed', STAT_CATEGORY_ENHANCEMENTS, {'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE', 'UNIT_SPELL_HASTE'}, OnEvent, nil, nil, nil, nil, _G.STAT_MOVEMENT_SPEED, nil, ValueColorUpdate)
