local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
local select = select
--WoW API / Variables
local UnitPosition = UnitPosition
local CreateVector2D = CreateVector2D
local C_Map_GetMapInfo = C_Map.GetMapInfo
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Map_GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos

E.MapInfo = {}
function E:Update_Coordinates()
	local mapID = C_Map_GetBestMapForUnit("player")
	local mapInfo = mapID and C_Map_GetMapInfo(mapID)

	E.MapInfo.mapID = mapID
	E.MapInfo.zoneText = E:GetZoneText(mapID)

	if mapInfo then
		E.MapInfo.name = mapInfo.name
		E.MapInfo.mapType = mapInfo.mapType
		E.MapInfo.parentMapID = mapInfo.parentMapID
	end

	if mapID then
		E.MapInfo.x, E.MapInfo.y = E:GetPlayerMapPos(mapID)
	end
end

-- This code fixes C_Map.GetPlayerMapPosition memory leak.
-- Fix stolen from NDui (and modified by Simpy). Credit: siweia.
local mapRects, tempVec2D = {}, CreateVector2D(0, 0)
function E:GetPlayerMapPos(mapID)
	tempVec2D.x, tempVec2D.y = UnitPosition("player")
	if not tempVec2D.x then return end

	local mapRect = mapRects[mapID]
	if not mapRect then
		mapRect = {
			select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))),
			select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))}
		mapRect[2]:Subtract(mapRect[1])
		mapRects[mapID] = mapRect
	end
	tempVec2D:Subtract(mapRect[1])

	return (tempVec2D.y/mapRect[2].y), (tempVec2D.x/mapRect[2].x)
end


E:RegisterEvent("PLAYER_ENTERING_WORLD", "Update_Coordinates")
E:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update_Coordinates")
E:RegisterEvent("ZONE_CHANGED_INDOORS", "Update_Coordinates")
E:RegisterEvent("ZONE_CHANGED", "Update_Coordinates")
