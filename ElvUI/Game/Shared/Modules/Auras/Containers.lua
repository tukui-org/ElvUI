------------------------------------------------------------------------
-- Patch 12.1 introduces Aura Containers, so now this file exists.
------------------------------------------------------------------------
local E, L, V, P, G = unpack(ElvUI)
local A = E:GetModule('Auras')

local _G = _G
local next = next
local type = type
local unpack = unpack
local strmatch = strmatch
local strlower = strlower
local huge = math.huge

local AnchorUtil = AnchorUtil
local AuraButtonBorderStyle = AuraButtonBorderStyle
local InCombatLockdown = InCombatLockdown
local CreateFrame = CreateFrame

local ItemEnchantmentSlot = AuraContainerItemEnchantmentSlot
local MAINHAND = ItemEnchantmentSlot and ItemEnchantmentSlot.MainHand
local OFFHAND = ItemEnchantmentSlot and ItemEnchantmentSlot.OffHand
local FLOWDIRECTION = AnchorUtil and AnchorUtil.FlowDirection
local SORTDIRECTION = _G.AuraContainerSortDirection
local SORTMETHOD = _G.AuraContainerSortMethod

E.AuraContainerSortDirection = {}
E.AuraContainerSortMethod = {}

E.AuraTarget = {}
E.AuraFocus = {}
E.AuraDispel = {
	style = AuraButtonBorderStyle and AuraButtonBorderStyle.Color or nil,
	showWhenHarmful = true,
	showWhenHelpful = false
}

E.AuraEvents = {
	PLAYER_TARGET_CHANGED = E.AuraTarget,
	PLAYER_FOCUS_CHANGED = E.AuraFocus
}

if SORTMETHOD then -- add the new ones (?)
	E.AuraContainerSortMethod.TIME_REMAINING = SORTMETHOD.Expiration
	E.AuraContainerSortMethod.DURATION = SORTMETHOD.Default
	E.AuraContainerSortMethod.NAME = SORTMETHOD.Name
	E.AuraContainerSortMethod.PLAYER = SORTMETHOD.ImportantOnly -- player doesnt exist (?)
	E.AuraContainerSortMethod.INDEX = SORTMETHOD.AuraInstanceIDOnly
end

if SORTDIRECTION then
	E.AuraContainerSortDirection.ASCENDING = SORTDIRECTION.Normal
	E.AuraContainerSortDirection.DESCENDING = SORTDIRECTION.Reverse
	E.AuraContainerSortDirection['+'] = SORTDIRECTION.Normal
	E.AuraContainerSortDirection['-'] = SORTDIRECTION.Reverse
end

function E:Auras_OnEvent(event)
	local obj = E.AuraEvents[event]
	if not obj then return end

	for container in next, obj do
		container:UpdateAllAuras()
	end
end

function E:Auras_FlowDirection(growthX, growthY)
	return (growthX == 'LEFT' and FLOWDIRECTION.Left) or FLOWDIRECTION.Right, (growthY == 'DOWN' and FLOWDIRECTION.Down) or FLOWDIRECTION.Up
end

function E:Auras_CreateElements(button)
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

	local highlight = button:CreateTexture(nil, 'HIGHLIGHT')
	highlight:SetColorTexture(1, 1, 1, .45)
	highlight:SetAllPoints(texture)
	button.highlight = highlight

	local statusbar = CreateFrame('StatusBar', nil, button)
	statusbar:CreateBackdrop('Transparent')
	button.statusbar = statusbar

	local cooldown = CreateFrame('Cooldown', nil, button, 'CooldownFrameTemplate')
	cooldown:SetAllPoints(texture)
	button.cooldown = cooldown

	local textFrame = CreateFrame('Frame', nil, button)
	if textFrame then
		textFrame:SetAllPoints()
		button.textFrame = textFrame

		local countText = textFrame:CreateFontString(nil, 'OVERLAY')
		countText:FontTemplate()
		textFrame.count = countText

		local timeText = textFrame:CreateFontString(nil, 'OVERLAY')
		timeText:FontTemplate()
		timeText:Point('CENTER')
		textFrame.time = timeText

		local nameText = textFrame:CreateFontString(nil, 'OVERLAY')
		nameText:FontTemplate()
		nameText:Point('LEFT', button, 2, 0)
		textFrame.nameText = nameText
	end
