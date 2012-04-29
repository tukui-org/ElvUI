local E, L, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.global.skins.blizzard.enable ~= true or E.global.skins.blizzard.worldmap ~= true then return end
	
	S:HandleScrollBar(WorldMapQuestScrollFrameScrollBar)
	S:HandleScrollBar(WorldMapQuestDetailScrollFrameScrollBar, 4)
	S:HandleScrollBar(WorldMapQuestRewardScrollFrameScrollBar, 4)
	
	WorldMapFrame:CreateBackdrop("Transparent")
	WorldMapDetailFrame.backdrop = CreateFrame("Frame", nil, WorldMapFrame)
	WorldMapDetailFrame.backdrop:SetTemplate("Default")
	WorldMapDetailFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -2, 2)
	WorldMapDetailFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 2, -2)
	WorldMapDetailFrame.backdrop:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel() - 2)

	S:HandleCloseButton(WorldMapFrameCloseButton)
	S:HandleCloseButton(WorldMapFrameSizeDownButton, nil, '-')
	S:HandleCloseButton(WorldMapFrameSizeUpButton, nil, '+')
							
	S:HandleDropDownBox(WorldMapLevelDropDown)
	S:HandleDropDownBox(WorldMapZoneMinimapDropDown)
	S:HandleDropDownBox(WorldMapContinentDropDown)
	S:HandleDropDownBox(WorldMapZoneDropDown)
	
	S:HandleDropDownBox(WorldMapShowDropDown)

	S:HandleButton(WorldMapZoomOutButton)
	
	S:HandleCheckBox(WorldMapTrackQuest)
	S:HandleCheckBox(WorldMapQuestShowObjectives)
	S:HandleCheckBox(WorldMapShowDigSites)
	
	--Mini
	local function SmallSkin()
		WorldMapFrame.backdrop:ClearAllPoints()
		WorldMapFrame.backdrop:Point("TOPLEFT", 2, 2)
		WorldMapFrame.backdrop:Point("BOTTOMRIGHT", 2, -2)
	end
	
	--Large
	local function LargeSkin()
		WorldMapFrame.backdrop:ClearAllPoints()
		WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -25, 70)
		WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 25, -30)    
	end
	
	local function QuestSkin()
		WorldMapFrame.backdrop:ClearAllPoints()
		WorldMapFrame.backdrop:Point("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -25, 70)
		WorldMapFrame.backdrop:Point("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", 325, -235)  
		
		if not WorldMapQuestDetailScrollFrame.backdrop then
			WorldMapQuestDetailScrollFrame:CreateBackdrop("Default")
			WorldMapQuestDetailScrollFrame.backdrop:Point("TOPLEFT", -22, 2)
			WorldMapQuestDetailScrollFrame.backdrop:Point("BOTTOMRIGHT", 23, -4)
		end
		
		if not WorldMapQuestRewardScrollFrame.backdrop then
			WorldMapQuestRewardScrollFrame:CreateBackdrop("Default")
			WorldMapQuestRewardScrollFrame.backdrop:Point("BOTTOMRIGHT", 22, -4)				
		end
		
		if not WorldMapQuestScrollFrame.backdrop then
			WorldMapQuestScrollFrame:CreateBackdrop("Default")
			WorldMapQuestScrollFrame.backdrop:Point("TOPLEFT", 0, 2)
			WorldMapQuestScrollFrame.backdrop:Point("BOTTOMRIGHT", 25, -3)				
		end
	end			
	
	local function FixSkin()
		WorldMapFrame:StripTextures()
		if not E.db.general.tinyWorldMap then
			BlackoutWorld:SetTexture(0, 0, 0, 1)
		end
		
		if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
			LargeSkin()
		elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
			SmallSkin()
		elseif WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
			QuestSkin()
		end
		
		WorldMapFrameAreaLabel:FontTemplate(nil, 50, "OUTLINE")
		WorldMapFrameAreaLabel:SetShadowOffset(2, -2)
		WorldMapFrameAreaLabel:SetTextColor(0.90, 0.8294, 0.6407)	
		
		WorldMapFrameAreaDescription:FontTemplate(nil, 40, "OUTLINE")
		WorldMapFrameAreaDescription:SetShadowOffset(2, -2)	
		
		WorldMapZoneInfo:FontTemplate(nil, 27, "OUTLINE")
		WorldMapZoneInfo:SetShadowOffset(2, -2)		
		WorldMapFrame:SetFrameLevel(3)
		WorldMapDetailFrame:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 1)
		WorldMapFrame:SetFrameStrata('HIGH')			
	end
	
	WorldMapFrame:HookScript("OnShow", FixSkin)
	hooksecurefunc("WorldMapFrame_SetFullMapView", LargeSkin)
	hooksecurefunc("WorldMapFrame_SetQuestMapView", QuestSkin)
	hooksecurefunc("WorldMap_ToggleSizeUp", FixSkin)
	BlackoutWorld:SetParent(WorldMapFrame.backdrop)
end

S:RegisterSkin('ElvUI', LoadSkin)