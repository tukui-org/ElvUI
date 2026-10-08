local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local wipe = wipe
local next = next
local pairs = pairs
local ipairs = ipairs
local unpack = unpack
local tinsert = tinsert

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local WhoFrameColumn_SetWidth = WhoFrameColumn_SetWidth
local FriendsFrame_GetInviteRestriction = FriendsFrame_GetInviteRestriction

local BNConnected = BNConnected
local BNFeaturesEnabled = BNFeaturesEnabled
local GetGuildRosterInfo = GetGuildRosterInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetCVarBool = C_CVar.GetCVarBool

local BNET_BACKGROUND_COLOR = FRIENDS_BNET_BACKGROUND_COLOR
local BNET_NAME_COLOR = FRIENDS_BNET_NAME_COLOR
local GUILDMEMBERS_TO_DISPLAY = GUILDMEMBERS_TO_DISPLAY

local INVITE_RESTRICTION_NONE = 9
local SOCIAL_TABS = {}

if E.Modern then
	S:AddCallback('FriendsFrame', nil, nil, 'friends')
else
	S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'FriendsFrame', nil, nil, nil, nil, 'friends')
end

local function BattleNetFrame_OnEnter(button)
	button.backdrop:SetBackdropBorderColor(BNET_NAME_COLOR.r, BNET_NAME_COLOR.g, BNET_NAME_COLOR.b)
end

local function BattleNetFrame_OnLeave(button)
	button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

local function BattleNetFrame_OnClick()
	_G.FriendsFrameBattlenetFrame.BroadcastFrame:ToggleFrame()
end

local function RAFRewardQuality(button)
	if not button.item then return end

	local quality = button.item:GetItemQuality()
	local r, g, b = E:GetItemQualityColor(quality)
	button.Icon.backdrop:SetBackdropBorderColor(r, g, b)
end

local function RAFRewards()
	_G.RecruitAFriendFrame.RewardClaiming.NextRewardButton.Icon:SetDesaturation(0)

	local rewardsFrame = _G.RecruitAFriendRewardsFrame
	for tab in rewardsFrame.rewardTabPool:EnumerateActive() do
		if not tab.IsSkinned then
			tab:CreateBackdrop(nil, true, nil, nil, nil, nil, nil, true)
			tab:StyleButton()
			tab.Tab:Hide()

			local _, relativeTo = tab:GetPoint()
			if relativeTo and relativeTo == rewardsFrame then
				tab:NudgePoint(2, 0)
			end

			tab.IsSkinned = true
		end
	end

	for reward in rewardsFrame.rewardPool:EnumerateActive() do
		local button = reward.Button
		button:StyleButton(nil, true)
		button.hover:SetAllPoints()
		button.IconOverlay:SetAlpha(0)
		button.IconBorder:SetAlpha(0)

		local icon = button.Icon
		icon:SetDesaturation(0)
		S:HandleIcon(icon, true)

		RAFRewardQuality(button)
		reward.Months.Text:SetTextColor(1, 1, 1)
	end
end

local function RAFShowSplashScreen(frame)
	local r, g, b = unpack(E.media.bordercolor)
	frame.SplashFrame.Background:SetColorTexture(r, g, b)
end

local InviteAtlas = {
	['friendslist-invitebutton-horde-normal'] = [[Interface\FriendsFrame\PlusManz-Horde]],
	['friendslist-invitebutton-alliance-normal'] = [[Interface\FriendsFrame\PlusManz-Alliance]],
	['friendslist-invitebutton-default-normal'] = [[Interface\FriendsFrame\PlusManz-PlusManz]],
}

local function HandleInviteTex(self, atlas)
	local tex = InviteAtlas[atlas]
	if tex then
		self.ownerIcon:SetTexture(tex)
	end
end

local function ReskinFriendButton(button)
	if button.IsSkinned then return end
	button.IsSkinned = true

	local summon = button.summonButton
	summon:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, nil, true)
	summon:Size(24)

	summon.highlightTexture = summon:GetHighlightTexture() -- the other one is different (HighlightTexture)
	summon.highlightTexture:SetTexture(136222)

	summon.PushedTexture:SetTexture(136222)
	summon.NormalTexture:SetTexture(136222)
	summon.PushedTexture:SetBlendMode('ADD')
	summon.PushedTexture:SetColorTexture(0.9, 0.8, 0.1, 0.3)

	summon.highlightTexture:SetTexCoord(0.12, 0.88, 0.12, 0.88)
	summon.PushedTexture:SetTexCoord(0.12, 0.88, 0.12, 0.88)
	summon.NormalTexture:SetTexCoord(0.12, 0.88, 0.12, 0.88)

	summon.highlightTexture:SetInside(summon.backdrop)
	summon.PushedTexture:SetInside(summon.backdrop)
	summon.NormalTexture:SetInside(summon.backdrop)

	summon.SlotBackground:SetAlpha(0)
	summon.SlotArt:SetAlpha(0)

	local invite = button.travelPassButton
	invite:Size(24)
	invite:Point('TOPRIGHT', -4, -5)
	invite:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, nil, true)
	invite.NormalTexture:SetAlpha(0)
	invite.PushedTexture:SetAlpha(0)
	invite.DisabledTexture:SetAlpha(0)
	invite.HighlightTexture:SetColorTexture(1, 1, 1, .25)
	invite.HighlightTexture:SetAllPoints()

	local gameIcon = button.gameIcon
	gameIcon:Size(26)
	gameIcon:SetTexCoord(0, 1, 0, 1)
	gameIcon:ClearAllPoints()
	gameIcon:Point('RIGHT', invite, 'LEFT', -6, 0)

	local icon = invite:CreateTexture(nil, 'ARTWORK')
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon:SetAllPoints()

	button.newIcon = icon
	button:SetHighlightTexture(E.media.normTex)
	button:GetHighlightTexture():SetVertexColor(.24, .56, 1, .2)

	invite.NormalTexture.ownerIcon = icon
	hooksecurefunc(invite.NormalTexture, 'SetAtlas', HandleInviteTex)
