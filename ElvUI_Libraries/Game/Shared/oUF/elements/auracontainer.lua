--[[
# Element: Auras (AuraContainer)

12.1 replacement for the classic Auras element. Aura data is secret in combat,
so display goes through Blizzard's AuraContainer object type, which handles
tracking, filtering, sorting and button creation internally.

## Widget

Auras   - A Frame to hold the aura container for both buffs and debuffs.
Buffs   - A Frame to hold the aura container for buffs.
Debuffs - A Frame to hold the aura container for debuffs.

## Notes

At least one of the above widgets must be present for the element to work.
The holder frames keep the same anchoring behavior as the classic element,
the actual AuraButtons live on a child AuraContainer.

Containers cannot be created or reconfigured during combat; the element will
queue the work and run it on PLAYER_REGEN_ENABLED.

## Options

.filter          - Base aura filter string. Defaults to 'HELPFUL' for buffs and 'HARMFUL' for debuffs (string)
.num             - The maximum number of auras to display. Defaults to 32 (number)
.size            - Aura button size. Defaults to 16 (number)
.height          - Aura button height. Takes priority over `size` (number)
.spacing         - Spacing between each button. Defaults to 0 (number)
.numAuras        - Buttons per row, used for the layout row width (number)
.growthX         - Horizontal growth direction. Defaults to 'RIGHT' (string)
.growthY         - Vertical growth direction. Defaults to 'UP' (string)
.initialAnchor   - Anchor point for the aura buttons. Defaults to 'BOTTOMLEFT' (string)
.disableMouse    - Disables mouse events (boolean)
.containerGroups - Ordered list of aura group descriptors (table):
                   { filter, candidateFilters, sortMethod, sortDirection, maxFrameCount }

## Callbacks

.PostCreateButton(element, button)     - Called for each AuraButton the container creates.
.PostUpdateButtonSettings(element, button) - Called when settings should be reapplied to a button.
.PostUpdateContainer(element, container)   - Called after the container has been (re)configured.
--]]

local _, ns = ...
local oUF = ns.oUF

local next, ipairs, wipe = next, ipairs, wipe
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown

local HUGE = math.huge

local pendingElements = {}
local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_REGEN_ENABLED')

local function GrowthToFlow(growthX, growthY)
	local flow = _G.AnchorUtil.FlowDirection
	local horizontal = (growthX == 'LEFT' and flow.Left) or flow.Right
	local vertical = (growthY == 'DOWN' and flow.Down) or flow.Up

	return horizontal, vertical
end

