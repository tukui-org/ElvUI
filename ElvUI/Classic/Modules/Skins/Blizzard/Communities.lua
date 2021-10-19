local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local ipairs, select, unpack = ipairs, select, unpack

local C_CreatureInfo_GetClassInfo = C_CreatureInfo.GetClassInfo
local FRIENDS_BNET_BACKGROUND_COLOR = FRIENDS_BNET_BACKGROUND_COLOR
local FRIENDS_WOW_BACKGROUND_COLOR = FRIENDS_WOW_BACKGROUND_COLOR
local BATTLENET_FONT_COLOR = BATTLENET_FONT_COLOR
local GREEN_FONT_COLOR = GREEN_FONT_COLOR
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

local ClubTypeGuild = Enum.ClubType.Guild
local ClubTypeBattleNet = Enum.ClubType.BattleNet

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

local function HandleCommunitiesButtons(self, color)
	self.Background:Hide()
	self.CircleMask:Hide()
	self:SetFrameLevel(self:GetFrameLevel() + 5)

	S:HandleIcon(self.Icon)
	self.Icon:Point('TOPLEFT', 8, -20)
	self.IconRing:Hide()

	if not self.bg then
		self.bg = CreateFrame('Frame', nil, self)
		self.bg:CreateBackdrop('Transparent')
		self.bg:SetPoint('TOPLEFT', 7, -16)
		self.bg:SetPoint('BOTTOMRIGHT', -10, 12)
	end

	if color then
		self.Selection:ClearAllPoints()
		self.Selection:SetAllPoints(self.bg)

		if color == 1 then
			self.Selection:SetColorTexture(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, 0.2)
		else
			self.Selection:SetColorTexture(BATTLENET_FONT_COLOR.r, BATTLENET_FONT_COLOR.g, BATTLENET_FONT_COLOR.b, 0.2)
		end
	end

	local highlight = self:GetHighlightTexture()
	highlight:SetColorTexture(1, 1, 1, 0.3)
	highlight:SetInside(self.bg)
end

