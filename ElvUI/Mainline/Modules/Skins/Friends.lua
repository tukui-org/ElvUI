local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local pairs = pairs
local select = select
local unpack = unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local WhoFrameColumn_SetWidth = WhoFrameColumn_SetWidth
local FriendsFrame_GetInviteRestriction = FriendsFrame_GetInviteRestriction

local INVITE_RESTRICTION_NONE = 9

--Social Frame
local function SkinSocialHeaderTab(tab)
	if not tab then return end

	tab:StripTextures()
	tab:CreateBackdrop('Transparent')
	tab.backdrop:Point('TOPLEFT', 3, -8)
	tab.backdrop:Point('BOTTOMRIGHT', -6, 0)
end

local function BattleNetFrame_OnEnter(button)
	if not button.backdrop then return end
	local bnetColor = _G.FRIENDS_BNET_NAME_COLOR

	button.backdrop:SetBackdropBorderColor(bnetColor.r, bnetColor.g, bnetColor.b)
end

local function BattleNetFrame_OnLeave(button)
	if not button.backdrop then return end

	button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

local function BattleNetFrame_OnClick()
	_G.FriendsFrameBattlenetFrame.BroadcastFrame:ToggleFrame()
end

local function RAFRewardQuality(button)
	if not button.Icon or not button.item then return end

	local quality = button.item:GetItemQuality()
	local r, g, b = E:GetItemQualityColor(quality)
	button.Icon.backdrop:SetBackdropBorderColor(r, g, b)
end

local function RAFRewards()
	local claiming = _G.RecruitAFriendFrame.RewardClaiming
	if claiming and claiming.NextRewardButton then
		claiming.NextRewardButton.Icon:SetDesaturation(0)
	end

	local rewardsFrame = _G.RecruitAFriendRewardsFrame
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
	if summon then
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
	end

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
	if gameIcon then
		gameIcon:Size(26)
		gameIcon:SetTexCoord(0, 1, 0, 1)
		gameIcon:ClearAllPoints()
		gameIcon:Point('RIGHT', invite, 'LEFT', -6, 0)
	end

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
	local tab = _G.FriendsFrameTab1
	local index, lastTab = 1, tab
	while tab do
		S:HandleTab(tab)

		tab:ClearAllPoints()

		if index == 1 then
			tab:Point('BOTTOMLEFT', _G.FriendsFrame, 'BOTTOMLEFT', -3, -32)
		else
			tab:Point('TOPLEFT', lastTab, 'TOPRIGHT', -5, 0)
			lastTab = tab
		end

		index = index + 1
		tab = _G['FriendsFrameTab'..index]
	end
end

local function UpdateFriendButton(button)
	if button.gameIcon then
		ReskinFriendButton(button)
	end

	if button.newIcon and button.buttonType == _G.FRIENDS_BUTTON_TYPE_BNET then
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

local StripAllTextures = {
	'FriendsTabHeaderTab1',
	'FriendsTabHeaderTab2',
	'WhoFrameColumnHeader1',
	'WhoFrameColumnHeader2',
	'WhoFrameColumnHeader3',
	'WhoFrameColumnHeader4',
	'AddFriendFrame',
}

