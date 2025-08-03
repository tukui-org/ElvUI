local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule('UnitFrames')

local next = next
local tonumber = tonumber

local UnitIsUnit = UnitIsUnit
local UnitInPhase = UnitInPhase
local UnitInRange = UnitInRange
local UnitIsPlayer = UnitIsPlayer
local UnitCanAttack = UnitCanAttack
local UnitIsConnected = UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local CheckInteractDistance = CheckInteractDistance
local InCombatLockdown = InCombatLockdown

local IsSpellInSpellBook = C_SpellBook.IsSpellInSpellBook or IsSpellKnownOrOverridesKnown

local IsSpellInRange = C_Spell.IsSpellInRange
local UnitPhaseReason = UnitPhaseReason

local list = {}
UF.RangeSpells = list

function UF:UpdateRangeList(db)
	local spells = {}
	for spell, value in next, db do
		if value then
			local id = tonumber(spell)
			if not id then -- support spells by name
				local _, _, _, _, _, _, spellID = E:GetSpellInfo(spell)
				if spellID then
					id = spellID
				end
			end

			if id and IsSpellInSpellBook(id, nil, true) then
				spells[id] = true
			end
		end
	end

	return spells
end

function UF:UpdateRangeSpells(event, arg1)
	if event == 'CHARACTER_POINTS_CHANGED' and (not arg1 or arg1 > 0) then
		return -- Not interested in gained points from leveling
	end

	local db = E.global.unitframe.rangeCheck
	if db then
		list[1] = UF:UpdateRangeList(db.ENEMY[E.myclass])
		list[2] = UF:UpdateRangeList(db.FRIENDLY[E.myclass])
		list[3] = UF:UpdateRangeList(db.RESURRECT[E.myclass])
		list[4] = UF:UpdateRangeList(db.PET[E.myclass])
	end
end

function UF:UnitSpellRange(unit, spells)
	local failed
	for spell in next, spells do
		local range = IsSpellInRange(spell, unit)
		if range then
			return true
		elseif range ~= nil then
			failed = true -- oh no
		end
	end

	if failed then
		return false
	end
end

function UF:UnitInSpellsRange(unit, which)
	local spells = list[which]
	local range = (not next(spells) and 1) or UF:UnitSpellRange(unit, spells)

	if (not range or range == 1) and not InCombatLockdown() then
		return CheckInteractDistance(unit, 4) -- check follow interact when not in combat
	else
		return (range == nil and 1) or range -- nil: various reason it cant be checked; ie: cant be cast on the unit
	end
end

function UF:FriendlyInRange(realUnit)
	local unit = E:GetGroupUnit(realUnit) or realUnit

	if UnitIsPlayer(unit) then
		if E.Retail then
			if UnitPhaseReason(unit) then
				return false
			end
		elseif not UnitInPhase(unit) then
			return false
		end
	end

	local range, checked = UnitInRange(unit)
	if checked and not range then
		return false -- blizz checked and unit is out of range
	end

	return UF:UnitInSpellsRange(unit, 2)
end

function UF:UpdateRange(unit)
	local element = self.Fader
	if not element then return end

	if not unit then
		unit = self.unit
	end

	if self.forceInRange or unit == 'player' then
		element.RangeAlpha = element.MaxAlpha
	elseif self.forceNotInRange then
		element.RangeAlpha = element.MinAlpha
	elseif unit then
		if UnitIsDeadOrGhost(unit) then
			element.RangeAlpha = UF:UnitInSpellsRange(unit, 3) == true and element.MaxAlpha or element.MinAlpha
		elseif UnitCanAttack('player', unit) then
			element.RangeAlpha = UF:UnitInSpellsRange(unit, 1) and element.MaxAlpha or element.MinAlpha
		elseif UnitIsUnit('pet', unit) then
			element.RangeAlpha = UF:UnitInSpellsRange(unit, 4) and element.MaxAlpha or element.MinAlpha
		elseif UnitIsConnected(unit) then
			element.RangeAlpha = UF:FriendlyInRange(unit) and element.MaxAlpha or element.MinAlpha
		else
			element.RangeAlpha = element.MinAlpha
		end
	else
		element.RangeAlpha = element.MaxAlpha
	end
end
