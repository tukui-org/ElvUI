local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function WorldMapBountyBoard(Frame)
	Frame.BountyName:FontTemplate()

	S:HandleCloseButton(Frame.TutorialBox.CloseButton)
end

function S:WorldMapFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.worldmap) then return end

	local WorldMapFrame = _G.WorldMapFrame
	WorldMapFrame:StripTextures()
	WorldMapFrame.BorderFrame:StripTextures()
	WorldMapFrame.BorderFrame:SetFrameStrata(WorldMapFrame:GetFrameStrata())
	WorldMapFrame.BorderFrame.NineSlice:Hide()
	WorldMapFrame.NavBar:StripTextures()
	WorldMapFrame.NavBar.overlay:StripTextures()
	WorldMapFrame.NavBar:SetPoint('TOPLEFT', 1, -40)

	WorldMapFrame.ScrollContainer:CreateBackdrop()
	WorldMapFrame:CreateBackdrop('Transparent')
	WorldMapFrame.backdrop:SetPoint('TOPLEFT', WorldMapFrame, 'TOPLEFT', -8, 0)
	WorldMapFrame.backdrop:SetPoint('BOTTOMRIGHT', WorldMapFrame, 'BOTTOMRIGHT', 0, -9)

	S:HandleButton(WorldMapFrame.NavBar.homeButton)
	WorldMapFrame.NavBar.homeButton.xoffset = 1
	WorldMapFrame.NavBar.homeButton.text:FontTemplate()

	-- Quest Frames
	local QuestMapFrame = _G.QuestMapFrame
	QuestMapFrame.VerticalSeparator:Hide()

	if E.private.skins.parchmentRemoverEnable then
		QuestMapFrame.DetailsFrame:StripTextures(true)
		QuestMapFrame.DetailsFrame:CreateBackdrop()
		QuestMapFrame.DetailsFrame.backdrop:SetPoint('TOPLEFT', 0, 0)
		QuestMapFrame.DetailsFrame.backdrop:SetPoint('BOTTOMRIGHT', QuestMapFrame.DetailsFrame.RewardsFrame, 'TOPRIGHT', 0, 1)
		QuestMapFrame.DetailsFrame.RewardsFrame:StripTextures()
		QuestMapFrame.DetailsFrame.RewardsFrame:SetTemplate()
	end

	local QuestScrollFrame = _G.QuestScrollFrame
	QuestScrollFrame.DetailFrame:StripTextures()
	QuestScrollFrame.DetailFrame.BottomDetail:Hide()
	QuestScrollFrame.Contents.Separator.Divider:Hide()

	local QuestScrollFrameScrollBar = _G.QuestScrollFrameScrollBar
	QuestScrollFrame.DetailFrame:CreateBackdrop()
	QuestScrollFrame.DetailFrame.backdrop:SetFrameLevel(1)
	QuestScrollFrame.DetailFrame.backdrop:SetPoint('TOPLEFT', QuestScrollFrame.DetailFrame, 'TOPLEFT', 3, 1)
	QuestScrollFrame.DetailFrame.backdrop:SetPoint('BOTTOMRIGHT', QuestScrollFrame.DetailFrame, 'BOTTOMRIGHT', -2, -7)
	QuestScrollFrame.Background:SetInside(QuestScrollFrame.DetailFrame.backdrop)
	QuestScrollFrame.Contents.StoryHeader.Background:SetWidth(251)
	QuestScrollFrame.Contents.StoryHeader.Background:SetPoint('TOP', 0, -9)
	QuestScrollFrame.Contents.StoryHeader.Text:SetPoint('TOPLEFT', 18, -20)
	QuestScrollFrame.Contents.StoryHeader.HighlightTexture:SetAllPoints(QuestScrollFrame.Contents.StoryHeader.Background)
	QuestScrollFrame.Contents.StoryHeader.HighlightTexture:SetAlpha(0)
	S:HandleScrollBar(QuestScrollFrameScrollBar, 3, 3)
	QuestScrollFrameScrollBar:SetPoint('TOPLEFT', QuestScrollFrame.DetailFrame, 'TOPRIGHT', 1, -15)
	QuestScrollFrameScrollBar:SetPoint('BOTTOMLEFT', QuestScrollFrame.DetailFrame, 'BOTTOMRIGHT', 6, 10)

	S:HandleButton(QuestMapFrame.DetailsFrame.BackButton)
	S:HandleButton(QuestMapFrame.DetailsFrame.AbandonButton)
	S:HandleButton(QuestMapFrame.DetailsFrame.ShareButton, true)
	S:HandleButton(QuestMapFrame.DetailsFrame.TrackButton)
	S:HandleButton(QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton, true)

	if E.private.skins.blizzard.tooltip then
		QuestMapFrame.QuestsFrame.StoryTooltip:SetTemplate('Transparent')
		QuestScrollFrame.WarCampaignTooltip:SetTemplate('Transparent')
	end

	QuestMapFrame.DetailsFrame.CompleteQuestFrame:StripTextures()

	S:HandleNextPrevButton(WorldMapFrame.SidePanelToggle.CloseButton, 'left')
	S:HandleNextPrevButton(WorldMapFrame.SidePanelToggle.OpenButton, 'right')

	S:HandleCloseButton(WorldMapFrame.BorderFrame.CloseButton)
	S:HandleMaxMinFrame(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame)
	WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:ClearAllPoints()
	WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:SetPoint('RIGHT', WorldMapFrame.BorderFrame.CloseButton, 'LEFT', 12, 0)

	if E.global.general.disableTutorialButtons then
		WorldMapFrame.BorderFrame.Tutorial:Kill()
	end

	-- Add a hook to adjust the OverlayFrames
	hooksecurefunc(WorldMapFrame, 'AddOverlayFrame', S.WorldMapMixin_AddOverlayFrame)

	-- Elements
	S:HandleDropDownBox(WorldMapFrame.overlayFrames[1]) -- NavBar handled in ElvUI/modules/skins/misc

	WorldMapFrame.overlayFrames[2]:StripTextures()
	WorldMapFrame.overlayFrames[2].Icon:SetTexture([[Interface\Minimap\Tracking\None]])
	WorldMapFrame.overlayFrames[2]:SetHighlightTexture([[Interface\Minimap\Tracking\None]], 'ADD')
	WorldMapFrame.overlayFrames[2]:GetHighlightTexture():SetAllPoints(WorldMapFrame.overlayFrames[2].Icon)

	WorldMapBountyBoard(WorldMapFrame.overlayFrames[3]) -- BountyBoard
	--WorldMapActionButtonTemplate(WorldMapFrame.overlayFrames[4]) -- ActionButtons
	--WorldMapZoneTimerTemplate(WorldMapFrame.overlayFrames[5]) -- Timer?

	-- 8.2.5 Party Sync | Credits Aurora/Shestak
	QuestMapFrame.QuestSessionManagement:StripTextures()

	local ExecuteSessionCommand = QuestMapFrame.QuestSessionManagement.ExecuteSessionCommand
	ExecuteSessionCommand:SetTemplate()
	ExecuteSessionCommand:StyleButton()

	local icon = ExecuteSessionCommand:CreateTexture(nil, 'ARTWORK')
	icon:SetPoint('TOPLEFT', 0, 0)
	icon:SetPoint('BOTTOMRIGHT', 0, 0)
	ExecuteSessionCommand.normalIcon = icon

	local sessionCommandToButtonAtlas = {
		[_G.Enum.QuestSessionCommand.Start] = 'QuestSharing-DialogIcon',
		[_G.Enum.QuestSessionCommand.Stop] = 'QuestSharing-Stop-DialogIcon'
	}

	hooksecurefunc(QuestMapFrame.QuestSessionManagement, 'UpdateExecuteCommandAtlases', function(s, command)
		s.ExecuteSessionCommand:SetNormalTexture('')
		s.ExecuteSessionCommand:SetPushedTexture('')
		s.ExecuteSessionCommand:SetDisabledTexture('')

		local atlas = sessionCommandToButtonAtlas[command]
		if atlas then
			s.ExecuteSessionCommand.normalIcon:SetAtlas(atlas)
		end
	end)

	hooksecurefunc(_G.QuestSessionManager, 'NotifyDialogShow', function(_, dialog)
		if not dialog.isSkinned then
			dialog:StripTextures()
			dialog:CreateBackdrop('Transparent')
			S:HandleButton(dialog.ButtonContainer.Confirm)
			S:HandleButton(dialog.ButtonContainer.Decline)
			if dialog.MinimizeButton then
				dialog.MinimizeButton:StripTextures()
				dialog.MinimizeButton:SetSize(16, 16)

				dialog.MinimizeButton.tex = dialog.MinimizeButton:CreateTexture(nil, 'OVERLAY')
				dialog.MinimizeButton.tex:SetTexture(E.Media.Textures.MinusButton)
				dialog.MinimizeButton.tex:SetInside()
				dialog.MinimizeButton:SetHighlightTexture([[Interface\Buttons\UI-PlusButton-Hilight]], 'ADD')
			end
			dialog.isSkinned = true
		end
	end)
end

S:AddCallback('WorldMapFrame')
