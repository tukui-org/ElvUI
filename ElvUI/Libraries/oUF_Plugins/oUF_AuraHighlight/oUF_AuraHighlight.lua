local _, ns = ...
local oUF = ns.oUF
if not oUF then return end

local UnitAura = UnitAura
local UnitCanAssist = UnitCanAssist
local GetSpecialization = GetSpecialization
local GetActiveSpecGroup = GetActiveSpecGroup
local Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local DispelList, BlackList = {}, {}
-- GLOBALS: DebuffTypeColor

--local DispellPriority = { Magic = 4, Curse = 3, Disease = 2, Poison = 1 }
--local FilterList = {}

if Classic then
	DispelList.PRIEST	= { Magic = true, Disease = true }
	DispelList.SHAMAN	= { Poison = true, Disease = true }
	DispelList.PALADIN	= { Magic = true, Poison = true, Disease = true }
	DispelList.MAGE		= { Curse = true }
	DispelList.DRUID	= { Curse = true, Poison = true }
	DispelList.WARLOCK	= { Magic = true }
else
	DispelList.PRIEST	= { Magic = true, Disease = true }
	DispelList.SHAMAN	= { Magic = false, Curse = true }
	DispelList.PALADIN	= { Magic = false, Poison = true, Disease = true }
	DispelList.DRUID	= { Magic = false, Curse = true, Poison = true, Disease = false }
	DispelList.MONK		= { Magic = false, Poison = true, Disease = true }
	DispelList.MAGE		= { Curse = true }
end

local playerClass = select(2, UnitClass('player'))
local CanDispel = DispelList[playerClass] or {}

if not Classic then
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

local function GetAuraType(unit, filter, filterTable)
	if not unit or not UnitCanAssist('player', unit) then return end

	local i = 1
	while true do
		local name, texture, _, debufftype, _, _, _, _, _, spellID = UnitAura(unit, i, 'HARMFUL')
		if not texture then break end

		local filterSpell = filterTable[spellID] or filterTable[name]
		if filterTable and filterSpell then
			if filterSpell.enable then
				return debufftype, texture, true, filterSpell.style, filterSpell.color
			end
		elseif debufftype and (not filter or (filter and CanDispel[debufftype])) and not (BlackList[name] or BlackList[spellID]) then
			return debufftype, texture
		end

		i = i + 1
	end

	i = 1
	while true do
		local _, texture, _, debufftype, _, _, caster, _, _, spellID = UnitAura(unit, i)
		if not texture then break end

		local filterSpell = filterTable[spellID]
		if filterTable and filterSpell and filterSpell.enable and (not filterSpell.ownOnly or caster == 'player') then
			return debufftype, texture, true, filterSpell.style, filterSpell.color
		end

		i = i + 1
	end
end

--[[
local function FilterTable()
	local debufftype, texture, filterSpell
	return debufftype, texture, true, filterSpell.style, filterSpell.color
end
]]

local function CheckTalentTree(tree)
	local activeGroup = GetActiveSpecGroup()
	local spec = activeGroup and GetSpecialization(false, false, activeGroup)

	if spec then
		return tree == spec
	end
end

local function CheckSpec()
	if Classic then return end

	-- Check for certain talents to see if we can dispel magic or not
	if playerClass == 'PALADIN' then
		CanDispel.Magic = CheckTalentTree(1)
	elseif playerClass == 'SHAMAN' then
		CanDispel.Magic = CheckTalentTree(3)
	elseif playerClass == 'DRUID' then
		CanDispel.Magic = CheckTalentTree(4)
	elseif playerClass == 'MONK' then
		CanDispel.Magic = CheckTalentTree(2)
	end
end

local function Update(self, _, unit)
	if unit ~= self.unit then return end

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
		self:RegisterEvent('UNIT_AURA', Update)
		return true
	end
end

local function Disable(self)
	local element = self.AuraHighlight
	if element then
		self:UnregisterEvent('UNIT_AURA', Update)

		if self.AuraHightlightGlow then
			self.AuraHightlightGlow:Hide()
		end

		if element then
			element:SetVertexColor(0, 0, 0, 0)
		end
	end
end

local f = CreateFrame('Frame')
f:RegisterEvent('CHARACTER_POINTS_CHANGED')

if not Classic then
	f:RegisterEvent('PLAYER_TALENT_UPDATE')
	f:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
end

f:SetScript('OnEvent', CheckSpec)

oUF:AddElement('AuraHighlight', Update, Enable, Disable)
