local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames')
local RangeCheck = E.Libs.RangeCheck

local UnitCanAttack = UnitCanAttack
local UnitInRange = UnitInRange
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitPhaseReason = UnitPhaseReason

local function friendlyIsInRange(realUnit)
	local unit = E:GetGroupUnit(realUnit) or realUnit

	if UnitIsPlayer(unit) and UnitPhaseReason(unit) then
		return false -- is not in same phase
	end

	local inRange, checkedRange = UnitInRange(unit)
	if checkedRange and not inRange then
		return false -- blizz checked and said the unit is out of range
	end

	local _, maxRange = RangeCheck:GetRange(unit, true, true)
	return maxRange
end

function UF:UpdateRange(unit)
	if not self.Fader then return end
	local alpha

	unit = unit or self.unit

	if self.forceInRange or unit == 'player' then
		alpha = self.Fader.MaxAlpha
	elseif self.forceNotInRange then
		alpha = self.Fader.MinAlpha
	elseif unit then
		if UnitCanAttack('player', unit) or UnitIsUnit(unit, 'pet') then
			local _, maxRange = RangeCheck:GetRange(unit, true, true)
			alpha = (maxRange and self.Fader.MaxAlpha) or self.Fader.MinAlpha
		else
			alpha = (UnitIsConnected(unit) and friendlyIsInRange(unit) and self.Fader.MaxAlpha) or self.Fader.MinAlpha
		end
	else
		alpha = self.Fader.MaxAlpha
	end

	self.Fader.RangeAlpha = alpha
end
