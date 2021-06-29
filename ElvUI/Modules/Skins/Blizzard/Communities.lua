local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local ipairs, next, pairs, select, unpack = ipairs, next, pairs, select, unpack

local C_CreatureInfo_GetClassInfo = C_CreatureInfo.GetClassInfo
local C_GuildInfo_GetGuildNewsInfo = C_GuildInfo.GetGuildNewsInfo
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local BATTLENET_FONT_COLOR = BATTLENET_FONT_COLOR
local FRIENDS_BNET_BACKGROUND_COLOR = FRIENDS_BNET_BACKGROUND_COLOR
local FRIENDS_WOW_BACKGROUND_COLOR = FRIENDS_WOW_BACKGROUND_COLOR
local GetClassInfo = GetClassInfo
local GREEN_FONT_COLOR = GREEN_FONT_COLOR
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetGuildRewardInfo = GetGuildRewardInfo
local GetItemQualityColor = GetItemQualityColor
local GetItemInfo = GetItemInfo

local CLUBTYPE_GUILD = Enum.ClubType.Guild
local CLUBTYPE_BATTLENET = Enum.ClubType.BattleNet

local function UpdateNames(self)
	if not self.expanded then return end

	local memberInfo = self:GetMemberInfo()
	if memberInfo and memberInfo.classID then
		local classInfo = C_CreatureInfo_GetClassInfo(memberInfo.classID)
		if classInfo then
			local tcoords = _G.CLASS_ICON_TCOORDS[classInfo.classFile]
			self.Class:SetTexCoord(tcoords[1] + .022, tcoords[2] - .025, tcoords[3] + .022, tcoords[4] - .025)
		end
	end
end

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

local function HandleCommunitiesButtons(self, color)
	self.Background:Hide()
	self.CircleMask:Hide()
	self:SetFrameLevel(self:GetFrameLevel() + 5)

	S:HandleIcon(self.Icon)
	self.Icon:ClearAllPoints()
	self.Icon:Point('TOPLEFT', 15, -18)
	self.IconRing:Hide()

	if not self.backdrop then
		self:CreateBackdrop('Transparent')
		self.backdrop:ClearAllPoints()
		self.backdrop:Point('TOPLEFT', 7, -16)
		self.backdrop:Point('BOTTOMRIGHT', -10, 12)
	end

	local highlight = self:GetHighlightTexture()
	highlight:SetColorTexture(1, 1, 1, 0.3)
	highlight:SetInside(self.backdrop)

	if self.IconBorder then
		self.IconBorder:Hide()
	end

	if color then
		self.Selection:SetInside(self.backdrop)

		if color == 1 then
			self.Selection:SetAtlas(nil)
			self.Selection:SetColorTexture(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, 0.2)
		else
			self.Selection:SetAtlas(nil)
			self.Selection:SetColorTexture(BATTLENET_FONT_COLOR.r, BATTLENET_FONT_COLOR.g, BATTLENET_FONT_COLOR.b, 0.2)
		end
	end
end

local function ColorMemberName(self, info)
	if not info then return end

	local class = self.Class
	local classInfo = select(2, GetClassInfo(info.classID))
	if classInfo then
		local tcoords = CLASS_ICON_TCOORDS[classInfo]
		class:SetTexCoord(tcoords[1] + .022, tcoords[2] - .025, tcoords[3] + .022, tcoords[4] - .025)
	end
end

local card = {"First", "Second", "Third"}
local function HandleGuildCards(cards)
	for _, name in pairs(card) do
		local guildCard = cards[name..'Card']
		guildCard:StripTextures()
		guildCard:SetTemplate('Transparent')
		S:HandleButton(guildCard.RequestJoin)
	end
	S:HandleNextPrevButton(cards.PreviousPage)
	S:HandleNextPrevButton(cards.NextPage)
end

