local E, L, V, P, G = unpack(ElvUI)
local A = E:GetModule('Auras')
local LSM = E.Libs.LSM

local _G = _G
local next, ceil, pcall = next, ceil, pcall
local strmatch, tonumber = strmatch, tonumber

local GetAuraApplicationDisplayCount = C_UnitAuras.GetAuraApplicationDisplayCount
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local GetAuraDuration = C_UnitAuras.GetAuraDuration

local GetInventoryItemQuality = GetInventoryItemQuality
local GetInventoryItemTexture = GetInventoryItemTexture
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local RegisterAttributeDriver = RegisterAttributeDriver
local SecureHandlerSetFrameRef = SecureHandlerSetFrameRef
local RegisterStateDriver = RegisterStateDriver
local GameTooltip_Hide = GameTooltip_Hide
local GameTooltip = GameTooltip
local CreateFrame = CreateFrame
local UIParent = UIParent
local GetTime = GetTime

local StatusBarInterpolation = Enum.StatusBarInterpolation

local Masque = E.Masque
local MasqueGroupBuffs = Masque and Masque:Group('ElvUI', 'Buffs')
local MasqueGroupDebuffs = Masque and Masque:Group('ElvUI', 'Debuffs')

local DebuffColors = E.Libs.Dispel:GetDebuffTypeColor()

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

-- use custom script that will only call hide when it needs to, this prevents spam to `SecureAuraHeader_Update`
A.AttributeCustomVisibility = [[
	local header = self:GetFrameRef('AuraHeader')
	local hide, shown = newstate == 0, header:IsShown()
	if hide and shown then header:Hide() elseif not hide and not shown then header:Show() end
]]

-- this will handle the size of auras
A.AttributeInitialConfig = [[
	local header = self:GetParent()

	self:SetWidth(header:GetAttribute('config-width'))
	self:SetHeight(header:GetAttribute('config-height'))
]]

function A:MasqueData(texture, highlight)
	local data = E:CopyTable({}, MasqueButtonData)

	data.Icon = texture
	data.Highlight = highlight

	return data
end

function A:SetStatusBarColor(bar, r, g, b)
	bar:GetStatusBarTexture():SetVertexColor(r, g, b)
end

function A:UpdateStatusBar(button)
	local db = A.db[button.auraType]
	if E.Retail and not button.enchantIndex then
		local color = db.barColorGradient and button.auraDuration and button.auraDuration:EvaluateRemainingPercent(E.Curves.Color.Default)
		if color then
			A:SetStatusBarColor(button.statusBar, color.r, color.g, color.b)
		end

		local remaining = button.auraDuration and button.auraDuration:GetRemainingDuration()
		if remaining then
			button.statusBar:SetValue(remaining, button.statusBar.smoothing)
		end
	elseif button.timeLeft then
		if db.barColorGradient then
			local r, g, b = E:ColorGradient(button.duration == 0 and 0 or (button.timeLeft / button.duration), .8, 0, 0, .8, .8, 0, 0, .8, 0)
			A:SetStatusBarColor(button.statusBar, r, g, b)
		end

		button.statusBar:SetValue(button.timeLeft, button.statusBar.smoothing)
	end
end

