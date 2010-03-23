--[[
	Elements handled: .Auras, .Buffs, .Debuffs

	Shared:
	 - spacing: Padding between aura icons. (Default: 0)
	 - size: Size of the aura icons. (Default: 16)
	 - initialAnchor: Initial anchor in the aura frame. (Default: "BOTTOMLEFT")
	 - onlyShowPlayer: Only display icons casted by the player. (Default: nil)
	 - growth-x: Growth direction, affected by initialAnchor. (Default: "UP")
	 - growth-y: Growth direction, affected by initialAnchor. (Default: "RIGHT")
	 - disableCooldown: Disable the Cooldown Spiral on the Aura Icons. (Default: nil)
	 - filter: Expects a string with filter. See the UnitAura[1] documentation for
		more information.

	.Auras only:
	 - gap: Adds a empty icon to separate buffs and debuffs. (Default: nil)
	 - numBuffs: The maximum number of buffs that should be shown. (Default: 32)
	 - numDebuffs: The maximum number of debuffs that should be shown. (Default: 40)
	 - buffFilter: See filter on Shared. (Default: "HELPFUL")
	 - debuffFilter: See filter on Shared. (Default: "HARMFUL")
	 - Variables set by .Auras:
		 - visibleBuffs: Number of currently visible buff icons.
		 - visibleDebuffs: Number of currently visible debuff icons.
		 - visibleAuras: Total number of currently visible buffs + debuffs.

	.Buffs only:
	 - num: The maximum number of buffs that should be shown. (Default: 32)
	 - Variables set by .Buffs:
		 - visibleBuffs: Number of currently visible buff icons.

	.Debuffs only:
	 - num: The maximum number of debuffs that should be shown. (Default: 40)
	 - Variables set by .Debuffs:
		 - visibleDebuffs: Number of currently visible debuff icons.

	Functions that can be overridden from within a layout:
	 - :PostCreateAuraIcon(icon, icons, index, isDebuff)
	 - :CreateAuraIcon(icons, index, isDebuff)
	 - :PostUpdateAuraIcon(icons, unit, icon, index, offset, filter, isDebuff)
	 - :PreUpdateAura(event, unit)
	 - :PreAuraSetPosition(auras, max)
	 - :SetAuraPosition(auras, max)
	 - :PostUpdateAura(event, unit)

	[1] http://www.wowwiki.com/API_UnitAura
--]]
local parent, ns = ...
local oUF = ns.oUF

local OnEnter = function(self)
	if(not self:IsVisible()) then return end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:SetUnitAura(self.frame.unit, self:GetID(), self.filter)
end

local OnLeave = function()
	GameTooltip:Hide()
end

-- We don't really need to validate much here as the filter should prevent us
-- from doing something we shouldn't.
local OnClick = function(self)
	CancelUnitBuff(self.frame.unit, self:GetID(), self.filter)
end

local createAuraIcon = function(self, icons, index, debuff)
	local button = CreateFrame("Button", nil, icons)
	button:EnableMouse(true)
	button:RegisterForClicks'RightButtonUp'

	button:SetWidth(icons.size or 16)
	button:SetHeight(icons.size or 16)

	local cd = CreateFrame("Cooldown", nil, button)
	cd:SetAllPoints(button)

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetAllPoints(button)

	local count = button:CreateFontString(nil, "OVERLAY")
	count:SetFontObject(NumberFontNormal)
	count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 0)

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetTexture"Interface\\Buttons\\UI-Debuff-Overlays"
	overlay:SetAllPoints(button)
	overlay:SetTexCoord(.296875, .5703125, 0, .515625)
	button.overlay = overlay

	button:SetScript("OnEnter", OnEnter)
	button:SetScript("OnLeave", OnLeave)

	if(self.unit == 'player') then
		button:SetScript('OnClick', OnClick)
	end

	table.insert(icons, button)

	button.parent = icons
	button.frame = self
	button.debuff = debuff

	button.icon = icon
	button.count = count
	button.cd = cd

	if(self.PostCreateAuraIcon) then self:PostCreateAuraIcon(button, icons, index, debuff) end

	return button
end

local customFilter = function(icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster)
	local isPlayer

	if(caster == 'player' or caster == 'vehicle') then
		isPlayer = true
	end

	if((icons.onlyShowPlayer and isPlayer) or (not icons.onlyShowPlayer and name)) then
		icon.isPlayer = isPlayer
		icon.owner = caster
		return true
	end
end

