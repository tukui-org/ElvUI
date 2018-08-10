local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard')

--Cache global variables
--Lua functions
local _G = _G
--WoW-Api
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for mikk's FindGlobals script

local function BelowMinimapContainer()
	local container = _G["UIWidgetBelowMinimapContainerFrame"]
	local holder = CreateFrame('Frame', 'BelowMinimapContainerHolder', UIParent)
	holder:Point("TOPRIGHT", _G["Minimap"], "BOTTOMRIGHT", 0, -16)
	holder:Size(128, 40)

	container:ClearAllPoints()
	container:Point('CENTER', holder, 'CENTER')
	container:SetParent(holder)
	container.ignoreFramePositionManager = true

	--Reposition capture bar on layout update
	hooksecurefunc(_G["UIWidgetManager"].registeredWidgetSetContainers[2], "layoutFunc", function(widgetContainer, sortedWidgets, ...)
		widgetContainer:ClearAllPoints()
		if widgetContainer:GetWidth() ~= holder:GetWidth() then holder:Width(widgetContainer:GetWidth()) end
	end)
	--And this one cause UIParentManageFramePositions() repositions the widget constantly
	hooksecurefunc(container, "ClearAllPoints", function(self)
		self:SetPoint('CENTER', holder, 'CENTER')
	end)

	E:CreateMover(holder, 'BelowMinimapContainerMover', L["BelowMinimapContainer"], nil, nil, nil,'ALL,SOLO')
end

function B:Handle_UIWidgets()
	BelowMinimapContainer()
end
