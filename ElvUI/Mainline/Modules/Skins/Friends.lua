local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next
local pairs = pairs
local unpack = unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local WhoFrameColumn_SetWidth = WhoFrameColumn_SetWidth
local FriendsFrame_GetInviteRestriction = FriendsFrame_GetInviteRestriction

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

local function RAFRewards()
	for reward in _G.RecruitAFriendRewardsFrame.rewardPool:EnumerateActive() do
		S:HandleIcon(reward.Button.Icon)
		reward.Button.IconBorder:Kill()
	end
end

local atlasToTex = {
	['friendslist-invitebutton-horde-normal'] = [[Interface\FriendsFrame\PlusManz-Horde]],
	['friendslist-invitebutton-alliance-normal'] = [[Interface\FriendsFrame\PlusManz-Alliance]],
	['friendslist-invitebutton-default-normal'] = [[Interface\FriendsFrame\PlusManz-PlusManz]],
}

local function HandleInviteTex(self, atlas)
	local tex = atlasToTex[atlas]
	if tex then
		self.ownerIcon:SetTexture(tex)
	end
end

local function ReskinFriendButton(button)
	if not button.IsSkinned then
		local gameIcon = button.gameIcon
		gameIcon:SetSize(22, 22)
		gameIcon:SetTexCoord(.17, .83, .17, .83)
		button.background:Hide()
		button:SetHighlightTexture(E.media.normTex)
		button:GetHighlightTexture():SetVertexColor(.24, .56, 1, .2)
		gameIcon:CreateBackdrop('Transparent')
		button.bg = gameIcon.backdrop

		local travelPass = button.travelPassButton
		travelPass:SetSize(22, 22)
		travelPass:Point('TOPRIGHT', -3, -6)
		travelPass:CreateBackdrop()
		travelPass.NormalTexture:SetAlpha(0)
		travelPass.PushedTexture:SetAlpha(0)
		travelPass.DisabledTexture:SetAlpha(0)
		travelPass.HighlightTexture:SetColorTexture(1, 1, 1, .25)
		travelPass.HighlightTexture:SetAllPoints()
		gameIcon:Point('TOPRIGHT', travelPass, 'TOPLEFT', -4, 0)

		local icon = travelPass:CreateTexture(nil, 'ARTWORK')
		icon:SetTexCoord(.1, .9, .1, .9)
		icon:SetAllPoints()
		button.newIcon = icon
		travelPass.NormalTexture.ownerIcon = icon
		hooksecurefunc(travelPass.NormalTexture, 'SetAtlas', HandleInviteTex)

		button.IsSkinned = true
	end

	button.bg:SetShown(button.gameIcon:IsShown())
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