local updateIcon = function(self, unit, icons, index, offset, filter, isDebuff, max)
	if(index == 0) then index = max end

	local name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID = UnitAura(unit, index, filter)
	if(name) then
		local icon = icons[index + offset]
		if(not icon) then
			icon = (self.CreateAuraIcon or createAuraIcon) (self, icons, index, isDebuff)
		end

		local show = (self.CustomAuraFilter or customFilter) (icons, unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID)
		if(show) then
			-- We might want to consider delaying the creation of an actual cooldown
			-- object to this point, but I think that will just make things needlessly
			-- complicated.
			local cd = icon.cd
			if(cd and not icons.disableCooldown) then
				if(duration and duration > 0) then
					cd:SetCooldown(timeLeft - duration, duration)
					cd:Show()
				else
					cd:Hide()
				end
			end

			if((isDebuff and icons.showDebuffType) or (not isDebuff and icons.showBuffType) or icons.showType) then
				local color = DebuffTypeColor[dtype] or DebuffTypeColor.none

				icon.overlay:SetVertexColor(color.r, color.g, color.b)
				icon.overlay:Show()
			else
				icon.overlay:Hide()
			end

			icon.icon:SetTexture(texture)
			icon.count:SetText((count > 1 and count))

			icon.filter = filter
			icon.debuff = isDebuff

			icon:SetID(index)
			icon:Show()

			if(self.PostUpdateAuraIcon) then
				self:PostUpdateAuraIcon(icons, unit, icon, index, offset, filter, isDebuff)
			end
		else
			-- Hide the icon in-case we are in the middle of the stack.
			icon:Hide()
		end

		return true
	end
end

local SetAuraPosition = function(self, icons, x)
	if(icons and x > 0) then
		local col = 0
		local row = 0
		local spacing = icons.spacing or 0
		local gap = icons.gap
		local size = (icons.size or 16) + spacing
		local anchor = icons.initialAnchor or "BOTTOMLEFT"
		local growthx = (icons["growth-x"] == "LEFT" and -1) or 1
		local growthy = (icons["growth-y"] == "DOWN" and -1) or 1
		local cols = math.floor(icons:GetWidth() / size + .5)
		local rows = math.floor(icons:GetHeight() / size + .5)

		for i = 1, #icons do
			local button = icons[i]
			if(button and button:IsShown()) then
				if(gap and button.debuff) then
					if(col > 0) then
						col = col + 1
					end

					gap = false
				end

				if(col >= cols) then
					col = 0
					row = row + 1
				end
				button:ClearAllPoints()
				button:SetPoint(anchor, icons, anchor, col * size * growthx, row * size * growthy)

				col = col + 1
			elseif(not button) then
				break
			end
		end
	end
end

local Update = function(self, event, unit)
	if(self.unit ~= unit) then return end
	if(self.PreUpdateAura) then self:PreUpdateAura(event, unit) end

	local auras, buffs, debuffs = self.Auras, self.Buffs, self.Debuffs

	if(auras) then
		local buffs = auras.numBuffs or 32
		local debuffs = auras.numDebuffs or 40
		local max = debuffs + buffs

		local visibleBuffs, visibleDebuffs = 0, 0
		for index = 1, max do
			if(index > buffs) then
				if(updateIcon(self, unit, auras, index % debuffs, visibleBuffs, auras.debuffFilter or auras.filter or 'HARMFUL', true, debuffs)) then
					visibleDebuffs = visibleDebuffs + 1
				end
			else
				if(updateIcon(self, unit, auras, index, 0, auras.buffFilter or  auras.filter or 'HELPFUL')) then
					visibleBuffs = visibleBuffs + 1
				end
			end
		end

		local index = visibleBuffs + visibleDebuffs + 1
		while(auras[index]) do
			auras[index]:Hide()
			index = index + 1
		end

		auras.visibleBuffs = visibleBuffs
		auras.visibleDebuffs = visibleDebuffs
		auras.visibleAuras = visibleBuffs + visibleDebuffs

		if(self.PreAuraSetPosition) then self:PreAuraSetPosition(auras, max) end
		self:SetAuraPosition(auras, max)
	end

	if(buffs) then
		local filter = buffs.filter or 'HELPFUL'
		local max = buffs.num or 32
		local visibleBuffs = 0
		for index = 1, max do
			if(not updateIcon(self, unit, buffs, index, 0, filter)) then
				max = index - 1

				while(buffs[index]) do
					buffs[index]:Hide()
					index = index + 1
				end
				break
			end

			visibleBuffs = visibleBuffs + 1
		end

		buffs.visibleBuffs = visibleBuffs

		if(self.PreAuraSetPosition) then self:PreAuraSetPosition(buffs, max) end
		self:SetAuraPosition(buffs, max)
	end

	if(debuffs) then
		local filter = debuffs.filter or 'HARMFUL'
		local max = debuffs.num or 40
		local visibleDebuffs = 0
		for index = 1, max do
			if(not updateIcon(self, unit, debuffs, index, 0, filter, true)) then
				max = index - 1

				while(debuffs[index]) do
					debuffs[index]:Hide()
					index = index + 1
				end
				break
			end

			visibleDebuffs = visibleDebuffs + 1
		end
		debuffs.visibleDebuffs = visibleDebuffs

		if(self.PreAuraSetPosition) then self:PreAuraSetPosition(debuffs, max) end
		self:SetAuraPosition(debuffs, max)
	end

	if(self.PostUpdateAura) then
		return self:PostUpdateAura(event, unit)
	end
end

local Enable = function(self)
	if(self.Buffs or self.Debuffs or self.Auras) then
		if(not self.SetAuraPosition) then 
			self.SetAuraPosition = SetAuraPosition
		end
		self:RegisterEvent("UNIT_AURA", Update)

		return true
	end
end

local Disable = function(self)
	if(self.Buffs or self.Debuffs or self.Auras) then
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement('Aura', Update, Enable, Disable)
