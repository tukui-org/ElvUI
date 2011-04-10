local E, C, L, DB = unpack(select(2, ...)) -- Import: E - functions, constants, variables; C - config; L - locales
-- yleaf (yaroot@gmail.com)

if C.unitframes.enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF

local addon = {}
ns.oUF_RaidDebuffs = addon
oUF_RaidDebuffs = ns.oUF_RaidDebuffs
if not _G.oUF_RaidDebuffs then
	_G.oUF_RaidDebuffs = addon
end

local debuff_data = {}
addon.DebuffData = debuff_data


addon.ShowDispelableDebuff = true
addon.FilterDispellableDebuff = true
addon.MatchBySpellName = true


addon.priority = 10

local function add(spell)
	if addon.MatchBySpellName and type(spell) == 'number' then
		spell = GetSpellInfo(spell)
	end
	
	debuff_data[spell] = addon.priority
	addon.priority = addon.priority + 1
end

function addon:RegisterDebuffs(t)
	for spell, value in pairs(t) do
		if value == true then
			add(spell)
		end
	end
end

function addon:ResetDebuffData()
	wipe(debuff_data)
	addon.priority = 10
end

local DispellColor = {
	['Magic']	= {.2, .6, 1},
	['Curse']	= {.6, 0, 1},
	['Disease']	= {.6, .4, 0},
	['Poison']	= {0, .6, 0},
	['none'] = {unpack(C.media.bordercolor)},
}

local DispellPriority = {
	['Magic']	= 4,
	['Curse']	= 3,
	['Disease']	= 2,
	['Poison']	= 1,
}

local DispellFilter
do
	local dispellClasses = {
		['PRIEST'] = {
			['Magic'] = true,
			['Disease'] = true,
		},
		['SHAMAN'] = {
			['Magic'] = false,
			['Curse'] = true,
		},
		['PALADIN'] = {
			['Poison'] = true,
			['Magic'] = false,
			['Disease'] = true,
		},
		['MAGE'] = {
			['Curse'] = true,
		},
		['DRUID'] = {
			['Magic'] = false,
			['Curse'] = true,
			['Poison'] = true,
		},
	}
	
	DispellFilter = dispellClasses[select(2, UnitClass('player'))] or {}
end

-- Return true if the talent matching the name of the spell given by (Credit Pitbull4)
-- spellid has at least one point spent in it or false otherwise
local function CheckForKnownTalent(spellid)
	local wanted_name = GetSpellInfo(spellid)
	if not wanted_name then return nil end
	local num_tabs = GetNumTalentTabs()
	for t=1, num_tabs do
		local num_talents = GetNumTalents(t)
		for i=1, num_talents do
			local name_talent, _, _, _, current_rank = GetTalentInfo(t,i)
			if name_talent and (name_talent == wanted_name) then
				if current_rank and (current_rank > 0) then
					return true
				else
					return false
				end
			end
		end
	end
	return false
end

local function CheckSpec(self, event, levels)
	-- Not interested in gained points from leveling	
	if event == "CHARACTER_POINTS_CHANGED" and levels > 0 then return end
	
	--Check for certain talents to see if we can dispel magic or not
	if select(2, UnitClass('player')) == "PALADIN" then
		--Check to see if we have the 'Sacred Cleansing' talent.
		if CheckForKnownTalent(53551) then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false	
		end
	elseif select(2, UnitClass('player')) == "SHAMAN" then
		--Check to see if we have the 'Improved Cleanse Spirit' talent.
		if CheckForKnownTalent(77130) then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false	
		end
	elseif select(2, UnitClass('player')) == "DRUID" then
		--Check to see if we have the 'Nature's Cure' talent.
		if CheckForKnownTalent(88423) then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false	
		end
	end
end


local function formatTime(s)
	if s > 60 then
		return format('%dm', s/60), s%60
	elseif s < 1 then
		return format("%.1f", s), s - floor(s)
	else
		return format('%d', s), s - floor(s)
	end
end

local abs = math.abs
local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.1 then
		local timeLeft = self.endTime - GetTime()
		if self.reverse then timeLeft = abs((self.endTime - GetTime()) - self.duration) end
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

local function UpdateDebuff(self, name, icon, count, debuffType, duration, endTime, spellId)
	local f = self.RaidDebuffs
	if name then
		f.icon:SetTexture(icon)
		f.icon:Show()
		f.duration = duration
		
		if f.count then
			if count and (count > 1) then
				f.count:SetText(count)
				f.count:Show()
			else
				f.count:SetText("")
				f.count:Hide()
			end
		end
		
		if spellId and E.ReverseTimer[spellId] then
			f.reverse = true
		else
			f.reverse = nil
		end
		
		if f.time then
			if duration and (duration > 0) then
				f.endTime = endTime
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
				f.cd:SetCooldown(endTime - duration, duration)
				f.cd:Show()
			else
				f.cd:Hide()
			end
		end
		
		local c = DispellColor[debuffType] or DispellColor.none
		f:SetBackdropBorderColor(c[1], c[2], c[3])
		
		f:Show()
	else
		f:Hide()
	end
end

local function Update(self, event, unit)
	if unit ~= self.unit then return end
	local _name, _icon, _count, _dtype, _duration, _endTime, _spellId
	local _priority, priority = 0
	for i = 1, 40 do
		local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(unit, i, 'HARMFUL')
		if (not name) then break end
		
		if addon.ShowDispelableDebuff and debuffType then
			if addon.FilterDispellableDebuff then
				DispellPriority[debuffType] = DispellPriority[debuffType] + addon.priority --Make Dispell buffs on top of Boss Debuffs
				priority = DispellFilter[debuffType] and DispellPriority[debuffType]
			else
				priority = DispellPriority[debuffType]
			end
			
			if priority and (priority > _priority) then
				_priority, _name, _icon, _count, _dtype, _duration, _endTime, _spellId = priority, name, icon, count, debuffType, duration, expirationTime, spellId
			end
		end
		
		priority = debuff_data[addon.MatchBySpellName and name or spellId]
		if priority and (priority > _priority) then
			_priority, _name, _icon, _count, _dtype, _duration, _endTime, _spellId = priority, name, icon, count, debuffType, duration, expirationTime, spellId
		end
	end
	
	UpdateDebuff(self, _name, _icon, _count, _dtype, _duration, _endTime, _spellId)
	
	--Reset the DispellPriority
	DispellPriority = {
		['Magic']	= 4,
		['Curse']	= 3,
		['Disease']	= 2,
		['Poison']	= 1,
	}	
end

local function Enable(self)
	if self.RaidDebuffs then
		self:RegisterEvent('UNIT_AURA', Update)
		return true
	end
	--Need to run these always
	self:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", CheckSpec)
end

local function Disable(self)
	if self.RaidDebuffs then
		self:UnregisterEvent('UNIT_AURA', Update)
		self.RaidDebuffs:Hide()
	end
	self:UnregisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
	self:UnregisterEvent("CHARACTER_POINTS_CHANGED", CheckSpec)
end

oUF:AddElement('RaidDebuffs', Update, Enable, Disable)