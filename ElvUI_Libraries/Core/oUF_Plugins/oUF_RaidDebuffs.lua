local _, ns = ...
local oUF = ns.oUF or oUF
local AuraFiltered = oUF.AuraFiltered

local _G = _G
local addon = {}

ns.oUF_RaidDebuffs = addon
_G.oUF_RaidDebuffs = ns.oUF_RaidDebuffs
if not _G.oUF_RaidDebuffs then
	_G.oUF_RaidDebuffs = addon
end

local LibDispel = LibStub('LibDispel-1.0')
local DispelFilter = LibDispel:GetMyDispelTypes()
local DebuffColors = LibDispel:GetDebuffTypeColor()

local abs = math.abs
local type, next, pairs, wipe = type, next, pairs, wipe

local UnpackAuraData = AuraUtil.UnpackAuraData
local UnitCanAttack = UnitCanAttack
local UnitIsCharmed = UnitIsCharmed
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

local function FormatTime(sec)
	if sec > 60 then
		return '%dm', sec / 60
	elseif sec < 1 then
		return '%.1f', sec
	else
		return '%d', sec
	end
end

local function AddSpell(spell, priority, stackThreshold)
	if addon.MatchBySpellName and type(spell) == 'number' then
		spell = oUF:GetSpellInfo(spell)
	end

	if spell then
		debuff_data[spell] = {
			priority = (addon.priority + priority),
			stackThreshold = stackThreshold,
		}
	end
end

function addon:RegisterDebuffs(t)
	for spell in pairs(t) do
		if type(t[spell]) == 'boolean' then
			local oldValue = t[spell]
			t[spell] = { enable = oldValue, priority = 0, stackThreshold = 0 }
		elseif t[spell].enable then
			AddSpell(spell, t[spell].priority or 0, t[spell].stackThreshold or 0)
		end
	end
end

function addon:ResetDebuffData()
	wipe(debuff_data)
end

local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if self.elapsed >= 0.1 then
		local timeLeft = self.endTime - GetTime()

		if self.reverse and self.duration then
			timeLeft = abs(timeLeft - self.duration)
		end

		if timeLeft > 0 then
			self.time:SetFormattedText(FormatTime(timeLeft))
		else
			self:SetScript('OnUpdate', nil)
			self.time:Hide()
		end

		self.elapsed = 0
	end
end

local function UpdateDebuff(self, name, icon, count, debuffType, duration, endTime, spellID, stackThreshold, modRate)
	local element = self.RaidDebuffs
	if name and (count >= stackThreshold) then
		element.icon:SetTexture(icon)
		element.icon:Show()

		element.modRate = modRate
		element.endTime = endTime
		element.duration = duration
		element.reverse = element.ReverseTimer and element.ReverseTimer[spellID]

		if element.count then
			if count and (count > 1) then
				element.count:SetText(count)
				element.count:Show()
			else
				element.count:SetText('')
				element.count:Hide()
			end
		end

		if element.time then
			if duration and (duration > 0) then
				element.nextUpdate = 0
				element:SetScript('OnUpdate', OnUpdate)
				element.time:Show()
			else
				element:SetScript('OnUpdate', nil)
				element.time:Hide()
			end
		end

		if element.cd then
			if duration and (duration > 0) then
				element.cd:SetCooldown(endTime - duration, duration, modRate)
				element.cd:Show()
			else
				element.cd:Hide()
			end
		end

		local c = DebuffColors[debuffType] or DebuffColors.none
		element:SetBackdropBorderColor(c.r, c.g, c.b)

		element:Show()
	else
		element:Hide()
	end

	if element.PostUpdate then
		element:PostUpdate(name, icon, count, debuffType, duration, endTime, spellID, stackThreshold, modRate)
	end
end

local function Update(self, event, unit, updateInfo)
	if oUF:ShouldSkipAuraUpdate(self, event, unit, updateInfo) then return end

	local element = self.RaidDebuffs
	local _name, _icon, _count, _dtype, _duration, _endTime, _spellID, _modRate
	local _stackThreshold, _priority = 0, 0

	if element.forceShow then
		_spellID, _count, _dtype, _duration, _endTime, _stackThreshold, _modRate = 5782, 5, 'Magic', 0, 60, 0, 1
		_name, _, _icon = oUF:GetSpellInfo(_spellID)
	else
		local isCharmed = UnitIsCharmed(unit) -- store if the unit its charmed, mind controlled units (Imperial Vizier Zor'lok: Convert)
		local canAttack = UnitCanAttack('player', unit) -- store if we cand attack that unit, if its so the unit its hostile (Amber-Shaper Un'sok: Reshape Life)

		local index = 1
		local unitAuraFiltered = AuraFiltered.HARMFUL[unit]
		local auraInstanceID, aura = next(unitAuraFiltered)
		while aura do
			local name, icon, count, debuffType, duration, expiration, _, _, _, spellID, _, _, _, _, modRate = UnpackAuraData(aura)

			-- we coudln't dispel if the unit its charmed, or its not friendly
			if debuffType and (not isCharmed and not canAttack) and addon.ShowDispellableDebuff and (element.showDispellableDebuff ~= false) then
				local priority
				if addon.FilterDispellableDebuff then
					DispelPriority[debuffType] = (DispelPriority[debuffType] or 0) + addon.priority -- Make Dispel buffs on top of Boss Debuffs

					priority = (DispelFilter[debuffType] and DispelPriority[debuffType]) or 0

					if priority == 0 then
						debuffType = nil
					end
				else
					priority = DispelPriority[debuffType] or 0
				end

				if priority > _priority then
					_priority, _name, _icon, _count, _dtype, _duration, _endTime, _spellID, _modRate = priority, name, icon, count, debuffType, duration, expiration, spellID, modRate
				end
			end

			-- handle from the list
			local data = debuff_data[spellID] or (not element.onlyMatchSpellID and debuff_data[name])
			local priority = data and data.priority
			if priority and (priority > _priority) then
				_priority, _name, _icon, _count, _dtype, _duration, _endTime, _spellID, _modRate = priority, name, icon, count, debuffType, duration, expiration, spellID, modRate
			end

			index = index + 1
			auraInstanceID, aura = next(unitAuraFiltered, auraInstanceID)
		end
	end

	local data = _name and debuff_data[addon.MatchBySpellName and _name or _spellID]
	if data and data.stackThreshold then
		_stackThreshold = data.stackThreshold
	end

	UpdateDebuff(self, _name, _icon, _count, _dtype, _duration, _endTime, _spellID, _stackThreshold, _modRate)

	-- Reset the DispelPriority
	DispelPriority.Magic = 4
	DispelPriority.Curse = 3
	DispelPriority.Disease = 2
	DispelPriority.Poison = 1
end

local function Enable(self)
	if self.RaidDebuffs then
		self:RegisterEvent('UNIT_AURA', Update)

		return true
	end
end

local function Disable(self)
	if self.RaidDebuffs then
		self:UnregisterEvent('UNIT_AURA', Update)

		self.RaidDebuffs:Hide()
	end
end

oUF:AddElement('RaidDebuffs', Update, Enable, Disable)
