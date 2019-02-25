local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard')

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

	E:CreateMover(topCenterHolder, 'TopCenterContainerMover', L["UIWidgetTopContainer"], nil, nil, nil,'ALL,SOLO')
	E:CreateMover(belowMiniMapHolder, 'BelowMinimapContainerMover', L["UIWidgetBelowMinimapContainer"], nil, nil, nil,'ALL,SOLO')

	topCenterContainer:ClearAllPoints()
	belowMiniMapcontainer:ClearAllPoints()

	topCenterContainer:SetPoint('CENTER', topCenterHolder)
	belowMiniMapcontainer:SetPoint('CENTER', belowMiniMapHolder, 'CENTER')

	hooksecurefunc(topCenterContainer, 'SetPoint', function(self, a, b, c, d, e)
		if b ~= topCenterHolder then
			self:ClearAllPoints()
			self:SetPoint('CENTER', topCenterHolder)
			self:SetParent(topCenterHolder)
		end
	end)

	hooksecurefunc(belowMiniMapcontainer, 'SetPoint', function(self, a, b, c, d, e)
		if b ~= belowMiniMapHolder then
			self:ClearAllPoints()
			self:SetPoint('CENTER', belowMiniMapHolder, 'CENTER')
			self:SetParent(belowMiniMapHolder)
		end
	end)
end

function B:Handle_UIWidgets()
	UIWidgets()
end
