local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local unpack = unpack

local hooksecurefunc = hooksecurefunc
local WhoFrameColumn_SetWidth = WhoFrameColumn_SetWidth

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

local function RAFRewardQuality(button)
	if not button.Icon or not button.item then return end

	local quality = button.item:GetItemQuality()
	local r, g, b = E:GetItemQualityColor(quality)
	button.Icon.backdrop:SetBackdropBorderColor(r, g, b)
end

local function RAFRewards()
	local rewardsFrame = _G.RecruitAFriendRewardsFrame
	if not rewardsFrame then return end

	local claiming = _G.RecruitAFriendFrame and _G.RecruitAFriendFrame.RewardClaiming
	if claiming and claiming.NextRewardButton then
		claiming.NextRewardButton.Icon:SetDesaturation(0)
	end

	for tab in rewardsFrame.rewardTabPool:EnumerateActive() do
		if not tab.IsSkinned then
			tab:CreateBackdrop(nil, true, nil, nil, nil, nil, nil, true)
			tab:StyleButton()

			if tab.Tab then
				tab.Tab:Hide()
			end

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

		local text = reward.Months
		if text then
			text:SetTextColor(1, 1, 1)
		end
	end
end

local function HideEditBoxBorders(editBox)
	for _, name in next, EditBoxBorders do
		local region = editBox[name]
		if region then
			region:Hide()
		end
	end
end

function S:SocialUI_PositionTab(_, relativeTo, _, x, y)
	local frame = _G.SocialUIFrame
	if relativeTo == frame and (x ~= 2 or y ~= -1) then
		self:ClearAllPoints()
		self:SetPoint('TOPLEFT', frame, 'TOPRIGHT', 2, -1)
	end
end

function S:SocialUI_PositionTabIcon(point)
	if point == 'CENTER' then return end

	self:ClearAllPoints()
	self:SetPoint('CENTER')
end

function S:SocialUI_HandleTab(tab)
	if tab.IsSkinned then return end

	tab:CreateBackdrop()
	tab:Size(30, 40)

	if tab.Icon then
		S.SocialUI_PositionTabIcon(tab.Icon)
		hooksecurefunc(tab.Icon, 'SetPoint', S.SocialUI_PositionTabIcon)
	end

	if tab.Background then
		tab.Background:SetAlpha(0)
	end

	if tab.SelectedTexture then
		tab.SelectedTexture:SetDrawLayer('ARTWORK')
		tab.SelectedTexture:SetColorTexture(1, 0.82, 0, 0.3)
		tab.SelectedTexture:SetAllPoints()
	end

	if tab.HighlightTexture then
		tab.HighlightTexture:SetColorTexture(1, 1, 1, 0.3)
		tab.HighlightTexture:SetAllPoints()
	end

	if tab.TabGlow then
		tab.TabGlow:SetAlpha(0)
	end

	tab.IsSkinned = true
end

function S:SocialUI_RefreshTabs()
	local frame = _G.SocialUIFrame
	if not frame or not frame.socialTabPool then return end

	for tab in frame.socialTabPool:EnumerateActive() do
		S:SocialUI_HandleTab(tab)
		S.SocialUI_PositionTab(tab, tab:GetPoint())

		if not tab.SocialUITabHooked then
			hooksecurefunc(tab, 'SetPoint', S.SocialUI_PositionTab)
			tab.SocialUITabHooked = true
		end
	end
end

function S:SocialUI_HandleActionButton(button)
	if not button or button.IsSkinned then return end

	button:CreateBackdrop('Transparent', nil, nil, nil, nil, nil, nil, nil, true)

	if button.NormalTexture then button.NormalTexture:SetAlpha(0) end
	if button.PushedTexture then button.PushedTexture:SetAlpha(0) end
	if button.HighlightTexture then
		button.HighlightTexture:SetColorTexture(1, 1, 1, 0.25)
		button.HighlightTexture:SetAllPoints()
	end

	button.IsSkinned = true
end

function S:SocialUI_HandleScrollableHeader(header)
	if not header or header.IsSkinned then return end

	header:StripTextures()
	S:HandleButton(header)

	header.IsSkinned = true
end

