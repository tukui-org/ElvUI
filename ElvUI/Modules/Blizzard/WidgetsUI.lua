local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

local _G = _G
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function topCenterPosition(self, _, b)
	local holder = _G.TopCenterContainerHolder
	if b and (b ~= holder) then
		self:ClearAllPoints()
		self:SetPoint('CENTER', holder)
		self:SetParent(holder)
	end
end

local function belowMinimapPosition(self, _, b)
	local holder = _G.BelowMinimapContainerHolder
	if b and (b ~= holder) then
		self:ClearAllPoints()
		self:SetPoint('CENTER', holder, 'CENTER')
		self:SetParent(holder)
	end
end

local function UIWidgets()
	local topCenterContainer = _G.UIWidgetTopCenterContainerFrame
	local belowMiniMapcontainer = _G.UIWidgetBelowMinimapContainerFrame

	local topCenterHolder = CreateFrame('Frame', 'TopCenterContainerHolder', E.UIParent)
	topCenterHolder:SetPoint('TOP', E.UIParent, 'TOP', 0, -30)
	topCenterHolder:SetSize(10, 58)

	local belowMiniMapHolder = CreateFrame('Frame', 'BelowMinimapContainerHolder', E.UIParent)
	belowMiniMapHolder:SetPoint('TOPRIGHT', _G.Minimap, 'BOTTOMRIGHT', 0, -16)
	belowMiniMapHolder:SetSize(128, 40)

	E:CreateMover(topCenterHolder, 'TopCenterContainerMover', L["UIWidgetTopContainer"], nil, nil, nil,'ALL,SOLO')
	E:CreateMover(belowMiniMapHolder, 'BelowMinimapContainerMover', L["UIWidgetBelowMinimapContainer"], nil, nil, nil,'ALL,SOLO')

	topCenterContainer:ClearAllPoints()
	topCenterContainer:SetPoint('CENTER', topCenterHolder)

	belowMiniMapcontainer:ClearAllPoints()
	belowMiniMapcontainer:SetPoint('CENTER', belowMiniMapHolder, 'CENTER')

	hooksecurefunc(topCenterContainer, 'SetPoint', topCenterPosition)
	hooksecurefunc(belowMiniMapcontainer, 'SetPoint', belowMinimapPosition)
end

function B:Handle_UIWidgets()
	UIWidgets()
end
