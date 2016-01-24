local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:NewModule('WorldMap', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
E.WorldMap = M

--Cache global variables
--WoW API / Variables
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local SetUIPanelAttribute = SetUIPanelAttribute
local IsInInstance = IsInInstance
local GetPlayerMapPosition = GetPlayerMapPosition
local GetCursorPosition = GetCursorPosition
local PLAYER = PLAYER
local MOUSE_LABEL = MOUSE_LABEL
local WORLDMAP_FULLMAP_SIZE = WORLDMAP_FULLMAP_SIZE
local WORLDMAP_WINDOWED_SIZE = WORLDMAP_WINDOWED_SIZE

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: WorldMapFrame, WorldMapFrameSizeUpButton, WorldMapFrameSizeDownButton
-- GLOBALS: UIParent, CoordsHolder, WorldMapDetailFrame, DropDownList1
-- GLOBALS: NumberFontNormal, WORLDMAP_SETTINGS, BlackoutWorld

function M:SetLargeWorldMap()
	if InCombatLockdown() then return end

	WorldMapFrame:SetParent(E.UIParent)
	WorldMapFrame:EnableKeyboard(false)
	WorldMapFrame:SetScale(1)
	WorldMapFrame:EnableMouse(true)

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

function M:UpdateCoords()
	if(not WorldMapFrame:IsShown()) then return end
	local inInstance, _ = IsInInstance()
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

function M:ResetDropDownListPosition(frame)
	DropDownList1:ClearAllPoints()
	DropDownList1:Point("TOPRIGHT", frame, "BOTTOMRIGHT", -17, -4)
end





function M:Initialize()
	--setfenv(WorldMapFrame_OnShow, setmetatable({ UpdateMicroButtons = function() end }, { __index = _G })) --blizzard taint fix

	if(E.global.general.WorldMapCoordinates) then
		local CoordsHolder = CreateFrame('Frame', 'CoordsHolder', WorldMapFrame)
		CoordsHolder:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() + 1)
		CoordsHolder:SetFrameStrata(WorldMapDetailFrame:GetFrameStrata())
		CoordsHolder.playerCoords = CoordsHolder:CreateFontString(nil, 'OVERLAY')
		CoordsHolder.mouseCoords = CoordsHolder:CreateFontString(nil, 'OVERLAY')
		CoordsHolder.playerCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.mouseCoords:SetTextColor(1, 1 ,0)
		CoordsHolder.playerCoords:SetFontObject(NumberFontNormal)
		CoordsHolder.mouseCoords:SetFontObject(NumberFontNormal)
		CoordsHolder.playerCoords:Point("BOTTOMLEFT", WorldMapFrame.BorderFrame.Inset, "BOTTOMLEFT", 5, 5)
		CoordsHolder.playerCoords:SetText(PLAYER..":   0, 0")
		CoordsHolder.mouseCoords:Point("BOTTOMLEFT", CoordsHolder.playerCoords, "TOPLEFT", 0, 5)
		CoordsHolder.mouseCoords:SetText(MOUSE_LABEL..":   0, 0")

		self:ScheduleRepeatingTimer('UpdateCoords', 0.05)
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
end

E:RegisterInitialModule(M:GetName())