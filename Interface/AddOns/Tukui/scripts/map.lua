if not TukuiDB["map"].enable == true then return end
if IsAddOnLoaded("Mapster") then return end

if TukuiDB.lowversion then
	WORLDMAP_RATIO_MINI = 0.56
else
	WORLDMAP_RATIO_MINI = 0.64
end
WORLDMAP_WINDOWED_SIZE = WORLDMAP_RATIO_MINI -- for a smooth transition 3.3.2 to 3.3.3

local dummy = function() end
local Kill = function(object)
	object.Show = dummy
	object:Hide()
end

local glowt = "Interface\\AddOns\\Tukui\\media\\glowTex"
local ft = "Fonts\\skurri.ttf" -- Map font
local fontsize = 18 -- Map Font Size
local mapbg = CreateFrame ("Frame", nil, WorldMapDetailFrame)
	mapbg:SetBackdrop( { 
	bgFile = TukuiDB["media"].blank, 
	edgeFile = TukuiDB["media"].blank, 
	tile = false, edgeSize = TukuiDB.mult, 
	insets = { left = -TukuiDB.mult, right = -TukuiDB.mult, top = -TukuiDB.mult, bottom = -TukuiDB.mult }
})

local movebutton = CreateFrame ("Frame", nil, WorldMapFrameSizeUpButton)
movebutton:SetHeight(TukuiDB:Scale(32))
movebutton:SetWidth(TukuiDB:Scale(32))
movebutton:SetPoint("TOP", WorldMapFrameSizeUpButton, "BOTTOM", TukuiDB:Scale(-1), TukuiDB:Scale(4))
movebutton:SetBackdrop( { 
	bgFile = "Interface\\AddOns\\Tukui\\media\\cross",
})

local addon = CreateFrame('Frame')
addon:RegisterEvent('PLAYER_LOGIN')
addon:RegisterEvent("PARTY_MEMBERS_CHANGED")
addon:RegisterEvent("RAID_ROSTER_UPDATE")
addon:RegisterEvent("PLAYER_REGEN_ENABLED")
addon:RegisterEvent("PLAYER_REGEN_DISABLED")

-- because smallmap > bigmap by far
local SmallerMap = GetCVarBool("miniWorldMap")
if SmallerMap == nil then
	SetCVar("miniWorldMap", 1);
end

-- look if map is not locked
local MoveMap = GetCVarBool("advancedWorldMap")
if MoveMap == nil then
	SetCVar("advancedWorldMap", 1)
end

local SmallerMapSkin = function()
	-- because it cause "action failed" when rescaling smaller map ...
	Kill(WorldMapBlobFrame)
	
	-- new frame to put zone and title text in
	local ald = CreateFrame ("Frame", nil, WorldMapButton)
	ald:SetFrameStrata("TOOLTIP")

	-- map glow
	local fb1 = CreateFrame("Frame", nil, mapbg )
	fb1:SetFrameLevel(0)
	fb1:SetFrameStrata("BACKGROUND")
	fb1:SetPoint("TOPLEFT", mapbg , "TOPLEFT", TukuiDB:Scale(-3), TukuiDB:Scale(3))
	fb1:SetPoint("BOTTOMRIGHT", mapbg , "BOTTOMRIGHT", TukuiDB:Scale(3), TukuiDB:Scale(-3))
	fb1:SetBackdrop {edgeFile = glowt, edgeSize = 3, insets = {left = 0, right = 0, top = 0, bottom = 0}}
	fb1:SetBackdropBorderColor(unpack(TukuiDB["media"].backdropcolor))
	
	-- map border and bg
	mapbg:SetBackdropColor(unpack(TukuiDB["media"].backdropcolor))
	mapbg:SetBackdropBorderColor(unpack(TukuiDB["media"].bordercolor))
	mapbg:SetScale(1 / WORLDMAP_RATIO_MINI)
	mapbg:SetPoint("TOPLEFT", WorldMapDetailFrame, TukuiDB:Scale(-2), TukuiDB:Scale(2))
	mapbg:SetPoint("BOTTOMRIGHT", WorldMapDetailFrame, TukuiDB:Scale(2), TukuiDB:Scale(-2))
	mapbg:SetFrameStrata("MEDIUM")
	mapbg:SetFrameLevel(20)
	
	-- move buttons / texts and hide default border
	WorldMapButton:SetAllPoints(WorldMapDetailFrame)
	WorldMapFrame:SetFrameStrata("MEDIUM")
	WorldMapFrame:SetClampedToScreen(true) 
	WorldMapDetailFrame:SetFrameStrata("MEDIUM")
	WorldMapTitleButton:Show()	
	WorldMapFrameMiniBorderLeft:Hide()
	WorldMapFrameMiniBorderRight:Hide()
	WorldMapFrameSizeUpButton:Show()
	WorldMapFrameSizeUpButton:ClearAllPoints()
	WorldMapFrameSizeUpButton:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT", TukuiDB:Scale(3), TukuiDB:Scale(-18))
	WorldMapFrameSizeUpButton:SetFrameStrata("HIGH")
	WorldMapFrameCloseButton:ClearAllPoints()
	WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT", TukuiDB:Scale(3), TukuiDB:Scale(3))
	WorldMapFrameCloseButton:SetFrameStrata("HIGH")
	WorldMapFrameSizeDownButton:SetPoint("TOPRIGHT", WorldMapFrameMiniBorderRight, "TOPRIGHT", TukuiDB:Scale(-66), TukuiDB:Scale(5))
	WorldMapQuestShowObjectives:SetParent(ald)
	WorldMapQuestShowObjectives:ClearAllPoints()
	WorldMapQuestShowObjectives:SetPoint("BOTTOMRIGHT", WorldMapButton, "BOTTOMRIGHT", 0, TukuiDB:Scale(-1))
	WorldMapQuestShowObjectivesText:SetFont(ft, fontsize, "OUTLINE")
	WorldMapQuestShowObjectivesText:ClearAllPoints()
	WorldMapQuestShowObjectivesText:SetPoint("RIGHT", WorldMapQuestShowObjectives, "LEFT", TukuiDB:Scale(-4), TukuiDB:Scale(1))
	WorldMapFrameTitle:ClearAllPoints()
	WorldMapFrameTitle:SetPoint("BOTTOMLEFT", WorldMapDetailFrame, TukuiDB:Scale(9), TukuiDB:Scale(5));
	WorldMapFrameTitle:SetFont(ft, fontsize, "OUTLINE")
	WorldMapFrameTitle:SetParent(ald)		
	WorldMapTitleButton:SetFrameStrata("TOOLTIP")
	WorldMapTooltip:SetFrameStrata("TOOLTIP")
	
	-- 3.3.3, hide the dropdown added into this patch
	WorldMapLevelDropDown:SetAlpha(0)
	WorldMapLevelDropDown:SetScale(0.0001)

	-- fix tooltip not hidding after leaving quest # tracker icon
	WorldMapQuestPOI_OnLeave = function()
		WorldMapTooltip:Hide()
	end