end

local function HandleTabs()
	local lastTab
	for _, tab in next, { _G.FriendsFrameTab1, _G.FriendsFrameTab2, _G.FriendsFrameTab3, _G.FriendsFrameTab4 } do -- no Who tab (2) on Forever, it lives in the group finder
		S:HandleTab(tab)

		tab:ClearAllPoints()

		if lastTab then
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -5, 0)
		else
			tab:Point('BOTTOMLEFT', _G.FriendsFrame, 'BOTTOMLEFT', -3, -32)
		end

		lastTab = tab
	end
end

local function UpdateFriendButton(button)
	ReskinFriendButton(button)

	if button.buttonType == _G.FRIENDS_BUTTON_TYPE_BNET then
		if FriendsFrame_GetInviteRestriction(button.id) == INVITE_RESTRICTION_NONE then
			button.newIcon:SetVertexColor(1, 1, 1)
		else
			button.newIcon:SetVertexColor(.5, .5, .5)
		end
	end
end

local function UpdateFriendInviteButton(button)
	if not button.IsSkinned then
		S:HandleButton(button.AcceptButton)
		S:HandleButton(button.DeclineButton)

		button.IsSkinned = true
	end
end

local function UpdateFriendInviteHeaderButton(button)
	if not button.IsSkinned then
		button:DisableDrawLayer('BACKGROUND')
		button:CreateBackdrop('Transparent')
		button.backdrop:SetInside(button, 2, 2)

		local highlight = button:GetHighlightTexture()
		if highlight then
			highlight:SetColorTexture(.24, .56, 1, .2)
			highlight:SetInside(button.backdrop)
		end

		button.IsSkinned = true
	end
end

local function HandleRecentAllies(frame)
	local invite = InviteAtlas['friendslist-invitebutton-default-normal']

	for _, button in next, { frame.ScrollTarget:GetChildren() } do
		local partyButton = not button.IsSkinned and button.PartyButton
		if partyButton then
			local normal = partyButton:GetNormalTexture()
			normal:SetTexture(invite)
			normal:SetTexCoords()

			local highlight = partyButton:GetHighlightTexture()
			highlight:SetTexture(invite)
			highlight:SetTexCoords()

			local disabled = partyButton:GetDisabledTexture()
			disabled:SetTexture(invite)
			disabled:SetDesaturated(true)
			disabled:SetTexCoords()

			partyButton:ClearAllPoints()
			partyButton:Point('RIGHT', -2, 0)

			partyButton:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, nil, true)
			partyButton:Size(24)

			button.IsSkinned = true
		end
	end
end

local ButtonsToHandle = {
	'FriendsFrameAddFriendButton',
	'FriendsFrameSendMessageButton',
	'AddFriendEntryFrameAcceptButton',
	'AddFriendEntryFrameCancelButton'
}

local EditBoxBorders = {
	'BottomBorder',
	'BottomLeftBorder',
	'BottomRightBorder',
	'LeftBorder',
	'MiddleBorder',
	'RightBorder',
	'TopBorder',
	'TopLeftBorder',
	'TopRightBorder'
}

-- Blizzard_UIPanels_Game's Classic FriendsFrame, loaded by Mists, Wrath, TBC and Vanilla
local function SkinFriendRequest(frame)
	if frame.IsSkinned then return end

	S:HandleButton(frame.DeclineButton, nil, true)
	S:HandleButton(frame.AcceptButton)

	frame.IsSkinned = true
end

local function CheckBattlenetStatus()
	if BNFeaturesEnabled() then
		_G.FriendsFrameBattlenetFrame.BroadcastButton:Hide()

		if BNConnected() then
			_G.FriendsFrameBattlenetFrame:Hide()
			_G.FriendsFrameBroadcastInput:Show()
			_G.FriendsFrameBroadcastInput_UpdateDisplay()
		end
	end
end

local function UpdateFriendsFrame()
	if _G.FriendsFrame.selectedTab == 1 and _G.FriendsTabHeader.selectedTab == 1 and _G.FriendsFrameBattlenetFrame.Tag:IsShown() then
		_G.FriendsFrameTitleText:Hide()
	else
		_G.FriendsFrameTitleText:Show()
	end
end

local function AcquireInvitePool(pool)
	for object in pool:EnumerateActive() do
		SkinFriendRequest(object)
	end
end

local function RepositionTabs()
	local previous = _G.FriendsFrame
	local index = 1
	local tab = _G['FriendsFrameTab'..index]
	while tab do
		tab:ClearAllPoints()

		if index ~= _G.FRIEND_TAB_GUILD or GetCVarBool('useClassicGuildUI') then
			tab:Point('TOPLEFT', previous, index == 1 and 'BOTTOMLEFT' or 'TOPRIGHT', index == 1 and -15 or -19, 0)
			previous = tab
		end

		index = index + 1
		tab = _G['FriendsFrameTab'..index]
	end
end

local function UpdateGuildStatus()
	if _G.FriendsFrame.playerStatusFrame then
		local playerZone = E.MapInfo.realZoneText
		for i = 1, GUILDMEMBERS_TO_DISPLAY do
			local button = _G['GuildFrameButton'..i]
			if button.guildIndex then
				local _, _, _, level, className, zone, _, _, online = GetGuildRosterInfo(button.guildIndex)
				local classFilename = E:UnlocalizedClassName(className)
				if classFilename then
					if online then
						local classTextColor = E:ClassColor(classFilename)
						local levelTextColor = GetQuestDifficultyColor(level)
						_G['GuildFrameButton'..i..'Name']:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
						_G['GuildFrameButton'..i..'Level']:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)

						if zone == playerZone then
							_G['GuildFrameButton'..i..'Zone']:SetTextColor(0, 1, 0)
						else
							_G['GuildFrameButton'..i..'Zone']:SetTextColor(1, 1, 1)
						end
					end

					button.icon:SetTexCoord(E:GetClassCoords(classFilename))
				end
			end
		end
	else
		for i = 1, GUILDMEMBERS_TO_DISPLAY do
			local button = _G['GuildFrameGuildStatusButton'..i]
			if button.guildIndex then
				local _, _, _, _, className, _, _, _, online = GetGuildRosterInfo(button.guildIndex)
				local classFilename = online and E:UnlocalizedClassName(className)
				if classFilename then
					local classTextColor = E:ClassColor(classFilename)
					_G['GuildFrameGuildStatusButton'..i..'Name']:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)
					_G['GuildFrameGuildStatusButton'..i..'Online']:SetTextColor(1, 1, 1)
				end
			end
		end
	end
