local E, _, V, P, G = unpack(ElvUI) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local WM = E:GetModule('WorldMap')
local MM = E:GetModule('Minimap')
local ACH = E.Libs.ACH

local _G = _G
local pairs = pairs
-- GLOBALS: WORLD_MAP_MIN_ALPHA

local buttonPositions = {
	LEFT = L["Left"],
	RIGHT = L["Right"],
	TOP = L["Top"],
	BOTTOM = L["Bottom"],
	TOPLEFT = L["Top Left"],
	TOPRIGHT = L["Top Right"],
	BOTTOMLEFT = L["Bottom Left"],
	BOTTOMRIGHT = L["Bottom Right"],
}

local buttonScale = { min = 0.5, max = 2, step = 0.05 }
local buttonOffsets = { min = -60, max = 60, step = 1 }

local Maps = ACH:Group(L["Maps"], nil, 2, 'tab')
E.Options.args.maps = Maps

Maps.args.worldMap = ACH:Group(L["WORLD_MAP"], nil, 1, 'tab')
Maps.args.worldMap.args.enable = ACH:Toggle(L["Enable"], L["Enable/Disable the World Map Enhancements."], 0, nil, nil, nil, function() return E.private.general.worldMap end, function(_, value) E.private.general.worldMap = value; E:StaticPopup_Show("PRIVATE_RL") end)

