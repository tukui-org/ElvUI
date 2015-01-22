--[[
Name: Astrolabe
Revision: $Rev: 161 $
$Date: 2014-10-14 22:59:04 -0700 (Tue, 14 Oct 2014) $
Author(s): Esamynn (esamynn at wowinterface.com)
Inspired By: Gatherer by Norganna
             MapLibrary by Kristofer Karlsson (krka at kth.se)
Documentation: http://wiki.esamynn.org/Astrolabe
SVN: http://svn.esamynn.org/astrolabe/
Description:
	This is a library for the World of Warcraft UI system to place
	icons accurately on both the Minimap and on Worldmaps.  
	This library also manages and updates the position of Minimap icons 
	automatically.  

Copyright (C) 2006-2012 James Carrothers

License:
	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

Note:
	This library's source code is specifically designed to work with
	World of Warcraft's interpreted AddOn system.  You have an implicit
	licence to use this library with these facilities since that is its
	designated purpose as per:
	http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

-- WARNING!!!
-- DO NOT MAKE CHANGES TO THIS LIBRARY WITHOUT FIRST CHANGING THE LIBRARY_VERSION_MAJOR
-- STRING (to something unique) OR ELSE YOU MAY BREAK OTHER ADDONS THAT USE THIS LIBRARY!!!
local LIBRARY_VERSION_MAJOR = "Astrolabe-1.0"
local LIBRARY_VERSION_MINOR = tonumber(string.match("$Revision: 161 $", "(%d+)") or 1)

if not DongleStub then error(LIBRARY_VERSION_MAJOR .. " requires DongleStub.") end
if not DongleStub:IsNewerVersion(LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR) then return end

local Astrolabe = {};

-- define local variables for Data Tables (defined at the end of this file)
local WorldMapSize, MicroDungeonSize, MinimapSize, ValidMinimapShapes, zeroData;

function Astrolabe:GetVersion()
	return LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR;
end


--------------------------------------------------------------------------------------------------------------
-- Config Constants
--------------------------------------------------------------------------------------------------------------

local configConstants = { 
	MinimapUpdateMultiplier = true, 
}

-- this constant is multiplied by the current framerate to determine
-- how many icons are updated each frame
Astrolabe.MinimapUpdateMultiplier = 1;


--------------------------------------------------------------------------------------------------------------
-- Working Tables
--------------------------------------------------------------------------------------------------------------

Astrolabe.LastPlayerPosition = { 0, 0, 0, 0 };
Astrolabe.MinimapIcons = {};
Astrolabe.IconAssociations = {};
Astrolabe.IconsOnEdge = {};
Astrolabe.IconsOnEdge_GroupChangeCallbacks = {};
Astrolabe.TargetMinimapChanged_Callbacks = {};

Astrolabe.MinimapIconCount = 0
Astrolabe.ForceNextUpdate = false;
Astrolabe.IconsOnEdgeChanged = false;
Astrolabe.DefaultEdgeRangeMultiplier = 1;
Astrolabe.EdgeRangeMultiplier = {};
setmetatable(Astrolabe.EdgeRangeMultiplier,
	{
		__index = function(t,k)
			local d = Astrolabe.DefaultEdgeRangeMultiplier; -- this works because we always update the Astrolabe local variable
			if ( type(k) == "table" ) then t[k] = d; end;
			return d;
		end
	}
);

-- This variable indicates whether we know of a visible World Map or not.  
-- The state of this variable is controlled by the AstrolabeMapMonitor library.  
Astrolabe.WorldMapVisible = false;

local AddedOrUpdatedIcons = {}
local MinimapIconsMetatable = { __index = AddedOrUpdatedIcons }


--------------------------------------------------------------------------------------------------------------
-- Local Pointers for often used API functions
--------------------------------------------------------------------------------------------------------------

local twoPi = math.pi * 2;
local atan2 = math.atan2;
local sin = math.sin;
local cos = math.cos;
local abs = math.abs;
local sqrt = math.sqrt;
local min = math.min
local max = math.max
local yield = coroutine.yield
local next = next
local GetFramerate = GetFramerate
local band = bit.band
local issecurevariable = issecurevariable

local real_GetCurrentMapAreaID = GetCurrentMapAreaID
local function GetCurrentMapAreaID()
	local id = real_GetCurrentMapAreaID();
	if ( id < 0 and GetCurrentMapContinent() == WORLDMAP_WORLD_ID ) then
		return 0;
	end
	return id;
end


--------------------------------------------------------------------------------------------------------------
-- Internal Utility Functions
--------------------------------------------------------------------------------------------------------------

local function assert(level,condition,message)
	if not condition then
		error(message,level)
	end
end

local function argcheck(value, num, ...)
	assert(1, type(num) == "number", "Bad argument #2 to 'argcheck' (number expected, got " .. type(level) .. ")")
	
	for i=1,select("#", ...) do
		if type(value) == select(i, ...) then return end
	end
	
	local types = strjoin(", ", ...)
	local name = string.match(debugstack(2,2,0), ": in function [`<](.-)['>]")
	error(string.format("Bad argument #%d to 'Astrolabe.%s' (%s expected, got %s)", num, name, types, type(value)), 3)
end

local function getSystemPosition( mapData, f, x, y )
	if ( f ~= 0 ) then
		mapData = rawget(mapData, f) or MicroDungeonSize[mapData.originSystem][f];
	end
	x = x * mapData.width + mapData.xOffset;
	y = y * mapData.height + mapData.yOffset;
	return x, y;
end

local function printError( ... )
	if ( ASTROLABE_VERBOSE) then
		print(...)
	end
end


--------------------------------------------------------------------------------------------------------------
-- General Utility Functions
--------------------------------------------------------------------------------------------------------------

function Astrolabe:ComputeDistance( m1, f1, x1, y1, m2, f2, x2, y2 )
	--[[
	argcheck(m1, 2, "number");
	assert(3, m1 >= 0, "ComputeDistance: Illegal map id to m1: "..m1);
	argcheck(f1, 3, "number", "nil");
	argcheck(x1, 4, "number");
	argcheck(y1, 5, "number");
	argcheck(m2, 6, "number");
	assert(3, m2 >= 0, "ComputeDistance: Illegal map id to m2: "..m2);
	argcheck(f2, 7, "number", "nil");
	argcheck(x2, 8, "number");
	argcheck(y2, 9, "number");
	--]]
	
	if not ( m1 and m2 ) then return end;
	f1 = f1 or min(#WorldMapSize[m1], 1);
	f2 = f2 or min(#WorldMapSize[m2], 1);
	
	local dist, xDelta, yDelta;
	if ( m1 == m2 and f1 == f2 ) then
		-- points in the same zone on the same floor
		local mapData = WorldMapSize[m1];
		if ( f1 ~= 0 ) then
			mapData = rawget(mapData, f1) or MicroDungeonSize[mapData.originSystem][f1];
		end
		xDelta = (x2 - x1) * mapData.width;
		yDelta = (y2 - y1) * mapData.height;
	
	else
		local map1 = WorldMapSize[m1];
		local map2 = WorldMapSize[m2];
		if ( map1.system == map2.system ) then
			-- points within the same system (continent)
			x1, y1 = getSystemPosition(map1, f1, x1, y1);
			x2, y2 = getSystemPosition(map2, f2, x2, y2);
			xDelta = (x2 - x1);
			yDelta = (y2 - y1);
		
		else
			local s1 = map1.system;
			local s2 = map2.system;
			if ( (m1==0 or WorldMapSize[0][s1]) and (m2==0 or WorldMapSize[0][s2]) ) then
				x1, y1 = getSystemPosition(map1, f1, x1, y1);
				x2, y2 = getSystemPosition(map2, f2, x2, y2);
				if ( m1 ~= 0 ) then
					-- translate up from system 1
					local cont1 = WorldMapSize[0][s1];
					x1 = (x1 - cont1.xOffset) * cont1.scale;
					y1 = (y1 - cont1.yOffset) * cont1.scale;
				end
				if ( m2 ~= 0 ) then
					-- translate up from system 2
					local cont2 = WorldMapSize[0][s2];
					x2 = (x2 - cont2.xOffset) * cont2.scale;
					y2 = (y2 - cont2.yOffset) * cont2.scale; 
				end
				
				xDelta = x2 - x1;
				yDelta = y2 - y1;
			end
		
		end
	
	end
	if ( xDelta and yDelta ) then
		dist = sqrt(xDelta*xDelta + yDelta*yDelta);
	end
	return dist, xDelta, yDelta;
end

function Astrolabe:TranslateWorldMapPosition( M, F, xPos, yPos, nM, nF )
	--[[
	argcheck(M, 2, "number");
	argcheck(F, 3, "number", "nil");
	argcheck(xPos, 4, "number");
	argcheck(yPos, 5, "number");
	argcheck(nM, 6, "number");
	argcheck(nF, 7, "number", "nil");
	--]]
	
	if not ( M and nM ) then return end;
	F = F or min(#WorldMapSize[M], 1);
	nF = nF or min(#WorldMapSize[nM], 1);
	if ( nM < 0 ) then
		return;
	end
	
	local mapData;
	if ( M == nM and F == nF ) then
		return xPos, yPos;
	
	else
		local map = WorldMapSize[M];
		local nMap = WorldMapSize[nM];
		if ( map.system == nMap.system ) then
			-- points within the same system (continent)
			xPos, yPos = getSystemPosition(map, F, xPos, yPos);
			mapData = WorldMapSize[nM];
			if ( nF ~= 0 ) then
				mapData = rawget(mapData, nF) or MicroDungeonSize[mapData.originSystem][nF];
			end
		
		else
			-- different continents, same world
			local S = map.system;
			local nS = nMap.system;
			if ( (M==0 or WorldMapSize[0][S]) and (nM==0 or WorldMapSize[0][nS]) ) then
				mapData = WorldMapSize[M];
				xPos, yPos = getSystemPosition(mapData, F, xPos, yPos);
				if ( M ~= 0 ) then
					-- translate up to world map if we aren't there already
					local cont = WorldMapSize[0][S];
					xPos = (xPos - cont.xOffset) * cont.scale;
					yPos = (yPos - cont.yOffset) * cont.scale;
					mapData = WorldMapSize[0];
				end
				if ( nM ~= 0 ) then
					-- translate down to the new continent
					local nCont = WorldMapSize[0][nS];
					xPos = (xPos / nCont.scale) + nCont.xOffset;
					yPos = (yPos / nCont.scale) + nCont.yOffset;
					mapData = WorldMapSize[nM];
					if ( nF ~= 0 ) then
						mapData = rawget(mapData, nF) or MicroDungeonSize[mapData.originSystem][nF];
					end
				end
			
			else
				return;
			end
		
		end
		-- need to account for the offset in the new system so we can
		-- correctly translate into 0-1 style coordinates
		xPos = xPos - mapData.xOffset;
		yPos = yPos - mapData.yOffset;
	
	end
	
	return (xPos / mapData.width), (yPos / mapData.height);
end

--*****************************************************************************
-- This function will do its utmost to retrieve some sort of valid position 
-- for the specified unit, including changing the current map zoom (if needed).  
-- Map Zoom is returned to its previous setting before this function returns.  
--*****************************************************************************
function Astrolabe:GetUnitPosition( unit, noMapChange )
	local x, y = GetPlayerMapPosition(unit);
	if ( x <= 0 and y <= 0 ) then
		if ( noMapChange ) then
			-- no valid position on the current map, and we aren't allowed
			-- to change map zoom, so return
			return;
		end
		local lastMapID, lastFloor = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel();
		SetMapToCurrentZone();
		x, y = GetPlayerMapPosition(unit);
		if ( x <= 0 and y <= 0 ) then
			-- attempt to zoom out once - logic copied from WorldMapZoomOutButton_OnClick()
				if ( ZoomOut() ) then
					-- do nothing
				elseif ( GetCurrentMapZone() ~= WORLDMAP_WORLD_ID ) then
					SetMapZoom(GetCurrentMapContinent());
				else
					SetMapZoom(WORLDMAP_WORLD_ID);
				end
			x, y = GetPlayerMapPosition(unit);
			if ( x <= 0 and y <= 0 ) then
				-- we are in an instance without a map or otherwise off map
				return;
			end
		end
		local M, F = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel();
		if ( M ~= lastMapID or F ~= lastFloor ) then
			-- set map zoom back to what it was before
			SetMapByID(lastMapID);
			SetDungeonMapLevel(lastFloor);
		end
		return M, F, x, y;
	end
	return GetCurrentMapAreaID(), GetCurrentMapDungeonLevel(), x, y;
end

--*****************************************************************************
-- This function will do its utmost to retrieve some sort of valid position 
-- for the specified unit, including changing the current map zoom (if needed).  
-- However, if a monitored WorldMapFrame (See AstrolabeMapMonitor.lua) is 
-- visible, then will simply return nil if the current zoom does not provide 
-- a valid position for the player unit.  Map Zoom is NOT returned to its previous 
-- setting before this function returns, in order to provide better performance.  
--*****************************************************************************
function Astrolabe:GetCurrentPlayerPosition()
	local x, y = GetPlayerMapPosition("player");
	if ( x <= 0 and y <= 0 ) then
		if ( self.WorldMapVisible ) then
			-- we know there is a visible world map, so don't cause 
			-- WORLD_MAP_UPDATE events by changing map zoom
			return;
		end
		SetMapToCurrentZone();
		x, y = GetPlayerMapPosition("player");
		if ( x <= 0 and y <= 0 ) then
			-- attempt to zoom out once - logic copied from WorldMapZoomOutButton_OnClick()
				if ( ZoomOut() ) then
					-- do nothing
				elseif ( GetCurrentMapZone() ~= WORLDMAP_WORLD_ID ) then
					SetMapZoom(GetCurrentMapContinent());
				else
					SetMapZoom(WORLDMAP_WORLD_ID);
				end
			x, y = GetPlayerMapPosition("player");
			if ( x <= 0 and y <= 0 ) then
				-- we are in an instance without a map or otherwise off map
				return;
			end
		end
	end
	return GetCurrentMapAreaID(), GetCurrentMapDungeonLevel(), x, y;
end

function Astrolabe:GetMapID(continent, zone)
	zone = zone or 0;
	local ret = self.ContinentList[continent];
	if ( ret ) then
		return ret[zone];
	end
	if ( continent == 0 and zone == 0 ) then
		return 0;
	end
end

function Astrolabe:GetNumFloors( mapID )
	if ( type(mapID) == "number" ) then
		local mapData = WorldMapSize[mapID]
		return #mapData
	end
end

function Astrolabe:GetMapInfo( mapID, mapFloor )
	argcheck(mapID, 2, "number");
	assert(3, mapID >= 0, "GetMapInfo: Illegal map id to mapID: "..mapID);
	argcheck(mapFloor, 3, "number", "nil");
	
	mapFloor = mapFloor or min(#WorldMapSize[mapID], 1);
	local mapData = WorldMapSize[mapID];
	local system, systemParent = mapData.system, WorldMapSize[0][mapData.system] and true or false
	if ( mapFloor ~= 0 ) then
		mapData = rawget(mapData, mapFloor) or MicroDungeonSize[mapData.originSystem][mapFloor];
	end
	if ( mapData ~= zeroData ) then
		return system, systemParent, mapData.width, mapData.height, mapData.xOffset, mapData.yOffset;
	end
end

function Astrolabe:GetMapFilename( mapID )
	local mapData = self.HarvestedMapData[mapID]
	if ( mapData ) then
		return mapData.mapName
	end
end


--------------------------------------------------------------------------------------------------------------
-- Working Table Cache System
--------------------------------------------------------------------------------------------------------------

local tableCache = {};
tableCache["__mode"] = "v";
setmetatable(tableCache, tableCache);

local function GetWorkingTable( icon )
	if ( tableCache[icon] ) then
		return tableCache[icon];
	else
		local T = {};
		tableCache[icon] = T;
		return T;
	end
end


--------------------------------------------------------------------------------------------------------------
-- Minimap Icon Placement
--------------------------------------------------------------------------------------------------------------

--*****************************************************************************
-- local variables specifically for use in this section
--*****************************************************************************
local minimapRotationEnabled = false;
local minimapShape = false;

local minimapRotationOffset = GetPlayerFacing();


local function placeIconOnMinimap( minimap, minimapZoom, mapWidth, mapHeight, icon, dist, xDist, yDist, edgeRangeMultiplier )
	local mapDiameter;
	if ( Astrolabe.minimapOutside ) then
		mapDiameter = MinimapSize.outdoor[minimapZoom];
	else
		mapDiameter = MinimapSize.indoor[minimapZoom];
	end
	local mapRadius = mapDiameter * edgeRangeMultiplier / 2;
	local xScale = mapDiameter / mapWidth;
	local yScale = mapDiameter / mapHeight;
	local iconDiameter = ((icon:GetWidth() / 2) + 3) * xScale;
	local iconOnEdge = nil;
	local isRound = true;
	
	if ( minimapRotationEnabled ) then
		local sinTheta = sin(minimapRotationOffset)
		local cosTheta = cos(minimapRotationOffset)
		--[[
		Math Note
		The math that is acutally going on in the next 3 lines is:
			local dx, dy = xDist, -yDist
			xDist = (dx * cosTheta) + (dy * sinTheta)
			yDist = -((-dx * sinTheta) + (dy * cosTheta))
		
		This is because the origin for map coordinates is the top left corner
		of the map, not the bottom left, and so we have to reverse the vertical 
		distance when doing the our rotation, and then reverse the result vertical 
		distance because this rotation formula gives us a result with the origin based 
		in the bottom left corner (of the (+, +) quadrant).  
		The actual code is a simplification of the above.  
		]]
		local dx, dy = xDist, yDist
		xDist = (dx * cosTheta) - (dy * sinTheta)
		yDist = (dx * sinTheta) + (dy * cosTheta)
	end
	
	if ( minimapShape and not (xDist == 0 or yDist == 0) ) then
		isRound = (xDist < 0) and 1 or 3;
		if ( yDist < 0 ) then
			isRound = minimapShape[isRound];
		else
			isRound = minimapShape[isRound + 1];
		end
	end
	
	-- for non-circular portions of the Minimap edge
	if not ( isRound ) then
		dist = max(abs(xDist), abs(yDist))
	end

	if ( (dist + iconDiameter) > mapRadius ) then
		-- position along the outside of the Minimap
		iconOnEdge = true;
		local factor = (mapRadius - iconDiameter) / dist;
		xDist = xDist * factor;
		yDist = yDist * factor;
	end
	
	if ( Astrolabe.IconsOnEdge[icon] ~= iconOnEdge ) then
		Astrolabe.IconsOnEdge[icon] = iconOnEdge;
		Astrolabe.IconsOnEdgeChanged = true;
	end
	
	icon:ClearAllPoints();
	icon:SetPoint("CENTER", minimap, "CENTER", xDist/xScale, -yDist/yScale);
end

function Astrolabe:PlaceIconOnMinimap( icon, mapID, mapFloor, xPos, yPos )
	-- check argument types
	argcheck(icon, 2, "table");
	assert(3, icon.SetPoint and icon.ClearAllPoints and icon.GetWidth, "Usage Message");
	argcheck(mapID, 3, "number");
	argcheck(mapFloor, 4, "number", "nil");
	argcheck(xPos, 5, "number");
	argcheck(yPos, 6, "number");
	
	-- if the positining system is currently active, just use the player position used by the last incremental (or full) update
	-- otherwise, make sure we base our calculations off of the most recent player position (if one is available)
	local lM, lF, lx, ly;
	if ( self.processingFrame:IsShown() ) then
		lM, lF, lx, ly = unpack(self.LastPlayerPosition);
	else
		lM, lF, lx, ly = self:GetCurrentPlayerPosition();
		if ( lM and lM >= 0 ) then
			local lastPosition = self.LastPlayerPosition;
			lastPosition[1] = lM;
			lastPosition[2] = lF;
			lastPosition[3] = lx;
			lastPosition[4] = ly;
		else
			lM, lF, lx, ly = unpack(self.LastPlayerPosition);
		end
	end
	
	local dist, xDist, yDist = self:ComputeDistance(lM, lF, lx, ly, mapID, mapFloor, xPos, yPos);
	if not ( dist ) then
		--icon's position has no meaningful position relative to the player's current location
		return -1;
	end
	
	local iconData = GetWorkingTable(icon);
	if ( self.MinimapIcons[icon] ) then
		self.MinimapIcons[icon] = nil;
	else
		self.MinimapIconCount = self.MinimapIconCount + 1
	end
	
	AddedOrUpdatedIcons[icon] = iconData
	iconData.mapID = mapID;
	iconData.mapFloor = mapFloor;
	iconData.xPos = xPos;
	iconData.yPos = yPos;
	iconData.dist = dist;
	iconData.xDist = xDist;
	iconData.yDist = yDist;
	
	minimapRotationEnabled = GetCVar("rotateMinimap") ~= "0"
	if ( minimapRotationEnabled ) then
		minimapRotationOffset = GetPlayerFacing();
	end
	
	-- check Minimap Shape
	minimapShape = GetMinimapShape and ValidMinimapShapes[GetMinimapShape()];
	
	-- place the icon on the Minimap and :Show() it
	local map = self.Minimap
	placeIconOnMinimap(map, map:GetZoom(), map:GetWidth(), map:GetHeight(), icon, dist, xDist, yDist, self.EdgeRangeMultiplier[icon]);
	-- re-parent the icon if necessary
	if ( icon.GetParent and icon.SetParent ) then
		local iconParent = icon:GetParent()
		if ( iconParent) then
			if ( iconParent == map ) then
				-- do nothing
			elseif ( iconParent:IsObjectType("Minimap") ) then
				icon:SetParent(map);
			else
				 -- just in case our icon has an ancestor inbetween it and the Minimap
				iconParent = iconParent:GetParent()
				if ( iconParent and iconParent ~= map and iconParent:IsObjectType("Minimap") ) then
					iconParent:SetParent(map);
				end
			end
		end
	end
	icon:Show()
	
	-- We know this icon's position is valid, so we need to make sure the icon placement system is active.  
	self.processingFrame:Show()
	
	return 0;
end

function Astrolabe:RemoveIconFromMinimap( icon )
	if not ( self.MinimapIcons[icon] ) then
		return 1;
	end
	AddedOrUpdatedIcons[icon] = nil
	self.MinimapIcons[icon] = nil;
	self.IconsOnEdge[icon] = nil;
	icon:Hide();
	
	local MinimapIconCount = self.MinimapIconCount - 1
	if ( MinimapIconCount <= 0 ) then
		-- no icons left to manage
		self.processingFrame:Hide()
		MinimapIconCount = 0 -- because I'm paranoid
	end
	self.MinimapIconCount = MinimapIconCount
	
	return 0;
end

function Astrolabe:RemoveAllMinimapIcons( assocName )
	argcheck(assocName, 2, "string", "nil");
	if ( assocName == nil ) then -- remove all icons
		self:DumpNewIconsCache();
		local MinimapIcons = self.MinimapIcons;
		local IconsOnEdge = self.IconsOnEdge;
		for icon, data in pairs(MinimapIcons) do
			MinimapIcons[icon] = nil;
			IconsOnEdge[icon] = nil;
			icon:Hide();
		end
		self.MinimapIconCount = 0;
		self.processingFrame:Hide();
	
	else -- remove just icons that match the specified association
		for icon, iconAssoc in pairs(self.IconAssociations) do
			if ( iconAssoc == assocName ) then
				self:RemoveIconFromMinimap(icon)
			end
		end
	
	end
end

local lastZoom; -- to remember the last seen Minimap zoom level

-- local variables to track the status of the two update coroutines
local fullUpdateInProgress = true
local resetIncrementalUpdate = false
local resetFullUpdate = false

-- Incremental Update Code
do
	-- local variables to track the incremental update coroutine
	local incrementalUpdateCrashed = true
	local incrementalUpdateThread
	
	local function UpdateMinimapIconPositions( self )
		-- cache a reference to EdgeRangeMultiplier, for performance
		local EdgeRangeMultiplier = self.EdgeRangeMultiplier;
		yield()
		
		while ( true ) do
			self:DumpNewIconsCache() -- put new/updated icons into the main datacache
			
			resetIncrementalUpdate = false -- by definition, the incremental update is reset if it is here
			
			local M, F, x, y = self:GetCurrentPlayerPosition();
			if ( M and M >= 0 ) then
				local Minimap = Astrolabe.Minimap;
				local lastPosition = self.LastPlayerPosition;
				local lM, lF, lx, ly = unpack(lastPosition);
				
				minimapRotationEnabled = GetCVar("rotateMinimap") ~= "0"
				if ( minimapRotationEnabled ) then
					minimapRotationOffset = GetPlayerFacing();
				end
				
				-- check current frame rate
				local numPerCycle = min(50, GetFramerate() * (self.MinimapUpdateMultiplier or 1))
				
				-- check Minimap Shape
				minimapShape = GetMinimapShape and ValidMinimapShapes[GetMinimapShape()];
				
				if ( lM == M and lF == F and lx == x and ly == y ) then
					-- player has not moved since the last update
					if ( lastZoom ~= Minimap:GetZoom() or self.ForceNextUpdate or minimapRotationEnabled ) then
						local currentZoom = Minimap:GetZoom();
						lastZoom = currentZoom;
						local mapWidth = Minimap:GetWidth();
						local mapHeight = Minimap:GetHeight();
						numPerCycle = numPerCycle * 2
						local count = 0
						for icon, data in pairs(self.MinimapIcons) do
							placeIconOnMinimap(Minimap, currentZoom, mapWidth, mapHeight, icon, data.dist, data.xDist, data.yDist, EdgeRangeMultiplier[icon]);
							
							count = count + 1
							if ( count > numPerCycle ) then
								count = 0
								yield()
								-- check if the incremental update cycle needs to be reset 
								-- because a full update has been run
								if ( resetIncrementalUpdate ) then
									break;
								end
							end
						end
						self.ForceNextUpdate = false;
					end
				else
					local dist, xDelta, yDelta = self:ComputeDistance(lM, lF, lx, ly, M, F, x, y);
					if ( dist ) then
						local currentZoom = Minimap:GetZoom();
						lastZoom = currentZoom;
						local mapWidth = Minimap:GetWidth();
						local mapHeight = Minimap:GetHeight();
						local count = 0
						for icon, data in pairs(self.MinimapIcons) do
							local xDist = data.xDist - xDelta;
							local yDist = data.yDist - yDelta;
							local dist = sqrt(xDist*xDist + yDist*yDist);
							placeIconOnMinimap(Minimap, currentZoom, mapWidth, mapHeight, icon, dist, xDist, yDist, EdgeRangeMultiplier[icon]);
							
							data.dist = dist;
							data.xDist = xDist;
							data.yDist = yDist;
							
							count = count + 1
							if ( count >= numPerCycle ) then
								count = 0
								yield()
								-- check if the incremental update cycle needs to be reset 
								-- because a full update has been run
								if ( resetIncrementalUpdate ) then
									break;
								end
							end
						end
						if not ( resetIncrementalUpdate ) then
							lastPosition[1] = M;
							lastPosition[2] = F;
							lastPosition[3] = x;
							lastPosition[4] = y;
						end
					else
						self:RemoveAllMinimapIcons()
						lastPosition[1] = M;
						lastPosition[2] = F;
						lastPosition[3] = x;
						lastPosition[4] = y;
					end
				end
			else
				if not ( self.WorldMapVisible ) then
					self.processingFrame:Hide();
				end
			end
			
			-- if we've been reset, then we want to start the new cycle immediately
			if not ( resetIncrementalUpdate ) then
				yield()
			end
		end
	end
	
	function Astrolabe:UpdateMinimapIconPositions()
		if ( fullUpdateInProgress ) then
			-- if we're in the middle a a full update, we want to finish that first
			self:CalculateMinimapIconPositions()
		else
			if ( incrementalUpdateCrashed ) then
				incrementalUpdateThread = coroutine.wrap(UpdateMinimapIconPositions)
				incrementalUpdateThread(self) --initialize the thread
			end
			incrementalUpdateCrashed = true
			incrementalUpdateThread()
			incrementalUpdateCrashed = false
		end
	end
end

-- Full Update Code
do
	-- local variables to track the full update coroutine
	local fullUpdateCrashed = true
	local fullUpdateThread
	
	local function CalculateMinimapIconPositions( self )
		-- cache a reference to EdgeRangeMultiplier, for performance
		local EdgeRangeMultiplier = self.EdgeRangeMultiplier;
		yield()
		
		while ( true ) do
			self:DumpNewIconsCache() -- put new/updated icons into the main datacache
			
			resetFullUpdate = false -- by definition, the full update is reset if it is here
			fullUpdateInProgress = true -- set the flag the says a full update is in progress
			
			local M, F, x, y = self:GetCurrentPlayerPosition();
			if ( M and M >= 0 ) then
				local Minimap = Astrolabe.Minimap;
				minimapRotationEnabled = GetCVar("rotateMinimap") ~= "0"
				if ( minimapRotationEnabled ) then
					minimapRotationOffset = GetPlayerFacing();
				end
				
				-- check current frame rate
				local numPerCycle = GetFramerate() * (self.MinimapUpdateMultiplier or 1) * 2
				
				-- check Minimap Shape
				minimapShape = GetMinimapShape and ValidMinimapShapes[GetMinimapShape()];
				
				local currentZoom = Minimap:GetZoom();
				lastZoom = currentZoom;
				local mapWidth = Minimap:GetWidth();
				local mapHeight = Minimap:GetHeight();
				local count = 0
				for icon, data in pairs(self.MinimapIcons) do
					local dist, xDist, yDist = self:ComputeDistance(M, F, x, y, data.mapID, data.mapFloor, data.xPos, data.yPos);
					if ( dist ) then
						placeIconOnMinimap(Minimap, currentZoom, mapWidth, mapHeight, icon, dist, xDist, yDist, EdgeRangeMultiplier[icon]);
						
						data.dist = dist;
						data.xDist = xDist;
						data.yDist = yDist;
					else
						self:RemoveIconFromMinimap(icon)
					end
					
					count = count + 1
					if ( count >= numPerCycle ) then
						count = 0
						yield()
						-- check if we need to restart due to the full update being reset
						if ( resetFullUpdate ) then
							break;
						end
					end
				end
				
				if not ( resetFullUpdate ) then
					local lastPosition = self.LastPlayerPosition;
					lastPosition[1] = M;
					lastPosition[2] = F;
					lastPosition[3] = x;
					lastPosition[4] = y;
					
					resetIncrementalUpdate = true
				end
			else
				if not ( self.WorldMapVisible ) then
					self.processingFrame:Hide();
				end
			end
			
			-- if we've been reset, then we want to start the new cycle immediately
			if not ( resetFullUpdate ) then
				fullUpdateInProgress = false
				yield()
			end
		end
	end
	
	function Astrolabe:CalculateMinimapIconPositions( reset )
		if ( fullUpdateCrashed ) then
			fullUpdateThread = coroutine.wrap(CalculateMinimapIconPositions)
			fullUpdateThread(self) --initialize the thread
		elseif ( reset ) then
			resetFullUpdate = true
		end
		fullUpdateCrashed = true
		fullUpdateThread()
		fullUpdateCrashed = false
		
		-- return result flag
		if ( fullUpdateInProgress ) then
			return 1 -- full update started, but did not complete on this cycle
		
		else
			if ( resetIncrementalUpdate ) then
				return 0 -- update completed
			else
				return -1 -- full update did no occur for some reason
			end
		
		end
	end
end

function Astrolabe:GetDistanceToIcon( icon )
	local data = self.MinimapIcons[icon];
	if ( data ) then
		return data.dist, data.xDist, data.yDist;
	end
end

function Astrolabe:IsIconOnEdge( icon )
	return self.IconsOnEdge[icon];
end

function Astrolabe:GetDirectionToIcon( icon )
	local data = self.MinimapIcons[icon];
	if ( data ) then
		local dir = atan2(data.xDist, -(data.yDist))
		if ( dir > 0 ) then
			return twoPi - dir;
		else
			return -dir;
		end
	end
end

function Astrolabe:AssociateIcon( icon, assocName )
	argcheck(icon, 2, "table");
	argcheck(assocName, 3, "string", "nil");
	self.IconAssociations[icon] = assocName;
	self.EdgeRangeMultiplier[icon] = self.EdgeRangeMultiplier[assocName]; -- update the icon's edge multiplier
	self.ForceNextUpdate = true; -- force a redraw
end

function Astrolabe:GetIconAssociation( icon )
	return self.IconAssociations[icon];
end

function Astrolabe:SetEdgeRangeMultiplier( multiplier, assocName )
	argcheck(multiplier, 2, "number", "nil");
	argcheck(assocName, 3, "string", "nil");
	assert(3, (multiplier or assocName), "Astrolabe:SetEdgeRangeMultiplier( multiplier, [assocName] ) - at least one argument must be specificed");
	assert(3, (not multiplier or multiplier > 0), "Astrolabe:SetEdgeRangeMultiplier( multiplier, [assocName] ) - mutliplier must be greater than zero");
	
	local EdgeRangeMultiplier = self.EdgeRangeMultiplier;
	local IconAssociations = self.IconAssociations;
	if ( assocName == nil ) then
		-- set the default multiplier
		self.DefaultEdgeRangeMultiplier = multiplier;
		for icon in pairs(EdgeRangeMultiplier) do
			local iconAssoc = IconAssociations[icon];
			if ( type(icon) == "table" and (not iconAssoc or rawget(EdgeRangeMultiplier, iconAssoc) == nil) ) then
				EdgeRangeMultiplier[icon] = multiplier;
			end
		end
	else
		-- set the multiplier for specific icons
		EdgeRangeMultiplier[assocName] = multiplier;
		for icon, iconAssoc in pairs(IconAssociations) do
			if ( iconAssoc == assocName ) then
				EdgeRangeMultiplier[icon] = multiplier;
			end
		end
	end
	self.ForceNextUpdate = true; -- force a redraw
end

function Astrolabe:GetEdgeRangeMultiplier( assocOrIcon )
	argcheck(assocOrIcon, 2, "table", "string", "nil");
	return rawget(self.EdgeRangeMultiplier, assocOrIcon) or self.DefaultEdgeRangeMultiplier;
end

function Astrolabe:Register_OnEdgeChanged_Callback( func, ident )
	argcheck(func, 2, "function");
	self.IconsOnEdge_GroupChangeCallbacks[func] = ident;
end

function Astrolabe:SetTargetMinimap( newMinimap )
	if ( newMinimap == self.Minimap ) then
		return; -- no change
	end
	argcheck(newMinimap, 2, "table");
	assert(3, issecurevariable(newMinimap, 0), "Astrolabe:SetTargetMinimap( newMinimap ) - argument is not a Minimap");
	assert(3, newMinimap.IsObjectType, "Astrolabe:SetTargetMinimap( newMinimap ) - argument is not a Minimap");
	assert(3, type(newMinimap.IsObjectType) == "function", "Astrolabe:SetTargetMinimap( newMinimap ) - argument is not a Minimap");
	assert(3, newMinimap:IsObjectType("Minimap"), "Astrolabe:SetTargetMinimap( newMinimap ) - argument is not a Minimap");
	
	local oldMinimap = self.Minimap;
	self.processingFrame:SetParent(newMinimap);
	self.Minimap = newMinimap;
	self:CalculateMinimapIconPositions(true); -- re-anchor all currently managed icons
	-- re-parent all currently managed icons
	for icon, data in pairs(self.MinimapIcons) do
		if ( icon.GetParent and icon.SetParent ) then
			if ( icon:GetParent() == oldMinimap ) then
				icon:SetParent(newMinimap);
			elseif ( icon:GetParent() and icon:GetParent():GetParent() == oldMinimap ) then -- just incase our icons have an ancestor inbetween them and the Minimap
				icon:GetParent():SetParent(newMinimap);
			end
		end
	end
	
	for func in pairs(self.TargetMinimapChanged_Callbacks) do
		pcall(func);
	end
end

function Astrolabe:Register_TargetMinimapChanged_Callback( func, ident )
	-- check argument types
	argcheck(func, 2, "function");
	
	self.TargetMinimapChanged_Callbacks[func] = ident;
end

--*****************************************************************************
-- INTERNAL USE ONLY PLEASE!!!
-- Calling this function at the wrong time can cause errors
--*****************************************************************************
function Astrolabe:DumpNewIconsCache()
	local MinimapIcons = self.MinimapIcons
	for icon, data in pairs(AddedOrUpdatedIcons) do
		MinimapIcons[icon] = data
		AddedOrUpdatedIcons[icon] = nil
	end
	-- we now need to restart any updates that were in progress
	resetIncrementalUpdate = true
	resetFullUpdate = true
end


--------------------------------------------------------------------------------------------------------------
-- World Map Icon Placement
--------------------------------------------------------------------------------------------------------------

function Astrolabe:PlaceIconOnWorldMap( worldMapFrame, icon, mapID, mapFloor, xPos, yPos )
	-- check argument types
	argcheck(worldMapFrame, 2, "table");
	assert(3, worldMapFrame.GetWidth and worldMapFrame.GetHeight, "Usage Message");
	argcheck(icon, 3, "table");
	assert(3, icon.SetPoint and icon.ClearAllPoints, "Usage Message");
	argcheck(mapID, 4, "number");
	argcheck(mapFloor, 5, "number", "nil");
	argcheck(xPos, 6, "number");
	argcheck(yPos, 7, "number");
	
	local M, F = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel();
	local nX, nY = self:TranslateWorldMapPosition(mapID, mapFloor, xPos, yPos, M, F);
	
	-- anchor and :Show() the icon if it is within the boundry of the current map, :Hide() it otherwise
	if ( nX and nY and (0 < nX and nX <= 1) and (0 < nY and nY <= 1) ) then
		icon:ClearAllPoints();
		icon:SetPoint("CENTER", worldMapFrame, "TOPLEFT", nX * worldMapFrame:GetWidth(), -nY * worldMapFrame:GetHeight());
		icon:Show();
	else
		icon:Hide();
	end
	return nX, nY;
end


--------------------------------------------------------------------------------------------------------------
-- Handler Scripts
--------------------------------------------------------------------------------------------------------------

function Astrolabe:OnEvent( frame, event )
	if ( event == "MINIMAP_UPDATE_ZOOM" ) then
		-- update minimap zoom scale
		local Minimap = self.Minimap;
		local curZoom = Minimap:GetZoom();
		if ( GetCVar("minimapZoom") == GetCVar("minimapInsideZoom") ) then
			if ( curZoom < 2 ) then
				Minimap:SetZoom(curZoom + 1);
			else
				Minimap:SetZoom(curZoom - 1);
			end
		end
		if ( GetCVar("minimapZoom")+0 == Minimap:GetZoom() ) then
			self.minimapOutside = true;
		else
			self.minimapOutside = false;
		end
		Minimap:SetZoom(curZoom);
		
		-- re-calculate all Minimap Icon positions
		if ( frame:IsVisible() ) then
			self:CalculateMinimapIconPositions(true);
		end
	
	elseif ( event == "PLAYER_LEAVING_WORLD" ) then
		frame:Hide(); -- yes, I know this is redunant
		self:RemoveAllMinimapIcons(); --dump all minimap icons
		-- TODO: when I uncouple the point buffer from Minimap drawing,
		--       I should consider updating LastPlayerPosition here
	
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		frame:Show();
		if not ( frame:IsVisible() ) then
			-- do the minimap recalculation anyways if the OnShow script didn't execute
			-- this is done to ensure the accuracy of information about icons that were 
			-- inserted while the Player was in the process of zoning
			self:CalculateMinimapIconPositions(true);
		end
	
	elseif ( event == "ZONE_CHANGED_NEW_AREA" ) then
		frame:Hide();
		frame:Show();
	
	end
end

function Astrolabe:OnUpdate( frame, elapsed )
	-- on-edge group changed call-backs
	if ( self.IconsOnEdgeChanged ) then
		self.IconsOnEdgeChanged = false;
		for func in pairs(self.IconsOnEdge_GroupChangeCallbacks) do
			pcall(func);
		end
	end
	
	self:UpdateMinimapIconPositions();
end

function Astrolabe:OnShow( frame )
	-- set the world map to a zoom with a valid player position
	if not ( self.WorldMapVisible ) then
		SetMapToCurrentZone();
	end
	local M, F = Astrolabe:GetCurrentPlayerPosition();
	if not ( M and M >= 0 ) then
		frame:Hide();
		return
	end
	
	-- re-calculate minimap icon positions (if needed)
	if ( next(self.MinimapIcons) ) then
		self:CalculateMinimapIconPositions(true);
	else
		-- needed so that the cycle doesn't overwrite an updated LastPlayerPosition
		resetIncrementalUpdate = true;
	end
	
	if ( self.MinimapIconCount <= 0 ) then
		-- no icons left to manage
		frame:Hide();
	end
end

function Astrolabe:OnHide( frame )
	-- dump the new icons cache here
	-- a full update will performed the next time processing is re-actived
	self:DumpNewIconsCache()
end

-- called by AstrolabMapMonitor when all world maps are hidden
function Astrolabe:AllWorldMapsHidden()
	if ( IsLoggedIn() ) then
		self.processingFrame:Hide();
		self.processingFrame:Show();
	end
end


--------------------------------------------------------------------------------------------------------------
-- Library Registration
--------------------------------------------------------------------------------------------------------------

local HARVESTED_DATA_VERSION = 3; -- increment this when the format of the harvested data has to change
local function harvestMapData( HarvestedMapData )
	local mapData = {}
	local mapName = GetMapInfo();
	local mapID = GetCurrentMapAreaID();
	local numFloors = GetNumDungeonMapLevels();
	mapData.mapName = mapName;
	mapData.cont = (GetCurrentMapContinent()) or -100;
	mapData.zone = (GetCurrentMapZone()) or -100;
	mapData.numFloors = numFloors;
	local _, TLx, TLy, BRx, BRy = GetCurrentMapZone();
	if ( TLx and TLy and BRx and BRy and (TLx~=0 or TLy~=0 or BRx~=0 or BRy~=0) ) then
		mapData[0] = {};
		mapData[0].TLx = TLx;
		mapData[0].TLy = TLy;
		mapData[0].BRx = BRx;
		mapData[0].BRy = BRy;
	end
	if ( not mapData[0] and numFloors == 0 and (GetCurrentMapDungeonLevel()) == 1 ) then
		numFloors = 1;
		mapData.hiddenFloor = true;
	end
	if ( numFloors > 0 ) then
		for f = 1, numFloors do
			SetDungeonMapLevel(f);
			local _, TLx, TLy, BRx, BRy = GetCurrentMapDungeonLevel();
			if ( TLx and TLy and BRx and BRy ) then
				mapData[f] = {};
				mapData[f].TLx = TLx;
				mapData[f].TLy = TLy;
				mapData[f].BRx = BRx;
				mapData[f].BRy = BRy;
			end
		end
	end

	HarvestedMapData[mapID] = mapData;
end

local function activate( newInstance, oldInstance )
	if ( oldInstance ) then -- this is an upgrade activate
		-- print upgrade debug info
		local _, oldVersion = oldInstance:GetVersion();
		printError("Upgrading "..LIBRARY_VERSION_MAJOR.." from version "..oldVersion.." to version "..LIBRARY_VERSION_MINOR);
		
		if ( oldInstance.DumpNewIconsCache ) then
			oldInstance:DumpNewIconsCache()
		end
		for k, v in pairs(oldInstance) do
			if ( type(v) ~= "function" and (not configConstants[k]) ) then
				newInstance[k] = v;
			end
		end
		-- sync up the current MinimapIconCount value
		local iconCount = 0
		for _ in pairs(newInstance.MinimapIcons) do
			iconCount = iconCount + 1
		end
		newInstance.MinimapIconCount = iconCount
		
		-- explicity carry over our Minimap reference, or create it if we don't already have one
		newInstance.Minimap = oldInstance.Minimap or _G.Minimap
		
		Astrolabe = oldInstance;
	else
		newInstance.Minimap = _G.Minimap
		local frame = CreateFrame("Frame");
		newInstance.processingFrame = frame;
	end
	configConstants = nil -- we don't need this anymore
	
	if not ( oldInstance and oldInstance.HarvestedMapData.VERSION == HARVESTED_DATA_VERSION ) then
		newInstance.HarvestedMapData = { VERSION = HARVESTED_DATA_VERSION };
		local HarvestedMapData = newInstance.HarvestedMapData;
		
		local continents = {GetMapContinents()};
		newInstance.ContinentList = {};
		for C = 1, (#continents / 2) do
			local zones = {GetMapZones(C)};
			newInstance.ContinentList[C] = {};
			SetMapZoom(C);
			harvestMapData(HarvestedMapData);
			local contZoneList = newInstance.ContinentList[C];
			contZoneList[0] = continents[C*2 - 1];
			for Z = 1, (#zones / 2) do
				contZoneList[Z] = zones[Z*2 - 1];
				SetMapByID(contZoneList[Z]);
				harvestMapData(HarvestedMapData);
			end
		end
		
		for _, id in ipairs(GetAreaMaps()) do
			if not ( HarvestedMapData[id] ) then
				if ( SetMapByID(id) ) then
					harvestMapData(HarvestedMapData);
				end
			end
		end
	end
	
	local Minimap = newInstance.Minimap
	local frame = newInstance.processingFrame;
	frame:Hide();
	frame:SetParent(Minimap);
	frame:UnregisterAllEvents();
	frame:RegisterEvent("MINIMAP_UPDATE_ZOOM");
	frame:RegisterEvent("PLAYER_LEAVING_WORLD");
	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	frame:SetScript("OnEvent",
		function( frame, event, ... )
			Astrolabe:OnEvent(frame, event, ...);
		end
	);
	frame:SetScript("OnUpdate",
		function( frame, elapsed )
			Astrolabe:OnUpdate(frame, elapsed);
		end
	);
	frame:SetScript("OnShow",
		function( frame )
			Astrolabe:OnShow(frame);
		end
	);
	frame:SetScript("OnHide",
		function( frame )
			Astrolabe:OnHide(frame);
		end
	);
	
	setmetatable(Astrolabe.MinimapIcons, MinimapIconsMetatable)
end

DongleStub:Register(Astrolabe, activate)


--------------------------------------------------------------------------------------------------------------
-- Data
--------------------------------------------------------------------------------------------------------------

-- diameter of the Minimap in game yards at
-- the various possible zoom levels
MinimapSize = {
	indoor = {
		[0] = 300, -- scale
		[1] = 240, -- 1.25
		[2] = 180, -- 5/3
		[3] = 120, -- 2.5
		[4] = 80,  -- 3.75
		[5] = 50,  -- 6
	},
	outdoor = {
		[0] = 466 + 2/3, -- scale
		[1] = 400,       -- 7/6
		[2] = 333 + 1/3, -- 1.4
		[3] = 266 + 2/6, -- 1.75
		[4] = 200,       -- 7/3
		[5] = 133 + 1/3, -- 3.5
	},
}

ValidMinimapShapes = {
	-- { upper-left, lower-left, upper-right, lower-right }
	["SQUARE"]                = { false, false, false, false },
	["CORNER-TOPLEFT"]        = { true,  false, false, false },
	["CORNER-TOPRIGHT"]       = { false, false, true,  false },
	["CORNER-BOTTOMLEFT"]     = { false, true,  false, false },
	["CORNER-BOTTOMRIGHT"]    = { false, false, false, true },
	["SIDE-LEFT"]             = { true,  true,  false, false },
	["SIDE-RIGHT"]            = { false, false, true,  true },
	["SIDE-TOP"]              = { true,  false, true,  false },
	["SIDE-BOTTOM"]           = { false, true,  false, true },
	["TRICORNER-TOPLEFT"]     = { true,  true,  true,  false },
	["TRICORNER-TOPRIGHT"]    = { true,  false, true,  true },
	["TRICORNER-BOTTOMLEFT"]  = { true,  true,  false, true },
	["TRICORNER-BOTTOMRIGHT"] = { false, true,  true,  true },
}

-- distances across and offsets of the world maps
-- in game yards
WorldMapSize = {
	[0] = {
		height = 22266.74312,
		system = -1,
		width = 33400.121,
		xOffset = 0,
		yOffset = 0,
		[1] = {
			xOffset = -10311.71318,
			yOffset = -19819.33898,
			scale = 0.56089997291565,
		},
		[0] = {
			xOffset = -48226.86993,
			yOffset = -16433.90283,
			scale = 0.56300002336502,
		},
		[571] = {
			xOffset = -29750.89905,
			yOffset = -11454.50802,
			scale = 0.5949000120163,
		},
		[870] = {
			xOffset = -27693.71178,
			yOffset = -29720.0585,
			scale = 0.65140002965927,
		},
	},
}

MicroDungeonSize = {}


--------------------------------------------------------------------------------------------------------------
-- Internal Data Table Setup
--------------------------------------------------------------------------------------------------------------

-- Map Data API Flag Fields --

-- GetAreaMapInfo - flags
local WORLDMAPAREA_DEFAULT_DUNGEON_FLOOR_IS_TERRAIN = 0x00000004
local WORLDMAPAREA_VIRTUAL_CONTINENT = 0x00000008

-- GetDungeonMapInfo - flags
local DUNGEONMAP_MICRO_DUNGEON = 0x00000001


-- Zero Data Table
-- Used to prevent runtime Lua errors due to missing data

local function zeroDataFunc(tbl, key)
	if ( type(key) == "number" ) then
		return zeroData;
	else
		return rawget(zeroData, key);
	end
end

zeroData = { xOffset = 0, height = 1, yOffset = 0, width = 1, __index = zeroDataFunc };
setmetatable(zeroData, zeroData);

-- get data on useful transforms
local TRANSFORMS = {}
for _, ID in ipairs(GetWorldMapTransforms()) do
	local terrainMapID, newTerrainMapID, _, _, transformMinY, transformMaxY, transformMinX, transformMaxX, offsetY, offsetX = GetWorldMapTransformInfo(ID)
	if ( offsetX ~= 0 or offsetY ~= 0 ) then
		TRANSFORMS[ID] = {
			terrainMapID = terrainMapID,
			newTerrainMapID = newTerrainMapID,
			BRy = -transformMinY,
			TLy = -transformMaxY,
			BRx = -transformMinX,
			TLx = -transformMaxX,
			offsetY = offsetY,
			offsetX = offsetX,
		}
	end
end

--remove this temporarily
local harvestedDataVersion = Astrolabe.HarvestedMapData.VERSION
Astrolabe.HarvestedMapData.VERSION = nil

for mapID, harvestedData in pairs(Astrolabe.HarvestedMapData) do
	local terrainMapID, _, _, _, _, _, _, _, _, flags = GetAreaMapInfo(mapID)
	local originSystem = terrainMapID;
	local mapData = WorldMapSize[mapID];
	if not ( mapData ) then mapData = {}; end
	if ( harvestedData.numFloors > 0 or harvestedData.hiddenFloor ) then
		for f, harvData in pairs(harvestedData) do
			if ( type(f) == "number" and f > 0 ) then
				if not ( mapData[f] ) then
					mapData[f] = {};
				end
				local floorData = mapData[f]
				local TLx, TLy, BRx, BRy = -harvData.BRx, -harvData.BRy, -harvData.TLx, -harvData.TLy
				if not ( TLx < BRx ) then
						printError("Bad x-axis Orientation (Floor): ", mapID, f, TLx, BRx);
					end
					if not ( TLy < BRy) then
						printError("Bad y-axis Orientation (Floor): ", mapID, f, TLy, BRy);
					end
				if not ( floorData.width ) then
					floorData.width = BRx - TLx
				end
				if not ( floorData.height ) then
					floorData.height = BRy - TLy
				end
				if not ( floorData.xOffset ) then
					floorData.xOffset = TLx
				end
				if not ( floorData.yOffset ) then
					floorData.yOffset = TLy
				end
			end
		end
		for f = 1, harvestedData.numFloors do
			if not ( mapData[f] ) then
				if ( f == 1 and harvestedData[0] and harvestedData[0].TLx and harvestedData[0].TLy and harvestedData[0].BRx and harvestedData[0].BRy and
				  band(flags, WORLDMAPAREA_DEFAULT_DUNGEON_FLOOR_IS_TERRAIN) == WORLDMAPAREA_DEFAULT_DUNGEON_FLOOR_IS_TERRAIN ) then
					-- handle dungeon maps which use zone level data for the first floor
					mapData[f] = {};
					local floorData = mapData[f]
					local harvData = harvestedData[0]
					local TLx, TLy, BRx, BRy = -harvData.TLx, -harvData.TLy, -harvData.BRx, -harvData.BRy
					if not ( TLx < BRx ) then
						printError("Bad x-axis Orientation (Floor from Zone): ", mapID, f, TLx, BRx);
					end
					if not ( TLy < BRy) then
						printError("Bad y-axis Orientation (Floor from Zone): ", mapID, f, TLy, BRy);
					end
					floorData.width = BRx - TLx
					floorData.height = BRy - TLy
					floorData.xOffset = TLx
					floorData.yOffset = TLy
				else
					printError(("Astrolabe is missing data for %s [%d], floor %d."):format(harvestedData.mapName, mapID, f));
				end
			end
		end
		if ( harvestedData.hiddenFloor ) then
			mapData.width = mapData[1].width
			mapData.height = mapData[1].height
			mapData.xOffset = mapData[1].xOffset
			mapData.yOffset = mapData[1].yOffset
		end
	
	else
		local harvData = harvestedData[0]
		if ( harvData ~= nil ) then
			local TLx, TLy, BRx, BRy = -harvData.TLx, -harvData.TLy, -harvData.BRx, -harvData.BRy
			-- apply any necessary transforms
			for transformID, transformData in pairs(TRANSFORMS) do
				if ( transformData.terrainMapID == terrainMapID ) then
					if ( (transformData.TLx < TLx and BRx < transformData.BRx) and (transformData.TLy < TLy and BRy < transformData.BRy) ) then
						TLx = TLx - transformData.offsetX;
						BRx = BRx - transformData.offsetX;
						BRy = BRy - transformData.offsetY;
						TLy = TLy - transformData.offsetY;
						terrainMapID = transformData.newTerrainMapID;
						break;
					end
				end
			end
			if not ( TLx==0 and TLy==0 and BRx==0 and BRy==0 ) then
				if not ( TLx < BRx ) then
					printError("Bad x-axis Orientation (Zone): ", mapID, TLx, BRx);
				end
				if not ( TLy < BRy) then
					printError("Bad y-axis Orientation (Zone): ", mapID, TLy, BRy);
				end
			end
			if not ( mapData.width ) then
				mapData.width = BRx - TLx
			end
			if not ( mapData.height ) then
				mapData.height = BRy - TLy
			end
			if not ( mapData.xOffset ) then
				mapData.xOffset = TLx
			end
			if not ( mapData.yOffset ) then
				mapData.yOffset = TLy
			end
		else
			if ( mapID == 751 ) then -- okay, this is Maelstrom continent
			else
				printError("Astrolabe harvested a map with no data at all: ", mapID)
			end
		end
	
	end
	
	-- if we don't have any data, we're gonna use zeroData, but we also need to 
	-- setup the system and systemParent IDs so things don't get confused
	if not ( next(mapData, nil) ) then
		mapData = { xOffset = 0, height = 1, yOffset = 0, width = 1 };
		-- if this is an outside continent level or world map then throw up an extra warning
		if ( harvestedData.cont > 0 and harvestedData.zone == 0 and not (band(flags, WORLDMAPAREA_VIRTUAL_CONTINENT) == WORLDMAPAREA_VIRTUAL_CONTINENT) ) then
			printError(("Astrolabe is missing data for world map %s [%d] (%d, %d)."):format(harvestedData.mapName, mapID, harvestedData.cont, harvestedData.zone));
		end
	end
	
	if not ( mapData.originSystem ) then
		mapData.originSystem = originSystem;
	end
	
	-- store the data in the WorldMapSize DB
	WorldMapSize[mapID] = mapData;
	
	
	if ( mapData and mapData ~= zeroData ) then
		-- setup system IDs
		if not ( mapData.system ) then
			mapData.system = terrainMapID;
		end
		
		-- determine terrainMapID for micro-dungeons
		if ( harvestedData.cont > 0 and harvestedData.zone > 0 ) then
			MicroDungeonSize[terrainMapID] = {}
		end
		
		setmetatable(mapData, zeroData);
	end
end

-- put the version back
Astrolabe.HarvestedMapData.VERSION = harvestedDataVersion

-- micro dungeons
for _, ID in ipairs(GetDungeonMaps()) do
	local floorIndex, minX, maxX, minY, maxY, terrainMapID, parentWorldMapID, flags = GetDungeonMapInfo(ID);
	if ( band(flags, DUNGEONMAP_MICRO_DUNGEON) == DUNGEONMAP_MICRO_DUNGEON ) then
		local TLx, TLy, BRx, BRy = -maxX, -maxY, -minX, -minY
		-- apply any necessary transforms
		local transformApplied = false
		for transformID, transformData in pairs(TRANSFORMS) do
			if ( transformData.terrainMapID == terrainMapID ) then
				if ( (transformData.TLx < TLx and BRx < transformData.BRx) and (transformData.TLy < TLy and BRy < transformData.BRy) ) then
					TLx = TLx - transformData.offsetX;
					BRx = BRx - transformData.offsetX;
					BRy = BRy - transformData.offsetY;
					TLy = TLy - transformData.offsetY;
					transformApplied = true;
					break;
				end
			end
		end
		if ( MicroDungeonSize[terrainMapID] ) then
			-- only consider systems that can have micro dungeons
			if ( MicroDungeonSize[terrainMapID][floorIndex] ) then
				printError("Astrolabe detected a duplicate microdungeon floor!", terrainMapID, ID);
			end
			MicroDungeonSize[terrainMapID][floorIndex] = {
				width = BRx - TLx,
				height = BRy - TLy,
				xOffset = TLx,
				yOffset = TLy,
			};
		end
	end
end

-- done with Transforms data
TRANSFORMS = nil

for _, data in pairs(MicroDungeonSize) do
	setmetatable(data, zeroData);
end
setmetatable(MicroDungeonSize, zeroData);

-- make sure we don't have any EXTRA data hanging around
for mapID, mapData in pairs(WorldMapSize) do
	if ( mapID ~= 0 and getmetatable(mapData) ~= zeroData ) then
		printError("Astrolabe has hard coded data for an invalid map ID", mapID);
	end
end

setmetatable(WorldMapSize, zeroData); -- setup the metatable so that invalid map IDs don't cause Lua errors

-- register this library with AstrolabeMapMonitor, this will cause a full update if PLAYER_LOGIN has already fired
local AstrolabeMapMonitor = DongleStub("AstrolabeMapMonitor");
AstrolabeMapMonitor:RegisterAstrolabeLibrary(Astrolabe, LIBRARY_VERSION_MAJOR);