function S:SocialUI_HandleSocialCard()
	if self.IsSkinned then return end

	-- Collapsible section headers
	if self.ButtonText then
		S:SocialUI_HandleScrollableHeader(self)
		return
	end

	-- Spacers
	if not self.Background and not self.PartyButton and not self.AcceptButton then
		self.IsSkinned = true
		return
	end

	if self.Background then
		self.Background:SetAlpha(0)
	end

	self:CreateBackdrop('Transparent')
	self.backdrop:SetInside(self, 2, 2)

	local highlight = self.Highlight or self:GetHighlightTexture()
	if highlight then
		highlight:SetColorTexture(0.24, 0.56, 1, 0.2)
		highlight:SetInside(self.backdrop)
	end

	if self.Selected then
		self.Selected:SetColorTexture(1, 0.82, 0, 0.2)
		self.Selected:SetAllPoints(self.backdrop)
	end

	S:SocialUI_HandleActionButton(self.PartyButton)
	S:SocialUI_HandleActionButton(self.RAFSummonButton)

	if self.AcceptButton then
		S:HandleButton(self.AcceptButton)
	end

	if self.DeclineButton then
		S:HandleButton(self.DeclineButton)
	end

	self.IsSkinned = true
end

function S:SocialUI_ScrollBoxUpdate()
	if not self.ForEachFrame then return end

	self:ForEachFrame(S.SocialUI_HandleSocialCard)
end

function S:SocialUI_HandleContactsView(view)
	if not view or view.IsSkinned then return end

	local filterBar = view.FilterBar
	if filterBar then
		if filterBar.SearchBar then
			S:HandleEditBox(filterBar.SearchBar)
		end

		if filterBar.SearchFilterDropdown then
			S:HandleButton(filterBar.SearchFilterDropdown, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true, 'right')
		end
	end

	if view.TopDivider then
		view.TopDivider:SetAlpha(0)
	end

	if view.BottomDivider then
		view.BottomDivider:SetAlpha(0)
	end

	if view.ScrollBar then
		S:HandleTrimScrollBar(view.ScrollBar)
	end

	if view.ActionButton then
		S:HandleButton(view.ActionButton)
	end

	if view.ScrollBox then
		hooksecurefunc(view.ScrollBox, 'Update', S.SocialUI_ScrollBoxUpdate)
		S.SocialUI_ScrollBoxUpdate(view.ScrollBox)
	end

	view.IsSkinned = true
end

function S:SocialUI_HandleRewardClaiming(claiming)
	if not claiming or claiming.IsSkinned then return end

	claiming:StripTextures()
	claiming:SetTemplate('Transparent')

	if claiming.Background then
		claiming.Background:SetAlpha(0)
	end

	if claiming.Watermark then
		claiming.Watermark:SetAlpha(0)
	end

	if claiming.ClaimOrViewRewardButton then
		S:HandleButton(claiming.ClaimOrViewRewardButton)
	end

	local nextReward = claiming.NextRewardButton
	if nextReward then
		S:HandleIcon(nextReward.Icon, true)

		if nextReward.CircleMask then
			nextReward.CircleMask:Hide()
		end

		if nextReward.IconBorder then
			nextReward.IconBorder:SetAlpha(0)
		end

		if nextReward.IconOverlay then
			nextReward.IconOverlay:SetAlpha(0)
		end

		RAFRewardQuality(nextReward)
	end

	claiming.IsSkinned = true
end

function S:SocialUI_HandleSideWindow(panel)
	if not panel or panel.IsSkinned then return end

	panel:StripTextures()
	panel:SetTemplate('Transparent')

	if panel.Border then
		panel.Border:Hide()
	end

	if panel.ScrollBar then
		S:HandleTrimScrollBar(panel.ScrollBar)
	end

	if panel.EditBox then
		HideEditBoxBorders(panel.EditBox)
		S:HandleEditBox(panel.EditBox)
	end

	if panel.UpdateButton then
		S:HandleButton(panel.UpdateButton)
	end

	if panel.CancelButton then
		S:HandleButton(panel.CancelButton)
	end

	if panel.BlockButton then
		S:HandleButton(panel.BlockButton)
	end

	if panel.UnblockButton then
		S:HandleButton(panel.UnblockButton)
	end

	if panel.CloseButton then
		S:HandleCloseButton(panel.CloseButton)
	end

	panel.IsSkinned = true
end

function S:SocialUI_HandleBattleNetBar(bar)
	if not bar or bar.IsSkinned then return end

	if bar.Background then
		bar.Background:SetAlpha(0)
	end

	local container = bar.ControlsContainer
	if container then
		if container.BattleNetBackground then
			container.BattleNetBackground:SetAlpha(0)
		end

		if container.OnlineStatusDropdown then
			S:HandleDropDownBox(container.OnlineStatusDropdown, 80)
			container.OnlineStatusDropdown:ClearAllPoints()
			container.OnlineStatusDropdown:SetPoint('LEFT', bar.ControlsContainer, 'LEFT', 9, 0)
		end

		S:SocialUI_HandleActionButton(container.BattleNetMenuButton)

		local battleTag = container.PersonalBattleTagDisplay
		if battleTag then
			S:SocialUI_HandleActionButton(battleTag.CopyBattleTagToClipboardButton)
			battleTag.CopyBattleTagToClipboardButton.backdrop:Hide()
		end
	end

	bar.IsSkinned = true