local function HandleCommunityCards(frame)
	for _, button in next, frame.ListScrollFrame.buttons do
		button.CircleMask:Hide()
		button.LogoBorder:Hide()
		button.Background:Hide()
		S:HandleIcon(button.CommunityLogo)
		S:HandleButton(button)
	end
	S:HandleScrollBar(frame.ListScrollFrame.scrollBar)
end

function S:Blizzard_Communities()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.communities) then return end

	local CommunitiesFrame = _G.CommunitiesFrame
	CommunitiesFrame:StripTextures()
	CommunitiesFrame.NineSlice:Hide()
	_G.CommunitiesFrameInset.Bg:Hide()
	CommunitiesFrame.CommunitiesList.InsetFrame:StripTextures()

	S:HandlePortraitFrame(CommunitiesFrame)

	local CommunitiesFrameCommunitiesList = _G.CommunitiesFrameCommunitiesList
	CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide()
	CommunitiesFrameCommunitiesList.Bg:Hide()
	CommunitiesFrameCommunitiesList.TopFiligree:Hide()
	CommunitiesFrameCommunitiesList.BottomFiligree:Hide()
	_G.CommunitiesFrameCommunitiesListListScrollFrame:StripTextures()

	hooksecurefunc(_G.CommunitiesListEntryMixin, 'SetClubInfo', function(s, clubInfo, isInvitation, isTicket)
		if clubInfo then
			s.Background:Hide()
			s.CircleMask:Hide()

			s.Icon:ClearAllPoints()
			s.Icon:Point('TOPLEFT', 8, -17)
			S:HandleIcon(s.Icon)
			s.IconRing:Hide()

			s.GuildTabardBackground:Point('TOPLEFT', 6, -17)
			s.GuildTabardEmblem:Point('TOPLEFT', 13, -17)
			s.GuildTabardBorder:Point('TOPLEFT', 6, -17)

			if not s.IconBorder then
				s.IconBorder = s:CreateTexture(nil, 'BORDER')
				s.IconBorder:SetOutside(s.Icon)
				s.IconBorder:Hide()
			end

			if not s.backdrop then
				s:CreateBackdrop('Transparent')
				s.backdrop:ClearAllPoints()
				s.backdrop:Point('TOPLEFT', 7, -16)
				s.backdrop:Point('BOTTOMRIGHT', -10, 12)
			end

			local highlight = s:GetHighlightTexture()
			highlight:SetColorTexture(1, 1, 1, 0.3)
			highlight:SetInside(s.backdrop)

			local isGuild = clubInfo.clubType == CLUBTYPE_GUILD
			if isGuild then
				s.Background:SetAtlas(nil)
				s.Selection:SetAtlas(nil)
				s.Selection:SetInside(s.backdrop)
				s.Selection:SetColorTexture(0, 1, 0, 0.2)
			else
				s.Background:SetAtlas(nil)
				s.Selection:SetAtlas(nil)
				s.Selection:SetInside(s.backdrop)
				s.Selection:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, 0.2)
			end

			if not isInvitation and not isGuild and not isTicket then
				if clubInfo.clubType == CLUBTYPE_BATTLENET then
					s.IconBorder:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b)
				else
					s.IconBorder:SetColorTexture(FRIENDS_WOW_BACKGROUND_COLOR.r, FRIENDS_WOW_BACKGROUND_COLOR.g, FRIENDS_WOW_BACKGROUND_COLOR.b)
				end

				s.IconBorder:Show()
			else
				s.IconBorder:Hide()
			end
		end
	end)

	-- Add Community Button
	hooksecurefunc(_G.CommunitiesListEntryMixin, 'SetAddCommunity', function(s) HandleCommunitiesButtons(s, 1) end)
	hooksecurefunc(_G.CommunitiesListEntryMixin, 'SetFindCommunity', function(s) HandleCommunitiesButtons(s, 2) end)
	hooksecurefunc(_G.CommunitiesListEntryMixin, 'SetGuildFinder', function(s) HandleCommunitiesButtons(s, 1) end)

	S:HandleItemButton(CommunitiesFrame.ChatTab)
	CommunitiesFrame.ChatTab:Point('TOPLEFT', nil, 'TOPRIGHT', E.PixelMode and 0 or E.Border + E.Spacing, -36)
	S:HandleItemButton(CommunitiesFrame.RosterTab)
	S:HandleItemButton(CommunitiesFrame.GuildBenefitsTab)
	S:HandleItemButton(CommunitiesFrame.GuildInfoTab)

	S:HandleInsetFrame(CommunitiesFrame.CommunitiesList)
	S:HandleMaxMinFrame(CommunitiesFrame.MaximizeMinimizeFrame)
	CommunitiesFrame.MaximizeMinimizeFrame:ClearAllPoints()
	CommunitiesFrame.MaximizeMinimizeFrame:Point('RIGHT', CommunitiesFrame.CloseButton, 'LEFT', 12, 0)

	S:HandleButton(CommunitiesFrame.InviteButton)
	S:HandleNextPrevButton(CommunitiesFrame.AddToChatButton)

	S:HandleScrollBar(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar)
	S:HandleScrollBar(CommunitiesFrame.Chat.MessageFrame.ScrollBar)
	S:HandleScrollBar(_G.CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar)

	S:HandleDropDownBox(CommunitiesFrame.StreamDropDownMenu)
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

	S:HandleEditBox(CommunitiesFrame.ChatEditBox)
	CommunitiesFrame.ChatEditBox:Size(120, 20)

	-- [[ GUILDFINDER FRAME ]]--
	local ClubFinderGuildFinderFrame = _G.ClubFinderGuildFinderFrame
	ClubFinderGuildFinderFrame:StripTextures()

	S:HandleDropDownBox(_G.ClubFinderLanguageDropdown)

	for _, name in next, {"GuildFinderFrame", "InvitationFrame", "TicketFrame", "CommunityFinderFrame", "ClubFinderInvitationFrame"} do
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
				S:HandleScrollBar(_G.ClubFinderGuildFinderFrameScrollBar)
				S:HandleButton(requestFrame.Apply)
				S:HandleButton(requestFrame.Cancel)
			end

			if frame.GuildCards then HandleGuildCards(frame.GuildCards) end
			if frame.PendingGuildCards then HandleGuildCards(frame.PendingGuildCards) end
			if frame.CommunityCards then HandleCommunityCards(frame.CommunityCards) end
			if frame.PendingCommunityCards then HandleCommunityCards(frame.PendingCommunityCards) end
		end
	end

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

	-- [[ClubFinderCommunityAndGuildFinderFrame ]]--
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

	S:HandleScrollBar(ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ListScrollFrame.scrollBar)
	S:HandleScrollBar(ClubFinderCommunityAndGuildFinderFrame.PendingCommunityCards.ListScrollFrame.scrollBar)

	S:HandleItemButton(ClubFinderCommunityAndGuildFinderFrame.ClubFinderSearchTab)
	S:HandleItemButton(ClubFinderCommunityAndGuildFinderFrame.ClubFinderPendingTab)

	-- Member Details
	CommunitiesFrame.GuildMemberDetailFrame:StripTextures()
	CommunitiesFrame.GuildMemberDetailFrame:SetTemplate('Transparent')

	CommunitiesFrame.GuildMemberDetailFrame.NoteBackground:SetTemplate('Transparent')
	CommunitiesFrame.GuildMemberDetailFrame.OfficerNoteBackground:SetTemplate('Transparent')
	S:HandleCloseButton(CommunitiesFrame.GuildMemberDetailFrame.CloseButton)
	S:HandleButton(CommunitiesFrame.GuildMemberDetailFrame.RemoveButton)
	S:HandleButton(CommunitiesFrame.GuildMemberDetailFrame.GroupInviteButton)

	local DropDown = CommunitiesFrame.GuildMemberDetailFrame.RankDropdown
	S:HandleDropDownBox(DropDown, 160)
	DropDown.backdrop:Point('TOPLEFT', 0, -6)
	DropDown.backdrop:Point('BOTTOMRIGHT', -12, 6)
	DropDown:Point('LEFT', CommunitiesFrame.GuildMemberDetailFrame.RankLabel, 'RIGHT', 2, 0)

	-- [[ ROSTER TAB ]]
	local MemberList = CommunitiesFrame.MemberList
	local ColumnDisplay = MemberList.ColumnDisplay
	ColumnDisplay:StripTextures()
	ColumnDisplay.InsetBorderLeft:Hide()
	ColumnDisplay.InsetBorderBottomLeft:Hide()
	ColumnDisplay.InsetBorderTopLeft:Hide()
	ColumnDisplay.InsetBorderTop:Hide()

	S:HandleInsetFrame(CommunitiesFrame.MemberList.InsetFrame)
	S:HandleDropDownBox(CommunitiesFrame.GuildMemberListDropDownMenu)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton)
	CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton:Size(129, 19)
	S:HandleCheckBox(CommunitiesFrame.MemberList.ShowOfflineButton)
	CommunitiesFrame.MemberList.ShowOfflineButton:Size(25, 25)

	hooksecurefunc(CommunitiesFrame.MemberList, 'RefreshListDisplay', function(s)
		for i = 1, s.ColumnDisplay:GetNumChildren() do
			local child = select(i, s.ColumnDisplay:GetChildren())
			child:StripTextures()
			child:SetTemplate('Transparent')
		end

		for _, button in ipairs(s.ListScrollFrame.buttons or {}) do
			if button and not button.hooked then
				hooksecurefunc(button, 'RefreshExpandedColumns', UpdateNames)

				if button.ProfessionHeader then
					local header = button.ProfessionHeader
					for i = 1, 3 do
						select(i, header:GetRegions()):Hide()
					end

					header:SetTemplate('Transparent')
				end

				button.hooked = true
			end

			if button and button.bg then
				button.bg:SetShown(button.Class:IsShown())
			end
		end
	end)

	-- [[ PERKS TAB ]]
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

	GuildBenefitsFrame.Perks:StripTextures()
	GuildBenefitsFrame.Perks.TitleText:FontTemplate(nil, 14)

	for i = 1, 5 do
		local button = _G['CommunitiesFrameContainerButton'..i]
		button:StripTextures()
		button:SetTemplate('Transparent')

		button.Icon:SetTexCoord(unpack(E.TexCoords))
		button.Icon:Point('LEFT', 3, 0)
	end

	GuildBenefitsFrame.Rewards.TitleText:FontTemplate(nil, 14)
	GuildBenefitsFrame.Rewards.Bg:Hide()
	S:HandleScrollBar(_G.CommunitiesFrameRewards.scrollBar)

	for _, button in pairs(CommunitiesFrame.GuildBenefitsFrame.Rewards.RewardsContainer.buttons) do
		button:SetTemplate('Transparent')
		button:SetNormalTexture('')
		button:SetHighlightTexture('')

		if not button.hover then
			local hover = button:CreateTexture()
			hover:SetColorTexture(1, 1, 1, 0.3)
			hover:SetInside(button.backdrop)
			button:SetHighlightTexture(hover)
			button.hover = hover
		end

		if button.DisabledBG then
			button.DisabledBG:SetInside(button)
		end

		if button.Icon and not button.Icon.backdrop then
			button.Icon:SetTexCoord(unpack(E.TexCoords))
			button.Icon:CreateBackdrop()
		end
	end

	hooksecurefunc('CommunitiesGuildRewards_Update', function()
		for _, button in pairs(CommunitiesFrame.GuildBenefitsFrame.Rewards.RewardsContainer.buttons) do
			if button.index then
				local _, itemID = GetGuildRewardInfo(button.index)
				if itemID then
					local _, _, quality = GetItemInfo(itemID)
					if quality and quality > 1 then
						button.Icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
					end
				end
			end
		end
	end)

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

	-- [[ INFO TAB ]]
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

	local striptextures = {
		'CommunitiesFrameGuildDetailsFrameInfo',
		'CommunitiesFrameGuildDetailsFrameNews',
		'CommunitiesGuildNewsFiltersFrame',
	}

	for _, frame in pairs(striptextures) do
		_G[frame]:StripTextures()
	end

	S:HandleScrollBar(_G.CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrameScrollBar)

	hooksecurefunc('GuildNewsButton_SetNews', function(button, news_id)
		local newsInfo = C_GuildInfo_GetGuildNewsInfo(news_id)
		if newsInfo then
			if button.header:IsShown() then
				button.header:SetAlpha(0)
			end
		end
	end)

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

	_G.CommunitiesFrameGuildDetailsFrameInfo.TitleText:FontTemplate(nil, 14)
	_G.CommunitiesFrameGuildDetailsFrameNews.TitleText:FontTemplate(nil, 14)

	S:HandleScrollBar(_G.CommunitiesFrameGuildDetailsFrameInfoScrollBar)
	S:HandleScrollBar(_G.CommunitiesFrameGuildDetailsFrameNewsContainer.ScrollBar)
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
	EditFrame.Container:SetTemplate('Transparent')
	S:HandleScrollBar(_G.CommunitiesGuildTextEditFrameScrollBar)
	S:HandleButton(_G.CommunitiesGuildTextEditFrameAcceptButton)

	local closeButton = select(4, _G.CommunitiesGuildTextEditFrame:GetChildren())
	S:HandleButton(closeButton)
	S:HandleCloseButton(_G.CommunitiesGuildTextEditFrameCloseButton)

	-- Guild Log
	local GuildLogFrame = _G.CommunitiesGuildLogFrame
	GuildLogFrame:StripTextures()
	GuildLogFrame.Container:StripTextures()
	GuildLogFrame:SetTemplate('Transparent')
	GuildLogFrame.Container:SetTemplate('Transparent')

	S:HandleScrollBar(_G.CommunitiesGuildLogFrameScrollBar, 4)
	S:HandleCloseButton(_G.CommunitiesGuildLogFrameCloseButton)
	closeButton = select(3, _G.CommunitiesGuildLogFrame:GetChildren()) -- swap local variable
	S:HandleButton(closeButton)

	-- Recruitment Info
	local RecruitmentFrame = _G.CommunitiesGuildRecruitmentFrame
	RecruitmentFrame:StripTextures()
	RecruitmentFrame:SetTemplate('Transparent')
	_G.CommunitiesGuildRecruitmentFrameInset:StripTextures(false)

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

	-- CheckBoxes
	local CommunitiesGuildRecruitmentFrameRecruitment = _G.CommunitiesGuildRecruitmentFrameRecruitment
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.InterestFrame.QuestButton)
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.InterestFrame.DungeonButton)
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.InterestFrame.RaidButton)
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.InterestFrame.PvPButton)
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.InterestFrame.RPButton)

	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.AvailabilityFrame.WeekdaysButton)
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.AvailabilityFrame.WeekendsButton)

	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.RolesFrame.TankButton.checkButton)
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.RolesFrame.HealerButton.checkButton)
	S:HandleCheckBox(CommunitiesGuildRecruitmentFrameRecruitment.RolesFrame.DamagerButton.checkButton)

	S:HandleCloseButton(_G.CommunitiesGuildRecruitmentFrameCloseButton)

	S:HandleButton(CommunitiesGuildRecruitmentFrameRecruitment.ListGuildButton)

	-- Tabs
	for i = 1, 2 do
		S:HandleTab(_G['CommunitiesGuildRecruitmentFrameTab'..i])
	end

	CommunitiesGuildRecruitmentFrameRecruitment.CommentFrame.CommentInputFrame:StripTextures()
	S:HandleEditBox(CommunitiesGuildRecruitmentFrameRecruitment.CommentFrame.CommentInputFrame)

	-- Recruitment Request
	local CommunitiesGuildRecruitmentFrameApplicants = _G.CommunitiesGuildRecruitmentFrameApplicants
	S:HandleButton(CommunitiesGuildRecruitmentFrameApplicants.InviteButton)
	S:HandleButton(CommunitiesGuildRecruitmentFrameApplicants.MessageButton)
	S:HandleButton(CommunitiesGuildRecruitmentFrameApplicants.DeclineButton)

	for i = 1, 5 do
		_G['CommunitiesGuildRecruitmentFrameApplicantsContainerButton'..i]:SetBackdrop()
	end

	-- Notification Settings Dialog
	local NotificationSettings = _G.CommunitiesFrame.NotificationSettingsDialog
	NotificationSettings:StripTextures()
	NotificationSettings:SetTemplate('Transparent')

	S:HandleDropDownBox(CommunitiesFrame.NotificationSettingsDialog.CommunitiesListDropDownMenu)
	S:HandleCheckBox(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame.Child.QuickJoinButton)
	S:HandleButton(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame.Child.AllButton)
	S:HandleButton(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame.Child.NoneButton)
	S:HandleButton(CommunitiesFrame.NotificationSettingsDialog.OkayButton)
	S:HandleButton(CommunitiesFrame.NotificationSettingsDialog.CancelButton)
	S:HandleScrollBar(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame.ScrollBar) -- Adjust me

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
	Avatar:StripTextures()
	Avatar:SetTemplate('Transparent')

	Avatar.ScrollFrame:StripTextures()
	S:HandleScrollBar(_G.CommunitiesAvatarPickerDialogScrollBar)

	S:HandleButton(Avatar.OkayButton)
	S:HandleButton(Avatar.CancelButton)

	-- Invite Frame
	local TicketManager = _G.CommunitiesTicketManagerDialog
	TicketManager:StripTextures()
	TicketManager.InviteManager.ArtOverlay:Hide()
	TicketManager.InviteManager.ColumnDisplay:StripTextures()
	TicketManager.InviteManager.ColumnDisplay.InsetBorderLeft:Hide()
	TicketManager.InviteManager.ColumnDisplay.InsetBorderBottomLeft:Hide()
	-- TO DO: Fix the Tabs
	TicketManager.InviteManager.ListScrollFrame:StripTextures()

	TicketManager:SetTemplate('Transparent')

	S:HandleButton(TicketManager.LinkToChat)
	S:HandleButton(TicketManager.Copy)
	S:HandleButton(TicketManager.Close)
	S:HandleButton(TicketManager.GenerateLinkButton)

	S:HandleDropDownBox(TicketManager.ExpiresDropDownMenu)
	S:HandleDropDownBox(TicketManager.UsesDropDownMenu)

	S:HandleScrollBar(TicketManager.InviteManager.ListScrollFrame.scrollBar)
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
	S:HandleScrollBar(ApplicantList.ListScrollFrame.scrollBar)

	ApplicantList:CreateBackdrop()
	ApplicantList.backdrop:Point('TOPLEFT', 0, 0)
	ApplicantList.backdrop:Point('BOTTOMRIGHT', -15, 0)

	hooksecurefunc(ApplicantList, 'BuildList', function(self)
		local columnDisplay = self.ColumnDisplay
		for i = 1, columnDisplay:GetNumChildren() do
			local child = select(i, columnDisplay:GetChildren())
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

		local buttons = self.ListScrollFrame.buttons
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
		end
	end)
end

S:AddCallbackForAddon('Blizzard_Communities')
