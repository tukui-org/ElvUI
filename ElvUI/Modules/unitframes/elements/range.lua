local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local SpellRange = LibStub("SpellRange-1.0")
local _,class = UnitClass("player")

--Cache global variables
--Lua functions
local pairs, ipairs = pairs, ipairs
local tinsert, tremove, twipe = table.insert, table.remove, table.wipe
--WoW API / Variables
local CheckInteractDistance = CheckInteractDistance
local UnitCanAttack = UnitCanAttack
local UnitInParty = UnitInParty
local UnitInPhase = UnitInPhase
local UnitInRaid = UnitInRaid
local UnitInRange = UnitInRange
local UnitIsConnected = UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsUnit = UnitIsUnit

function UF:Construct_Range()
	local Range = {insideAlpha = 1, outsideAlpha = E.db.unitframe.OORAlpha}
	Range.Override = UF.UpdateRange

	return Range
end

function UF:Configure_Range(frame)
	local range = frame.Range
	if frame.db.rangeCheck then
		if not frame:IsElementEnabled('Range') then
			frame:EnableElement('Range')
		end

		range.outsideAlpha = E.db.unitframe.OORAlpha
	else
		if frame:IsElementEnabled('Range') then
			frame:DisableElement('Range')
		end
	end
end

local SpellRangeTable = {}

local function AddTable(tbl)
	SpellRangeTable[class] = SpellRangeTable[class] or {}
	SpellRangeTable[class][tbl] = {}
end

local function AddSpell(tbl, spellID)
	SpellRangeTable[class][tbl][#SpellRangeTable[class][tbl] + 1] = spellID
end

function UF:UpdateRangeCheckSpells()
	for tbl, spells in pairs(E.global.unitframe.spellRangeCheck[class]) do
		AddTable(tbl) --Create the table holding spells, even if it ends up being an empty table
		for spellID in pairs(spells) do
			local enabled = spells[spellID]
			if enabled then --We will allow value to be false to disable this spell from being used
				AddSpell(tbl, spellID, enabled)
			end
		end
	end
end

local function getUnit(unit)
	if not unit:find("party") or not unit:find("raid") then
		for i=1, 4 do
			if UnitIsUnit(unit, "party"..i) then
				return "party"..i
			end
		end

		for i=1, 40 do
			if UnitIsUnit(unit, "raid"..i) then
				return "raid"..i
			end
		end
	else
		return unit
	end
end

local function friendlyIsInRange(unit)
	if not UnitInPhase(unit) then --Different phase
		return false
	end

	if CheckInteractDistance(unit, 1) then --Inspect (28 yards)
		return true
	end

	if UnitIsDeadOrGhost(unit) and #SpellRangeTable[class].resSpells > 0 then
		for _, spellID in ipairs(SpellRangeTable[class].resSpells) do
			if SpellRange.IsSpellInRange(spellID, unit) == 1 then
				return true
			end
		end

		return false
	end

	if #SpellRangeTable[class].friendlySpells == 0 and (UnitInRaid(unit) or UnitInParty(unit)) then
		unit = getUnit(unit)
		return unit and UnitInRange(unit)
	else
		for _, spellID in ipairs(SpellRangeTable[class].friendlySpells) do
			if SpellRange.IsSpellInRange(spellID, unit) == 1 then
				return true
			end
		end
	end
	
	return false
end

local function petIsInRange(unit)
	if CheckInteractDistance(unit, 2) then
		return true
	end
	
	for _, spellID in ipairs(SpellRangeTable[class].friendlySpells) do
		if SpellRange.IsSpellInRange(spellID, unit) == 1 then
			return true
		end
	end
	for _, spellID in ipairs(SpellRangeTable[class].petSpells) do
		if SpellRange.IsSpellInRange(spellID, unit) == 1 then
			return true
		end
	end
	
	return false
end

local function enemyIsInRange(unit)
	if CheckInteractDistance(unit, 2) then
		return true
	end
	
	for _, spellID in ipairs(SpellRangeTable[class].enemySpells) do
		if SpellRange.IsSpellInRange(spellID, unit) == 1 then
			return true
		end
	end
	
	return false
end

local function enemyIsInLongRange(unit)
	for _, spellID in ipairs(SpellRangeTable[class].longEnemySpells) do
		if SpellRange.IsSpellInRange(spellID, unit) == 1 then
			return true
		end
	end
	
	return false
end

function UF:UpdateRange(event)
	local range = self.Range
	local unit = self.unit
	if(unit) then
		if UnitCanAttack("player", unit) then
			if enemyIsInRange(unit) then
				self:SetAlpha(range.insideAlpha)
			elseif enemyIsInLongRange(unit) then
				self:SetAlpha(range.insideAlpha)
			else
				self:SetAlpha(range.outsideAlpha)
			end
		elseif UnitIsUnit(unit, "pet") then
			if petIsInRange(unit) then
				self:SetAlpha(range.insideAlpha)
			else
				self:SetAlpha(range.outsideAlpha)
			end
		else
			if friendlyIsInRange(unit) and UnitIsConnected(unit) then
				self:SetAlpha(range.insideAlpha)
			else
				self:SetAlpha(range.outsideAlpha)
			end
		end
	else
		self:SetAlpha(range.insideAlpha)	
	end
end