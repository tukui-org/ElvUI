local _, ns = ...
local oUF = ns.oUF

local UnitAura = UnitAura
local UnitCanAssist = UnitCanAssist
local BlackList = {}
-- GLOBALS: DebuffTypeColor

local LibDispel = _G.LibStub('LibDispel-1.0')

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
	elseif debuffType then
		local allow = not check
		if not allow then
			local filter = LibDispel:GetMyDispelTypes()
			allow = filter and filter[debuffType]
		end

		if allow and not (BlackList[spellID] or BlackList[name]) then
			return debuffType, icon
		end
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

oUF:AddElement('AuraHighlight', Update, Enable, Disable)
