local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local SessionCommand_ButtonAtlases = {
	[Enum.QuestSessionCommand.Start] = 'QuestSharing-DialogIcon',
	[Enum.QuestSessionCommand.Stop] = 'QuestSharing-Stop-DialogIcon'
}

local function UpdateExecuteCommandAtlases(frame, command)
	frame.ExecuteSessionCommand:SetNormalTexture(E.ClearTexture)
	frame.ExecuteSessionCommand:SetPushedTexture(E.ClearTexture)
	frame.ExecuteSessionCommand:SetDisabledTexture(E.ClearTexture)

	local atlas = SessionCommand_ButtonAtlases[command]
	if atlas then
		frame.ExecuteSessionCommand.normalIcon:SetAtlas(atlas)
	end
end

local function NotifyDialogShow(_, dialog)
	if dialog.isSkinned then return end

	dialog:StripTextures()
	dialog:SetTemplate('Transparent')

	S:HandleButton(dialog.ButtonContainer.Confirm)
	S:HandleButton(dialog.ButtonContainer.Decline)

	local minimize = dialog.MinimizeButton
	if minimize then
		minimize:StripTextures()
		minimize:Size(16)

		minimize.tex = minimize:CreateTexture(nil, 'OVERLAY')
		minimize.tex:SetTexture(E.Media.Textures.MinusButton)
		minimize.tex:SetInside()

		minimize:SetHighlightTexture(130837, 'ADD') -- Interface/Buttons/UI-PlusButton-Hilight
	end

	dialog.isSkinned = true
end

local function SkinHeaders(header)
	if header.IsSkinned then return end

	if header.TopFiligree then
		header.TopFiligree:Hide()
	end

	header:SetAlpha(.8)

	header.HighlightTexture:SetAllPoints(header.Background)
	header.HighlightTexture:SetAlpha(0)

	header.IsSkinned = true
end

local function QuestLogQuests()
	for header in _G.QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
		SkinHeaders(header)
	end
end

-- The original script here would taint the Quest Objective Tracker Button, so swapping to our own ~Simpy
function S:WorldMap_QuestMapHide()
	local QuestModelScene = _G.QuestModelScene
	if self:GetParent() == QuestModelScene:GetParent() then -- variant of QuestFrame_HideQuestPortrait
		QuestModelScene:SetParent(nil)
		QuestModelScene:Hide()
	end
end