function A:CreateIcon(button)
	local header = button:GetParent()

	button.name = button:GetName()
	button.header = header
	button.filter = header.filter
	button.auraType = (header.filter == 'HELPFUL' and 'buffs') or 'debuffs'

	local enchantIndex = tonumber(strmatch(button.name, 'TempEnchant(%d)$'))
	button.enchantIndex = enchantIndex

	if enchantIndex then
		header['enchant'..enchantIndex] = button
		header.enchantButtons[enchantIndex] = button
	else
		button.instant = true -- let update on attribute change
	end

	button.cooldown = CreateFrame('Cooldown', '$parentCooldown', button, 'CooldownFrameTemplate')

	button.RaisedElement = CreateFrame('Frame', '$parent_RaisedElement', button)
	button.RaisedElement:OffsetFrameLevel(5)
	button.RaisedElement:SetAllPoints()

	button.texture = button:CreateTexture(nil, 'ARTWORK')
	button.texture:SetInside()

	button.count = button.RaisedElement:CreateFontString(nil, 'OVERLAY')
	button.count:FontTemplate()

	button.highlight = button:CreateTexture(nil, 'HIGHLIGHT')
	button.highlight:SetColorTexture(1, 1, 1, .45)
	button.highlight:SetInside()

	button.statusBar = CreateFrame('StatusBar', nil, button)
	button.statusBar:OffsetFrameLevel(nil, button)
	button.statusBar:SetFrameStrata(button:GetFrameStrata())
	button.statusBar:CreateBackdrop()

	button:SetScript('OnAttributeChanged', A.Button_OnAttributeChanged)
	button:SetScript('OnUpdate', A.Button_OnUpdate)
	button:SetScript('OnEnter', A.Button_OnEnter)
	button:SetScript('OnLeave', A.Button_OnLeave)
	button:SetScript('OnHide', A.Button_OnHide)
	button:SetScript('OnShow', A.Button_OnShow)

	E:RegisterCooldown(button.cooldown, 'auras')

	A:UpdateIcon(button)
end

function A:UpdateTexture(button) -- self here can be the header from UpdateMasque calling this function
	local db = A.db[button.auraType]
	local width, height = db.size, (db.keepSizeRatio and db.size) or db.height

	if db.keepSizeRatio then
		button.texture:SetTexCoords()
	else
		local left, right, top, bottom = E:CropRatio(width, height)
		button.texture:SetTexCoord(left, right, top, bottom)
	end
end

function A:UpdateIcon(button, update)
	local db = A.db[button.auraType]

	local width, height = db.size, (db.keepSizeRatio and db.size) or db.height
	if update then
		button:SetWidth(width)
		button:SetHeight(height)
	elseif button.header.MasqueGroup then
		local data = A:MasqueData(button.texture, button.highlight)
		button.header.MasqueGroup:AddButton(button, data)
	elseif not button.template then
		button:SetTemplate()
	end

	if button.texture then
		A:UpdateTexture(button)
	end

	if button.count then
		button.count:ClearAllPoints()
		button.count:Point('BOTTOMRIGHT', db.countXOffset, db.countYOffset)
		button.count:FontTemplate(LSM:Fetch('font', db.countFont), db.countFontSize, db.countFontOutline)
	end

	if button.statusBar then
		if E.Retail then
			button.statusBar.smoothing = (db.smoothbars and StatusBarInterpolation.ExponentialEaseOut) or StatusBarInterpolation.Immediate or nil
		else
			E:SetSmoothing(button.statusBar, db.smoothbars)
		end

		local pos, iconSize = db.barPosition, db.size - (E.Border * 2)
		local onTop, onBottom, onLeft = pos == 'TOP', pos == 'BOTTOM', pos == 'LEFT'
		local barSpacing = db.barSpacing + (E.PixelMode and 1 or 3)
		local barSize = db.barSize + (E.PixelMode and 0 or 2)
		local isHorizontal = onTop or onBottom

		button.statusBar:ClearAllPoints()
		button.statusBar:Size(isHorizontal and iconSize or barSize, isHorizontal and barSize or iconSize)
		button.statusBar:Point(E.InversePoints[pos], button, pos, isHorizontal and 0 or (onLeft and -barSpacing or barSpacing), not isHorizontal and 0 or (onTop and barSpacing or -barSpacing))
		button.statusBar:SetStatusBarTexture(LSM:Fetch('statusbar', db.barTexture))
		button.statusBar:SetOrientation(isHorizontal and 'HORIZONTAL' or 'VERTICAL')
		button.statusBar:SetRotatesTexture(not isHorizontal)
	end
end

function A:SetAuraTime(button, expiration, duration, modRate)
	button.duration = duration
	button.expiration = expiration
	button.modRate = modRate

	A:UpdateButton(button, duration, expiration, modRate)