end

local function HandleGuild() -- /groster
	_G.GuildFrame:StripTextures()
	_G.GuildFrameColumnHeader3:ClearAllPoints()
	_G.GuildFrameColumnHeader3:Point('TOPLEFT', 8, -57)
	_G.GuildFrameColumnHeader4:ClearAllPoints()
	_G.GuildFrameColumnHeader4:Point('LEFT', _G.GuildFrameColumnHeader3, 'RIGHT', -2, -0)
	_G.GuildFrameColumnHeader4:Width(50)
	_G.GuildFrameColumnHeader1:ClearAllPoints()
	_G.GuildFrameColumnHeader1:Point('LEFT', _G.GuildFrameColumnHeader4, 'RIGHT', -2, -0)
	_G.GuildFrameColumnHeader1:Width(105)
	_G.GuildFrameColumnHeader2:ClearAllPoints()
	_G.GuildFrameColumnHeader2:Point('LEFT', _G.GuildFrameColumnHeader1, 'RIGHT', -2, -0)
	_G.GuildFrameColumnHeader2:Width(127)

	for i = 1, GUILDMEMBERS_TO_DISPLAY do
		local button = _G['GuildFrameButton'..i]
		local level = _G['GuildFrameButton'..i..'Level']
		local name = _G['GuildFrameButton'..i..'Name']
		local classButton = _G['GuildFrameButton'..i..'Class']
		local statusButton = _G['GuildFrameGuildStatusButton'..i]
		local statusName = _G['GuildFrameGuildStatusButton'..i..'Name']

		button.icon = button:CreateTexture('$parentIcon', 'ARTWORK')
		button.icon:Point('LEFT', 48, 0)
		button.icon:Size(15)
		button.icon:SetTexture([[Interface\WorldStateFrame\Icons-Classes]])
		button.icon:CreateBackdrop(nil, true, nil, nil, nil, nil, nil, button.icon)

		S:HandleButtonHighlight(button)
		S:HandleButtonHighlight(statusButton)
		level:ClearAllPoints()
		level:SetPoint('TOPLEFT', 10, -1)
		name:SetSize(100, 14)
		name:ClearAllPoints()
		name:SetPoint('LEFT', 85, 0)
		classButton:Hide()
		statusName:ClearAllPoints()
		statusName:SetPoint('LEFT', 10, 0)
	end

	hooksecurefunc('GuildStatus_Update', UpdateGuildStatus)

	S:HandleFrame(_G.GuildFrameLFGFrame, true)
	S:HandleCheckBox(_G.GuildFrameLFGButton)

	for i = 1, 4 do
		_G['GuildFrameColumnHeader'..i]:StripTextures()
		_G['GuildFrameColumnHeader'..i]:StyleButton()
		_G['GuildFrameGuildStatusColumnHeader'..i]:StripTextures()
		_G['GuildFrameGuildStatusColumnHeader'..i]:StyleButton()
	end

	_G.GuildListScrollFrame:StripTextures()
	S:HandleScrollBar(_G.GuildListScrollFrameScrollBar)
	S:HandleNextPrevButton(_G.GuildFrameGuildListToggleButton, 'left')
	S:HandleButton(_G.GuildFrameGuildInformationButton)
	_G.GuildFrameGuildInformationButton:Point('BOTTOMLEFT', -1, 4)
	S:HandleButton(_G.GuildFrameAddMemberButton)
	S:HandleButton(_G.GuildFrameControlButton)
	S:HandleButton(_G.GuildFrameImpeachButton)

	-- Member Detail Frame
	_G.GuildMemberDetailFrame:StripTextures()
	_G.GuildMemberDetailFrame:CreateBackdrop('Transparent')
	_G.GuildMemberDetailFrame:Point('TOPLEFT', _G.GuildFrame, 'TOPRIGHT', 3, -1)
	S:HandleCloseButton(_G.GuildMemberDetailCloseButton, _G.GuildMemberDetailFrame.backdrop)
	S:HandleButton(_G.GuildMemberRemoveButton)
	_G.GuildMemberRemoveButton:Point('BOTTOMLEFT', 3, 3)
	S:HandleButton(_G.GuildMemberGroupInviteButton)
	_G.GuildMemberGroupInviteButton:Point('BOTTOMRIGHT', -3, 3)

	-- Not the reason of the taint
	S:HandleNextPrevButton(_G.GuildFramePromoteButton, 'up')
	_G.GuildFramePromoteButton:SetHitRectInsets(0, 0, 0, 0)
	_G.GuildFramePromoteButton:SetPoint('TOPLEFT', _G.GuildMemberDetailFrame, 'TOPLEFT', 155, -68)
	S:HandleNextPrevButton(_G.GuildFrameDemoteButton)
	_G.GuildFrameDemoteButton:SetHitRectInsets(0, 0, 0, 0)
	_G.GuildFrameDemoteButton:Point('LEFT', _G.GuildFramePromoteButton, 'RIGHT', 2, 0)
	_G.GuildMemberNoteBackground:StripTextures()
	_G.GuildMemberNoteBackground:CreateBackdrop()
	_G.GuildMemberNoteBackground.backdrop:Point('TOPLEFT', 0, -2)
	_G.GuildMemberNoteBackground.backdrop:Point('BOTTOMRIGHT', 0, 2)
	_G.PersonalNoteText:Point('TOPLEFT', 4, -4)
	_G.GuildMemberOfficerNoteBackground:StripTextures()
	_G.GuildMemberOfficerNoteBackground:CreateBackdrop()
	_G.GuildMemberOfficerNoteBackground.backdrop:Point('TOPLEFT', 0, -2)
	_G.GuildMemberOfficerNoteBackground.backdrop:Point('BOTTOMRIGHT', 0, -1)
	_G.GuildFrameNotesLabel:Point('TOPLEFT', _G.GuildFrame, 'TOPLEFT', 6, -328)
	_G.GuildFrameNotesText:Point('TOPLEFT', _G.GuildFrameNotesLabel, 'BOTTOMLEFT', 0, -6)
	_G.GuildFrameBarLeft:StripTextures()
	_G.GuildMOTDEditButton:CreateBackdrop()
	_G.GuildMOTDEditButton.backdrop:Point('TOPLEFT', -7, 3)
	_G.GuildMOTDEditButton.backdrop:Point('BOTTOMRIGHT', 7, -2)
	_G.GuildMOTDEditButton:SetHitRectInsets(-7, -7, -3, -2)

	-- Info Frame
	_G.GuildInfoFrame:StripTextures()
	_G.GuildInfoFrame:CreateBackdrop('Transparent')
	_G.GuildInfoFrame:Point('TOPLEFT', _G.GuildFrame, 'TOPRIGHT', -1, 6)
	_G.GuildInfoFrame.backdrop:Point('TOPLEFT', 3, -6)
	_G.GuildInfoFrame.backdrop:Point('BOTTOMRIGHT', -2, 3)
	_G.GuildInfoTextBackground.NineSlice:SetTemplate('Transparent')
	S:HandleScrollBar(_G.GuildInfoFrameScrollFrameScrollBar)
	S:HandleCloseButton(_G.GuildInfoCloseButton, _G.GuildInfoFrame.backdrop)
	S:HandleButton(_G.GuildInfoSaveButton)
	S:HandleButton(_G.GuildInfoCancelButton)
	_G.GuildInfoCancelButton:ClearAllPoints()
	_G.GuildInfoCancelButton:Point('BOTTOMRIGHT', _G.GuildInfoFrame, -10, 8)
	_G.GuildInfoSaveButton:ClearAllPoints()
	_G.GuildInfoSaveButton:Point('RIGHT', _G.GuildInfoCancelButton, 'LEFT', -4, 0)

	-- Guild Control Frame (Guild Master Only)
	_G.GuildControlPopupFrame:StripTextures()
	_G.GuildControlPopupFrame:CreateBackdrop('Transparent')
	_G.GuildControlPopupFrame.backdrop:Point('TOPLEFT', 3, 0)
	S:HandleDropDownBox(_G.GuildControlPopupFrameDropdown, 170)
	-- _G.GuildControlPopupFrameDropdownButton:Size(18)
	S:HandleCollapseTexture(_G.GuildControlPopupFrameAddRankButton, nil, true)
	_G.GuildControlPopupFrameAddRankButton:Point('LEFT', _G.GuildControlPopupFrameDropdown, 'RIGHT', -2, 3)
	S:HandleCollapseTexture(_G.GuildControlPopupFrameRemoveRankButton, nil, true)
	_G.GuildControlPopupFrameRemoveRankButton:Point('LEFT', _G.GuildControlPopupFrameAddRankButton, 'RIGHT', 2, 0)
	_G.GuildControlPopupFrameEditBox:StripTextures()
	S:HandleEditBox(_G.GuildControlPopupFrameEditBox)
	_G.GuildControlPopupFrameEditBox.backdrop:Point('TOPLEFT', 0, -5)
	_G.GuildControlPopupFrameEditBox.backdrop:Point('BOTTOMRIGHT', 0, 5)

	for _, checkBox in next, _G.GuildControlPopupFrameCheckboxes.PermissionCheckboxes do
		S:HandleCheckBox(checkBox)
	end

	S:HandleButton(_G.GuildControlPopupAcceptButton)
	S:HandleButton(_G.GuildControlPopupFrameCancelButton)
