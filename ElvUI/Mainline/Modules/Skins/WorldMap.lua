local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local next = next
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

local function SkinHeaders(header, isCalling)
	if header.IsSkinned then return end

	if header.Background then header.Background:SetAlpha(.7) end
	if header.TopFiligree then header.TopFiligree:Hide() end
	if header.Divider then header.Divider:Hide() end

	header.HighlightTexture:SetAllPoints(header.Background)
	header.HighlightTexture:SetAlpha(0)

	local collapseButton = isCalling and header or header.CollapseButton
	if collapseButton then
		collapseButton:GetPushedTexture():SetAlpha(0)
		collapseButton:GetHighlightTexture():SetAlpha(0)
		S:HandleCollapseTexture(collapseButton, true)
	end

	header.IsSkinned = true
end

local function QuestLogQuests()
	local r, g, b = unpack(E.media.rgbvaluecolor)

	for button in _G.QuestScrollFrame.headerFramePool:EnumerateActive() do
		if button.ButtonText and not button.IsSkinned then
			button:StripTextures()
			button:CreateBackdrop('Transparent')
			button:GetHighlightTexture():SetColorTexture(r, g, b, .25)
			button.ButtonText:FontTemplate(nil, 16)
			button.IsSkinned = true
		end
	end

	for button in _G.QuestScrollFrame.titleFramePool:EnumerateActive() do
		if not button.IsSkinned then
			--FIX ME 11.0; Use the actual ElvUI Check Skin thing
			if button.Checkbox then
				button.Checkbox:DisableDrawLayer('BACKGROUND')
				button.Checkbox:CreateBackdrop()
			end

			button.IsSkinned = true
		end
	end

	for header in _G.QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
		if header.Text and not header.IsSkinned then
			header.Text:FontTemplate(nil, 16)
			header.Progress:FontTemplate(nil, 12)

			header.IsSkinned = true
		end
	end

	for header in _G.QuestScrollFrame.campaignHeaderMinimalFramePool:EnumerateActive() do
		if header.CollapseButton and not header.IsSkinned then
			header:StripTextures()
			header.Background:CreateBackdrop('Transparent')
			header.Highlight:SetColorTexture(r, g, b, 0.75)
			header.IsSkinned = true
		end
	end
end