end

function A:ClearAuraTime(button)
	button.duration = nil
	button.expiration = nil
	button.modRate = nil
	button.timeLeft = nil

	E:StopFlash(button, 1)
end

function A:UpdateAura(button, index)
	local unitToken = button.header:GetAttribute('unit')
	local success, data = pcall(GetAuraDataByIndex, unitToken, index, button.filter)
	if not success or not data then return end

	local icon = data.icon
	local duration = data.duration
	local expiration = data.expirationTime
	local debuffType = data.dispelName
	local count = data.applications
	local modRate = data.timeMod

	button.texture:SetTexture(icon)
	button.auraInstanceID = data.auraInstanceID
	button.unit = unitToken
	button.aura = data

	local minCount, maxCount = 2, 999 -- maybe do options for this
	if E:IsSecretValue(count) then
		button.count:SetText(GetAuraApplicationDisplayCount(unitToken, data.auraInstanceID, minCount, maxCount))
	else
		local hideCount = not count or (count < minCount or count > maxCount)
		button.count:SetText(hideCount and '' or count)
	end

	local color = (E:NotSecretValue(debuffType) and (button.filter == 'HARMFUL' and A.db.colorDebuffs) and DebuffColors[debuffType or 'None']) or E.db.general.bordercolor
	button:SetBackdropBorderColor(color.r, color.g, color.b)
	button.statusBar.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)

	if E.Retail then
		A:UpdateButton(button, duration, expiration, modRate)
	elseif duration and expiration then
		A:SetAuraTime(button, expiration, duration, modRate)
	else
		A:ClearAuraTime(button)
	end
end

function A:UpdateTempEnchant(button, index, expiration)
	if expiration then
		local quality = A.db.colorEnchants and GetInventoryItemQuality('player', index)
		local r, g, b = E:GetItemQualityColor(quality and quality > 1 and quality)

		button:SetBackdropBorderColor(r, g, b)
		button.statusBar.backdrop:SetBackdropBorderColor(r, g, b)
		button.texture:SetTexture(GetInventoryItemTexture('player', index))

		local remain = (expiration * 0.001) or 0
		local duration = (remain <= 600 and 600) or (remain <= 1800 and 1800) or (ceil(remain / 3600)*3600)
		local expire = remain + GetTime()

		A:SetAuraTime(button, expire, duration)
	else
		A:ClearAuraTime(button)
	end
end

function A:SetTooltip(button)
	if button:GetAttribute('index') then
		GameTooltip:SetUnitAura(button.header:GetAttribute('unit'), button:GetID(), button.filter)
	elseif button:GetAttribute('target-slot') then
		GameTooltip:SetInventoryItem('player', button:GetID())
	end
end

function A:Button_OnLeave()
	GameTooltip_Hide()
end

function A:Button_OnEnter()
	local db = A.db[self.auraType]
	GameTooltip:SetOwner(self, db.tooltipAnchorType or 'ANCHOR_BOTTOMLEFT', db.tooltipAnchorX or -5, db.tooltipAnchorY or-5)

	self.elapsed = 1 -- let the tooltip update next frame
end

function A:Button_OnShow()
	if self.enchantIndex then
		self.header.enchants[self.enchantIndex] = self
		self.header.elapsedEnchants = 1 -- let the enchant update next frame
	end
end

function A:Button_OnHide()
	if self.enchantIndex then
		self.header.enchants[self.enchantIndex] = nil
	else
		self.instant = true
	end
end

