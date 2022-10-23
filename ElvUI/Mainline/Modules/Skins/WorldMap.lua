local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local hooksecurefunc = hooksecurefunc
local QUESTSESSIONCOMMAND_START = Enum.QuestSessionCommand.Start
local QUESTSESSIONCOMMAND_STOP = Enum.QuestSessionCommand.Stop

local function SkinHeaders(header)
	if not header.IsSkinned then
		if header.TopFiligree then header.TopFiligree:Hide() end

		header:SetAlpha(.8)

		header.HighlightTexture:SetAllPoints(header.Background)
		header.HighlightTexture:SetAlpha(0)

		header.IsSkinned = true
	end
end

-- The original script here would taint the Quest Objective Tracker Button, so swapping to our own ~Simpy
function S:WorldMap_QuestMapHide()
	if self:GetParent() == _G.QuestModelScene:GetParent() then -- variant of QuestFrame_HideQuestPortrait
		_G.QuestModelScene:SetParent(nil)
		_G.QuestModelScene:Hide()
	end
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
	WorldMapFrame.NavBar:Point('TOPLEFT', 1, -40)

	WorldMapFrame.ScrollContainer:SetTemplate()
	WorldMapFrame:CreateBackdrop('Transparent')
	WorldMapFrame.backdrop:Point('TOPLEFT', WorldMapFrame, 'TOPLEFT', -8, 0)
	WorldMapFrame.backdrop:Point('BOTTOMRIGHT', WorldMapFrame, 'BOTTOMRIGHT', 6, -8)

	S:HandleButton(WorldMapFrame.NavBar.homeButton)
	WorldMapFrame.NavBar.homeButton.xoffset = 1
	WorldMapFrame.NavBar.homeButton.text:FontTemplate()

	-- Quest Frames
	local QuestMapFrame = _G.QuestMapFrame
	QuestMapFrame.VerticalSeparator:Hide()
	QuestMapFrame:SetScript('OnHide', S.WorldMap_QuestMapHide)

	if E.private.skins.parchmentRemoverEnable then
		QuestMapFrame.DetailsFrame:StripTextures(true)
		QuestMapFrame.DetailsFrame:CreateBackdrop()
		QuestMapFrame.DetailsFrame.backdrop:Point('TOPLEFT', -3, 5)
		QuestMapFrame.DetailsFrame.backdrop:Point('BOTTOMRIGHT', QuestMapFrame.DetailsFrame.RewardsFrame, 'TOPRIGHT', -1, -12)
		QuestMapFrame.DetailsFrame.RewardsFrame:StripTextures()
		QuestMapFrame.DetailsFrame.RewardsFrame:CreateBackdrop()
		QuestMapFrame.DetailsFrame.RewardsFrame.backdrop:Point('TOPLEFT', -3, -14)
		QuestMapFrame.DetailsFrame.RewardsFrame.backdrop:Point('BOTTOMRIGHT', -1, 1)

		if QuestMapFrame.Background then
			QuestMapFrame.Background:SetAlpha(0)
		end

		if QuestMapFrame.DetailsFrame.SealMaterialBG then
			QuestMapFrame.DetailsFrame.SealMaterialBG:SetAlpha(0)
		end
	end

	local QuestScrollFrame = _G.QuestScrollFrame
	QuestScrollFrame.DetailFrame:StripTextures()
	QuestScrollFrame.DetailFrame.BottomDetail:Hide()
	QuestScrollFrame.Contents.Separator.Divider:Hide()

	local QuestScrollFrameScrollBar = _G.QuestScrollFrame.ScrollBar
	QuestScrollFrame.DetailFrame:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, nil, 1)

	if QuestScrollFrame.DetailFrame.backdrop then
		QuestScrollFrame.DetailFrame.backdrop:Point('TOPLEFT', QuestScrollFrame.DetailFrame, 'TOPLEFT', 3, 1)
		QuestScrollFrame.DetailFrame.backdrop:Point('BOTTOMRIGHT', QuestScrollFrame.DetailFrame, 'BOTTOMRIGHT', -2, -7)
	end

	SkinHeaders(QuestScrollFrame.Contents.StoryHeader)
	S:HandleScrollBar(QuestScrollFrameScrollBar)
	QuestScrollFrameScrollBar:Point('TOPLEFT', QuestScrollFrame.DetailFrame, 'TOPRIGHT', 1, -15)
	QuestScrollFrameScrollBar:Point('BOTTOMLEFT', QuestScrollFrame.DetailFrame, 'BOTTOMRIGHT', 6, 10)

	S:HandleButton(QuestMapFrame.DetailsFrame.BackButton, true)
	QuestMapFrame.DetailsFrame.BackButton:SetFrameLevel(5)
	S:HandleButton(QuestMapFrame.DetailsFrame.AbandonButton, true)
	QuestMapFrame.DetailsFrame.AbandonButton:SetFrameLevel(5)
	S:HandleButton(QuestMapFrame.DetailsFrame.ShareButton, true)
	QuestMapFrame.DetailsFrame.ShareButton:SetFrameLevel(5)
	S:HandleButton(QuestMapFrame.DetailsFrame.TrackButton, true)
	QuestMapFrame.DetailsFrame.TrackButton:SetFrameLevel(5)
	QuestMapFrame.DetailsFrame.TrackButton:Width(95)
	S:HandleButton(QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton, true)

	local CampaignOverview = QuestMapFrame.CampaignOverview
	SkinHeaders(CampaignOverview.Header)
	CampaignOverview.ScrollFrame:StripTextures()
	S:HandleScrollBar(_G.QuestMapFrameScrollBar)

	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(QuestMapFrame.QuestsFrame.StoryTooltip)
	end

	S:HandleScrollBar(_G.QuestMapDetailsScrollFrame.ScrollBar)

	QuestMapFrame.DetailsFrame.CompleteQuestFrame:StripTextures()

	S:HandleNextPrevButton(WorldMapFrame.SidePanelToggle.CloseButton, 'left')
	S:HandleNextPrevButton(WorldMapFrame.SidePanelToggle.OpenButton, 'right')

	S:HandleCloseButton(WorldMapFrame.BorderFrame.CloseButton)
	S:HandleMaxMinFrame(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame)

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

	-- 8.2.5 Party Sync | Credits Aurora/Shestak
	QuestMapFrame.QuestSessionManagement:StripTextures()

	local ExecuteSessionCommand = QuestMapFrame.QuestSessionManagement.ExecuteSessionCommand
	ExecuteSessionCommand:SetTemplate()
	ExecuteSessionCommand:StyleButton()

	local icon = ExecuteSessionCommand:CreateTexture(nil, 'ARTWORK')
	icon:Point('TOPLEFT', 0, 0)
	icon:Point('BOTTOMRIGHT', 0, 0)
	ExecuteSessionCommand.normalIcon = icon

	local sessionCommandToButtonAtlas = {
		[QUESTSESSIONCOMMAND_START] = 'QuestSharing-DialogIcon',
		[QUESTSESSIONCOMMAND_STOP] = 'QuestSharing-Stop-DialogIcon'
	}

	hooksecurefunc(QuestMapFrame.QuestSessionManagement, 'UpdateExecuteCommandAtlases', function(s, command)
		s.ExecuteSessionCommand:SetNormalTexture(E.ClearTexture)
		s.ExecuteSessionCommand:SetPushedTexture(E.ClearTexture)
		s.ExecuteSessionCommand:SetDisabledTexture(E.ClearTexture)

		local atlas = sessionCommandToButtonAtlas[command]
		if atlas then
			s.ExecuteSessionCommand.normalIcon:SetAtlas(atlas)
		end
	end)

	hooksecurefunc(_G.QuestSessionManager, 'NotifyDialogShow', function(_, dialog)
		if not dialog.isSkinned then
			dialog:StripTextures()
			dialog:SetTemplate('Transparent')

			S:HandleButton(dialog.ButtonContainer.Confirm)
			S:HandleButton(dialog.ButtonContainer.Decline)

			if dialog.MinimizeButton then
				dialog.MinimizeButton:StripTextures()
				dialog.MinimizeButton:Size(16, 16)

				dialog.MinimizeButton.tex = dialog.MinimizeButton:CreateTexture(nil, 'OVERLAY')
				dialog.MinimizeButton.tex:SetTexture(E.Media.Textures.MinusButton)
				dialog.MinimizeButton.tex:SetInside()
				dialog.MinimizeButton:SetHighlightTexture([[Interface\Buttons\UI-PlusButton-Hilight]], 'ADD')
			end

			dialog.isSkinned = true
		end
	end)

	hooksecurefunc('QuestLogQuests_Update', function()
		for header in QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
			SkinHeaders(header)
		end
	end)
end

S:AddCallback('WorldMapFrame')
