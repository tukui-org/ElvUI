local _, ns = ...
local oUF = ns.oUF

local next = next
local UnitAura = UnitAura
local IsSpellKnown = IsSpellKnown
local UnitCanAssist = UnitCanAssist
local GetSpecialization = GetSpecialization
local GetActiveSpecGroup = GetActiveSpecGroup
local BlackList = {}
-- GLOBALS: DebuffTypeColor

--local DispellPriority = { Magic = 4, Curse = 3, Disease = 2, Poison = 1 }
--local FilterList = {}

local DispelList = {
	PALADIN = { Poison = true, Disease = true },
	PRIEST = { Magic = true, Disease = true },
	MONK = { Disease = true, Poison = true },
	DRUID = { Curse = true, Poison = true },
	MAGE = { Curse = true },
	WARLOCK = {},
	SHAMAN = {}
}

if oUF.isRetail then
	DispelList.SHAMAN.Curse = true
else
	DispelList.SHAMAN.Poison = true
	DispelList.SHAMAN.Disease = true

	DispelList.PALADIN.Magic = true
end

local playerClass = select(2, UnitClass('player'))
local DispelFilter = DispelList[playerClass] or {}

if oUF.isRetail then
	BlackList[140546] = true -- Fully Mutated
	BlackList[136184] = true -- Thick Bones
	BlackList[136186] = true -- Clear mind
	BlackList[136182] = true -- Improved Synapses
	BlackList[136180] = true -- Keen Eyesight
	BlackList[105171] = true -- Deep Corruption
	BlackList[108220] = true -- Deep Corruption
	BlackList[116095] = true -- Disable, Slow
	BlackList[137637] = true -- Warbringer, Slow
end

local function DebuffLoop(check, list, name, icon, _, debuffType, _, _, _, _, _, spellID)
	local spell = list and (list[spellID] or list[name])
	if spell then
		if spell.enable then
			return debuffType, icon, true, spell.style, spell.color
		end
	elseif debuffType and (not check or DispelFilter[debuffType]) and not (BlackList[spellID] or BlackList[name]) then
		return debuffType, icon
	end
end

local function BuffLoop(_, list, name, icon, _, debuffType, _, _, source, _, _, spellID)
	local spell = list and (list[spellID] or list[name])
	if spell and spell.enable and (not spell.ownOnly or source == 'player') then
		return debuffType, icon, true, spell.style, spell.color
	end
end

local function Looper(unit, filter, check, list, func)
	local index = 1
	local name, icon, count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID = UnitAura(unit, index, filter)
	while name do
		local DebuffType, Icon, filtered, style, color = func(check, list, name, icon, count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID)
		if Icon then
			return DebuffType, Icon, filtered, style, color
		else
			index = index + 1
			name, icon, count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID = UnitAura(unit, index, filter)
		end
	end
end

local function GetAuraType(unit, check, list)
	if not unit or not UnitCanAssist('player', unit) then return end

	local debuffType, icon, filtered, style, color = Looper(unit, 'HARMFUL', check, list, DebuffLoop)
	if icon then return debuffType, icon, filtered, style, color end

	debuffType, icon, filtered, style, color = Looper(unit, 'HELPFUL', check, list, BuffLoop)
	if icon then return debuffType, icon, filtered, style, color end
end

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
		DispelFilter.Curse = CheckTalentTree(3) -- TODO: Maybe instead check specifically for Cleanse Spirit instead?
	end
end

local function Update(self, event, unit, isFullUpdate, updatedAuras)
	if not unit or self.unit ~= unit then return end

	local debuffType, texture, wasFiltered, style, color = GetAuraType(unit, self.AuraHighlightFilter, self.AuraHighlightFilterTable)

	if wasFiltered then
		if style == 'GLOW' and self.AuraHightlightGlow then
			self.AuraHightlightGlow:Show()
			self.AuraHightlightGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		elseif self.AuraHightlightGlow then
			self.AuraHightlightGlow:Hide()
			self.AuraHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
		end
	elseif debuffType then
		color = DebuffTypeColor[debuffType or 'none']

		if self.AuraHighlightBackdrop and self.AuraHightlightGlow then
			self.AuraHightlightGlow:Show()
			self.AuraHightlightGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		elseif self.AuraHighlightUseTexture then
			self.AuraHighlight:SetTexture(texture)
		else
			self.AuraHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
		end
	else
		if self.AuraHightlightGlow then
			self.AuraHightlightGlow:Hide()
		end

		if self.AuraHighlightUseTexture then
			self.AuraHighlight:SetTexture(nil)
		else
			self.AuraHighlight:SetVertexColor(0, 0, 0, 0)
		end
	end

	if self.AuraHighlight.PostUpdate then
		self.AuraHighlight:PostUpdate(self, debuffType, texture, wasFiltered, style, color)
	end
end

local function Enable(self)
	if self.AuraHighlight then
		oUF:RegisterEvent(self, 'UNIT_AURA', Update)

		return true
	end
end

local function Disable(self)
	local element = self.AuraHighlight
	if element then
		oUF:UnregisterEvent(self, 'UNIT_AURA', Update)

		if self.AuraHightlightGlow then
			self.AuraHightlightGlow:Hide()
		end

		if element then
			element:SetVertexColor(0, 0, 0, 0)
		end
	end
end

local frame = CreateFrame('Frame')
frame:SetScript('OnEvent', CheckDispel)
frame:RegisterEvent('UNIT_PET', CheckDispel)

if oUF.isRetail then
	frame:RegisterEvent('PLAYER_TALENT_UPDATE')
	frame:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
	frame:RegisterEvent('CHARACTER_POINTS_CHANGED')
end

oUF:AddElement('AuraHighlight', Update, Enable, Disable)
