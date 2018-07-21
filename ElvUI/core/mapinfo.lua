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

	if mapInfo then
		E.MapInfo.name = mapInfo.name
		E.MapInfo.mapType = mapInfo.mapType
		E.MapInfo.parentMapID = mapInfo.parentMapID
	end

	if mapID then
		E.MapInfo.x, E.MapInfo.y = E:GetPlayerMapPos(mapID)
	end

	E.MapInfo.mapID = mapID
	E.MapInfo.zoneText = E:GetZoneText(mapID)
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

-- Code taken from LibTourist-3.0 and rewritten to fit our purpose
local localizedMapNames = {}
local ZoneIDToContinentName = {
	[473] = "Outland",
	[477] = "Outland",
}
local MapIdLookupTable = {
	[466] = "Outland",
	[473] = "Shadowmoon Valley",
	[477] = "Nagrand",
}
local function LocalizeZoneNames()
	local mapInfo
	for mapID, englishName in pairs(MapIdLookupTable) do
		mapInfo = C_Map_GetMapInfo(mapID)
		-- Add combination of English and localized name to lookup table
		if mapInfo and mapInfo.name and not localizedMapNames[englishName] then
			localizedMapNames[englishName] = mapInfo.name
		end
	end
end
LocalizeZoneNames()

--Add " (Outland)" to the end of zone name for Nagrand and Shadowmoon Valley, if mapID matches Outland continent.
--We can then use this function when we need to compare the players own zone against return values from stuff like GetFriendInfo and GetGuildRosterInfo,
--which adds the " (Outland)" part unlike the GetRealZoneText() API.
function E:GetZoneText(mapID)
	if not (mapID and E.MapInfo.name) then return end

	local continent, zoneName = ZoneIDToContinentName[mapID]
	if continent and continent == "Outland" then
		if E.MapInfo.name == localizedMapNames["Nagrand"] or E.MapInfo.name == "Nagrand"  then
			zoneName = localizedMapNames["Nagrand"].." ("..localizedMapNames["Outland"]..")"
		elseif E.MapInfo.name == localizedMapNames["Shadowmoon Valley"] or E.MapInfo.name == "Shadowmoon Valley"  then
			zoneName = localizedMapNames["Shadowmoon Valley"].." ("..localizedMapNames["Outland"]..")"
		end
	end

	return zoneName
end

E:RegisterEvent("PLAYER_ENTERING_WORLD", "Update_Coordinates")
E:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update_Coordinates")
E:RegisterEvent("ZONE_CHANGED_INDOORS", "Update_Coordinates")
E:RegisterEvent("ZONE_CHANGED", "Update_Coordinates")