function S:Blizzard_Communities()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.communities) then return end

	local CommunitiesFrame = _G.CommunitiesFrame
	CommunitiesFrame:StripTextures()
	_G.CommunitiesFrameInset.Bg:Hide()
	CommunitiesFrame.CommunitiesList.InsetFrame:StripTextures()

	S:HandleFrame(CommunitiesFrame, true, nil, -5, 0, -1, 0)

	_G.CommunitiesFrameCloseButton:Point('TOPRIGHT', 0, 2)

	local CommunitiesFrameCommunitiesList = _G.CommunitiesFrameCommunitiesList
	CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide()
	CommunitiesFrameCommunitiesList.Bg:Hide()
	CommunitiesFrameCommunitiesList.TopFiligree:Hide()
	CommunitiesFrameCommunitiesList.BottomFiligree:Hide()
	_G.CommunitiesFrameCommunitiesListListScrollFrame:StripTextures()

	for i = 1, 5 do
		S:HandleTab(_G['CommunitiesFrameTab'..i])
	end

	hooksecurefunc(_G.CommunitiesListEntryMixin, 'SetClubInfo', function(self, clubInfo, isInvitation, isTicket)
		if clubInfo then
			self.Background:Hide()
			self.CircleMask:Hide()

			self.Icon:ClearAllPoints()
			self.Icon:Point('TOPLEFT', 8, -17)
			S:HandleIcon(self.Icon)
			self.IconRing:Hide()

			if not self.IconBorder then
				self.IconBorder = self:CreateTexture(nil, 'BORDER')
				self.IconBorder:SetOutside(self.Icon)
				self.IconBorder:Hide()
			end

			if not self.bg then
				self.bg = CreateFrame('Frame', nil, self)
				self.bg:CreateBackdrop('Transparent')
				self.bg:Point('TOPLEFT', 7, -16)
				self.bg:Point('BOTTOMRIGHT', -10, 12)
			end

			self.Selection:ClearAllPoints()
			self.Selection:SetAllPoints(self.bg)

			local isGuild = clubInfo.clubType == ClubTypeGuild
			if isGuild then
				self.Selection:SetColorTexture(0, 1, 0, 0.2)
			else
				self.Selection:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, 0.2)
			end

			if not isInvitation and not isGuild and not isTicket then
				if clubInfo.clubType == ClubTypeBattleNet then
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
	hooksecurefunc(_G.CommunitiesListEntryMixin, 'SetAddCommunity', function(self) HandleCommunitiesButtons(self, 1) end)
	--hooksecurefunc(_G.CommunitiesListEntryMixin, 'SetFindCommunity', function(self) HandleCommunitiesButtons(self, 2) end) -- Not on classic.. huh!?

	S:HandleItemButton(CommunitiesFrame.ChatTab)
	CommunitiesFrame.ChatTab:Point('TOPLEFT', '$parent', 'TOPRIGHT', E.PixelMode and 0 or E.Border + E.Spacing, -36)
	S:HandleItemButton(CommunitiesFrame.RosterTab)

	S:HandleInsetFrame(CommunitiesFrame.CommunitiesList)
	S:HandleMaxMinFrame(CommunitiesFrame.MaximizeMinimizeFrame)

	S:HandleButton(CommunitiesFrame.InviteButton)
	CommunitiesFrame.AddToChatButton:ClearAllPoints()
	CommunitiesFrame.AddToChatButton:Point('BOTTOM', CommunitiesFrame.ChatEditBox, 'BOTTOMRIGHT', -5, -30) -- needs probably adjustment
	S:HandleNextPrevButton(CommunitiesFrame.AddToChatButton)

	S:HandleScrollBar(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar)
	S:HandleScrollBar(CommunitiesFrame.Chat.MessageFrame.ScrollBar)
	S:HandleScrollBar(_G.CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar)

	S:HandleDropDownBox(CommunitiesFrame.StreamDropDownMenu)
	S:HandleDropDownBox(CommunitiesFrame.CommunitiesListDropDownMenu, nil, true) -- use an override here to adjust the damn text position >.>

	hooksecurefunc(_G.CommunitiesNotificationSettingsStreamEntryMixin, 'SetFilter', function(self)
		self.ShowNotificationsButton:SetSize(20, 20)
		self.HideNotificationsButton:SetSize(20, 20)
		S:HandleCheckBox(self.ShowNotificationsButton)
		S:HandleCheckBox(self.HideNotificationsButton)
	end)

	-- [[ CHAT TAB ]]
	CommunitiesFrame.MemberList:StripTextures()
	CommunitiesFrame.MemberList.InsetFrame:Hide()

	CommunitiesFrame.Chat:StripTextures()
	CommunitiesFrame.Chat.InsetFrame:SetTemplate('Transparent')

	S:HandleEditBox(CommunitiesFrame.ChatEditBox)
	CommunitiesFrame.ChatEditBox:Size(120, 20)

	-- Member Details
	CommunitiesFrame.InvitationFrame:StripTextures()
	CommunitiesFrame.InvitationFrame:CreateBackdrop('Transparent')

	-- [[ ROSTER TAB ]]
	local MemberList = CommunitiesFrame.MemberList
	local ColumnDisplay = MemberList.ColumnDisplay
	ColumnDisplay:StripTextures()
	ColumnDisplay.InsetBorderLeft:Hide()
	ColumnDisplay.InsetBorderBottomLeft:Hide()
	ColumnDisplay.InsetBorderTopLeft:Hide()
	ColumnDisplay.InsetBorderTop:Hide()

	S:HandleInsetFrame(CommunitiesFrame.MemberList.InsetFrame)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton)
	S:HandleCheckBox(CommunitiesFrame.MemberList.ShowOfflineButton)
	CommunitiesFrame.MemberList.ShowOfflineButton:Size(25, 25)

	hooksecurefunc(CommunitiesFrame.MemberList, 'RefreshListDisplay', function(self)
		for i = 1, self.ColumnDisplay:GetNumChildren() do
			local child = select(i, self.ColumnDisplay:GetChildren())
			if not child.IsSkinned then
				child:StripTextures()
				child:SetTemplate('Transparent')

				child.IsSkinned = true
			end
		end

		for _, button in ipairs(self.ListScrollFrame.buttons or {}) do
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

	-- Notification Settings Dialog
	local NotificationSettings = _G.CommunitiesFrame.NotificationSettingsDialog
	NotificationSettings:StripTextures()
	NotificationSettings:CreateBackdrop('Transparent')
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
	EditStreamDialog:CreateBackdrop('Transparent')
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
	Settings:CreateBackdrop('Transparent')
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
	Avatar:CreateBackdrop('Transparent')
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

	TicketManager:CreateBackdrop('Transparent')
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

S:AddCallbackForAddon('Blizzard_Communities')
