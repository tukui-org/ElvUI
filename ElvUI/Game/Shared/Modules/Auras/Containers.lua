------------------------------------------------------------------------
-- Patch 12.1 introduces Aura Containers, so now this file exists.
------------------------------------------------------------------------
local E, L, V, P, G = unpack(ElvUI)
local A = E:GetModule('Auras')
local UF = E:GetModule('UnitFrames')

local _G = _G
local ceil, huge = ceil, math.huge
local strfind, wipe = strfind, wipe
local floor, next, type = floor, next, type

local AnchorUtil = AnchorUtil
local CopyTable = CopyTable
local CreateFrame = CreateFrame
local UnitCanAssist = UnitCanAssist

local GetCVarBool = C_CVar.GetCVarBool
local AuraButtonBorderStyle = AuraButtonBorderStyle
local ItemEnchantmentPlacement = _G.CustomAuraContainerItemEnchantmentPlacement
local ItemEnchantmentSlot = _G.AuraContainerItemEnchantmentSlot
local MAINHAND = ItemEnchantmentSlot and ItemEnchantmentSlot.MainHand
local OFFHAND = ItemEnchantmentSlot and ItemEnchantmentSlot.OffHand
local FLOWDIRECTION = AnchorUtil and AnchorUtil.FlowDirection
local FLOWAXIS = AnchorUtil and AnchorUtil.FlowLayoutAxis
local SORTDIRECTION = _G.AuraContainerSortDirection
local SORTMETHOD = _G.AuraContainerSortMethod
local DispelTypes = E.Libs.Dispel:GetMyDispelTypes()

local FALLBACK = Mixin({ r = 1, g = 1, b = 1, a = 1 }, ColorMixin)

E.AuraHighlight = {
	style = AuraButtonBorderStyle and AuraButtonBorderStyle.Color or nil
 -- customDispelColorCurve is added from UpdateAuraCurves
}

E.AuraEventUnits = {
	PLAYER_TARGET_CHANGED = 'target',
	PLAYER_FOCUS_CHANGED = 'focus'
}

E.AuraDispel = {
	style = AuraButtonBorderStyle and AuraButtonBorderStyle.Color or nil,
	showWhenHarmful = true,
	showWhenHelpful = false,
	showWithoutDispelType = true,
	customDispelColorMap = {} -- updated by UpdateDispelColors
}

E.AuraContainerSortDirection = {}
E.AuraContainerSortMethod = {}
E.AuraPreviewFrames = {}
E.AuraGrowthMap = {}

if FLOWAXIS then
	E.AuraGrowthMap.RIGHT_DOWN	= { axis = FLOWAXIS.Horizontal,	horiz = FLOWDIRECTION.Right,	vert = FLOWDIRECTION.Down,	anchor = 'TOPLEFT' }
	E.AuraGrowthMap.RIGHT_UP	= { axis = FLOWAXIS.Horizontal,	horiz = FLOWDIRECTION.Right,	vert = FLOWDIRECTION.Up,	anchor = 'BOTTOMLEFT' }
	E.AuraGrowthMap.LEFT_DOWN	= { axis = FLOWAXIS.Horizontal,	horiz = FLOWDIRECTION.Left,		vert = FLOWDIRECTION.Down,	anchor = 'TOPRIGHT' }
	E.AuraGrowthMap.LEFT_UP		= { axis = FLOWAXIS.Horizontal,	horiz = FLOWDIRECTION.Left,		vert = FLOWDIRECTION.Up,	anchor = 'BOTTOMRIGHT' }
	E.AuraGrowthMap.DOWN_RIGHT	= { axis = FLOWAXIS.Vertical,	horiz = FLOWDIRECTION.Right,	vert = FLOWDIRECTION.Down,	anchor = 'TOPLEFT' }
	E.AuraGrowthMap.DOWN_LEFT	= { axis = FLOWAXIS.Vertical,	horiz = FLOWDIRECTION.Left,		vert = FLOWDIRECTION.Down,	anchor = 'TOPRIGHT' }
	E.AuraGrowthMap.UP_RIGHT	= { axis = FLOWAXIS.Vertical,	horiz = FLOWDIRECTION.Right,	vert = FLOWDIRECTION.Up,	anchor = 'BOTTOMLEFT' }
	E.AuraGrowthMap.UP_LEFT		= { axis = FLOWAXIS.Vertical,	horiz = FLOWDIRECTION.Left,		vert = FLOWDIRECTION.Up,	anchor = 'BOTTOMRIGHT' }