function S:WorldMapFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.worldmap) then return end

	local WorldMapFrame = _G.WorldMapFrame
	WorldMapFrame:StripTextures()
	WorldMapFrame.ScrollContainer:SetTemplate()
	WorldMapFrame:CreateBackdrop('Transparent')
	WorldMapFrame.backdrop:Point('TOPLEFT', WorldMapFrame, 'TOPLEFT', -8, 0)
	WorldMapFrame.backdrop:Point('BOTTOMRIGHT', WorldMapFrame, 'BOTTOMRIGHT', 6, -8)

	local MapNavBar = WorldMapFrame.NavBar
	MapNavBar:StripTextures()
	MapNavBar.overlay:StripTextures()
	MapNavBar:Point('TOPLEFT', 1, -40)
	S:HandleButton(MapNavBar.homeButton)
	MapNavBar.homeButton.text:FontTemplate()

	-- Quest Frames
	local QuestMapFrame = _G.QuestMapFrame
	QuestMapFrame.VerticalSeparator:Hide()
	QuestMapFrame:SetScript('OnHide', S.WorldMap_QuestMapHide)

	local DetailsFrame = QuestMapFrame.DetailsFrame
	if E.private.skins.parchmentRemoverEnable then
		DetailsFrame:StripTextures(true)
		DetailsFrame:CreateBackdrop()
		DetailsFrame.backdrop:Point('TOPLEFT', -3, 5)
		DetailsFrame.backdrop:Point('BOTTOMRIGHT', DetailsFrame.RewardsFrame, 'TOPRIGHT', -1, -12)
		DetailsFrame.RewardsFrame:StripTextures()
		DetailsFrame.RewardsFrame:CreateBackdrop()
		DetailsFrame.RewardsFrame.backdrop:Point('TOPLEFT', -3, -14)
		DetailsFrame.RewardsFrame.backdrop:Point('BOTTOMRIGHT', -1, 1)

		if QuestMapFrame.Background then
			QuestMapFrame.Background:SetAlpha(0)
		end

		if DetailsFrame.SealMaterialBG then
			DetailsFrame.SealMaterialBG:SetAlpha(0)
		end
	end

	local QuestScrollFrame = _G.QuestScrollFrame
	QuestScrollFrame.Edge:SetAlpha(0)
	QuestScrollFrame.Contents.Separator.Divider:Hide()
	SkinHeaders(QuestScrollFrame.Contents.StoryHeader)

	local QuestDetailFrame = QuestScrollFrame.DetailFrame
	QuestDetailFrame:StripTextures()
	QuestDetailFrame.BottomDetail:Hide()
	QuestDetailFrame:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, nil, 1)

	if QuestDetailFrame.backdrop then
		QuestDetailFrame.backdrop:Point('TOPLEFT', QuestDetailFrame, 'TOPLEFT', 3, 1)
		QuestDetailFrame.backdrop:Point('BOTTOMRIGHT', QuestDetailFrame, 'BOTTOMRIGHT', -2, -7)
	end

	local QuestScrollBar = _G.QuestScrollFrame.ScrollBar
	S:HandleTrimScrollBar(QuestScrollBar)
	QuestScrollBar:Point('TOPLEFT', QuestDetailFrame, 'TOPRIGHT', 4, -15)
	QuestScrollBar:Point('BOTTOMLEFT', QuestDetailFrame, 'BOTTOMRIGHT', 9, 10)

	S:HandleButton(DetailsFrame.CompleteQuestFrame.CompleteButton, true)
	DetailsFrame.CompleteQuestFrame:StripTextures()

	S:HandleButton(DetailsFrame.BackButton, true)
	S:HandleButton(DetailsFrame.AbandonButton, true)
	S:HandleButton(DetailsFrame.ShareButton, true)
	S:HandleButton(DetailsFrame.TrackButton, true)

	DetailsFrame.BackButton:SetFrameLevel(5)
	DetailsFrame.AbandonButton:SetFrameLevel(5)
	DetailsFrame.ShareButton:SetFrameLevel(5)
	DetailsFrame.TrackButton:SetFrameLevel(5)
	DetailsFrame.TrackButton:Width(95)

	local CampaignOverview = QuestMapFrame.CampaignOverview
	SkinHeaders(CampaignOverview.Header)
	CampaignOverview.ScrollFrame:StripTextures()

	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(QuestMapFrame.QuestsFrame.StoryTooltip)
	end

	S:HandleTrimScrollBar(_G.QuestMapDetailsScrollFrame.ScrollBar)

	S:HandleNextPrevButton(WorldMapFrame.SidePanelToggle.CloseButton, 'left')
	S:HandleNextPrevButton(WorldMapFrame.SidePanelToggle.OpenButton, 'right')

	local MapBorderFrame = WorldMapFrame.BorderFrame
	MapBorderFrame:StripTextures()
	MapBorderFrame:SetFrameStrata(WorldMapFrame:GetFrameStrata())
	MapBorderFrame.NineSlice:Hide()

	S:HandleCloseButton(MapBorderFrame.CloseButton)
	S:HandleMaxMinFrame(MapBorderFrame.MaximizeMinimizeFrame)

	if E.global.general.disableTutorialButtons then
		MapBorderFrame.Tutorial:Kill()
	end

	do -- Add a hook to adjust the OverlayFrames
		hooksecurefunc(WorldMapFrame, 'AddOverlayFrame', S.WorldMapMixin_AddOverlayFrame)

		local Dropdown, Tracking, Pin = unpack(WorldMapFrame.overlayFrames)
		S:HandleDropDownBox(Dropdown) -- NavBar handled in ElvUI/modules/skins/misc

		Tracking:StripTextures()
		Tracking.Icon:SetTexture(136460) -- Interface/Minimap/Tracking/None
		Tracking:SetHighlightTexture(136460, 'ADD')

		local TrackingHighlight = Tracking:GetHighlightTexture()
		TrackingHighlight:SetAllPoints(Tracking.Icon)

		Pin:StripTextures()
		Pin.Icon:SetAtlas('Waypoint-MapPin-Untracked')
		Pin.ActiveTexture:SetAtlas('Waypoint-MapPin-Tracked')
		Pin.ActiveTexture:SetAllPoints(Pin.Icon)
		Pin:SetHighlightTexture(3500068, 'ADD') -- Interface/Waypoint/WaypoinMapPinUI

		local PinHighlight = Pin:GetHighlightTexture()
		PinHighlight:SetAllPoints(Pin.Icon)
		PinHighlight:SetTexCoord(0.3203125, 0.5546875, 0.015625, 0.484375)
	end

	-- 8.2.5 Party Sync | Credits Aurora/Shestak
	QuestMapFrame.QuestSessionManagement:StripTextures()

	local ExecuteSessionCommand = QuestMapFrame.QuestSessionManagement.ExecuteSessionCommand
	ExecuteSessionCommand:SetTemplate()
	ExecuteSessionCommand:StyleButton()

	local ExecuteSessionIcon = ExecuteSessionCommand:CreateTexture(nil, 'ARTWORK')
	ExecuteSessionIcon:Point('TOPLEFT', 0, 0)
	ExecuteSessionIcon:Point('BOTTOMRIGHT', 0, 0)
	ExecuteSessionCommand.normalIcon = ExecuteSessionIcon

	hooksecurefunc(QuestMapFrame.QuestSessionManagement, 'UpdateExecuteCommandAtlases', UpdateExecuteCommandAtlases)
	hooksecurefunc(_G.QuestSessionManager, 'NotifyDialogShow', NotifyDialogShow)
	hooksecurefunc('QuestLogQuests_Update', QuestLogQuests)
end

S:AddCallback('WorldMapFrame')
