local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local A = E:GetModule('Auras')
local LSM = E.Libs.LSM

--Lua functions
local _G = _G
local floor, format, tinsert = floor, format, tinsert
local select, unpack, strmatch = select, unpack, strmatch
--WoW API / Variables
local CreateFrame = CreateFrame
local GetInventoryItemQuality = GetInventoryItemQuality
local GetInventoryItemTexture = GetInventoryItemTexture
local GetItemQualityColor = GetItemQualityColor
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local RegisterAttributeDriver = RegisterAttributeDriver
local RegisterStateDriver = RegisterStateDriver
local UnitAura = UnitAura
local GetTime = GetTime

local Masque = E.Masque
local MasqueGroupBuffs = Masque and Masque:Group('ElvUI', 'Buffs')
local MasqueGroupDebuffs = Masque and Masque:Group('ElvUI', 'Debuffs')

local DIRECTION_TO_POINT = {
	DOWN_RIGHT = 'TOPLEFT',
	DOWN_LEFT = 'TOPRIGHT',
	UP_RIGHT = 'BOTTOMLEFT',
	UP_LEFT = 'BOTTOMRIGHT',
	RIGHT_DOWN = 'TOPLEFT',
	RIGHT_UP = 'BOTTOMLEFT',
	LEFT_DOWN = 'TOPRIGHT',
	LEFT_UP = 'BOTTOMRIGHT',
}

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = 1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = -1,
	RIGHT_DOWN = 1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = -1,
}

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = -1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = 1,
	RIGHT_DOWN = -1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = 1,
}

local IS_HORIZONTAL_GROWTH = {
	RIGHT_DOWN = true,
	RIGHT_UP = true,
	LEFT_DOWN = true,
	LEFT_UP = true,
}

local MasqueButtonData = {
	-- ones we update:
	Icon = nil,
	Highlight = nil,

	-- ones we dont update:
	FloatingBG = nil,
	Cooldown = nil,
	Flash = nil,
	Pushed = nil,
	Normal = nil,
	Disabled = nil,
	Checked = nil,
	Border = nil,
	AutoCastable = nil,
	HotKey = nil,
	Count = false,
	Name = nil,
	Duration = false,
	AutoCast = nil,
}

function A:MasqueData(texture, highlight)
	local btnData = E:CopyTable({}, MasqueButtonData)
	btnData.Icon = texture
	btnData.Highlight = highlight
	return btnData
end

function A:UpdateStatusBar(button)
	button.statusBar:SetValue(button.timeLeft)

	local threshold = E.db.auras.fadeThreshold
	if threshold == -1 then
		return
	elseif button.timeLeft > threshold then
		E:StopFlash(button)
	else
		E:Flash(button, 1)
	end
end

