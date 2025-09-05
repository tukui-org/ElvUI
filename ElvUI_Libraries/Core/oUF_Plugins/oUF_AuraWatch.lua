-- Original work by Astromech
-- Rewritten based on Auras by Azilroka and Simpy

local _, ns = ...
local oUF = ns.oUF
local AuraFiltered = oUF.AuraFiltered

local VISIBLE = 1
local HIDDEN = 0

local min, next, wipe, pairs, tinsert = min, next, wipe, pairs, tinsert
local GetSpellTexture = C_Spell.GetSpellTexture
local UnpackAuraData = AuraUtil.UnpackAuraData
local CreateFrame = CreateFrame
local UnitIsUnit = UnitIsUnit

local function CreateAuraIcon(element, index)
	local button = CreateFrame('Button', element:GetName() .. 'Button' .. index, element)
	button:EnableMouse(false)
	button:Hide()

	local cd = CreateFrame('Cooldown', '$parentCooldown', button, 'CooldownFrameTemplate')
	cd:SetAllPoints()
	cd:SetReverse(true)
	cd:SetDrawBling(false)
	cd:SetDrawEdge(false)

	local icon = button:CreateTexture(nil, 'ARTWORK')
	icon:SetAllPoints()

	local countFrame = CreateFrame('Frame', nil, button)
	countFrame:SetAllPoints(button)
	countFrame:SetFrameLevel(cd:GetFrameLevel() + 1)

	local count = countFrame:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
	count:SetPoint('BOTTOMRIGHT', countFrame, 'BOTTOMRIGHT', -1, 0)

	local overlay = button:CreateTexture(nil, 'OVERLAY')
	overlay:SetTexture([[Interface\Buttons\UI-Debuff-Overlays]])
	overlay:SetAllPoints()
	overlay:SetTexCoord(.296875, .5703125, 0, .515625)

	button.overlay = overlay
	button.icon = icon
	button.count = count
	button.cd = cd

	if element.PostCreateIcon then element:PostCreateIcon(button) end

	return button
end

local stackAuras = {}
local function CustomFilter(element, _, button, _, _, count)
	local spellID = button.spellID
	local setting = element.watched[spellID]
	if not setting then
		return false
	end

	local allowUnit = (not setting.anyUnit and button.isPlayer) or (setting.anyUnit and button.castByPlayer)
	if not allowUnit then
		return false
	end

	button.onlyShowMissing = setting.onlyShowMissing
	button.anyUnit = setting.anyUnit

	if element.allowStacks and element.allowStacks[spellID] then
		local total = (not count or count < 1) and 1 or count
		local stack = stackAuras[spellID] -- fake stacking for spells with same spell ID
		if not stack then
			stackAuras[spellID] = button
			button.matches = total
		else
			stack.matches = stack.matches + total
			stack.count:SetText(stack.matches)
			return false
		end
	elseif button.matches then
		button.matches = nil
	end

	return setting.enabled and not setting.onlyShowMissing
end

local function FetIcon(element, visible, offset)
	local position = visible + offset + 1
	local button = element[position]

	if not button then
		button = (element.CreateIcon or CreateAuraIcon) (element, position)

		tinsert(element, button)
		element.createdIcons = element.createdIcons + 1
	end

	return button, position
end

local function HandleElements(element, unit, button, setting, icon, count, duration, expiration, isDebuff, debuffType, isStealable, modRate)
	if button.cd then
		if duration and duration > 0 then
			button.cd:SetCooldown(expiration - duration, duration, modRate)
			button.cd:Show()
		else
			button.cd:Hide()
		end
	end

	if button.stealable then
		if not isDebuff and isStealable and element.showStealableBuffs and not UnitIsUnit(unit, 'player') then
			button.stealable:Show()
		else
			button.stealable:Hide()
		end
	end

	if button.count then
		if button.matches and button.matches > 1 then
			button.count:SetText(button.matches)
		elseif count and count > 1 then
			button.count:SetText(count)
		else
			button.count:SetText('')
		end
	end

	if button.overlay then
		if element.showType or (isDebuff and element.showDebuffType) or (not isDebuff and element.showBuffType) then
			local colors = element.__owner.colors.debuff
			local color = colors[debuffType] or colors.none

			button.overlay:SetVertexColor(color.r, color.g, color.b)
			button.overlay:Show()
		else
			button.overlay:Hide()
		end
	end

	if button.icon then
		button.icon:SetTexture(icon)
	end

	if not setting.sizeOffset or setting.sizeOffset == 0 then
		button:SetSize(element.size, element.size)
	else
		button:SetSize(setting.sizeOffset + element.size, setting.sizeOffset + element.size)
	end

	button:Show()
	button:ClearAllPoints()
	button:SetPoint(setting.point or 'TOPRIGHT', setting.xOffset or 0, setting.yOffset or 0)
end

