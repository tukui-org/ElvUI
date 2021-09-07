local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local ipairs, pairs, select, unpack = ipairs, pairs, select, unpack

local C_CreatureInfo_GetClassInfo = C_CreatureInfo.GetClassInfo
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local BATTLENET_FONT_COLOR = BATTLENET_FONT_COLOR
local FRIENDS_BNET_BACKGROUND_COLOR = FRIENDS_BNET_BACKGROUND_COLOR
local FRIENDS_WOW_BACKGROUND_COLOR = FRIENDS_WOW_BACKGROUND_COLOR
local GetClassInfo = GetClassInfo
local GREEN_FONT_COLOR = GREEN_FONT_COLOR
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
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

	if not self.bg then
		self.bg = CreateFrame('Frame', nil, self)
		self.bg:CreateBackdrop('Transparent')
		self.bg:Point('TOPLEFT', 7, -16)
		self.bg:Point('BOTTOMRIGHT', -10, 12)
	end

	if self.IconBorder then
		self.IconBorder:Hide()
	end

	if color then
		self.Selection:SetInside(self.bg, 0, 0)
		if color == 1 then
			self.Selection:SetAtlas(nil)
			self.Selection:SetColorTexture(GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, 0.2)
		else
			self.Selection:SetAtlas(nil)
			self.Selection:SetColorTexture(BATTLENET_FONT_COLOR.r, BATTLENET_FONT_COLOR.g, BATTLENET_FONT_COLOR.b, 0.2)
		end
	end

	local highlight = self:GetHighlightTexture()
	highlight:SetColorTexture(1, 1, 1, 0.3)
	highlight:SetInside(self.bg)
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

function S:Blizzard_Communities()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.communities) then return end

	local CommunitiesFrame = _G.CommunitiesFrame
	CommunitiesFrame:StripTextures()
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

			if not s.IconBorder then
				s.IconBorder = s:CreateTexture(nil, 'BORDER')
				s.IconBorder:SetOutside(s.Icon)
				s.IconBorder:Hide()
			end

			if not s.bg then
				s.bg = CreateFrame('Frame', nil, s)
				s.bg:CreateBackdrop('Transparent')
				s.bg:Point('TOPLEFT', 7, -16)
				s.bg:Point('BOTTOMRIGHT', -10, 12)
			end

			local isGuild = clubInfo.clubType == Enum.ClubType.Guild
			if isGuild then
				s.Background:SetAtlas(nil)
				s.Selection:SetAtlas(nil)
				s.Selection:SetAllPoints(s.bg)
				s.Selection:SetColorTexture(0, 1, 0, 0.2)
			else
				s.Background:SetAtlas(nil)
				s.Selection:SetAtlas(nil)
				s.Selection:SetAllPoints(s.bg)
				s.Selection:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, 0.2)
			end

			if not isInvitation and not isGuild and not isTicket then
				if clubInfo.clubType == _G.Enum.ClubType.BattleNet then
					s.IconBorder:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b)
				else
					s.IconBorder:SetColorTexture(FRIENDS_WOW_BACKGROUND_COLOR.r, FRIENDS_WOW_BACKGROUND_COLOR.g, FRIENDS_WOW_BACKGROUND_COLOR.b)
				end
				s.IconBorder:Show()
			else
				s.IconBorder:Hide()
			end

			local highlight = s:GetHighlightTexture()
			highlight:SetColorTexture(1, 1, 1, 0.3)
			highlight:SetAllPoints(s.bg)
		end
	end)

	-- Add Community Button
	hooksecurefunc(_G.CommunitiesListEntryMixin, 'SetAddCommunity', function(s) HandleCommunitiesButtons(s, 1) end)

	S:HandleItemButton(CommunitiesFrame.ChatTab)
	CommunitiesFrame.ChatTab:Point('TOPLEFT', '$parent', 'TOPRIGHT', E.PixelMode and 0 or E.Border + E.Spacing, -36)
	S:HandleItemButton(CommunitiesFrame.RosterTab)

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

	CommunitiesFrame.Chat:StripTextures()
	CommunitiesFrame.Chat.InsetFrame:CreateBackdrop('Transparent')

	S:HandleEditBox(CommunitiesFrame.ChatEditBox)
	CommunitiesFrame.ChatEditBox:Size(120, 20)

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
	CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton:Size(129, 19)
	S:HandleCheckBox(CommunitiesFrame.MemberList.ShowOfflineButton)
	CommunitiesFrame.MemberList.ShowOfflineButton:Size(25, 25)

	hooksecurefunc(CommunitiesFrame.MemberList, 'RefreshListDisplay', function(s)
		for i = 1, s.ColumnDisplay:GetNumChildren() do
			local child = select(i, s.ColumnDisplay:GetChildren())
			child:StripTextures()
			child:CreateBackdrop('Transparent')
		end

		for _, button in ipairs(s.ListScrollFrame.buttons or {}) do
			if button and not button.hooked then
				hooksecurefunc(button, 'RefreshExpandedColumns', UpdateNames)
				if button.ProfessionHeader then
					local header = button.ProfessionHeader
					for i = 1, 3 do
						select(i, header:GetRegions()):Hide()
					end

					header:CreateBackdrop('Transparent')
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
	NotificationSettings:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, true)

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
	EditStreamDialog:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, true)

	S:HandleEditBox(EditStreamDialog.NameEdit)
	EditStreamDialog.NameEdit:Size(280, 20)
	S:HandleEditBox(EditStreamDialog.Description)
	S:HandleCheckBox(EditStreamDialog.TypeCheckBox)

	S:HandleButton(EditStreamDialog.Accept)
	S:HandleButton(EditStreamDialog.Cancel)

	-- Communities Settings
	local Settings = _G.CommunitiesSettingsDialog
	Settings:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, true)
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
	Avatar:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, true)

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

	TicketManager:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, true)

	S:HandleButton(TicketManager.LinkToChat)
	S:HandleButton(TicketManager.Copy)
	S:HandleButton(TicketManager.Close)
	S:HandleButton(TicketManager.GenerateLinkButton)

	S:HandleDropDownBox(TicketManager.ExpiresDropDownMenu)
	S:HandleDropDownBox(TicketManager.UsesDropDownMenu)

	S:HandleScrollBar(TicketManager.InviteManager.ListScrollFrame.scrollBar)
	S:HandleButton(TicketManager.MaximizeButton)

	-- Bottom Tabs
	for i = 1, 5 do
		S:HandleTab(_G['CommunitiesFrameTab'..i])
	end
end

S:AddCallbackForAddon('Blizzard_Communities')
