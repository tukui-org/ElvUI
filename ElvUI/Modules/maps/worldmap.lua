local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:NewModule('WorldMap', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
E.WorldMap = M

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
local find = string.find
--WoW API / Variables
local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local SetCVar = SetCVar
local SetUIPanelAttribute = SetUIPanelAttribute
local MOUSE_LABEL = MOUSE_LABEL:gsub("|T.-|t","")
local PLAYER = PLAYER

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: WorldMapFrame, CoordsHolder, NumberFontNormal, WORLD_MAP_MIN_ALPHA

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
		WorldMapFrame:Point("TOPLEFT", E.UIParent, "TOPLEFT", 16, -94)
	end
end

local inRestrictedArea = false
function M:UpdateRestrictedArea()
	E:MapInfo_Update()

	if E.MapInfo.x and E.MapInfo.y then
		inRestrictedArea = false
	else
		inRestrictedArea = true
		CoordsHolder.playerCoords:SetFormattedText("%s:   %s", PLAYER, "N/A")
	end
end

function M:UpdateCoords(OnShow)
	if not WorldMapFrame:IsShown() then return end

	if WorldMapFrame.ScrollContainer:IsMouseOver() then
		local scale = WorldMapFrame.ScrollContainer:GetEffectiveScale()
		local width = WorldMapFrame.ScrollContainer:GetWidth()
		local height = WorldMapFrame.ScrollContainer:GetHeight()
		local centerX, centerY = WorldMapFrame.ScrollContainer:GetCenter()
		local x, y = GetCursorPosition()

		local adjustedX = x and ((x / scale - (centerX - (width/2))) / width)
		local adjustedY = y and ((centerY + (height/2) - y / scale) / height)

		if adjustedX and adjustedY and (adjustedX >= 0 and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
			adjustedX = E:Round(100 * adjustedX, 2)
			adjustedY = E:Round(100 * adjustedY, 2)
			CoordsHolder.mouseCoords:SetFormattedText("%s:   %.2f, %.2f", MOUSE_LABEL, adjustedX, adjustedY)
		else
			CoordsHolder.mouseCoords:SetText("")
		end
	else
		CoordsHolder.mouseCoords:SetText("")
	end

	if not inRestrictedArea and (OnShow or E.MapInfo.coordsWatching) then
		if E.MapInfo.x and E.MapInfo.y then
			CoordsHolder.playerCoords:SetFormattedText("%s:   %.2f, %.2f", PLAYER, (E.MapInfo.xText or 0), (E.MapInfo.yText or 0))
		else
			CoordsHolder.playerCoords:SetFormattedText("%s:   %s", PLAYER, "N/A")
		end
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
		CoordsHolder:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 2)
		CoordsHolder:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
		CoordsHolder.playerCoords = CoordsHolder:CreateFontString(nil, 'OVERLAY')
		CoordsHolder.mouseCoords = CoordsHolder:CreateFontString(nil, 'OVERLAY')
		CoordsHolder.playerCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.mouseCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.playerCoords:SetFontObject(NumberFontNormal)
		CoordsHolder.mouseCoords:SetFontObject(NumberFontNormal)
		CoordsHolder.playerCoords:SetText(PLAYER..":   0, 0")
		CoordsHolder.mouseCoords:SetText(MOUSE_LABEL..":   0, 0")

		WorldMapFrame:HookScript("OnShow", function()
			if not M.CoordsTimer then
				M:UpdateCoords(true)
				M.CoordsTimer = M:ScheduleRepeatingTimer('UpdateCoords', 0.1)
			end
		end)
		WorldMapFrame:HookScript("OnHide", function()
			M:CancelTimer(M.CoordsTimer)
			M.CoordsTimer = nil
		end)

		M:PositionCoords()

		self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateRestrictedArea")
		self:RegisterEvent("ZONE_CHANGED_INDOORS", "UpdateRestrictedArea")
		self:RegisterEvent("ZONE_CHANGED", "UpdateRestrictedArea")
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