end

function S:Blizzard_SocialUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.friends) then return end

	local frame = _G.SocialUIFrame
	if not frame then return end

	S:HandlePortraitFrame(frame)

	if frame.TopFade then
		frame.TopFade:Hide()
	end

	if frame.BottomFade then
		frame.BottomFade:Hide()
	end

	S:SocialUI_HandleBattleNetBar(frame.BattleNetBar)

	-- Tabs on the right side are pooled and rebuilt on RefreshTabs
	hooksecurefunc(frame, 'RefreshTabs', S.SocialUI_RefreshTabs)
	S:SocialUI_RefreshTabs()

	-- Tab content views
	for _, view in next, { frame.FriendsList, frame.RecentAlliesList, frame.QuickJoinFrame, frame.FriendRequestsList } do
		S:SocialUI_HandleContactsView(view)
	end

	local recruitFrame = frame.RecruitAFriendFrame
	if recruitFrame then
		S:SocialUI_HandleContactsView(recruitFrame)
		S:SocialUI_HandleRewardClaiming(recruitFrame.RewardClaiming)

		if recruitFrame.RecruitmentButton then
			S:HandleButton(recruitFrame.RecruitmentButton)
		end

		if recruitFrame.NoRecruitsScrollBar then
			S:HandleTrimScrollBar(recruitFrame.NoRecruitsScrollBar)
		end
	end

	-- Raid tab
	local raidFrame = frame.RaidFrame
	if raidFrame then
		S:SocialUI_HandleContactsView(raidFrame)
		S:HandleButton(raidFrame.RaidInfoButton)
		S:HandleButton(raidFrame.ConvertToRaidButton)
	end

	-- Side windows anchored to the right of SocialUIFrame
	S:SocialUI_HandleSideWindow(frame.BattleNetBroadcastFrame)
	S:SocialUI_HandleSideWindow(frame.BattleNetUnavailableNoticeFrame)
	S:SocialUI_HandleSideWindow(frame.IgnoreListFrame)
	S:SocialUI_HandleSideWindow(frame.RaidInfoFrame)
end

