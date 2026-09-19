local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local QuestSessionCommand = Enum.QuestSessionCommand
local SessionCommand_ButtonAtlases = {
	[QuestSessionCommand.Start] = 'QuestSharing-DialogIcon',
	[QuestSessionCommand.Stop] = 'QuestSharing-Stop-DialogIcon'
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
	if dialog.IsSkinned then return end

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

		minimize:SetHighlightTexture(130837, 'ADD') -- Interface\Buttons\UI-PlusButton-Hilight
	end

	dialog.IsSkinned = true
end

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

local EventsFrameHookedElements = {}
local function EventsFrameHighlightTexture(element)
	local rr, gg, bb = unpack(E.media.rgbvaluecolor)
	element:SetTexture(E.Media.Textures.White8x8)
	element:SetVertexColor(rr, gg, bb)
	element:SetAlpha(0.2)
end

local function EventsFrameBackgroundNormal(element, texture)
	if texture ~= E.Media.Textures.NormTex then
		local r, g, b = unpack(E.media.backdropcolor)
		element:SetTexture(E.Media.Textures.NormTex)
		element:SetVertexColor(r, g, b)
		element:SetAlpha(0.5)

		local parent = element:GetParent()
		if parent and parent.Highlight then
			EventsFrameHighlightTexture(parent.Highlight)
		end
	end
end

local EventsFrameFunctions = {
	function(element) -- 1: OngoingHeader
		if not element.Background.backdrop then
			element.Background:StripTextures()
			element.Background:CreateBackdrop('Transparent')
		end

		element.Label:SetTextColor(1, 1, 1)
	end,
	function(element) -- 2: OngoingEvent
		if not EventsFrameHookedElements[element] then
			hooksecurefunc(element.Background, 'SetAtlas', EventsFrameBackgroundNormal)
			EventsFrameHookedElements[element] = element.Background
		end
	end,
	function(element) -- 3: ScheduledHeader
		if not element.Background.backdrop then
			element.Background:StripTextures()
			element.Background:CreateBackdrop('Transparent')
		end

		element.Label:SetTextColor(1, 1, 1)
	end,
	function(element) -- 4: ScheduledEvent
		if element.Highlight then
			EventsFrameHighlightTexture(element.Highlight)
		end
	end
}

local function EventsFrameCallback(_, frame, elementData)
	if not elementData.data then return end

	local func = EventsFrameFunctions[elementData.data.entryType]
	if func then
		func(frame)
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
	StoryHeader.Background:SetAlpha(.7)
	StoryHeader.Divider:Hide()
	StoryHeader.HighlightTexture:SetAllPoints(StoryHeader.Background)
	StoryHeader.HighlightTexture:SetAlpha(0)

	S:HandleEditBox(QuestScrollFrame.SearchBox)
	S:HandleTrimScrollBar(QuestScrollFrame.ScrollBar)
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
		Tracking.Icon:SetTexture(136460) -- Interface\Minimap\Tracking/None
		Tracking:SetHighlightTexture(136460, 'ADD')

		local TrackingHighlight = Tracking:GetHighlightTexture()
		TrackingHighlight:SetAllPoints(Tracking.Icon)

		Pin:StripTextures()
		Pin.Icon:SetAtlas('Waypoint-MapPin-Untracked')
		Pin.ActiveTexture:SetAtlas('Waypoint-MapPin-Tracked')
		Pin.ActiveTexture:SetAllPoints(Pin.Icon)
		Pin:SetHighlightTexture(3500068, 'ADD') -- Interface\Waypoint\WaypoinMapPinUI

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

	local MapLegend = QuestMapFrame.MapLegend
	MapLegend.TitleText:FontTemplate(nil, 16)

	local MapLegendScroll = MapLegend.ScrollFrame
	MapLegend.BorderFrame:SetAlpha(0)
	MapLegendScroll.Background:SetDrawLayer('BACKGROUND', -1)
	MapLegendScroll.Background:SetVertexColor(0, 0.5, 1)
	MapLegendScroll.Background:SetAlpha(0.9)

	if E.private.skins.parchmentRemoverEnable then
		MapLegendScroll:StripTextures()
		MapLegendScroll:SetTemplate('Transparent')
	else
		MapLegendScroll:SetTemplate()
		MapLegendScroll.Center:Hide()
	end

	S:HandleTrimScrollBar(MapLegendScroll.ScrollBar)

	-- 11.1 New Side Tabs
	local tabs = {
		QuestMapFrame.QuestsTab,
		QuestMapFrame.EventsTab,
		QuestMapFrame.MapLegendTab
	}

	local function PositionQuestTab(tab, _, _, _, x, y)
		local X, Y = 1, 0
		if x ~= X or y ~= Y then
			tab:ClearAllPoints()
			tab:SetPoint('TOPLEFT', QuestMapFrame, 'TOPRIGHT', X, Y)
		end
	end

	local function PositionTabIcons(icon, point, anchor)
		if anchor and point ~= 'CENTER' then
			icon:SetPoint('CENTER')
		end
	end

	for i, tab in next, tabs do
		tab:CreateBackdrop()
		tab:Size(30, 40)

		if i == 1 then
			tab:ClearAllPoints()
			tab:SetPoint('TOPLEFT', QuestMapFrame, 'TOPRIGHT', 11, 24)

			hooksecurefunc(tab, 'SetPoint', PositionQuestTab)
		end

		tab.Icon:ClearAllPoints()
		tab.Icon:SetPoint('CENTER')
		hooksecurefunc(tab.Icon, 'SetPoint', PositionTabIcons)

		tab.Background:SetAlpha(0)
		tab.TabGlow:SetAlpha(0)

		tab.SelectedTexture:SetDrawLayer('ARTWORK')
		tab.SelectedTexture:SetColorTexture(1, 0.82, 0, 0.3)
		tab.SelectedTexture:SetAllPoints()

		tab.HighlightTexture:SetColorTexture(1, 1, 1, 0.3)
		tab.HighlightTexture:SetAllPoints()
	end

	local EventsFrame = QuestMapFrame.EventsFrame
	EventsFrame.TitleText:FontTemplate(nil, 16)

	local EventsFrameScrollBox = EventsFrame.ScrollBox
	EventsFrame.BorderFrame:SetAlpha(0)
	EventsFrameScrollBox.Background:SetDrawLayer('BACKGROUND', -1)
	EventsFrameScrollBox.Background:SetVertexColor(1, 0, 1)
	EventsFrameScrollBox.Background:SetAlpha(0.9)

	if E.private.skins.parchmentRemoverEnable then
		EventsFrameScrollBox:StripTextures()
		EventsFrameScrollBox:SetTemplate('Transparent')
	else
		EventsFrameScrollBox:SetTemplate()
		EventsFrameScrollBox.Center:Hide()
	end

	for _, region in next, { EventsFrame:GetRegions() } do
		if region:IsObjectType('Texture') then
			region:Hide() -- some weird yellow box ?

			break
		end
	end

	S:HandleTrimScrollBar(EventsFrame.ScrollBar)

	-- Blizz new function for AddOns to access items on a ScrollBox. See Interface\AddOns\Blizzard_SharedXML\Shared\Scroll\ScrollUtil.lua
	_G.ScrollUtil.AddAcquiredFrameCallback(EventsFrameScrollBox, EventsFrameCallback, EventsFrame, true)
end

S:AddCallback('WorldMapFrame')
