local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local pairs, select, unpack = pairs, select, unpack

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local WhoFrameColumn_SetWidth = WhoFrameColumn_SetWidth

--Tab Regions
local tabs = {
	'LeftDisabled',
	'MiddleDisabled',
	'RightDisabled',
	'Left',
	'Middle',
	'Right',
}

local function SkinFriendRequest(frame)
	if frame.isSkinned then return end
	S:HandleButton(frame.DeclineButton, nil, true)
	S:HandleButton(frame.AcceptButton)
	frame.isSkinned = true
end

local function UpdateWhoSkins()
	_G.WhoListScrollFrame:StripTextures()
end

--Social Frame
local function SkinSocialHeaderTab(tab)
	if not tab then return end
	for _, object in pairs(tabs) do
		local tex = _G[tab:GetName()..object]
		tex:SetTexture()
	end

	tab:GetHighlightTexture():SetTexture()

	tab.backdrop = CreateFrame('Frame', nil, tab)
	tab.backdrop:SetTemplate()
	tab.backdrop:SetFrameLevel(tab:GetFrameLevel() - 1)
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

function S:FriendsFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.friends) then return end

	S:HandleScrollBar(_G.FriendsListFrameScrollFrame.scrollBar, 5)
	S:HandleScrollBar(_G.WhoListScrollFrame.scrollBar, 5)

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
	_G.WhoFrameListInset:StripTextures()
	_G.WhoFrameListInset.NineSlice:Hide()
	_G.WhoFrameEditBoxInset:StripTextures()
	_G.WhoFrameEditBoxInset.NineSlice:Hide()
	_G.IgnoreListFrame:StripTextures()

	S:HandleScrollBar(_G.IgnoreListFrameScrollFrame.scrollBar, 4)
	S:HandleDropDownBox(_G.FriendsFrameStatusDropDown, 70)

	_G.FriendsFrameStatusDropDown:ClearAllPoints()
	_G.FriendsFrameStatusDropDown:Point('TOPLEFT', FriendsFrame, 'TOPLEFT', 5, -24)

	local FriendsFrameBattlenetFrame = _G.FriendsFrameBattlenetFrame
	FriendsFrameBattlenetFrame:StripTextures()
	FriendsFrameBattlenetFrame:SetTemplate('Transparent')

	local bnetColor = _G.FRIENDS_BNET_BACKGROUND_COLOR
	local button = CreateFrame('Button', nil, FriendsFrameBattlenetFrame)
	button:Point('TOPLEFT', FriendsFrameBattlenetFrame, 'TOPLEFT')
	button:Point('BOTTOMRIGHT', FriendsFrameBattlenetFrame, 'BOTTOMRIGHT')
	button:Size(FriendsFrameBattlenetFrame:GetSize())
	button:SetTemplate()
	button:SetBackdropColor(bnetColor.r, bnetColor.g, bnetColor.b, bnetColor.a)
	button:SetBackdropBorderColor(unpack(E.media.bordercolor))

	button:SetScript('OnClick', function() FriendsFrameBattlenetFrame.BroadcastFrame:ToggleFrame() end)
	button:SetScript('OnEnter', BattleNetFrame_OnEnter)
	button:SetScript('OnLeave', BattleNetFrame_OnLeave)

	FriendsFrameBattlenetFrame.BroadcastButton:Kill() -- We use the BattlenetFrame to enter a Status Message

	FriendsFrameBattlenetFrame.UnavailableInfoFrame:ClearAllPoints()
	FriendsFrameBattlenetFrame.UnavailableInfoFrame:Point('TOPLEFT', FriendsFrame, 'TOPRIGHT', 1, -18)

	FriendsFrameBattlenetFrame.BroadcastFrame:StripTextures()
	FriendsFrameBattlenetFrame.BroadcastFrame:SetTemplate('Transparent')
	FriendsFrameBattlenetFrame.BroadcastFrame.EditBox:StripTextures()
	FriendsFrameBattlenetFrame.BroadcastFrame:ClearAllPoints()
	FriendsFrameBattlenetFrame.BroadcastFrame:Point('TOPLEFT', FriendsFrame, 'TOPRIGHT', 3, -1)
	S:HandleEditBox(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox)
	S:HandleButton(FriendsFrameBattlenetFrame.BroadcastFrame.UpdateButton)
	S:HandleButton(FriendsFrameBattlenetFrame.BroadcastFrame.CancelButton)

	S:HandleEditBox(_G.AddFriendNameEditBox)
	_G.AddFriendFrame:SetTemplate('Transparent')

	--Pending invites
	local PendingHeader = _G.FriendsListFrameScrollFrame.PendingInvitesHeaderButton
	S:HandleButton(PendingHeader)
	if PendingHeader.backdrop then PendingHeader.backdrop:SetInside() end
	hooksecurefunc(_G.FriendsListFrameScrollFrame.invitePool, 'Acquire', function()
		for object in pairs(_G.FriendsListFrameScrollFrame.invitePool.activeObjects) do
			SkinFriendRequest(object)
		end
	end)

	--Who Frame
	_G.WhoFrame:HookScript('OnShow', UpdateWhoSkins)
	hooksecurefunc('FriendsFrame_OnEvent', UpdateWhoSkins)

	--Increase width of Level column slightly
	WhoFrameColumn_SetWidth(_G.WhoFrameColumnHeader3, 37) --Default is 32
	for i = 1, 17 do
		local level = _G['WhoFrameButton'..i..'Level']
		if level then
			level:Width(level:GetWidth() + 5)
		end
	end

	S:HandleDropDownBox(_G.WhoFrameDropDown, 120)

	--Bottom Tabs
	for i = 1, 4 do
		S:HandleTab(_G['FriendsFrameTab'..i])
	end

	for i = 1, 3 do
		SkinSocialHeaderTab(_G['FriendsTabHeaderTab'..i])
	end

	--View Friends BN Frame
	local FriendsFriendsFrame = _G.FriendsFriendsFrame
	FriendsFriendsFrame.ScrollFrameBorder:Hide()
	FriendsFriendsFrame:StripTextures()
	FriendsFriendsFrame:SetTemplate('Transparent')
	S:HandleDropDownBox(_G.FriendsFriendsFrameDropDown, 150)
	S:HandleButton(FriendsFriendsFrame.SendRequestButton)
	S:HandleButton(FriendsFriendsFrame.CloseButton)
	S:HandleScrollBar(_G.FriendsFriendsScrollFrame.scrollBar)

	--Quick join
	local QuickJoinFrame = _G.QuickJoinFrame
	local QuickJoinRoleSelectionFrame = _G.QuickJoinRoleSelectionFrame
	S:HandleScrollBar(_G.QuickJoinScrollFrame.scrollBar, 5)
	S:HandleButton(_G.QuickJoinFrame.JoinQueueButton)
	QuickJoinFrame.JoinQueueButton:Size(131, 21) --Match button on other tab
	QuickJoinFrame.JoinQueueButton:ClearAllPoints()
	QuickJoinFrame.JoinQueueButton:Point('BOTTOMRIGHT', QuickJoinFrame, 'BOTTOMRIGHT', -6, 4)
	_G.QuickJoinScrollFrameTop:SetTexture()
	_G.QuickJoinScrollFrameBottom:SetTexture()
	_G.QuickJoinScrollFrameMiddle:SetTexture()
	QuickJoinRoleSelectionFrame:StripTextures()
	QuickJoinRoleSelectionFrame:SetTemplate('Transparent')
	S:HandleButton(QuickJoinRoleSelectionFrame.AcceptButton)
	S:HandleButton(QuickJoinRoleSelectionFrame.CancelButton)
	S:HandleCloseButton(QuickJoinRoleSelectionFrame.CloseButton)
	S:HandleCheckBox(QuickJoinRoleSelectionFrame.RoleButtonTank.CheckButton)
	S:HandleCheckBox(QuickJoinRoleSelectionFrame.RoleButtonHealer.CheckButton)
	S:HandleCheckBox(QuickJoinRoleSelectionFrame.RoleButtonDPS.CheckButton)

	-- GameIcons
	for i = 1, _G.FRIENDS_TO_DISPLAY do
		local btn = _G['FriendsListFrameScrollFrameButton'..i]
		local icon = _G['FriendsListFrameScrollFrameButton'..i..'GameIcon']

		icon:Size(22, 22)
		icon:SetTexCoord(.15, .85, .15, .85)

		icon:ClearAllPoints()
		icon:Point('RIGHT', btn, 'RIGHT', -24, 0)
		icon.SetPoint = E.noop
	end

	-- RecruitAFriend 8.2.5
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
	S:HandleScrollBar(RecruitList.ScrollFrame.Slider)

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