end

-- Shared "Recruit a Friend" reward header
local function HandleRAFRewardClaiming(frame)
	frame:StripTextures()
	frame:SetTemplate('Transparent')

	frame.Background:SetAlpha(0)
	frame.Watermark:SetAlpha(0)

	local nextReward = frame.NextRewardButton
	S:HandleIcon(nextReward.Icon, true)

	nextReward.CircleMask:Hide()
	nextReward.IconBorder:SetAlpha(0)
	nextReward.IconOverlay:SetAlpha(0)

	RAFRewardQuality(nextReward)
end

local function HandleBroadcastEditBox(editBox)
	for _, name in next, EditBoxBorders do
		editBox[name]:Hide()
	end

	S:HandleEditBox(editBox)
end

-- SocialUI (C_SocialUI.IsSystemEnabled)
local function UpdateSocialTabs(frame)
	wipe(SOCIAL_TABS)

	-- The tab pool enumerates in no order, availableTabData is sorted
	for _, data in ipairs(frame.availableTabData) do
		local tab = frame:GetTabByType(data.tabType)
		if tab then
			S:HandleLargeSideTab(tab)

			tinsert(SOCIAL_TABS, tab)
		end
	end

	S:LayoutLargeSideTabs(frame, SOCIAL_TABS)
end

-- SocialUIScrollableHeaderTemplate, keeps Blizzard's plus / minus
local function HandleSocialHeader(header)
	header:SetNormalTexture(E.ClearTexture)
	header:SetHighlightTexture(E.ClearTexture)

	header:CreateBackdrop()
	header.backdrop:SetInside(header, 0, 1)
end

