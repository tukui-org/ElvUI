-- Original work by Astromech
-- Rewritten based on Auras by Azilroka

local _, ns = ...
local oUF = ns.oUF

local VISIBLE = 1
local HIDDEN = 0

local function updateText(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.1 then
		local timeNow = GetTime()
		self.timeLeft = self.expiration - timeNow
		if self.timeLeft > 0 and self.timeLeft <= self.textThreshold then
			self.cd:SetCooldown(timeNow, self.timeLeft)
			self.cd:Show()
			self:SetScript("OnUpdate", nil)
			self.elapsed = 0
		end
	end
end

local function createAuraIcon(element, index)
	local button = CreateFrame('Button', element:GetDebugName() .. 'Button' .. index, element)

	local cd = CreateFrame('Cooldown', '$parentCooldown', button, 'CooldownFrameTemplate')
	cd:SetAllPoints()
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

local function customFilter(element, _, button, name, _, _, _, _, _, _, _, _, spellID)
	if button.onlyShowMissing then
		return false
	end

	if (not button.anyUnit and not button.isPlayer) then
		return
	end

	return (element.watched[spellID] or element.watched[name]) and true or false
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

			table.insert(element, button)
			element.createdIcons = element.createdIcons + 1
		end

		local setting = element.watched[spellID]

		button.caster = caster
		button.filter = filter
		button.isDebuff = isDebuff
		button.debuffType = debuffType
		button.isPlayer = caster == 'player'
		button.spellID = spellID

		button.onlyShowMissing = setting and setting.onlyShowMissing or false
		button.anyUnit = setting and setting.anyUnit or false

		local show = (element.CustomFilter or customFilter) (element, unit, button, name, texture,
			count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID,
			canApply, isBossDebuff, casterIsPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3)

		if(show) then
			if(button.cd) then
				button.cd:Hide()

				button.cd.hideText = not setting.displayText

				if setting.displayText and setting.textThreshold ~= -1 then
					button.textThreshold = setting.textThreshold
					button.duration = duration
					button.expiration = expiration
					button.first = true
					button:SetScript('OnUpdate', updateText)
				else
					if(duration and duration > 0) then
						button.cd:SetCooldown(expiration - duration, duration)
						button.cd:Show()
					end
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
				if(not isDebuff and isStealable and element.showStealableBuffs and not UnitIsUnit('player', unit)) then
					button.stealable:Show()
				else
					button.stealable:Hide()
				end
			end

			if(button.icon) then button.icon:SetTexture(texture) end
			if(button.count) then button.count:SetText(count > 1 and count) end

			local size = setting.sizeOverride > 0 and setting.sizeOverride or element.size or 16
			button:SetSize(size, size)

			button:SetID(index)
			button:Show()
			button:ClearAllPoints()
			button:SetPoint(setting.point, setting.xOffset, setting.yOffset)

			if(element.PostUpdateIcon) then
				element:PostUpdateIcon(unit, button, index, position, duration, expiration, debuffType, isStealable)
			end

			return VISIBLE
		else
			return HIDDEN
		end
	end
end

local function onlyShowMissingIcon(element, unit, _, offset, filtered)
	local visible = 0
	local index = 1
	local show = true
	for spellID, setting in pairs(element.watched) do
		if setting.onlyShowMissing then
			local position = visible + offset + 1
			local button = element[position]
			if(not button) then
				button = (element.CreateIcon or createAuraIcon) (element, position)

				table.insert(element, button)
				element.createdIcons = element.createdIcons + 1
			end

			for i = 1, (offset + filtered) do
				local icon = element[i]
				if icon and spellID == icon.spellID and (icon.anyUnit or icon.isPlayer) then
					show = false
					break
				end
			end

			if show then
				if(button.icon) then button.icon:SetTexture(GetSpellTexture(spellID)) end

				if(button.overlay) then
					button.overlay:Hide()
				end

				local size = setting.sizeOverride > 0 and setting.sizeOverride or element.size or 16
				button:SetSize(size, size)

				button.spellID = spellID

				button:SetID(index)
				button:Show()
				button:ClearAllPoints()
				button:SetPoint(setting.point, setting.xOffset, setting.yOffset)

				if(element.PostUpdateIcon) then
					element:PostUpdateIcon(unit, button, index, position)
				end

				index = index + 1
				visible = visible + 1
			end
		end
	end

	return visible
end

local function filterIcons(element, unit, filter, limit, isDebuff, offset, dontHide)
	if(not offset) then offset = 0 end
	local index = 1
	local visible = 0
	local hidden = 0
	while(visible < limit) do
		local result = updateIcon(element, unit, index, offset, filter, isDebuff, visible)
		if(not result) then
			break
		elseif(result == VISIBLE) then
			visible = visible + 1
		elseif(result == HIDDEN) then
			hidden = hidden + 1
		end

		index = index + 1
	end

	if(not dontHide) then
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
		local numDebuffs = element.numDebuffs or 40
		local max = element.numTotal or numBuffs + numDebuffs

		local visibleBuffs, filteredBuffs = filterIcons(element, unit, element.buffFilter or element.filter or 'HELPFUL', math.min(numBuffs, max), nil, 0, true)
		visibleBuffs = visibleBuffs + onlyShowMissingIcon(element, unit, nil, visibleBuffs, filteredBuffs)

		local hasGap
		if(visibleBuffs ~= 0) then
			hasGap = true
			visibleBuffs = visibleBuffs + 1

			local button = element[visibleBuffs]
			if(not button) then
				button = (element.CreateIcon or createAuraIcon) (element, visibleBuffs)
				table.insert(element, button)
				element.createdIcons = element.createdIcons + 1
			end

			if(button.cd) then button.cd:Hide() end
			if(button.icon) then button.icon:SetTexture() end
			if(button.overlay) then button.overlay:Hide() end
			if(button.stealable) then button.stealable:Hide() end
			if(button.count) then button.count:SetText() end

			button:Show()

			if(element.PostUpdateGapIcon) then
				element:PostUpdateGapIcon(unit, button, visibleBuffs)
			end
		end

		local visibleDebuffs = filterIcons(element, unit, element.debuffFilter or element.filter or 'HARMFUL', math.min(numDebuffs, max - visibleBuffs), true, visibleBuffs)
		element.visibleDebuffs = visibleDebuffs

		if(hasGap and visibleDebuffs == 0) then
			element[visibleBuffs]:Hide()
			visibleBuffs = visibleBuffs - 1
		end

		element.visibleBuffs = visibleBuffs
		element.visibleAuras = element.visibleBuffs + element.visibleDebuffs

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
		element.size = element.size or 16
		element.createdIcons = element.createdIcons or 0
		element.anchoredIcons = 0
		element.showDebuffType = false -- Can replace RaidDebuffs?

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
