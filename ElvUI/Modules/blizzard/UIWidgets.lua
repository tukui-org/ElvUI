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
	local topCenterContainer = _G["UIWidgetTopCenterContainerFrame"]
	local belowMiniMapcontainer = _G["UIWidgetBelowMinimapContainerFrame"]

	local topCenterHolder = CreateFrame('Frame', 'TopCenterContainerHolder', UIParent)
	topCenterHolder:Point("TOP", UIParent, "TOP", 0, 15)
	topCenterHolder:Size(10, 56)

	local belowMiniMapHolder = CreateFrame('Frame', 'BelowMinimapContainerHolder', UIParent)
	belowMiniMapHolder:Point("TOPRIGHT", _G["Minimap"], "BOTTOMRIGHT", 0, -16)
	belowMiniMapHolder:Size(128, 40)

	topCenterContainer:ClearAllPoints()
	topCenterContainer:Point('CENTER', topCenterHolder, 'CENTER')
	topCenterContainer:SetParent(topCenterHolder)
	topCenterContainer.ignoreFramePositionManager = true

	belowMiniMapcontainer:ClearAllPoints()
	belowMiniMapcontainer:Point('CENTER', belowMiniMapHolder, 'CENTER')
	belowMiniMapcontainer:SetParent(belowMiniMapHolder)
	belowMiniMapcontainer.ignoreFramePositionManager = true

	-- Reposition the TopCenter Widget after layout update
	hooksecurefunc(_G["UIWidgetManager"].registeredWidgetSetContainers[1], "layoutFunc", function(widgetContainer, sortedWidgets, ...)
		widgetContainer:ClearAllPoints()
		if widgetContainer:GetWidth() ~= topCenterHolder:GetWidth() then topCenterHolder:Width(widgetContainer:GetWidth()) end
	end)

	--Reposition capture bar on layout update
	hooksecurefunc(_G["UIWidgetManager"].registeredWidgetSetContainers[2], "layoutFunc", function(widgetContainer, sortedWidgets, ...)
		widgetContainer:ClearAllPoints()
		if widgetContainer:GetWidth() ~= belowMiniMapHolder:GetWidth() then belowMiniMapHolder:Width(widgetContainer:GetWidth()) end
	end)

	hooksecurefunc(topCenterContainer, "ClearAllPoints", function(self)
		self:SetPoint('CENTER', topCenterHolder, 'CENTER')
	end)

	--And this one cause UIParentManageFramePositions() repositions the widget constantly
	hooksecurefunc(belowMiniMapcontainer, "ClearAllPoints", function(self)
		self:SetPoint('CENTER', belowMiniMapHolder, 'CENTER')
	end)

	E:CreateMover(topCenterHolder, 'TopCenterContainerMover', L["TopCenterContainer"], nil, nil, nil,'ALL,SOLO')
	E:CreateMover(belowMiniMapHolder, 'BelowMinimapContainerMover', L["BelowMinimapContainer"], nil, nil, nil,'ALL,SOLO')
end

function B:Handle_UIWidgets()
	BelowMinimapContainer()
end
