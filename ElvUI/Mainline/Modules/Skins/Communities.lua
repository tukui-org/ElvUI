local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next, pairs, select = next, pairs, select

local C_CreatureInfo_GetClassInfo = C_CreatureInfo.GetClassInfo
local C_GuildInfo_GetGuildNewsInfo = C_GuildInfo.GetGuildNewsInfo
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local BATTLENET_FONT_COLOR = BATTLENET_FONT_COLOR
local GetClassInfo = GetClassInfo
local GREEN_FONT_COLOR = GREEN_FONT_COLOR
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

---- current unused:
local function UpdateNames(button)
	if not button.expanded then return end

	local memberInfo = button:GetMemberInfo()
	if memberInfo and memberInfo.classID then
		local classInfo = C_CreatureInfo_GetClassInfo(memberInfo.classID)
		if classInfo then
			local tcoords = _G.CLASS_ICON_TCOORDS[classInfo.classFile]
			button.Class:SetTexCoord(tcoords[1] + .022, tcoords[2] - .025, tcoords[3] + .022, tcoords[4] - .025)
		end
	end
end

local function ColorMemberName(button, info)
	if not info then return end

	local class = button.Class
	local _, classTag = GetClassInfo(info.classID)
	if classTag then
		local tcoords = CLASS_ICON_TCOORDS[classTag]
		class:SetTexCoord(tcoords[1] + .022, tcoords[2] - .025, tcoords[3] + .022, tcoords[4] - .025)
	end
end
---- TODO: need to reimplement this ^

local function HandleRoleChecks(button, ...)
	button:StripTextures()
	button:DisableDrawLayer('ARTWORK')
	button:DisableDrawLayer('OVERLAY')

	button.bg = button:CreateTexture(nil, 'BACKGROUND', nil, -7)
	button.bg:SetTexture(E.Media.Textures.RolesHQ)
	button.bg:SetTexCoord(...)
	button.bg:Point('CENTER')
	button.bg:Size(40, 40)
	button.bg:SetAlpha(0.6)

	S:HandleCheckBox(button.CheckBox)
end

local function HandleCommunitiesButtons(button)
	button.Background:Hide()
	button.CircleMask:Hide()
	button.IconRing:Hide()

	if button.IconBorder then
		button.IconBorder:Hide()
	end

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

local function HandleCommunityCards(frame)
	if not frame then return end

	for _, child in next, { frame.ScrollTarget:GetChildren() } do
		if not child.IsSkinned then
			child.CircleMask:Hide()
			child.LogoBorder:Hide()
			child.Background:Hide()
			S:HandleIcon(child.CommunityLogo)
			S:HandleButton(child)

			child.IsSkinned = true
		end
	end
end