function A:UpdateButton(button, duration, expiration, modRate)
	local db = A.db[button.auraType]

	A:UpdateTime(button, duration, expiration, modRate)

	if E.Retail and not button.enchantIndex then -- midnight auras
		local auraDuration = button.unit and GetAuraDuration(button.unit, button.auraInstanceID)
		button.auraDuration = auraDuration or nil

		local showBar = db.barShow and (db.barNoDuration and 1)
		if auraDuration then
			if not showBar and (db.barShow and button.aura) then
				showBar = auraDuration:EvaluateRemainingDuration(E.Curves.Float.Alpha)
			end

			button.cooldown:SetCooldownFromDurationObject(auraDuration)

			button.statusBar:SetMinMaxValues(0, duration)

			if not db.barColorGradient then
				A:SetStatusBarColor(button.statusBar, db.barColor.r, db.barColor.g, db.barColor.b)
			end
		else
			button.cooldown:Clear()
		end

		button.statusBar:SetAlpha(showBar or 0)
	elseif not E.Retail or button.enchantIndex then
		local hasCooldown = duration > 0
		local barShown = db.barShow and (hasCooldown or (db.barNoDuration and duration == 0))
		button.statusBar:SetAlpha(barShown and 1 or 0)

		if barShown then
			button.statusBar:SetMinMaxValues(0, (hasCooldown and duration) or 1)

			if not db.barColorGradient then
				A:SetStatusBarColor(button.statusBar, db.barColor.r, db.barColor.g, db.barColor.b)
			elseif not hasCooldown then
				button.statusBar:SetValue(1, button.statusBar.smoothing)
				A:SetStatusBarColor(button.statusBar, 0, 0.8, 0)
			end
		end

		if hasCooldown then
			button.cooldown:SetCooldown((expiration - duration), duration, modRate)
		else
			button.cooldown:Clear()
		end
	end

	button.elapsed = 0
end

function A:UpdateTime(button, duration, expiration, modRate)
	button.timeLeft = (E:IsSecretValue(expiration) and 0) or (((expiration or 0) - GetTime()) / (modRate or 1))

	if button.timeLeft < 0.1 then
		A:ClearAuraTime(button)
	elseif not E.Retail and duration > 0 then
		A:UpdateFlash(button)
	end
end

function A:UpdateFlash(button)
	local db = button.timeLeft and A.db[button.auraType]
	local threshold = db and db.fadeThreshold
	if threshold and (button.timeLeft <= threshold) then
		E:Flash(button, 1, true)
	else
		E:StopFlash(button, 1)
	end
end

function A:Button_OnUpdate(elapsed)
	if self.elapsed and self.elapsed > 0.1 then
		if GameTooltip:IsOwned(self) then
			A:SetTooltip(self)
		end

		if self.statusBar:IsShown() then
			A:UpdateStatusBar(self)
		end

		if self.timeLeft then
			A:UpdateTime(self, self.duration, self.expiration, self.modRate)
		end

		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end

function A:Button_OnAttributeChanged(attr, value)
	if attr == 'index' then
		if self.instant then
			A:UpdateAura(self, value)
			self.instant = nil
		elseif self.header.spells[self] ~= value then
			self.header.spells[self] = value
		end
	elseif attr == 'target-slot' and self.enchantIndex and self.header.enchants[self.enchantIndex] ~= self then
		self.header.enchants[self.enchantIndex] = self
		self.header.elapsedEnchants = 0 -- reset the timer so we can wait for the data to be ready
	end
end

function A:UpdateMasque(header)
	header.MasqueGroup:ReSkin()
	header:ForEachChild(A.UpdateTexture) -- masque retrims them all so we have to too
end

function A:Header_OnEvent(event)
	if event == 'UNIT_AURA' and self.MasqueGroup then
		A:UpdateMasque(self)
	end
end

function A:Visibility_OnEvent(event)
	if event == 'WEAPON_ENCHANT_CHANGED' then
		local header = self.frame
		for enchantIndex, button in next, header.enchantButtons do
			if header.enchants[enchantIndex] ~= button then
				header.enchants[enchantIndex] = button
				header.elapsedEnchants = 0 -- reset the timer so we can wait for the data to be ready
			end
		end
	end
end

