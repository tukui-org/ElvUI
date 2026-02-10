local _, ns = ...
local oUF = ns.oUF
local AuraFiltered = oUF.AuraFiltered

local LibDispel = LibStub('LibDispel-1.0')
local DebuffColors = LibDispel:GetDebuffTypeColor()
local DispelFilter = LibDispel:GetMyDispelTypes()
local BlockList = LibDispel:GetBlockList()

local next = next
local UnitCanAssist = UnitCanAssist

local function DebuffLoop(_, check, list, name, icon, _, auraType, _, _, _, _, _, spellID)
	local allowSpell = oUF:NotSecretValue(spellID)
	local spell = list and (allowSpell and oUF:NotSecretValue(name)) and (list[spellID] or list[name])

	if spell then
		if spell.enable then
			return auraType, icon, true, spell.style, spell.color
		end
	elseif oUF:NotSecretValue(auraType) and auraType then
		local allow = not check
		if not allow then
			allow = DispelFilter[auraType]
		end

		if allow and not BlockList[spellID] then
			return auraType, icon
		end
	end
end

local function BuffLoop(_, _, list, name, icon, _, auraType, _, _, source, _, _, spellID)
	local spell = list and (oUF:NotSecretValue(spellID) and oUF:NotSecretValue(name)) and (list[spellID] or list[name])
	if spell and spell.enable and (not spell.ownOnly or source == 'player') then
		return auraType, icon, true, spell.style, spell.color
	end
end

local function MidnightLoop(aura, _, _, _, icon, _, auraType)
	if aura.auraIsRaidPlayerDispellable then
		return auraType, icon
	end
end

local function Looper(unit, filter, check, list, func)
	local unitAuraFiltered = AuraFiltered[filter][unit]
	local auraInstanceID, aura = next(unitAuraFiltered)
	while aura do
		local name, icon, count, auraType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID = oUF:UnpackAuraData(aura)
		local AuraType, Icon, filtered, style, color = func(aura, check, list, name, icon, count, auraType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID)

		if Icon then
			return aura, AuraType, Icon, filtered, style, color
		end

		auraInstanceID, aura = next(unitAuraFiltered, auraInstanceID)
	end
end

local function GetAuraType(unit, check, list)
	if not unit or not UnitCanAssist('player', unit) then return end

	local aura, auraType, icon, filtered, style, color = Looper(unit, 'HARMFUL', check, list, oUF.isRetail and MidnightLoop or DebuffLoop)
	if icon then
		return aura, auraType, icon, filtered, style, color
	end

	if not oUF.isRetail then
		aura, auraType, icon, filtered, style, color = Looper(unit, 'HELPFUL', check, list, BuffLoop)

		if icon then
			return aura, auraType, icon, filtered, style, color
		end
	end
end

local function Update(self, event, unit, updateInfo)
	if oUF:ShouldSkipAuraUpdate(self, event, unit, updateInfo) then return end

	local aura, auraType, texture, wasFiltered, style, color = GetAuraType(unit, self.AuraHighlightFilter, self.AuraHighlightFilterTable)

	if wasFiltered then
		if style == 'GLOW' and self.AuraHightlightGlow then
			self.AuraHightlightGlow:Show()
			self.AuraHightlightGlow:SetBackdropBorderColor(color.r, color.g, color.b)
		elseif self.AuraHightlightGlow then
			self.AuraHightlightGlow:Hide()
			self.AuraHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
		end
	elseif auraType then
		if not color then
			color = oUF:NotSecretValue(auraType) and DebuffColors[auraType] or DebuffColors.None
		end

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
		self.AuraHighlight:PostUpdate(self, unit, aura, auraType, texture, wasFiltered, style, color)
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

oUF:AddElement('AuraHighlight', Update, Enable, Disable)