function S:FriendsFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.friends) then return end

	S:HandleTrimScrollBar(_G.FriendsListFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.IgnoreListFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.WhoFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.FriendsFriendsFrame.ScrollBar)
	S:HandleTrimScrollBar(_G.QuickJoinFrame.ScrollBar)

	local StripAllTextures = {
		'FriendsTabHeaderTab1',
		'FriendsTabHeaderTab2',
		'WhoFrameColumnHeader1',
		'WhoFrameColumnHeader2',
		'WhoFrameColumnHeader3',
		'WhoFrameColumnHeader4',
		'AddFriendFrame',
	}

	local buttons = {
		'FriendsFrameAddFriendButton',
		'FriendsFrameSendMessageButton',
		'WhoFrameWhoButton',
		'WhoFrameAddFriendButton',
		'WhoFrameGroupInviteButton',
		'FriendsFrameIgnorePlayerButton',
		'FriendsFrameUnsquelchButton',
		'AddFriendEntryFrameAcceptButton',
		'AddFriendEntryFrameCancelButton',
		'AddFriendInfoFrameContinueButton',
	}

	for _, button in pairs(buttons) do
		S:HandleButton(_G[button])
	end

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	local mainFrames = {
		'WhoFrame',
		'LFRQueueFrame',
	}

	for _, frame in pairs(mainFrames) do
		_G[frame]:StripTextures()
	end

	local FriendsFrame = _G.FriendsFrame
	S:HandlePortraitFrame(FriendsFrame)

	_G.FriendsFrameIcon:Hide()
	_G.IgnoreListFrame:StripTextures()

	S:HandleDropDownBox(_G.FriendsFrameStatusDropDown, 70)

	_G.FriendsFrameStatusDropDown:ClearAllPoints()
	_G.FriendsFrameStatusDropDown:Point('TOPLEFT', FriendsFrame, 'TOPLEFT', 5, -24)

	local FriendsFrameBattlenetFrame = _G.FriendsFrameBattlenetFrame
	FriendsFrameBattlenetFrame:StripTextures()
	FriendsFrameBattlenetFrame:SetTemplate('Transparent')

	local bnetColor = _G.FRIENDS_BNET_BACKGROUND_COLOR
	local BattlenetFrame = CreateFrame('Button', nil, FriendsFrameBattlenetFrame)
	BattlenetFrame:Point('TOPLEFT', FriendsFrameBattlenetFrame, 'TOPLEFT')
	BattlenetFrame:Point('BOTTOMRIGHT', FriendsFrameBattlenetFrame, 'BOTTOMRIGHT')
	BattlenetFrame:Size(FriendsFrameBattlenetFrame:GetSize())
	BattlenetFrame:SetTemplate()
	BattlenetFrame:SetBackdropColor(bnetColor.r, bnetColor.g, bnetColor.b, bnetColor.a)
	BattlenetFrame:SetBackdropBorderColor(unpack(E.media.bordercolor))

	BattlenetFrame:SetScript('OnClick', function() FriendsFrameBattlenetFrame.BroadcastFrame:ToggleFrame() end)
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

	local editBoxBorders = {
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

	local broadcastEdit = FriendsFrameBattlenetFrame.BroadcastFrame.EditBox
	for _, name in next, editBoxBorders do
		local region = broadcastEdit[name]
		if region then region:Hide() end
	end

	S:HandleEditBox(broadcastEdit)

	S:HandleEditBox(_G.AddFriendNameEditBox)
	_G.AddFriendFrame:SetTemplate('Transparent')

	local INVITE_RESTRICTION_NONE = 9
	hooksecurefunc('FriendsFrame_UpdateFriendButton', function(button)
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
	end)

	hooksecurefunc('FriendsFrame_UpdateFriendInviteButton', function(button)
		if not button.IsSkinned then
			S:HandleButton(button.AcceptButton)
			S:HandleButton(button.DeclineButton)

			button.IsSkinned = true
		end
	end)

	hooksecurefunc('FriendsFrame_UpdateFriendInviteHeaderButton', function(button)
		if not button.IsSkinned then
			button:DisableDrawLayer('BACKGROUND')
			button:CreateBackdrop('Transparent')
			button.backdrop:SetInside(button, 2, 2)
			local hl = button:GetHighlightTexture()
			hl:SetColorTexture(.24, .56, 1, .2)
			hl:SetInside(button.backdrop)

			button.IsSkinned = true
		end
	end)

	--Who Frame
	_G.WhoFrameListInset:StripTextures()
	_G.WhoFrameListInset.NineSlice:Hide()
	_G.WhoFrameEditBoxInset:StripTextures()
	_G.WhoFrameEditBoxInset.NineSlice:Hide()

	_G.WhoFrameEditBox:CreateBackdrop('Transparent')
	_G.WhoFrameEditBox.backdrop:Point('TOPLEFT', _G.WhoFrameEditBoxInset)
	_G.WhoFrameEditBox.backdrop:Point('BOTTOMRIGHT', _G.WhoFrameEditBoxInset, -1, 1)

	--Increase width of Level column slightly
	WhoFrameColumn_SetWidth(_G.WhoFrameColumnHeader3, 37) --Default is 32
	for i = 1, 17 do
		local level = _G['WhoFrameButton'..i..'Level']
		if level then
			level:Width(level:GetWidth() + 5)
		end
	end

	S:HandleDropDownBox(_G.WhoFrameDropDown, 120)

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
	S:HandleDropDownBox(_G.FriendsFriendsFrameDropDown, 150)
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
	S:HandleIcon(Claiming.NextRewardButton.Icon)
	Claiming.NextRewardButton.CircleMask:Hide()
	Claiming.NextRewardButton.IconBorder:Kill()
	S:HandleButton(Claiming.ClaimOrViewRewardButton)

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
	local Reward = _G.RecruitAFriendRewardsFrame
	Reward:StripTextures()
	Reward:SetTemplate('Transparent')
	S:HandleCloseButton(Reward.CloseButton)

	hooksecurefunc(Reward, 'UpdateRewards', RAFRewards)
	RAFRewards() -- Because it's loaded already. The securehook is for when it updates in game. Thanks for playing.
end

S:AddCallback('FriendsFrame')
