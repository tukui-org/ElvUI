local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true then return end

	local WorldMapFrame = _G["WorldMapFrame"]
	WorldMapFrame:StripTextures()
	WorldMapFrame.BorderFrame:StripTextures()
	WorldMapFrame.BorderFrame:SetFrameStrata(WorldMapFrame:GetFrameStrata())
	WorldMapFrame.NavBar:StripTextures()
	WorldMapFrame.NavBar.overlay:StripTextures()

	WorldMapFrame:CreateBackdrop("Transparent")

	WorldMapFrameHomeButton:StripTextures()
	WorldMapFrameHomeButton:CreateBackdrop("Default", true)
	WorldMapFrameHomeButton.backdrop:SetPoint("TOPLEFT", WorldMapFrameHomeButton, "TOPLEFT", 0, 0)
	WorldMapFrameHomeButton.backdrop:SetPoint("BOTTOMRIGHT", WorldMapFrameHomeButton, "BOTTOMRIGHT", -15, 0)
	WorldMapFrameHomeButton:SetFrameLevel(1)
	WorldMapFrameHomeButton.text:FontTemplate()

	-- Quest Frames
	QuestMapFrame.VerticalSeparator:Hide()

	QuestScrollFrame.DetailFrame:StripTextures()
	QuestScrollFrame.Background:SetAlpha(0)
	QuestScrollFrame.Contents.Separator.Divider:Hide()

	QuestScrollFrame.DetailFrame:CreateBackdrop("Default")
	QuestScrollFrame.DetailFrame.backdrop:Point("TOPLEFT", QuestScrollFrame.DetailFrame, "TOPLEFT", 1, -3)
	QuestScrollFrame.DetailFrame.backdrop:Point("BOTTOMRIGHT", QuestScrollFrame.DetailFrame, "BOTTOMRIGHT", -1, 1)

	S:HandleScrollBar(QuestScrollFrameScrollBar)

	local QuestMapFrame = _G["QuestMapFrame"]
	S:HandleButton(QuestMapFrame.DetailsFrame.BackButton)
	S:HandleButton(QuestMapFrame.DetailsFrame.AbandonButton)
	S:HandleButton(QuestMapFrame.DetailsFrame.ShareButton, true)
	S:HandleButton(QuestMapFrame.DetailsFrame.TrackButton)
	S:HandleButton(QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton, true)

	if E.private.skins.blizzard.tooltip then
		QuestMapFrame.QuestsFrame.StoryTooltip:SetTemplate("Transparent")
		QuestScrollFrame.WarCampaignTooltip:SetTemplate("Transparent")
	end

	QuestMapFrame.DetailsFrame.CompleteQuestFrame:StripTextures()

	S:HandleNextPrevButton(WorldMapFrame.SidePanelToggle.CloseButton, nil, true)
	S:HandleNextPrevButton(WorldMapFrame.SidePanelToggle.OpenButton)

	S:HandleCloseButton(WorldMapFrameCloseButton)
	S:HandleMaxMinFrame(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame)

	if E.global.general.disableTutorialButtons then
		WorldMapFrame.BorderFrame.Tutorial:Kill()
	end

	--S:HandleCloseButton(WorldMapFrame.UIElementsFrame.BountyBoard.TutorialBox.CloseButton)

	--WorldMapFrameAreaLabel:FontTemplate(nil,30)
	--WorldMapFrameAreaLabel:SetShadowOffset(2,-2)
	--WorldMapFrameAreaLabel:SetTextColor(0.9,0.8,0.6)
	--WorldMapFrameAreaDescription:FontTemplate(nil,20)
	--WorldMapFrameAreaDescription:SetShadowOffset(2,-2)
	--WorldMapFrameAreaPetLevels:FontTemplate(nil,20)
	--WorldMapFrameAreaPetLevels:SetShadowOffset(2,-2)
	--WorldMapZoneInfo:FontTemplate(nil,25)
	--WorldMapZoneInfo:SetShadowOffset(2,-2)


	-- Floor Dropdown
	local function WorldMapFloorNavigationDropDown(Frame)
		S:HandleWorldMapDropDownMenu(Frame)
	end

	-- Tracking Button
	local function WorldMapTrackingOptionsButton(Button)
		local shadow = Button:GetRegions()
		shadow:Hide()

		Button.Background:Hide()
		Button.IconOverlay:SetAlpha(0)
		Button.Border:Hide()

		local tex = Button:GetHighlightTexture()
		tex:SetTexture([[Interface\Minimap\Tracking\None]], "ADD")
		tex:SetAllPoints(Button.Icon)
	end

	-- Bounty Board
	local function WorldMapBountyBoard(Frame)
		Frame.BountyName:FontTemplate()

		S:HandleCloseButton(Frame.TutorialBox.CloseButton)
	end

	-- Add a hook to adjust the OverlayFrames
	hooksecurefunc(WorldMapFrame, "AddOverlayFrame", S.WorldMapMixin_AddOverlayFrame)

	-- Elements
	WorldMapFloorNavigationDropDown(WorldMapFrame.overlayFrames[1]) -- NavBar handled in ElvUI/modules/skins/misc
	WorldMapTrackingOptionsButton(WorldMapFrame.overlayFrames[2]) -- Buttons
	WorldMapBountyBoard(WorldMapFrame.overlayFrames[3]) -- BountyBoard
	--WorldMapActionButtonTemplate(WorldMapFrame.overlayFrames[4]) -- ActionButtons
	--WorldMapZoneTimerTemplate(WorldMapFrame.overlayFrames[5]) -- Timer?
end

S:AddCallback("SkinWorldMap", LoadSkin)