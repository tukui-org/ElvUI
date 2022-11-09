-- Original work by Astromech
-- Rewritten based on Auras by Azilroka and Simpy

local _, ns = ...
local oUF = ns.oUF
local LCD = oUF.isClassic and LibStub('LibClassicDurations', true)

local VISIBLE = 1
local HIDDEN = 0

local min, wipe, pairs, tinsert = min, wipe, pairs, tinsert
local GetSpellTexture = GetSpellTexture
local CreateFrame = CreateFrame
local UnitIsUnit = UnitIsUnit
local UnitAura = UnitAura

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

	if element.PostCreateIcon then element:PostCreateIcon(button) end

	return button
end

local function customFilter(element, _, button)
	local setting = element.watched[button.spellID]
	if not setting then
		return false
	end

	button.onlyShowMissing = setting.onlyShowMissing
	button.anyUnit = setting.anyUnit

	if setting.enabled and ((not setting.anyUnit and button.isPlayer) or (setting.anyUnit and button.castByPlayer)) then
		return not setting.onlyShowMissing
	end

	return false
end

local function getIcon(element, visible, offset)
	local position = visible + offset + 1
	local button = element[position]

	if not button then
		button = (element.CreateIcon or createAuraIcon) (element, position)

		tinsert(element, button)
		element.createdIcons = element.createdIcons + 1
	end

	return button, position
end

local function handleElements(element, unit, button, setting, icon, count, duration, expiration, isDebuff, debuffType, isStealable, modRate)
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
		if count and count > 1 then
			button.count:SetText(count)
		else
			button.count:SetText()
		end
	end

	if button.overlay then
		if element.showType or (isDebuff and element.showDebuffType) or (not isDebuff and element.showBuffType) then
			local color = element.__owner.colors.debuff[debuffType] or element.__owner.colors.debuff.none

			button.overlay:SetVertexColor(color[1], color[2], color[3])
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
	button:SetPoint(setting.point, setting.xOffset, setting.yOffset)
end

local missing = {}
local function preOnlyMissing(element)
	wipe(missing)

	for spellID, setting in pairs(element.watched) do
		if setting.onlyShowMissing then
			missing[spellID] = setting
		end
	end
end

local function postOnlyMissing(element, unit, offset)
	local visible = 0
	for spellID, setting in pairs(missing) do
		local button, position = getIcon(element, visible, offset)

		button.spellID = spellID

		local icon = GetSpellTexture(spellID)
		handleElements(element, unit, button, setting, icon)

		if element.PostUpdateIcon then
			element:PostUpdateIcon(unit, button, nil, position)
		end

		visible = visible + 1
	end

	return visible
end

local function updateIcon(element, unit, index, offset, filter, isDebuff, visible)
	local name, icon, count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, modRate, effect1, effect2, effect3 = UnitAura(unit, index, filter)
	if not name then return end

	local button, position = getIcon(element, visible, offset)

	button.caster = source
	button.filter = filter
	button.spellID = spellID
	button.isDebuff = isDebuff
	button.debuffType = debuffType
	button.castByPlayer = castByPlayer
	button.isPlayer = source == 'player'

	button:SetID(index)

	if LCD and spellID and not UnitIsUnit('player', unit) then
		local durationNew, expirationTimeNew = LCD:GetAuraDurationByUnit(unit, spellID, source, name)
		if durationNew and durationNew > 0 then
			duration, expiration = durationNew, expirationTimeNew
		end
	end

	local show = (element.CustomFilter or customFilter) (element, unit, button, name, icon,
		count, debuffType, duration, expiration, source, isStealable, nameplateShowPersonal, spellID,
		canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, modRate, effect1, effect2, effect3)

	local setting = element.watched[spellID]
	if setting and setting.onlyShowMissing then
		missing[spellID] = nil
	end

	if show then
		handleElements(element, unit, button, setting, icon, count, duration, expiration, isDebuff, debuffType, isStealable, modRate)

		if element.PostUpdateIcon then
			element:PostUpdateIcon(unit, button, index, position, duration, expiration, debuffType, isStealable)
		end

		return VISIBLE
	else
		return HIDDEN
	end
end

local function filterIcons(element, unit, filter, limit, isDebuff, offset, dontHide)
	if not offset then offset = 0 end

	local index, visible, hidden = 1, 0, 0
	while visible < limit do
		local result = updateIcon(element, unit, index, offset, filter, isDebuff, visible)
		if not result then
			break
		elseif result == VISIBLE then
			visible = visible + 1
		elseif result == HIDDEN then
			hidden = hidden + 1
		end

		index = index + 1
	end

	if not dontHide then
		for i = visible + offset + 1, #element do
			element[i]:Hide()
		end
	end

	return visible, hidden
end

local function UpdateAuras(self, event, unit, isFullUpdate, updatedAuras)
	if not unit or self.unit ~= unit then return end

	local element = self.AuraWatch
	if element then
		if element.PreUpdate then element:PreUpdate(unit) end

		preOnlyMissing(element)

		local numBuffs = element.numBuffs or 32
		local numDebuffs = element.numDebuffs or 16
		local numAuras = element.numTotal or (numBuffs + numDebuffs)

		local visibleBuffs, hiddenBuffs = filterIcons(element, unit, element.buffFilter or element.filter or 'HELPFUL', min(numBuffs, numAuras), nil, 0, true)
		local visibleDebuffs, hiddenDebuffs = filterIcons(element, unit, element.buffFilter or element.filter or 'HARMFUL', min(numDebuffs, numAuras - visibleBuffs), true, visibleBuffs)

		element.visibleDebuffs = visibleDebuffs
		element.visibleBuffs = visibleBuffs

		element.visibleAuras = visibleBuffs + visibleDebuffs

		local visibleMissing = postOnlyMissing(element, unit, element.visibleAuras)

		element.allAuras = visibleBuffs + visibleDebuffs + hiddenBuffs + hiddenDebuffs + visibleMissing

		if element.PostUpdate then element:PostUpdate(unit) end
	end
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

		oUF:RegisterEvent(self, 'UNIT_AURA', UpdateAuras)

		element:Show()

		return true
	end
end

local function Disable(self)
	if self.AuraWatch then
		oUF:UnregisterEvent(self, 'UNIT_AURA', UpdateAuras)

		if self.AuraWatch then self.AuraWatch:Hide() end
	end
end

oUF:AddElement('AuraWatch', Update, Enable, Disable)
