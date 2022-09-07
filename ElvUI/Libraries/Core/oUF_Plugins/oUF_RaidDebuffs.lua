local _, ns = ...
local oUF = ns.oUF or oUF

local _G = _G
local addon = {}

ns.oUF_RaidDebuffs = addon
_G.oUF_RaidDebuffs = ns.oUF_RaidDebuffs
if not _G.oUF_RaidDebuffs then
	_G.oUF_RaidDebuffs = addon
end

local abs = math.abs
local format, floor, next = format, floor, next
local type, pairs, wipe = type, pairs, wipe

local GetActiveSpecGroup = GetActiveSpecGroup
local GetSpecialization = GetSpecialization
local UnitCanAttack = UnitCanAttack
local UnitIsCharmed = UnitIsCharmed
local GetSpellInfo = GetSpellInfo
local IsSpellKnown = IsSpellKnown
local UnitAura = UnitAura
local GetTime = GetTime

local debuff_data = {}
addon.DebuffData = debuff_data
addon.ShowDispellableDebuff = true
addon.FilterDispellableDebuff = true
addon.MatchBySpellName = false
addon.priority = 10

local DispelPriority = {
	Magic   = 4,
	Curse   = 3,
	Disease = 2,
	Poison  = 1,
}

local blackList = {
	[105171] = true, -- Deep Corruption (Dragon Soul: Yor'sahj the Unsleeping)
	[108220] = true, -- Deep Corruption (Dragon Soul: Shadowed Globule)
	[116095] = true, -- Disable, Slow   (Monk: Windwalker)
}

local DispelColor = {
	Magic   = {0.2, 0.6, 1.0},
	Curse   = {0.6, 0, 1.0},
	Disease = {0.6, 0.4, 0},
	Poison  = {0, 0.6, 0},
	none    = {0.2, 0.2, 0.2}
}

local function add(spell, priority, stackThreshold)
	if addon.MatchBySpellName and type(spell) == 'number' then
		spell = GetSpellInfo(spell)
	end

	if spell then
		debuff_data[spell] = {
			priority = (addon.priority + priority),
			stackThreshold = stackThreshold,
		}
	end
end

function addon:RegisterDebuffs(t)
	for spell, value in pairs(t) do
		if type(t[spell]) == 'boolean' then
			local oldValue = t[spell]
			t[spell] = { enable = oldValue, priority = 0, stackThreshold = 0 }
		else
			if t[spell].enable then
				add(spell, t[spell].priority or 0, t[spell].stackThreshold or 0)
			end
		end
	end
end

function addon:ResetDebuffData()
	wipe(debuff_data)
end

function addon:GetDispelColor()
	return DispelColor
end

local DispelClasses = {
	PALADIN = { Poison = true, Disease = true },
	PRIEST = { Magic = true, Disease = true },
	MONK = { Disease = true, Poison = true },
	DRUID = { Curse = true, Poison = true },
	MAGE = { Curse = true },
	WARLOCK = {},
	SHAMAN = {}
}

if oUF.isRetail then
	DispelClasses.SHAMAN.Curse = true
else
	local cleanse = not oUF.isWrath or IsSpellKnown(51886)
	DispelClasses.SHAMAN.Curse = oUF.isWrath and cleanse
	DispelClasses.SHAMAN.Poison = cleanse
	DispelClasses.SHAMAN.Disease = cleanse

	DispelClasses.PALADIN.Magic = true
end

local playerClass = select(2, UnitClass('player'))
local DispelFilter = DispelClasses[playerClass] or {}

local function CheckTalentTree(tree)
	local activeGroup = GetActiveSpecGroup()
	local activeSpec = activeGroup and GetSpecialization(false, false, activeGroup)
	if activeSpec then
		return tree == activeSpec
	end
end

local SingeMagic = 89808
local DevourMagic = {
	[19505] = 'Rank 1',
	[19731] = 'Rank 2',
	[19734] = 'Rank 3',
	[19736] = 'Rank 4',
	[27276] = 'Rank 5',
	[27277] = 'Rank 6'
}

local function CheckPetSpells()
	if oUF.isRetail then
		return IsSpellKnown(SingeMagic, true)
	else
		for spellID in next, DevourMagic do
			if IsSpellKnown(spellID, true) then
				return true
			end
		end
	end
end

-- Check for certain talents to see if we can dispel magic or not
local function CheckDispel(_, event, arg1)
	if event == 'UNIT_PET' then
		if arg1 == 'player' and playerClass == 'WARLOCK' then
			DispelFilter.Magic = CheckPetSpells()
		end
	elseif event == 'CHARACTER_POINTS_CHANGED' and arg1 > 0 then
		return -- Not interested in gained points from leveling
	elseif oUF.isRetail then
		if playerClass == 'PALADIN' then
			DispelFilter.Magic = CheckTalentTree(1)
		elseif playerClass == 'SHAMAN' then
			DispelFilter.Magic = CheckTalentTree(3)
		elseif playerClass == 'DRUID' then
			DispelFilter.Magic = CheckTalentTree(4)
		elseif playerClass == 'MONK' then
			DispelFilter.Magic = CheckTalentTree(2)
		end
	elseif playerClass == 'SHAMAN' then
		DispelFilter.Curse = IsSpellKnown(51886)
	end
end

local function formatTime(s)
	if s > 60 then
		return format('%dm', s/60), s%60
	elseif s < 1 then
		return format('%.1f', s), s - floor(s)
	else
		return format('%d', s), s - floor(s)
	end
end

local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.1 then
		local timeLeft = self.endTime - GetTime()

		if self.reverse and self.duration then
			timeLeft = abs(timeLeft - self.duration)
		end

		if timeLeft > 0 then
			local text = formatTime(timeLeft)
			self.time:SetText(text)
		else
			self:SetScript('OnUpdate', nil)
			self.time:Hide()
		end

		self.elapsed = 0
	end
end

local function UpdateDebuff(self, name, icon, count, debuffType, duration, endTime, spellID, stackThreshold, modRate)
	local f = self.RaidDebuffs

	if name and (count >= stackThreshold) then
		f.icon:SetTexture(icon)
		f.icon:Show()

		f.modRate = modRate
		f.endTime = endTime
		f.duration = duration
		f.reverse = f.ReverseTimer and f.ReverseTimer[spellID]

		if f.count then
			if count and (count > 1) then
				f.count:SetText(count)
				f.count:Show()
			else
				f.count:SetText("")
				f.count:Hide()
			end
		end

		if f.time then
			if duration and (duration > 0) then
				f.nextUpdate = 0
				f:SetScript('OnUpdate', OnUpdate)
				f.time:Show()
			else
				f:SetScript('OnUpdate', nil)
				f.time:Hide()
			end
		end

		if f.cd then
			if duration and (duration > 0) then
				f.cd:SetCooldown(endTime - duration, duration, modRate)
				f.cd:Show()
			else
				f.cd:Hide()
			end
		end

		local c = DispelColor[debuffType] or DispelColor.none
		f:SetBackdropBorderColor(c[1], c[2], c[3])

		f:Show()
	else
		f:Hide()
	end
end

local function Update(self, event, unit, isFullUpdate, updatedAuras)
	if not unit or self.unit ~= unit then return end

	local _name, _icon, _count, _dtype, _duration, _endTime, _spellID, _timeMod
	local _stackThreshold, _priority, priority = 0, 0, 0

	--store if the unit its charmed, mind controlled units (Imperial Vizier Zor'lok: Convert)
	local isCharmed = UnitIsCharmed(unit)

	--store if we cand attack that unit, if its so the unit its hostile (Amber-Shaper Un'sok: Reshape Life)
	local canAttack = UnitCanAttack('player', unit)

	local index = 1
	local name, icon, count, debuffType, duration, expiration, _, _, _, spellID, _, _, _, _, modRate = UnitAura(unit, index, 'HARMFUL')
	while name do
		--we coudln't dispel if the unit its charmed, or its not friendly
		if addon.ShowDispellableDebuff and (self.RaidDebuffs.showDispellableDebuff ~= false) and debuffType and (not isCharmed) and (not canAttack) then
			if addon.FilterDispellableDebuff then
				DispelPriority[debuffType] = (DispelPriority[debuffType] or 0) + addon.priority --Make Dispel buffs on top of Boss Debuffs

				priority = DispelFilter[debuffType] and DispelPriority[debuffType] or 0
				if priority == 0 then
					debuffType = nil
				end
			else
				priority = DispelPriority[debuffType] or 0
			end

			if priority > _priority then
				_priority, _name, _icon, _count, _dtype, _duration, _endTime, _spellID, _timeMod = priority, name, icon, count, debuffType, duration, expiration, spellID, modRate
			end
		end

		local debuff
		if self.RaidDebuffs.onlyMatchSpellID then
			debuff = debuff_data[spellID]
		else
			if debuff_data[spellID] then
				debuff = debuff_data[spellID]
			else
				debuff = debuff_data[name]
			end
		end

		priority = debuff and debuff.priority
		if priority and not blackList[spellID] and (priority > _priority) then
			_priority, _name, _icon, _count, _dtype, _duration, _endTime, _spellID, _timeMod = priority, name, icon, count, debuffType, duration, expiration, spellID, modRate
		end

		index = index + 1
		name, icon, count, debuffType, duration, expiration, _, _, _, spellID, _, _, _, _, modRate = UnitAura(unit, index, 'HARMFUL')
	end

	if self.RaidDebuffs.forceShow then
		_spellID = 5782
		_name, _, _icon = GetSpellInfo(_spellID)
		_count, _dtype, _duration, _endTime, _stackThreshold = 5, 'Magic', 0, 60, 0
	end

	if _name then
		_stackThreshold = debuff_data[addon.MatchBySpellName and _name or _spellID] and debuff_data[addon.MatchBySpellName and _name or _spellID].stackThreshold or _stackThreshold
	end

	UpdateDebuff(self, _name, _icon, _count, _dtype, _duration, _endTime, _spellID, _stackThreshold, _timeMod)

	--Reset the DispelPriority
	DispelPriority.Magic = 4
	DispelPriority.Curse = 3
	DispelPriority.Disease = 2
	DispelPriority.Poison = 1
end

local function Enable(self)
	if self.RaidDebuffs then
		oUF:RegisterEvent(self, 'UNIT_AURA', Update)

		return true
	end
end

local function Disable(self)
	if self.RaidDebuffs then
		oUF:UnregisterEvent(self, 'UNIT_AURA', Update)

		self.RaidDebuffs:Hide()
	end
end

local frame = CreateFrame('Frame')
frame:SetScript('OnEvent', CheckDispel)
frame:RegisterEvent('UNIT_PET', CheckDispel)

if oUF.isRetail or oUF.isWrath then
	frame:RegisterEvent('PLAYER_TALENT_UPDATE')
	frame:RegisterEvent('CHARACTER_POINTS_CHANGED')
end

if oUF.isRetail then
	frame:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
end

oUF:AddElement('RaidDebuffs', Update, Enable, Disable)