function A:Visibility_OnUpdate(elapsed)
	local header = self.frame
	if header.elapsedSpells and header.elapsedSpells > 0.1 then
		local button, value = next(header.spells)
		while button do
			A:UpdateAura(button, value)

			header.spells[button] = nil
			button, value = next(header.spells)
		end

		header.elapsedSpells = 0
	else
		header.elapsedSpells = (header.elapsedSpells or 0) + elapsed
	end

	if header.elapsedEnchants and header.elapsedEnchants > 0.5 then
		local index, enchant = next(header.enchants)
		if index then
			local _, main, _, _, _, offhand, _, _, _, ranged = GetWeaponEnchantInfo()
			while enchant do
				A:UpdateTempEnchant(enchant, enchant:GetID(), (index == 1 and main) or (index == 2 and offhand) or (index == 3 and ranged))

				header.enchants[index] = nil
				index, enchant = next(header.enchants)
			end
		end

		header.elapsedEnchants = 0
	else
		header.elapsedEnchants = (header.elapsedEnchants or 0) + elapsed
	end
end

function A:UpdateChild(child, index, db) -- self here is the header
	child.auraType = self.auraType
	child.db = db

	A:UpdateIcon(child, true)

	-- blizzard bug fix, icons arent being hidden when you reduce the amount of maximum buttons
	if index > (db.maxWraps * db.wrapAfter) and child:IsShown() then
		child:Hide()
	end
end

function A:UpdateHeader(header)
	if not E.private.auras.enable then return end

	local db = A.db[header.auraType]
	local width, height = db.size, (db.keepSizeRatio and db.size) or db.height

	E:UpdateClassColor(db.barColor)

	header:SetAttribute('config-width', width)
	header:SetAttribute('config-height', height)
	header:SetAttribute('template', 'ElvUIAuraTemplate')
	header:SetAttribute('weaponTemplate', header.filter == 'HELPFUL' and 'ElvUIAuraTemplate' or nil)
	header:SetAttribute('separateOwn', db.seperateOwn)
	header:SetAttribute('sortMethod', db.sortMethod)
	header:SetAttribute('sortDirection', db.sortDir)
	header:SetAttribute('maxWraps', db.maxWraps)
	header:SetAttribute('wrapAfter', db.wrapAfter)
	header:SetAttribute('point', DIRECTION_TO_POINT[db.growthDirection])
	header:SetAttribute('initialConfigFunction', A.AttributeInitialConfig)

	if IS_HORIZONTAL_GROWTH[db.growthDirection] then
		header:SetAttribute('minWidth', ((db.wrapAfter == 1 and 0 or db.horizontalSpacing) + width) * db.wrapAfter)
		header:SetAttribute('minHeight', (db.verticalSpacing + height) * db.maxWraps)
		header:SetAttribute('xOffset', DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection] * (db.horizontalSpacing + width))
		header:SetAttribute('yOffset', 0)
		header:SetAttribute('wrapXOffset', 0)
		header:SetAttribute('wrapYOffset', DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + height))
	else
		header:SetAttribute('minWidth', (db.horizontalSpacing + width) * db.maxWraps)
		header:SetAttribute('minHeight', ((db.wrapAfter == 1 and 0 or db.verticalSpacing) + height) * db.wrapAfter)
		header:SetAttribute('xOffset', 0)
		header:SetAttribute('yOffset', DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[db.growthDirection] * (db.verticalSpacing + height))
		header:SetAttribute('wrapXOffset', DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[db.growthDirection] * (db.horizontalSpacing + width))
		header:SetAttribute('wrapYOffset', 0)
	end

	header:ForEachChild(A.UpdateChild, db)

	if header.MasqueGroup then
		A:UpdateMasque(header)
	end
end

function A:ForEachChild(func, ...)
	if not func then return end

	for index, child in next, { self:GetChildren() } do
		func(self, child, index, ...)
	end
end