end

if SORTMETHOD then -- add the new ones (?)
	-- top aura conversion
	E.AuraContainerSortMethod.TIME = SORTMETHOD.Expiration -- not in UF or NP
	E.AuraContainerSortMethod.INDEX = SORTMETHOD.AuraInstanceIDOnly
	E.AuraContainerSortMethod.NAME = SORTMETHOD.Name

	-- unitframe and nameplates
	E.AuraContainerSortMethod.TIME_REMAINING = SORTMETHOD.Expiration
	E.AuraContainerSortMethod.DURATION = SORTMETHOD.Default
	E.AuraContainerSortMethod.PLAYER = SORTMETHOD.UnitFrameDebuff -- player doesnt exist (?)

	-- new ones for 12.1
	E.AuraContainerSortMethod.DEFENSIVE = SORTMETHOD.BigDefensive
	E.AuraContainerSortMethod.IMPORTANT = SORTMETHOD.ImportantOnly
end

if SORTDIRECTION then
	E.AuraContainerSortDirection.ASCENDING = SORTDIRECTION.Normal
	E.AuraContainerSortDirection.DESCENDING = SORTDIRECTION.Reverse
	E.AuraContainerSortDirection['+'] = SORTDIRECTION.Normal
	E.AuraContainerSortDirection['-'] = SORTDIRECTION.Reverse
end

function E:Auras_OnEvent(event, arg1, arg2)
	local container = self.owner
	if event == 'PLAYER_FOCUS_CHANGED' or event == 'PLAYER_TARGET_CHANGED' then
		local eventUnit = E.AuraEventUnits[event]
		if eventUnit == container.unit then
			if container.isAuraBar then
				UF:AuraBars_UpdateFilter(container, eventUnit)
				E:Auras_SetContainer(container)
			else -- for target frame
				container:UpdateAllAuras()
			end
		end
	elseif arg1 and (arg1 == container.unit) then -- about to do something
		if event == 'UNIT_FACTION' or event == 'UNIT_TARGETABLE_CHANGED' then
			container:UpdateAllAuras()
		end
	end
end

function E:Auras_FlowDirection(growthX, growthY)
	return (growthX == 'LEFT' and FLOWDIRECTION.Left) or FLOWDIRECTION.Right, (growthY == 'DOWN' and FLOWDIRECTION.Down) or FLOWDIRECTION.Up
end

function E:Auras_CreateHighlight(button)
	button:EnableMouse(false)
	button:SetAllPoints()

	local highlight = button:CreateTexture(nil, 'OVERLAY')
	highlight:SetTexture(E.media.blankTex)
	highlight:SetBlendMode('ADD')
	highlight:SetAllPoints()
	button.highlight = highlight
end

function E:Auras_UpdateHighlight(container, button)
	if button.highlight then
		if container.key == 'bad' then
			button:SetAuraBorder(button.highlight, E.AuraHighlight)
		else
			local color = button.data.color or FALLBACK
			button.highlight:SetVertexColor(color.r or 1, color.g or 1, color.b or 1, color.a or 1)
		end

		button.highlight:SetBlendMode(container.blendMode)
	end
end

function E:Auras_CreateIndicator(button)
	button:CreateBackdrop('Transparent', nil, true) -- these are forbidden, ignore updates

	local statusbar = CreateFrame('StatusBar', nil, button)
	button.statusbar = statusbar

	local texture = button:CreateTexture(nil, 'ARTWORK')
	texture:SetAllPoints()
	button.texture = texture

	local cooldown = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate')
	cooldown:SetAllPoints(texture)
	button.cooldown = cooldown
end

