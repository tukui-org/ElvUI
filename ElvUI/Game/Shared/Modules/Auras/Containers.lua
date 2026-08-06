------------------------------------------------------------------------
-- Patch 12.1 introduces Aura Containers, so now this file exists.
------------------------------------------------------------------------
local E, L, V, P, G = unpack(ElvUI)
local A = E:GetModule('Auras')

local _G = _G
local next = next
local type = type
local unpack = unpack
local strlower = strlower
local huge = math.huge

local AnchorUtil = AnchorUtil
local AuraButtonBorderStyle = AuraButtonBorderStyle
local InCombatLockdown = InCombatLockdown
local CreateFrame = CreateFrame

local FLOWDIRECTION = AnchorUtil and AnchorUtil.FlowDirection
local SORTDIRECTION = _G.AuraContainerSortDirection
local SORTMETHOD = _G.AuraContainerSortMethod

E.AuraContainerSortDirection = {}
E.AuraContainerSortMethod = {}

E.AuraTarget = {}
E.AuraFocus = {}
E.AuraDispel = {
	style = AuraButtonBorderStyle.Color,
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
end

function E:Auras_OnEvent(event)
	local obj = E.AuraEvents[event]
	if not obj then return end

	for container in next, obj do
		container:UpdateAllAuras()
	end
end

do
	local temp = {}
	function E:Auras_AddGroup(maxCount, filters, sortMethod, sortDirection, initializeFrame, layout)
		temp.maxFrameCount = maxCount
		temp.sortMethod = sortMethod
		temp.sortDirection = sortDirection
		temp.initializeFrame = initializeFrame
		temp.layout = layout
		temp.candidateFilters = type(filters) == 'table' and filters or nil

		return temp
	end
end

function E:Auras_FlowDirection(growthX, growthY)
	return (growthX == 'LEFT' and FLOWDIRECTION.Left) or FLOWDIRECTION.Right, (growthY == 'DOWN' and FLOWDIRECTION.Down) or FLOWDIRECTION.Up
end

function E:Auras_CreateElements(button)
	local r, g, b = unpack(E.media.bordercolor)

	local dispel = button:CreateTexture(nil, 'BACKGROUND', nil, -1)
	dispel:SetTexture(E.media.blankTex)
	dispel:SetAllPoints()
	button.dispelBorder = dispel

	local border = button:CreateTexture(nil, 'BACKGROUND', nil, -2)
	border:SetTexture(E.media.blankTex)
	border:SetVertexColor(r, g, b)
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
	statusbar:OffsetFrameLevel()
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
	end
end

function E:Auras_UpdateElement(container, button)
	local width, height = E:Auras_GetSize(container)
	button:SetSize(width, height)
	button:SetMouseMotionEnabled(not container.noMouse)

	if button.texture then
		if container.keepSizeRatio or (width == height) then
			button.texture:SetTexCoords()
		else
			local left, right, top, bottom = E:CropRatio(width, height)
			button.texture:SetTexCoord(left, right, top, bottom)
		end

		button:SetIcon(button.texture)
	end

	if button.cooldown then
		button:SetDurationCooldown(button.cooldown)

		-- will also update the cooldown when needed
		if container.unitframeType then -- unitframe
			E:RegisterCooldown(button.cooldown, 'unitframe', container.unitframeType, container.auraType)
		elseif container.nameplateType then -- nameplate
			E:RegisterCooldown(button.cooldown, 'nameplates', container.nameplateType, container.auraType)
		elseif container.auraType then -- top auras
			E:RegisterCooldown(button.cooldown, 'auras')
		end
	end

	if button.statusbar then
		button:SetDurationBar(button.statusbar)
	end

	if button.dispelBorder then
		button:SetAuraBorder(button.dispelBorder, E.AuraDispel)
	end

	local textFrame = button.textFrame
	if textFrame then
		button:SetApplicationCount(textFrame.count)

		-- button:SetDurationText(textFrame.time, { formatter = nil })
	end

	if container.unit == 'player' and container.filter == 'HELPFUL' then
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
		layout.elementSpacingX = container.spacingX or container.spacing or 1
		layout.elementSpacingY = container.spacingY or container.spacing or 1
		layout.elementWidth = width
		layout.elementHeight = height
	end

	return layout
end

function E:Auras_SetContainer(container, filter)
	container.filter = filter

	local maxCount = container.maxFrameCount or 32
	local sortMethod = container.sortMethod or SORTMETHOD.Default
	local sortDirection = container.sortDirection or SORTDIRECTION.Normal

	local layout = E:Auras_UpdateLayout(container)
	local anchor = container.initialAnchor or 'BOTTOMLEFT'
	container:SetFlowLayoutAnchorPoint(anchor)

	local horizontal, vertical = E:Auras_FlowDirection(container.growthX, container.growthY)
	container:SetFlowLayoutGrowthDirection(horizontal, vertical)

	if container.filters[filter] then
		if type(filter) == 'table' then
			container:SetAuraGroupCandidateFilters(filter, filter)
		end

		container:SetAuraGroupMaxFrameCount(filter, maxCount)
		container:SetAuraGroupSortMethod(filter, sortMethod, sortDirection)
		container:SetAuraGroupLayout(filter, layout)
	else
		container.filters[filter] = filter

		local func = E:Auras_GenerateInitialize(container)
		local group = E:Auras_AddGroup(maxCount, filter, sortMethod, sortDirection, func, layout)
		container:AddAuraGroup(filter, filter, group)
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

function E:Auras_Create(parent, which, override)
	local container = CreateFrame('AuraContainer', override or (parent:GetName() .. which), parent, 'CustomAuraContainerTemplate, DisableUntrustedLayoutScriptsTemplate')
	container.filters = {}
	container.buttons = {}
	container.layout = {}

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
