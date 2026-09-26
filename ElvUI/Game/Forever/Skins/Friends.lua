local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local pairs = pairs
local unpack = unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local FriendsFrame_GetInviteRestriction = FriendsFrame_GetInviteRestriction

local BNET_NAME_COLOR = FRIENDS_BNET_NAME_COLOR
local BNET_BACKGROUND_COLOR = FRIENDS_BNET_BACKGROUND_COLOR
local INVITE_RESTRICTION_NONE = 9

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

-- parchment remover off: the pane art above the ElvUI backdrop, its brackets and watermark above the parchment
local function RAFPaneParchment(pane)
	pane.Background:SetDrawLayer('BACKGROUND', 1)

	for _, region in next, { pane.Bracket_TopLeft, pane.Bracket_TopRight, pane.Bracket_BottomRight, pane.Bracket_BottomLeft, pane.Watermark } do
		region:SetDrawLayer('BACKGROUND', 2)
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
	for _, tab in next, { _G.FriendsFrameTab1, _G.FriendsFrameTab3, _G.FriendsFrameTab4 } do -- no Who tab, it lives in the group finder
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

function S:FriendsFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.friends) then return end

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

	local broadcastEdit = FriendsFrameBattlenetFrame.BroadcastFrame.EditBox
	for _, name in next, EditBoxBorders do
		broadcastEdit[name]:Hide()
	end

	S:HandleEditBox(broadcastEdit)
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

	local RAF = _G.RecruitAFriendFrame
	S:HandleButton(RAF.RecruitmentButton)

	-- /run RecruitAFriendFrame:ShowSplashScreen()
	local SplashFrame = RAF.SplashFrame
	S:HandleButton(SplashFrame.OKButton)

	if E.private.skins.parchmentRemoverEnable then
		RAFShowSplashScreen(RAF)
		-- Blizzard sets the parchment atlas again on every show
		hooksecurefunc(RAF, 'ShowSplashScreen', RAFShowSplashScreen)

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

	local Claiming = RAF.RewardClaiming
	if E.private.skins.parchmentRemoverEnable then
		Claiming:StripTextures()
		-- Blizzard sets the atlas again on every reward update
		Claiming.Background:SetAlpha(0)
		Claiming.Watermark:SetAlpha(0)
	else
		Claiming.Inset:StripTextures()
		RAFPaneParchment(Claiming)
	end

	Claiming:SetTemplate('Transparent')
	Claiming:Point('TOPLEFT', 4, -84)
	S:HandleButton(Claiming.ClaimOrViewRewardButton)

	local NextReward = Claiming.NextRewardButton
	S:HandleIcon(NextReward.Icon, true)
	NextReward.CircleMask:Hide()
	NextReward.IconBorder:SetAlpha(0)
	NextReward.IconOverlay:SetAlpha(0)
	RAFRewardQuality(NextReward)

	local RecruitList = RAF.RecruitList
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
	if E.private.skins.parchmentRemoverEnable then
		rewardsFrame:StripTextures()
		-- Blizzard sets the atlas again on every refresh
		rewardsFrame.Background:SetAlpha(0)
		rewardsFrame.Watermark:SetAlpha(0)
	else
		rewardsFrame.Border:StripTextures()
		RAFPaneParchment(rewardsFrame)
	end

	rewardsFrame:SetTemplate('Transparent')
	S:HandleCloseButton(rewardsFrame.CloseButton)

	hooksecurefunc(rewardsFrame, 'UpdateRewards', RAFRewards)
	RAFRewards() -- Because it's loaded already. The securehook is for when it updates in game. Thanks for playing.
end

S:AddCallback('FriendsFrame')
