local _, ns = ...
local oUF = ns.oUF

local UnitAura = UnitAura
local UnitCanAssist = UnitCanAssist

local LibDispel = LibStub('LibDispel-1.0')
local DebuffColors = LibDispel:GetDebuffTypeColor()
local DispelFilter = LibDispel:GetMyDispelTypes()
local BlockList = LibDispel:GetBlockList()
local BleedList = LibDispel:GetBleedList()

local function DebuffLoop(check, list, name, icon, _, auraType, _, _, _, _, _, spellID)
	local spell = list and (list[spellID] or list[name])
	local dispelType = auraType or (BleedList[spellID] and 'Bleed') or nil

	if spell then
		if spell.enable then
			return dispelType, icon, true, spell.style, spell.color
		end
	elseif dispelType then
		local allow = not check
		if not allow then
			allow = DispelFilter[dispelType]
		end

		if allow and not BlockList[spellID] then
			return dispelType, icon
		end
	end
end

local function BuffLoop(_, list, name, icon, _, auraType, _, _, source, _, _, spellID)
	local spell = list and (list[spellID] or list[name])
	if spell and spell.enable and (not spell.ownOnly or source == 'player') then
		return auraType, icon, true, spell.style, spell.color
	end
end

local function Looper(unit, filter, check, list, func)
	local index = 1
	local name, icon, count, auraType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID = UnitAura(unit, index, filter)
	while name do
		local AuraType, Icon, filtered, style, color = func(check, list, name, icon, count, auraType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID)
		if Icon then
			return AuraType, Icon, filtered, style, color
		else
			index = index + 1
			name, icon, count, auraType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID = UnitAura(unit, index, filter)
		end
	end
end

local function GetAuraType(unit, check, list)
	if not unit or not UnitCanAssist('player', unit) then return end

	local auraType, icon, filtered, style, color = Looper(unit, 'HARMFUL', check, list, DebuffLoop)
	if icon then return auraType, icon, filtered, style, color end

	auraType, icon, filtered, style, color = Looper(unit, 'HELPFUL', check, list, BuffLoop)
	if icon then return auraType, icon, filtered, style, color end
end

local function Update(self, event, unit, isFullUpdate, updatedAuras)
	if not unit or self.unit ~= unit then return end

	local auraType, texture, wasFiltered, style, color = GetAuraType(unit, self.AuraHighlightFilter, self.AuraHighlightFilterTable)

	if wasFiltered then
		if style == 'GLOW' and self.AuraHightlightGlow then
			self.AuraHightlightGlow:Show()
			self.AuraHightlightGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		elseif self.AuraHightlightGlow then
			self.AuraHightlightGlow:Hide()
			self.AuraHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
		end
	elseif auraType then
		color = DebuffColors[auraType or 'none']

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
		self.AuraHighlight:PostUpdate(self, auraType, texture, wasFiltered, style, color)
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

oUF:AddElement('AuraHighlight', Update, Enable, Disable)
