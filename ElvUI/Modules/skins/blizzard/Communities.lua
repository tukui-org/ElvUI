local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local ipairs, pairs, select, unpack = ipairs, pairs, select, unpack
--WoW API / Variables
local C_CreatureInfo_GetClassInfo = C_CreatureInfo.GetClassInfo
local FRIENDS_BNET_BACKGROUND_COLOR = FRIENDS_BNET_BACKGROUND_COLOR
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local GetGuildRewardInfo = GetGuildRewardInfo
local GetItemQualityColor = GetItemQualityColor
local GetItemInfo = GetItemInfo
local Enum = Enum
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CLASS_ICON_TCOORDS

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Communities ~= true then return end

	local CommunitiesFrame = _G["CommunitiesFrame"]
	CommunitiesFrame:StripTextures()
	CommunitiesFrame.NineSlice:Hide()
	CommunitiesFrameInset.Bg:Hide()
	CommunitiesFrame.PortraitOverlay:Kill()
	CommunitiesFrame.PortraitOverlay.Portrait:Hide()
	CommunitiesFrame.CommunitiesList.InsetFrame:StripTextures()

	CommunitiesFrame:CreateBackdrop("Transparent")

	local CommunitiesFrameCommunitiesList = _G["CommunitiesFrameCommunitiesList"]
	CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide()
	CommunitiesFrameCommunitiesList.Bg:Hide()
	CommunitiesFrameCommunitiesList.TopFiligree:Hide()
	CommunitiesFrameCommunitiesList.BottomFiligree:Hide()
	CommunitiesFrameCommunitiesListListScrollFrame:StripTextures()

	hooksecurefunc(CommunitiesListEntryMixin, "SetClubInfo", function(self, clubInfo)
		if clubInfo then
			self:SetSize(166, 67)

			--select(13, self:GetRegions()):Hide() -- Hide the mouseover texture
			self.Background:Hide()
			self:SetFrameLevel(self:GetFrameLevel()+5)

			S:HandleTexture(self.Icon)
			self.Icon:RemoveMaskTexture(self.CircleMask)
			self.Icon:SetDrawLayer("OVERLAY", 1)
			self.Icon:SetTexCoord(unpack(E.TexCoords))
			self.IconRing:Hide()

			if not self.bg then
				self.bg = CreateFrame("Frame", nil, self)
				self.bg:CreateBackdrop("Overlay")
				self.bg:SetFrameLevel(self:GetFrameLevel() -2)
				self.bg:Point("TOPLEFT", 4, -3)
				self.bg:Point("BOTTOMRIGHT", -1, 3)
			end

			local isGuild = clubInfo.clubType == Enum.ClubType.Guild
			if isGuild then
				self.Selection:SetInside(self.bg)
				self.Selection:SetColorTexture(0, 1, 0, 0.2)
			else
				self.Selection:SetInside(self.bg)
				self.Selection:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, 0.2)
			end

			local highlight = self:GetHighlightTexture()
			highlight:SetColorTexture(1, 1, 1, 0.3)
			highlight:SetInside(self.bg)
		end
	end)

	hooksecurefunc(CommunitiesListEntryMixin, "SetAddCommunity", function(self)
		self:SetSize(166, 67)

		--select(13, self:GetRegions()):Hide() -- Hide the mouseover texture (needs some love)
		self.Background:Hide()
		self:SetFrameLevel(self:GetFrameLevel()+5)
		S:HandleTexture(self.Icon)
		self.CircleMask:Hide()
		self.Icon:SetDrawLayer("OVERLAY", 1)
		self.Icon:SetTexCoord(unpack(E.TexCoords))
		self.IconRing:Hide()

		if not self.bg then
			self.bg = CreateFrame("Frame", nil, self)
			self.bg:CreateBackdrop("Overlay")
			self.bg:SetFrameLevel(self:GetFrameLevel() -2)
			self.bg:Point("TOPLEFT", 4, -3)
			self.bg:Point("BOTTOMRIGHT", -1, 3)
		end

		local highlight = self:GetHighlightTexture()
		highlight:SetColorTexture(1, 1, 1, 0.3)
		highlight:SetInside(self.bg)
	end)

	local function SkinTab(tab)
		local normTex = tab:GetNormalTexture()
		if normTex then
			normTex:SetTexCoord(unpack(E.TexCoords))
			normTex:SetInside()
		end

		if not tab.isSkinned then
			for i = 1, tab:GetNumRegions() do
				local region = select(i, tab:GetRegions())
				if region:GetObjectType() == "Texture" then
					if region:GetTexture() == "Interface\\SpellBook\\SpellBook-SkillLineTab" then
						region:Kill()
					end
				end
			end

			tab.pushed = true;
			tab:CreateBackdrop("Default")
			tab.backdrop:Point("TOPLEFT", -2, 2)
			tab.backdrop:Point("BOTTOMRIGHT", 2, -2)
			tab:StyleButton(true)
			tab.Icon:SetTexCoord(unpack(E.TexCoords))

			hooksecurefunc(tab:GetHighlightTexture(), "SetTexture", function(self, texPath)
				if texPath ~= nil then
					self:SetPushedTexture(nil);
				end
			end)

			hooksecurefunc(tab:GetCheckedTexture(), "SetTexture", function(self, texPath)
				if texPath ~= nil then
					self:SetHighlightTexture(nil);
				end
			end)

			local point, relatedTo, point2, _, y = tab:GetPoint()
			tab:Point(point, relatedTo, point2, 1, y)
		end

		tab.isSkinned = true
	end
	SkinTab(CommunitiesFrame.ChatTab)
	SkinTab(CommunitiesFrame.RosterTab)
	SkinTab(CommunitiesFrame.GuildBenefitsTab)
	SkinTab(CommunitiesFrame.GuildInfoTab)

	S:HandleInsetFrameTemplate(CommunitiesFrame.CommunitiesList)
	S:HandleMaxMinFrame(CommunitiesFrame.MaximizeMinimizeFrame)
	S:HandleCloseButton(CommunitiesFrameCloseButton)
	S:HandleButton(CommunitiesFrame.InviteButton)
	CommunitiesFrame.AddToChatButton:ClearAllPoints()
	CommunitiesFrame.AddToChatButton:SetPoint("BOTTOM", CommunitiesFrame.ChatEditBox, "BOTTOMRIGHT", -5, -30) -- needs probably adjustment
	S:HandleButton(CommunitiesFrame.AddToChatButton)
	S:HandleButton(CommunitiesFrame.GuildFinderFrame.FindAGuildButton)

	S:HandleScrollSlider(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar)
	S:HandleScrollSlider(CommunitiesFrame.Chat.MessageFrame.ScrollBar)
	S:HandleScrollSlider(CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar)

	S:HandleDropDownFrame(CommunitiesFrame.StreamDropDownMenu)
	S:HandleDropDownFrame(CommunitiesFrame.CommunitiesListDropDownMenu)

	-- [[ CHAT TAB ]]
	CommunitiesFrame.MemberList:StripTextures()
	CommunitiesFrame.MemberList.InsetFrame:Hide()
	CommunitiesFrame.MemberList.WatermarkFrame:Hide()

	CommunitiesFrame.Chat:StripTextures()
	CommunitiesFrame.Chat.InsetFrame:SetTemplate("Transparent")

	CommunitiesFrame.GuildFinderFrame:StripTextures()

	S:HandleEditBox(CommunitiesFrame.ChatEditBox)
	CommunitiesFrame.ChatEditBox:SetSize(120, 20)

	-- Member Details
	CommunitiesFrame.GuildMemberDetailFrame:StripTextures()
	CommunitiesFrame.GuildMemberDetailFrame:CreateBackdrop("Transparent")

	CommunitiesFrame.GuildMemberDetailFrame.NoteBackground:SetTemplate("Transparent")
	CommunitiesFrame.GuildMemberDetailFrame.OfficerNoteBackground:SetTemplate("Transparent")
	S:HandleCloseButton(CommunitiesFrame.GuildMemberDetailFrame.CloseButton)
	S:HandleButton(CommunitiesFrame.GuildMemberDetailFrame.RemoveButton)
	S:HandleButton(CommunitiesFrame.GuildMemberDetailFrame.GroupInviteButton)
	S:HandleDropDownFrame(CommunitiesFrame.GuildMemberDetailFrame.RankDropdown)

	-- [[ ROSTER TAB ]]
	local MemberList = CommunitiesFrame.MemberList
	local ColumnDisplay = MemberList.ColumnDisplay
	ColumnDisplay:StripTextures()
	ColumnDisplay.InsetBorderLeft:Hide()
	ColumnDisplay.InsetBorderBottomLeft:Hide()
	ColumnDisplay.InsetBorderTopLeft:Hide()
	ColumnDisplay.InsetBorderTop:Hide()

	S:HandleInsetFrameTemplate(CommunitiesFrame.MemberList.InsetFrame)
	S:HandleDropDownFrame(CommunitiesFrame.GuildMemberListDropDownMenu)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton)
	S:HandleCheckBox(CommunitiesFrame.MemberList.ShowOfflineButton)
	CommunitiesFrame.MemberList.ShowOfflineButton:SetSize(25, 25)

	local function UpdateNames(self)
		if not self.expanded then return end

		local memberInfo = self:GetMemberInfo()
		if memberInfo and memberInfo.classID then
			local classInfo = C_CreatureInfo_GetClassInfo(memberInfo.classID)
			if classInfo then
				local tcoords = CLASS_ICON_TCOORDS[classInfo.classFile]
				self.Class:SetTexCoord(tcoords[1] + .022, tcoords[2] - .025, tcoords[3] + .022, tcoords[4] - .025)
			end
		end
	end

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
		button:CreateBackdrop("Default")

		button.Icon:SetTexCoord(unpack(E.TexCoords))
	end

	GuildBenefitsFrame.Rewards.TitleText:FontTemplate(nil, 14)

	GuildBenefitsFrame.Rewards.Bg:Hide()

	S:HandleScrollSlider(CommunitiesFrameRewards.scrollBar)

	for _, button in pairs(CommunitiesFrame.GuildBenefitsFrame.Rewards.RewardsContainer.buttons) do
		if not button.backdrop then
			button:CreateBackdrop("Default")
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
			button.Icon:CreateBackdrop("Default")
			button.Icon.backdrop:SetOutside(button.Icon, 1, 1)
			button.Icon.backdrop:SetFrameLevel(button.backdrop:GetFrameLevel() + 1)
		end
	end

	hooksecurefunc("CommunitiesGuildRewards_Update", function(self)
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
	bg:SetPoint("TOPLEFT", 0, -3)
	bg:SetPoint("BOTTOMRIGHT", 0, 1)
	bg:SetFrameLevel(StatusBar:GetFrameLevel())
	bg:CreateBackdrop("Default")

	-- [[ INFO TAB ]]
	local GuildDetails = _G["CommunitiesFrameGuildDetailsFrame"]
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

	hooksecurefunc("CommunitiesGuildNewsButton_SetNews", function(button)
		if button.header:IsShown() then
			button.header:SetAlpha(0)
		end
	end)

	-- Guild Challenges Background
	local GuildDetailsFrameInfo = _G["CommunitiesFrameGuildDetailsFrameInfo"]
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

	CommunitiesFrameGuildDetailsFrameInfo.TitleText:FontTemplate(nil, 14)
	CommunitiesFrameGuildDetailsFrameNews.TitleText:FontTemplate(nil, 14)

	S:HandleScrollBar(CommunitiesFrameGuildDetailsFrameInfoScrollBar)
	S:HandleScrollSlider(CommunitiesFrameGuildDetailsFrameNewsContainer.ScrollBar)
	S:HandleButton(CommunitiesFrame.GuildLogButton)

	-- Filters Frame
	local FiltersFrame = _G["CommunitiesGuildNewsFiltersFrame"]
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
	local EditFrame = _G["CommunitiesGuildTextEditFrame"]
	EditFrame:StripTextures()
	EditFrame:SetTemplate("Transparent")
	EditFrame.Container:SetTemplate("Transparent")
	S:HandleScrollBar(CommunitiesGuildTextEditFrameScrollBar)
	S:HandleButton(CommunitiesGuildTextEditFrameAcceptButton)
	local closeButton = select(4, CommunitiesGuildTextEditFrame:GetChildren())
	S:HandleButton(closeButton)
	S:HandleCloseButton(CommunitiesGuildTextEditFrameCloseButton)

	-- Guild Log
	local GuildLogFrame = _G["CommunitiesGuildLogFrame"]
	GuildLogFrame:StripTextures()
	GuildLogFrame.Container:StripTextures()
	GuildLogFrame:CreateBackdrop("Transparent")

	S:HandleScrollBar(CommunitiesGuildLogFrameScrollBar, 4)
	S:HandleCloseButton(CommunitiesGuildLogFrameCloseButton)
	local closeButton = select(3, CommunitiesGuildLogFrame:GetChildren())
	S:HandleButton(closeButton)

	-- Recruitment Info
	local RecruitmentFrame = _G["CommunitiesGuildRecruitmentFrame"]
	RecruitmentFrame:StripTextures()
	RecruitmentFrame:CreateBackdrop("Transparent")
	CommunitiesGuildRecruitmentFrameInset:StripTextures(false)

	-- CheckBoxes
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

	S:HandleCloseButton(CommunitiesGuildRecruitmentFrameCloseButton)

	S:HandleButton(CommunitiesGuildRecruitmentFrameRecruitment.ListGuildButton)

	-- Tabs
	for i = 1, 2 do
		S:HandleTab(_G["CommunitiesGuildRecruitmentFrameTab"..i])
	end

	CommunitiesGuildRecruitmentFrameRecruitment.CommentFrame.CommentInputFrame:StripTextures()
	S:HandleEditBox(CommunitiesGuildRecruitmentFrameRecruitment.CommentFrame.CommentInputFrame)

	-- Recruitment Request
	S:HandleButton(CommunitiesGuildRecruitmentFrameApplicants.InviteButton)
	S:HandleButton(CommunitiesGuildRecruitmentFrameApplicants.MessageButton)
	S:HandleButton(CommunitiesGuildRecruitmentFrameApplicants.DeclineButton)

	for i = 1, 5 do
		local bu = _G["CommunitiesGuildRecruitmentFrameApplicantsContainerButton"..i]
		bu:SetBackdrop(nil)
	end

	-- Notification Settings Dialog
	local NotificationSettings = _G["CommunitiesFrame"].NotificationSettingsDialog
	NotificationSettings:StripTextures()
	NotificationSettings:CreateBackdrop("Transparent")
	NotificationSettings.backdrop:SetAllPoints()

	S:HandleDropDownFrame(CommunitiesFrame.NotificationSettingsDialog.CommunitiesListDropDownMenu)
	S:HandleCheckBox(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame.Child.QuickJoinButton)
	S:HandleButton(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame.Child.AllButton)
	S:HandleButton(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame.Child.NoneButton)
	S:HandleButton(CommunitiesFrame.NotificationSettingsDialog.OkayButton)
	S:HandleButton(CommunitiesFrame.NotificationSettingsDialog.CancelButton)
	S:HandleScrollSlider(CommunitiesFrame.NotificationSettingsDialog.ScrollFrame.ScrollBar) -- Adjust me

	-- Create Channel Dialog
	local EditStreamDialog = CommunitiesFrame.EditStreamDialog
	EditStreamDialog:StripTextures()
	EditStreamDialog:CreateBackdrop("Transparent")
	EditStreamDialog.backdrop:SetAllPoints()

	S:HandleEditBox(EditStreamDialog.NameEdit)
	EditStreamDialog.NameEdit:SetSize(280, 20)
	S:HandleEditBox(EditStreamDialog.Description)
	S:HandleCheckBox(EditStreamDialog.TypeCheckBox)

	S:HandleButton(EditStreamDialog.Accept)
	S:HandleButton(EditStreamDialog.Cancel)

	-- Communities Settings
	local Settings = _G["CommunitiesSettingsDialog"]
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
	local Avatar = _G["CommunitiesAvatarPickerDialog"]
	Avatar:StripTextures()
	Avatar:CreateBackdrop("Transparent")
	Avatar.backdrop:SetAllPoints()

	Avatar.ScrollFrame:StripTextures()
	S:HandleScrollBar(CommunitiesAvatarPickerDialogScrollBar)

	S:HandleButton(Avatar.OkayButton)
	S:HandleButton(Avatar.CancelButton)

	-- Invite Frame
	local TicketManager = _G["CommunitiesTicketManagerDialog"]
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

	S:HandleDropDownFrame(TicketManager.ExpiresDropDownMenu)
	S:HandleDropDownFrame(TicketManager.UsesDropDownMenu)

	S:HandleScrollSlider(TicketManager.InviteManager.ListScrollFrame.scrollBar)
	S:HandleButton(TicketManager.MaximizeButton)
end

S:AddCallbackForAddon("Blizzard_Communities", "Communities", LoadSkin)