function A:CreateIcon(button)
	local font = LSM:Fetch('font', self.db.font)
	local header = button:GetParent()
	local auraType = header:GetAttribute('filter')

	local db = self.db.debuffs
	button.auraType = 'debuffs' -- used to update cooldown text
	button.filter = auraType
	if auraType == 'HELPFUL' then
		db = self.db.buffs
		button.auraType = 'buffs'
	end

	-- button:SetFrameLevel(4)
	button.texture = button:CreateTexture(nil, 'ARTWORK')
	button.texture:SetInside()
	button.texture:SetTexCoord(unpack(E.TexCoords))

	button.count = button:CreateFontString(nil, 'OVERLAY')
	button.count:Point('BOTTOMRIGHT', -1 + self.db.countXOffset, 1 + self.db.countYOffset)
	button.count:FontTemplate(font, db.countFontSize, self.db.fontOutline)

	button.text = button:CreateFontString(nil, 'OVERLAY')
	button.text:Point('TOP', button, 'BOTTOM', 1 + self.db.timeXOffset, 0 + self.db.timeYOffset)

	button.highlight = button:CreateTexture(nil, 'HIGHLIGHT')
	button.highlight:SetColorTexture(1, 1, 1, .45)
	button.highlight:SetInside()

	button.statusBar = CreateFrame('StatusBar', nil, button)
	button.statusBar:SetFrameLevel(button:GetFrameLevel())
	button.statusBar:SetFrameStrata(button:GetFrameStrata())
	button.statusBar:SetStatusBarTexture(E.Libs.LSM:Fetch('statusbar', self.db.barTexture))
	button.statusBar:CreateBackdrop()
	E:SetSmoothing(button.statusBar)

	local pos, spacing, iconSize = self.db.barPosition, self.db.barSpacing, db.size - (E.Border * 2)
	local isOnTop = pos == 'TOP' and true or false
	local isOnBottom = pos == 'BOTTOM' and true or false
	local isOnLeft = pos == 'LEFT' and true or false
	local isOnRight = pos == 'RIGHT' and true or false

	button.statusBar:Width((isOnTop or isOnBottom) and iconSize or (self.db.barWidth + (E.PixelMode and 0 or 2)))
	button.statusBar:Height((isOnLeft or isOnRight) and iconSize or (self.db.barHeight + (E.PixelMode and 0 or 2)))
	button.statusBar:Point(E.InversePoints[pos], button, pos, (isOnTop or isOnBottom) and 0 or ((isOnLeft and -((E.PixelMode and 1 or 3) + spacing)) or ((E.PixelMode and 1 or 3) + spacing)), (isOnLeft or isOnRight) and 0 or ((isOnTop and ((E.PixelMode and 1 or 3) + spacing) or -((E.PixelMode and 1 or 3) + spacing))))
	if isOnLeft or isOnRight then button.statusBar:SetOrientation('VERTICAL') end

	E:SetUpAnimGroup(button)

	-- support cooldown override
	if not button.isRegisteredCooldown then
		button.CooldownOverride = 'auras'
		button.isRegisteredCooldown = true

		if not E.RegisteredCooldowns.auras then E.RegisteredCooldowns.auras = {} end
		tinsert(E.RegisteredCooldowns.auras, button)
	end

	if button.customFont then
		button.text:FontTemplate(button.customFont, button.customFontSize, button.customFontOutline)
	else
		button.text:FontTemplate(font, db.durationFontSize, self.db.fontOutline)
	end

	button:SetScript('OnAttributeChanged', A.OnAttributeChanged)

	if auraType == 'HELPFUL' then
		if MasqueGroupBuffs and E.private.auras.masque.buffs then
			MasqueGroupBuffs:AddButton(button, A:MasqueData(button.texture, button.highlight))
			if button.__MSQ_BaseFrame then
				button.__MSQ_BaseFrame:SetFrameLevel(2) --Lower the framelevel to fix issue with buttons created during combat
			end
			MasqueGroupBuffs:ReSkin()
		else
			button:SetTemplate()
		end
	elseif auraType == 'HARMFUL' then
		if MasqueGroupDebuffs and E.private.auras.masque.debuffs then
			MasqueGroupDebuffs:AddButton(button, A:MasqueData(button.texture, button.highlight))
			if button.__MSQ_BaseFrame then
				button.__MSQ_BaseFrame:SetFrameLevel(2) --Lower the framelevel to fix issue with buttons created during combat
			end
			MasqueGroupDebuffs:ReSkin()
		else
			button:SetTemplate()
		end
	end
end

function A:SetAuraTime(button, expiration, duration)
	button.timeLeft = E:Round(expiration - GetTime(), 3)

	-- this keeps enchants from derping out when they expire
	if button.timeLeft <= 0.05 then
		A:ClearAuraTime(button, true)
		return
	end

	A:UpdateStatusBar(button)

	local oldEnd = button.endTime
	button.endTime = expiration

	if oldEnd ~= button.endTime then
		button.nextUpdate = 0
		button.statusBar:SetMinMaxValues(0, duration)
		button:SetScript('OnUpdate', E.Cooldown_OnUpdate)
	end
end

function A:ClearAuraTime(button, expired)
	if not expired then
		button.statusBar:SetValue(1)
		button.statusBar:SetMinMaxValues(0, 1)
	end

	button.endTime = nil
	button.text:SetText('')
	button:SetScript('OnUpdate', nil)
end

function A:UpdateAura(button, index)
	local unit = button:GetParent():GetAttribute('unit')
	local name, texture, count, dtype, duration, expiration = UnitAura(unit, index, button.filter)

	if name then
		if duration > 0 and expiration then
			A:SetAuraTime(button, expiration, duration)
		else
			A:ClearAuraTime(button)
		end

		local r, g, b
		if button.timeLeft and self.db.barColorGradient then
			r, g, b = E.oUF:ColorGradient(button.timeLeft, duration or 0, .8, 0, 0, .8, .8, 0, 0, .8, 0)
		else
			r, g, b = self.db.barColor.r, self.db.barColor.g, self.db.barColor.b
		end

		button.statusBar:SetStatusBarColor(r, g, b)

		if count and count > 1 then
			button.count:SetText(count)
		else
			button.count:SetText('')
		end

		if self.db.showDuration then
			button.text:Show()
		else
			button.text:Hide()
		end

		if (self.db.barShow and duration > 0) or (self.db.barShow and self.db.barNoDuration and duration == 0) then
			button.statusBar:Show()
		else
			button.statusBar:Hide()
		end

		if button.filter == 'HARMFUL' then
			local color = _G.DebuffTypeColor[dtype or 'none']
			button:SetBackdropBorderColor(color.r, color.g, color.b)
			button.statusBar.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			local cr, cg, cb = unpack(E.media.bordercolor)
			button:SetBackdropBorderColor(cr, cg, cb)
			button.statusBar.backdrop:SetBackdropBorderColor(cr, cg, cb)
		end

		button.texture:SetTexture(texture)
	end