function A:CreateAuraHeader(filter)
	local name, auraType = filter == 'HELPFUL' and 'ElvUIPlayerBuffs' or 'ElvUIPlayerDebuffs', filter == 'HELPFUL' and 'buffs' or 'debuffs'

	local header = CreateFrame('Frame', name, E.UIParent, 'SecureAuraHeaderTemplate')
	header:SetClampedToScreen(true)
	header:UnregisterEvent('UNIT_AURA') -- we only need to watch player and vehicle
	header:RegisterUnitEvent('UNIT_AURA', 'player', 'vehicle')
	header:SetAttribute('unit', 'player')
	header:SetAttribute('filter', filter)
	header:HookScript('OnEvent', A.Header_OnEvent)
	header.ForEachChild = A.ForEachChild
	header.enchantButtons = {}
	header.enchants = {}
	header.spells = {}

	header.visibility = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
	header.visibility:SetScript('OnUpdate', A.Visibility_OnUpdate) -- dont put this on the main frame
	header.visibility:SetScript('OnEvent', A.Visibility_OnEvent) -- dont put this on the main frame
	header.visibility.frame = header
	header.auraType = auraType
	header.filter = filter
	header.name = name

	if E.Retail then
		header.visibility:RegisterEvent('WEAPON_ENCHANT_CHANGED')
	end

	RegisterAttributeDriver(header, 'unit', '[vehicleui] vehicle; player')
	SecureHandlerSetFrameRef(header.visibility, 'AuraHeader', header)
	RegisterStateDriver(header.visibility, 'customVisibility', '[petbattle] 0;1')
	header.visibility:SetAttribute('_onstate-customVisibility', A.AttributeCustomVisibility)

	if filter == 'HELPFUL' then
		header:SetAttribute('consolidateDuration', -1)
		header:SetAttribute('includeWeapons', 1)

		if MasqueGroupBuffs and E.private.auras.masque.buffs then
			header.MasqueGroup = MasqueGroupBuffs
		end
	elseif MasqueGroupDebuffs and E.private.auras.masque.debuffs then
		header.MasqueGroup = MasqueGroupDebuffs
	end

	header:Show()

	return header
end

function A:Initialize()
	if E.private.auras.disableBlizzard then
		_G.BuffFrame:Kill()

		if E.Retail then -- edit mode error
			_G.BuffFrame.numHideableBuffs = 0
		end

		if _G.DebuffFrame then
			_G.DebuffFrame:Kill()
		end

		if E.Wrath or E.Mists or E.Classic then
			_G.TemporaryEnchantFrame:Kill()
		end

		if E.Wrath or E.Mists then
			_G.ConsolidatedBuffs:Kill()
		end
	end

	if not E.private.auras.enable then return end

	A.Initialized = true

	local mapCluster = _G.MinimapCluster -- this is safer cause of anchoring protection
	local mapAnchor = _G.ElvUI_MinimapHolder or mapCluster or _G.Minimap
	local mapOffsetY = (mapAnchor == mapCluster and 3 or 0) + E.Spacing
	local mapOffsetX = 6 + E.Border

	if E.private.auras.buffsHeader then
		A.BuffFrame = A:CreateAuraHeader('HELPFUL')
		A:UpdateHeader(A.BuffFrame)

		A.BuffFrame:ClearAllPoints()
		A.BuffFrame:SetPoint('TOPRIGHT', mapAnchor, 'TOPLEFT', -mapOffsetX, -mapOffsetY)

		E:CreateMover(A.BuffFrame, 'BuffsMover', L["Player Buffs"], nil, nil, nil, nil, nil, 'auras,buffs')
	end

	if E.private.auras.debuffsHeader then
		A.DebuffFrame = A:CreateAuraHeader('HARMFUL')
		A:UpdateHeader(A.DebuffFrame)

		A.DebuffFrame:ClearAllPoints()
		A.DebuffFrame:SetPoint('BOTTOMRIGHT', mapAnchor, 'BOTTOMLEFT', -mapOffsetX, -mapOffsetY)

		E:CreateMover(A.DebuffFrame, 'DebuffsMover', L["Player Debuffs"], nil, nil, nil, nil, nil, 'auras,debuffs')
	end
end

E:RegisterModule(A:GetName())
