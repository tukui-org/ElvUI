-- by AlleyCat
-- http://www.tukui.org/forum/viewtopic.php?f=17&t=1340&p=7503#p7503

-- credit
-- Mapster (Nevcairiel), pMap (p3lim), m_Map (Monolit)

if not TukuiMap == true or (IsAddOnLoaded("Mapster")) then return end

  -- Settings here
 local smallmapposposition = {x = 0, y = 0, point = "CENTER"} -- Small Map Spawn Position
 local mapscale = 0.8 -- Choose Map Scale
 local mapalpha = 1 -- Optimal Value
 local ft = "Fonts\\skurri.ttf" -- Map font
 local fontsize = 18 -- Map Font Size
 ---------------------
 -- Stttings End --
  local blanke = BLANK_TEXTURE
  local glowt = "Interface\\AddOns\\Tukui\\media\\glowTex"
  local movebutton = CreateFrame ("Frame",nil,WorldMapFrameSizeUpButton)
  movebutton:SetHeight(32)
  movebutton:SetWidth(32)
  movebutton:SetPoint("TOP",WorldMapFrameSizeUpButton,"BOTTOM",-1,4)
  movebutton:SetBackdrop( { 
	  bgFile = "Interface\\AddOns\\Tukui\\media\\cross",})
	WORLDMAP_RATIO_MINI=1
 local qfix = 0
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
	mapbg:SetScale (1/mapscale)
	mapbgfix:SetScale (1/mapscale)
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
	WorldMapButton:SetAllPoints(WorldMapDetailFrame)
	WorldMapDetailFrame:ClearAllPoints()
	WorldMapDetailFrame:SetPoint(smallmapposposition.point,UIParent,smallmapposposition.point,smallmapposposition.x,smallmapposposition.y)
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
	movebutton:SetFrameStrata("HIGH")
	mapbg:SetPoint("BOTTOMRIGHT", WorldMapDetailFrame, 1, -1)
	mapbg:SetPoint("TOPLEFT", WorldMapDetailFrame, -1, 1)
	mapbgfix:SetPoint("TOPLEFT", WorldMapDetailFrame, 0, 0)
	mapbgfix:SetPoint("BOTTOMRIGHT", WorldMapDetailFrame, 0, 0)
end
WorldMapDetailFrame:SetMovable(true)
local qs = 0
local function OnMouseDown()
	WorldMapDetailFrame:StartMoving()
	WorldMapDetailFrame.moving = true
	qs=1
end
local function OnMouseUp()
	WorldMapDetailFrame:StopMovingOrSizing()
	WorldMapDetailFrame.moving = nil
	qs=0
	qfix=1
end
hooksecurefunc("WorldMap_ToggleSizeDown", function() MapShrink() end)
movebutton:EnableMouse(true)
movebutton:SetScript("OnMouseDown",OnMouseDown)
movebutton:SetScript("OnMouseUp",OnMouseUp)
local function CreateText(offset)
	local text = WorldMapButton:CreateFontString(nil, 'ARTWORK')
	text:SetPoint('TOPLEFT', WorldMapDetailFrame, 7 , offset)
	text:SetFontObject('GameFontNormal')
	text:SetFont (ft,fontsize,"LINE")
	text:SetJustifyH('LEFT')
	return text
end
function MouseXY()
	local left, top = WorldMapDetailFrame:GetLeft(), WorldMapDetailFrame:GetTop()
	local width, height = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()
	local scale = WorldMapDetailFrame:GetEffectiveScale()
	local x, y = GetCursorPosition()
	local cx = (x/scale - left) / width
	local cy = (top - y/scale) / height
	if cx < 0 or cx > 1 or cy < 0 or cy > 1 then
	return
	end
	return cx, cy
end
local shown = 0
local function OnUpdate(player, cursor)
	if shown == 1 then
	if ( WatchFrame.showObjectives ) and qs == 1 then
	WorldMapFrame_UpdateQuests()
	end
	if ( WatchFrame.showObjectives ) and qfix == 1 then
	WorldMapFrame_UpdateQuests() qfix=0 end
	if InCombatLockdown() then	WorldMapFrameSizeDownButton:Disable() 
								WorldMapFrameSizeUpButton:Disable()	end
	if not InCombatLockdown() then 
								WorldMapFrameSizeDownButton:Enable()
								WorldMapFrameSizeUpButton:Enable() end
	local cx, cy = MouseXY()
	local px, py = GetPlayerMapPosition("player")

	if cx then
		cursor:SetFormattedText('Cursor : %.2d , %.2d', 100 * cx, 100 * cy)
	else
		cursor:SetText("")
	end

	if px == 0 then
		player:SetText("")
	else
		player:SetFormattedText(UnitName("player")..' : %.2d , %.2d', 100 * px, 100 * py)
	end else return end
end
local function OnEvent(self)
		local player = CreateText(-3)
		local cursor = CreateText((fontsize+5)*(-1))
		local elapsed = 0

		self:SetScript('OnUpdate', function(self, u)
			elapsed = elapsed + u
			if(elapsed > 0.1) then
				OnUpdate(player, cursor)
				elapsed = 0
			end
		end)
end
local addon = CreateFrame('Frame')
addon:SetScript('OnEvent', OnEvent)
addon:RegisterEvent('PLAYER_LOGIN')
 BlackoutWorld:Hide()
 WorldMapFrame:EnableKeyboard(false)
 WorldMapFrame:EnableMouse(false)
 WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
 WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
 UIPanelWindows["WorldMapFrame"] = {area = "center"}
BlackoutWorld.Show = function() UIPanelWindows["WorldMapFrame"] = {area = "center"}
WorldMapFrame:EnableKeyboard(false)
WorldMapFrame:EnableMouse(false)
WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
 end
 WorldMapFrame:HookScript("OnShow", function(self) self:SetScale(mapscale) self:SetAlpha(mapalpha) WorldMapTooltip:SetScale(1/mapscale) shown = 1 qfix = 1 end)
 WorldMapFrame:HookScript("OnHide", function(self) shown = 0 WorldMapFrame_UpdateQuests() end)
corl = function() 
WorldMapQuestShowObjectives:SetParent(WorldMapPositioningGuide)
WorldMapQuestShowObjectives:ClearAllPoints()
WorldMapQuestShowObjectives:SetPoint("BOTTOMRIGHT",WorldMapPositioningGuide,"BOTTOMRIGHT",-6, 5)
end
hooksecurefunc("WorldMap_ToggleSizeUp", corl)