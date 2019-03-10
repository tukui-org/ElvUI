local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local pairs, select, unpack = pairs, select, unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local BNFeaturesEnabled = BNFeaturesEnabled
local FriendsFrameBroadcastInput_UpdateDisplay = FriendsFrameBroadcastInput_UpdateDisplay
local FriendsFrame_CheckBattlenetStatus = FriendsFrame_CheckBattlenetStatus
local WhoFrameColumn_SetWidth = WhoFrameColumn_SetWidth
local RaiseFrameLevel = RaiseFrameLevel
local BNConnected = BNConnected

--Tab Regions
local tabs = {
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"Left",
	"Middle",
	"Right",
}

local function SkinFriendRequest(frame)
	if frame.isSkinned then return; end
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
	tab.backdrop = CreateFrame("Frame", nil, tab)
	tab.backdrop:SetTemplate()
	tab.backdrop:SetFrameLevel(tab:GetFrameLevel() - 1)
	tab.backdrop:Point("TOPLEFT", 3, -8)
	tab.backdrop:Point("BOTTOMRIGHT", -6, 0)
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.friends ~= true then return end

	S:HandleScrollBar(_G.FriendsFrameFriendsScrollFrameScrollBar, 5)
	S:HandleScrollBar(_G.WhoListScrollFrameScrollBar, 5)
	S:HandleScrollBar(_G.FriendsFriendsScrollFrameScrollBar)

	local StripAllTextures = {
		"ScrollOfResurrectionSelectionFrame",
		"ScrollOfResurrectionSelectionFrameList",
		"FriendsListFrame",
		"FriendsTabHeader",
		"FriendsFrameFriendsScrollFrame",
		"WhoFrameColumnHeader1",
		"WhoFrameColumnHeader2",
		"WhoFrameColumnHeader3",
		"WhoFrameColumnHeader4",
		"AddFriendFrame",
		"AddFriendNoteFrame",
	}

	local KillTextures = {
		"FriendsFrameBroadcastInputLeft",
		"FriendsFrameBroadcastInputRight",
		"FriendsFrameBroadcastInputMiddle",
	}

	local buttons = {
		"FriendsFrameAddFriendButton",
		"FriendsFrameSendMessageButton",
		"WhoFrameWhoButton",
		"WhoFrameAddFriendButton",
		"WhoFrameGroupInviteButton",
		"FriendsFrameIgnorePlayerButton",
		"FriendsFrameUnsquelchButton",
		"AddFriendEntryFrameAcceptButton",
		"AddFriendEntryFrameCancelButton",
		"AddFriendInfoFrameContinueButton",
		"ScrollOfResurrectionSelectionFrameAcceptButton",
		"ScrollOfResurrectionSelectionFrameCancelButton",
	}

	for _, button in pairs(buttons) do
		S:HandleButton(_G[button])
	end

	for _, texture in pairs(KillTextures) do
		_G[texture]:Kill()
	end

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	local mainFrames = {
		"WhoFrame",
		"LFRQueueFrame",
	}

	for _, frame in pairs(mainFrames) do
		_G[frame]:StripTextures()
	end

	local FriendsFrame = _G.FriendsFrame
	S:HandlePortraitFrame(FriendsFrame, true)

	_G.WhoFrameListInset:StripTextures()
	_G.WhoFrameListInset.NineSlice:Hide()
	_G.WhoFrameEditBoxInset:StripTextures()
	_G.WhoFrameEditBoxInset.NineSlice:Hide()

	for i=1, FriendsFrame:GetNumRegions() do
		local region = select(i, FriendsFrame:GetRegions())
		if region:IsObjectType('Texture') then
			region:SetTexture()
			region:SetAlpha(0)
		end
	end

	S:HandleEditBox(_G.FriendsFriendsList)
	S:HandleDropDownBox(_G.FriendsFriendsFrameDropDown, 150)

	_G.FriendsTabHeaderSoRButton:SetTemplate()
	_G.FriendsTabHeaderSoRButton:StyleButton()
	_G.FriendsTabHeaderSoRButtonIcon:SetDrawLayer('OVERLAY')
	_G.FriendsTabHeaderSoRButtonIcon:SetTexCoord(unpack(E.TexCoords))
	_G.FriendsTabHeaderSoRButtonIcon:SetInside()
	_G.FriendsTabHeaderSoRButton:Point('TOPRIGHT', _G.FriendsTabHeader, 'TOPRIGHT', -8, -56)

	local SoRBg = CreateFrame("Frame", nil, _G.FriendsTabHeaderSoRButton)
	SoRBg:Point("TOPLEFT", -1, 1)
	SoRBg:Point("BOTTOMRIGHT", 1, -1)

	_G.FriendsTabHeaderRecruitAFriendButton:SetTemplate()
	_G.FriendsTabHeaderRecruitAFriendButton:StyleButton()
	_G.FriendsTabHeaderRecruitAFriendButtonIcon:SetDrawLayer("OVERLAY")
	_G.FriendsTabHeaderRecruitAFriendButtonIcon:SetTexCoord(unpack(E.TexCoords))
	_G.FriendsTabHeaderRecruitAFriendButtonIcon:SetInside()

	S:HandleScrollBar(_G.FriendsFrameIgnoreScrollFrameScrollBar, 4)
	S:HandleDropDownBox(_G.FriendsFrameStatusDropDown, 70)

	_G.FriendsFrameStatusDropDown:ClearAllPoints()
	_G.FriendsFrameStatusDropDown:Point("TOPLEFT", FriendsFrame, "TOPLEFT", -6, -28)

	local FriendsFrameBattlenetFrame = _G.FriendsFrameBattlenetFrame
	FriendsFrameBattlenetFrame:StripTextures()
	FriendsFrameBattlenetFrame:GetRegions():Hide()

	FriendsFrameBattlenetFrame.UnavailableInfoFrame:Point("TOPLEFT", FriendsFrame, "TOPRIGHT", 1, -18)

	FriendsFrameBattlenetFrame.Tag:SetParent(_G.FriendsListFrame)
	FriendsFrameBattlenetFrame.Tag:Point("TOP", FriendsFrame, "TOP", 0, -8)

	_G.FriendsFrameBroadcastInput:CreateBackdrop()
	_G.FriendsFrameBroadcastInput:Width(250)

	hooksecurefunc("FriendsFrame_CheckBattlenetStatus", function()
		if BNFeaturesEnabled() then
			local frame = FriendsFrameBattlenetFrame

			frame.BroadcastButton:Hide()

			if BNConnected() then
				frame:Hide()
				_G.FriendsFrameBroadcastInput:Show()
				FriendsFrameBroadcastInput_UpdateDisplay()
			end
		end
	end)
	FriendsFrame_CheckBattlenetStatus()

	hooksecurefunc("FriendsFrame_Update", function()
		if FriendsFrame.selectedTab == 1 and _G.FriendsTabHeader.selectedTab == 1 and FriendsFrameBattlenetFrame.Tag:IsShown() then
			_G.FriendsFrameTitleText:Hide()
		else
			_G.FriendsFrameTitleText:Show()
		end
	end)

	S:HandleEditBox(_G.AddFriendNameEditBox)
	_G.AddFriendFrame:SetTemplate("Transparent")
	_G.ScrollOfResurrectionSelectionFrame:SetTemplate('Transparent')
	_G.ScrollOfResurrectionSelectionFrameList:SetTemplate()
	S:HandleScrollBar(_G.ScrollOfResurrectionSelectionFrameListScrollFrameScrollBar, 4)
	S:HandleEditBox(_G.ScrollOfResurrectionSelectionFrameTargetEditBox)
	RaiseFrameLevel(_G.ScrollOfResurrectionSelectionFrameTargetEditBox)

	--Pending invites
	S:HandleButton(_G.FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton)
	hooksecurefunc(_G.FriendsFrameFriendsScrollFrame.invitePool, "Acquire", function()
		for object in pairs(_G.FriendsFrameFriendsScrollFrame.invitePool.activeObjects) do
			SkinFriendRequest(object)
		end
	end)

	--Who Frame
	_G.WhoFrame:HookScript("OnShow", UpdateWhoSkins)
	hooksecurefunc("FriendsFrame_OnEvent", UpdateWhoSkins)

	--Increase width of Level column slightly
	WhoFrameColumn_SetWidth(_G.WhoFrameColumnHeader3, 37) --Default is 32
	for i = 1, 17 do
		local level = _G["WhoFrameButton"..i.."Level"]
		if level then
			level:Width(level:GetWidth() + 5)
		end
	end

	S:HandleDropDownBox(_G.WhoFrameDropDown,150)

	--Bottom Tabs
	for i = 1, 4 do
		S:HandleTab(_G["FriendsFrameTab"..i])
	end

	for i=1, 3 do
		SkinSocialHeaderTab(_G["FriendsTabHeaderTab"..i])
	end

	--View Friends BN Frame
	_G.FriendsFriendsFrame:CreateBackdrop("Transparent")

	StripAllTextures = {
		"FriendsFriendsFrame",
		"FriendsFriendsList",
	}

	buttons = {
		"FriendsFriendsSendRequestButton",
		"FriendsFriendsCloseButton",
	}

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	for _, button in pairs(buttons) do
		S:HandleButton(_G[button])
	end

	_G.IgnoreListFrame:StripTextures()
	_G.ScrollOfResurrectionFrame:StripTextures()
	S:HandleButton(_G.ScrollOfResurrectionFrameAcceptButton)
	S:HandleButton(_G.ScrollOfResurrectionFrameCancelButton)

	_G.ScrollOfResurrectionFrameTargetEditBoxLeft:SetTexture()
	_G.ScrollOfResurrectionFrameTargetEditBoxMiddle:SetTexture()
	_G.ScrollOfResurrectionFrameTargetEditBoxRight:SetTexture()
	_G.ScrollOfResurrectionFrameNoteFrame:StripTextures()
	_G.ScrollOfResurrectionFrameNoteFrame:SetTemplate()
	_G.ScrollOfResurrectionFrameTargetEditBox:SetTemplate()
	_G.ScrollOfResurrectionFrame:SetTemplate('Transparent')

	_G.RecruitAFriendFrame:StripTextures()
	_G.RecruitAFriendFrame:SetTemplate("Transparent")
	_G.RecruitAFriendFrame.MoreDetails.Text:FontTemplate()
	S:HandleCloseButton(_G.RecruitAFriendFrameCloseButton)
	S:HandleButton(_G.RecruitAFriendFrameSendButton)
	S:HandleEditBox(_G.RecruitAFriendNameEditBox)
	_G.RecruitAFriendNoteFrame:StripTextures()
	S:HandleEditBox(_G.RecruitAFriendNoteFrame)

	_G.RecruitAFriendSentFrame:StripTextures()
	_G.RecruitAFriendSentFrame:SetTemplate("Transparent")
	S:HandleCloseButton(_G.RecruitAFriendSentFrameCloseButton)
	S:HandleButton(_G.RecruitAFriendSentFrame.OKButton)
	hooksecurefunc("RecruitAFriend_Send", function()
		_G.RecruitAFriendSentFrame:ClearAllPoints()
		_G.RecruitAFriendSentFrame:Point("CENTER", E.UIParent, "CENTER", 0, 100)
	end)

	--Quick join
	local QuickJoinFrame = _G.QuickJoinFrame
	local QuickJoinRoleSelectionFrame = _G.QuickJoinRoleSelectionFrame
	S:HandleScrollBar(_G.QuickJoinScrollFrameScrollBar, 5)
	S:HandleButton(QuickJoinFrame.JoinQueueButton)
	QuickJoinFrame.JoinQueueButton:Size(131, 21)  --Match button on other tab
	QuickJoinFrame.JoinQueueButton:ClearAllPoints()
	QuickJoinFrame.JoinQueueButton:Point("BOTTOMRIGHT", QuickJoinFrame, "BOTTOMRIGHT", -6, 4)
	_G.QuickJoinScrollFrameTop:SetTexture()
	_G.QuickJoinScrollFrameBottom:SetTexture()
	_G.QuickJoinScrollFrameMiddle:SetTexture()
	QuickJoinRoleSelectionFrame:StripTextures()
	QuickJoinRoleSelectionFrame:SetTemplate("Transparent")
	S:HandleButton(QuickJoinRoleSelectionFrame.AcceptButton)
	S:HandleButton(QuickJoinRoleSelectionFrame.CancelButton)
	S:HandleCloseButton(QuickJoinRoleSelectionFrame.CloseButton)
	S:HandleCheckBox(QuickJoinRoleSelectionFrame.RoleButtonTank.CheckButton)
	S:HandleCheckBox(QuickJoinRoleSelectionFrame.RoleButtonHealer.CheckButton)
	S:HandleCheckBox(QuickJoinRoleSelectionFrame.RoleButtonDPS.CheckButton)

	-- GameIcons
	for i = 1, _G.FRIENDS_TO_DISPLAY do
		local button = _G["FriendsFrameFriendsScrollFrameButton"..i]
		local icon = _G["FriendsFrameFriendsScrollFrameButton"..i.."GameIcon"]

		icon:Size(22, 22)
		icon:SetTexCoord(.15, .85, .15, .85)

		icon:ClearAllPoints()
		icon:Point("RIGHT", button, "RIGHT", -24, 0)
		icon.SetPoint = E.noop
	end

	--Tutorial
	S:HandleCloseButton(_G.FriendsTabHeader.FriendsFrameQuickJoinHelpTip.CloseButton)
end

S:AddCallback("Friends", LoadSkin)
