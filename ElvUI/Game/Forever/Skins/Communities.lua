local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, pairs, select = next, pairs, select

local CreateFrame = CreateFrame
local BATTLENET_FONT_COLOR = BATTLENET_FONT_COLOR
local GREEN_FONT_COLOR = GREEN_FONT_COLOR
local hooksecurefunc = hooksecurefunc

local function HandleCommunitiesButton(button)
	button.Background:Hide()
	button.CircleMask:Hide()
	button.IconRing:Hide()

	if not button.backdrop then
		button:CreateBackdrop('Transparent')
	end

	S:HandleIcon(button.Icon)
	button.Icon:ClearAllPoints()
	button.Icon:Point('TOPLEFT', 15, -18)

	button.backdrop:ClearAllPoints()
	button.backdrop:Point('TOPLEFT', 4, -13)
	button.backdrop:Point('BOTTOMRIGHT', -8, 8)

	local highlight = button:GetHighlightTexture()
	highlight:SetTexture(E.media.normTex)
	highlight:SetVertexColor(1, 1, 1, 0.3)
	highlight:SetInside(button.backdrop)

	button.Selection:SetAtlas(nil)
	button.Selection:SetTexture(E.media.normTex)
	button.Selection:SetInside(button.backdrop)

	local color = (button.Background:GetAtlas() == 'communities-nav-button-green-normal' and GREEN_FONT_COLOR) or BATTLENET_FONT_COLOR
	button.Selection:SetVertexColor(color.r, color.g, color.b, 0.2)
end

local HandleGuildCards
do
	local card = { 'First', 'Second', 'Third' }
	function HandleGuildCards(cards)
		for _, name in pairs(card) do
			local guildCard = cards[name..'Card']
			guildCard:StripTextures()
			guildCard:SetTemplate('Transparent')
			S:HandleButton(guildCard.RequestJoin)
		end

		S:HandleNextPrevButton(cards.PreviousPage)
		S:HandleNextPrevButton(cards.NextPage)
	end
end

local function HandleCommunityCardsChild(child)
	if not child.IsSkinned then
		child.CircleMask:Hide()
		child.LogoBorder:Hide()
		child.Background:Hide()
		S:HandleIcon(child.CommunityLogo)
		S:HandleButton(child)

		child.IsSkinned = true
	end
end

local function HandleCommunityCards(frame)
	frame:ForEachFrame(HandleCommunityCardsChild)
end

local function HandleRewardButton(child)
	if not child.IsSkinned then
		S:HandleIcon(child.Icon, true)
		child:StripTextures()

		child:CreateBackdrop('Transparent')
		child.backdrop:ClearAllPoints()
		child.backdrop:Point('TOPLEFT', child.Icon.backdrop)
		child.backdrop:Point('BOTTOMLEFT', child.Icon.backdrop)
		child.backdrop:SetWidth(child:GetWidth() - 5)

		child.IsSkinned = true
	end
end

local function HandleRewardButtons(frame)
	frame:ForEachFrame(HandleRewardButton)
end

local function CommunitiesListScrollUpdate(frame)
	frame:ForEachFrame(HandleCommunitiesButton)
end

local function RequestToJoin_Initialize(frame)
	for button in frame.SpecsPool:EnumerateActive() do
		S:HandleCheckBox(button.Checkbox)
		button.Checkbox:Size(26)
	end
end

local function HandleRequestToJoinFrame(requestFrame)
	requestFrame:StripTextures()
	requestFrame:SetTemplate('Transparent')
	hooksecurefunc(requestFrame, 'Initialize', RequestToJoin_Initialize)

	requestFrame.MessageFrame:StripTextures(true)
	requestFrame.MessageFrame.MessageScroll:StripTextures(true)

	S:HandleEditBox(requestFrame.MessageFrame.MessageScroll)
	S:HandleButton(requestFrame.Apply)
	S:HandleButton(requestFrame.Cancel)
end

local function NotificationSettingsStreamFilter(frame)
	frame.ShowNotificationsButton:Size(20, 20)
	frame.HideNotificationsButton:Size(20, 20)

	S:HandleCheckBox(frame.ShowNotificationsButton)
	S:HandleCheckBox(frame.HideNotificationsButton)
end

