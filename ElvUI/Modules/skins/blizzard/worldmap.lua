local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true then return end

	local WorldMapFrame = _G["WorldMapFrame"]
	WorldMapFrame:StripTextures()
	WorldMapFrame.BorderFrame:StripTextures()
	WorldMapFrame.BorderFrame:SetFrameStrata(WorldMapFrame:GetFrameStrata())
	WorldMapFrame.BorderFrame.NineSlice:Hide()
	WorldMapFrame.NavBar:StripTextures()
	WorldMapFrame.NavBar.overlay:StripTextures()
	WorldMapFrame.NavBar:SetPoint("TOPLEFT", 1, -40)

	WorldMapFrame.ScrollContainer:CreateBackdrop()
	WorldMapFrame:CreateBackdrop("Transparent")

	WorldMapFrameHomeButton:StripTextures()
	WorldMapFrameHomeButton:CreateBackdrop("Default", true)
	WorldMapFrameHomeButton.backdrop:SetPoint("TOPLEFT", WorldMapFrameHomeButton, "TOPLEFT", 0, 0)
	WorldMapFrameHomeButton.backdrop:SetPoint("BOTTOMRIGHT", WorldMapFrameHomeButton, "BOTTOMRIGHT", -15, 0)
	WorldMapFrameHomeButton:SetFrameLevel(1)
	WorldMapFrameHomeButton.text:FontTemplate()

	-- Quest Frames
	local QuestMapFrame = _G["QuestMapFrame"]
	QuestMapFrame.VerticalSeparator:Hide()

	if E.private.skins.parchmentRemover.enable then
		QuestMapFrame.DetailsFrame:StripTextures(true)
		QuestMapFrame.DetailsFrame:CreateBackdrop()
		QuestMapFrame.DetailsFrame.backdrop:SetPoint('TOPLEFT', 0, 0)
		QuestMapFrame.DetailsFrame.backdrop:SetPoint('BOTTOMRIGHT', QuestMapFrame.DetailsFrame.RewardsFrame, 'TOPRIGHT', 0, 1)
		QuestMapFrame.DetailsFrame.RewardsFrame:StripTextures()
		QuestMapFrame.DetailsFrame.RewardsFrame:SetTemplate()
	end

	local QuestScrollFrame = _G["QuestScrollFrame"]
	QuestScrollFrame.DetailFrame:StripTextures()
	QuestScrollFrame.Contents.Separator.Divider:Hide()

	QuestScrollFrame.DetailFrame:CreateBackdrop("Default")
	QuestScrollFrame.DetailFrame.backdrop:SetFrameLevel(1)
	QuestScrollFrame.DetailFrame.backdrop:Point("TOPLEFT", QuestScrollFrame.DetailFrame, "TOPLEFT", 3, 1)
	QuestScrollFrame.DetailFrame.backdrop:Point("BOTTOMRIGHT", QuestScrollFrame.DetailFrame, "BOTTOMRIGHT", -2, -7)
	QuestScrollFrame.Background:SetInside(QuestScrollFrame.DetailFrame.backdrop)
	QuestScrollFrame.Contents.StoryHeader.Background:SetWidth(251)
	QuestScrollFrame.Contents.StoryHeader.Background:SetPoint("TOP", 0, -9)
	QuestScrollFrame.Contents.StoryHeader.Text:SetPoint("TOPLEFT", 18, -20)
	QuestScrollFrame.Contents.StoryHeader.HighlightTexture:SetAllPoints(QuestScrollFrame.Contents.StoryHeader.Background)
	QuestScrollFrame.Contents.StoryHeader.HighlightTexture:SetAlpha(0)
	S:HandleScrollBar(QuestScrollFrameScrollBar, 3, 3)
	QuestScrollFrameScrollBar:SetPoint("TOPLEFT", QuestScrollFrame.DetailFrame, "TOPRIGHT", 1, -15)
	QuestScrollFrameScrollBar:SetPoint("BOTTOMLEFT", QuestScrollFrame.DetailFrame, "BOTTOMRIGHT", 6, 10)

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
