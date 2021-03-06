-- Original work by Astromech
-- Rewritten based on Auras by Azilroka

local _, ns = ...
local oUF = ns.oUF

local VISIBLE = 1
local HIDDEN = 0

local min, wipe, pairs, tinsert = min, wipe, pairs, tinsert
local CreateFrame = CreateFrame
local UnitAura = UnitAura
local UnitIsUnit = UnitIsUnit
local GetSpellTexture = GetSpellTexture

local function createAuraIcon(element, index)
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

	if(element.PostCreateIcon) then element:PostCreateIcon(button) end

	return button
end

local function customFilter(element, _, button, name, _, _, debuffType, _, _, caster, isStealable, _, spellID, canApply, isBossDebuff, casterIsPlayer)
	local setting = element.watched[spellID]
	if not setting then return false end

	button.onlyShowMissing = setting.onlyShowMissing
	button.anyUnit = setting.anyUnit

	if setting.enabled then
		if setting.onlyShowMissing and not setting.anyUnit and caster == 'player' then
			return false
		elseif setting.onlyShowMissing and setting.anyUnit and casterIsPlayer then
			return true
		elseif not setting.onlyShowMissing and setting.anyUnit and casterIsPlayer then
			return true
		elseif not setting.onlyShowMissing and not setting.anyUnit and caster == 'player' then
			return true
		end
	end

	return false
end

local function updateIcon(element, unit, index, offset, filter, isDebuff, visible)
	local name, texture, count, debuffType, duration, expiration, caster, isStealable,
		nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll,
		timeMod, effect1, effect2, effect3 = UnitAura(unit, index, filter)

	if(name) then
		local position = visible + offset + 1
		local button = element[position]
		if(not button) then
			button = (element.CreateIcon or createAuraIcon) (element, position)

			tinsert(element, button)
			element.createdIcons = element.createdIcons + 1
		end

		button.caster = caster
		button.filter = filter
		button.isDebuff = isDebuff
		button.debuffType = debuffType
		button.spellID = spellID
		button.isPlayer = caster == 'player'

		local show = (element.CustomFilter or customFilter) (element, unit, button, name, texture,
			count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID,
			canApply, isBossDebuff, casterIsPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3)

		if(show) then
			local setting = element.watched[spellID]
			if(button.cd) then
				if(duration and duration > 0) then
					button.cd:SetCooldown(expiration - duration, duration)
					button.cd:Show()
				else
					button.cd:Hide()
				end
			end

			if(button.overlay) then
				if((isDebuff and element.showDebuffType) or (not isDebuff and element.showBuffType) or element.showType) then
					local color = element.__owner.colors.debuff[debuffType] or element.__owner.colors.debuff.none

					button.overlay:SetVertexColor(color[1], color[2], color[3])
					button.overlay:Show()
				else
					button.overlay:Hide()
				end
			end

			if(button.stealable) then
				if(not isDebuff and isStealable and element.showStealableBuffs and not UnitIsUnit(unit, 'player')) then
					button.stealable:Show()
				else
					button.stealable:Hide()
				end
			end

			if(button.icon) then button.icon:SetTexture(texture) end
			if(button.count) then button.count:SetText(count > 1 and count) end

			if setting.sizeOffset == 0 then
				button:SetSize(element.size, element.size)
			else
				button:SetSize(setting.sizeOffset + element.size, setting.sizeOffset + element.size)
			end

			button:SetID(index)
			button:Show()
			button:ClearAllPoints()
			button:SetPoint(setting.point, setting.xOffset, setting.yOffset)

			if(element.PostUpdateIcon) then
				element:PostUpdateIcon(unit, button, index, position, duration, expiration, debuffType, isStealable)
			end

			return VISIBLE
		else
			button.isFiltered = true
			return HIDDEN
		end
	end
end

local missing = {}
local function onlyShowMissingIcon(element, unit, offset)
	wipe(missing)

	for SpellID, setting in pairs(element.watched) do
		if setting.onlyShowMissing then
			missing[SpellID] = setting
		end
	end

	for i = 1, #element do
		local button = element[i]
		if button.isFiltered and missing[button.spellID] then
			missing[button.spellID] = nil
		end
	end

	local visible = 0
	for SpellID, setting in pairs(missing) do
		local position = visible + offset + 1
		local button = element[position]
		if(not button) then
			button = (element.CreateIcon or createAuraIcon) (element, position)
			tinsert(element, button)
			element.createdIcons = element.createdIcons + 1
		end

		if(button.cd) then button.cd:Hide() end
		if(button.icon) then button.icon:SetTexture(GetSpellTexture(SpellID)) end
		if(button.overlay) then button.overlay:Hide() end

		if setting.sizeOffset == 0 then
			button:SetSize(element.size, element.size)
		else
			button:SetSize(setting.sizeOffset + element.size, setting.sizeOffset + element.size)
		end

		button:SetID(position)
		button.spellID = SpellID

		button:Show()
		button:ClearAllPoints()
		button:SetPoint(setting.point, setting.xOffset, setting.yOffset)

		if(element.PostUpdateIcon) then
			element:PostUpdateIcon(unit, button, nil, position)
		end

		visible = visible + 1
	end

	return visible
end

local function filterIcons(element, unit, filter, limit, isDebuff, offset, dontHide)
	if (not offset) then offset = 0 end
	local index, visible, hidden = 1, 0, 0
	while (visible < limit) do
		local result = updateIcon(element, unit, index, offset, filter, isDebuff, visible)
		if (not result) then
			break
		elseif (result == VISIBLE) then
			visible = visible + 1
		elseif (result == HIDDEN) then
			hidden = hidden + 1
		end

		index = index + 1
	end

	if (not dontHide) then
		for i = visible + offset + 1, #element do
			element[i]:Hide()
		end
	end

	return visible, hidden
end

local function UpdateAuras(self, event, unit)
	if(self.unit ~= unit) then return end

	local element = self.AuraWatch
	if(element) then
		if(element.PreUpdate) then element:PreUpdate(unit) end

		local numBuffs = element.numBuffs or 32
		local numDebuffs = element.numDebuffs or 16
		local numAuras = element.numTotal or (numBuffs + numDebuffs)

		for i = 1, #element do element[i].isFiltered = false end

		local visibleBuffs, hiddenBuffs = filterIcons(element, unit, element.buffFilter or element.filter or 'HELPFUL', min(numBuffs, numAuras), nil, 0, true)
		local visibleDebuffs, hiddenDebuffs = filterIcons(element, unit, element.buffFilter or element.filter or 'HARMFUL', min(numDebuffs, numAuras - visibleBuffs), true, visibleBuffs)

		element.visibleDebuffs = visibleDebuffs
		element.visibleBuffs = visibleBuffs

		element.visibleAuras = visibleBuffs + visibleDebuffs
		element.allAuras = visibleBuffs + visibleDebuffs + hiddenBuffs + hiddenDebuffs

		onlyShowMissingIcon(element, unit, element.visibleAuras)

		if(element.PostUpdate) then element:PostUpdate(unit) end
	end
end

local function Update(self, event, unit)
	if(self.unit ~= unit) then return end

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
	if(element) then
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
	if(self.AuraWatch) then
		self:UnregisterEvent('UNIT_AURA', UpdateAuras)

		if(self.AuraWatch) then self.AuraWatch:Hide() end
	end
end

oUF:AddElement('AuraWatch', Update, Enable, Disable)
