local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local B = E:GetModule('Blizzard')

--Lua functions
local _G = _G
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local function topCenterPosition(self, _, b)
	local holder = _G.TopCenterContainerHolder
	if b and (b ~= holder) then
		self:ClearAllPoints()
		self:Point('CENTER', holder)
		self:SetParent(holder)
	end
end

local function belowMinimapPosition(self, _, b)
	local holder = _G.BelowMinimapContainerHolder
	if b and (b ~= holder) then
		self:ClearAllPoints()
		self:Point('CENTER', holder, 'CENTER')
		self:SetParent(holder)
	end
end

local function UIWidgets()
	local topCenterContainer = _G.UIWidgetTopCenterContainerFrame
	local belowMiniMapcontainer = _G.UIWidgetBelowMinimapContainerFrame

	local topCenterHolder = CreateFrame('Frame', 'TopCenterContainerHolder', E.UIParent)
	topCenterHolder:Point("TOP", E.UIParent, "TOP", 0, -30)
	topCenterHolder:Size(10, 58)

	local belowMiniMapHolder = CreateFrame('Frame', 'BelowMinimapContainerHolder', E.UIParent)
	belowMiniMapHolder:Point("TOPRIGHT", _G.Minimap, "BOTTOMRIGHT", 0, -16)
	belowMiniMapHolder:Size(128, 40)

	E:CreateMover(topCenterHolder, 'TopCenterContainerMover', L["UIWidgetTopContainer"], nil, nil, nil,'ALL,SOLO')
	E:CreateMover(belowMiniMapHolder, 'BelowMinimapContainerMover', L["UIWidgetBelowMinimapContainer"], nil, nil, nil,'ALL,SOLO')

	topCenterContainer:ClearAllPoints()
	topCenterContainer:Point('CENTER', topCenterHolder)

	belowMiniMapcontainer:ClearAllPoints()
	belowMiniMapcontainer:Point('CENTER', belowMiniMapHolder, 'CENTER')

	hooksecurefunc(topCenterContainer, 'SetPoint', topCenterPosition)
	hooksecurefunc(belowMiniMapcontainer, 'SetPoint', belowMinimapPosition)
end

function B:Handle_UIWidgets()
	UIWidgets()
end
