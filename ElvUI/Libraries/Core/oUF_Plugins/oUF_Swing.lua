--[[
	Project.: oUF_Swing
	File....: oUF_Swing.lua
	Version.: 40200.1
	Rev Date: 06/28/2011, cleaned up on 08/02/2022 by Simpy
	Authors.: p3lim, Thalyra
]]

--[[
	Elements handled:
	 .Swing [frame]
	 .Swing.Text [fontstring]
	 .Swing.TextMH [fontstring]
	 .Swing.TextOH [fontstring]

	Code Example:
	 .Swing = CreateFrame('Frame', nil, self)
	 .Swing:SetWidth(400)
	 .Swing:SetHeight(20)
	 .Swing:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 100)
	 .Swing.texture = [=[Interface\TargetingFrame\UI-StatusBar]=]
	 .Swing.color = {1, 0, 0, 0.8}
	 .Swing.textureBG = [=[Interface\TargetingFrame\UI-StatusBar]=]
	 .Swing.colorBG = {0, 0, 0, 0.8}

	Autocreated if not created by Layout:
	 - .Twohand [statusbar]
	 - .Mainhand [statusbar]
	 - .Offhand [statusbar]

	Shared:
	 - disableMelee [boolean]
	 - disableRanged [boolean]
	 - hideOoc [boolean] (Autohide on leaving Combat)

	Functions that can be overridden from within a layout:
	 - .OverrideText(text, now)
--]]

local _, ns = ...
local oUF = oUF or ns.oUF

local select, unpack, strfind = select, unpack, strfind
local CreateFrame = CreateFrame
local GetTime = GetTime

local UnitGUID = UnitGUID
local GetSpellInfo = GetSpellInfo
local UnitCastingInfo = UnitCastingInfo
local UnitRangedDamage = UnitRangedDamage
local UnitAttackSpeed = UnitAttackSpeed
local GetInventoryItemID = GetInventoryItemID

local MainhandID = GetInventoryItemID('player', 16)
local OffhandID = GetInventoryItemID('player', 17)
local RangedID = GetInventoryItemID('player', 18)

local meleeing, rangeing, lasthit

local _, _, _, toc = GetBuildInfo()

local SwingStopped = function(element)
	local bar = element.__owner

	if bar.Twohand:IsShown() then return end
	if bar.Mainhand:IsShown() then return end
	if bar.Offhand:IsShown() then return end

	bar:Hide()
end

local OnDurationUpdate
do
	local slamtime, slamelapsed, checkelapsed = 0, 0, 0
	local slam = GetSpellInfo(1464)

	function OnDurationUpdate(self, elapsed)
		local now = GetTime()

		if meleeing then
			if checkelapsed > 0.02 then
				-- little hack for detecting melee stop
				-- improve... dw sucks at this point -.-
				if lasthit + self.speed + slamtime < now then
					self:Hide()
					self:SetScript('OnUpdate', nil)
					SwingStopped(self)
					meleeing = false
					rangeing = false
				end

				checkelapsed = 0
			else
				checkelapsed = checkelapsed + elapsed
			end
		end

		local spell = UnitCastingInfo('player')

		if slam == spell then
			-- slamelapsed: time to add for one slam
			slamelapsed = slamelapsed + elapsed
			-- slamtime: needed for meleeing hack (see some lines above)
			slamtime = slamtime + elapsed
		else
			-- after slam
			if slamelapsed ~= 0 then
				self.min = self.min + slamelapsed
				self.max = self.max + slamelapsed
				self:SetMinMaxValues(self.min, self.max)
				slamelapsed = 0
			end

			if now > self.max then
				if not meleeing then
					self:Hide()
					self:SetScript('OnUpdate', nil)
					meleeing = false
					rangeing = false
				elseif lasthit then
					self.min = self.max
					self.max = self.max + self.speed
					self:SetMinMaxValues(self.min, self.max)
					slamtime = 0
				end
			else
				self:SetValue(now)

				if self.__owner.OverrideText then
					self.__owner.OverrideText(self, now)
				elseif self.Text then
					self.Text:SetFormattedText('%.1f', self.max - now)
				end
			end
		end
	end
end

