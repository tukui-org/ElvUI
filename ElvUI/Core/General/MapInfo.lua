local E, L, V, P, G = unpack(ElvUI)

local pairs = pairs
local IsFalling = IsFalling
local CreateFrame = CreateFrame
local UnitPosition = UnitPosition
local GetUnitSpeed = GetUnitSpeed
local CreateVector2D = CreateVector2D
local GetRealZoneText = GetRealZoneText
local GetMinimapZoneText = GetMinimapZoneText

local C_Map_GetMapInfo = C_Map.GetMapInfo
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Map_GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos

local UIMAPTYPE_CONTINENT = Enum.UIMapType.Continent
local MapUtil_GetMapParentInfo = MapUtil.GetMapParentInfo

local MapInfo = {}
E.MapInfo = MapInfo

function E:MapInfo_Update()
	local mapID = C_Map_GetBestMapForUnit('player')

	local mapInfo = mapID and C_Map_GetMapInfo(mapID)
	MapInfo.name = (mapInfo and mapInfo.name) or nil
	MapInfo.mapType = (mapInfo and mapInfo.mapType) or nil
	MapInfo.parentMapID = (mapInfo and mapInfo.parentMapID) or nil

	MapInfo.mapID = mapID or nil
	MapInfo.zoneText = (mapID and E:GetZoneText(mapID)) or nil
	MapInfo.subZoneText = GetMinimapZoneText() or nil
	MapInfo.realZoneText = GetRealZoneText() or nil

	local continent = mapID and MapUtil_GetMapParentInfo(mapID, UIMAPTYPE_CONTINENT, true)
	MapInfo.continentParentMapID = (continent and continent.parentMapID) or nil
	MapInfo.continentMapType = (continent and continent.mapType) or nil
	MapInfo.continentMapID = (continent and continent.mapID) or nil
	MapInfo.continentName = (continent and continent.name) or nil

	E:MapInfo_CoordsUpdate()
end

local coordsWatcher = CreateFrame('Frame')
function E:MapInfo_CoordsStart()
	MapInfo.coordsWatching = true
	MapInfo.coordsFalling = nil
	coordsWatcher:SetScript('OnUpdate', E.MapInfo_OnUpdate)

	if MapInfo.coordsStopTimer then
		E:CancelTimer(MapInfo.coordsStopTimer)
		MapInfo.coordsStopTimer = nil
	end
end

function E:MapInfo_CoordsStopWatching()
	MapInfo.coordsWatching = nil
	MapInfo.coordsStopTimer = nil
	coordsWatcher:SetScript('OnUpdate', nil)
end

function E:MapInfo_CoordsStop(event)
	if event == 'CRITERIA_UPDATE' then
		if not MapInfo.coordsFalling then return end -- stop if we weren't falling
		if (GetUnitSpeed('player') or 0) > 0 then return end -- we are still moving!
		MapInfo.coordsFalling = nil -- we were falling!
	elseif (event == 'PLAYER_STOPPED_MOVING' or event == 'PLAYER_CONTROL_GAINED') and IsFalling() then
		MapInfo.coordsFalling = true
		return
	end

	if not MapInfo.coordsStopTimer then
		MapInfo.coordsStopTimer = E:ScheduleTimer('MapInfo_CoordsStopWatching', 0.5)
	end
end

function E:MapInfo_CoordsUpdate()
	if MapInfo.mapID then
		MapInfo.x, MapInfo.y = E:GetPlayerMapPos(MapInfo.mapID)
	else
		MapInfo.x, MapInfo.y = nil, nil
	end

	if MapInfo.x and MapInfo.y then
		MapInfo.xText = E:Round(100 * MapInfo.x, 2)
		MapInfo.yText = E:Round(100 * MapInfo.y, 2)
	else
		MapInfo.xText, MapInfo.yText = nil, nil
	end
end

function E:MapInfo_OnUpdate(elapsed)
	self.lastUpdate = (self.lastUpdate or 0) + elapsed
	if self.lastUpdate > 0.1 then
		E:MapInfo_CoordsUpdate()
		self.lastUpdate = 0
	end
end

-- This code fixes C_Map.GetPlayerMapPosition memory leak.
-- Fix stolen from NDui (and modified by Simpy). Credit: siweia.
local mapRects, tempVec2D = {}, CreateVector2D(0, 0)
function E:GetPlayerMapPos(mapID)
	tempVec2D.x, tempVec2D.y = UnitPosition('player')
	if not tempVec2D.x then return end

	local mapRect = mapRects[mapID]
	if not mapRect then
		local _, pos1 = C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
		local _, pos2 = C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
		if not pos1 or not pos2 then return end

		mapRect = {pos1, pos2}
		mapRect[2]:Subtract(mapRect[1])
		mapRects[mapID] = mapRect
	end
	tempVec2D:Subtract(mapRect[1])

	return (tempVec2D.y/mapRect[2].y), (tempVec2D.x/mapRect[2].x)
end

-- Code taken from LibTourist-3.0 and rewritten to fit our purpose
local localizedMapNames = {}
local ZoneIDToContinentName = {
	[104] = 'Outland',
	[107] = 'Outland',
}
local MapIdLookupTable = {
	[101] = 'Outland',
	[104] = 'Shadowmoon Valley',
	[107] = 'Nagrand',
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

--Add ' (Outland)' to the end of zone name for Nagrand and Shadowmoon Valley, if mapID matches Outland continent.
--We can then use this function when we need to compare the players own zone against return values from stuff like GetFriendInfo and GetGuildRosterInfo,
--which adds the ' (Outland)' part unlike the GetRealZoneText() API.
function E:GetZoneText(mapID)
	if not (mapID and MapInfo.name) then return end

	local continent, zoneName = ZoneIDToContinentName[mapID]
	if continent and continent == 'Outland' then
		if MapInfo.name == localizedMapNames.Nagrand or MapInfo.name == 'Nagrand' then
			zoneName = localizedMapNames.Nagrand..' ('..localizedMapNames.Outland..')'
		elseif MapInfo.name == localizedMapNames['Shadowmoon Valley'] or MapInfo.name == 'Shadowmoon Valley' then
			zoneName = localizedMapNames['Shadowmoon Valley']..' ('..localizedMapNames.Outland..')'
		end
	end

	return zoneName or MapInfo.name
end

E:RegisterEvent('CRITERIA_UPDATE', 'MapInfo_CoordsStop') -- when the player goes into an animation (landing)
E:RegisterEvent('PLAYER_STARTED_MOVING', 'MapInfo_CoordsStart')
E:RegisterEvent('PLAYER_STOPPED_MOVING', 'MapInfo_CoordsStop')
E:RegisterEvent('PLAYER_CONTROL_LOST', 'MapInfo_CoordsStart')
E:RegisterEvent('PLAYER_CONTROL_GAINED', 'MapInfo_CoordsStop')
E:RegisterEventForObject('LOADING_SCREEN_DISABLED', E.MapInfo, E.MapInfo_Update)
E:RegisterEventForObject('ZONE_CHANGED_NEW_AREA', E.MapInfo, E.MapInfo_Update)
E:RegisterEventForObject('ZONE_CHANGED_INDOORS', E.MapInfo, E.MapInfo_Update)
E:RegisterEventForObject('ZONE_CHANGED', E.MapInfo, E.MapInfo_Update)