local function ChatEditBoxMinimized(frame)
	local parent = frame:GetParent()
	local editBox = parent.ChatEditBox
	editBox:Point('BOTTOMLEFT', 10, 6)
	editBox:Point('BOTTOMRIGHT', -12, 6)
end

-- MOTD moves up into the challenges area when the guild has none
local function GuildInfoHideChallenges(frame)
	if frame.motdBackdrop then -- one box down to the Guild Information header
		frame.motdBackdrop:Hide()
		frame.challengesBackdrop:Point('BOTTOMRIGHT', frame, 0, 118)
		frame.MOTDScrollFrame:Height(188)
	else
		frame.MOTDScrollFrame:Height(106)
	end
end

-- Blizzard moves GuildInfoTab under RosterTab when perks are disabled
local function UpdateCommunitiesTabs(frame)
	local last
	for _, tab in next, { frame.ChatTab, frame.RosterTab, frame.GuildBenefitsTab, frame.GuildInfoTab, frame.GuildPreferredPlaySettingsTab } do
		if tab:IsShown() then
			tab:ClearAllPoints()

			if last then
				tab:Point('TOPLEFT', last, 'BOTTOMLEFT', 0, -1)
			else
				tab:Point('TOPLEFT', frame, 'TOPRIGHT', 1, 0)
			end

			last = tab
		end
	end
end

local function ApplicantList_BuildList(list)
	local columnDisplay = list.ColumnDisplay
	for _, child in next, { columnDisplay:GetChildren() } do
		if not child.IsSkinned then
			child:StripTextures()

			child:CreateBackdrop()
			child.backdrop:Point('TOPLEFT', 4, -2)
			child.backdrop:Point('BOTTOMRIGHT', 0, 2)

			child:SetHighlightTexture(E.media.normTex)
			local hl = child:GetHighlightTexture()
			hl:SetVertexColor(1, 1, 1, .25)
			hl:SetInside(child.backdrop)

			child.IsSkinned = true
		end
	end
end

local function GuildNewsSetNews(button)
	button.header:SetAlpha(0)
end

local function MemberList_RefreshListDisplay(frame)
	for _, child in next, { frame.ColumnDisplay:GetChildren() } do
		if not child.template then
			child:StripTextures()
			child:SetTemplate('Transparent')
		end
	end
end

