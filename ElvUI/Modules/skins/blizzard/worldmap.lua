local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SquareButton_SetIcon

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

	-- WorldMap SidePanel Button
	local function HandleQuestToggleButton(button, direction)
		button:ClearAllPoints()
		button:SetPoint("CENTER")

		local arrow = button:CreateTexture(nil, "ARTWORK")
		arrow:SetPoint("TOPLEFT", 5, -9)
		arrow:SetPoint("BOTTOMRIGHT", -20, 9)

		if direction == "Right" then
			arrow:SetTexture([[Interface/MONEYFRAME/Arrow-Right-Up]])
		elseif direction == "Left" then
			arrow:SetTexture([[Interface/MONEYFRAME/Arrow-Left-Up]])
		end

		local quest = button:CreateTexture(nil, "ARTWORK")
		quest:SetTexture([[Interface/QuestFrame/QuestMapLogAtlas]])
		quest:SetTexCoord(0.5390625, 0.556640625, 0.7265625, 0.75)
		quest:SetPoint("TOPLEFT", 14, -5)
		quest:SetPoint("BOTTOMRIGHT", -1, 3)

		button:SetNormalTexture("")
		button:SetPushedTexture("")
		button:SetHighlightTexture("")

		S:HandleButton(button)
	end

	local function HandleWorldMapSidePanelToggle(frame)
		HandleQuestToggleButton(frame.OpenButton, "Right")
		HandleQuestToggleButton(frame.CloseButton, "Left")

		frame:SetSize(32, 32)
	end

	HandleWorldMapSidePanelToggle(WorldMapFrame.SidePanelToggle)

	S:HandleCloseButton(WorldMapFrameCloseButton)
	S:HandleMaxMinFrame(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame)

	if E.global.general.disableTutorialButtons then
		WorldMapFrame.BorderFrame.Tutorial:Kill()
	end

	--local TrackingOptions = _G["WorldMapFrame"].UIElementsFrame.TrackingOptionsButton
	--TrackingOptions.Button:StripTextures()
	--TrackingOptions.Background:SetAlpha(0)
	--TrackingOptions.IconOverlay:SetAlpha(0)

	--S:HandleNextPrevButton(WorldMapFrame.UIElementsFrame.OpenQuestPanelButton)
	--S:HandleNextPrevButton(WorldMapFrame.UIElementsFrame.CloseQuestPanelButton)
	--SquareButton_SetIcon(WorldMapFrame.UIElementsFrame.CloseQuestPanelButton, 'LEFT')

	--WorldMapFrame.UIElementsFrame.BountyBoard.BountyName:FontTemplate(nil, 14, "OUTLINE")
	--WorldMapFrame.UIElementsFrame.OpenQuestPanelButton:Size(22,20)
	--WorldMapFrame.UIElementsFrame.CloseQuestPanelButton:Size(22,20)

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
end

S:AddCallback("SkinWorldMap", LoadSkin)