function E:Auras_UpdateIndicator(container, button)
	local data = button.data -- the data
	local point = data.point or 'BOTTOMLEFT'
	button:ClearAllPoints()
	button:Point(point, data.anchor or container.anchor or nil, data.relativePoint or point or nil, data.xOffset or 0, data.yOffset or 0)
	button:SetMouseMotionEnabled(not container.noMouse)

	if container.useStatusbar then -- not used atm
		local width, height = E:Auras_GetSize(container)
		button:Size(width, height)
		button.backdrop:Hide()

		if button.statusbar then
			local color = data.color
			button.statusbar:SetStatusBarTexture(container.barTexture)
			button.statusbar:SetStatusBarColor(color.r, color.g, color.b)
			button.statusbar:SetAllPoints()
		end
	else
		local textureIcon = data.style == 'texturedIcon'
		local onlyText = data.style == 'timerOnly'
		local colorIcon = data.style == 'coloredIcon'
		local cooldown = button.cooldown
		if cooldown then
			button:SetDurationCooldown(cooldown)

			E:RegisterCooldown(cooldown, 'auraindicator')

			if colorIcon or textureIcon then
				if button.texture then
					button.texture:Show()
					button.backdrop:Show()
				end

				cooldown:SetDrawSwipe(true)
				cooldown:SetDrawEdge(true)
			elseif onlyText then
				if button.texture then
					button.texture:Hide()
					button.backdrop:Hide()
				end

				cooldown:SetDrawSwipe(false)
				cooldown:SetDrawEdge(false)
			end

			cooldown:SetHideCountdownNumbers(not onlyText and not data.displayText)

			local text = cooldown.Text or cooldown:GetRegions()
			if text then -- CD module aquires the text to Text but without it we need to grab it
				text:ClearAllPoints()
				text:Point(data.cooldownAnchor or 'CENTER', data.cooldownX or 1, data.cooldownY or 1)

				local db = data.cooldownDB
				local color = (onlyText and data.color) or (db and db.colors.text)
				if color then
					text:SetTextColor(color.r, color.g, color.b)

					-- currently the entire system is PTR only but check anyways
					if cooldown.SetCountdownFormatter then -- this overrides the coloring
						cooldown:SetCountdownFormatter()
					end
				end
			end
		end

		local size = container.size
		if not data.sizeOffset or data.sizeOffset == 0 then
			button:Size(size, size)
		else
			button:Size(data.sizeOffset + size, data.sizeOffset + size)
		end

		if button.texture then
			button.texture:SetTexCoords()

			if colorIcon then
				local color = data.color
				button.texture:SetTexture(E.media.blankTex)
				button.texture:SetVertexColor(color.r, color.g, color.b)
				button:ClearIcon()
			else
				button:SetIcon(button.texture)
				button.texture:SetVertexColor(1, 1, 1)
			end
		end
	end
end

function E:Auras_CreateButton(button)
	local dispel = button:CreateTexture(nil, 'BACKGROUND', nil, -1)
	dispel:SetTexture(E.media.blankTex)
	dispel:SetAllPoints()
	button.dispelBorder = dispel

	local border = button:CreateTexture(nil, 'BACKGROUND', nil, -2)
	border:SetTexture(E.media.blankTex)
	border:SetAllPoints()
	button.border = border

	local backdrop = button:CreateTexture(nil, 'BACKGROUND', nil, -3)
	backdrop:SetTexture(E.media.blankTex)
	backdrop:SetVertexColor(0, 0, 0)
	backdrop:SetAllPoints()
	button.backdrop = backdrop

	local texture = button:CreateTexture(nil, 'ARTWORK')
	texture:SetInside()
	button.texture = texture

	local spark = button:CreateTexture(nil, 'OVERLAY')
	spark:SetTexture(E.media.blankTex)
	spark:SetVertexColor(0.9, 0.9, 0.9, 0.6)
	spark:SetBlendMode('ADD')
	spark:Width(2)
	button.spark = spark

	local highlight = button:CreateTexture(nil, 'HIGHLIGHT')
	highlight:SetColorTexture(1, 1, 1, .45)
	highlight:SetAllPoints(texture)
	button.highlight = highlight

	local statusbar = CreateFrame('StatusBar', nil, button)
	statusbar:CreateBackdrop('Transparent', nil, true) -- these are forbidden, ignore updates
	button.statusbar = statusbar

	local cooldown = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate')
	cooldown:SetAllPoints(texture)
	button.cooldown = cooldown

	local textFrame = CreateFrame('Frame', nil, button)
	if textFrame then
		textFrame:SetAllPoints()
		button.textFrame = textFrame

		local countText = textFrame:CreateFontString(nil, 'OVERLAY')
		textFrame.count = countText

		local timeText = textFrame:CreateFontString(nil, 'OVERLAY')
		timeText:FontTemplate(nil, 14)
		timeText:Point('CENTER')
		textFrame.time = timeText

		local nameText = textFrame:CreateFontString(nil, 'OVERLAY')
		nameText:Point('LEFT', button, 2, 0)
		textFrame.nameText = nameText
	end
