local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Cache global variables
local select = select
--WoW API / Variables
local CreateFrame = CreateFrame
local UnitPosition = UnitPosition
local CreateVector2D = CreateVector2D
local C_Map_GetMapInfo = C_Map.GetMapInfo
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Map_GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos

E.MapInfo = {}
function E:Update_MapInfo()
	local mapID = C_Map_GetBestMapForUnit("player")
	local mapInfo = mapID and C_Map_GetMapInfo(mapID)

	E.MapInfo.name = (mapInfo and mapInfo.name) or nil
	E.MapInfo.mapType = (mapInfo and mapInfo.mapType) or nil
	E.MapInfo.parentMapID = (mapInfo and mapInfo.parentMapID) or nil

	E.MapInfo.mapID = mapID or nil
	E.MapInfo.zoneText = E:GetZoneText(mapID)

	E:Update_MapCoords()
end

local coordsWatcher = CreateFrame("Frame")
function E:MapInfo_CoordsStart()
	coordsWatcher:SetScript("OnUpdate", E.MapInfo_OnUpdate)
end

function E:MapInfo_CoordsStop()
	coordsWatcher:SetScript("OnUpdate", nil)
end

function E:Update_MapCoords()
	if E.MapInfo.mapID then
		E.MapInfo.x, E.MapInfo.y = E:GetPlayerMapPos(E.MapInfo.mapID)
	else
		E.MapInfo.x, E.MapInfo.y = nil, nil
	end

	if E.MapInfo.x and E.MapInfo.y then
		E.MapInfo.xText = E:Round(100 * E.MapInfo.x, 1)
		E.MapInfo.yText = E:Round(100 * E.MapInfo.y, 1)
	else
		E.MapInfo.xText, E.MapInfo.yText = nil, nil
	end
end

function E:MapInfo_OnUpdate(elapsed)
	self.lastUpdate = (self.lastUpdate or 0) + elapsed
	if self.lastUpdate > 0.1 then
		E:Update_MapCoords()
		self.lastUpdate = 0
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

-- Code taken from LibTourist-3.0 and rewritten to fit our purpose
local localizedMapNames = {}
local ZoneIDToContinentName = {
	[104] = "Outland",
	[107] = "Outland",
}
local MapIdLookupTable = {
	[101] = "Outland",
	[104] = "Shadowmoon Valley",
	[107] = "Nagrand",
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

E:RegisterEvent("PLAYER_STARTED_MOVING", "MapInfo_CoordsStart")
E:RegisterEvent("PLAYER_STOPPED_MOVING", "MapInfo_CoordsStop")
E:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update_MapInfo")
E:RegisterEvent("ZONE_CHANGED_INDOORS", "Update_MapInfo")
E:RegisterEvent("ZONE_CHANGED", "Update_MapInfo")