-- Friend, friend request, recent ally, recruit and quick join cards
local function HandleSocialCard(card)
	card.Background:SetAlpha(0)
	card:CreateBackdrop('Transparent')
	card.backdrop:SetInside(card, 0, 1)

	-- Quick join cards have their own Highlight and Selected textures
	local highlight = card:GetHighlightTexture() or card.Highlight
	highlight:SetColorTexture(1, 1, 1, .25)
	highlight:SetInside(card.backdrop)

	local selected = card.Selected
	if selected then
		local r, g, b = unpack(E.media.rgbvaluecolor)
		selected:SetColorTexture(r, g, b, .25)
		selected:SetInside(card.backdrop)
	end

	-- Party invite (friends, recent allies), RAF summon (friends) and accept (friend requests)
	for _, button in next, { card.PartyButton, card.RAFSummonButton, card.AcceptButton } do
		S:HandleButton(button)
	end
end

local function UpdateSocialRow(row)
	if row.IsSkinned then return end

	if row.CollapseButton then
		HandleSocialHeader(row)
	elseif row.Background then -- Spacer rows have nothing to skin
		HandleSocialCard(row)
	end

	row.IsSkinned = true
end

local function UpdateSocialList(scrollBox)
	scrollBox:ForEachFrame(UpdateSocialRow)
end

