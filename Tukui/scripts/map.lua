if not TukuiCF["map"].enable == true then return end

local mapscale = WORLDMAP_WINDOWED_SIZE

local glowt = TukuiCF["media"].glowTex
local ft = TukuiCF["media"].uffont -- Map font
local fontsize = 18 -- Map Font Size

local mapbg = CreateFrame("Frame", nil, WorldMapDetailFrame)
	mapbg:SetBackdrop( { 
	bgFile = TukuiCF["media"].blank, 
	edgeFile = TukuiCF["media"].blank, 
	tile = false, edgeSize = TukuiDB.mult, 
	insets = { left = -TukuiDB.mult, right = -TukuiDB.mult, top = -TukuiDB.mult, bottom = -TukuiDB.mult }
})

local movebutton = CreateFrame ("Frame", nil, WorldMapFrameSizeUpButton)
movebutton:SetHeight(TukuiDB.Scale(32))
movebutton:SetWidth(TukuiDB.Scale(32))
movebutton:SetPoint("TOP", WorldMapFrameSizeUpButton, "BOTTOM", TukuiDB.Scale(-1), TukuiDB.Scale(4))
movebutton:SetBackdrop( { 
	bgFile = "Interface\\AddOns\\Tukui\\media\\textures\\cross",
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
	TukuiDB.Kill(WorldMapBlobFrame)
	
	-- don't need this
	TukuiDB.Kill(WorldMapTrackQuest)
	
	-- new frame to put zone and title text in
	local ald = CreateFrame ("Frame", nil, WorldMapButton)
	ald:SetFrameStrata("HIGH")
	ald:SetFrameLevel(0)

	-- map glow
	local fb1 = CreateFrame("Frame", nil, mapbg )
	fb1:SetFrameLevel(0)
	fb1:SetFrameStrata("BACKGROUND")
	fb1:SetPoint("TOPLEFT", mapbg , "TOPLEFT", TukuiDB.Scale(-3), TukuiDB.Scale(3))
	fb1:SetPoint("BOTTOMRIGHT", mapbg , "BOTTOMRIGHT", TukuiDB.Scale(3), TukuiDB.Scale(-3))
	fb1:SetBackdrop {edgeFile = glowt, edgeSize = 3, insets = {left = 0, right = 0, top = 0, bottom = 0}}
	fb1:SetBackdropBorderColor(unpack(TukuiCF["media"].backdropcolor))
	
	-- map border and bg
	mapbg:SetBackdropColor(unpack(TukuiCF["media"].backdropcolor))
	mapbg:SetBackdropBorderColor(unpack(TukuiCF["media"].bordercolor))
	mapbg:SetScale(1 / mapscale)
	mapbg:SetPoint("TOPLEFT", WorldMapDetailFrame, TukuiDB.Scale(-2), TukuiDB.Scale(2))
	mapbg:SetPoint("BOTTOMRIGHT", WorldMapDetailFrame, TukuiDB.Scale(2), TukuiDB.Scale(-2))
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
	WorldMapFrameSizeUpButton:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT", TukuiDB.Scale(3), TukuiDB.Scale(-18))
	WorldMapFrameSizeUpButton:SetFrameStrata("HIGH")
	WorldMapFrameSizeUpButton:SetFrameLevel(18)
	WorldMapFrameCloseButton:ClearAllPoints()
	WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT", TukuiDB.Scale(3), TukuiDB.Scale(3))
	WorldMapFrameCloseButton:SetFrameStrata("HIGH")
	WorldMapFrameCloseButton:SetFrameLevel(18)
	WorldMapFrameSizeDownButton:SetPoint("TOPRIGHT", WorldMapFrameMiniBorderRight, "TOPRIGHT", TukuiDB.Scale(-66), TukuiDB.Scale(5))
	WorldMapQuestShowObjectives:SetParent(ald)
	WorldMapQuestShowObjectives:ClearAllPoints()
	WorldMapQuestShowObjectives:SetPoint("BOTTOMRIGHT", WorldMapButton, "BOTTOMRIGHT", 0, TukuiDB.Scale(-1))
	WorldMapQuestShowObjectives:SetFrameStrata("HIGH")
	WorldMapQuestShowObjectivesText:SetFont(ft, fontsize, "OUTLINE")
	WorldMapQuestShowObjectivesText:ClearAllPoints()
	WorldMapQuestShowObjectivesText:SetPoint("RIGHT", WorldMapQuestShowObjectives, "LEFT", TukuiDB.Scale(-4), TukuiDB.Scale(1))
	WorldMapFrameTitle:ClearAllPoints()
	WorldMapFrameTitle:SetPoint("BOTTOMLEFT", WorldMapDetailFrame, TukuiDB.Scale(9), TukuiDB.Scale(5))
	WorldMapFrameTitle:SetFont(ft, fontsize, "OUTLINE")
	WorldMapFrameTitle:SetParent(ald)		
	WorldMapTitleButton:SetFrameStrata("MEDIUM")
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
	TukuiDB.Kill(BlackoutWorld)
end
hooksecurefunc("WorldMap_ToggleSizeUp", function() BiggerMapSkin() end)

local function OnMouseDown()
	local maplock = GetCVar("advancedWorldMap")
	if maplock ~= "1" then return end
	WorldMapScreenAnchor:ClearAllPoints();
	WorldMapFrame:ClearAllPoints();
	WorldMapFrame:StartMoving(); 
end

local function OnMouseUp()
	local maplock = GetCVar("advancedWorldMap")
	if maplock ~= "1" then return end
	WorldMapFrame:StopMovingOrSizing();
	WorldMapScreenAnchor:StartMoving();
	WorldMapScreenAnchor:SetPoint("TOPLEFT", WorldMapFrame);
	WorldMapScreenAnchor:StopMovingOrSizing();
end

movebutton:EnableMouse(true)
movebutton:SetScript("OnMouseDown", OnMouseDown)
movebutton:SetScript("OnMouseUp", OnMouseUp)

-- the classcolor function
local function UpdateIconColor(self)
	if not self.unit then return end -- it seem sometime self.unit is not found causing lua error. idn why but anyway.
	local color = RAID_CLASS_COLORS[select(2, UnitClass(self.unit))]
	if not color then return end -- sometime color return nil
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
	elseif event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
		for r=1, 40 do
			if not _G["WorldMapRaid"..r] then return end
			if UnitInParty(_G["WorldMapRaid"..r].unit) then
				_G["WorldMapRaid"..r].icon:SetTexture("Interface\\AddOns\\Tukui\\media\\textures\\Party")
			else
				_G["WorldMapRaid"..r].icon:SetTexture("Interface\\AddOns\\Tukui\\media\\textures\\Raid")
			end
			_G["WorldMapRaid"..r]:SetScript("OnUpdate", UpdateIconColor)
		end

		for p=1, 4 do
			if not _G["WorldMapParty"..p] then return end
			_G["WorldMapParty"..p].icon:SetTexture("Interface\\AddOns\\Tukui\\media\\textures\\Party")
			_G["WorldMapParty"..p]:SetScript("OnUpdate", UpdateIconColor)
		end
	end
end
addon:SetScript("OnEvent", OnEvent)

-- BG TINY MAP (BG, mining, etc)
local tinymap = CreateFrame("frame", "TukuiTinyMapMover", UIParent)
tinymap:SetPoint("CENTER")
tinymap:SetSize(223, 150)
tinymap:EnableMouse(true)
tinymap:SetMovable(true)
tinymap:RegisterEvent("ADDON_LOADED")
tinymap:SetPoint("CENTER", UIParent, 0, 0)
tinymap:SetFrameLevel(20)
tinymap:Hide()

-- create minimap background
local tinymapbg = CreateFrame("Frame", nil, tinymap)
tinymapbg:SetAllPoints()
tinymapbg:SetFrameLevel(8)
TukuiDB.SetTemplate(tinymapbg)

tinymap:SetScript("OnEvent", function(self, event, addon)
	if addon ~= "Blizzard_BattlefieldMinimap" then return end
		
	-- show holder
	self:Show()

	BattlefieldMinimap:SetScript("OnShow", function()
		TukuiDB.Kill(BattlefieldMinimapCorner)
		TukuiDB.Kill(BattlefieldMinimapBackground)
		TukuiDB.Kill(BattlefieldMinimapTab)
		TukuiDB.Kill(BattlefieldMinimapTabLeft)
		TukuiDB.Kill(BattlefieldMinimapTabMiddle)
		TukuiDB.Kill(BattlefieldMinimapTabRight)
		BattlefieldMinimap:SetParent(self)
		BattlefieldMinimap:SetPoint("TOPLEFT", self, "TOPLEFT", 2, -2)
		BattlefieldMinimap:SetFrameStrata(self:GetFrameStrata())
		BattlefieldMinimap:SetFrameLevel(self:GetFrameLevel() + 1)
		BattlefieldMinimapCloseButton:ClearAllPoints()
		BattlefieldMinimapCloseButton:SetPoint("TOPRIGHT", -4, 0)
		BattlefieldMinimapCloseButton:SetFrameLevel(self:GetFrameLevel() + 1)
		self:SetScale(1)
		self:SetAlpha(1)
	end)
	
	BattlefieldMinimap:SetScript("OnHide", function()
		self:SetScale(0.00001)
		self:SetAlpha(0)
	end)
	
	self:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" then
			self:StopMovingOrSizing()
		elseif btn == "RightButton" then
			ToggleDropDownMenu(1, nil, BattlefieldMinimapTabDropDown, this:GetName(), 0, -4)
		end
	end)
	
	self:SetScript("OnMouseDown", function(self, btn)
		if btn == "LeftButton" then
			if BattlefieldMinimapOptions.locked then
				return
			else
				self:StartMoving()
			end
		end
	end)
end)

