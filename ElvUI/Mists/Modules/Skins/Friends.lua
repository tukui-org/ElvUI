local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

local BNConnected = BNConnected
local BNFeaturesEnabled = BNFeaturesEnabled
local WhoFrameColumn_SetWidth = WhoFrameColumn_SetWidth
local GetCVarBool = C_CVar.GetCVarBool
local hooksecurefunc = hooksecurefunc

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
	if pool.activeObjects then
		for object in next, pool.activeObjects do
			SkinFriendRequest(object)
		end
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

local StripAllTextures = {
	'WhoFrameColumnHeader1',
	'WhoFrameColumnHeader2',
	'WhoFrameColumnHeader3',
	'WhoFrameColumnHeader4',
}

local ButtonsToHandle = {
	'WhoFrameWhoButton',
	'WhoFrameAddFriendButton',
	'WhoFrameGroupInviteButton',
}

function S:FriendsFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.friends) then return end

	for _, button in next, ButtonsToHandle do
		S:HandleButton(_G[button])
	end

	for _, object in next, StripAllTextures do
		_G[object]:StripTextures()
	end

	-- Friends Frame
	local FriendsFrame = _G.FriendsFrame
	S:HandleFrame(FriendsFrame, true, nil, -5, 0, -2)
	_G.FriendsFrameCloseButton:Point('TOPRIGHT', 0, 2)
	S:HandleDropDownBox(_G.FriendsFrameStatusDropdown, 70)
	_G.FriendsFrameStatusDropdown:PointXY(256, -55)

	for i = 1, #_G.FRIENDSFRAME_SUBFRAMES do
		S:HandleTab(_G['FriendsFrameTab'..i])
	end

	-- Reposition Tabs
	hooksecurefunc('FriendsFrame_UpdateGuildTabVisibility', RepositionTabs)

	if _G.FriendsFrameTab5 then
		_G.FriendsFrameTab5:ClearAllPoints()
		_G.FriendsFrameTab5:Point('TOPLEFT', _G.FriendsFrameTab3, 'TOPRIGHT', -19, 0)
	end

	-- Friends List Frame
	for i = 1, _G.FRIEND_HEADER_TAB_IGNORE do
		local tab = _G['FriendsTabHeaderTab'..i]
		S:HandleFrame(tab, true, nil, 3, -7, -2, -1)

		tab:HookScript('OnEnter', S.SetModifiedBackdrop)
		tab:HookScript('OnLeave', S.SetOriginalBackdrop)
	end

	for i = 1, _G.FRIENDS_FRIENDS_TO_DISPLAY do
		local button = 'FriendsFrameFriendsScrollFrameButton'..i
		local btn = _G[button]

		_G[button..'SummonButtonIcon']:SetTexCoords()
		_G[button..'SummonButtonNormalTexture']:SetAlpha(0)
		_G[button..'SummonButton']:StyleButton()
		btn.highlight:SetTexture(E.Media.Textures.Highlight)
		btn.highlight:SetAlpha(0.3)
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

	hooksecurefunc('FriendsFrame_CheckBattlenetStatus', CheckBattlenetStatus)

	_G.FriendsFrame_CheckBattlenetStatus()

	hooksecurefunc('FriendsFrame_Update', UpdateFriendsFrame)

	S:HandleEditBox(_G.AddFriendNameEditBox)
	_G.AddFriendFrame:SetTemplate('Transparent')

	-- Pending invites
	_G.FriendsFrameFriendsScrollFrame:StripTextures()
	S:HandleButton(_G.FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton, true)

	_G.FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton:SetScript('OnMouseUp', nil)
	_G.FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton:SetScript('OnMouseDown', nil)
	_G.FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton.RightArrow:SetTexture(E.Media.Textures.ArrowUp)
	_G.FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton.RightArrow:SetRotation(S.ArrowRotation['right'])
	_G.FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton.DownArrow:SetTexture(E.Media.Textures.ArrowUp)
	_G.FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton.DownArrow:SetRotation(S.ArrowRotation['down'])
	_G.FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton.RightArrow:SetPoint('LEFT', 11, 0)
	_G.FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton.DownArrow:SetPoint('TOPLEFT', 8, -10)

	hooksecurefunc(_G.FriendsFrameFriendsScrollFrame.invitePool, 'Acquire', AcquireInvitePool)

	S:HandleFrame(_G.FriendsFriendsFrame, true)
	_G.FriendsFriendsList:StripTextures()
	_G.IgnoreListFrame:StripTextures()

	S:HandleButton(_G.FriendsFriendsCloseButton)
	S:HandleButton(_G.FriendsFriendsSendRequestButton)
	S:HandleEditBox(_G.FriendsFriendsList)
	S:HandleScrollBar(_G.FriendsFriendsScrollFrameScrollBar)
	S:HandleDropDownBox(_G.FriendsFriendsFrameDropdown, 150)

	-- Ignore List Frame
	_G.IgnoreListFrame:StripTextures()
	S:HandleButton(_G.FriendsFrameIgnorePlayerButton, true)
	S:HandleButton(_G.FriendsFrameUnsquelchButton, true)
	S:HandleScrollBar(_G.FriendsFrameIgnoreScrollFrameScrollBar)

	--Who Frame
	_G.WhoFrame:StripTextures()
	_G.WhoFrameListInset:StripTextures()
	_G.WhoFrameListInset.NineSlice:Hide()

	S:HandleBlizzardRegions(_G.WhoFrameEditBox)
	_G.WhoFrameEditBox:CreateBackdrop()
	_G.WhoFrameEditBox.backdrop:Point('TOPLEFT', _G.WhoFrameEditBox.Left)
	_G.WhoFrameEditBox.backdrop:Point('BOTTOMRIGHT', _G.WhoFrameEditBox.Right)

	--Increase width of Level column slightly
	WhoFrameColumn_SetWidth(_G.WhoFrameColumnHeader3, 37) -- Default is 32

	for i = 1, 17 do
		local level = _G['WhoFrameButton'..i..'Level']
		if level then
			level:Width(level:GetWidth() + 5)
		end
	end

	S:HandleDropDownBox(_G.WhoFrameDropdown, 90)
end

S:AddCallback('FriendsFrame')
