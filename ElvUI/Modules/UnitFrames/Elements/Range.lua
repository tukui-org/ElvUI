local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local RangeCheck = E.Libs.RangeCheck

local UnitCanAttack = UnitCanAttack
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitInRange = UnitInRange
local UnitIsConnected = UnitIsConnected
local UnitPhaseReason = UnitPhaseReason
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit

local function getUnit(unit)
	if not unit:find('party') or not unit:find('raid') then
		for i=1, 4 do
			if UnitIsUnit(unit, 'party'..i) then
				return 'party'..i
			end
		end

		for i=1, 40 do
			if UnitIsUnit(unit, 'raid'..i) then
				return 'raid'..i
			end
		end
	else
		return unit
	end
end

local function friendlyIsInRange(unit)
	if not UnitIsUnit(unit, 'player') and (UnitInParty(unit) or UnitInRaid(unit)) then
		unit = getUnit(unit) -- swap the unit with `raid#` or `party#` when its NOT `player`, UnitIsUnit is true, and its not using `raid#` or `party#` already
	end

	if UnitIsPlayer(unit) and UnitPhaseReason(unit) then
		return false -- is not in same phase
	end

	local inRange, checkedRange = UnitInRange(unit)
	if checkedRange and not inRange then
		return false -- blizz checked and said the unit is out of range
	end

	local _, maxRange = RangeCheck:GetRange(unit, true)
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
			local _, maxRange = RangeCheck:GetRange(unit, true)
			alpha = (maxRange and self.Fader.MaxAlpha) or self.Fader.MinAlpha
		else
			alpha = (UnitIsConnected(unit) and friendlyIsInRange(unit) and self.Fader.MaxAlpha) or self.Fader.MinAlpha
		end
	else
		alpha = self.Fader.MaxAlpha
	end

	self.Fader.RangeAlpha = alpha
end