Maps.args.worldMap.args.generalGroup = ACH:Group(L["General"], nil, 1, nil, function(info) return E.global.general[info[#info]] end, function(info, value) E.global.general[info[#info]] = value end, function() return not E.private.general.worldMap end)
Maps.args.worldMap.args.generalGroup.inline = true
Maps.args.worldMap.args.generalGroup.args.smallerWorldMap = ACH:Toggle(L["Smaller World Map"], L["Make the world map smaller."], 1, nil, nil, nil, nil, function(_, value) E.global.general.smallerWorldMap = value; E:StaticPopup_Show('GLOBAL_RL') end)
Maps.args.worldMap.args.generalGroup.args.smallerWorldMapScale = ACH:Range(L["Smaller World Map Scale"], nil, 2, { min = .5, max = .9, step = .01, isPercent = true }, nil, nil, function(_, value) E.global.general.smallerWorldMapScale = value; E:StaticPopup_Show('GLOBAL_RL') end)

Maps.args.worldMap.args.generalGroup.args.spacer1 = ACH:Spacer(3)
Maps.args.worldMap.args.generalGroup.args.fadeMapWhenMoving = ACH:Toggle(L["MAP_FADE_TEXT"], nil, 4)
Maps.args.worldMap.args.generalGroup.args.mapAlphaWhenMoving = ACH:Range(L["Map Opacity When Moving"], nil, 5, { min = 0, max = 1, step = .01, isPercent = true }, nil, nil, function(_, value) E.global.general.mapAlphaWhenMoving = value; E.WorldMap.UpdateMapFade(_G.WorldMapFrame, E.global.general.mapAlphaWhenMoving, 1.0, E.global.general.fadeMapDuration, E.noop); end) -- we use E.noop to force the update of the minValue here
Maps.args.worldMap.args.generalGroup.args.fadeMapDuration = ACH:Range(L["Fade Duration"], nil, 6, { min = 0, max = 1, step = .01, isPercent = true }, nil, nil, function(_, value) E.global.general.fadeMapDuration = value; E.WorldMap.UpdateMapFade(_G.WorldMapFrame, E.global.general.mapAlphaWhenMoving, 1.0, E.global.general.fadeMapDuration, E.noop); end) -- we use E.noop to force the update of the minValue here

Maps.args.worldMap.args.coordinatesGroup = ACH:Group(L["World Map Coordinates"], nil, 3, nil, function(info) return E.global.general.WorldMapCoordinates[info[#info]] end, function(info, value) E.global.general.WorldMapCoordinates[info[#info]] = value; WM:PositionCoords() end, function() return not E.private.general.worldMap end)
Maps.args.worldMap.args.coordinatesGroup.inline = true
Maps.args.worldMap.args.coordinatesGroup.args.enable = ACH:Toggle(L["Enable"], L["Puts coordinates on the world map."], 1, nil, nil, nil, nil, function(_, value) E.global.general.WorldMapCoordinates.enable = value; E:StaticPopup_Show('GLOBAL_RL') end)
Maps.args.worldMap.args.coordinatesGroup.args.position = ACH:Select(L["Position"], nil, 3, buttonPositions, nil, nil, nil, nil, function() return not E.global.general.WorldMapCoordinates.enable end)
Maps.args.worldMap.args.coordinatesGroup.args.xOffset = ACH:Range(L["X-Offset"], nil, 4, { min = -200, max = 200, step = 1 }, nil, nil, nil, function() return not E.global.general.WorldMapCoordinates.enable end)
Maps.args.worldMap.args.coordinatesGroup.args.yOffset = ACH:Range(L["Y-Offset"], nil, 5, { min = -200, max = 200, step = 1 }, nil, nil, nil, function() return not E.global.general.WorldMapCoordinates.enable end)

Maps.args.minimap = ACH:Group(L["MINIMAP_LABEL"], nil, 2, 'tab', function(info) return E.db.general.minimap[info[#info]] end, function(info, value) E.db.general.minimap[info[#info]] = value; MM:UpdateSettings() end)
Maps.args.minimap.args.generalGroup = ACH:Group(L["General"], nil, 1)
Maps.args.minimap.args.generalGroup.inline = true
Maps.args.minimap.args.generalGroup.args.enable = ACH:Toggle(L["Enable"], L["Enable/Disable the minimap. |cffFF0000Warning: This will prevent you from seeing the minimap datatexts.|r"], 1, nil, nil, nil, function(info) return E.private.general.minimap[info[#info]] end, function(info, value) E.private.general.minimap[info[#info]] = value; E:StaticPopup_Show('PRIVATE_RL') end)
Maps.args.minimap.args.generalGroup.args.size = ACH:Range(L["Size"], L["Adjust the size of the minimap."], 2, { min = 24, max = 500, step = 1 }, nil, nil, nil, function() return not E.private.general.minimap.enable end)

Maps.args.minimap.args.locationTextGroup = ACH:Group(L["Location Text"], nil, 2, nil, function(info) return E.db.general.minimap[info[#info]] end, function(info, value) E.db.general.minimap[info[#info]] = value; MM:UpdateSettings(); MM:Update_ZoneText() end, function() return not E.private.general.minimap.enable end)
Maps.args.minimap.args.locationTextGroup.args.locationText = ACH:Select(L["Location Text"], L["Change settings for the display of the location text that is on the minimap."], 1, { MOUSEOVER = L["Minimap Mouseover"], SHOW = L["Always Display"], HIDE = L["Hide"] })
Maps.args.minimap.args.locationTextGroup.args.locationFont = ACH:SharedMediaFont(L["Font"], nil, 2)
Maps.args.minimap.args.locationTextGroup.args.locationFontSize = ACH:Range(L["FONT_SIZE"], nil, 3, { min = 6, max = 36, step = 1 })
Maps.args.minimap.args.locationTextGroup.args.locationFontOutline = ACH:Select(L["Font Outline"], nil, 4, C.Values.FontFlags)

Maps.args.minimap.args.zoomResetGroup = ACH:Group(L["Reset Zoom"], nil, 3, nil, function(info) return E.db.general.minimap.resetZoom[info[#info]] end, function(info, value) E.db.general.minimap.resetZoom[info[#info]] = value; MM:UpdateSettings() end, function() return not E.private.general.minimap.enable end)
Maps.args.minimap.args.zoomResetGroup.args.enable = ACH:Toggle(L["Reset Zoom"], nil, 1)
Maps.args.minimap.args.zoomResetGroup.args.time =  ACH:Range(L["Seconds"], nil, 2, { min = 1, max = 15, step = 1 })

Maps.args.minimap.args.icons = ACH:Group(L["Minimap Buttons"], nil, 4, nil, function(info) return E.db.general.minimap.icons[info[#info - 1]][info[#info]] end, function(info, value) E.db.general.minimap.icons[info[#info - 1]][info[#info]] = value; MM:UpdateSettings() end, function() return not E.private.general.minimap.enable end)

Maps.args.minimap.args.icons.args.classHall = ACH:Group(L["GARRISON_LANDING_PAGE_TITLE"], nil, 1)
Maps.args.minimap.args.icons.args.classHall.args.hideClassHallReport = ACH:Toggle(L["Hide"], nil, 1, nil, nil, nil, function() return E.private.general.minimap.hideClassHallReport end, function(_, value) E.private.general.minimap.hideClassHallReport = value; MM:UpdateSettings() end)
Maps.args.minimap.args.icons.args.classHall.args.spacer = ACH:Spacer(2, 'full')
Maps.args.minimap.args.icons.args.classHall.args.position = ACH:Select(L["Position"], nil, 3, buttonPositions, nil, nil, nil, nil, function() return E.private.general.minimap.hideClassHallReport end)
Maps.args.minimap.args.icons.args.classHall.args.scale = ACH:Range(L["Scale"], nil, 4, buttonScale, nil, nil, nil, function() return E.private.general.minimap.hideClassHallReport end)
Maps.args.minimap.args.icons.args.classHall.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, buttonOffsets, nil, nil, nil, function() return E.private.general.minimap.hideClassHallReport end)
Maps.args.minimap.args.icons.args.classHall.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, buttonOffsets, nil, nil, nil, function() return E.private.general.minimap.hideClassHallReport end)

Maps.args.minimap.args.icons.args.calendar = ACH:Group(L["Calendar"], nil, 2)
Maps.args.minimap.args.icons.args.calendar.args.hideCalendar = ACH:Toggle(L["Hide"], nil, 1, nil, nil, nil, function() return E.private.general.minimap.hideCalendar end, function(_, value) E.private.general.minimap.hideCalendar = value; MM:UpdateSettings() end)
Maps.args.minimap.args.icons.args.calendar.args.spacer = ACH:Spacer(2, 'full')
Maps.args.minimap.args.icons.args.calendar.args.position = ACH:Select(L["Position"], nil, 3, buttonPositions, nil, nil, nil, nil, function() return E.private.general.minimap.hideCalendar end)
Maps.args.minimap.args.icons.args.calendar.args.scale = ACH:Range(L["Scale"], nil, 4, buttonScale, nil, nil, nil, function() return E.private.general.minimap.hideCalendar end)
Maps.args.minimap.args.icons.args.calendar.args.xOffset = ACH:Range(L["X-Offset"], nil, 5, buttonOffsets, nil, nil, nil, function() return E.private.general.minimap.hideCalendar end)
Maps.args.minimap.args.icons.args.calendar.args.yOffset = ACH:Range(L["Y-Offset"], nil, 6, buttonOffsets, nil, nil, nil, function() return E.private.general.minimap.hideCalendar end)

Maps.args.minimap.args.icons.args.mail = ACH:Group(L["MAIL_LABEL"], nil, 3)
Maps.args.minimap.args.icons.args.mail.args.position = ACH:Select(L["Position"], nil, 1, buttonPositions)
Maps.args.minimap.args.icons.args.mail.args.scale = ACH:Range(L["Scale"], nil, 2, buttonScale)
Maps.args.minimap.args.icons.args.mail.args.xOffset = ACH:Range(L["X-Offset"], nil, 3, buttonOffsets)
Maps.args.minimap.args.icons.args.mail.args.yOffset = ACH:Range(L["Y-Offset"], nil, 4, buttonOffsets)
Maps.args.minimap.args.icons.args.mail.args.texture = ACH:Select(L["Texture"], nil, 5)

do -- mail icons
	local mail = {}
	Maps.args.minimap.args.icons.args.mail.args.texture.values = mail

	for key, icon in pairs(E.Media.MailIcons) do
		mail[key] = E:TextureString(icon, ':14:14')
	end
end

Maps.args.minimap.args.icons.args.lfgEye = ACH:Group(L["LFG Queue"], nil, 4)
Maps.args.minimap.args.icons.args.lfgEye.args.position = ACH:Select(L["Position"], nil, 1, buttonPositions)
Maps.args.minimap.args.icons.args.lfgEye.args.scale = ACH:Range(L["Scale"], nil, 2, buttonScale)
Maps.args.minimap.args.icons.args.lfgEye.args.xOffset = ACH:Range(L["X-Offset"], nil, 3, buttonOffsets)
Maps.args.minimap.args.icons.args.lfgEye.args.yOffset = ACH:Range(L["Y-Offset"], nil, 4, buttonOffsets)

Maps.args.minimap.args.icons.args.difficulty = ACH:Group(L["Instance Difficulty"], nil, 5)
Maps.args.minimap.args.icons.args.difficulty.args.position = ACH:Select(L["Position"], nil, 1, buttonPositions)
Maps.args.minimap.args.icons.args.difficulty.args.scale = ACH:Range(L["Scale"], nil, 2, buttonScale)
Maps.args.minimap.args.icons.args.difficulty.args.xOffset = ACH:Range(L["X-Offset"], nil, 3, buttonOffsets)
Maps.args.minimap.args.icons.args.difficulty.args.yOffset = ACH:Range(L["Y-Offset"], nil, 4, buttonOffsets)

Maps.args.minimap.args.icons.args.challengeMode = ACH:Group(L["CHALLENGE_MODE"], nil, 6)
Maps.args.minimap.args.icons.args.challengeMode.args.position = ACH:Select(L["Position"], nil, 1, buttonPositions)
Maps.args.minimap.args.icons.args.challengeMode.args.scale = ACH:Range(L["Scale"], nil, 2, buttonScale)
Maps.args.minimap.args.icons.args.challengeMode.args.xOffset = ACH:Range(L["X-Offset"], nil, 3, buttonOffsets)
Maps.args.minimap.args.icons.args.challengeMode.args.yOffset = ACH:Range(L["Y-Offset"], nil, 4, buttonOffsets)