end

function E:Auras_UpdateButton(container, button)
	local width, height = E:Auras_GetSize(container)
	button:Size(width, height)
	button:SetMouseMotionEnabled(not container.noMouse)
	button:SetCancelAuraButtons(GetCVarBool('ActionButtonUseKeyDown') and 'RightButtonDown' or 'RightButtonUp')

	if button.texture then
		if container.isAuraBar or container.keepSizeRatio or (width == height) then
			button.texture:SetTexCoords()
		else
			local left, right, top, bottom = E:CropRatio(width, height)
			button.texture:SetTexCoord(left, right, top, bottom)
		end

		if container.isUnitframe or container.isNameplate then
			button.texture:SetDesaturated(container.useDesaturate and not not strfind(button.filter, '!PLAYER'))
		end

		button:SetIcon(button.texture)
	end

	local valueColor = E.media.rgbvaluecolor
	local borderColor = E.media.bordercolor
	local backdropColor = E.media.backdropcolor
	local backdropFadeColor = E.media.backdropfadecolor
	if button.dispelBorder then
		if button.data.isEnchantment then
			if container.colorEnchants then
				button.dispelBorder:SetVertexColor(valueColor.r, valueColor.g, valueColor.b)
			else
				button.dispelBorder:SetVertexColor(borderColor.r, borderColor.g, borderColor.b)
			end
		else
			button.dispelBorder:SetVertexColor(borderColor.r, borderColor.g, borderColor.b)

			if container.isAuraBar or container.colorByType then -- auraByDispels would be isStealable
				button:SetAuraBorder(button.dispelBorder, E.AuraDispel)
			else
				button:ClearAuraBorder()
			end
		end
	end

	if button.border then
		if container.isAuraBar then
			if container.invertAurabars then
				button.border:SetTexture(container.statusbarTexture)
			else
				button.border:SetTexture(E.media.blankTex)
			end

			local color = container.customBackdropColor or backdropColor
			button.border:SetVertexColor(color.r or 1, color.g or 1, color.b or 1, container.isTransparent and backdropFadeColor.a or 1)
		else
			button.border:SetVertexColor(borderColor.r, borderColor.g, borderColor.b)
		end
	end

	if button.cooldown then
		button:SetDurationCooldown(button.cooldown)

		if container.isAuraBar then
			E:RegisterCooldown(button.cooldown, 'aurabars')

			button.cooldown:SetDrawSwipe(false)
			button.cooldown:SetDrawBling(false)
			button.cooldown:SetEdgeTexture(E.Media.Textures.Invisible)

			button.cooldown:ClearAllPoints()
			button.cooldown:Size(height)
			button.cooldown:Point('RIGHT', button.statusbar)
		elseif container.unitframeType then -- unitframe
			E:RegisterCooldown(button.cooldown, 'unitframe', container.unitframeType, container.auraType)
		elseif container.nameplateType then -- nameplate
			E:RegisterCooldown(button.cooldown, 'nameplates', container.nameplateType, container.auraType)
		elseif container.auraType then -- top auras
			E:RegisterCooldown(button.cooldown, 'auras')
		end -- will also update the cooldown when needed
	end

	if container.isTopAura then
		local statusbar = button.statusbar
		if container.useStatusbar then
			button:SetDurationBar(statusbar)

			local color = container.customBackdropColor or backdropColor
			statusbar:SetStatusBarTexture(container.barTexture)
			statusbar:SetStatusBarColor(color.r or 1, color.g or 1, color.b or 1, container.isTransparent and backdropFadeColor.a or 1)
			statusbar:Show()

			if container.isAuraBar then
				statusbar.backdrop.Center:Hide()
			end

			A:Configure_Statusbar(button, statusbar, container.barDB)
		else
			button:ClearDurationBar()
			statusbar:Hide()
		end
	elseif container.isAuraBar then
		if button.statusbar then
			button:SetDurationBar(button.statusbar)

			if container.invertAurabars then
				button.statusbar:SetStatusBarTexture(E.media.blankTex)
			else
				button.statusbar:SetStatusBarTexture(container.statusbarTexture)
			end

			local color = container.customBackdropColor or backdropColor
			button.statusbar:SetInside()
			button.statusbar:SetReverseFill(not container.reverseFill)
			button.statusbar:SetStatusBarColor(color.r or 1, color.g or 1, color.b or 1, container.isTransparent and backdropFadeColor.a or 1)

			if button.border then
				button.border:ClearAllPoints()
				button.border:Point('TOP')
				button.border:Point('BOTTOM')

				if button.spark then
					button.spark:ClearAllPoints()
					button.spark:Point(not container.reverseFill and 'RIGHT' or 'LEFT', button.border)
					button.spark:Point('BOTTOM', button.statusbar)
					button.spark:Point('TOP', button.statusbar)
				end

				local barTexture = button.statusbar:GetStatusBarTexture()
				barTexture:SetInside()
				if not container.reverseFill then
					button.border:Point('LEFT')
					button.border:Point('RIGHT', barTexture, 'LEFT')
				else
					button.border:Point('RIGHT')
					button.border:Point('LEFT', barTexture, 'RIGHT')
				end
			end
		end

		if button.backdrop then
			button.backdrop:ClearAllPoints()
			button.backdrop:Point('RIGHT', button, 'LEFT')
			button.backdrop:Size(height)
		end

		if button.texture then
			button.texture:SetInside(button.backdrop)
		end
	end

	local textFrame = button.textFrame
	if textFrame then
		local count = textFrame.count
		if count then
			local point = container.countPosition or 'CENTER'
			count:ClearAllPoints()
			count:Point(point, container.countXOffset or 0, container.countYOffset or 0)
			count:SetJustifyH(strfind(point, 'RIGHT') and 'RIGHT' or 'LEFT')
			count:FontTemplate(container.countFont, container.countFontSize, container.countFontOutline)

			button:SetApplicationCount(count)
		end

		local name = container.isAuraBar and textFrame.nameText
		if name then
			name:FontTemplate(container.textFont, container.textFontSize, container.textFontOutline)
			button:SetSpellName(name)
		end
	end

	if container.MasqueGroup then
		local data = A:MasqueData(button.texture, button.highlight)
		container.MasqueGroup:AddButton(button, data)
	end