local function HandleRewardButton(button)
	for _, child in next, { button.ScrollTarget:GetChildren() } do
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
	S:HandleDropDownBox(CommunitiesFrame.StreamDropDownMenu)

	hooksecurefunc(CommunitiesFrameCommunitiesList.ScrollBox, 'Update', function(frame)
		for _, child in next, { frame.ScrollTarget:GetChildren() } do
			HandleCommunitiesButtons(child)
		end
	end)

	-- Add Community Button
	hooksecurefunc(_G.CommunitiesListEntryMixin, 'SetAddCommunity', HandleCommunitiesButtons)
	hooksecurefunc(_G.CommunitiesListEntryMixin, 'SetFindCommunity', HandleCommunitiesButtons)
	hooksecurefunc(_G.CommunitiesListEntryMixin, 'SetGuildFinder', HandleCommunitiesButtons)

	S:HandleItemButton(CommunitiesFrame.ChatTab)
	CommunitiesFrame.ChatTab:Point('TOPLEFT', nil, 'TOPRIGHT', E.PixelMode and 0 or E.Border + E.Spacing, -36)
	S:HandleItemButton(CommunitiesFrame.RosterTab)
	S:HandleItemButton(CommunitiesFrame.GuildBenefitsTab)
	S:HandleItemButton(CommunitiesFrame.GuildInfoTab)

	S:HandleInsetFrame(CommunitiesFrame.CommunitiesList)
	S:HandleMaxMinFrame(CommunitiesFrame.MaximizeMinimizeFrame)

	S:HandleButton(CommunitiesFrame.InviteButton)
	S:HandleNextPrevButton(CommunitiesFrame.AddToChatButton)

	S:HandleDropDownBox(CommunitiesFrame.CommunitiesListDropDownMenu)

	hooksecurefunc(_G.CommunitiesNotificationSettingsStreamEntryMixin, 'SetFilter', function(s)
		s.ShowNotificationsButton:Size(20, 20)
		s.HideNotificationsButton:Size(20, 20)
		S:HandleCheckBox(s.ShowNotificationsButton)
		S:HandleCheckBox(s.HideNotificationsButton)
	end)

	-- Chat Tab
	CommunitiesFrame.MemberList:StripTextures()
	CommunitiesFrame.MemberList.InsetFrame:Hide()
	CommunitiesFrame.MemberList.WatermarkFrame:Hide()

	CommunitiesFrame.Chat:StripTextures()
	CommunitiesFrame.Chat.InsetFrame:SetTemplate('Transparent')
	S:HandleTrimScrollBar(CommunitiesFrame.Chat.ScrollBar)

	S:HandleEditBox(CommunitiesFrame.ChatEditBox)
	CommunitiesFrame.ChatEditBox:Size(120, 20)

	for _, name in next, {'GuildFinderFrame', 'InvitationFrame', 'TicketFrame', 'CommunityFinderFrame', 'ClubFinderInvitationFrame'} do
		local frame = CommunitiesFrame[name]
		if frame then
			frame:StripTextures()
			frame.InsetFrame:Hide()

			if frame.CircleMask then
				frame.CircleMask:Hide()
				frame.IconRing:Hide()
				S:HandleIcon(frame.Icon)
			end

			if frame.FindAGuildButton then S:HandleButton(frame.FindAGuildButton) end
			if frame.AcceptButton then S:HandleButton(frame.AcceptButton) end
			if frame.DeclineButton then S:HandleButton(frame.DeclineButton) end
			if frame.ApplyButton then S:HandleButton(frame.ApplyButton) end

			local requestFrame = frame.RequestToJoinFrame
			if requestFrame then
				requestFrame:StripTextures()
				requestFrame:SetTemplate('Transparent')

				hooksecurefunc(requestFrame, 'Initialize', function(s)
					for button in s.SpecsPool:EnumerateActive() do
						if button.CheckBox then
							S:HandleCheckBox(button.CheckBox)
							button.CheckBox:Size(26, 26)
						end
					end
				end)

				requestFrame.MessageFrame:StripTextures(true)
				requestFrame.MessageFrame.MessageScroll:StripTextures(true)

				S:HandleEditBox(requestFrame.MessageFrame.MessageScroll)
				S:HandleButton(requestFrame.Apply)
				S:HandleButton(requestFrame.Cancel)
			end

			if frame.GuildCards then HandleGuildCards(frame.GuildCards) end
			if frame.PendingGuildCards then HandleGuildCards(frame.PendingGuildCards) end
			if frame.CommunityCards then
				S:HandleTrimScrollBar(frame.CommunityCards.ScrollBar)
				hooksecurefunc(frame.CommunityCards.ScrollBox, 'Update', HandleCommunityCards)
			end
			if frame.PendingCommunityCards then
				S:HandleTrimScrollBar(frame.PendingCommunityCards.ScrollBar)
				hooksecurefunc(frame.PendingCommunityCards.ScrollBox, 'Update', HandleCommunityCards)
			end
		end
	end

	-- Guild finder Frame
	local ClubFinderGuildFinderFrame = _G.ClubFinderGuildFinderFrame
	ClubFinderGuildFinderFrame:StripTextures()

	S:HandleDropDownBox(_G.ClubFinderLanguageDropdown)
	S:HandleDropDownBox(ClubFinderGuildFinderFrame.OptionsList.ClubFilterDropdown)
	S:HandleDropDownBox(ClubFinderGuildFinderFrame.OptionsList.ClubSizeDropdown)

	ClubFinderGuildFinderFrame.OptionsList.SearchBox:Size(118, 20)
	ClubFinderGuildFinderFrame.OptionsList.Search:Size(118, 20)
	ClubFinderGuildFinderFrame.OptionsList.Search:ClearAllPoints()
	ClubFinderGuildFinderFrame.OptionsList.Search:Point('TOP', ClubFinderGuildFinderFrame.OptionsList.SearchBox, 'BOTTOM', 1, -3)
	S:HandleEditBox(ClubFinderGuildFinderFrame.OptionsList.SearchBox)
	S:HandleButton(ClubFinderGuildFinderFrame.OptionsList.Search)

	HandleRoleChecks(ClubFinderGuildFinderFrame.OptionsList.TankRoleFrame, _G.LFDQueueFrameRoleButtonTank.background:GetTexCoord())
	HandleRoleChecks(ClubFinderGuildFinderFrame.OptionsList.HealerRoleFrame, _G.LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
	HandleRoleChecks(ClubFinderGuildFinderFrame.OptionsList.DpsRoleFrame, _G.LFDQueueFrameRoleButtonDPS.background:GetTexCoord())

	S:HandleItemButton(ClubFinderGuildFinderFrame.ClubFinderSearchTab)
	S:HandleItemButton(ClubFinderGuildFinderFrame.ClubFinderPendingTab)

	-- Community and Guild finder Tab
	local ClubFinderCommunityAndGuildFinderFrame = _G.ClubFinderCommunityAndGuildFinderFrame
	ClubFinderCommunityAndGuildFinderFrame:StripTextures()

	S:HandleDropDownBox(ClubFinderCommunityAndGuildFinderFrame.OptionsList.ClubFilterDropdown)
	S:HandleDropDownBox(ClubFinderCommunityAndGuildFinderFrame.OptionsList.SortByDropdown)

	S:HandleButton(ClubFinderCommunityAndGuildFinderFrame.OptionsList.Search)
	ClubFinderCommunityAndGuildFinderFrame.OptionsList.Search:ClearAllPoints()
	ClubFinderCommunityAndGuildFinderFrame.OptionsList.Search:Point('TOP', ClubFinderCommunityAndGuildFinderFrame.OptionsList.SearchBox, 'BOTTOM', 1, -3)
	ClubFinderCommunityAndGuildFinderFrame.OptionsList.Search:Size(118, 20)
	ClubFinderCommunityAndGuildFinderFrame.OptionsList.SearchBox:Size(118, 20)
	S:HandleEditBox(ClubFinderCommunityAndGuildFinderFrame.OptionsList.SearchBox)

	HandleRoleChecks(ClubFinderCommunityAndGuildFinderFrame.OptionsList.TankRoleFrame, _G.LFDQueueFrameRoleButtonTank.background:GetTexCoord())
	HandleRoleChecks(ClubFinderCommunityAndGuildFinderFrame.OptionsList.HealerRoleFrame, _G.LFDQueueFrameRoleButtonHealer.background:GetTexCoord())
	HandleRoleChecks(ClubFinderCommunityAndGuildFinderFrame.OptionsList.DpsRoleFrame, _G.LFDQueueFrameRoleButtonDPS.background:GetTexCoord())

	S:HandleItemButton(ClubFinderCommunityAndGuildFinderFrame.ClubFinderSearchTab)
	S:HandleItemButton(ClubFinderCommunityAndGuildFinderFrame.ClubFinderPendingTab)

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
	DropDown:Point('LEFT', CommunitiesFrame.GuildMemberDetailFrame.RankLabel, 'RIGHT', -12, -3)
	S:HandleDropDownBox(DropDown, 175)

	-- Roster Tab
	local MemberList = CommunitiesFrame.MemberList
	local ColumnDisplay = MemberList.ColumnDisplay
	ColumnDisplay:StripTextures()
	ColumnDisplay.InsetBorderLeft:Hide()
	ColumnDisplay.InsetBorderBottomLeft:Hide()
	ColumnDisplay.InsetBorderTopLeft:Hide()
	ColumnDisplay.InsetBorderTop:Hide()

	S:HandleInsetFrame(MemberList.InsetFrame)
	S:HandleDropDownBox(CommunitiesFrame.GuildMemberListDropDownMenu)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton)
	CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton:Size(129, 19)
	S:HandleCheckBox(CommunitiesFrame.MemberList.ShowOfflineButton)
	CommunitiesFrame.MemberList.ShowOfflineButton:Size(25, 25)
	CommunitiesFrame.MemberList.ScrollBar:GetChildren():Hide()
	S:HandleTrimScrollBar(MemberList.ScrollBar)

	hooksecurefunc(CommunitiesFrame.MemberList, 'RefreshListDisplay', function(frame)
		for _, child in next, { frame.ColumnDisplay:GetChildren() } do
			if not child.template then
				child:StripTextures()
				child:SetTemplate('Transparent')
			end
		end
	end)

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

	S:HandleTrimScrollBar(CommunitiesFrame.GuildBenefitsFrame.Rewards.ScrollBar)

	if E.private.skins.parchmentRemoverEnable then
		GuildBenefitsFrame.Perks:StripTextures()
		GuildBenefitsFrame.Rewards.Bg:Hide()

		hooksecurefunc(CommunitiesFrame.GuildBenefitsFrame.Perks.ScrollBox, 'Update', HandleRewardButton)
		hooksecurefunc(CommunitiesFrame.GuildBenefitsFrame.Rewards.ScrollBox, 'Update', HandleRewardButton)
	end

	-- Guild Reputation Bar TO DO: Adjust me!
	local StatusBar = CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar
	StatusBar.Middle:Hide()
	StatusBar.Right:Hide()
	StatusBar.Left:Hide()
	StatusBar.BG:Hide()
	StatusBar.Shadow:Hide()
	StatusBar.Progress:SetTexture(E.media.normTex)
	StatusBar.Progress:SetAllPoints()
	E:RegisterStatusBar(StatusBar)

	local bg = CreateFrame('Frame', nil, StatusBar)
	bg:SetFrameLevel(StatusBar:GetFrameLevel())
	bg:SetTemplate()
	bg:SetOutside()

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

	S:HandleTrimScrollBar(_G.CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.CommunitiesFrameGuildDetailsFrameNews.ScrollBar)

	hooksecurefunc('GuildNewsButton_SetNews', function(button, news_id)
		local newsInfo = C_GuildInfo_GetGuildNewsInfo(news_id)
		if newsInfo and button.header and button.header:IsShown() then
			button.header:SetAlpha(0)
		end
	end)

	if E.private.skins.parchmentRemoverEnable then
		for _, frame in pairs({
			_G.CommunitiesFrameGuildDetailsFrameInfo,
			_G.CommunitiesFrameGuildDetailsFrameNews,
			_G.CommunitiesGuildNewsFiltersFrame,
		}) do
			frame:StripTextures()
		end

		-- Guild Challenges Background
		local GuildDetailsFrameInfo = _G.CommunitiesFrameGuildDetailsFrameInfo
		local backdrop1 = CreateFrame('Frame', nil, GuildDetailsFrameInfo)
		backdrop1:SetTemplate('Transparent')
		backdrop1:SetFrameLevel(GuildDetailsFrameInfo:GetFrameLevel() - 1)
		backdrop1:Point('TOPLEFT', GuildDetailsFrameInfo, 'TOPLEFT', 14, -22)
		backdrop1:Point('BOTTOMRIGHT', GuildDetailsFrameInfo, 'BOTTOMRIGHT', 0, 200)

		-- Guild MOTD Background
		local backdrop2 = CreateFrame('Frame', nil, GuildDetailsFrameInfo)
		backdrop2:SetTemplate('Transparent')
		backdrop2:SetFrameLevel(GuildDetailsFrameInfo:GetFrameLevel() - 1)
		backdrop2:Point('TOPLEFT', GuildDetailsFrameInfo, 'TOPLEFT', 14, -158)
		backdrop2:Point('BOTTOMRIGHT', GuildDetailsFrameInfo, 'BOTTOMRIGHT', 0, 118)

		-- Guild Information Background
		local backdrop3 = CreateFrame('Frame', nil, GuildDetailsFrameInfo)
		backdrop3:SetTemplate('Transparent')
		backdrop3:SetFrameLevel(GuildDetailsFrameInfo:GetFrameLevel() - 1)
		backdrop3:Point('TOPLEFT', GuildDetailsFrameInfo, 'TOPLEFT', 14, -236)
		backdrop3:Point('BOTTOMRIGHT', GuildDetailsFrameInfo, 'BOTTOMRIGHT', -7, 1)

		-- Guild News Background
		local backdrop4 = CreateFrame('Frame', nil, GuildDetailsFrameInfo)
		backdrop4:SetTemplate('Transparent')
		backdrop4:SetFrameLevel(GuildDetailsFrameInfo:GetFrameLevel() - 1)
		backdrop4:Point('TOPLEFT', GuildDetailsFrameInfo, 'TOPLEFT', 591, -22)
		backdrop4:Point('BOTTOMRIGHT', GuildDetailsFrameInfo, 'BOTTOMRIGHT', 18, 1)
	end

	_G.CommunitiesFrameGuildDetailsFrameInfo.TitleText:FontTemplate(nil, 14)
	_G.CommunitiesFrameGuildDetailsFrameNews.TitleText:FontTemplate(nil, 14)

	_G.CommunitiesFrameGuildDetailsFrameNews.ScrollBar:GetChildren():Hide()
	S:HandleTrimScrollBar(_G.CommunitiesFrameGuildDetailsFrameNews.ScrollBar)
	S:HandleButton(CommunitiesFrame.GuildLogButton)

	local BossModel = _G.CommunitiesFrameGuildDetailsFrameNews.BossModel
	BossModel:StripTextures()
	BossModel:SetTemplate('Transparent')
	BossModel.TextFrame:StripTextures()
	BossModel.TextFrame:SetTemplate('Transparent')

	-- Filters Frame
	local FiltersFrame = _G.CommunitiesGuildNewsFiltersFrame
	FiltersFrame:SetTemplate('Transparent')
	S:HandleCheckBox(FiltersFrame.GuildAchievement)
	S:HandleCheckBox(FiltersFrame.Achievement)
	S:HandleCheckBox(FiltersFrame.DungeonEncounter)
	S:HandleCheckBox(FiltersFrame.EpicItemLooted)
	S:HandleCheckBox(FiltersFrame.EpicItemCrafted)
	S:HandleCheckBox(FiltersFrame.EpicItemPurchased)
	S:HandleCheckBox(FiltersFrame.LegendaryItemLooted)
	S:HandleCloseButton(FiltersFrame.CloseButton)

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
	S:HandleDropDownBox(RecruitmentDialog.ClubFocusDropdown, 220)
	S:HandleDropDownBox(RecruitmentDialog.LookingForDropdown, 220)
	S:HandleDropDownBox(RecruitmentDialog.LanguageDropdown, 190)
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
	S:HandleDropDownBox(NotificationSettings.CommunitiesListDropDownMenu)
	S:HandleCheckBox(NotificationSettings.ScrollFrame.Child.QuickJoinButton)
	S:HandleButton(NotificationSettings.ScrollFrame.Child.AllButton)
	S:HandleButton(NotificationSettings.ScrollFrame.Child.NoneButton)
	S:HandleScrollBar(NotificationSettings.ScrollFrame.ScrollBar)

	-- Create Channel Dialog
	local EditStreamDialog = CommunitiesFrame.EditStreamDialog
	EditStreamDialog:StripTextures()
	EditStreamDialog:SetTemplate('Transparent')

	S:HandleEditBox(EditStreamDialog.NameEdit)
	EditStreamDialog.NameEdit:Size(280, 20)
	S:HandleEditBox(EditStreamDialog.Description)
	S:HandleCheckBox(EditStreamDialog.TypeCheckBox)

	S:HandleButton(EditStreamDialog.Accept)
	S:HandleButton(EditStreamDialog.Cancel)

	-- Communities Settings
	local Settings = _G.CommunitiesSettingsDialog
	Settings.BG:Hide()
	Settings:SetTemplate('Transparent')
	S:HandleIcon(Settings.IconPreview)
	Settings.IconPreviewRing:Hide()

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

	S:HandleDropDownBox(TicketManager.ExpiresDropDownMenu)
	S:HandleDropDownBox(TicketManager.UsesDropDownMenu)

	S:HandleButton(TicketManager.MaximizeButton)

	-- InvitationsFrames
	local ClubFinderInvitationFrame = CommunitiesFrame.ClubFinderInvitationFrame
	ClubFinderInvitationFrame.InsetFrame:StripTextures()
	ClubFinderInvitationFrame:SetTemplate()
	S:HandleButton(ClubFinderInvitationFrame.AcceptButton)
	S:HandleButton(ClubFinderInvitationFrame.DeclineButton)
	S:HandleButton(ClubFinderInvitationFrame.ApplyButton)

	ClubFinderInvitationFrame.WarningDialog:StripTextures()
	ClubFinderInvitationFrame.WarningDialog:SetTemplate('Transparent')
	S:HandleButton(ClubFinderInvitationFrame.WarningDialog.Accept)
	S:HandleButton(ClubFinderInvitationFrame.WarningDialog.Cancel)

	local InvitationFrame = CommunitiesFrame.InvitationFrame
	InvitationFrame.InsetFrame:StripTextures()
	InvitationFrame:SetTemplate()
	S:HandleButton(InvitationFrame.AcceptButton)
	S:HandleButton(InvitationFrame.DeclineButton)

	-- ApplicationList
	local ApplicantList = CommunitiesFrame.ApplicantList
	ApplicantList:StripTextures()
	ApplicantList.ColumnDisplay:StripTextures()

	ApplicantList:CreateBackdrop('Transparent')
	ApplicantList.backdrop:Point('TOPLEFT', 0, 0)
	ApplicantList.backdrop:Point('BOTTOMRIGHT', -15, 0)

	hooksecurefunc(ApplicantList, 'BuildList', function(list)
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

		--[[local buttons = list.ListScrollFrame.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			if not button.IsSkinned then
				button:Point('LEFT', ApplicantList.backdrop, 1, 0)
				button:Point('RIGHT', ApplicantList.backdrop, -1, 0)

				button:SetHighlightTexture(E.media.normTex)
				button:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)

				button.InviteButton:Size(66, 18)
				button.CancelInvitationButton:Size(20, 18)
				S:HandleButton(button.InviteButton)
				S:HandleButton(button.CancelInvitationButton)

				hooksecurefunc(button, 'UpdateMemberInfo', ColorMemberName)

				button.IsSkinned = true
			end
		end]] -- DF
	end)
end

S:AddCallbackForAddon('Blizzard_Communities')