end

function E:Auras_UpdateElement(container, button)
	local width, height = E:Auras_GetSize(container)
	button:SetSize(width, height)
	button:SetMouseMotionEnabled(not container.noMouse)

	if button.texture then
		if container.isAuraBar or container.keepSizeRatio or (width == height) then
			button.texture:SetTexCoords()
		else
			local left, right, top, bottom = E:CropRatio(width, height)
			button.texture:SetTexCoord(left, right, top, bottom)
		end

		button:SetIcon(button.texture)
	end

	local r, g, b = unpack(E.media.bordercolor)
	local bgR, bgG, bgB, bgA = unpack(E.media.backdropfadecolor)
	if button.border then
		if container.isAuraBar then
			local color = container.barColor
			if container.invertAurabars then
				button.border:SetTexture(container.statusbarTexture)
				button.border:SetVertexColor(color.r, color.g, color.b)
			else
				button.border:SetTexture(E.media.blankTex)
				button.border:SetVertexColor(r, g, b, bgA)
			end
		else
			button.border:SetVertexColor(r, g, b)
		end
	end

	if button.cooldown then
		button:SetDurationCooldown(button.cooldown)

		if container.isAuraBar then
			E:RegisterCooldown(button.cooldown, 'aurabars')

			if button.dispelBorder then
				button.dispelBorder:Hide()
			end

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

	if container.useStatusbar then
		if button.statusbar then
			button:SetDurationBar(button.statusbar)

			local color = container.barColor
			button.statusbar:SetStatusBarColor(color.r, color.g, color.b)
			button.statusbar:SetStatusBarTexture(container.barTexture)

			A:Configure_Statusbar(button, button.statusbar, container.barDB)
		end
	elseif container.isAuraBar then
		if button.statusbar then
			button.statusbar:SetAllPoints()
			button:SetDurationBar(button.statusbar)

			local color = container.barColor
			button.statusbar:SetReverseFill(container.reverseFill)

			if container.invertAurabars then
				button.statusbar:SetStatusBarTexture(E.media.blankTex)
				button.statusbar:SetStatusBarColor(bgR, bgG, bgB, bgA)
			else
				button.statusbar:SetStatusBarTexture(container.statusbarTexture)
				button.statusbar:SetStatusBarColor(color.r, color.g, color.b)
			end

			if button.border then
				button.border:ClearAllPoints()
				button.border:Point('TOP')
				button.border:Point('BOTTOM')

				if container.reverseFill then
					button.border:Point('LEFT')
					button.border:Point('RIGHT', button.statusbar:GetStatusBarTexture(), 'LEFT')
				else
					button.border:Point('RIGHT')
					button.border:Point('LEFT', button.statusbar:GetStatusBarTexture(), 'RIGHT')
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

	if button.dispelBorder then
		button:SetAuraBorder(button.dispelBorder, E.AuraDispel)
	end

	local textFrame = button.textFrame
	if textFrame then
		button:SetApplicationCount(textFrame.count)

		if container.isAuraBar then
			button:SetSpellName(textFrame.nameText)
		end
	end

	if container.unit == 'player' and strmatch(container.filter, 'HELPFUL') then
		button:SetCancelAuraButtons('RightButtonUp')
	end

	if container.MasqueGroup then
		container.MasqueGroup:AddButton(button, A:MasqueData(button.texture, button.highlight))
	end
end

function E:Auras_CreateButton(container, button)
	button.container = container

	E:Auras_CreateElements(button)
end

function E:Auras_UpdateElements(container)
	if InCombatLockdown() then return end

	for button in next, container.buttons do
		E:Auras_UpdateElement(container, button)
	end
end

function E:Auras_GenerateInitialize(container)
	return function(button)
		container.buttons[button] = container

		E:Auras_CreateButton(container, button)
		E:Auras_UpdateElement(container, button)
	end
end

function E:Auras_GetSize(container)
	return container.width or container.size or 24, container.height or container.size or 24
end

function E:Auras_UpdateLayout(container)
	local layout = container.layout
	if layout then
		local width, height = E:Auras_GetSize(container)
		layout.elementSpacing = container.spacing or 1
		layout.groupSpacing = container.spacing or 1
		layout.elementWidth = width
		layout.elementHeight = height
	end

	return layout