end

function E:Auras_UpdateButtons(container)
	if E:IsRestrictedAuras() then return end

	for button in next, container.buttons do
		E:Auras_UpdateButton(container, button)
	end
end

function E:Auras_UpdateIndicators(container)
	if E:IsRestrictedAuras() then return end

	for button in next, container.indicators do
		E:Auras_UpdateIndicator(container, button)
	end
end

function E:Auras_GenerateButton(container, key, filter, data)
	return function(button)
		container.buttons[button] = container

		button.key = key
		button.data = data
		button.filter = filter
		button.container = container

		E:Auras_CreateButton(button)
		E:Auras_UpdateButton(container, button)
	end
end

function E:Auras_GenerateSlot(container, key, filter, data)
	return function(button)
		container.indicators[button] = container

		button.key = key
		button.data = data
		button.filter = filter
		button.container = container

		E:Auras_CreateIndicator(button)
		E:Auras_UpdateIndicator(container, button)
	end
end

function E:Auras_GenerateHighlight(container, key, data)
	return function(button)
		container.indicators[button] = container

		button.key = key
		button.data = data
		button.container = container

		E:Auras_CreateHighlight(button)
		E:Auras_UpdateHighlight(container, button)
	end
end

function E:Auras_GetSize(container)
	return container.width or container.size or 24, container.height or container.size or 24
end

function E:Auras_GetSpacing(container)
	return container.elementSpacing or container.spacing or 1
end

function E:Auras_UpdateLayout(container)
	local layout = container.layout
	if layout then
		local width, height = E:Auras_GetSize(container)
		layout.lineSpacing = container.lineSpacing
		layout.groupSpacing = container.groupSpacing
		layout.elementSpacing = E:Auras_GetSpacing(container)
		layout.elementHeight = height
		layout.elementWidth = width
	end

	return layout
end

do
	local temp = {}
	local spell = {}
	function E:Auras_FilterIndicator(data)
		temp.includeSpellIDs = spell

		wipe(spell)

		local dataID = data.id
		if dataID then
			spell[dataID] = true
		end

		return temp
	end
end

do
	local spell = {}
	function E:Auras_FilterHighlight(container, data)
		local temp = container.candidateTemp
		wipe(temp) -- trash object for reuse

		if data then
			temp.includeSpellIDs = spell

			wipe(spell)

			local dataID = data.id
			if dataID then
				spell[dataID] = true
			end
		else
			temp.includeDispelTypes = CopyTable(DispelTypes)
		end

		return temp
	end
