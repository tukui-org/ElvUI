local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

--Cache global variables
--Lua functions
local join = string.join
--WoW API / Variables
local ToggleFrame = ToggleFrame
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: WorldMapFrame

local displayString = ""
local inRestrictedArea = false

-- This code fixes C_Map.GetPlayerMapPosition memory leak.
-- Fix stolen from NDui. Credit: siweia.
local mapRects = {}
local tempVec2D = CreateVector2D(0, 0)

function E:GetPlayerMapPos(mapID)
	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then return end

	local mapRect = mapRects[mapID]
	if not mapRect then
		mapRect = {}
		mapRect[1] = select(2, C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0)))
		mapRect[2] = select(2, C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))
		mapRect[2]:Subtract(mapRect[1])

		mapRects[mapID] = mapRect
	end
	tempVec2D:Subtract(mapRect[1])

	return (tempVec2D.y/mapRect[2].y), (tempVec2D.x/mapRect[2].x)
end

local function Update(self, elapsed)
	if inRestrictedArea then return; end

	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed

	if self.timeSinceUpdate > 0.1 then
		local mapID = C_Map_GetBestMapForUnit("player")
		local x, y = E:GetPlayerMapPos(mapID)

		x = x and E:Round(100 * x, 1) or 0
		y = y and E:Round(100 * y, 1) or 0

		self.text:SetFormattedText(displayString, x, y)
		self.timeSinceUpdate = 0
	end
end

local function OnEvent(self)
	local mapID = C_Map_GetBestMapForUnit("player")
	local x, y = E:GetPlayerMapPos(mapID)
	if x and y then
		inRestrictedArea = false
		self:Show()
	else
		inRestrictedArea = true
		self.text:SetText("N/A")
		self:Hide()
	end
end

local function Click()
	ToggleFrame(WorldMapFrame)
end

local function ValueColorUpdate(hex)
	displayString = join("", hex, "%.1f|r", " , ", hex, "%.1f|r")
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

DT:RegisterDatatext('Coords', {"PLAYER_ENTERING_WORLD"}, OnEvent, Update, Click, nil, nil, L["Coords"])