local function EventsFrameEvents(...)
	local _, element, elementData, new
	local r, g, b = unpack(E.media.rgbvaluecolor)

	if _G.select("#", ...) == 2 then
		element, elementData = ...
	elseif _G.select("#", ...) == 3 then
		element, elementData, new = ...
	else
		_, element, elementData, new = ...
	end

	if new ~= false then
		if elementData.data.entryType == 1 then -- OngoingHeader
			element.Background:StripTextures()
			element.Background:CreateBackdrop('Transparent')
		elseif elementData.data.entryType == 2 then -- OngoingEvent
			element.Background:SetAlpha(0)
		elseif elementData.data.entryType == 3 then -- ScheduledHeader
			element.Background:StripTextures()
			element.Background:CreateBackdrop('Transparent')
		elseif elementData.data.entryType == 4 then -- ScheduledEvent
			_G.nop()
		elseif elementData.data.entryType == 5 then -- Date
			_G.nop()
		elseif elementData.data.entryType == 6 then -- HiddenEventsLabel
			_G.nop()
		elseif elementData.data.entryType == 7 then -- NoEventsLabel
			_G.nop()
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
	S:HandleButton(MapNavBar.homeButton)
	MapNavBar.homeButton.text:FontTemplate()

	-- Quest Frames
	local QuestMapFrame = _G.QuestMapFrame
	QuestMapFrame.VerticalSeparator:Hide()
	QuestMapFrame:SetScript('OnHide', S.WorldMap_QuestMapHide)

	local DetailsFrame = QuestMapFrame.DetailsFrame
	S:HandleButton(DetailsFrame.BackFrame.BackButton, true)
	S:HandleButton(DetailsFrame.AbandonButton, true)
	DetailsFrame.ShareButton:StripTextures() -- strip the Blizz Art around from it
	S:HandleButton(DetailsFrame.ShareButton, true)
	S:HandleButton(DetailsFrame.TrackButton, true)

	DetailsFrame.BackFrame:StripTextures()
	DetailsFrame.BackFrame.BackButton:SetFrameLevel(5)
	DetailsFrame.AbandonButton:SetFrameLevel(5)
	DetailsFrame.ShareButton:SetFrameLevel(5)
	DetailsFrame.TrackButton:SetFrameLevel(5)
	DetailsFrame.TrackButton:Width(95)

	local RewardsFrameContainer = DetailsFrame.RewardsFrameContainer
	if E.private.skins.parchmentRemoverEnable then
		DetailsFrame:StripTextures(true)
		DetailsFrame.BackFrame:StripTextures()
		DetailsFrame:CreateBackdrop()
		DetailsFrame.backdrop:Point('TOPLEFT', -3, 5)
		DetailsFrame.backdrop:Point('BOTTOMRIGHT', DetailsFrame.RewardsFrame, 'TOPRIGHT', -1, -12)

		RewardsFrameContainer.RewardsFrame:StripTextures()

		if QuestMapFrame.Background then
			QuestMapFrame.Background:SetAlpha(0)
		end

		if DetailsFrame.SealMaterialBG then
			DetailsFrame.SealMaterialBG:SetAlpha(0)
		end
	end

	local QuestScrollFrame = _G.QuestScrollFrame
	QuestScrollFrame.Edge:SetAlpha(0)
	QuestScrollFrame.BorderFrame:SetAlpha(0)
	QuestScrollFrame.Background:SetAlpha(0)
	QuestScrollFrame.Contents.Separator:SetAlpha(0)

	QuestScrollFrame:SetTemplate()
	SkinHeaders(QuestScrollFrame.Contents.StoryHeader)
	S:HandleEditBox(QuestScrollFrame.SearchBox)

	local QuestScrollBar = _G.QuestScrollFrame.ScrollBar
	S:HandleTrimScrollBar(QuestScrollBar)
	QuestScrollBar:Point('TOPLEFT', _G.QuestDetailFrame, 'TOPRIGHT', 4, -15)
	QuestScrollBar:Point('BOTTOMLEFT', _G.QuestDetailFrame, 'BOTTOMRIGHT', 9, 10)

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
	MapLegend.BorderFrame:SetAlpha(0)

	local MapLegendScroll = MapLegend.ScrollFrame
	MapLegendScroll:StripTextures()
	MapLegendScroll:SetTemplate()
	S:HandleTrimScrollBar(MapLegendScroll.ScrollBar)

	-- 11.1 New Side Tabs
	local tabs = {
		QuestMapFrame.QuestsTab,
		QuestMapFrame.EventsTab,
		QuestMapFrame.MapLegendTab
	}

	for _, tab in next, tabs do
		tab:Size(34, 44)
		tab:CreateBackdrop()
		tab.backdrop:Point('TOPLEFT', 2, -2)
		tab.backdrop:Point('BOTTOMRIGHT', -2, 2)

		if tab.Background then
			tab.Background:SetAlpha(0)
		end

		if tab.SelectedTexture then
			tab.SelectedTexture:SetDrawLayer('ARTWORK')
			tab.SelectedTexture:ClearAllPoints()
			tab.SelectedTexture:SetPoint('TOPLEFT', 4, -4)
			tab.SelectedTexture:SetPoint('BOTTOMRIGHT', -4, 4)
			tab.SelectedTexture:SetColorTexture(1, 0.82, 0, 0.3)
		end

		for _, region in next, { tab:GetRegions() } do
			if region:IsObjectType('Texture') and region:GetAtlas() == 'QuestLog-Tab-side-Glow-hover' then
				region:SetColorTexture(1, 1, 1, 0.3)
				region:Point('TOPLEFT', 4, -4)
				region:Point('BOTTOMRIGHT', -4, 4)
			end
		end
	end

	if QuestMapFrame.QuestsTab then
		QuestMapFrame.QuestsTab:ClearAllPoints()
		QuestMapFrame.QuestsTab:Point('TOPLEFT', QuestMapFrame, 'TOPRIGHT', 1, 2)
	end

	local EventsFrame = QuestMapFrame.EventsFrame
	if EventsFrame then
		EventsFrame.TitleText:FontTemplate(nil, 16)
		EventsFrame.BorderFrame:SetAlpha(0)

		local EventsFrameScrollBox = EventsFrame.ScrollBox
		EventsFrameScrollBox:StripTextures()
		EventsFrameScrollBox:SetTemplate()

		S:HandleTrimScrollBar(EventsFrame.ScrollBar)

		-- Blizz new function for AddOns to access items on a ScrollBox. See Interface\AddOns\Blizzard_SharedXML\Shared\Scroll\ScrollUtil.lua
		_G.ScrollUtil.AddAcquiredFrameCallback(EventsFrameScrollBox, EventsFrameEvents, self, true)
	end
end

S:AddCallback('WorldMapFrame')