end

do
	local layout = {}
	function E:Auras_LayoutEnchantment(container, placement)
		layout.elementSpacing = E:Auras_GetSpacing(container)
		layout.placement = placement

		return layout
	end

	local temp, data = {}, { isEnchantment = true }
	function E:Auras_SetupEnchantment(container, key, filter)
		temp.initializeFrame = E:Auras_GenerateButton(container, key, filter, data)

		return temp
	end
end

do
	local temp = {}
	function E:Auras_SetupGroup(container, key, data, layout, maxCount, sortMethod, sortDirection)
		local filter, candidate = data.filter, data.candidateFilters
		temp.initializeFrame = E:Auras_GenerateButton(container, key, filter, data)
		temp.candidateFilters = candidate
		temp.maxFrameCount = maxCount
		temp.sortDirection = sortDirection
		temp.sortMethod = sortMethod
		temp.layout = layout

		return temp
	end
end

do
	local temp = {}
	function E:Auras_SetupSlot(container, key, filter, candidate, sortMethod, sortDirection, data)
		temp.initializeFrame = E:Auras_GenerateSlot(container, key, filter, data)
		temp.candidateFilters = candidate
		temp.sortDirection = sortDirection
		temp.sortMethod = sortMethod

		return temp
	end
end

do
	local temp = {}
	function E:Auras_SetupHighlight(container, candidate, key, data)
		temp.initializeFrame = E:Auras_GenerateHighlight(container, key, data)
		temp.candidateFilters = candidate

		return temp
	end
end

function E:Auras_AddGroup(container, key, data, layout, maxCount, sortMethod, sortDirection)
	local group = E:Auras_SetupGroup(container, key, data, layout, maxCount, sortMethod, sortDirection)
	container:AddAuraGroup(key, data.filter, group)
end

function E:Auras_UpdateGroup(container, key, data, layout, maxCount, sortMethod, sortDirection)
	local filter, candidate = data.filter, data.candidateFilters
	container:SetAuraGroupCandidateFilters(key, candidate)
	container:SetAuraGroupFilterString(key, filter)
	container:SetAuraGroupMaxFrameCount(key, maxCount)
	container:SetAuraGroupSortMethod(key, sortMethod, sortDirection)
	container:SetAuraGroupLayout(key, layout)
end

function E:Auras_UpdateEnchantments(container)
	local layout = E:Auras_LayoutEnchantment(container, ItemEnchantmentPlacement.BeforeAuraGroups)
	container:SetItemEnchantmentLayout(layout)
end

function E:Auras_AddEnchantments(container)
	local group = E:Auras_SetupEnchantment(container, container.auraType, container.filter)
	container:AddItemEnchantment(MAINHAND, group)
	container:AddItemEnchantment(OFFHAND, group)

	E:Auras_UpdateEnchantments(container)
end

function E:Auras_UpdateSlot(container, key, filter, candidate, sortMethod, sortDirection)
	if candidate then
		container:SetAuraSlotCandidateFilters(key, candidate)
	end

	container:SetAuraSlotFilterString(key, filter)
	container:SetAuraSlotSortMethod(key, sortMethod, sortDirection)
end

function E:Auras_AddSlot(container, key, filter, candidate, sortMethod, sortDirection, data)
	local slot = E:Auras_SetupSlot(container, key, filter, candidate, sortMethod, sortDirection, data)
	container:AddAuraSlot(key, filter, slot)
end

function E:Auras_SetHighlight(container)
	local groupKey = container.key
	if groupKey == 'bad' then
		if container.known[groupKey] then return end

		local candidate = E:Auras_FilterHighlight(container)
		container.candidateFilters = candidate

		local slot = E:Auras_SetupHighlight(container, candidate)
		container:AddAuraSlot(groupKey, container.filter, slot)

		container.known[groupKey] = 'meow'
	else
		for key, data in next, container.keys do
			local candidate = E:Auras_FilterHighlight(container, data)
			container.candidateFilters = candidate

			local slotFilter = container.filter .. (data.ownOnly and '|PLAYER' or '')
			if container.known[key] then
				container:SetAuraSlotFilterString(key, slotFilter)
				container:SetAuraSlotCandidateFilters(key, candidate)
			else
				local slot = E:Auras_SetupHighlight(container, candidate, key, data)
				container:AddAuraSlot(key, slotFilter, slot)
				container.known[key] = 'bark'
			end
		end
	end
