local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:NewModule('WorldMap', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
E.WorldMap = M

--Cache global variables
--Lua functions
local find = string.find
--WoW API / Variables
local CreateFrame = CreateFrame
local GetCursorPosition = GetCursorPosition
local GetPlayerMapPosition = GetPlayerMapPosition
local InCombatLockdown = InCombatLockdown
local SetCVar = SetCVar
local SetUIPanelAttribute = SetUIPanelAttribute
local PLAYER = PLAYER
local MOUSE_LABEL = MOUSE_LABEL
local WORLDMAP_FULLMAP_SIZE = WORLDMAP_FULLMAP_SIZE
local WORLDMAP_WINDOWED_SIZE = WORLDMAP_WINDOWED_SIZE

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: WorldMapFrame, WorldMapFrameSizeUpButton, WorldMapFrameSizeDownButton
-- GLOBALS: UIParent, CoordsHolder, WorldMapDetailFrame, DropDownList1, WORLD_MAP_MIN_ALPHA
-- GLOBALS: NumberFontNormal, WORLDMAP_SETTINGS, BlackoutWorld, WorldMapScrollFrame

local INVERTED_POINTS = {
	["TOPLEFT"] = "BOTTOMLEFT",
	["TOPRIGHT"] = "BOTTOMRIGHT",
	["BOTTOMLEFT"] = "TOPLEFT",
	["BOTTOMRIGHT"] = "TOPRIGHT",
	["TOP"] = "BOTTOM",
	["BOTTOM"] = "TOP",
}

function M:SetLargeWorldMap()
	if InCombatLockdown() then return end

	WorldMapFrame:SetParent(E.UIParent)
	WorldMapFrame:EnableKeyboard(false)
	WorldMapFrame:SetScale(1)
	WorldMapFrame:EnableMouse(true)
	WorldMapTooltip:SetFrameStrata("TOOLTIP")
	WorldMapCompareTooltip1:SetFrameStrata("TOOLTIP")
	WorldMapCompareTooltip2:SetFrameStrata("TOOLTIP")

	if WorldMapFrame:GetAttribute('UIPanelLayout-area') ~= 'center' then
		SetUIPanelAttribute(WorldMapFrame, "area", "center");
	end

	if WorldMapFrame:GetAttribute('UIPanelLayout-allowOtherPanels') ~= true then
		SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
	end

	WorldMapFrameSizeUpButton:Hide()
	WorldMapFrameSizeDownButton:Show()

	WorldMapFrame:ClearAllPoints()
	WorldMapFrame:Point("CENTER", UIParent, "CENTER", 0, 100)
	WorldMapFrame:SetSize(1002, 668)
end

function M:SetSmallWorldMap()
	if InCombatLockdown() then return; end

	WorldMapFrameSizeUpButton:Show()
	WorldMapFrameSizeDownButton:Hide()
end

function M:PLAYER_REGEN_ENABLED()
	WorldMapFrameSizeDownButton:Enable()
	WorldMapFrameSizeUpButton:Enable()
end

function M:PLAYER_REGEN_DISABLED()
	WorldMapFrameSizeDownButton:Disable()
	WorldMapFrameSizeUpButton:Disable()
end

local inRestrictedArea = false
function M:PLAYER_ENTERING_WORLD()
	local x = GetPlayerMapPosition("player")
	if not x then
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
	local x, y = GetPlayerMapPosition("player")
	x = E:Round(100 * x, 2)
	y = E:Round(100 * y, 2)

	if x ~= 0 and y ~= 0 then
		CoordsHolder.playerCoords:SetText(PLAYER..":   "..x..", "..y)
	else
		CoordsHolder.playerCoords:SetText("")
	end

	local scale = WorldMapDetailFrame:GetEffectiveScale()
	local width = WorldMapDetailFrame:GetWidth()
	local height = WorldMapDetailFrame:GetHeight()
	local centerX, centerY = WorldMapDetailFrame:GetCenter()
	local x, y = GetCursorPosition()
	local adjustedX = (x / scale - (centerX - (width/2))) / width
	local adjustedY = (centerY + (height/2) - y / scale) / height

	if (adjustedX >= 0  and adjustedY >= 0 and adjustedX <= 1 and adjustedY <= 1) then
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
	CoordsHolder.playerCoords:Point(position, WorldMapScrollFrame, position, x + xOffset, y + yOffset)
	CoordsHolder.mouseCoords:ClearAllPoints()
	CoordsHolder.mouseCoords:Point(position, CoordsHolder.playerCoords, INVERTED_POINTS[position], 0, y)
end

function M:Initialize()
	if(E.global.general.WorldMapCoordinates.enable) then
		local CoordsHolder = CreateFrame('Frame', 'CoordsHolder', WorldMapFrame)
		CoordsHolder:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() + 1)
		CoordsHolder:SetFrameStrata(WorldMapDetailFrame:GetFrameStrata())
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

	if(E.global.general.smallerWorldMap) then
		BlackoutWorld:SetTexture(nil)
		self:SecureHook("WorldMap_ToggleSizeDown", 'SetSmallWorldMap')
		self:SecureHook("WorldMap_ToggleSizeUp", "SetLargeWorldMap")
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		self:RegisterEvent('PLAYER_REGEN_DISABLED')

		if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
			self:SetLargeWorldMap()
		elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
			self:SetSmallWorldMap()
		end
	end

	--Set alpha used when moving
	WORLD_MAP_MIN_ALPHA = E.global.general.mapAlphaWhenMoving
	SetCVar("mapAnimMinAlpha", E.global.general.mapAlphaWhenMoving)
	--Enable/Disable map fading when moving
	SetCVar("mapFade", (E.global.general.fadeMapWhenMoving == true and 1 or 0))
end

E:RegisterInitialModule(M:GetName())