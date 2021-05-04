local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local A = E:GetModule('Auras')
local LSM = E.Libs.LSM

local _G = _G
local format, tinsert = format, tinsert
local select, unpack, strmatch = select, unpack, strmatch
local GetInventoryItemQuality = GetInventoryItemQuality
local GetInventoryItemTexture = GetInventoryItemTexture
local GetItemQualityColor = GetItemQualityColor
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local RegisterAttributeDriver = RegisterAttributeDriver
local RegisterStateDriver = RegisterStateDriver
local CreateFrame = CreateFrame
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
	local db = A.db[button.auraType]
	button.statusBar:SetValue(button.timeLeft)

	local threshold = db.fadeThreshold
	if threshold == -1 then
		return
	elseif button.timeLeft > threshold then
		E:StopFlash(button)
	else
		E:Flash(button, 1)
	end
end

function A:CreateIcon(button)
	local header = button:GetParent()
	local auraType = header.filter

	button.auraType = auraType == 'HELPFUL' and 'buffs' or 'debuffs' -- used to update cooldown text
	button.filter = auraType

	button.texture = button:CreateTexture(nil, 'ARTWORK')
	button.texture:SetInside()
	button.texture:SetTexCoord(unpack(E.TexCoords))

	button.count = button:CreateFontString(nil, 'OVERLAY')
	button.count:FontTemplate()

	button.text = button:CreateFontString(nil, 'OVERLAY')
	button.text:FontTemplate()

	button.highlight = button:CreateTexture(nil, 'HIGHLIGHT')
	button.highlight:SetColorTexture(1, 1, 1, .45)
	button.highlight:SetInside()

	button.statusBar = CreateFrame('StatusBar', nil, button)
	button.statusBar:SetFrameLevel(button:GetFrameLevel())
	button.statusBar:SetFrameStrata(button:GetFrameStrata())
	button.statusBar:CreateBackdrop()

	button:SetScript('OnAttributeChanged', A.OnAttributeChanged)

	-- support cooldown override
	if not button.isRegisteredCooldown then
		button.CooldownOverride = 'auras'
		button.isRegisteredCooldown = true
		button.forceEnabled = true
		button.showSeconds = true

		if not E.RegisteredCooldowns.auras then E.RegisteredCooldowns.auras = {} end
		tinsert(E.RegisteredCooldowns.auras, button)
	end

	A:Update_CooldownOptions(button)
	A:UpdateIcon(button)

	E:SetSmoothing(button.statusBar)
	E:SetUpAnimGroup(button)

	if auraType == 'HELPFUL' and MasqueGroupBuffs and E.private.auras.masque.buffs then
		MasqueGroupBuffs:AddButton(button, A:MasqueData(button.texture, button.highlight))
		if button.__MSQ_BaseFrame then button.__MSQ_BaseFrame:SetFrameLevel(2) end --Lower the framelevel to fix issue with buttons created during combat
		MasqueGroupBuffs:ReSkin()
	elseif auraType == 'HARMFUL' and MasqueGroupDebuffs and E.private.auras.masque.debuffs then
		MasqueGroupDebuffs:AddButton(button, A:MasqueData(button.texture, button.highlight))
		if button.__MSQ_BaseFrame then button.__MSQ_BaseFrame:SetFrameLevel(2) end --Lower the framelevel to fix issue with buttons created during combat
		MasqueGroupDebuffs:ReSkin()
	else
		button:SetTemplate()
	end
end

function A:UpdateIcon(button)
	local db = A.db[button.auraType]

	button.count:ClearAllPoints()
	button.count:Point('BOTTOMRIGHT', db.countXOffset, db.countYOffset)
	button.count:FontTemplate(LSM:Fetch('font', db.countFont), db.countFontSize, db.countFontOutline)

	button.text:ClearAllPoints()
	button.text:Point('TOP', button, 'BOTTOM', db.timeXOffset, db.timeYOffset)
	button.text:FontTemplate(LSM:Fetch('font', db.timeFont), db.timeFontSize, db.timeFontOutline)

	local pos, spacing, iconSize = db.barPosition, db.barSpacing, db.size - (E.Border * 2)
	local isOnTop, isOnBottom, isOnLeft = pos == 'TOP', pos == 'BOTTOM', pos == 'LEFT'
	local isHorizontal = isOnTop or isOnBottom

	button.statusBar:ClearAllPoints()
	button.statusBar:Size(isHorizontal and iconSize or (db.barSize + (E.PixelMode and 0 or 2)), isHorizontal and (db.barSize + (E.PixelMode and 0 or 2)) or iconSize)
	button.statusBar:Point(E.InversePoints[pos], button, pos, isHorizontal and 0 or ((isOnLeft and -((E.PixelMode and 1 or 3) + spacing)) or ((E.PixelMode and 1 or 3) + spacing)), not isHorizontal and 0 or ((isOnTop and ((E.PixelMode and 1 or 3) + spacing) or -((E.PixelMode and 1 or 3) + spacing))))
	button.statusBar:SetStatusBarTexture(LSM:Fetch('statusbar', db.barTexture))
	button.statusBar:SetOrientation(isHorizontal and 'HORIZONTAL' or 'VERTICAL')
	button.statusBar:SetRotatesTexture(not isHorizontal)
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
	button.timeLeft = nil
	button.text:SetText('')
	button:SetScript('OnUpdate', nil)
end