end

function E:Auras_SetIndicator(container)
	local sortMethod = container.sortMethod or SORTMETHOD.Default
	local sortDirection = container.sortDirection or SORTDIRECTION.Normal

	for key, data in next, container.keys do
		local candidate = E:Auras_FilterIndicator(data)
		container.candidateFilters = candidate

		local slotFilter = container.filter .. (data.anyUnit and '' or '|PLAYER')
		if container.known[key] then
			E:Auras_UpdateSlot(container, key, slotFilter, candidate, sortMethod, sortDirection)
		else
			E:Auras_AddSlot(container, key, slotFilter, candidate, sortMethod, sortDirection, data)

			container.known[key] = data
		end
	end
end

function E:Auras_SetupList(container, auraTable)
	wipe(container.keys)

	for spell, data in next, auraTable do
		local key = spell..''
		if container.isIndicator then
			if data.enabled then
				container.keys[key] = data
			end
		elseif container.isHighlight then
			if data.enable then
				if not data.id then
					data.id = spell
				end

				container.keys[key] = data
			end
		end
	end
end

function E:Auras_GetFlowInfo(container)
	local growth = E.AuraGrowthMap[container.growthDirection]
	if growth then
		return growth.anchor, growth.horiz, growth.vert, growth.axis
	end

	return container.initialAnchor or 'BOTTOMLEFT', E:Auras_FlowDirection(container.growthX, container.growthY)
end

function E:Auras_SetFlowLayout(container)
	local anchor, horiz, vert, axis = E:Auras_GetFlowInfo(container)
	if anchor == 'CENTER' then
		container:ResetFlowLayoutOptions()
	else
		container:SetFlowLayoutAnchorPoint(anchor)
		container:SetFlowLayoutGrowthDirection(horiz, vert)
	end

	container:SetFlowLayoutPadding(container.paddingLeft or 0, container.paddingRight or 0, container.paddingTop or 0, container.paddingBottom or 0)

	if axis then
		container:SetFlowLayoutAxis(axis)
	end
end

function E:Auras_HidePreviewIcons(container)
	local icons = container.previewIcons
	if not icons then return end

	container.wasPreviewing = nil

	for _, icon in next, icons do
		icon:Hide()
	end
end

do
	local _, _, texture = E:GetSpellInfo(5782) -- fear, same dummy icon oUF uses
	function E:Auras_CreatePreview(container)
		local button = CreateFrame('Button', nil, container)
		button:SetTemplate(nil, nil, true)
		button:EnableMouse(false)

		local icon = button:CreateTexture(nil, 'ARTWORK')
		icon:SetInside()
		icon:SetTexCoords()
		icon:SetTexture(texture)

		button.icon = icon

		return button
	end
end

function E:Auras_UpdatePreviewIcons(container)
	if not container.forceShowAuras then
		return E:Auras_HidePreviewIcons(container)
	end

	container.wasPreviewing = true

	local icons = container.previewIcons
	if not icons then
		icons = {}
		container.previewIcons = icons
	end

	local spacing = container.spacing or 1
	local count = container.maxFrameCount or 40
	local width, height = E:Auras_GetSize(container)
	local color = (container.isUnitframe and E.media.unitframeBorderColor) or E.media.bordercolor
	local debuff = E.db.general.debuffColors.None
	local curse = E.db.general.debuffColors.Curse

	local anchor, horiz, vert = E:Auras_GetFlowInfo(container)
	local centered = container.initialAnchor == 'CENTER' and 'CENTER'

	local perLine = container.numAuras or count
	if perLine < 1 then perLine = count end

	local numRows = ceil(count / perLine)
	if numRows < 1 then numRows = count end

	local btnWidth, btnHeight = width + spacing, height + spacing
	for i = 1, count do
		local button = icons[i]
		if not button then
			button = E:Auras_CreatePreview(container)
			icons[i] = button
		end

		local x, y
		local line, wrap = (i - 1) % perLine, floor((i - 1) / perLine)
		if centered then -- BOTTOM or TOP grow from the CENTER
			x = ((line - (perLine - 1) * 0.5) * btnWidth) * horiz
			y = ((wrap - (numRows - 1) * 0.5) * btnHeight) * vert
		else
			x = line * btnWidth * horiz
			y = wrap * btnHeight * vert
		end

		button:Show()
		button:ClearAllPoints()
		button:Point(centered or anchor, container, centered or anchor, x, y)
		button:Size(width, height)

		if container.auraType == 'debuffs' then
			button:SetBackdropBorderColor(debuff.r, debuff.g, debuff.b)
		elseif container.auraType == 'auras' then
			button:SetBackdropBorderColor(curse.r, curse.g, curse.b)
		else
			button:SetBackdropBorderColor(color.r, color.g, color.b)
		end
	end

	for _, icon in next, icons, count do
		icon:Hide() -- hide additional icons
	end