local function InitializeButton(element, button)
	button.__owner = element

	element.buttons[#element.buttons + 1] = button

	local width = element.size or 16
	local height = element.height or element.size or 16
	button:SetSize(width, height)

	if element.PostCreateButton then
		element:PostCreateButton(button)
	end
end

local function ConfigureGroups(element, container)
	local groups = element.containerGroups
	local known = element.containerGroupKeys
	local active = element.activeGroupKeys

	wipe(active)

	local width = element.size or 16
	local height = element.height or element.size or 16
	local spacing = element.spacing or 0

	local layout = element.groupLayout
	layout.elementSpacingX = spacing
	layout.elementSpacingY = spacing
	layout.elementWidth = width
	layout.elementHeight = height
	layout.forceNewRow = element.forceNewRow or false

	if groups then
		for _, group in ipairs(groups) do
			local key = group.filter
			if key and not active[key] then -- first descriptor per filter wins
				active[key] = true

				local maxCount = group.maxFrameCount or element.num or 32
				local sortMethod = group.sortMethod or _G.AuraContainerSortMethod.Default
				local sortDirection = group.sortDirection or _G.AuraContainerSortDirection.Normal

				if known[key] then
					container:SetAuraGroupMaxFrameCount(key, maxCount)
					container:SetAuraGroupCandidateFilters(key, group.candidateFilters)
					container:SetAuraGroupSortMethod(key, sortMethod, sortDirection)
					container:SetAuraGroupLayout(key, layout)
				else
					known[key] = true

					container:AddAuraGroup(key, key, {
						maxFrameCount = maxCount,
						candidateFilters = group.candidateFilters,
						sortMethod = sortMethod,
						sortDirection = sortDirection,
						initializeFrame = element.initializeFrame,
						layout = layout
					})
				end
			end
		end
	end

	-- groups cannot be removed once added, collapse the unused ones instead
	for key in next, known do
		if not active[key] then
			container:SetAuraGroupMaxFrameCount(key, 0)
		end
	end
end

local function ConfigureContainer(element)
	local frame = element.__owner
	local unit = frame.unit
	if not unit then return end

	if InCombatLockdown() then
		pendingElements[element] = true
		return
	end

	local container = element.Container
	if not container then
		container = CreateFrame('AuraContainer', nil, element, 'CustomAuraContainerTemplate')
		element.Container = container
	end

	container:SetUnit(unit)
	element.containerUnit = unit

	local anchor = element.initialAnchor or 'BOTTOMLEFT'
	container:ClearAllPoints()
	container:SetPoint(anchor, element, anchor)
	container:SetAuraLayoutAnchorPoint(anchor)
	container:SetAuraLayoutGrowthDirection(GrowthToFlow(element.growthX, element.growthY))

	local width = element.size or 16
	local spacing = element.spacing or 0
	local perRow = element.numAuras
	local rowWidth = (perRow and perRow > 0 and (perRow * (width + spacing))) or element:GetWidth()
	container:SetAuraLayoutRowWidth((rowWidth and rowWidth > 0 and rowWidth) or HUGE)

	ConfigureGroups(element, container)

	for _, button in next, element.buttons do
		button:SetSize(width, element.height or element.size or 16)

		if element.PostUpdateButtonSettings then
			element:PostUpdateButtonSettings(button)
		end
	end

	container:SetEnabled(true)
	container:Show()

	if element.PostUpdateContainer then
		element:PostUpdateContainer(container)
	end
end

watcher:SetScript('OnEvent', function()
	local element = next(pendingElements)
	while element do
		pendingElements[element] = nil
		ConfigureContainer(element)

		element = next(pendingElements)
	end
end)

local function UpdateContainer(element)
	ConfigureContainer(element)
end

local function UpdateElement(element, unit)
	local container = element.Container
	if container then
		if element.containerUnit ~= unit then
			container:SetUnit(unit)
			element.containerUnit = unit
		end
	else
		ConfigureContainer(element)
	end
end

local function Update(self, event, unit)
	if self.unit ~= unit then return end

	if self.Auras then UpdateElement(self.Auras, unit) end
	if self.Buffs then UpdateElement(self.Buffs, unit) end
	if self.Debuffs then UpdateElement(self.Debuffs, unit) end
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function EnableElement(frame, element)
	element.__owner = frame
	element.__restricted = frame:IsAnchoringRestricted()
	element.ForceUpdate = ForceUpdate
	element.UpdateContainer = UpdateContainer

	if not element.buttons then element.buttons = {} end
	if not element.containerGroupKeys then element.containerGroupKeys = {} end
	if not element.activeGroupKeys then element.activeGroupKeys = {} end
	if not element.groupLayout then element.groupLayout = {} end

	if not element.initializeFrame then
		element.initializeFrame = function(button)
			InitializeButton(element, button)
		end
	end

	ConfigureContainer(element)

	element:Show()
end

local function Enable(self)
	if self.Buffs or self.Debuffs or self.Auras then
		if self.Buffs then EnableElement(self, self.Buffs) end
		if self.Debuffs then EnableElement(self, self.Debuffs) end
		if self.Auras then EnableElement(self, self.Auras) end

		return true
	end
end

local function DisableElement(element)
	pendingElements[element] = nil

	if element.Container then
		element.Container:SetEnabled(false)
	end

	element:Hide()
end

local function Disable(self)
	if self.Buffs then DisableElement(self.Buffs) end
	if self.Debuffs then DisableElement(self.Debuffs) end
	if self.Auras then DisableElement(self.Auras) end
end

if oUF.wowtoc >= 120100 then
	oUF:AddElement('Auras', Update, Enable, Disable)
end
