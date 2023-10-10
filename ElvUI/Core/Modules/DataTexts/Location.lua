local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local _G = _G
local GetZonePVPInfo = GetZonePVPInfo
local IsInInstance = IsInInstance
local ToggleFrame = ToggleFrame

local NOT_APPLICABLE = NOT_APPLICABLE

local mapInfo = E.MapInfo

local colors = { -- pulled from Blizz's ZoneText.lua
	none		= {r = 1, g = 1, b = 0},
	arena		= {r = 1.0, g = 0.1, b = 0.1},
	combat		= {r = 1.0, g = 0.1, b = 0.1},
	contested	= {r = 1.0, g = 0.7, b = 0.1},
	friendly	= {r = 0.1, g = 1.0, b = 0.1},
	hostile		= {r = 1.0, g = 0.1, b = 0.1},
	instance	= {r = 1.0, g = 0.1, b = 0.1},
	sanctuary	= {r = 0.4, g = 0.8, b = 0.9},
}

local function GetStatus()
	return IsInInstance() and colors.instance or colors[GetZonePVPInfo()] or colors.none
end

local function OnEvent(self)
	if not mapInfo.mapID then
		self.text:SetText(NOT_APPLICABLE)
		return
	end

	local db = E.global.datatexts.settings.Location
	local color = db.color == 'REACTION' and GetStatus() or db.color == 'CLASS' and E:ClassColor(E.myclass) or db.customColor

	local continent = db.showContinent and mapInfo.continentName or ''
	local subzone = db.showSubZone and mapInfo.subZoneText or ''
	local zone = db.showZone and ((mapInfo.subZoneText == mapInfo.zoneText and mapInfo.realZoneText) or mapInfo.zoneText) or ''

	if zone ~= '' or subzone ~= '' or continent ~= '' then
		local first = continent ~= '' and zone ~= '' and ': ' or ''
		local second = (zone ~= '' or continent ~= '') and subzone ~= '' and ': ' or ''

		self.text:SetFormattedText('%s%s%s%s%s%s|r', E:RGBToHex(color.r, color.g, color.b), continent, first, zone, second, subzone)
	else
		self.text:SetText(NOT_APPLICABLE)
	end
end

local function OnClick()
	if not E:AlertCombat() then
		ToggleFrame(_G.WorldMapFrame)
	end
end

DT:RegisterDatatext('Location', nil, { 'LOADING_SCREEN_DISABLED', 'ZONE_CHANGED_NEW_AREA', 'ZONE_CHANGED_INDOORS', 'ZONE_CHANGED' }, OnEvent, nil, OnClick, nil, nil, L["Location"])
