-- http://www.tukui.org/forum/viewtopic.php?f=17&t=1340&p=7503#p7503
-- credit : Mapster (Nevcairiel), pMap (p3lim), m_Map (Monolit)

local blanke = BLANK_TEXTURE
local glowt = "Interface\\AddOns\\Tukui\\media\\glowTex"
local ft = "Fonts\\skurri.ttf" -- Map font
local fontsize = 18 -- Map Font Size

local addon = CreateFrame('Frame')
addon:RegisterEvent('PLAYER_LOGIN')
addon:RegisterEvent("PARTY_MEMBERS_CHANGED")
addon:RegisterEvent("RAID_ROSTER_UPDATE")
addon:RegisterEvent("WORLD_MAP_UPDATE")

-- because smallmap > bigmap by far
local mapminionlogin = GetCVarBool("miniWorldMap")
if mapminionlogin == nil then
	SetCVar("miniWorldMap", 1);
end

function MapShrink()
	local ald = CreateFrame ("Frame",nil,WorldMapButton)
	ald:SetFrameStrata("TOOLTIP")
    local mapbg = CreateFrame ("Frame",nil, WorldMapDetailFrame)
		mapbg:SetBackdrop( { 
		bgFile = blanke, 
		edgeFile = blanke, 
		tile = false, edgeSize = 1, 
		insets = { left = -1, right = -1, top = -1, bottom = -1 }
	})
	local mapbgfix = CreateFrame ("Frame",nil, WorldMapDetailFrame)
		mapbgfix:SetBackdrop( {  
		edgeFile = blanke, 
		tile = false, edgeSize = 1, 
		insets = { left = -1, right = -1, top = -1, bottom = -1 }
	})
	mapbgfix:SetFrameLevel(0)
	local fb1 = CreateFrame("Frame", nil, mapbg )
	fb1:SetFrameLevel(0)
	fb1:SetFrameStrata("BACKGROUND")
	fb1:SetPoint("TOPLEFT", mapbg , "TOPLEFT", -3.4, 3.4)
	fb1:SetPoint("BOTTOMRIGHT", mapbg , "BOTTOMRIGHT", 3.2, -3.4)
	fb1:SetBackdrop {edgeFile = glowt, edgeSize = 3,
		insets = {left = 0, right = 0, top = 0, bottom = 0}}
	fb1:SetBackdropBorderColor(0.1, 0.1, 0.1,1)
	mapbgfix:SetBackdropBorderColor(0/255,15/255,26/255,0.7)
	mapbg:SetBackdropColor(unpack(TUKUI_BACKDROP_COLOR))
	mapbg:SetBackdropBorderColor(unpack(TUKUI_BORDER_COLOR))
	mapbg:SetScale(1/WORLDMAP_RATIO_SMALL)
	WorldMapButton:SetAllPoints(WorldMapDetailFrame)
	WorldMapFrame:SetFrameStrata("MEDIUM")
	WorldMapDetailFrame:SetFrameStrata("MEDIUM")
	mapbg:SetFrameStrata("LOW")	
	mapbgfix:SetFrameStrata("HIGH")
	WorldMapTitleButton:Show()
	WorldMapFrameMiniBorderLeft:Hide()
	WorldMapFrameMiniBorderRight:Hide()
	WorldMapFrameSizeUpButton:Show()
	WorldMapFrameSizeUpButton:ClearAllPoints()
	WorldMapFrameSizeUpButton:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT",3,-18)
	WorldMapFrameSizeUpButton:SetFrameStrata("HIGH")
	WorldMapFrameCloseButton:ClearAllPoints()
	WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT",3,3)
	WorldMapFrameCloseButton:SetFrameStrata("HIGH")
	WorldMapFrameSizeDownButton:SetPoint("TOPRIGHT", WorldMapFrameMiniBorderRight, "TOPRIGHT", -66, 5)
	WorldMapFrameTitle:ClearAllPoints()
	WorldMapFrameTitle:SetPoint("BOTTOMLEFT", WorldMapDetailFrame, 9, 5);
	WorldMapFrameTitle:SetFont(ft,fontsize,"LINE")
	WorldMapFrameTitle:SetParent(ald)
	WorldMapQuestShowObjectives:SetParent(ald)
	WorldMapQuestShowObjectives:ClearAllPoints()
	WorldMapQuestShowObjectives:SetPoint("BOTTOMRIGHT",WorldMapButton,"BOTTOMRIGHT", 0, -1)
	WorldMapQuestShowObjectivesText:SetFont(ft,fontsize,"LINE")
	WorldMapQuestShowObjectivesText:ClearAllPoints()
	WorldMapQuestShowObjectivesText:SetPoint("RIGHT",WorldMapQuestShowObjectives,"LEFT",-4,1)
	WorldMapTitleButton:SetFrameStrata("TOOLTIP")
	WorldMapTooltip:SetFrameStrata("TOOLTIP")
	mapbg:SetPoint("BOTTOMRIGHT", WorldMapDetailFrame, 1, -1)
	mapbg:SetPoint("TOPLEFT", WorldMapDetailFrame, -1, 1)
	mapbgfix:SetPoint("TOPLEFT", WorldMapDetailFrame, 0, 0)
	mapbgfix:SetPoint("BOTTOMRIGHT", WorldMapDetailFrame, 0, 0)
end
hooksecurefunc("WorldMap_ToggleSizeDown", function() MapShrink() end)

local function UpdateIconColor(self, t)
	color = RAID_CLASS_COLORS[select(2, UnitClass(self.unit))]
	self.icon:SetVertexColor(color.r, color.g, color.b)
end

function UpdateParty()
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
addon:SetScript("OnEvent", UpdateParty)