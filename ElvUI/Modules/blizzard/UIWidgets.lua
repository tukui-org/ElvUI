local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard')

--Cache global variables
--Lua functions
local _G = _G
--WoW-Api
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for mikk's FindGlobals script

local function UIWidgets()
	local topCenterContainer = _G["UIWidgetTopCenterContainerFrame"]
	local belowMiniMapcontainer = _G["UIWidgetBelowMinimapContainerFrame"]

	local topCenterHolder = CreateFrame('Frame', 'TopCenterContainerHolder', E.UIParent)
	topCenterHolder:Point("TOP", E.UIParent, "TOP", 0, -30)
	topCenterHolder:Size(10, 58)

	local belowMiniMapHolder = CreateFrame('Frame', 'BelowMinimapContainerHolder', E.UIParent)
	belowMiniMapHolder:Point("TOPRIGHT", _G["Minimap"], "BOTTOMRIGHT", 0, -16)
	belowMiniMapHolder:Size(128, 40)

	topCenterContainer:ClearAllPoints()
	topCenterContainer:SetPoint('CENTER', topCenterHolder)

	belowMiniMapcontainer:ClearAllPoints()
	belowMiniMapcontainer:Point('CENTER', belowMiniMapHolder, 'CENTER')
	belowMiniMapcontainer:SetParent(belowMiniMapHolder)
	belowMiniMapcontainer.ignoreFramePositionManager = true

	--Reposition capture bar on layout update
	hooksecurefunc(_G["UIWidgetManager"].registeredWidgetSetContainers[2], "layoutFunc", function(widgetContainer)
		widgetContainer:ClearAllPoints()
		if widgetContainer:GetWidth() ~= belowMiniMapHolder:GetWidth() then belowMiniMapHolder:Width(widgetContainer:GetWidth()) end
	end)

	--And this one cause UIParentManageFramePositions() repositions the widget constantly
	hooksecurefunc(belowMiniMapcontainer, "ClearAllPoints", function(self)
		self:SetPoint('CENTER', belowMiniMapHolder, 'CENTER')
	end)

	E:CreateMover(topCenterHolder, 'TopCenterContainerMover', L["UIWidgetTopContainer"], nil, nil, nil,'ALL,SOLO')
	E:CreateMover(belowMiniMapHolder, 'BelowMinimapContainerMover', L["UIWidgetBelowMinimapContainer"], nil, nil, nil,'ALL,SOLO')
end

function B:Handle_UIWidgets()
	UIWidgets()
end
