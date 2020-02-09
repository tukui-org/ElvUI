local _, ns = ...
local oUF = ns.oUF
if not oUF then return end

local playerClass = select(2, UnitClass('player'))

local Classic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

local DispelList, BlackList = {}, {}

if Classic then
	DispelList.PRIEST = { Magic = true, Disease = true }
	DispelList.SHAMAN = { Poison = true, Disease = true }
	DispelList.PALADIN = { Magic = true, Poison = true, Disease = true }
	DispelList.MAGE = { Curse = true }
	DispelList.DRUID = { Curse = true, Poison = true }
	DispelList.WARLOCK = { Magic = true }
else
	DispelList.PRIEST = { Magic = true, Disease = true }
	DispelList.SHAMAN = { Magic = false, Curse = true }
	DispelList.PALADIN = { Magic = false, Poison = true, Disease = true }
	DispelList.DRUID = { Magic = false, Curse = true, Poison = true, Disease = false }
	DispelList.MONK = { Magic = false, Poison = true, Disease = true }
	DispelList.MAGE = { Curse = true }
end

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

local DispellPriority = { Magic = 4, Curse = 3, Disease = 2, Poison = 1 }
local FilterList = {}

local function GetAuraType(unit, filter, filterTable)
--	local isCharmed = UnitIsCharmed(unit)
--	local canAttack = UnitCanAttack("player", unit)

	if not unit or not UnitCanAssist('player', unit) then return nil end

	local i = 1
	while true do
		local name, texture, _, debufftype, _, _, _, _, _, spellID = UnitAura(unit, i, 'HARMFUL')
		if not texture then break end

		local filterSpell = filterTable[spellID] or filterTable[name]

		if (filterTable and filterSpell) then
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
		local _, texture, _, debufftype, _, _, _, _, _, spellID = UnitAura(unit, i)
		if not texture then break end

		local filterSpell = filterTable[spellID]

		if (filterTable and filterSpell) then
			if filterSpell.enable then
				return debufftype, texture, true, filterSpell.style, filterSpell.color
			end
		end

		i = i + 1
	end
end

local function FilterTable()
	return debufftype, texture, true, filterSpell.style, filterSpell.color
end

local function CheckTalentTree(tree)
	local activeGroup = GetActiveSpecGroup()

	if activeGroup and GetSpecialization(false, false, activeGroup) then
		return tree == GetSpecialization(false, false, activeGroup)
	end
end

local function CheckSpec(self, event, levels)
	if event == 'CHARACTER_POINTS_CHANGED' and levels > 0 then return end

	if not Classic then
		-- Check for certain talents to see if we can dispel magic or not
		if playerClass == 'PALADIN' then
			if CheckTalentTree(1) then
				CanDispel.Magic = true
			else
				CanDispel.Magic = false
			end
		elseif playerClass == 'SHAMAN' then
			if CheckTalentTree(3) then
				CanDispel.Magic = true
			else
				CanDispel.Magic = false
			end
		elseif playerClass == 'DRUID' then
			if CheckTalentTree(4) then
				CanDispel.Magic = true
			else
				CanDispel.Magic = false
			end
		elseif playerClass == 'MONK' then
			if CheckTalentTree(2) then
				CanDispel.Magic = true
			else
				CanDispel.Magic = false
			end
		end
	end
end

local function Update(object, event, unit)
	if unit ~= object.unit then return; end

	local debuffType, texture, wasFiltered, style, color = GetAuraType(unit, object.AuraHighlightFilter, object.AuraHighlightFilterTable)

	if(wasFiltered) then
		if style == 'GLOW' and object.AuraHightlightGlow then
			object.AuraHightlightGlow:Show()
			object.AuraHightlightGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		elseif object.AuraHightlightGlow then
			object.AuraHightlightGlow:Hide()
			object.AuraHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
		end
	elseif debuffType then
		color = DebuffTypeColor[debuffType or 'none']
		if object.AuraHighlightBackdrop and object.AuraHightlightGlow then
			object.AuraHightlightGlow:Show()
			object.AuraHightlightGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		elseif object.AuraHighlightUseTexture then
			object.AuraHighlight:SetTexture(texture)
		else
			object.AuraHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
		end
	else
		if object.AuraHightlightGlow then
			object.AuraHightlightGlow:Hide()
		end

		if object.AuraHighlightUseTexture then
			object.AuraHighlight:SetTexture(nil)
		else
			object.AuraHighlight:SetVertexColor(0, 0, 0, 0)
		end
	end

	if object.AuraHighlight.PostUpdate then
		object.AuraHighlight:PostUpdate(object, debuffType, texture, wasFiltered, style, color)
	end
end

local function Enable(self)
	local element = self.AuraHighlight
	if element then

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

		if self.AuraHighlight then
			self.AuraHighlight:SetVertexColor(0, 0, 0, 0)
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