local MeleeChange = function(self, event, unit)
	if unit ~= 'player' then return end
	if not meleeing then return end

	local bar = self.Swing

	local swing = bar.Twohand
	local swingMH = bar.Mainhand
	local swingOH = bar.Offhand

	local NewMainhandID = GetInventoryItemID('player', 16)
	local NewOffhandID = GetInventoryItemID('player', 17)

	local now = GetTime()
	local mhspeed, ohspeed = UnitAttackSpeed('player')

	if MainhandID ~= NewMainhandID or OffhandID ~= NewOffhandID then
		if ohspeed then
			swing:Hide()
			swing:SetScript('OnUpdate', nil)

			swingMH.min = now
			swingMH.max = swingMH.min + mhspeed
			swingMH.speed = mhspeed

			swingMH:Show()
			swingMH:SetMinMaxValues(swingMH.min, swingMH.max)
			swingMH:SetScript('OnUpdate', OnDurationUpdate)

			swingOH.min = now
			swingOH.max = swingOH.min + ohspeed
			swingOH.speed = ohspeed

			swingOH:Show()
			swingOH:SetMinMaxValues(swingOH.min, swingMH.max)
			swingOH:SetScript('OnUpdate', OnDurationUpdate)
		else
			swing.min = now
			swing.max = swing.min + mhspeed
			swing.speed = mhspeed

			swing:Show()
			swing:SetMinMaxValues(swing.min, swing.max)
			swing:SetScript('OnUpdate', OnDurationUpdate)

			swingMH:Hide()
			swingMH:SetScript('OnUpdate', nil)

			swingOH:Hide()
			swingOH:SetScript('OnUpdate', nil)

		end

		lasthit = now

		MainhandID = NewMainhandID
		OffhandID = NewOffhandID
	elseif ohspeed then
		if swingMH.speed ~= mhspeed then
			local percentage = (swingMH.max - now) / (swingMH.speed)
			swingMH.min = now - mhspeed * (1 - percentage)
			swingMH.max = now + mhspeed * percentage
			swingMH:SetMinMaxValues(swingMH.min, swingMH.max)
			swingMH.speed = mhspeed
		end
		if swingOH.speed ~= ohspeed then
			local percentage = (swingOH.max - now) / (swingOH.speed)
			swingOH.min = now - ohspeed * (1 - percentage)
			swingOH.max = now + ohspeed * percentage
			swingOH:SetMinMaxValues(swingOH.min, swingOH.max)
			swingOH.speed = ohspeed
		end
	elseif swing.speed ~= mhspeed then
		local percentage = (swing.max - now) / (swing.speed)
		swing.min = now - mhspeed * (1 - percentage)
		swing.max = now + mhspeed * percentage
		swing:SetMinMaxValues(swing.min, swing.max)
		swing.speed = mhspeed
	end
end

local RangedChange = function(self, event, unit)
	if unit ~= 'player' or not rangeing then return end

	local swing = self.Swing.Twohand
	local NewRangedID = GetInventoryItemID('player', 18)
	local speed = UnitRangedDamage('player')
	local now = GetTime()

	if RangedID ~= NewRangedID then
		swing.speed = UnitRangedDamage(unit)
		swing.min = now
		swing.max = swing.min + swing.speed

		swing:Show()
		swing:SetMinMaxValues(swing.min, swing.max)
		swing:SetScript('OnUpdate', OnDurationUpdate)
	elseif swing.speed ~= speed then
		local percentage = (swing.max - now) / swing.speed
		swing.min = now - speed * (1 - percentage)
		swing.max = now + speed * percentage
		swing.speed = speed
	end
end

local Ranged = function(self, event, unit, spellName)
	if unit ~= 'player' or (spellName ~= GetSpellInfo(75) and spellName ~= GetSpellInfo(5019)) then return end

	local bar = self.Swing
	local swing = bar.Twohand
	local swingMH = bar.Mainhand
	local swingOH = bar.Offhand

	meleeing = false
	rangeing = true

	bar:Show()

	swing.speed = UnitRangedDamage(unit)
	swing.min = GetTime()
	swing.max = swing.min + swing.speed

	swing:Show()
	swing:SetMinMaxValues(swing.min, swing.max)
	swing:SetScript('OnUpdate', OnDurationUpdate)

	swingMH:Hide()
	swingMH:SetScript('OnUpdate', nil)

	swingOH:Hide()
	swingOH:SetScript('OnUpdate', nil)
end