-- SocialUIContactsFrameTemplate, the content frame of every tab (except raid tab)
local function HandleContactsFrame(frame)
	frame:StripTextures()

	S:HandleButton(frame.ActionButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleTrimScrollBar(frame.ScrollBar)

	hooksecurefunc(frame.ScrollBox, 'Update', UpdateSocialList)

	local filterBar = frame.FilterBar
	S:HandleEditBox(filterBar.SearchBar)

	local filter = filterBar.SearchFilterDropdown
	S:HandleButton(filter, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
	S:HandleCloseButton(filter.ResetButton)

	filter.ResetButton:ClearAllPoints()
	filter.ResetButton:Point('CENTER', filter, 'TOPRIGHT')
end

-- The raid tab pools its group boxes and player buttons
local function UpdateRaidGroups(frame)
	if InCombatLockdown() then return end -- Player buttons (Secure unit buttons)

	for _, group in next, frame.groups do
		if not group.backdrop then
			group:StripTextures()
			group:CreateBackdrop('Transparent')
		end
	end

	for _, player in next, frame.players do
		if not player.backdrop then
			player:StripTextures()
			player:CreateBackdrop('Transparent')
		end
	end
end

local function HandleSocialUI()
	local socialFrame = _G.SocialUIFrame
	S:HandlePortraitFrame(socialFrame)

	hooksecurefunc(socialFrame, 'RefreshTabs', UpdateSocialTabs)

	local bnetBar = socialFrame.BattleNetBar
	bnetBar:StripTextures()

	local bnetControls = bnetBar.ControlsContainer
	S:HandleDropDownBox(bnetControls.OnlineStatusDropdown, 54)
	S:HandleButton(bnetControls.BattleNetMenuButton)

	local battleTag = bnetControls.PersonalBattleTagDisplay
	battleTag:CreateBackdrop('Transparent')
	battleTag.backdrop:SetAllPoints(bnetControls.BattleNetBackground)
	battleTag.backdrop:SetBackdropColor(BNET_BACKGROUND_COLOR.r, BNET_BACKGROUND_COLOR.g, BNET_BACKGROUND_COLOR.b, BNET_BACKGROUND_COLOR.a)
	bnetControls.BattleNetBackground:SetAlpha(0)

	-- Side windows
	local notice = socialFrame.BattleNetUnavailableNoticeFrame
	notice:StripTextures()
	notice:SetTemplate('Transparent')

	local broadcast = socialFrame.BattleNetBroadcastFrame
	broadcast:StripTextures()
	broadcast:SetTemplate('Transparent')
	HandleBroadcastEditBox(broadcast.EditBox)
	S:HandleButton(broadcast.UpdateButton)
	S:HandleButton(broadcast.CancelButton)

	local ignoreList = socialFrame.IgnoreListFrame
	S:HandleFrame(ignoreList)
	S:HandleTrimScrollBar(ignoreList.ScrollBar)
	S:HandleButton(ignoreList.BlockButton)
	S:HandleButton(ignoreList.UnblockButton)

	-- Tab content
	for _, frame in next, { socialFrame.FriendsList, socialFrame.RecentAlliesList, socialFrame.QuickJoinFrame, socialFrame.FriendRequestsList, socialFrame.RecruitAFriendFrame } do
		HandleContactsFrame(frame)
	end

	local requests = socialFrame.FriendRequestsList
	if requests then
		local warning = requests.RealIDWarning
		S:HandleButton(warning.ContinueButton, nil, nil, nil, true, nil, nil, nil, true)
		S:HandleTrimScrollBar(warning.ScrollBar)
	end

	local recruit = socialFrame.RecruitAFriendFrame
	if recruit then
		HandleRAFRewardClaiming(recruit.RewardClaiming)

		S:HandleButton(recruit.RewardClaiming.ClaimOrViewRewardButton, nil, nil, nil, true, nil, nil, nil, true)
		S:HandleTrimScrollBar(recruit.NoRecruitsScrollBar)
	end

	local raidFrame = socialFrame.RaidFrame
	if raidFrame then
		local allAssist = raidFrame.AllAssistCheckButton
		S:HandleCheckBox(allAssist)

		-- HandleCheckBox strips the raid assist icon next to the box
		allAssist.Icon:SetAtlas('friends-icon-raidAssist', true)

		S:HandleButton(raidFrame.RaidInfoButton, nil, nil, nil, true, nil, nil, nil, true)
		S:HandleButton(raidFrame.ConvertToRaidButton, nil, nil, nil, true, nil, nil, nil, true)

		hooksecurefunc(raidFrame, 'UpdateContents', UpdateRaidGroups)

		local raidInfo = socialFrame.RaidInfoFrame
		raidInfo:StripTextures()
		raidInfo:SetTemplate('Transparent')

		S:HandleCloseButton(raidInfo.CloseButton)
		S:HandleTrimScrollBar(raidInfo.ScrollBar)
		S:HandleButton(raidInfo.ExtendButton, nil, nil, nil, true, nil, nil, nil, true)
	end
end

function S:FriendsFrame()
	if E.Modern then
		S:HandleTrimScrollBar(_G.FriendsListFrame.ScrollBar)
		S:HandleTrimScrollBar(_G.RecentAlliesFrame.List.ScrollBar)
		S:HandleTrimScrollBar(_G.FriendsFriendsFrame.ScrollBar)
		S:HandleTrimScrollBar(_G.QuickJoinFrame.ScrollBar)

		for _, button in pairs(ButtonsToHandle) do
			S:HandleButton(_G[button])
		end

		local FriendsFrame = _G.FriendsFrame
		S:HandlePortraitFrame(FriendsFrame)

		_G.FriendsFrameIcon:Hide()

		S:HandleDropDownBox(_G.FriendsFrameStatusDropdown, 70)

		local FriendsFrameBattlenetFrame = _G.FriendsFrameBattlenetFrame
		FriendsFrameBattlenetFrame:StripTextures()
		FriendsFrameBattlenetFrame:SetTemplate('Transparent')
		S:HandleButton(FriendsFrameBattlenetFrame.ContactsMenuButton)
		FriendsFrameBattlenetFrame.ContactsMenuButton:Size(31) -- Default is 32, 32

		local BattlenetFrame = CreateFrame('Button', nil, FriendsFrameBattlenetFrame)
		BattlenetFrame:Point('TOPLEFT', FriendsFrameBattlenetFrame, 'TOPLEFT')
		BattlenetFrame:Point('BOTTOMRIGHT', FriendsFrameBattlenetFrame, 'BOTTOMRIGHT')
		BattlenetFrame:Size(FriendsFrameBattlenetFrame:GetSize())
		BattlenetFrame:CreateBackdrop('Transparent')
		BattlenetFrame.backdrop:SetBackdropColor(BNET_BACKGROUND_COLOR.r, BNET_BACKGROUND_COLOR.g, BNET_BACKGROUND_COLOR.b, BNET_BACKGROUND_COLOR.a)
		BattlenetFrame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))

		BattlenetFrame:SetScript('OnClick', BattleNetFrame_OnClick)
		BattlenetFrame:SetScript('OnEnter', BattleNetFrame_OnEnter)
		BattlenetFrame:SetScript('OnLeave', BattleNetFrame_OnLeave)

		FriendsFrameBattlenetFrame.UnavailableInfoFrame.Bg:SetTexture(nil)
		FriendsFrameBattlenetFrame.UnavailableInfoFrame:SetTemplate('Transparent')
		FriendsFrameBattlenetFrame.UnavailableInfoFrame:ClearAllPoints()
		FriendsFrameBattlenetFrame.UnavailableInfoFrame:Point('TOPLEFT', FriendsFrame, 'TOPRIGHT', 1, -18)

		FriendsFrameBattlenetFrame.BroadcastFrame:StripTextures()
		FriendsFrameBattlenetFrame.BroadcastFrame:SetTemplate('Transparent')
		FriendsFrameBattlenetFrame.BroadcastFrame:ClearAllPoints()
		FriendsFrameBattlenetFrame.BroadcastFrame:Point('TOPLEFT', FriendsFrame, 'TOPRIGHT', 3, -1)
		S:HandleButton(FriendsFrameBattlenetFrame.BroadcastFrame.UpdateButton)
		S:HandleButton(FriendsFrameBattlenetFrame.BroadcastFrame.CancelButton)

		HandleBroadcastEditBox(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox)
		S:HandleEditBox(_G.AddFriendNameEditBox)
		_G.AddFriendFrame:StripTextures()
		_G.AddFriendFrame:SetTemplate('Transparent')
		S:HandleCloseButton(_G.AddFriendFrame.CloseButton)
		S:HandleButton(_G.AddFriendInfoFrame.OkayButton)

		hooksecurefunc(_G.RecentAlliesFrame.List.ScrollBox, 'Update', HandleRecentAllies)

		hooksecurefunc('FriendsFrame_UpdateFriendButton', UpdateFriendButton)
		hooksecurefunc('FriendsFrame_UpdateFriendInviteButton', UpdateFriendInviteButton)
		hooksecurefunc('FriendsFrame_UpdateFriendInviteHeaderButton', UpdateFriendInviteHeaderButton)

		-- IgnoreListWindow
		local IgnoreWindow = FriendsFrame.IgnoreListWindow
		IgnoreWindow:StripTextures()
		IgnoreWindow:SetTemplate('Transparent')
		S:HandleTrimScrollBar(IgnoreWindow.ScrollBar)
		S:HandleButton(IgnoreWindow.UnignorePlayerButton)
		S:HandleCloseButton(IgnoreWindow.CloseButton)

		-- Who Frame
		local WhoFrame = _G.WhoFrame
		if WhoFrame then -- Not on Forever, its Who list lives in the group finder
			WhoFrame:StripTextures()
			_G.WhoFrameListInset:StripTextures()
			_G.WhoFrameListInset.NineSlice:Hide()
			_G.WhoFrameEditBox.Backdrop:StripTextures()
			_G.WhoFrameEditBox.Backdrop:CreateBackdrop()
			S:HandleTrimScrollBar(WhoFrame.ScrollBar)

			for _, header in next, { _G.WhoFrameColumnHeader1, _G.WhoFrameColumnHeader2, _G.WhoFrameColumnHeader3, _G.WhoFrameColumnHeader4 } do
				header:StripTextures()
			end

			for _, button in next, { _G.WhoFrameWhoButton, _G.WhoFrameAddFriendButton, _G.WhoFrameGroupInviteButton } do
				S:HandleButton(button)
			end

			-- Increase width of Level column slightly
			WhoFrameColumn_SetWidth(_G.WhoFrameColumnHeader3, 37) -- Default is 32

			S:HandleDropDownBox(_G.WhoFrameDropdown, 90)
		end

		-- Bottom Tabs
		HandleTabs()

		for _, tab in next, { _G.FriendsTabHeader.TabSystem:GetChildren() } do
			S:HandleTab(tab)
		end

		-- View Friends BN Frame
		local FriendsFriendsFrame = _G.FriendsFriendsFrame
		FriendsFriendsFrame.ScrollFrameBorder:Hide()
		FriendsFriendsFrame:StripTextures()
		FriendsFriendsFrame:SetTemplate('Transparent')
		S:HandleDropDownBox(_G.FriendsFriendsFrameDropdown, 150)
		S:HandleButton(FriendsFriendsFrame.SendRequestButton)
		S:HandleButton(FriendsFriendsFrame.CloseButton)

		-- Quick join
		local QuickJoinFrame = _G.QuickJoinFrame
		local QuickJoinRoleSelectionFrame = _G.QuickJoinRoleSelectionFrame
		S:HandleButton(_G.QuickJoinFrame.JoinQueueButton)
		QuickJoinFrame.JoinQueueButton:Size(131, 21) -- Match button on other tab
		QuickJoinFrame.JoinQueueButton:ClearAllPoints()
		QuickJoinFrame.JoinQueueButton:Point('BOTTOMRIGHT', QuickJoinFrame, 'BOTTOMRIGHT', -6, 4)
		QuickJoinRoleSelectionFrame:StripTextures()
		QuickJoinRoleSelectionFrame:SetTemplate('Transparent')
		S:HandleButton(QuickJoinRoleSelectionFrame.AcceptButton)
		S:HandleButton(QuickJoinRoleSelectionFrame.CancelButton)
		S:HandleCloseButton(QuickJoinRoleSelectionFrame.CloseButton)
		S:HandleCheckBox(QuickJoinRoleSelectionFrame.RoleButtonTank.CheckButton)
		S:HandleCheckBox(QuickJoinRoleSelectionFrame.RoleButtonHealer.CheckButton)
		S:HandleCheckBox(QuickJoinRoleSelectionFrame.RoleButtonDPS.CheckButton)

		local RecruitFrame = _G.RecruitAFriendFrame
		S:HandleButton(RecruitFrame.RecruitmentButton)

		-- /run RecruitAFriendFrame:ShowSplashScreen()
		local SplashFrame = RecruitFrame.SplashFrame
		S:HandleButton(SplashFrame.OKButton)

		if E.private.skins.parchmentRemoverEnable then
			RAFShowSplashScreen(RecruitFrame)

			-- Blizzard sets the parchment atlas again on every show
			hooksecurefunc(RecruitFrame, 'ShowSplashScreen', RAFShowSplashScreen)

			SplashFrame.Description:SetTextColor(1, 1, 1)
			SplashFrame.PictureFrame:Hide()
			SplashFrame.Bracket_TopLeft:Hide()
			SplashFrame.Bracket_TopRight:Hide()
			SplashFrame.Bracket_BottomRight:Hide()
			SplashFrame.Bracket_BottomLeft:Hide()
			SplashFrame.PictureFrame_Bracket_TopLeft:Hide()
			SplashFrame.PictureFrame_Bracket_TopRight:Hide()
			SplashFrame.PictureFrame_Bracket_BottomRight:Hide()
			SplashFrame.PictureFrame_Bracket_BottomLeft:Hide()
		end

		local Claiming = RecruitFrame.RewardClaiming
		HandleRAFRewardClaiming(Claiming)
		Claiming:Point('TOPLEFT', 4, -84)
		S:HandleButton(Claiming.ClaimOrViewRewardButton)

		local RecruitList = RecruitFrame.RecruitList
		RecruitList.Header:StripTextures()
		RecruitList.ScrollFrameInset:StripTextures()
		RecruitList.ScrollFrameInset:SetTemplate('Transparent')
		S:HandleTrimScrollBar(RecruitList.ScrollBar)

		-- Recruitment
		local Recruitment = _G.RecruitAFriendRecruitmentFrame
		Recruitment:StripTextures()
		Recruitment:SetTemplate('Transparent')
		S:HandleEditBox(Recruitment.EditBox)
		S:HandleButton(Recruitment.GenerateOrCopyLinkButton)
		S:HandleCloseButton(Recruitment.CloseButton)

		-- Rewards
		local rewardsFrame = _G.RecruitAFriendRewardsFrame
		rewardsFrame:StripTextures()
		rewardsFrame:SetTemplate('Transparent')

		-- Blizzard sets the atlas again on every refresh
		rewardsFrame.Background:SetAlpha(0)
		rewardsFrame.Watermark:SetAlpha(0)

		S:HandleCloseButton(rewardsFrame.CloseButton)

		hooksecurefunc(rewardsFrame, 'UpdateRewards', RAFRewards)
		RAFRewards() -- Because it's loaded already. The securehook is for when it updates in game. Thanks for playing.

		HandleSocialUI()
	else
		-- Friends Frame
		local FriendsFrame = _G.FriendsFrame
		S:HandleFrame(FriendsFrame, true, nil, -5, 0, -2)
		_G.FriendsFrameCloseButton:Point('TOPRIGHT', 0, 2)
		S:HandleDropDownBox(_G.FriendsFrameStatusDropdown, 70)
		_G.FriendsFrameStatusDropdown:PointXY(256, -55)

		for i = 1, 4 do -- friends, who, guild, raid
			S:HandleTab(_G['FriendsFrameTab'..i])
		end

		-- Reposition Tabs
		hooksecurefunc('FriendsFrame_UpdateGuildTabVisibility', RepositionTabs)

		-- Friends List Frame
		for i = 1, _G.FRIEND_HEADER_TAB_IGNORE do
			local tab = _G['FriendsTabHeaderTab'..i]
			S:HandleFrame(tab, true, nil, 3, -7, -2, -1)

			tab:HookScript('OnEnter', S.SetModifiedBackdrop)
			tab:HookScript('OnLeave', S.SetOriginalBackdrop)
		end

		local FriendsScrollFrame = _G.FriendsFrameFriendsScrollFrame
		for _, button in next, FriendsScrollFrame.buttons do
			local summonButton = button.summonButton
			summonButton.icon:SetTexCoords()
			summonButton.NormalTexture:SetAlpha(0)
			summonButton:StyleButton()

			button.highlight:SetTexture(E.Media.Textures.Highlight)
			button.highlight:SetAlpha(0.3)
		end

		for i = 1, _G.FRIENDS_FRIENDS_TO_DISPLAY do
			S:HandleButtonHighlight(_G['FriendsFriendsButton'..i])
		end

		S:HandleScrollBar(_G.FriendsFrameFriendsScrollFrameScrollBar)
		S:HandleButton(_G.AddFriendEntryFrameAcceptButton)
		S:HandleButton(_G.AddFriendEntryFrameCancelButton)
		S:HandleButton(_G.FriendsFrameAddFriendButton)
		S:HandleButton(_G.FriendsFrameSendMessageButton)
		S:HandleButton(_G.FriendsFrameUnsquelchButton)
		_G.FriendsFrameAddFriendButton:PointXY(-1, 4)

		-- Battle.net
		local FriendsFrameBattlenetFrame = _G.FriendsFrameBattlenetFrame
		FriendsFrameBattlenetFrame:StripTextures()
		FriendsFrameBattlenetFrame:GetRegions():Hide()
		FriendsFrameBattlenetFrame.UnavailableInfoFrame:Point('TOPLEFT', FriendsFrame, 'TOPRIGHT', 1, -18)
		FriendsFrameBattlenetFrame.Tag:SetParent(_G.FriendsListFrame)
		FriendsFrameBattlenetFrame.Tag:Point('TOP', FriendsFrame, 'TOP', 0, -8)

		local FriendsFrameBroadcastInput = _G.FriendsFrameBroadcastInput
		FriendsFrameBroadcastInput:CreateBackdrop()
		FriendsFrameBroadcastInput:Width(250)
		FriendsFrameBroadcastInput:Point('TOPLEFT', 22, -32)
		FriendsFrameBroadcastInput:Point('TOPRIGHT', -9, -32)

		_G.FriendsFrameBroadcastInputLeft:Kill()
		_G.FriendsFrameBroadcastInputRight:Kill()
		_G.FriendsFrameBroadcastInputMiddle:Kill()

		hooksecurefunc('FriendsFrame_Update', UpdateFriendsFrame)
		hooksecurefunc('FriendsFrame_CheckBattlenetStatus', CheckBattlenetStatus)

		_G.FriendsFrame_CheckBattlenetStatus()

		S:HandleEditBox(_G.AddFriendNameEditBox)
		_G.AddFriendFrame:SetTemplate('Transparent')

		-- Pending invites
		FriendsScrollFrame:StripTextures()

		local PendingInvitesHeaderButton = FriendsScrollFrame.PendingInvitesHeaderButton
		S:HandleButton(PendingInvitesHeaderButton, true)
		PendingInvitesHeaderButton:SetScript('OnMouseUp', nil)
		PendingInvitesHeaderButton:SetScript('OnMouseDown', nil)
		PendingInvitesHeaderButton.RightArrow:SetTexture(E.Media.Textures.ArrowUp)
		PendingInvitesHeaderButton.RightArrow:SetRotation(S.ArrowRotation.right)
		PendingInvitesHeaderButton.RightArrow:SetPoint('LEFT', 11, 0)
		PendingInvitesHeaderButton.DownArrow:SetTexture(E.Media.Textures.ArrowUp)
		PendingInvitesHeaderButton.DownArrow:SetRotation(S.ArrowRotation.down)
		PendingInvitesHeaderButton.DownArrow:SetPoint('TOPLEFT', 8, -10)

		hooksecurefunc(FriendsScrollFrame.invitePool, 'Acquire', AcquireInvitePool)

		S:HandleFrame(_G.FriendsFriendsFrame, true)
		_G.FriendsFriendsList:StripTextures()

		S:HandleButton(_G.FriendsFriendsCloseButton)
		S:HandleButton(_G.FriendsFriendsSendRequestButton)
		S:HandleEditBox(_G.FriendsFriendsList)
		S:HandleScrollBar(_G.FriendsFriendsScrollFrameScrollBar)
		S:HandleDropDownBox(_G.FriendsFriendsFrameDropdown, 150)

		-- Ignore List Frame
		_G.IgnoreListFrame:StripTextures()
		S:HandleButton(_G.FriendsFrameIgnorePlayerButton, true)
		S:HandleScrollBar(_G.FriendsFrameIgnoreScrollFrameScrollBar)

		-- Who Frame
		_G.WhoFrame:StripTextures()
		_G.WhoFrameListInset:StripTextures()
		_G.WhoFrameListInset.NineSlice:Hide()

		_G.WhoListScrollFrame:StripTextures()
		S:HandleScrollBar(_G.WhoListScrollFrameScrollBar)

		S:HandleBlizzardRegions(_G.WhoFrameEditBox)
		_G.WhoFrameEditBox:CreateBackdrop()
		_G.WhoFrameEditBox.backdrop:Point('TOPLEFT', _G.WhoFrameEditBox.Left)
		_G.WhoFrameEditBox.backdrop:Point('BOTTOMRIGHT', _G.WhoFrameEditBox.Right)

		for _, header in next, { _G.WhoFrameColumnHeader1, _G.WhoFrameColumnHeader2, _G.WhoFrameColumnHeader3, _G.WhoFrameColumnHeader4 } do
			header:StripTextures()
		end

		for _, button in next, { _G.WhoFrameWhoButton, _G.WhoFrameAddFriendButton, _G.WhoFrameGroupInviteButton } do
			S:HandleButton(button)
		end

		-- Increase width of Level column slightly
		WhoFrameColumn_SetWidth(_G.WhoFrameColumnHeader3, 37) -- Default is 32

		for i = 1, _G.WHOS_TO_DISPLAY do
			local level = _G['WhoFrameButton'..i..'Level']
			level:Width(level:GetWidth() + 5)
		end

		S:HandleDropDownBox(_G.WhoFrameDropdown, 90)

		HandleGuild()
	end
end
