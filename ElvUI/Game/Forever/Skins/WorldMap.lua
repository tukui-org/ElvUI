local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next = next
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local function QuestLogQuests()
	local r, g, b = unpack(E.media.rgbvaluecolor)

	for button in _G.QuestScrollFrame.headerFramePool:EnumerateActive() do
		if not button.IsSkinned then
			button:StripTextures()
			button:CreateBackdrop('Transparent')
			button:GetHighlightTexture():SetColorTexture(r, g, b, .25)
			button.ButtonText:FontTemplate(nil, 16)
			button.IsSkinned = true
		end
	end

	for button in _G.QuestScrollFrame.titleFramePool:EnumerateActive() do
		if not button.IsSkinned then
			button.Checkbox:StripTextures(true)
			button.Checkbox:CreateBackdrop()
			button.IsSkinned = true
		end
	end

	for header in _G.QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
		if not header.IsSkinned then
			header.Text:FontTemplate(nil, 16)
			header.Progress:FontTemplate(nil, 12)
			header.IsSkinned = true
		end
	end

	for header in _G.QuestScrollFrame.campaignHeaderMinimalFramePool:EnumerateActive() do
		if not header.IsSkinned then
			header:StripTextures()
			header.Background:CreateBackdrop('Transparent')
			header.Highlight:SetColorTexture(r, g, b, 0.75)
			header.IsSkinned = true
		end
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

	S.HandleNavBarButtons(MapNavBar)

	local HomeButton = MapNavBar.homeButton
	S:HandleButton(HomeButton)
	HomeButton.text:FontTemplate()

	local OverflowButton = MapNavBar.overflowButton
	S:HandleButton(OverflowButton)

	for _, tex in next, { OverflowButton:GetNormalTexture(), OverflowButton:GetPushedTexture() } do
		S:SetupArrow(tex, 'left')

		tex:SetTexCoord(0, 1, 0, 1)
		tex:ClearAllPoints()
		tex:Point('CENTER')
		tex:Size(14)
	end

	-- Quest Frames
	local QuestMapFrame = _G.QuestMapFrame
	QuestMapFrame.VerticalSeparator:Hide()
	QuestMapFrame:SetScript('OnHide', S.WorldMap_QuestMapHide)

	local QuestsFrame = QuestMapFrame.QuestsFrame
	local DetailsFrame = QuestMapFrame.DetailsFrame
	local RewardsContainer = DetailsFrame.RewardsFrameContainer

	S:HandleButton(DetailsFrame.AbandonButton, true)
	DetailsFrame.ShareButton:StripTextures() -- strip the Blizz Art around from it
	S:HandleButton(DetailsFrame.ShareButton, true)
	S:HandleButton(DetailsFrame.TrackButton, true)

	DetailsFrame.BorderFrame:SetAlpha(0)
	DetailsFrame.AbandonButton:SetFrameLevel(5)
	DetailsFrame.ShareButton:SetFrameLevel(5)
	DetailsFrame.TrackButton:SetFrameLevel(5)
	DetailsFrame.TrackButton:Width(95)

	local BackFrame = DetailsFrame.BackFrame
	BackFrame:StripTextures()
	BackFrame.BackButton:SetFrameLevel(5)
	S:HandleButton(BackFrame.BackButton, true)

	local DetailsBg = DetailsFrame.Bg
	DetailsBg:ClearAllPoints()
	DetailsBg:Point('TOPLEFT', 0, -41)
	DetailsBg:Point('BOTTOMRIGHT', RewardsContainer)

	if E.private.skins.parchmentRemoverEnable then
		DetailsFrame:StripTextures(true)

		DetailsFrame:CreateBackdrop('Transparent')
		DetailsFrame.backdrop:SetAllPoints(DetailsBg)

		RewardsContainer.RewardsFrame:StripTextures()
		DetailsFrame.SealMaterialBG:SetAlpha(0)
	else
		DetailsFrame.SealMaterialBG:SetAllPoints(DetailsBg)
	end

	local CampaignOverview = QuestsFrame.CampaignOverview
	S:HandleTrimScrollBar(CampaignOverview.ScrollFrame.ScrollBar)
	CampaignOverview.BorderFrame:SetAlpha(0)

	if E.private.skins.parchmentRemoverEnable then
		CampaignOverview:StripTextures()
		CampaignOverview:SetTemplate('Transparent')
	end

	local QuestScrollFrame = _G.QuestScrollFrame
	QuestScrollFrame:SetTemplate('Transparent')

	QuestScrollFrame.Edge:SetAlpha(0)
	QuestScrollFrame.BorderFrame:SetAlpha(0)
	QuestScrollFrame.Contents.Separator:SetAlpha(0)

	QuestScrollFrame.Background:SetDrawLayer('BACKGROUND', -1)
	QuestScrollFrame.Background:SetVertexColor(1, 0.5, 0)
	QuestScrollFrame.Background:SetAlpha(0.9)

	if E.private.skins.parchmentRemoverEnable then
		QuestScrollFrame.Background:SetAlpha(0)
	else
		QuestScrollFrame.Center:Hide()
	end

	local StoryHeader = QuestScrollFrame.Contents.StoryHeader
	StoryHeader.Background:SetAlpha(0.7)
	StoryHeader.Divider:Hide()
	StoryHeader.HighlightTexture:SetAllPoints(StoryHeader.Background)
	StoryHeader.HighlightTexture:SetAlpha(0)

	S:HandleEditBox(QuestScrollFrame.SearchBox)

	_G.QuestLogCount:StripTextures()
	_G.QuestLogCount:SetTemplate('Transparent')

	local QuestScrollBar = _G.QuestScrollFrame.ScrollBar
	S:HandleTrimScrollBar(QuestScrollBar)

	if E.private.skins.blizzard.tooltip then
		TT:SetStyle(QuestScrollFrame.StoryTooltip)
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

		S:HandleDropDownBox(WorldMapFrame.overlayFrames[1]) -- NavBar handled in ElvUI\Modules\Skins\Misc

		local Tracking = WorldMapFrame.WorldMapTrackingOptionsButton
		if Tracking then
			S:HandleCloseButton(Tracking.ResetButton)
		end

		local Pin = WorldMapFrame.WorldMapTrackingPinButton
		if Pin then
			Pin:StripTextures()
			Pin.Icon:SetAtlas('Waypoint-MapPin-Untracked')
			Pin.ActiveTexture:SetAtlas('Waypoint-MapPin-Tracked')
			Pin.ActiveTexture:SetAllPoints(Pin.Icon)
			Pin:SetHighlightTexture(3500068, 'ADD') -- Interface\Waypoint\WaypoinMapPinUI

			local PinHighlight = Pin:GetHighlightTexture()
			PinHighlight:SetAllPoints(Pin.Icon)
			PinHighlight:SetTexCoord(0.3203125, 0.5546875, 0.015625, 0.484375)
		end
	end

	hooksecurefunc('QuestLogQuests_Update', QuestLogQuests)
end

S:AddCallback('WorldMapFrame')