local Melee = function(self, event, _, subevent, _, GUID)
	if UnitGUID('player') ~= GUID or not strfind(subevent, 'SWING') then return end

	local bar = self.Swing
	local swing = bar.Twohand
	local swingMH = bar.Mainhand
	local swingOH = bar.Offhand
	local now = GetTime()

	-- calculation of new hits is in OnDurationUpdate
	-- workaround, cant differ between mainhand and offhand hits
	if not meleeing then
		bar:Show()

		swing:Hide()
		swingMH:Hide()
		swingOH:Hide()

		swing:SetScript('OnUpdate', nil)
		swingMH:SetScript('OnUpdate', nil)
		swingOH:SetScript('OnUpdate', nil)

		local mhspeed, ohspeed = UnitAttackSpeed('player')

		if ohspeed then
			swingMH.min = now
			swingMH.max = swingMH.min + mhspeed
			swingMH.speed = mhspeed

			swingMH:Show()
			swingMH:SetMinMaxValues(swingMH.min, swingMH.max)
			swingMH:SetScript('OnUpdate', OnDurationUpdate)

			swingOH.min = now
			swingOH.max = swingOH.min + ohspeed
			swingOH.speed = ohspeed

			swingOH:Show()
			swingOH:SetMinMaxValues(swingOH.min, swingOH.max)
			swingOH:SetScript('OnUpdate', OnDurationUpdate)
		else
			swing.min = now
			swing.max = swing.min + mhspeed
			swing.speed = mhspeed

			swing:Show()
			swing:SetMinMaxValues(swing.min, swing.max)
			swing:SetScript('OnUpdate', OnDurationUpdate)
		end

		meleeing = true
		rangeing = false
	end

	lasthit = now
end

local ParryHaste = function(self, event, _, subevent, ...)
	local tarGUID, _, missType = select(toc >= 40200 and 7 or 6, ...)

	if UnitGUID('player') ~= tarGUID or missType ~= 'PARRY' or not meleeing or not strfind(subevent, 'MISSED') then return end

	local bar = self.Swing
	local swing = bar.Twohand
	local swingMH = bar.Mainhand
	local swingOH = bar.Offhand

	local _, dualwield = UnitAttackSpeed('player')
	local now = GetTime()

	-- needed calculations, so the timer doesnt jump on parryhaste
	if dualwield then
		local percentage = (swingMH.max - now) / swingMH.speed

		if percentage > 0.6 then
			swingMH.max = now + swingMH.speed * 0.6
			swingMH.min = now - (swingMH.max - now) * percentage / (1 - percentage)
			swingMH:SetMinMaxValues(swingMH.min, swingMH.max)
		elseif percentage > 0.2 then
			swingMH.max = now + swingMH.speed * 0.2
			swingMH.min = now - (swingMH.max - now) * percentage / (1 - percentage)
			swingMH:SetMinMaxValues(swingMH.min, swingMH.max)
		end

		percentage = (swingOH.max - now) / swingOH.speed

		if percentage > 0.6 then
			swingOH.max = now + swingOH.speed * 0.6
			swingOH.min = now - (swingOH.max - now) * percentage / (1 - percentage)
			swingOH:SetMinMaxValues(swingOH.min, swingOH.max)
		elseif percentage > 0.2 then
			swingOH.max = now + swingOH.speed * 0.2
			swingOH.min = now - (swingOH.max - now) * percentage / (1 - percentage)
			swingOH:SetMinMaxValues(swingOH.min, swingOH.max)
		end
	else
		local percentage = (swing.max - now) / swing.speed

		if percentage > 0.6 then
			swing.max = now + swing.speed * 0.6
			swing.min = now - (swing.max - now) * percentage / (1 - percentage)
			swing:SetMinMaxValues(swing.min, swing.max)
		elseif percentage > 0.2 then
			swing.max = now + swing.speed * 0.2
			swing.min = now - (swing.max - now) * percentage / (1 - percentage)
			swing:SetMinMaxValues(swing.min, swing.max)
		end
	end
end

local Ooc = function(self)
	local bar = self.Swing

	-- strange behaviour sometimes...
	meleeing = false
	rangeing = false

	if not bar.hideOoc then return end

	bar:Hide()
	bar.Twohand:Hide()
	bar.Mainhand:Hide()
	bar.Offhand:Hide()
end

