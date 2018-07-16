local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:NewModule('WorldMap', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
E.WorldMap = M

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
local find = string.find
--WoW API / Variables
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Map_GetPlayerMapPosition = C_Map.GetPlayerMapPosition
local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local SetCVar = SetCVar
local SetUIPanelAttribute = SetUIPanelAttribute
local MOUSE_LABEL = MOUSE_LABEL:gsub("|T.-|t","")
local PLAYER = PLAYER

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIParent, WorldMapFrame, CoordsHolder, NumberFontNormal, WORLD_MAP_MIN_ALPHA

local INVERTED_POINTS = {
	["TOPLEFT"] = "BOTTOMLEFT",
	["TOPRIGHT"] = "BOTTOMRIGHT",
	["BOTTOMLEFT"] = "TOPLEFT",
	["BOTTOMRIGHT"] = "TOPRIGHT",
	["TOP"] = "BOTTOM",
	["BOTTOM"] = "TOP",
}

local tooltips = {
	WorldMapTooltip,
	WorldMapCompareTooltip1,
	WorldMapCompareTooltip2,
	WorldMapCompareTooltip3
}

-- this will be updated later
local smallerMapScale = 0.8

function M:SetLargeWorldMap()
	WorldMapFrame:SetParent(E.UIParent)
	WorldMapFrame:SetScale(1)
	WorldMapFrame.ScrollContainer.Child:SetScale(smallerMapScale)

	if WorldMapFrame:GetAttribute('UIPanelLayout-area') ~= 'center' then
		SetUIPanelAttribute(WorldMapFrame, "area", "center");
	end

	if WorldMapFrame:GetAttribute('UIPanelLayout-allowOtherPanels') ~= true then
		SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
	end

	WorldMapFrame:OnFrameSizeChanged()
	if WorldMapFrame:GetMapID() then
		WorldMapFrame.NavBar:Refresh()
	end

	for _, tt in pairs(tooltips) do
		if _G[tt] then _G[tt]:SetFrameStrata("TOOLTIP") end
	end
end

function M:UpdateMaximizedSize()
	local width, height = WorldMapFrame:GetSize()
	local magicNumber = (1 - smallerMapScale) * 100
	WorldMapFrame:Size((width * smallerMapScale) - (magicNumber + 2), (height * smallerMapScale) - 2)
end

function M:SynchronizeDisplayState()
	if WorldMapFrame:IsMaximized() then
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:Point("CENTER", E.UIParent)
	end
end

function M:SetSmallWorldMap()
	if not WorldMapFrame:IsMaximized() then
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:Point("TOPLEFT", UIParent, "TOPLEFT", 16, -94)
	end
end

local inRestrictedArea = false
function M:PLAYER_ENTERING_WORLD()
	local position = C_Map_GetBestMapForUnit("player")
	if not position then
		inRestrictedArea = true
		self:CancelTimer(self.CoordsTimer)
		self.CoordsTimer = nil
		CoordsHolder.playerCoords:SetText("")
		CoordsHolder.mouseCoords:SetText("")
	elseif not self.CoordsTimer then
		inRestrictedArea = false
		self.CoordsTimer = self:ScheduleRepeatingTimer('UpdateCoords', 0.05)
	end
end

function M:UpdateCoords()
	if (not WorldMapFrame:IsShown() or inRestrictedArea) then return end

	local x, y
	local mapID = C_Map_GetBestMapForUnit("player")
	local mapPos = mapID and C_Map_GetPlayerMapPosition(mapID, "player")
	if mapPos then x, y = mapPos:GetXY() end

	x = x and E:Round(100 * x, 2) or 0
	y = y and E:Round(100 * y, 2) or 0

	if x ~= 0 and y ~= 0 then
		CoordsHolder.playerCoords:SetText(PLAYER..":   "..x..", "..y)
	else
		CoordsHolder.playerCoords:SetText("")
	end

	local scale = WorldMapFrame.ScrollContainer:GetEffectiveScale()
	local width = WorldMapFrame.ScrollContainer:GetWidth()
	local height = WorldMapFrame.ScrollContainer:GetHeight()
	local centerX, centerY = WorldMapFrame.ScrollContainer:GetCenter()
	x, y = GetCursorPosition()

	local adjustedX = x and ((x / scale - (centerX - (width/2))) / width)
	local adjustedY = y and ((centerY + (height/2) - y / scale) / height)

	if adjustedX and adjustedY and (adjustedX >= 0 and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
		adjustedX = E:Round(100 * adjustedX, 2)
		adjustedY = E:Round(100 * adjustedY, 2)
		CoordsHolder.mouseCoords:SetText(MOUSE_LABEL..":   "..adjustedX..", "..adjustedY)
	else
		CoordsHolder.mouseCoords:SetText("")
	end
end

function M:PositionCoords()
	local db = E.global.general.WorldMapCoordinates
	local position = db.position
	local xOffset = db.xOffset
	local yOffset = db.yOffset

	local x, y = 5, 5
	if find(position, "RIGHT") then	x = -5 end
	if find(position, "TOP") then y = -5 end

	CoordsHolder.playerCoords:ClearAllPoints()
	CoordsHolder.playerCoords:Point(position, WorldMapFrame.BorderFrame, position, x + xOffset, y + yOffset)
	CoordsHolder.mouseCoords:ClearAllPoints()
	CoordsHolder.mouseCoords:Point(position, CoordsHolder.playerCoords, INVERTED_POINTS[position], 0, y)
end

function M:Initialize()
	if E.global.general.WorldMapCoordinates.enable then
		local CoordsHolder = CreateFrame('Frame', 'CoordsHolder', WorldMapFrame)
		CoordsHolder:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 1)
		CoordsHolder:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
		CoordsHolder.playerCoords = CoordsHolder:CreateFontString(nil, 'OVERLAY')
		CoordsHolder.mouseCoords = CoordsHolder:CreateFontString(nil, 'OVERLAY')
		CoordsHolder.playerCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.mouseCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.playerCoords:SetFontObject(NumberFontNormal)
		CoordsHolder.mouseCoords:SetFontObject(NumberFontNormal)
		CoordsHolder.playerCoords:SetText(PLAYER..":   0, 0")
		CoordsHolder.mouseCoords:SetText(MOUSE_LABEL..":   0, 0")

		self.CoordsTimer = self:ScheduleRepeatingTimer('UpdateCoords', 0.05)
		M:PositionCoords()

		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	end

	if E.global.general.smallerWorldMap then
		smallerMapScale = E.global.general.smallerWorldMapScale

		WorldMapFrame.BlackoutFrame.Blackout:SetTexture(nil)
		WorldMapFrame.BlackoutFrame:EnableMouse(false)

		self:SecureHook(WorldMapFrame, 'Maximize', 'SetLargeWorldMap')
		self:SecureHook(WorldMapFrame, 'Minimize', 'SetSmallWorldMap')
		self:SecureHook(WorldMapFrame, 'SynchronizeDisplayState')
		self:SecureHook(WorldMapFrame, 'UpdateMaximizedSize')

		self:SecureHookScript(WorldMapFrame, 'OnShow', function()
			if WorldMapFrame:IsMaximized() then
				self:SetLargeWorldMap()
			else
				self:SetSmallWorldMap()
			end

			M:Unhook(WorldMapFrame, 'OnShow', nil)
		end)
	end

	--Set alpha used when moving
	WORLD_MAP_MIN_ALPHA = E.global.general.mapAlphaWhenMoving
	SetCVar("mapAnimMinAlpha", E.global.general.mapAlphaWhenMoving)

	--Enable/Disable map fading when moving
	SetCVar("mapFade", (E.global.general.fadeMapWhenMoving == true and 1 or 0))

	if WorldMapFrame.UIElementsFrame and WorldMapFrame.UIElementsFrame.ActionButton.SpellButton.Cooldown then
		WorldMapFrame.UIElementsFrame.ActionButton.SpellButton.Cooldown.CooldownFontSize = 20
		E:RegisterCooldown(WorldMapFrame.UIElementsFrame.ActionButton.SpellButton.Cooldown)
	end
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterInitialModule(M:GetName(), InitializeCallback)