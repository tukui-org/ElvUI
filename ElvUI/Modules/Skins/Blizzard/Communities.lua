local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local ipairs, pairs, select, unpack = ipairs, pairs, select, unpack
--WoW API / Variables
local C_CreatureInfo_GetClassInfo = C_CreatureInfo.GetClassInfo
local C_GuildInfo_GetGuildNewsInfo = C_GuildInfo.GetGuildNewsInfo
local FRIENDS_BNET_BACKGROUND_COLOR = FRIENDS_BNET_BACKGROUND_COLOR
local FRIENDS_WOW_BACKGROUND_COLOR = FRIENDS_WOW_BACKGROUND_COLOR
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetGuildRewardInfo = GetGuildRewardInfo
local GetItemQualityColor = GetItemQualityColor
local GetItemInfo = GetItemInfo
local Enum = Enum

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

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Communities ~= true then return end

	local CommunitiesFrame = _G.CommunitiesFrame
	CommunitiesFrame:StripTextures()
	CommunitiesFrame.NineSlice:Hide()
	_G.CommunitiesFrameInset.Bg:Hide()
	CommunitiesFrame.CommunitiesList.InsetFrame:StripTextures()

	S:HandlePortraitFrame(CommunitiesFrame, true)

	local CommunitiesFrameCommunitiesList = _G.CommunitiesFrameCommunitiesList
	CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide()
	CommunitiesFrameCommunitiesList.Bg:Hide()
	CommunitiesFrameCommunitiesList.TopFiligree:Hide()
	CommunitiesFrameCommunitiesList.BottomFiligree:Hide()
	_G.CommunitiesFrameCommunitiesListListScrollFrame:StripTextures()

	hooksecurefunc(_G.CommunitiesListEntryMixin, "SetClubInfo", function(self, clubInfo, isInvitation, isTicket)
		if clubInfo then
			self.Background:Hide()
			self.CircleMask:Hide()

			self.Icon:ClearAllPoints()
			self.Icon:SetPoint("TOPLEFT", 8, -17)
			S:HandleIcon(self.Icon)
			self.IconRing:Hide()

			if not self.IconBorder then
				self.IconBorder = self:CreateTexture(nil, "BORDER")
				self.IconBorder:SetOutside(self.Icon)
				self.IconBorder:Hide()
			end

			self.GuildTabardBackground:SetPoint("TOPLEFT", 6, -17)
			self.GuildTabardEmblem:SetPoint("TOPLEFT", 11, -17)
			self.GuildTabardBorder:SetPoint("TOPLEFT", 6, -17)

			if not self.bg then
				self.bg = CreateFrame("Frame", nil, self)
				self.bg:CreateBackdrop("Transparent")
				self.bg:SetPoint("TOPLEFT", 7, -16)
				self.bg:SetPoint("BOTTOMRIGHT", -10, 12)
			end

			local isGuild = clubInfo.clubType == Enum.ClubType.Guild
			if isGuild then
				self.Selection:SetAllPoints(self.bg)
				self.Selection:SetColorTexture(0, 1, 0, 0.2)
			else
				self.Selection:SetAllPoints(self.bg)
				self.Selection:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, 0.2)
			end

			if not isInvitation and not isGuild and not isTicket then
				if clubInfo.clubType == _G.Enum.ClubType.BattleNet then
					self.IconBorder:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b)
				else
					self.IconBorder:SetColorTexture(FRIENDS_WOW_BACKGROUND_COLOR.r, FRIENDS_WOW_BACKGROUND_COLOR.g, FRIENDS_WOW_BACKGROUND_COLOR.b)
				end
				self.IconBorder:Show()
			else
				self.IconBorder:Hide()
			end

			local highlight = self:GetHighlightTexture()
			highlight:SetColorTexture(1, 1, 1, 0.3)
			highlight:SetAllPoints(self.bg)
		end
	end)

	-- Add Community Button
	hooksecurefunc(_G.CommunitiesListEntryMixin, "SetAddCommunity", function(self)
		self.Background:Hide()
		self.CircleMask:Hide()

		S:HandleIcon(self.Icon)
		self.Icon:Point("TOPLEFT", 8, -20)
		self.IconRing:Hide()

		if not self.bg then
			self.bg = CreateFrame("Frame", nil, self)
			self.bg:CreateBackdrop("Transparent")
			self.bg:SetPoint("TOPLEFT", 7, -16)
			self.bg:SetPoint("BOTTOMRIGHT", -10, 12)
		end

		local highlight = self:GetHighlightTexture()
		highlight:SetColorTexture(1, 1, 1, 0.3)
		highlight:SetInside(self.bg)
	end)

	S:HandleItemButton(CommunitiesFrame.ChatTab)
	CommunitiesFrame.ChatTab:Point('TOPLEFT', '$parent', 'TOPRIGHT', E.PixelMode and 0 or E.Border + E.Spacing, -36)
	S:HandleItemButton(CommunitiesFrame.RosterTab)
	S:HandleItemButton(CommunitiesFrame.GuildBenefitsTab)
	S:HandleItemButton(CommunitiesFrame.GuildInfoTab)

	S:HandleInsetFrame(CommunitiesFrame.CommunitiesList)
	S:HandleMaxMinFrame(CommunitiesFrame.MaximizeMinimizeFrame)
	CommunitiesFrame.MaximizeMinimizeFrame:ClearAllPoints()
	CommunitiesFrame.MaximizeMinimizeFrame:Point("RIGHT", CommunitiesFrame.CloseButton, "LEFT", 12, 0)

	S:HandleButton(CommunitiesFrame.InviteButton)
	CommunitiesFrame.AddToChatButton:ClearAllPoints()
	CommunitiesFrame.AddToChatButton:Point("BOTTOM", CommunitiesFrame.ChatEditBox, "BOTTOMRIGHT", -5, -30) -- needs probably adjustment
	S:HandleButton(CommunitiesFrame.AddToChatButton)

	S:HandleScrollBar(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar)
	S:HandleScrollBar(CommunitiesFrame.Chat.MessageFrame.ScrollBar)
	S:HandleScrollBar(_G.CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar)

	S:HandleDropDownBox(CommunitiesFrame.StreamDropDownMenu)
	S:HandleDropDownBox(CommunitiesFrame.CommunitiesListDropDownMenu, nil, true) -- use an override here to adjust the damn text position >.>

	hooksecurefunc(_G.CommunitiesNotificationSettingsStreamEntryMixin, "SetFilter", function(self)
		self.ShowNotificationsButton:SetSize(20, 20)
		self.HideNotificationsButton:SetSize(20, 20)
		S:HandleCheckBox(self.ShowNotificationsButton)
		S:HandleCheckBox(self.HideNotificationsButton)
	end)

	-- [[ CHAT TAB ]]
	CommunitiesFrame.MemberList:StripTextures()
	CommunitiesFrame.MemberList.InsetFrame:Hide()
	CommunitiesFrame.MemberList.WatermarkFrame:Hide()

	CommunitiesFrame.Chat:StripTextures()
	CommunitiesFrame.Chat.InsetFrame:SetTemplate("Transparent")

	S:HandleEditBox(CommunitiesFrame.ChatEditBox)
	CommunitiesFrame.ChatEditBox:Size(120, 20)

	-- GuildFinder Frame
	CommunitiesFrame.GuildFinderFrame:StripTextures()
	S:HandleButton(CommunitiesFrame.GuildFinderFrame.FindAGuildButton)
	--S:HandleDropDownBox(CommunitiesFrame.GuildFinderFrame.OptionsList.ClubFocusDropdown)
	--S:HandleDropDownBox(CommunitiesFrame.GuildFinderFrame.OptionsList.ClubSizeDropdown)

	--S:HandleEditBox(CommunitiesFrame.GuildFinderFrame.OptionsList.SearchBox)
	--CommunitiesFrame.GuildFinderFrame.OptionsList.SearchBox:SetSize(118, 20)
	--CommunitiesFrame.GuildFinderFrame.OptionsList.Search:ClearAllPoints()
	--CommunitiesFrame.GuildFinderFrame.OptionsList.Search:SetPoint("TOP", CommunitiesFrame.GuildFinderFrame.OptionsList.SearchBox, "BOTTOM", 0, -3)
	--S:HandleButton(CommunitiesFrame.GuildFinderFrame.OptionsList.Search)
	--S:HandleButton(CommunitiesFrame.GuildFinderFrame.PendingClubs)

	-- Member Details
	CommunitiesFrame.GuildMemberDetailFrame:StripTextures()
	CommunitiesFrame.GuildMemberDetailFrame:CreateBackdrop("Transparent")

	CommunitiesFrame.GuildMemberDetailFrame.NoteBackground:SetTemplate("Transparent")
	CommunitiesFrame.GuildMemberDetailFrame.OfficerNoteBackground:SetTemplate("Transparent")
	S:HandleCloseButton(CommunitiesFrame.GuildMemberDetailFrame.CloseButton)
	S:HandleButton(CommunitiesFrame.GuildMemberDetailFrame.RemoveButton)
	S:HandleButton(CommunitiesFrame.GuildMemberDetailFrame.GroupInviteButton)
	local DropDown = CommunitiesFrame.GuildMemberDetailFrame.RankDropdown
	S:HandleDropDownBox(DropDown, 160)
	DropDown.backdrop:Point("TOPLEFT", 0, -6)
	DropDown.backdrop:Point("BOTTOMRIGHT", -12, 6)
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
	S:HandleCheckBox(CommunitiesFrame.MemberList.ShowOfflineButton)
	CommunitiesFrame.MemberList.ShowOfflineButton:Size(25, 25)

	hooksecurefunc(CommunitiesFrame.MemberList, "RefreshListDisplay", function(self)
		for i = 1, self.ColumnDisplay:GetNumChildren() do
			local child = select(i, self.ColumnDisplay:GetChildren())
			if not child.IsSkinned then
				child:StripTextures()
				child:SetTemplate("Transparent")

				child.IsSkinned = true
			end
		end

		for _, button in ipairs(self.ListScrollFrame.buttons or {}) do
			if button and not button.hooked then
				hooksecurefunc(button, "RefreshExpandedColumns", UpdateNames)
				if button.ProfessionHeader then
					local header = button.ProfessionHeader
					for i = 1, 3 do
						select(i, header:GetRegions()):Hide()
					end
					header:SetTemplate("Transparent")
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
		local button = _G["CommunitiesFrameContainerButton"..i]
		button:DisableDrawLayer("BACKGROUND")
		button:DisableDrawLayer("BORDER")
		button:CreateBackdrop()

		button.Icon:SetTexCoord(unpack(E.TexCoords))
	end

	GuildBenefitsFrame.Rewards.TitleText:FontTemplate(nil, 14)

	GuildBenefitsFrame.Rewards.Bg:Hide()

	S:HandleScrollBar(_G.CommunitiesFrameRewards.scrollBar)

	for _, button in pairs(CommunitiesFrame.GuildBenefitsFrame.Rewards.RewardsContainer.buttons) do
		if not button.backdrop then
			button:CreateBackdrop()
		end

		button:SetNormalTexture("")
		button:SetHighlightTexture("")

		if not button.hover then
			local hover = button:CreateTexture()
			hover:SetColorTexture(1, 1, 1, 0.3)
			hover:SetInside(button.backdrop)
			button:SetHighlightTexture(hover)
			button.hover = hover
		end

		button.Icon:SetTexCoord(unpack(E.TexCoords))
		if not button.Icon.backdrop then
			button.Icon:CreateBackdrop()
			button.Icon.backdrop:SetOutside(button.Icon, 1, 1)
			button.Icon.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() + 1)
		end
	end

	hooksecurefunc("CommunitiesGuildRewards_Update", function()
		for _, button in pairs(CommunitiesFrame.GuildBenefitsFrame.Rewards.RewardsContainer.buttons) do
			if button.index then
				local _, itemID = GetGuildRewardInfo(button.index)
				local _, _, quality = GetItemInfo(itemID)
				if quality and quality > 1 then
					button.Icon.backdrop:SetBackdropBorderColor(GetItemQualityColor(quality))
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

	local bg = CreateFrame("Frame", nil, StatusBar)
	bg:Point("TOPLEFT", 0, -3)
	bg:Point("BOTTOMRIGHT", 0, 1)
	bg:SetFrameLevel(StatusBar:GetFrameLevel())
	bg:CreateBackdrop()

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
		"CommunitiesFrameGuildDetailsFrameInfo",
		"CommunitiesFrameGuildDetailsFrameNews",
		"CommunitiesGuildNewsFiltersFrame",
	}

	for _, frame in pairs(striptextures) do
		_G[frame]:StripTextures()
	end

	S:HandleScrollBar(_G.CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrameScrollBar)

	hooksecurefunc("GuildNewsButton_SetNews", function(button, news_id)
		local newsInfo = C_GuildInfo_GetGuildNewsInfo(news_id)
		if newsInfo then
			if button.header:IsShown() then
				button.header:SetAlpha(0)
			end
		end
	end)

	-- Guild Challenges Background
	local GuildDetailsFrameInfo = _G.CommunitiesFrameGuildDetailsFrameInfo
	local backdrop1 = CreateFrame("Frame", nil, GuildDetailsFrameInfo)
	backdrop1:SetTemplate("Transparent")
	backdrop1:SetFrameLevel(GuildDetailsFrameInfo:GetFrameLevel() - 1)
	backdrop1:Point("TOPLEFT", GuildDetailsFrameInfo, "TOPLEFT", 14, -22)
	backdrop1:Point("BOTTOMRIGHT", GuildDetailsFrameInfo, "BOTTOMRIGHT", 0, 200)

	-- Guild MOTD Background
	local backdrop2 = CreateFrame("Frame", nil, GuildDetailsFrameInfo)
	backdrop2:SetTemplate("Transparent")
	backdrop2:SetFrameLevel(GuildDetailsFrameInfo:GetFrameLevel() - 1)
	backdrop2:Point("TOPLEFT", GuildDetailsFrameInfo, "TOPLEFT", 14, -158)
	backdrop2:Point("BOTTOMRIGHT", GuildDetailsFrameInfo, "BOTTOMRIGHT", 0, 118)

	-- Guild Information Background
	local backdrop3 = CreateFrame("Frame", nil, GuildDetailsFrameInfo)
	backdrop3:SetTemplate("Transparent")
	backdrop3:SetFrameLevel(GuildDetailsFrameInfo:GetFrameLevel() - 1)
	backdrop3:Point("TOPLEFT", GuildDetailsFrameInfo, "TOPLEFT", 14, -236)
	backdrop3:Point("BOTTOMRIGHT", GuildDetailsFrameInfo, "BOTTOMRIGHT", -7, 1)

	-- Guild News Background
	local backdrop4 = CreateFrame("Frame", nil, GuildDetailsFrameInfo)
	backdrop4:SetTemplate("Transparent")
	backdrop4:SetFrameLevel(GuildDetailsFrameInfo:GetFrameLevel() - 1)
	backdrop4:Point("TOPLEFT", GuildDetailsFrameInfo, "TOPLEFT", 591, -22)
	backdrop4:Point("BOTTOMRIGHT", GuildDetailsFrameInfo, "BOTTOMRIGHT", 18, 1)

	_G.CommunitiesFrameGuildDetailsFrameInfo.TitleText:FontTemplate(nil, 14)
	_G.CommunitiesFrameGuildDetailsFrameNews.TitleText:FontTemplate(nil, 14)

	S:HandleScrollBar(_G.CommunitiesFrameGuildDetailsFrameInfoScrollBar)
	S:HandleScrollBar(_G.CommunitiesFrameGuildDetailsFrameNewsContainer.ScrollBar)
	S:HandleButton(CommunitiesFrame.GuildLogButton)

	-- Filters Frame
	local FiltersFrame = _G.CommunitiesGuildNewsFiltersFrame
	FiltersFrame:CreateBackdrop("Transparent")
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
	EditFrame:SetTemplate("Transparent")
	EditFrame.Container:SetTemplate("Transparent")
	S:HandleScrollBar(_G.CommunitiesGuildTextEditFrameScrollBar)
	S:HandleButton(_G.CommunitiesGuildTextEditFrameAcceptButton)

	local closeButton = select(4, _G.CommunitiesGuildTextEditFrame:GetChildren())
	S:HandleButton(closeButton)
	S:HandleCloseButton(_G.CommunitiesGuildTextEditFrameCloseButton)

	-- Guild Log
	local GuildLogFrame = _G.CommunitiesGuildLogFrame
	GuildLogFrame:StripTextures()
	GuildLogFrame.Container:StripTextures()
	GuildLogFrame:CreateBackdrop("Transparent")

	S:HandleScrollBar(_G.CommunitiesGuildLogFrameScrollBar, 4)
	S:HandleCloseButton(_G.CommunitiesGuildLogFrameCloseButton)
	closeButton = select(3, _G.CommunitiesGuildLogFrame:GetChildren()) -- swap local variable
	S:HandleButton(closeButton)

	-- Recruitment Info
	local RecruitmentFrame = _G.CommunitiesGuildRecruitmentFrame
	RecruitmentFrame:StripTextures()
	RecruitmentFrame:CreateBackdrop("Transparent")
	_G.CommunitiesGuildRecruitmentFrameInset:StripTextures(false)

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
		S:HandleTab(_G["CommunitiesGuildRecruitmentFrameTab"..i])
	end

	CommunitiesGuildRecruitmentFrameRecruitment.CommentFrame.CommentInputFrame:StripTextures()
	S:HandleEditBox(CommunitiesGuildRecruitmentFrameRecruitment.CommentFrame.CommentInputFrame)

	-- Recruitment Request
	local CommunitiesGuildRecruitmentFrameApplicants = _G.CommunitiesGuildRecruitmentFrameApplicants
	S:HandleButton(CommunitiesGuildRecruitmentFrameApplicants.InviteButton)
	S:HandleButton(CommunitiesGuildRecruitmentFrameApplicants.MessageButton)
	S:HandleButton(CommunitiesGuildRecruitmentFrameApplicants.DeclineButton)

	for i = 1, 5 do
		_G["CommunitiesGuildRecruitmentFrameApplicantsContainerButton"..i]:SetBackdrop(nil)
	end

	-- Notification Settings Dialog
	local NotificationSettings = _G.CommunitiesFrame.NotificationSettingsDialog
	NotificationSettings:StripTextures()
	NotificationSettings:CreateBackdrop("Transparent")
	NotificationSettings.backdrop:SetAllPoints()

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
	EditStreamDialog:CreateBackdrop("Transparent")
	EditStreamDialog.backdrop:SetAllPoints()

	S:HandleEditBox(EditStreamDialog.NameEdit)
	EditStreamDialog.NameEdit:Size(280, 20)
	S:HandleEditBox(EditStreamDialog.Description)
	S:HandleCheckBox(EditStreamDialog.TypeCheckBox)

	S:HandleButton(EditStreamDialog.Accept)
	S:HandleButton(EditStreamDialog.Cancel)

	-- Communities Settings
	local Settings = _G.CommunitiesSettingsDialog
	Settings:StripTextures()
	Settings:CreateBackdrop("Transparent")
	Settings.backdrop:SetAllPoints()

	Settings.IconPreview:SetTexCoord(unpack(E.TexCoords))
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
	Avatar:CreateBackdrop("Transparent")
	Avatar.backdrop:SetAllPoints()

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

	TicketManager:CreateBackdrop("Transparent")
	TicketManager.backdrop:SetAllPoints()

	S:HandleButton(TicketManager.LinkToChat)
	S:HandleButton(TicketManager.Copy)
	S:HandleButton(TicketManager.Close)
	S:HandleButton(TicketManager.GenerateLinkButton)

	S:HandleDropDownBox(TicketManager.ExpiresDropDownMenu)
	S:HandleDropDownBox(TicketManager.UsesDropDownMenu)

	S:HandleScrollBar(TicketManager.InviteManager.ListScrollFrame.scrollBar)
	S:HandleButton(TicketManager.MaximizeButton)
end

S:AddCallbackForAddon("Blizzard_Communities", "Communities", LoadSkin)
