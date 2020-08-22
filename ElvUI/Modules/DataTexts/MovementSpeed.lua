local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local BASE_MOVEMENT_SPEED = BASE_MOVEMENT_SPEED
local GetUnitSpeed = GetUnitSpeed
local IsFalling = IsFalling
local IsFlying = IsFlying
local IsSwimming = IsSwimming
local STAT_CATEGORY_ENHANCEMENTS = STAT_CATEGORY_ENHANCEMENTS

local displayString, lastPanel = ''
local movementSpeedText, beforeFalling = L["Mov. Speed:"]

local function OnEvent(self)
	local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed('player')

	local speed = runSpeed
	if IsSwimming('player') then
		speed = swimSpeed
	elseif IsFlying('player') then
		speed = flightSpeed
	end

	if IsFalling('player') then
		speed = beforeFalling or speed
	else
		beforeFalling = speed
	end

	self.text:SetFormattedText(displayString, movementSpeedText, speed/BASE_MOVEMENT_SPEED*100)
	lastPanel = self
end

local function ValueColorUpdate(hex)
	displayString = strjoin('', '%s ', hex, '%.0f%%|r')

	if lastPanel then OnEvent(lastPanel) end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext('Movement Speed', STAT_CATEGORY_ENHANCEMENTS, {'UNIT_STATS', 'UNIT_AURA', 'ACTIVE_TALENT_GROUP_CHANGED', 'PLAYER_TALENT_UPDATE', 'UNIT_SPELL_HASTE'}, OnEvent, nil, nil, nil, nil, _G.STAT_MOVEMENT_SPEED)