end

function A:UpdateTempEnchant(button, index)
	local offset = (strmatch(button:GetName(), '2$') and 6) or 2

	local duration, remaining = 600, 0
	local expiration = select(offset, GetWeaponEnchantInfo())
	if expiration then
		button.texture:SetTexture(GetInventoryItemTexture('player', index))

		local quality = GetInventoryItemQuality('player', index)
		if quality and quality > 1 then
			button:SetBackdropBorderColor(GetItemQualityColor(quality))
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end

		remaining = expiration / 1000
		if remaining <= 3600 and remaining > 1800 then
			duration = 3600
		elseif remaining <= 1800 and remaining > 600 then
			duration = 1800
		end

		A:SetAuraTime(button, E:Round(remaining + GetTime(), 3), duration)
	else
		A:ClearAuraTime(button)
	end

	if (self.db.barShow and remaining > 0) or (self.db.barShow and self.db.barNoDuration and not expiration) then
		button.statusBar:Show()
	else
		button.statusBar:Hide()
	end

	local r, g, b
	if expiration and self.db.barColorGradient then
		r, g, b = E.oUF:ColorGradient(remaining, duration, .8, 0, 0, .8, .8, 0, 0, .8, 0)
	else
		r, g, b = self.db.barColor.r, self.db.barColor.g, self.db.barColor.b
	end

	button.statusBar:SetStatusBarColor(r, g, b)
end

function A:Update_CooldownOptions(button)
	E:Cooldown_Options(button, self.db.cooldown, button)

	button.forceEnabled = true
	button.showSeconds = true
end

function A:OnAttributeChanged(attribute, value)
	A:Update_CooldownOptions(self)

	if attribute == 'index' then
		A:UpdateAura(self, value)
	elseif attribute == 'target-slot' then
		A:UpdateTempEnchant(self, value)
	end
end

