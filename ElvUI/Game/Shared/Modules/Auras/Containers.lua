------------------------------------------------------------------------
-- Patch 12.1 introduces Aura Containers, so now this file exists.
------------------------------------------------------------------------
local E, L, V, P, G = unpack(ElvUI)
local A = E:GetModule('Auras')
local UF = E:GetModule('UnitFrames')

local _G = _G
local type = type
local unpack = unpack

local AnchorUtil = AnchorUtil
local CreateFrame = CreateFrame

local FLOWDIRECTION = AnchorUtil and AnchorUtil.FlowDirection
local SORTDIRECTION = _G.AuraContainerSortDirection
local SORTMETHOD = _G.AuraContainerSortMethod

E.AuraContainers = {}
E.AuraTarget = {}
E.AuraFocus = {}
E.AuraEvents = {
	PLAYER_TARGET_CHANGED = E.AuraTarget,
	PLAYER_FOCUS_CHANGED = E.AuraFocus
}

function E:Auras_OnEvent(event)
	local obj = E.AuraEvents[event]
	if not obj then return end

	for _, container in next, obj do
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

function E:Auras_UpdateElements(container, button)
	local width, height = E:Auras_GetSize(container)
	button:SetSize(width, height)

	if button.texture then
		if container.keepSizeRatio or (width == height) then
			button.texture:SetTexCoords()
		else
			local left, right, top, bottom = E:CropRatio(width, height)
			button.texture:SetTexCoord(left, right, top, bottom)
		end

		button:SetIcon(button.texture)
	end

	if button.statusbar then
		button:SetDurationBar(button.statusbar)
	end

	if button.dispelBorder then
		button.dispelBorder:Hide()
	end

	local textFrame = button.textFrame
	if textFrame then
		button:SetApplicationCount(textFrame.count)
		button:SetDurationText(textFrame.time, { formatter = nil })
	end

	if container.filter == 'HELPFUL' then
		button:SetCancelAuraButtons('RightButtonUp')
	end

	if container.MasqueGroup then
		container.MasqueGroup:AddButton(button, A:MasqueData(button.texture, button.highlight))
	end
end

function E:Auras_CreateButton(container, button)
	E:Auras_CreateElements(button)
	E:Auras_UpdateElements(container, button)
end

function E:Auras_GenerateInitialize(container)
	return function(button)
		container.buttons[button] = container

		E:Auras_CreateButton(container, button)
	end
end

function E:Auras_GetSize(container)
	return container.width or container.size or 24, container.height or container.size or 24
end

function E:Auras_SetContainer(container, key, filter)
	container.filter = filter

	local layout = container.layout
	if layout then
		local width, height = E:Auras_GetSize(container)
		layout.elementSpacingX = container.spacingX or container.spacing or 1
		layout.elementSpacingY = container.spacingY or container.spacing or 1
		layout.elementWidth = width
		layout.elementHeight = height
	end

	local maxCount = container.maxFrameCount or 32
	local sortMethod = container.sortMethod or SORTMETHOD.Default
	local sortDirection = container.sortDirection or SORTDIRECTION.Normal

	local horizontal, vertical = E:Auras_FlowDirection(container.growthX, container.growthY)
	container:SetFlowLayoutGrowthDirection(horizontal, vertical)

	if container.filters[key] then
		if type(filter) == 'table' then
			container:SetAuraGroupCandidateFilters(key, filter)
		end

		container:SetAuraGroupMaxFrameCount(key, maxCount)
		container:SetAuraGroupSortMethod(key, sortMethod, sortDirection)
		container:SetAuraGroupLayout(key, layout)
	else
		container.filters[key] = filter

		local func = E:Auras_GenerateInitialize(container)
		local group = E:Auras_AddGroup(maxCount, filter, sortMethod, sortDirection, func, layout)
		container:AddAuraGroup(key, filter, group)
	end
end

function E:Auras_SetUnit(container, unit)
	container.unit = unit
	container:SetUnit(unit)
end

function E:Auras_Create(parent, name, unit, key, filter)
	if E.AuraContainers[key] then return end -- what?

	local container = CreateFrame('AuraContainer', name, parent, 'CustomAuraContainerTemplate')
	container.filters = {}
	container.buttons = {}
	container.layout = {}

	E.AuraContainers[key] = container

	if unit == 'target' then
		E.AuraTarget[key] = container
	elseif unit == 'focus' then
		E.AuraFocus[key] = container
	end

	E:Auras_SetUnit(container, unit)
	E:Auras_SetContainer(container, key, filter)

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