local ButtonsToHandle = {
	'FriendsFrameAddFriendButton',
	'FriendsFrameSendMessageButton',
	'WhoFrameWhoButton',
	'WhoFrameAddFriendButton',
	'WhoFrameGroupInviteButton',
	'FriendsFrameIgnorePlayerButton',
	'FriendsFrameUnsquelchButton',
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
	S:HandleTrimScrollBar(_G.IgnoreListFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.WhoFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.FriendsFriendsFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.QuickJoinFrame.ScrollBar)

	for _, button in pairs(ButtonsToHandle) do
		S:HandleButton(_G[button])
	end

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	local FriendsFrame = _G.FriendsFrame
	S:HandlePortraitFrame(FriendsFrame)

	_G.FriendsFrameIcon:Hide()
	_G.IgnoreListFrame:StripTextures()

	S:HandleDropDownBox(_G.FriendsFrameStatusDropdown, 70)

	_G.FriendsFrameStatusDropdown:ClearAllPoints()
	_G.FriendsFrameStatusDropdown:Point('TOPLEFT', FriendsFrame, 'TOPLEFT', 5, -24)

	local FriendsFrameBattlenetFrame = _G.FriendsFrameBattlenetFrame
	FriendsFrameBattlenetFrame:StripTextures()
	FriendsFrameBattlenetFrame:SetTemplate('Transparent')

	local bnetColor = _G.FRIENDS_BNET_BACKGROUND_COLOR
	local BattlenetFrame = CreateFrame('Button', nil, FriendsFrameBattlenetFrame)
	BattlenetFrame:Point('TOPLEFT', FriendsFrameBattlenetFrame, 'TOPLEFT')
	BattlenetFrame:Point('BOTTOMRIGHT', FriendsFrameBattlenetFrame, 'BOTTOMRIGHT')
	BattlenetFrame:Size(FriendsFrameBattlenetFrame:GetSize())
	BattlenetFrame:CreateBackdrop('Transparent')
	BattlenetFrame.backdrop:SetBackdropColor(bnetColor.r, bnetColor.g, bnetColor.b, bnetColor.a)
	BattlenetFrame.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))

	BattlenetFrame:SetScript('OnClick', BattleNetFrame_OnClick)
	BattlenetFrame:SetScript('OnEnter', BattleNetFrame_OnEnter)
	BattlenetFrame:SetScript('OnLeave', BattleNetFrame_OnLeave)

	FriendsFrameBattlenetFrame.BroadcastButton:Kill() -- We use the BattlenetFrame to enter a Status Message
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
		local region = broadcastEdit[name]
		if region then region:Hide() end
	end

	S:HandleEditBox(broadcastEdit)
	S:HandleEditBox(_G.AddFriendNameEditBox)
	_G.AddFriendFrame:SetTemplate('Transparent')

	hooksecurefunc('FriendsFrame_UpdateFriendButton', UpdateFriendButton)
	hooksecurefunc('FriendsFrame_UpdateFriendInviteButton', UpdateFriendInviteButton)
	hooksecurefunc('FriendsFrame_UpdateFriendInviteHeaderButton', UpdateFriendInviteHeaderButton)

	--Who Frame
	_G.WhoFrame:StripTextures()
	_G.WhoFrameListInset:StripTextures()
	_G.WhoFrameListInset.NineSlice:Hide()
	_G.WhoFrameEditBox.Backdrop:StripTextures()
	_G.WhoFrameEditBox.Backdrop:CreateBackdrop()

	--Increase width of Level column slightly
	WhoFrameColumn_SetWidth(_G.WhoFrameColumnHeader3, 37) -- Default is 32
	for i = 1, 17 do
		local level = _G['WhoFrameButton'..i..'Level']
		if level then
			level:Width(level:GetWidth() + 5)
		end
	end

	S:HandleDropDownBox(_G.WhoFrameDropdown, 90)

	-- Bottom Tabs
	HandleTabs()

	for i = 1, 3 do
		local tab = _G['FriendsTabHeaderTab'..i]
		if tab then
			SkinSocialHeaderTab(tab)
		end
	end

	--View Friends BN Frame
	local FriendsFriendsFrame = _G.FriendsFriendsFrame
	FriendsFriendsFrame.ScrollFrameBorder:Hide()
	FriendsFriendsFrame:StripTextures()
	FriendsFriendsFrame:SetTemplate('Transparent')
	S:HandleDropDownBox(_G.FriendsFriendsFrameDropdown, 150)
	S:HandleButton(FriendsFriendsFrame.SendRequestButton)
	S:HandleButton(FriendsFriendsFrame.CloseButton)

	--Quick join
	local QuickJoinFrame = _G.QuickJoinFrame
	local QuickJoinRoleSelectionFrame = _G.QuickJoinRoleSelectionFrame
	S:HandleButton(_G.QuickJoinFrame.JoinQueueButton)
	QuickJoinFrame.JoinQueueButton:Size(131, 21) --Match button on other tab
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
		SplashFrame.Background:SetColorTexture(unpack(E.media.bordercolor))

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
	Claiming:StripTextures()
	Claiming:SetTemplate('Transparent')
	Claiming:Point('TOPLEFT', 4, -84)
	Claiming.Background:SetAlpha(0)
	Claiming.Watermark:SetAlpha(0)
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
	rewardsFrame:StripTextures()
	rewardsFrame:SetTemplate('Transparent')
	rewardsFrame.Background:SetAlpha(0)
	rewardsFrame.Watermark:SetAlpha(0)
	S:HandleCloseButton(rewardsFrame.CloseButton)

	hooksecurefunc(rewardsFrame, 'UpdateRewards', RAFRewards)
	RAFRewards() -- Because it's loaded already. The securehook is for when it updates in game. Thanks for playing.
end

S:AddCallback('FriendsFrame')