end

function E:Auras_SetContainer(container)
	local allowPreview = container.isUnitframe or container.isNameplate
	if allowPreview then -- dont add the ones we dont want to preview
		E.AuraPreviewFrames[container] = true
	end

	local maxCount = container.maxFrameCount or 40
	local layout = E:Auras_UpdateLayout(container)

	E:Auras_SetFlowLayout(container)

	for key, filter in next, container.active do -- known but not active anymore
		if container.known[key] and (container.filters[key] ~= filter) then
			container:SetAuraGroupMaxFrameCount(key, 0)
		end

		container.active[key] = nil
	end

	local count = container.forceShowAuras and 0 or maxCount
	local sortMethod = container.sortMethod or SORTMETHOD.Default
	local sortDirection = container.sortDirection or SORTDIRECTION.Normal

	for key, data in next, container.filters do
		if data.filter then
			container.active[key] = data.filter -- set all active

			if container.known[key] then
				E:Auras_UpdateGroup(container, key, data, layout, count, sortMethod, sortDirection)
			else
				E:Auras_AddGroup(container, key, data, layout, count, sortMethod, sortDirection)

				container.known[key] = data.filter
			end
		end
	end

	if allowPreview then
		E:Auras_UpdatePreviewIcons(container)
	end
end

function E:Auras_SetLineSize(container)
	local lineSize
	if container.isAuraBar then
		lineSize = 1
	elseif container.numAuras and container.numAuras > 0 then
		local spacing = E:Auras_GetSpacing(container)
		local width, height = E:Auras_GetSize(container)
		local size = (container.useWidth and width) or height
		lineSize = (size + spacing) * container.numAuras
	else
		local size = container.useWidth and container:GetWidth() or container:GetHeight()
		lineSize = E:NotSecretValue(size) and (size and size > 0 and size)
	end

	container:SetFlowLayoutMaximumLineSize(lineSize or huge)
end

function E:Auras_SetUnit(container, unit)
	container:SetUnit(unit)

	container.unit = unit
	container.canAssist = UnitCanAssist('player', unit)
end

function E:Auras_SetEnabled(container)
	container:SetEnabled(container.enabled and container.canAssist)
end

function E:Auras_GroupUnit(container, unit)
	if not container then return end

	E:Auras_SetUnit(container, unit)

	if container.isHighlight then
		E:Auras_SetEnabled(container)
	end
end

function E:Auras_GetFilter(obj, key)
	local filter = obj and obj[key]
	local spells = filter and filter.spells
	if not spells then return end

	local list
	for spellID, spell in next, spells do
		if spell.enable and type(spellID) == 'number' then
			if not list then list = {} end

			list[spellID] = true
		end
	end

	return list
end

function E:Auras_Create(parent, which, override)
	local parentName = parent and parent:GetName()
	local container = CreateFrame('AuraContainer', override or (parentName and (parentName..which)) or nil, parent, 'CustomAuraContainerTemplate, DisableUntrustedLayoutScriptsTemplate')

	container.parentName = parentName
	container.parent = parent

	container.known = {} -- both
	container.keys = {} -- indicators
	container.indicators = {}
	container.active = {} -- groups
	container.buttons = {}
	container.layout = {}
	container.filters = {}

	local events = CreateFrame('Frame', nil, container)
	events.owner = container
	container.events = events

	-- bugged: vehicle
	events:RegisterEvent('UNIT_FACTION')
	events:RegisterEvent('UNIT_TARGETABLE_CHANGED')

	-- aurabar to switch to friendship
	events:RegisterEvent('PLAYER_TARGET_CHANGED')
	events:RegisterEvent('PLAYER_FOCUS_CHANGED')
	events:SetScript('OnEvent', E.Auras_OnEvent)

	return container
end