function S:Blizzard_Communities()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.communities) then return end

	local CommunitiesFrame = _G.CommunitiesFrame
	CommunitiesFrame:StripTextures()
	CommunitiesFrame.NineSlice:Hide()
	_G.CommunitiesFrameInset.Bg:Hide()

	S:HandlePortraitFrame(CommunitiesFrame)

	local CommunitiesFrameCommunitiesList = _G.CommunitiesFrameCommunitiesList
	CommunitiesFrameCommunitiesList.InsetFrame:StripTextures()
	CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide()
	CommunitiesFrameCommunitiesList.Bg:Hide()
	CommunitiesFrameCommunitiesList.TopFiligree:Hide()
	CommunitiesFrameCommunitiesList.BottomFiligree:Hide()
	CommunitiesFrameCommunitiesList.ScrollBar:GetChildren():Hide()
	S:HandleTrimScrollBar(CommunitiesFrameCommunitiesList.ScrollBar)
	_G.ChannelFrame.ChannelRoster.ScrollBar:StripTextures()
	S:HandleDropDownBox(CommunitiesFrame.StreamDropdown)

	hooksecurefunc(CommunitiesFrameCommunitiesList.ScrollBox, 'Update', CommunitiesListScrollUpdate)

	-- Add Community Button
	hooksecurefunc(_G.CommunitiesListEntryMixin, 'SetAddCommunity', HandleCommunitiesButton)
	hooksecurefunc(_G.CommunitiesListEntryMixin, 'SetFindCommunity', HandleCommunitiesButton)
	hooksecurefunc(_G.CommunitiesListEntryMixin, 'SetGuildFinder', HandleCommunitiesButton)

	S:HandleItemButton(CommunitiesFrame.ChatTab)
	S:HandleItemButton(CommunitiesFrame.RosterTab)
	S:HandleItemButton(CommunitiesFrame.GuildBenefitsTab)
	S:HandleItemButton(CommunitiesFrame.GuildInfoTab)
	S:HandleItemButton(CommunitiesFrame.GuildPreferredPlaySettingsTab)
	hooksecurefunc(CommunitiesFrame, 'UpdateCommunitiesTabs', UpdateCommunitiesTabs)

	-- Preferred Play Settings
	local PreferredPlay = CommunitiesFrame.GuildPreferredPlaySettingsFrame
	S:HandleDropDownBox(PreferredPlay.LocaleDropdown, 200, nil, true)
	S:HandleDropDownBox(PreferredPlay.DatacenterDropdown, 200, nil, true)
	S:HandleButton(PreferredPlay.LocaleApplyButton)
	S:HandleButton(PreferredPlay.DatacenterApplyButton)

	S:HandleInsetFrame(CommunitiesFrame.CommunitiesList)
	S:HandleMaxMinFrame(CommunitiesFrame.MaximizeMinimizeFrame)

	S:HandleButton(CommunitiesFrame.InviteButton)
	S:HandleNextPrevButton(CommunitiesFrame.AddToChatButton)

	S:HandleDropDownBox(CommunitiesFrame.CommunitiesListDropdown)

	hooksecurefunc(_G.CommunitiesNotificationSettingsStreamEntryMixin, 'SetFilter', NotificationSettingsStreamFilter)

	-- Chat Tab
	CommunitiesFrame.MemberList:StripTextures()
	CommunitiesFrame.MemberList.InsetFrame:Hide()
	CommunitiesFrame.MemberList.WatermarkFrame:Hide()

	CommunitiesFrame.Chat:StripTextures()
	CommunitiesFrame.Chat.InsetFrame:SetTemplate('Transparent')
	S:HandleTrimScrollBar(CommunitiesFrame.Chat.ScrollBar)

	S:HandleEditBox(CommunitiesFrame.ChatEditBox)
	CommunitiesFrame.ChatEditBox:Size(120, 20)
	hooksecurefunc(CommunitiesFrame.MaximizeMinimizeFrame, 'Minimize', ChatEditBoxMinimized)

	-- Guild and Community Finder
	for _, name in next, { 'GuildFinderFrame', 'CommunityFinderFrame' } do
		local frame = CommunitiesFrame[name]
		frame:StripTextures()
		frame.InsetFrame:Hide()

		HandleRequestToJoinFrame(frame.RequestToJoinFrame)

		HandleGuildCards(frame.GuildCards)
		HandleGuildCards(frame.PendingGuildCards)
		S:HandleTrimScrollBar(frame.CommunityCards.ScrollBar)
		hooksecurefunc(frame.CommunityCards.ScrollBox, 'Update', HandleCommunityCards)
		S:HandleTrimScrollBar(frame.PendingCommunityCards.ScrollBar)
		hooksecurefunc(frame.PendingCommunityCards.ScrollBox, 'Update', HandleCommunityCards)

		local searchTab, pendingTab = frame.ClubFinderSearchTab, frame.ClubFinderPendingTab
		S:HandleItemButton(searchTab)
		S:HandleItemButton(pendingTab)
		searchTab:ClearAllPoints()
		searchTab:Point('TOPLEFT', CommunitiesFrame, 'TOPRIGHT', 1, 0)
		pendingTab:ClearAllPoints()
		pendingTab:Point('TOPLEFT', searchTab, 'BOTTOMLEFT', 0, -1)
	end

	-- Invitations
	for _, name in next, { 'InvitationFrame', 'TicketFrame', 'ClubFinderInvitationFrame' } do
		local frame = CommunitiesFrame[name]
		frame:StripTextures()
		frame.InsetFrame:Hide()
		frame.CircleMask:Hide()
		frame.IconRing:Hide()

		S:HandleIcon(frame.Icon)
		S:HandleButton(frame.AcceptButton)
		S:HandleButton(frame.DeclineButton)
	end

	-- Guild finder Frame
	local ClubFinderGuildFinderFrame = _G.ClubFinderGuildFinderFrame
	ClubFinderGuildFinderFrame:StripTextures()

	local ClubFinderGuildOptionsList = ClubFinderGuildFinderFrame.OptionsList
	S:HandleDropDownBox(ClubFinderGuildOptionsList.ClubFilterDropdown)
	ClubFinderGuildOptionsList.ClubSizeDropdown:ClearAllPoints() -- FIX ME 11.0 Is this DropDown trolling us?
	ClubFinderGuildOptionsList.ClubSizeDropdown:Point('LEFT', ClubFinderGuildOptionsList.ClubFilterDropdown, 'RIGHT', 3, 0)
	S:HandleDropDownBox(ClubFinderGuildOptionsList.ClubSizeDropdown)

	ClubFinderGuildOptionsList.SearchBox:Size(118, 20)
	ClubFinderGuildOptionsList.Search:Size(118, 20)
	ClubFinderGuildOptionsList.Search:ClearAllPoints()
	ClubFinderGuildOptionsList.Search:Point('TOP', ClubFinderGuildOptionsList.SearchBox, 'BOTTOM', 1, -3)
	S:HandleEditBox(ClubFinderGuildOptionsList.SearchBox)
	S:HandleButton(ClubFinderGuildOptionsList.Search)

	-- Community and Guild finder Tab
	local ClubFinderCommunityAndGuildFinderFrame = _G.ClubFinderCommunityAndGuildFinderFrame
	local ClubFinderCommunityOptionsList = ClubFinderCommunityAndGuildFinderFrame.OptionsList
	ClubFinderCommunityAndGuildFinderFrame:StripTextures()

	for _, checkButton in next, {
		ClubFinderGuildOptionsList.TankRoleFrame.Checkbox,
		ClubFinderGuildOptionsList.HealerRoleFrame.Checkbox,
		ClubFinderGuildOptionsList.DpsRoleFrame.Checkbox,
		ClubFinderCommunityOptionsList.TankRoleFrame.Checkbox,
		ClubFinderCommunityOptionsList.HealerRoleFrame.Checkbox,
		ClubFinderCommunityOptionsList.DpsRoleFrame.Checkbox
	} do
		S:HandleCheckBox(checkButton)
		checkButton:OffsetFrameLevel(1)
	end

	S:HandleDropDownBox(ClubFinderCommunityOptionsList.ClubFilterDropdown, 120)
	S:HandleDropDownBox(ClubFinderCommunityOptionsList.SortByDropdown, 120)

	ClubFinderCommunityOptionsList.SortByDropdown:ClearAllPoints()
	ClubFinderCommunityOptionsList.SortByDropdown:Point('RIGHT', ClubFinderCommunityOptionsList.ClubFilterDropdown, 'RIGHT', 120, 0)

	S:HandleButton(ClubFinderCommunityOptionsList.Search)
	ClubFinderCommunityOptionsList.Search:ClearAllPoints()
	ClubFinderCommunityOptionsList.Search:Point('TOP', ClubFinderCommunityOptionsList.SearchBox, 'BOTTOM', 1, -3)
	ClubFinderCommunityOptionsList.Search:Size(118, 20)
	ClubFinderCommunityOptionsList.SearchBox:Size(118, 20)
	S:HandleEditBox(ClubFinderCommunityOptionsList.SearchBox)

	-- Member Details
	CommunitiesFrame.GuildMemberDetailFrame:StripTextures()
	CommunitiesFrame.GuildMemberDetailFrame:SetTemplate('Transparent')
	CommunitiesFrame.GuildMemberDetailFrame:ClearAllPoints()
	CommunitiesFrame.GuildMemberDetailFrame:Point('TOPLEFT', CommunitiesFrame, 'TOPRIGHT', -1, -30)

	CommunitiesFrame.GuildMemberDetailFrame.NoteBackground.NineSlice:SetTemplate('Transparent')
	CommunitiesFrame.GuildMemberDetailFrame.OfficerNoteBackground.NineSlice:SetTemplate('Transparent')
	S:HandleCloseButton(CommunitiesFrame.GuildMemberDetailFrame.CloseButton)
	S:HandleButton(CommunitiesFrame.GuildMemberDetailFrame.RemoveButton)
	S:HandleButton(CommunitiesFrame.GuildMemberDetailFrame.GroupInviteButton)
	CommunitiesFrame.GuildMemberDetailFrame.RemoveButton:ClearAllPoints()
	CommunitiesFrame.GuildMemberDetailFrame.RemoveButton:Point('BOTTOMLEFT', 10, 4)

	local DropDown = CommunitiesFrame.GuildMemberDetailFrame.RankDropdown
	DropDown:Point('LEFT', CommunitiesFrame.GuildMemberDetailFrame.RankLabel, 'RIGHT', 0, -3)
	S:HandleDropDownBox(DropDown, 150)

	-- Roster Tab
	local MemberList = CommunitiesFrame.MemberList
	local ColumnDisplay = MemberList.ColumnDisplay
	ColumnDisplay:StripTextures()
	ColumnDisplay.InsetBorderLeft:Hide()
	ColumnDisplay.InsetBorderBottomLeft:Hide()
	ColumnDisplay.InsetBorderTopLeft:Hide()
	ColumnDisplay.InsetBorderTop:Hide()

	S:HandleInsetFrame(MemberList.InsetFrame)
	S:HandleDropDownBox(CommunitiesFrame.GuildMemberListDropdown)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton)
	CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton:Size(129, 19)
	S:HandleCheckBox(CommunitiesFrame.MemberList.ShowOfflineButton)
	CommunitiesFrame.MemberList.ShowOfflineButton:Size(25)
	CommunitiesFrame.MemberList.ScrollBar:GetChildren():Hide()
	S:HandleTrimScrollBar(MemberList.ScrollBar)

	hooksecurefunc(CommunitiesFrame.MemberList, 'RefreshListDisplay', MemberList_RefreshListDisplay)

	-- Perks Tab
	local GuildBenefitsFrame = CommunitiesFrame.GuildBenefitsFrame
	GuildBenefitsFrame.InsetBorderLeft:Hide()
	GuildBenefitsFrame.InsetBorderRight:Hide()
	GuildBenefitsFrame.InsetBorderBottomRight:Hide()
	GuildBenefitsFrame.InsetBorderBottomLeft:Hide()
	GuildBenefitsFrame.InsetBorderTopRight:Hide()
	GuildBenefitsFrame.InsetBorderTopLeft:Hide()
	GuildBenefitsFrame.InsetBorderLeft2:Hide()
	GuildBenefitsFrame.InsetBorderBottomLeft2:Hide()
	GuildBenefitsFrame.InsetBorderTopLeft2:Hide()

	GuildBenefitsFrame.Perks.TitleText:FontTemplate(nil, 14)
	GuildBenefitsFrame.Rewards.TitleText:FontTemplate(nil, 14)

	S:HandleTrimScrollBar(CommunitiesFrame.GuildBenefitsFrame.Perks.ScrollBar)
	S:HandleTrimScrollBar(CommunitiesFrame.GuildBenefitsFrame.Rewards.ScrollBar)

	if E.private.skins.parchmentRemoverEnable then
		GuildBenefitsFrame.Perks:StripTextures()
		GuildBenefitsFrame.Rewards.Bg:Hide()

		hooksecurefunc(CommunitiesFrame.GuildBenefitsFrame.Perks.ScrollBox, 'Update', HandleRewardButtons)
		hooksecurefunc(CommunitiesFrame.GuildBenefitsFrame.Rewards.ScrollBox, 'Update', HandleRewardButtons)
	end

	local StatusBar = CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar
	StatusBar.Middle:Hide()
	StatusBar.Right:Hide()
	StatusBar.Left:Hide()
	StatusBar.BG:Hide()
	StatusBar.Shadow:SetAlpha(0)
	StatusBar.Progress:SetTexture(E.media.normTex)
	StatusBar.Progress:ClearAllPoints()
	StatusBar.Progress:Point('TOPLEFT')
	StatusBar.Progress:Point('BOTTOMLEFT')
	E:RegisterStatusBar(StatusBar)

	local ProgressBarBG = CreateFrame('Frame', nil, StatusBar)
	ProgressBarBG:OffsetFrameLevel(nil, StatusBar)
	ProgressBarBG:SetTemplate()
	ProgressBarBG:Point('TOPLEFT')
	ProgressBarBG:Point('BOTTOMRIGHT')
	StatusBar.background = ProgressBarBG

	-- Info Tab
	local GuildDetails = _G.CommunitiesFrameGuildDetailsFrame
	GuildDetails.InsetBorderLeft:Hide()
	GuildDetails.InsetBorderRight:Hide()
	GuildDetails.InsetBorderBottomRight:Hide()
	GuildDetails.InsetBorderBottomLeft:Hide()
	GuildDetails.InsetBorderTopRight:Hide()
	GuildDetails.InsetBorderTopLeft:Hide()
	GuildDetails.InsetBorderLeft2:Hide()
	GuildDetails.InsetBorderBottomLeft2:Hide()
	GuildDetails.InsetBorderTopLeft2:Hide()

	-- Filters Frame
	local FiltersFrame = _G.CommunitiesGuildNewsFiltersFrame
	FiltersFrame:StripTextures()
	FiltersFrame:SetTemplate('Transparent')
	S:HandleCheckBox(FiltersFrame.GuildAchievement)
	S:HandleCheckBox(FiltersFrame.Achievement)
	S:HandleCheckBox(FiltersFrame.DungeonEncounter)
	S:HandleCheckBox(FiltersFrame.EpicItemLooted)
	S:HandleCheckBox(FiltersFrame.EpicItemCrafted)
	S:HandleCheckBox(FiltersFrame.EpicItemPurchased)
	S:HandleCheckBox(FiltersFrame.LegendaryItemLooted)
	S:HandleCloseButton(FiltersFrame.CloseButton)

	local GuildDetailsFrameNews = _G.CommunitiesFrameGuildDetailsFrameNews
	local GuildDetailsFrameInfo = _G.CommunitiesFrameGuildDetailsFrameInfo
	S:HandleTrimScrollBar(GuildDetailsFrameInfo.DetailsFrame.ScrollBar)
	S:HandleTrimScrollBar(GuildDetailsFrameInfo.MOTDScrollFrame.ScrollBar)
	S:HandleTrimScrollBar(GuildDetailsFrameNews.ScrollBar)

	hooksecurefunc('CommunitiesGuildInfoFrame_HideChallenges', GuildInfoHideChallenges)
	hooksecurefunc('GuildNewsButton_SetNews', GuildNewsSetNews)

	if E.private.skins.parchmentRemoverEnable then
		GuildDetailsFrameInfo:StripTextures()
		GuildDetailsFrameNews:StripTextures()

		-- Guild Challenges Background
		local challengesBackdrop = CreateFrame('Frame', nil, GuildDetailsFrameInfo)
		challengesBackdrop:SetTemplate('Transparent')
		challengesBackdrop:OffsetFrameLevel(-1, GuildDetailsFrameInfo)
		challengesBackdrop:Point('TOPLEFT', GuildDetailsFrameInfo, 14, -22)
		challengesBackdrop:Point('BOTTOMRIGHT', GuildDetailsFrameInfo, 0, 200)
		GuildDetailsFrameInfo.challengesBackdrop = challengesBackdrop

		-- Guild MOTD Background
		local motdBackdrop = CreateFrame('Frame', nil, GuildDetailsFrameInfo)
		motdBackdrop:SetTemplate('Transparent')
		motdBackdrop:OffsetFrameLevel(-1, GuildDetailsFrameInfo)
		motdBackdrop:Point('TOPLEFT', GuildDetailsFrameInfo, 14, -158)
		motdBackdrop:Point('BOTTOMRIGHT', GuildDetailsFrameInfo, 0, 118)
		GuildDetailsFrameInfo.motdBackdrop = motdBackdrop

		-- Guild Information Background
		local infoBackdrop = CreateFrame('Frame', nil, GuildDetailsFrameInfo)
		infoBackdrop:SetTemplate('Transparent')
		infoBackdrop:OffsetFrameLevel(-1, GuildDetailsFrameInfo)
		infoBackdrop:Point('TOPLEFT', GuildDetailsFrameInfo, 14, -236)
		infoBackdrop:Point('BOTTOMRIGHT', GuildDetailsFrameInfo, -7, 1)
		GuildDetailsFrameInfo.infoBackdrop = infoBackdrop

		-- Guild News Background
		local newsBackdrop = CreateFrame('Frame', nil, GuildDetailsFrameNews)
		newsBackdrop:SetTemplate('Transparent')
		newsBackdrop:OffsetFrameLevel(-1, GuildDetailsFrameNews)
		newsBackdrop:Point('TOPLEFT', GuildDetailsFrameNews, 7, -22)
		newsBackdrop:Point('BOTTOMRIGHT', GuildDetailsFrameNews, -13, 1)
		GuildDetailsFrameInfo.newsBackdrop = newsBackdrop
	else
		-- the horizontal dividers are the only ARTWORK textures, the page art is BACKGROUND
		for _, region in next, { GuildDetailsFrameInfo:GetRegions() } do
			if region:IsObjectType('Texture') and region:GetDrawLayer() == 'ARTWORK' then
				region:SetAlpha(0)
			end
		end
	end

	GuildDetailsFrameInfo.TitleText:FontTemplate(nil, 14)
	GuildDetailsFrameNews.TitleText:FontTemplate(nil, 14)

	GuildDetailsFrameNews.ScrollBar:GetChildren():Hide()
	S:HandleButton(CommunitiesFrame.GuildLogButton)

	local BossModel = GuildDetailsFrameNews.BossModel
	BossModel:StripTextures()
	BossModel:SetTemplate('Transparent')
	BossModel.TextFrame:StripTextures()
	BossModel.TextFrame:SetTemplate('Transparent')

	-- Guild Message EditBox
	local EditFrame = _G.CommunitiesGuildTextEditFrame
	EditFrame:StripTextures()
	EditFrame:SetTemplate('Transparent')
	EditFrame.Container.NineSlice:SetTemplate('Transparent')
	S:HandleTrimScrollBar(EditFrame.Container.ScrollFrame.ScrollBar)
	S:HandleButton(_G.CommunitiesGuildTextEditFrameAcceptButton)

	local closeButton = select(4, _G.CommunitiesGuildTextEditFrame:GetChildren())
	S:HandleButton(closeButton)
	S:HandleCloseButton(_G.CommunitiesGuildTextEditFrameCloseButton)

	-- Guild Log
	local GuildLogFrame = _G.CommunitiesGuildLogFrame
	GuildLogFrame:StripTextures()
	GuildLogFrame:SetTemplate('Transparent')
	GuildLogFrame.Container.NineSlice:SetTemplate('Transparent')

	S:HandleTrimScrollBar(GuildLogFrame.Container.ScrollFrame.ScrollBar)
	S:HandleCloseButton(_G.CommunitiesGuildLogFrameCloseButton)
	closeButton = select(3, _G.CommunitiesGuildLogFrame:GetChildren()) -- swap local variable
	S:HandleButton(closeButton)

	-- Recruitment Dialog
	local RecruitmentDialog = _G.CommunitiesFrame.RecruitmentDialog
	RecruitmentDialog:StripTextures()
	RecruitmentDialog:SetTemplate('Transparent')
	S:HandleCheckBox(RecruitmentDialog.ShouldListClub.Button)
	S:HandleDropDownBox(RecruitmentDialog.ClubFocusDropdown, 200)
	S:HandleDropDownBox(RecruitmentDialog.LookingForDropdown, 200)
	S:HandleDropDownBox(RecruitmentDialog.LanguageDropdown, 140)
	RecruitmentDialog.RecruitmentMessageFrame:StripTextures()
	S:HandleEditBox(RecruitmentDialog.RecruitmentMessageFrame.RecruitmentMessageInput)
	S:HandleCheckBox(RecruitmentDialog.MaxLevelOnly.Button)
	S:HandleCheckBox(RecruitmentDialog.MinIlvlOnly.Button)
	S:HandleEditBox(RecruitmentDialog.MinIlvlOnly.EditBox)
	S:HandleButton(RecruitmentDialog.Accept)
	S:HandleButton(RecruitmentDialog.Cancel)
	S:HandleScrollBar(RecruitmentDialog.RecruitmentMessageFrame.RecruitmentMessageInput.ScrollBar)

	-- Notification Settings Dialog
	local NotificationSettings = _G.CommunitiesFrame.NotificationSettingsDialog
	NotificationSettings.Selector:StripTextures()
	S:HandleFrame(NotificationSettings)
	S:HandleDropDownBox(NotificationSettings.CommunitiesListDropdown, 190)
	S:HandleCheckBox(NotificationSettings.ScrollFrame.Child.QuickJoinButton)
	S:HandleButton(NotificationSettings.ScrollFrame.Child.AllButton)
	S:HandleButton(NotificationSettings.ScrollFrame.Child.NoneButton)
	S:HandleScrollBar(NotificationSettings.ScrollFrame.ScrollBar)
	S:HandleButton(NotificationSettings.Selector.OkayButton)
	S:HandleButton(NotificationSettings.Selector.CancelButton)

	-- Create Channel Dialog
	local EditStreamDialog = CommunitiesFrame.EditStreamDialog
	EditStreamDialog:StripTextures()
	EditStreamDialog:SetTemplate('Transparent')

	S:HandleEditBox(EditStreamDialog.NameEdit)
	EditStreamDialog.NameEdit:Size(280, 20)
	S:HandleEditBox(EditStreamDialog.Description)
	S:HandleCheckBox(EditStreamDialog.TypeCheckbox)

	S:HandleButton(EditStreamDialog.Accept)
	S:HandleButton(EditStreamDialog.Cancel)

	-- Communities Settings
	local Settings = _G.CommunitiesSettingsDialog
	Settings.BG:Hide()
	Settings:SetTemplate('Transparent')
	S:HandleIcon(Settings.IconPreview)
	Settings.IconPreviewRing:Hide()

	S:HandleCheckBox(Settings.CrossFactionToggle.CheckButton)
	S:HandleCheckBox(Settings.ShouldListClub.Button)
	S:HandleCheckBox(Settings.AutoAcceptApplications.Button)
	S:HandleCheckBox(Settings.MaxLevelOnly.Button)
	S:HandleCheckBox(Settings.MinIlvlOnly.Button)
	S:HandleEditBox(Settings.MinIlvlOnly.EditBox)
	S:HandleDropDownBox(Settings.ClubFocusDropdown, 180)
	S:HandleDropDownBox(Settings.LookingForDropdown, 180)

	S:HandleEditBox(Settings.NameEdit)
	S:HandleEditBox(Settings.ShortNameEdit)
	S:HandleEditBox(Settings.Description)
	S:HandleEditBox(Settings.MessageOfTheDay)

	S:HandleButton(Settings.ChangeAvatarButton)
	S:HandleButton(Settings.Accept)
	S:HandleButton(Settings.Delete)
	S:HandleButton(Settings.Cancel)

	-- Avatar Picker
	local Avatar = _G.CommunitiesAvatarPickerDialog
	Avatar.Selector:StripTextures()
	Avatar:SetTemplate('Transparent')

	S:HandleTrimScrollBar(Avatar.ScrollBar)
	S:HandleButton(Avatar.Selector.OkayButton)
	S:HandleButton(Avatar.Selector.CancelButton)

	-- Invite Frame
	local TicketManager = _G.CommunitiesTicketManagerDialog
	TicketManager:StripTextures()
	TicketManager:SetTemplate('Transparent')
	TicketManager.InviteManager.ArtOverlay:Hide()
	TicketManager.InviteManager.ColumnDisplay:StripTextures()
	TicketManager.InviteManager.ColumnDisplay.InsetBorderLeft:Hide()
	TicketManager.InviteManager.ColumnDisplay.InsetBorderBottomLeft:Hide()

	S:HandleButton(TicketManager.LinkToChat)
	S:HandleButton(TicketManager.Copy)
	S:HandleButton(TicketManager.Close)
	S:HandleButton(TicketManager.GenerateLinkButton)

	S:HandleDropDownBox(TicketManager.ExpiresDropdown)
	S:HandleDropDownBox(TicketManager.UsesDropdown)

	S:HandleButton(TicketManager.MaximizeButton)

	-- InvitationsFrames
	local ClubFinderInvitationFrame = CommunitiesFrame.ClubFinderInvitationFrame
	ClubFinderInvitationFrame:SetTemplate()
	S:HandleButton(ClubFinderInvitationFrame.ApplyButton)
	HandleRequestToJoinFrame(ClubFinderInvitationFrame.RequestToJoinFrame) -- linked posting

	ClubFinderInvitationFrame.WarningDialog:StripTextures()
	ClubFinderInvitationFrame.WarningDialog:SetTemplate('Transparent')
	S:HandleButton(ClubFinderInvitationFrame.WarningDialog.Accept)
	S:HandleButton(ClubFinderInvitationFrame.WarningDialog.Cancel)

	CommunitiesFrame.InvitationFrame:SetTemplate()

	-- ApplicationList
	local ApplicantList = CommunitiesFrame.ApplicantList
	ApplicantList:StripTextures()
	ApplicantList.ColumnDisplay:StripTextures()

	ApplicantList:CreateBackdrop('Transparent')
	ApplicantList.backdrop:Point('TOPLEFT', 0, 0)
	ApplicantList.backdrop:Point('BOTTOMRIGHT', -15, 0)
	S:HandleTrimScrollBar(ApplicantList.ScrollBar)

	hooksecurefunc(ApplicantList, 'BuildList', ApplicantList_BuildList)
end

S:AddCallbackForAddon('Blizzard_Communities')
