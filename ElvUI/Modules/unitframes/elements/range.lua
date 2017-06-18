local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local UF = E:GetModule('UnitFrames');
local SpellRange = LibStub("SpellRange-1.0")

--Cache global variables
--Lua functions
local ipairs = ipairs
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

local function AddSpell(table, spellID)
	table[#table + 1] = spellID
end

local _,class = UnitClass("player")
local friendlySpells, resSpells, longEnemySpells, enemySpells, petSpells = {}, {}, {}, {}, {}

do
	if class == "PRIEST" then
		AddSpell(enemySpells, 585) -- Smite (40 yards)
		AddSpell(enemySpells, 589) -- Shadow Word: Pain (40 yards)
		AddSpell(friendlySpells, 2061) -- Flash Heal (40 yards)
		AddSpell(friendlySpells, 17) -- Power Word: Shield (40 yards)
		AddSpell(resSpells, 2006) -- Resurrection (40 yards)
	elseif class == "DRUID" then
		AddSpell(enemySpells, 8921) -- Moonfire (40 yards, all specs, lvl 3)
		AddSpell(friendlySpells, 8936) -- Regrowth (40 yards, all specs, lvl 5)
		AddSpell(resSpells, 50769) -- Revive (40 yards, all specs, lvl 14)
	elseif class == "PALADIN" then
		AddSpell(enemySpells, 20271) -- Judgement (30 yards)
		AddSpell(longEnemySpells, 20473) -- Holy Shock (40 yards)
		AddSpell(friendlySpells, 19750) -- Flash of Light (40 yards)
		AddSpell(resSpells, 7328) -- Redemption (40 yards)
	elseif class == "SHAMAN" then
		AddSpell(enemySpells, 188196) -- Lightning Bolt (Elemental) (40 yards)
		AddSpell(enemySpells, 187837) -- Lightning Bolt (Enhancement) (40 yards)
		AddSpell(enemySpells, 403) -- Lightning Bolt (Resto) (40 yards)
		AddSpell(friendlySpells, 8004) -- Healing Surge (Resto/Elemental) (40 yards)
		AddSpell(friendlySpells, 188070) -- Healing Surge (Enhancement) (40 yards)
		AddSpell(resSpells, 2008) -- Ancestral Spirit (40 yards) 
	elseif class == "WARLOCK" then
		AddSpell(enemySpells, 5782) -- Fear (30 yards)
		AddSpell(longEnemySpells, 234153) -- Drain Life (40 yards)
		AddSpell(longEnemySpells, 198590) --Drain Soul (40 yards)
		AddSpell(longEnemySpells, 232670) --Shadow Bolt (40 yards, lvl 1 spell)
		AddSpell(longEnemySpells, 686) --Shadow Bolt (Demonology) (40 yards, lvl 1 spell)
		AddSpell(petSpells, 755) -- Health Funnel (45 yards)
		AddSpell(friendlySpells, 20707) -- Soulstone (40 yards)
	elseif class == "MAGE" then
		AddSpell(enemySpells, 118) -- Polymorph (30 yards)
		AddSpell(longEnemySpells, 116) -- Frostbolt (Frost) (40 yards)
		AddSpell(longEnemySpells, 44425) -- Arcane Barrage (Arcane) (40 yards)
		AddSpell(longEnemySpells, 133) -- Fireball (Fire) (40 yards)
		AddSpell(friendlySpells, 130) -- Slow Fall (40 yards)
	elseif class == "HUNTER" then
		AddSpell(petSpells, 982) -- Mend Pet (45 yards)
		AddSpell(enemySpells, 75) -- Auto Shot (40 yards)
	elseif class == "DEATHKNIGHT" then
		AddSpell(enemySpells, 49576) -- Death Grip
		AddSpell(longEnemySpells, 47541) -- Death Coil (Unholy) (40 yards)
		AddSpell(resSpells, 61999) -- Raise Ally (40 yards)
	elseif class == "ROGUE" then
		AddSpell(enemySpells, 185565) -- Poisoned Knife (Assassination) (30 yards)
		AddSpell(enemySpells, 185763) -- Pistol Shot (Outlaw) (20 yards)
		AddSpell(enemySpells, 114014) -- Shuriken Toss (Sublety) (30 yards)
		AddSpell(enemySpells, 1725) -- Distract (30 yards)
		AddSpell(friendlySpells, 57934) -- Tricks of the Trade (100 yards)
	elseif class == "WARRIOR" then
		AddSpell(enemySpells, 5246) -- Intimidating Shout (Arms/Fury) (8 yards)
		AddSpell(enemySpells, 100) -- Charge (Arms/Fury) (8-25 yards)
		AddSpell(longEnemySpells, 355) -- Taunt (30 yards)
	elseif class == "MONK" then
		AddSpell(enemySpells, 115546) -- Provoke (30 yards)
		AddSpell(longEnemySpells, 117952) -- Crackling Jade Lightning (40 yards)
		AddSpell(friendlySpells, 116694) -- Effuse (40 yards)
		AddSpell(resSpells, 115178) -- Resuscitate (40 yards)
	elseif class == "DEMONHUNTER" then
		AddSpell(enemySpells, 183752) -- Consume Magic (20 yards)
		AddSpell(longEnemySpells, 185123) -- Throw Glaive (Havoc) (30 yards)
		AddSpell(longEnemySpells, 204021) -- Fiery Brand (Vengeance) (30 yards)
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
	if CheckInteractDistance(unit, 1) and UnitInPhase(unit) then --Inspect (28 yards) and same phase as you
		return true
	end

	if UnitIsDeadOrGhost(unit) and #resSpells > 0 then
		for _, spellID in ipairs(resSpells) do
			if SpellRange.IsSpellInRange(spellID, unit) == 1 then
				return true
			end
		end

		return false
	end

	if #friendlySpells == 0 and (UnitInRaid(unit) or UnitInParty(unit)) then
		unit = getUnit(unit)
		return unit and UnitInRange(unit)
	else
		for _, spellID in ipairs(friendlySpells) do
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
	
	for _, spellID in ipairs(friendlySpells) do
		if SpellRange.IsSpellInRange(spellID, unit) == 1 then
			return true
		end
	end
	for _, spellID in ipairs(petSpells) do
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
	
	for _, spellID in ipairs(enemySpells) do
		if SpellRange.IsSpellInRange(spellID, unit) == 1 then
			return true
		end
	end
	
	return false
end

local function enemyIsInLongRange(unit)
	for _, spellID in ipairs(longEnemySpells) do
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