function S:FriendsFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.friends) then return end

	-- /who still opens through the old FriendsFrame
	local FriendsFrame = _G.FriendsFrame
	if FriendsFrame then
		S:HandlePortraitFrame(FriendsFrame)

		if _G.FriendsFrameIcon then
			_G.FriendsFrameIcon:Hide()
		end

		local tab = _G.FriendsFrameTab1
		local index = 1
		while tab do
			S:HandleTab(tab)
			index = index + 1
			tab = _G['FriendsFrameTab'..index]
		end
	end

	local WhoFrame = _G.WhoFrame
	if WhoFrame then
		WhoFrame:StripTextures()

		if _G.WhoFrameListInset then
			_G.WhoFrameListInset:StripTextures()

			if _G.WhoFrameListInset.NineSlice then
				_G.WhoFrameListInset.NineSlice:Hide()
			end
		end

		if _G.WhoFrameEditBox and _G.WhoFrameEditBox.Backdrop then
			_G.WhoFrameEditBox.Backdrop:StripTextures()
			_G.WhoFrameEditBox.Backdrop:CreateBackdrop()
		end

		if _G.WhoFrame.ScrollBar then
			S:HandleTrimScrollBar(_G.WhoFrame.ScrollBar)
		end

		if _G.WhoFrameColumnHeader3 then
			WhoFrameColumn_SetWidth(_G.WhoFrameColumnHeader3, 37)
		end

		for i = 1, 17 do
			local level = _G['WhoFrameButton'..i..'Level']
			if level then
				level:Width(level:GetWidth() + 5)
			end
		end

		if _G.WhoFrameDropdown then
			S:HandleDropDownBox(_G.WhoFrameDropdown, 90)
		end

		if _G.WhoFrameWhoButton then
			S:HandleButton(_G.WhoFrameWhoButton)
		end

		if _G.WhoFrameAddFriendButton then
			S:HandleButton(_G.WhoFrameAddFriendButton)
		end

		if _G.WhoFrameGroupInviteButton then
			S:HandleButton(_G.WhoFrameGroupInviteButton)
		end

		for i = 1, 4 do
			local header = _G['WhoFrameColumnHeader'..i]
			if header then
				header:StripTextures()
			end
		end
	end

	-- Add friend popup
	if _G.AddFriendFrame then
		_G.AddFriendFrame:StripTextures()
		_G.AddFriendFrame:SetTemplate('Transparent')

		if _G.AddFriendFrame.CloseButton then
			S:HandleCloseButton(_G.AddFriendFrame.CloseButton)
		end
	end

	if _G.AddFriendNameEditBox then
		S:HandleEditBox(_G.AddFriendNameEditBox)
	end

	if _G.AddFriendEntryFrameAcceptButton then
		S:HandleButton(_G.AddFriendEntryFrameAcceptButton)
	end

	if _G.AddFriendEntryFrameCancelButton then
		S:HandleButton(_G.AddFriendEntryFrameCancelButton)
	end

	-- View Friends BN popup
	local friendsFrame = _G.FriendsFriendsFrame
	if friendsFrame then
		if friendsFrame.ScrollFrameBorder then
			friendsFrame.ScrollFrameBorder:Hide()
		end

		friendsFrame:StripTextures()
		friendsFrame:SetTemplate('Transparent')

		if friendsFrame.ScrollBar then
			S:HandleTrimScrollBar(friendsFrame.ScrollBar)
		end

		if _G.FriendsFriendsFrameDropdown then
			S:HandleDropDownBox(_G.FriendsFriendsFrameDropdown, 150)
		end

		S:HandleButton(friendsFrame.SendRequestButton)
		S:HandleButton(friendsFrame.CloseButton)
	end

	-- Quick Join role selection popup
	local quickJoinSelection = _G.QuickJoinRoleSelectionFrame
	if quickJoinSelection then
		quickJoinSelection:StripTextures()
		quickJoinSelection:SetTemplate('Transparent')

		S:HandleButton(quickJoinSelection.AcceptButton)
		S:HandleButton(quickJoinSelection.CancelButton)
		S:HandleCloseButton(quickJoinSelection.CloseButton)
		S:HandleCheckBox(quickJoinSelection.RoleButtonTank.CheckButton)
		S:HandleCheckBox(quickJoinSelection.RoleButtonHealer.CheckButton)
		S:HandleCheckBox(quickJoinSelection.RoleButtonDPS.CheckButton)
	end

	-- Recruit-a-Friend popups / splash (still used from Social UI RAF tab)
	local recruitFrame = _G.RecruitAFriendFrame
	if recruitFrame then
		if recruitFrame.RecruitmentButton then
			S:HandleButton(recruitFrame.RecruitmentButton)
		end

		local splashFrame = recruitFrame.SplashFrame
		if splashFrame then
			S:HandleButton(splashFrame.OKButton)

			if E.private.skins.parchmentRemoverEnable then
				splashFrame.Background:SetColorTexture(unpack(E.media.bordercolor))

				splashFrame.PictureFrame:Hide()
				splashFrame.Bracket_TopLeft:Hide()
				splashFrame.Bracket_TopRight:Hide()
				splashFrame.Bracket_BottomRight:Hide()
				splashFrame.Bracket_BottomLeft:Hide()
				splashFrame.PictureFrame_Bracket_TopLeft:Hide()
				splashFrame.PictureFrame_Bracket_TopRight:Hide()
				splashFrame.PictureFrame_Bracket_BottomRight:Hide()
				splashFrame.PictureFrame_Bracket_BottomLeft:Hide()
			end
		end

		if recruitFrame.RewardClaiming then
			S:SocialUI_HandleRewardClaiming(recruitFrame.RewardClaiming)
		end

		local recruitList = recruitFrame.RecruitList
		if recruitList then
			if recruitList.Header then
				recruitList.Header:StripTextures()
			end

			if recruitList.ScrollFrameInset then
				recruitList.ScrollFrameInset:StripTextures()
				recruitList.ScrollFrameInset:SetTemplate('Transparent')
			end

			if recruitList.ScrollBar then
				S:HandleTrimScrollBar(recruitList.ScrollBar)
			end
		end
	end

	local recruitment = _G.RecruitAFriendRecruitmentFrame
	if recruitment then
		recruitment:StripTextures()
		recruitment:SetTemplate('Transparent')

		S:HandleEditBox(recruitment.EditBox)
		S:HandleButton(recruitment.GenerateOrCopyLinkButton)
		S:HandleCloseButton(recruitment.CloseButton)
	end

	local rewardsFrame = _G.RecruitAFriendRewardsFrame
	if rewardsFrame then
		rewardsFrame:StripTextures()
		rewardsFrame:SetTemplate('Transparent')

		if rewardsFrame.Background then
			rewardsFrame.Background:SetAlpha(0)
		end

		if rewardsFrame.Watermark then
			rewardsFrame.Watermark:SetAlpha(0)
		end

		S:HandleCloseButton(rewardsFrame.CloseButton)

		hooksecurefunc(rewardsFrame, 'UpdateRewards', RAFRewards)
		RAFRewards()
	end
end

S:AddCallback('FriendsFrame')
S:AddCallbackForAddon('Blizzard_SocialUI')
