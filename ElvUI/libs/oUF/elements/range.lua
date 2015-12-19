local parent, ns = ...
local oUF = ns.oUF

local _FRAMES = {}
local OnRangeFrame

local UnitIsConnected = UnitIsConnected
local tinsert, tremove, twipe = table.insert, table.remove, table.wipe

local friendlySpells, resSpells, longEnemySpells, enemySpells, petSpells = {}, {}, {}, {}, {}
local addSpellRetry = {}

local SpellRange = LibStub("SpellRange-1.0")

local function AddSpell(table, spellID)
	local name = GetSpellInfo(spellID)
	if name then
		local usable, nomana = IsUsableSpell(name)
		if usable or nomana then
			table[#table + 1] = name
		end
	else --What happened here? Try again in a few seconds
		if addSpellRetry[spellID] and addSpellRetry[spellID] > 5 then
			print("ElvUI: Issue adding spell to range check. Please report this. SpellID:", spellID)
			return
		end
		C_Timer.After(2, function() AddSpell(table, spellID) end)
		addSpellRetry[spellID] = ((addSpellRetry[spellID] or 0) + 1)
	end
end

local _,class = UnitClass("player")
local function UpdateSpellList()
	twipe(friendlySpells)
	twipe(resSpells)
	twipe(longEnemySpells)
	twipe(enemySpells)
	twipe(petSpells)
	
	if class == "PRIEST" then
		AddSpell(enemySpells, 585) -- Smite
		AddSpell(longEnemySpells, 589) -- Shadow Word: Pain
		AddSpell(friendlySpells, 2061) -- Flash Heal
		AddSpell(resSpells, 2006) -- Resurrection
	elseif class == "DRUID" then
		AddSpell(enemySpells, 33786) -- Cyclone
		AddSpell(longEnemySpells, 5176) -- Wrath
		AddSpell(friendlySpells, 774) -- Rejuvenation
		AddSpell(resSpells, 50769) -- Revive 
		AddSpell(resSpells, 20484) -- Rebirth 
	elseif class == "PALADIN" then
		AddSpell(enemySpells, 20271) -- Judgement
		AddSpell(friendlySpells, 85673) -- Word of Glory
		AddSpell(resSpells, 7328) -- Redemption
		AddSpell(longEnemySpells, 114165) -- Holy Prism
		AddSpell(longEnemySpells, 114157) -- Execution Sentence
	elseif class == "SHAMAN" then
		AddSpell(enemySpells, 8042) -- Earth Shock 
		AddSpell(longEnemySpells, 403) -- Lightning Bolt
		AddSpell(friendlySpells, 8004) -- Healing Surge
		AddSpell(resSpells, 2008) -- Ancestral Spirit 
	elseif class == "WARLOCK" then
		AddSpell(enemySpells, 5782) -- Fear
		AddSpell(longEnemySpells, 172) -- Corruption
		AddSpell(longEnemySpells, 686) -- Shadow Bolt
		AddSpell(longEnemySpells, 17962) -- Conflag
		AddSpell(petSpells, 755) -- Health Funnel
		AddSpell(friendlySpells, 5697) -- Unending Breath
	elseif class == "MAGE" then
		AddSpell(enemySpells, 118) -- Polymorph
		AddSpell(longEnemySpells, 44614) -- Frostfire Bolt
		AddSpell(friendlySpells, 475) -- Remove Curse
	elseif class == "HUNTER" then
		AddSpell(petSpells, 136) -- Mend Pet
		AddSpell(enemySpells, 75) -- Auto Shot
	elseif class == "DEATHKNIGHT" then
		AddSpell(enemySpells, 49576) -- Death Grip
		AddSpell(friendlySpells, 47541) -- Death Coil
		AddSpell(resSpells, 61999) -- Raise Ally 
	elseif class == "ROGUE" then
		AddSpell(enemySpells, 2094) -- Blind 
		AddSpell(longEnemySpells, 1725) -- Distract
		AddSpell(friendlySpells, 57934) -- Tricks of the Trade
	elseif class == "WARRIOR" then
		AddSpell(enemySpells, 5246) -- Intimidating Shout
		AddSpell(enemySpells, 100) -- Charge
		AddSpell(longEnemySpells, 355) -- Taunt
	elseif class == "MONK" then
		AddSpell(enemySpells, 115546) -- Provoke
		AddSpell(friendlySpells, 115450) -- Detox
		AddSpell(resSpells, 115178) -- Resuscitate
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
		for _, name in ipairs(resSpells) do
			if SpellRange.IsSpellInRange(name, unit) == 1 then
				return true
			end
		end

		return false
	end

	if #friendlySpells == 0 and (UnitInRaid(unit) or UnitInParty(unit)) then
		unit = getUnit(unit)
		return unit and UnitInRange(unit)
	else
		for _, name in ipairs(friendlySpells) do
			if SpellRange.IsSpellInRange(name, unit) == 1 then
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
	
	for _, name in ipairs(friendlySpells) do
		if SpellRange.IsSpellInRange(name, unit) == 1 then
			return true
		end
	end
	for _, name in ipairs(petSpells) do
		if SpellRange.IsSpellInRange(name, unit) == 1 then
			return true
		end
	end
	
	return false
end

local function enemyIsInRange(unit)
	if CheckInteractDistance(unit, 2) then
		return true
	end
	
	for _, name in ipairs(enemySpells) do
		if SpellRange.IsSpellInRange(name, unit) == 1 then
			return true
		end
	end
	
	return false
end

local function enemyIsInLongRange(unit)
	for _, name in ipairs(longEnemySpells) do
		if SpellRange.IsSpellInRange(name, unit) == 1 then
			return true
		end
	end
	
	return false
end

-- updating of range.
local timer = 0
local OnRangeUpdate = function(self, elapsed)
	timer = timer + elapsed

	if(timer >= .20) then
		for _, object in next, _FRAMES do
			if(object:IsShown()) then
				local range = object.Range
				local unit = object.unit
				if(unit) then
					if UnitCanAttack("player", unit) then
						if enemyIsInRange(unit) then
							object:SetAlpha(range.insideAlpha)
						elseif enemyIsInLongRange(unit) then
							object:SetAlpha(range.insideAlpha)
						else
							object:SetAlpha(range.outsideAlpha)
						end
					elseif UnitIsUnit(unit, "pet") then
						if petIsInRange(unit) then
							object:SetAlpha(range.insideAlpha)
						else
							object:SetAlpha(range.outsideAlpha)
						end
					else
						if friendlyIsInRange(unit) and UnitIsConnected(unit) then
							object:SetAlpha(range.insideAlpha)
						else
							object:SetAlpha(range.outsideAlpha)
						end
					end
				else
					object:SetAlpha(range.insideAlpha)	
				end
			end
		end

		timer = 0
	end
end

local Enable = function(self)
	local range = self.Range
	if(range and range.insideAlpha and range.outsideAlpha) then
		tinsert(_FRAMES, self)

		if(not OnRangeFrame) then
			OnRangeFrame = CreateFrame"Frame"
			OnRangeFrame:RegisterEvent("LEARNED_SPELL_IN_TAB");
			OnRangeFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
			OnRangeFrame:SetScript("OnUpdate", OnRangeUpdate)
			OnRangeFrame:SetScript("OnEvent", function() C_Timer.After(5, UpdateSpellList) end)
		end

		OnRangeFrame:Show()

		return true
	end
end

local Disable = function(self)
	local range = self.Range
	if(range) then
		for k, frame in next, _FRAMES do
			if(frame == self) then
				tremove(_FRAMES, k)
				frame:SetAlpha(1)
				break
			end
		end

		if(#_FRAMES == 0) then
			OnRangeFrame:Hide()
		end
	end
end

oUF:AddElement('Range', nil, Enable, Disable)