function A:UpdateAura(button, index)
	local unit = button:GetParent():GetAttribute('unit')
	local name, texture, count, dtype, duration, expiration = UnitAura(unit, index, button.filter)

	local DebuffType = dtype or 'none'
	if name then
		local db = A.db[button.auraType]
		if duration > 0 and expiration then
			A:SetAuraTime(button, expiration, duration)
		else
			A:ClearAuraTime(button)
		end

		local r, g, b = db.barColor.r, db.barColor.g, db.barColor.b
		if button.timeLeft and db.barColorGradient then
			r, g, b = E.oUF:ColorGradient(button.timeLeft, duration or 0, .8, 0, 0, .8, .8, 0, 0, .8, 0)
		end

		button.count:SetText(count > 1 and count)
		button.text:SetShown(db.showDuration)
		button.statusBar:SetShown((db.barShow and duration > 0) or (db.barShow and db.barNoDuration and duration == 0))
		button.statusBar:SetStatusBarColor(r, g, b)
		button.texture:SetTexture(texture)

		if button.debuffType ~= DebuffType then
			local color = button.filter == 'HARMFUL' and _G.DebuffTypeColor[DebuffType] or E.db.general.bordercolor
			button:SetBackdropBorderColor(color.r, color.g, color.b)
			button.statusBar.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		end
	end

	button.debuffType = DebuffType
end

function A:UpdateTempEnchant(button, index)
	local offset = (strmatch(button:GetName(), '2$') and 6) or 2
	local db = A.db[button.auraType]

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

	local r, g, b = db.barColor.r, db.barColor.g, db.barColor.b
	if expiration and db.barColorGradient then
		r, g, b = E.oUF:ColorGradient(remaining, duration, .8, 0, 0, .8, .8, 0, 0, .8, 0)
	end

	button.text:SetShown(db.showDuration)
	button.statusBar:SetShown((db.barShow and remaining > 0) or (db.barShow and db.barNoDuration and not expiration))
	button.statusBar:SetStatusBarColor(r, g, b)
end

function A:Update_CooldownOptions(button)
	E:Cooldown_Options(button, A.db.cooldown, button)
end

function A:OnAttributeChanged(attribute, value)
	if attribute == 'index' then
		A:UpdateAura(self, value)
	elseif attribute == 'target-slot' then
		A:UpdateTempEnchant(self, value)
	end
end

function A:UpdateHeader(header)
	if not E.private.auras.enable then return end

	local db = A.db[header.auraType]
	local template = format('ElvUIAuraTemplate%d', db.size)

	local colors = db.barColor
	if E:CheckClassColor(colors.r, colors.g, colors.b) then
		local classColor = E:ClassColor(E.myclass, true)
		colors.r, colors.g, colors.b = classColor.r, classColor.g, classColor.b
	end

	if header.filter == 'HELPFUL' then
		header:SetAttribute('consolidateTo', 0)
		header:SetAttribute('weaponTemplate', template)
	end

	header:SetAttribute('template', template)
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

	local index = 1
	local child = select(index, header:GetChildren())
	while child do
		child.db = db
		child.auraType = header.auraType -- used to update cooldown text
		child:Size(db.size, db.size)

		A:Update_CooldownOptions(child)
		A:UpdateIcon(child)

		--Blizzard bug fix, icons arent being hidden when you reduce the amount of maximum buttons
		if index > (db.maxWraps * db.wrapAfter) and child:IsShown() then
			child:Hide()
		end

		index = index + 1
		child = select(index, header:GetChildren())
	end

	if MasqueGroupBuffs and E.private.auras.buffsHeader and E.private.auras.masque.buffs then MasqueGroupBuffs:ReSkin() end
	if MasqueGroupDebuffs and E.private.auras.debuffsHeader and E.private.auras.masque.debuffs then MasqueGroupDebuffs:ReSkin() end
end

function A:CreateAuraHeader(filter)
	local name, auraType = filter == 'HELPFUL' and 'ElvUIPlayerBuffs' or 'ElvUIPlayerDebuffs', filter == 'HELPFUL' and 'buffs' or 'debuffs'

	local header = CreateFrame('Frame', name, E.UIParent, 'SecureAuraHeaderTemplate')
	header:SetClampedToScreen(true)
	header:SetAttribute('unit', 'player')
	header:SetAttribute('filter', filter)
	header.filter = filter
	header.auraType = auraType
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

	A.Initialized = true
	A.db = E.db.auras

	local xoffset = -(6 + E.Border)
	if E.private.auras.buffsHeader then
		A.BuffFrame = A:CreateAuraHeader('HELPFUL')
		A.BuffFrame:ClearAllPoints()
		A.BuffFrame:SetPoint('TOPRIGHT', _G.MMHolder or _G.MinimapCluster, 'TOPLEFT', xoffset, -E.Spacing)
		E:CreateMover(A.BuffFrame, 'BuffsMover', L["Player Buffs"], nil, nil, nil, nil, nil, 'auras,buffs')
		if Masque and MasqueGroupBuffs then A.BuffsMasqueGroup = MasqueGroupBuffs end
	end

	if E.private.auras.debuffsHeader then
		A.DebuffFrame = A:CreateAuraHeader('HARMFUL')
		A.DebuffFrame:ClearAllPoints()
		A.DebuffFrame:SetPoint('BOTTOMRIGHT', _G.MMHolder or _G.MinimapCluster, 'BOTTOMLEFT', xoffset, E.Spacing)
		E:CreateMover(A.DebuffFrame, 'DebuffsMover', L["Player Debuffs"], nil, nil, nil, nil, nil, 'auras,debuffs')
		if Masque and MasqueGroupDebuffs then A.DebuffsMasqueGroup = MasqueGroupDebuffs end
	end
end

E:RegisterModule(A:GetName())