end
hooksecurefunc("WorldMap_ToggleSizeDown", function() SmallerMapSkin() end)

local BiggerMapSkin = function()
	-- 3.3.3, show the dropdown added into this patch
	WorldMapLevelDropDown:SetAlpha(1)
	WorldMapLevelDropDown:SetScale(1)
end
hooksecurefunc("WorldMap_ToggleSizeUp", function() BiggerMapSkin() end)

local function OnMouseDown()
	WorldMapScreenAnchor:ClearAllPoints();
	WorldMapFrame:ClearAllPoints();
	WorldMapFrame:StartMoving(); 
end

local function OnMouseUp()
	WorldMapFrame:StopMovingOrSizing();
	WorldMapScreenAnchor:StartMoving();
	WorldMapScreenAnchor:SetPoint("TOPLEFT", WorldMapFrame);
	WorldMapScreenAnchor:StopMovingOrSizing();
end

movebutton:EnableMouse(true)
movebutton:SetScript("OnMouseDown", OnMouseDown)
movebutton:SetScript("OnMouseUp", OnMouseUp)

-- the classcolor function
local function UpdateIconColor(self, t)
	color = RAID_CLASS_COLORS[select(2, UnitClass(self.unit))]
	self.icon:SetVertexColor(color.r, color.g, color.b)
end

local OnEvent = function()
	-- fixing a stupid bug error by blizzard on default ui :x
	if event == "PLAYER_REGEN_DISABLED" then
		WorldMapFrameSizeDownButton:Disable() 
		WorldMapFrameSizeUpButton:Disable()
	elseif event == "PLAYER_REGEN_ENABLED" then
		WorldMapFrameSizeDownButton:Enable()
		WorldMapFrameSizeUpButton:Enable()
	else
		for r=1, 40 do
			if UnitInParty(_G["WorldMapRaid"..r].unit) then
				_G["WorldMapRaid"..r].icon:SetTexture("Interface\\AddOns\\Tukui\\media\\Party")
			else
				_G["WorldMapRaid"..r].icon:SetTexture("Interface\\AddOns\\Tukui\\media\\Raid")
			end
			_G["WorldMapRaid"..r]:SetScript("OnUpdate", UpdateIconColor)
		end

		for p=1, 4 do
			_G["WorldMapParty"..p].icon:SetTexture("Interface\\AddOns\\Tukui\\media\\Party")
			_G["WorldMapParty"..p]:SetScript("OnUpdate", UpdateIconColor)
		end
	end
end
addon:SetScript("OnEvent", OnEvent)

