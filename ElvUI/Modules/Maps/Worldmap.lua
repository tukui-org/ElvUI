local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('WorldMap')

--Lua functions
local _G = _G
local strfind = strfind
--WoW API / Variables
local CreateFrame = CreateFrame
local SetCVar = SetCVar
local SetUIPanelAttribute = SetUIPanelAttribute
local MOUSE_LABEL = MOUSE_LABEL:gsub("|T.-|t","")
local PLAYER = PLAYER
-- GLOBALS: WORLD_MAP_MIN_ALPHA, CoordsHolder

local INVERTED_POINTS = {
	["TOPLEFT"] = "BOTTOMLEFT",
	["TOPRIGHT"] = "BOTTOMRIGHT",
	["BOTTOMLEFT"] = "TOPLEFT",
	["BOTTOMRIGHT"] = "TOPRIGHT",
	["TOP"] = "BOTTOM",
	["BOTTOM"] = "TOP",
}

-- this will be updated later
local smallerMapScale = 0.8

function M:SetLargeWorldMap()
	local WorldMapFrame = _G.WorldMapFrame
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
end

function M:UpdateMaximizedSize()
	local WorldMapFrame = _G.WorldMapFrame
	local width, height = WorldMapFrame:GetSize()
	local magicNumber = (1 - smallerMapScale) * 100
	WorldMapFrame:Size((width * smallerMapScale) - (magicNumber + 2), (height * smallerMapScale) - 2)
end

function M:SynchronizeDisplayState()
	local WorldMapFrame = _G.WorldMapFrame
	if WorldMapFrame:IsMaximized() then
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:Point("CENTER", E.UIParent)
	end
end

function M:SetSmallWorldMap()
	local WorldMapFrame = _G.WorldMapFrame
	if not WorldMapFrame:IsMaximized() then
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:Point("TOPLEFT", E.UIParent, "TOPLEFT", 16, -94)
	end
end

local inRestrictedArea = false
function M:UpdateRestrictedArea()
	if E.MapInfo.x and E.MapInfo.y then
		inRestrictedArea = false
	else
		inRestrictedArea = true
		CoordsHolder.playerCoords:SetFormattedText("%s:   %s", PLAYER, "N/A")
	end
end

function M:UpdateCoords(OnShow)
	local WorldMapFrame = _G.WorldMapFrame
	if not WorldMapFrame:IsShown() then return end

	if WorldMapFrame.ScrollContainer:IsMouseOver() then
		local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
		if x and y and x >= 0 and y >= 0 then
			CoordsHolder.mouseCoords:SetFormattedText("%s:   %.2f, %.2f", MOUSE_LABEL, x * 100, y * 100)
		else
			CoordsHolder.mouseCoords:SetText('')
		end
	else
		CoordsHolder.mouseCoords:SetText('')
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
	if strfind(position, "RIGHT") then	x = -5 end
	if strfind(position, "TOP") then y = -5 end

	CoordsHolder.playerCoords:ClearAllPoints()
	CoordsHolder.playerCoords:Point(position, _G.WorldMapFrame.BorderFrame, position, x + xOffset, y + yOffset)
	CoordsHolder.mouseCoords:ClearAllPoints()
	CoordsHolder.mouseCoords:Point(position, CoordsHolder.playerCoords, INVERTED_POINTS[position], 0, y)
end

function M:Initialize()
	self.Initialized = true

	local WorldMapFrame = _G.WorldMapFrame
	if E.global.general.WorldMapCoordinates.enable then
		local CoordsHolder = CreateFrame('Frame', 'CoordsHolder', WorldMapFrame)
		CoordsHolder:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 2)
		CoordsHolder:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())
		CoordsHolder.playerCoords = CoordsHolder:CreateFontString(nil, 'OVERLAY')
		CoordsHolder.mouseCoords = CoordsHolder:CreateFontString(nil, 'OVERLAY')
		CoordsHolder.playerCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.mouseCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.playerCoords:SetFontObject(_G.NumberFontNormal)
		CoordsHolder.mouseCoords:SetFontObject(_G.NumberFontNormal)
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

		E:RegisterEventForObject("LOADING_SCREEN_DISABLED", E.MapInfo, M.UpdateRestrictedArea)
		E:RegisterEventForObject("ZONE_CHANGED_NEW_AREA", E.MapInfo, M.UpdateRestrictedArea)
		E:RegisterEventForObject("ZONE_CHANGED_INDOORS", E.MapInfo, M.UpdateRestrictedArea)
		E:RegisterEventForObject("ZONE_CHANGED", E.MapInfo, M.UpdateRestrictedArea)
	end

	if E.global.general.smallerWorldMap then
		smallerMapScale = E.global.general.smallerWorldMapScale

		WorldMapFrame.BlackoutFrame.Blackout:SetTexture()
		WorldMapFrame.BlackoutFrame:EnableMouse(false)

		self:SecureHook(WorldMapFrame, 'Maximize', 'SetLargeWorldMap')
		self:SecureHook(WorldMapFrame, 'Minimize', 'SetSmallWorldMap')
		self:SecureHook(WorldMapFrame, 'SynchronizeDisplayState')
		self:SecureHook(WorldMapFrame, 'UpdateMaximizedSize')

		self:SecureHookScript(WorldMapFrame, 'OnShow', function()
			if WorldMapFrame:IsMaximized() then
				WorldMapFrame:UpdateMaximizedSize()
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
end

E:RegisterInitialModule(M:GetName())