function A:UpdateHeader(header)
	if not E.private.auras.enable then return end

	local auraType = 'debuffs'
	local db = self.db.debuffs
	if header:GetAttribute('filter') == 'HELPFUL' then
		auraType = 'buffs'
		db = self.db.buffs
		header:SetAttribute('consolidateTo', 0)
		header:SetAttribute('weaponTemplate', format('ElvUIAuraTemplate%d',db.size))
	end

	header:SetAttribute('separateOwn', db.seperateOwn)
	header:SetAttribute('sortMethod', db.sortMethod)
	header:SetAttribute('sortDirection', db.sortDir)
	header:SetAttribute('maxWraps', db.maxWraps)
	header:SetAttribute('wrapAfter', db.wrapAfter)

	header:SetAttribute('point', DIRECTION_TO_POINT[db.growthDirection])

	if IS_HORIZONTAL_GROWTH[db.growthDirection] then
		header:SetAttribute('minWidth', ((db.wrapAfter == 1 and 0 or db.horizontalSpacing) + db.size) * db.wrapAfter)
		header:SetAttribute('minHeight', (db.verticalSpacing + db.size) * db.maxWraps)
		header:SetAttribute('xOffset', DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection] * (db.horizontalSpacing + db.size))
		header:SetAttribute('yOffset', 0)
		header:SetAttribute('wrapXOffset', 0)
		header:SetAttribute('wrapYOffset', DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + db.size))
	else
		header:SetAttribute('minWidth', (db.horizontalSpacing + db.size) * db.maxWraps)
		header:SetAttribute('minHeight', ((db.wrapAfter == 1 and 0 or db.verticalSpacing) + db.size) * db.wrapAfter)
		header:SetAttribute('xOffset', 0)
		header:SetAttribute('yOffset', DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + db.size))
		header:SetAttribute('wrapXOffset', DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection] * (db.horizontalSpacing + db.size))
		header:SetAttribute('wrapYOffset', 0)
	end

	header:SetAttribute('template', format('ElvUIAuraTemplate%d',db.size))

	local pos, spacing, iconSize = self.db.barPosition, self.db.barSpacing, db.size - (E.Border * 2)
	local isOnTop = pos == 'TOP' and true or false
	local isOnBottom = pos == 'BOTTOM' and true or false
	local isOnLeft = pos == 'LEFT' and true or false
	local isOnRight = pos == 'RIGHT' and true or false

	local index = 1
	local child = select(index, header:GetChildren())
	while child do
		if (floor(child:GetWidth() * 100 + 0.5) / 100) ~= db.size then
			child:Size(db.size, db.size)
		end

		child.auraType = auraType -- used to update cooldown text

		if child.text then
			local font = LSM:Fetch('font', self.db.font)
			child.text:ClearAllPoints()
			child.text:Point('TOP', child, 'BOTTOM', 1 + self.db.timeXOffset, 0 + self.db.timeYOffset)
			child.text:FontTemplate(font, db.durationFontSize, self.db.fontOutline)

			child.count:ClearAllPoints()
			child.count:Point('BOTTOMRIGHT', -1 + self.db.countXOffset, 0 + self.db.countYOffset)
			child.count:FontTemplate(font, db.countFontSize, self.db.fontOutline)
		end

		--Blizzard bug fix, icons arent being hidden when you reduce the amount of maximum buttons
		if index > (db.maxWraps * db.wrapAfter) and child:IsShown() then
			child:Hide()
		end

		child.statusBar:Width((isOnTop or isOnBottom) and iconSize or (self.db.barWidth + (E.PixelMode and 0 or 2)))
		child.statusBar:Height((isOnLeft or isOnRight) and iconSize or (self.db.barHeight + (E.PixelMode and 0 or 2)))
		child.statusBar:ClearAllPoints()
		child.statusBar:Point(E.InversePoints[pos], child, pos, (isOnTop or isOnBottom) and 0 or ((isOnLeft and -((E.PixelMode and 1 or 3) + spacing)) or ((E.PixelMode and 1 or 3) + spacing)), (isOnLeft or isOnRight) and 0 or ((isOnTop and ((E.PixelMode and 1 or 3) + spacing) or -((E.PixelMode and 1 or 3) + spacing))))
		child.statusBar:SetStatusBarTexture(E.Libs.LSM:Fetch('statusbar', self.db.barTexture))
		if isOnLeft or isOnRight then
			child.statusBar:SetOrientation('VERTICAL')
		else
			child.statusBar:SetOrientation('HORIZONTAL')
		end

		index = index + 1
		child = select(index, header:GetChildren())
	end

	if MasqueGroupBuffs and E.private.auras.masque.buffs then MasqueGroupBuffs:ReSkin() end
	if MasqueGroupDebuffs and E.private.auras.masque.debuffs then MasqueGroupDebuffs:ReSkin() end
end

function A:CreateAuraHeader(filter)
	local name = 'ElvUIPlayerDebuffs'
	if filter == 'HELPFUL' then
		name = 'ElvUIPlayerBuffs'
	end

	local header = CreateFrame('Frame', name, E.UIParent, 'SecureAuraHeaderTemplate')
	header:SetClampedToScreen(true)
	header:SetAttribute('unit', 'player')
	header:SetAttribute('filter', filter)
	RegisterStateDriver(header, 'visibility', '[petbattle] hide; show')
	RegisterAttributeDriver(header, 'unit', '[vehicleui] vehicle; player')

	if filter == 'HELPFUL' then
		header:SetAttribute('consolidateDuration', -1)
		header:SetAttribute('includeWeapons', 1)
	end

	A:UpdateHeader(header)
	header:Show()

	return header
end

function A:Initialize()
	if E.private.auras.disableBlizzard then
		_G.BuffFrame:Kill()
		_G.TemporaryEnchantFrame:Kill()
	end

	if not E.private.auras.enable then return end

	self.Initialized = true
	self.db = E.db.auras

	self.BuffFrame = self:CreateAuraHeader('HELPFUL')
	self.BuffFrame:Point('TOPRIGHT', _G.MMHolder, 'TOPLEFT', -(6 + E.Border), -E.Border - E.Spacing)
	E:CreateMover(self.BuffFrame, 'BuffsMover', L["Player Buffs"], nil, nil, nil, nil, nil, 'auras,buffs')

	self.DebuffFrame = self:CreateAuraHeader('HARMFUL')
	self.DebuffFrame:Point('BOTTOMRIGHT', _G.MMHolder, 'BOTTOMLEFT', -(6 + E.Border), E.Border + E.Spacing)
	E:CreateMover(self.DebuffFrame, 'DebuffsMover', L["Player Debuffs"], nil, nil, nil, nil, nil, 'auras,debuffs')

	if Masque then
		if MasqueGroupBuffs then A.BuffsMasqueGroup = MasqueGroupBuffs end
		if MasqueGroupDebuffs then A.DebuffsMasqueGroup = MasqueGroupDebuffs end
	end
end

E:RegisterModule(A:GetName())