local Enable = function(self, unit)
	local bar = self.Swing

	if bar and unit == 'player' then
		local normTex = bar.texture or [=[Interface\TargetingFrame\UI-StatusBar]=]
		local bgTex = bar.textureBG or [=[Interface\TargetingFrame\UI-StatusBar]=]
		local r, g, b, a, r2, g2, b2, a2

		if bar.color then
			r, g, b, a = unpack(bar.color)
		else
			r, g, b, a = 1, 1, 1, 1
		end

		if bar.colorBG then
			r2, g2, b2, a2 = unpack(bar.colorBG)
		else
			r2, g2, b2, a2 = 0, 0, 0, 1
		end

		if not bar.Twohand then
			bar.Twohand = CreateFrame('StatusBar', nil, bar)
			bar.Twohand:SetPoint('TOPLEFT', bar, 'TOPLEFT', 0, 0)
			bar.Twohand:SetPoint('BOTTOMRIGHT', bar, 'BOTTOMRIGHT', 0, 0)
			bar.Twohand:SetStatusBarTexture(normTex)
			bar.Twohand:SetStatusBarColor(r, g, b, a)
			bar.Twohand:SetFrameLevel(20)
			bar.Twohand:Hide()

			bar.Twohand.bg = bar.Twohand:CreateTexture(nil, 'BACKGROUND')
			bar.Twohand.bg:SetAllPoints(bar.Twohand)
			bar.Twohand.bg:SetTexture(bgTex)
			bar.Twohand.bg:SetVertexColor(r2, g2, b2, a2)
		end
		bar.Twohand.__owner = bar

		if not bar.Mainhand then
			bar.Mainhand = CreateFrame('StatusBar', nil, bar)
			bar.Mainhand:SetPoint('TOPLEFT', bar, 'TOPLEFT', 0, 0)
			bar.Mainhand:SetPoint('BOTTOMRIGHT', bar, 'RIGHT', 0, 0)
			bar.Mainhand:SetStatusBarTexture(normTex)
			bar.Mainhand:SetStatusBarColor(r, g, b, a)
			bar.Mainhand:SetFrameLevel(20)
			bar.Mainhand:Hide()

			bar.Mainhand.bg = bar.Mainhand:CreateTexture(nil, 'BACKGROUND')
			bar.Mainhand.bg:SetAllPoints(bar.Mainhand)
			bar.Mainhand.bg:SetTexture(bgTex)
			bar.Mainhand.bg:SetVertexColor(r2, g2, b2, a2)
		end
		bar.Mainhand.__owner = bar

		if not bar.Offhand then
			bar.Offhand = CreateFrame('StatusBar', nil, bar)
			bar.Offhand:SetPoint('TOPLEFT', bar, 'LEFT', 0, 0)
			bar.Offhand:SetPoint('BOTTOMRIGHT', bar, 'BOTTOMRIGHT', 0, 0)
			bar.Offhand:SetStatusBarTexture(normTex)
			bar.Offhand:SetStatusBarColor(r, g, b, a)
			bar.Offhand:SetFrameLevel(20)
			bar.Offhand:Hide()

			bar.Offhand.bg = bar.Offhand:CreateTexture(nil, 'BACKGROUND')
			bar.Offhand.bg:SetAllPoints(bar.Offhand)
			bar.Offhand.bg:SetTexture(bgTex)
			bar.Offhand.bg:SetVertexColor(r2, g2, b2, a2)
		end
		bar.Offhand.__owner = bar

		if bar.Text then
			bar.Twohand.Text = bar.Text
			bar.Twohand.Text:SetParent(bar.Twohand)
		end
		if bar.TextMH then
			bar.Mainhand.Text = bar.TextMH
			bar.Mainhand.Text:SetParent(bar.Mainhand)
		end
		if bar.TextOH then
			bar.Offhand.Text = bar.TextOH
			bar.Offhand.Text:SetParent(bar.Offhand)
		end

		if bar.OverrideText then
			bar.Twohand.OverrideText = bar.OverrideText
			bar.Mainhand.OverrideText = bar.OverrideText
			bar.Offhand.OverrideText = bar.OverrideText
		end

		if not bar.disableRanged then
			self:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED', Ranged)
			self:RegisterEvent('UNIT_RANGEDDAMAGE', RangedChange)
		end

		if not bar.disableMelee then
			self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', Melee)
			self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', ParryHaste)
			self:RegisterEvent('UNIT_ATTACK_SPEED', MeleeChange)
		end

		self:RegisterEvent('PLAYER_REGEN_ENABLED', Ooc)

		return true
	end
end

local Disable = function(self)
	local bar = self.Swing
	if bar then
		if not bar.disableRanged then
			self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', Ranged)
			self:UnregisterEvent('UNIT_RANGEDDAMAGE', RangedChange)
		end

		if not bar.disableMelee then
			self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED', Melee)
			self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED', ParryHaste)
			self:UnregisterEvent('UNIT_ATTACK_SPEED', MeleeChange)
		end

		self:UnregisterEvent('PLAYER_REGEN_ENABLED', Ooc)

		bar:Hide()
	end
end

oUF:AddElement('Swing', nil, Enable, Disable)