end

do
	local temp = {}
	function E:Auras_CanidateFilters(allow, block, maxDuration)
		temp.includeSpellIDs = allow
		temp.excludeSpellIDs = block
		temp.maxDuration = maxDuration

		return temp
	end
end

do
	local temp = {}
	function E:Auras_SetupGroup(container, filter, layout, maxCount, sortMethod, sortDirection)
		temp.maxFrameCount = maxCount
		temp.sortMethod = sortMethod
		temp.sortDirection = sortDirection
		temp.initializeFrame = E:Auras_GenerateInitialize(container)
		temp.candidateFilters = filter
		temp.layout = layout

		return temp
	end
end

function E:Auras_AddGroup(container, key, filter, layout, maxCount, sortMethod, sortDirection)
	local group = E:Auras_SetupGroup(container, filter, layout, maxCount, sortMethod, sortDirection)
	container:AddAuraGroup(key, key, group)
end

function E:Auras_UpdateGroup(container, key, filter, layout, maxCount, sortMethod, sortDirection)
	if filter then
		container:SetAuraGroupCandidateFilters(key, filter)
	end

	container:SetAuraGroupMaxFrameCount(key, maxCount)
	container:SetAuraGroupSortMethod(key, sortMethod, sortDirection)
	container:SetAuraGroupLayout(key, layout)
end

function E:Auras_SetEnchantments(container)
	local group = E:Auras_SetupGroup(container)
	container:AddItemEnchantment(MAINHAND, group)
	container:AddItemEnchantment(OFFHAND, group)
end

function E:Auras_SetContainer(container)
	local maxCount = container.maxFrameCount or 32
	local sortMethod = container.sortMethod or SORTMETHOD.Default
	local sortDirection = container.sortDirection or SORTDIRECTION.Normal
	local layout = E:Auras_UpdateLayout(container)

	local anchor = container.initialAnchor or 'BOTTOMLEFT'
	container:SetFlowLayoutAnchorPoint(anchor)

	local horizontal, vertical = E:Auras_FlowDirection(container.growthX, container.growthY)
	container:SetFlowLayoutGrowthDirection(horizontal, vertical)

	for filter in next, container.active do -- known but not active anymore
		local clear = container.known[filter] and not container.filters[filter]
		if clear then
			container:SetAuraGroupMaxFrameCount(filter, 0)
		end

		container.active[filter] = nil
	end

	for filter, index in next, container.filters do
		container.active[filter] = index -- set all active

		if container.known[filter] then
			E:Auras_UpdateGroup(container, filter, container.candidateFilters, layout, maxCount, sortMethod, sortDirection)
		else
			E:Auras_AddGroup(container, filter, container.candidateFilters, layout, maxCount, sortMethod, sortDirection)

			container.known[filter] = index
		end
	end
end

function E:Auras_SetLineSize(container)
	local rowWidth = (container.numAuras and container.numAuras > 0 and (container.numAuras * (container.size + container.spacing))) or container:GetWidth()
	container:SetFlowLayoutMaximumLineSize((rowWidth and rowWidth > 0 and rowWidth) or huge)
end

function E:Auras_SetUnit(container, unit)
	if not container then return end

	if unit == 'target' then
		E.AuraTarget[container] = unit
	elseif unit == 'focus' then
		E.AuraFocus[container] = unit
	end

	container.unit = unit
	container:SetUnit(unit)
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
	local container = CreateFrame('AuraContainer', override or (parent:GetName() .. which), parent, 'CustomAuraContainerTemplate, DisableUntrustedLayoutScriptsTemplate')
	container.known = {}
	container.active = {}
	container.buttons = {}
	container.layout = {}
	container.filters = {}

	if which then -- top auras dont set this here
		container.auraType = strlower(which)
	end

	return container
end

function E:InitializeAuras()
	if E.AuraEventFrame then return end

	local eventFrame = CreateFrame('Frame')
	eventFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
	eventFrame:RegisterEvent('PLAYER_FOCUS_CHANGED')
	eventFrame:SetScript('OnEvent', E.Auras_OnEvent)

	E.AuraEventFrame = eventFrame
end
