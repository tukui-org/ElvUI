local parent, ns = ...
local oUF = ns.oUF

local _FRAMES = {}
local OnRangeFrame

local UnitIsConnected = UnitIsConnected
local tinsert, tremove = table.insert, table.remove

local friendlySpells, resSpells, longEnemySpells, enemySpells, petSpells = {}, {}, {}, {}, {}

do
	local _,class = UnitClass("player")
	if class == "PRIEST" then
		enemySpells[#enemySpells+1] = GetSpellInfo(585) -- Smite
		longEnemySpells[#longEnemySpells+1] = GetSpellInfo(589) -- Shadow Word: Pain
		friendlySpells[#friendlySpells+1] = GetSpellInfo(2061) -- Flash Heal
		resSpells[#resSpells+1] = GetSpellInfo(2006) -- Resurrection
	elseif class == "DRUID" then
		enemySpells[#enemySpells+1] = GetSpellInfo(33786) -- Cyclone
		longEnemySpells[#longEnemySpells+1] = GetSpellInfo(5176) -- Wrath
		friendlySpells[#friendlySpells+1] = GetSpellInfo(774) -- Rejuvenation
		resSpells[#resSpells+1] = GetSpellInfo(50769) -- Revive 
		resSpells[#resSpells+1] = GetSpellInfo(20484) -- Rebirth 
	elseif class == "PALADIN" then
		enemySpells[#enemySpells+1] = GetSpellInfo(20271) -- Judgement
		friendlySpells[#friendlySpells+1] = GetSpellInfo(19750) -- Flash of Light
		resSpells[#resSpells+1] = GetSpellInfo(7328) -- Redemption
		longEnemySpells[#longEnemySpells+1] = GetSpellInfo(114165) -- Holy Prism
		longEnemySpells[#longEnemySpells+1] = GetSpellInfo(114157) -- Execution Sentence
	elseif class == "SHAMAN" then
		enemySpells[#enemySpells+1] = GetSpellInfo(8042) -- Earth Shock 
		longEnemySpells[#longEnemySpells+1] = GetSpellInfo(403) -- Lightning Bolt
		friendlySpells[#friendlySpells+1] = GetSpellInfo(8004) -- Healing Surge
		resSpells[#resSpells+1] = GetSpellInfo(2008) -- Ancestral Spirit 
	elseif class == "WARLOCK" then
		enemySpells[#enemySpells+1] = GetSpellInfo(5782) -- Fear
		longEnemySpells[#longEnemySpells+1] = GetSpellInfo(172) -- Corruption
		longEnemySpells[#longEnemySpells+1] = GetSpellInfo(686) -- Shadow Bolt
		longEnemySpells[#longEnemySpells+1] = GetSpellInfo(17962) -- Conflag
		petSpells[#petSpells+1] = GetSpellInfo(755) -- Health Funnel
		friendlySpells[#friendlySpells+1] = GetSpellInfo(5697) -- Unending Breath
	elseif class == "MAGE" then
		enemySpells[#enemySpells+1] = GetSpellInfo(118) -- Polymorph
		longEnemySpells[#longEnemySpells+1] = GetSpellInfo(44614) -- Frostfire Bolt
		friendlySpells[#friendlySpells+1] = GetSpellInfo(475) -- Remove Curse
	elseif class == "HUNTER" then
		petSpells[#petSpells+1] = GetSpellInfo(136) -- Mend Pet
		enemySpells[#enemySpells+1] = GetSpellInfo(75) -- Auto Shot
	elseif class == "DEATHKNIGHT" then
		enemySpells[#enemySpells+1] = GetSpellInfo(49576) -- Death Grip
		friendlySpells[#friendlySpells+1] = GetSpellInfo(49016) -- Unholy Frenzy
		resSpells[#resSpells+1] = GetSpellInfo(61999) -- Raise Ally 
	elseif class == "ROGUE" then
		enemySpells[#enemySpells+1] = GetSpellInfo(2094) -- Blind 
		longEnemySpells[#longEnemySpells+1] = GetSpellInfo(1725) -- Distract
		friendlySpells[#friendlySpells+1] = GetSpellInfo(57934) -- Tricks of the Trade
	elseif class == "WARRIOR" then
		enemySpells[#enemySpells+1] = GetSpellInfo(5246) -- Intimidating Shout
		enemySpells[#enemySpells+1] = GetSpellInfo(100) -- Charge
		longEnemySpells[#longEnemySpells+1] = GetSpellInfo(355) -- Taunt
		friendlySpells[#friendlySpells+1] = GetSpellInfo(3411) -- Intervene
	elseif class == "MONK" then
		enemySpells[#enemySpells+1] = GetSpellInfo(115546) -- Provoke
		friendlySpells[#friendlySpells+1] = GetSpellInfo(115450) -- Detox
		resSpells[#resSpells+1] = GetSpellInfo(115178) -- Resuscitate
	end	
end

local function friendlyIsInRange(unit)
	if CheckInteractDistance(unit, 2) then
		return true
	end
	
	if UnitIsDeadOrGhost(unit) then
		for _, name in ipairs(resSpells) do
			if IsSpellInRange(name, unit) == 1 then
				return true
			end
		end

		return false
	end

	for _, name in ipairs(friendlySpells) do
		if IsSpellInRange(name, unit) == 1 then
			return true
		end
	end
	
	return false
end

local function petIsInRange(unit)
	if CheckInteractDistance(unit, 2) then
		return true
	end
	
	for _, name in ipairs(friendlySpells) do
		if IsSpellInRange(name, unit) == 1 then
			return true
		end
	end
	for _, name in ipairs(petSpells) do
		if IsSpellInRange(name, unit) == 1 then
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
		if IsSpellInRange(name, unit) == 1 then
			return true
		end
	end
	
	return false
end

local function enemyIsInLongRange(unit)
	for _, name in ipairs(longEnemySpells) do
		if IsSpellInRange(name, unit) == 1 then
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
			OnRangeFrame:SetScript("OnUpdate", OnRangeUpdate)
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
