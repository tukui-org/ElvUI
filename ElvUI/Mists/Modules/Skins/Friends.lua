local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack, pairs = unpack, pairs

local BNConnected = BNConnected
local BNFeaturesEnabled = BNFeaturesEnabled
local GetQuestDifficultyColor = GetQuestDifficultyColor
local hooksecurefunc = hooksecurefunc

local C_FriendList_GetNumWhoResults = C_FriendList.GetNumWhoResults
local C_FriendList_GetWhoInfo = C_FriendList.GetWhoInfo
local GetCVarBool = C_CVar.GetCVarBool

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
		for object in pairs(pool.activeObjects) do
			SkinFriendRequest(object)
		end
	end
end

local function UpdateWhoList()
	local numWhos = C_FriendList_GetNumWhoResults()
	if numWhos == 0 then return end

	if numWhos > _G.WHOS_TO_DISPLAY then
		numWhos = _G.WHOS_TO_DISPLAY
	end

	local playerZone = E.MapInfo.realZoneText
	for i = 1, numWhos do
		local button = _G['WhoFrameButton'..i]
		if button and button.whoIndex then
			local info = C_FriendList_GetWhoInfo(button.whoIndex)
			if info.filename then
				local classTextColor = E:ClassColor(info.filename)
				_G['WhoFrameButton'..i..'Name']:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)

				button.icon:Show()
				button.icon:SetTexCoord(E:GetClassCoords(info.filename))
			else
				local classTextColor = _G.HIGHLIGHT_FONT_COLOR
				_G['WhoFrameButton'..i..'Name']:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b)

				button.icon:Hide()
			end

			local levelTextColor = GetQuestDifficultyColor(info.level)
			_G['WhoFrameButton'..i..'Level']:SetTextColor(levelTextColor.r, levelTextColor.g, levelTextColor.b)
			_G['WhoFrameButton'..i..'Class']:SetTextColor(1, 1, 1)

			if info.area == playerZone then
				_G['WhoFrameButton'..i..'Variable']:SetTextColor(0, 1, 0)
			else
				_G['WhoFrameButton'..i..'Variable']:SetTextColor(1, 1, 1)
			end
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

function S:FriendsFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.friends) then return end

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

		_G[button..'SummonButtonIcon']:SetTexCoord(unpack(E.TexCoords))
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

	-- Who Frame
	_G.WhoFrameListInset:StripTextures()
	_G.WhoFrameEditBoxInset:StripTextures()
	_G.WhoListScrollFrame:StripTextures()

	for i = 1, 4 do
		local header = _G['WhoFrameColumnHeader'..i]
		header:StripTextures()
		header:StyleButton()
		header:ClearAllPoints()
	end

	_G.WhoFrameColumnHeader1:Point('LEFT', _G.WhoFrameColumnHeader4, 'RIGHT', -2, 0)
	_G.WhoFrameColumn_SetWidth(_G.WhoFrameColumnHeader1, 105)
	_G.WhoFrameColumnHeader2:Point('LEFT', _G.WhoFrameColumnHeader1, 'RIGHT', -5, 0)
	_G.WhoFrameColumnHeader3:Point('TOPLEFT', _G.WhoFrame, 'TOPLEFT', 8, -57)
	_G.WhoFrameColumnHeader4:Point('LEFT', _G.WhoFrameColumnHeader3, 'RIGHT', -2, 0)
	_G.WhoFrameColumn_SetWidth(_G.WhoFrameColumnHeader4, 50)

	_G.WhoFrameButton1:Point('TOPLEFT', 10, -82)

	S:HandleEditBox(_G.WhoFrameEditBox)
	_G.WhoFrameEditBox:Point('BOTTOM', -3, 29)
	_G.WhoFrameEditBox:Size(332, 18)

	S:HandleButton(_G.WhoFrameWhoButton)
	_G.WhoFrameWhoButton:Point('RIGHT', _G.WhoFrameAddFriendButton, 'LEFT', -2, 0)
	_G.WhoFrameWhoButton:Width(90)

	S:HandleButton(_G.WhoFrameAddFriendButton)
	_G.WhoFrameAddFriendButton:Point('RIGHT', _G.WhoFrameGroupInviteButton, 'LEFT', -2, 0)

	S:HandleButton(_G.WhoFrameGroupInviteButton)
	_G.WhoFrameGroupInviteButton:Point('BOTTOMRIGHT', -6, 4)

	S:HandleDropDownBox(_G.WhoFrameDropdown)
	_G.WhoFrameDropdown:Point('TOPLEFT', -6, 4)

	S:HandleScrollBar(_G.WhoListScrollFrameScrollBar, 3)
	_G.WhoListScrollFrameScrollBar:ClearAllPoints()
	_G.WhoListScrollFrameScrollBar:Point('TOPRIGHT', _G.WhoListScrollFrame, 'TOPRIGHT', 26, -13)
	_G.WhoListScrollFrameScrollBar:Point('BOTTOMRIGHT', _G.WhoListScrollFrame, 'BOTTOMRIGHT', 0, 18)

	for i = 1, _G.WHOS_TO_DISPLAY do
		local button = _G['WhoFrameButton'..i]
		local level = _G['WhoFrameButton'..i..'Level']
		local name = _G['WhoFrameButton'..i..'Name']
		local className = _G['WhoFrameButton'..i..'Class']

		button.icon = button:CreateTexture('$parentIcon', 'ARTWORK')
		button.icon:Point('LEFT', 45, 0)
		button.icon:Size(15)
		button.icon:SetTexture([[Interface\WorldStateFrame\Icons-Classes]])
		button.icon:CreateBackdrop(nil, true, nil, nil, nil, nil, nil, button.icon)

		S:HandleButtonHighlight(button)

		level:ClearAllPoints()
		level:SetPoint('TOPLEFT', 11, -1)

		name:SetSize(100, 14)
		name:ClearAllPoints()
		name:SetPoint('LEFT', 85, 0)

		className:Hide()
	end

	hooksecurefunc('WhoList_Update', UpdateWhoList)
end

S:AddCallback('FriendsFrame')