local missing = {}
local function PreOnlyMissing(element)
	wipe(missing)

	for spellID, setting in pairs(element.watched) do
		if setting.enabled and setting.onlyShowMissing then
			missing[spellID] = setting
		end
	end
end

local function PostOnlyMissing(element, unit, offset)
	local visible = 0
	for spellID, setting in pairs(missing) do
		local button, position = FetIcon(element, visible, offset)

		button.spellID = spellID

		local icon = GetSpellTexture(spellID)
		HandleElements(element, unit, button, setting, icon)

		if element.PostUpdateIcon then
			element:PostUpdateIcon(unit, button, nil, position)
		end

		visible = visible + 1
	end

	return visible
end

local function UpdateIcon(element, unit, aura, index, offset, filter, isDebuff, visible)
	local name, icon, count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, modRate, effect1, effect2, effect3 = UnpackAuraData(aura)
	if not name then return end

	local button, position = FetIcon(element, visible, offset)

	button.aura = aura
	button.filter = filter
	button.spellID = spellID
	button.isDebuff = isDebuff
	button.debuffType = debuffType
	button.castByPlayer = castByPlayer
	button.isPlayer = source == 'player'

	button:SetID(index)

	local show = (element.CustomFilter or CustomFilter) (element, unit, button, aura, name, icon,
		count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID,
		canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, modRate, effect1, effect2, effect3)

	local setting = element.watched[spellID]
	if setting and setting.onlyShowMissing then
		missing[spellID] = nil
	end

	if show then
		HandleElements(element, unit, button, setting, icon, count, duration, expiration, isDebuff, debuffType, isStealable, modRate)

		if element.PostUpdateIcon then
			element:PostUpdateIcon(unit, button, index, position, duration, expiration, debuffType, isStealable)
		end

		return VISIBLE
	else
		return HIDDEN
	end
end

local function FilterIcons(element, unit, filter, limit, isDebuff, offset, dontHide)
	if not offset then offset = 0 end

	local index, visible, hidden = 1, 0, 0
	local unitAuraFiltered = AuraFiltered[filter][unit]
	local auraInstanceID, aura = next(unitAuraFiltered)
	while aura and (visible < limit) do
		local result = UpdateIcon(element, unit, aura, index, offset, filter, isDebuff, visible)
		if result == VISIBLE then
			visible = visible + 1
		elseif result == HIDDEN then
			hidden = hidden + 1
		end

		index = index + 1
		auraInstanceID, aura = next(unitAuraFiltered, auraInstanceID)
	end

	if not dontHide then
		for i = visible + offset + 1, #element do
			element[i]:Hide()
		end
	end

	return visible, hidden
end

local function UpdateAuras(self, event, unit, updateInfo)
	local element = self.AuraWatch
	if not element then return end

	if oUF:ShouldSkipAuraUpdate(self, event, unit, updateInfo) then return end

	if element.PreUpdate then element:PreUpdate(unit) end

	PreOnlyMissing(element)
	wipe(stackAuras) -- clear stacking table

	local numBuffs = element.numBuffs or 32
	local numDebuffs = element.numDebuffs or 16
	local numAuras = element.numTotal or (numBuffs + numDebuffs)

	local visibleBuffs, hiddenBuffs = FilterIcons(element, unit, element.buffFilter or element.filter or 'HELPFUL', min(numBuffs, numAuras), nil, 0, true)
	local visibleDebuffs, hiddenDebuffs = FilterIcons(element, unit, element.debuffFilter or element.filter or 'HARMFUL', min(numDebuffs, numAuras - visibleBuffs), true, visibleBuffs)

	element.visibleDebuffs = visibleDebuffs
	element.visibleBuffs = visibleBuffs

	element.visibleAuras = visibleBuffs + visibleDebuffs

	local visibleMissing = PostOnlyMissing(element, unit, element.visibleAuras)

	element.allAuras = visibleBuffs + visibleDebuffs + hiddenBuffs + hiddenDebuffs + visibleMissing

	if element.PostUpdate then element:PostUpdate(unit) end
end

local function Update(self, event, unit)
	if self.unit ~= unit then return end

	UpdateAuras(self, event, unit)
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function SetNewTable(element, table)
	element.watched = table or {}
end

local function Enable(self)
	local element = self.AuraWatch
	if element then
		element.__owner = self
		element.SetNewTable = SetNewTable
		element.ForceUpdate = ForceUpdate

		element.watched = element.watched or {}
		element.createdIcons = element.createdIcons or 0
		element.anchoredIcons = 0
		element.size = 8

		self:RegisterEvent('UNIT_AURA', UpdateAuras)

		element:Show()

		return true
	end
end

local function Disable(self)
	if self.AuraWatch then
		self:UnregisterEvent('UNIT_AURA', UpdateAuras)

		if self.AuraWatch then self.AuraWatch:Hide() end
	end
end

oUF:AddElement('AuraWatch', Update, Enable, Disable)
