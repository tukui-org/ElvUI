local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, select, unpack = pairs, select, unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local BNFeaturesEnabled = BNFeaturesEnabled
local RaiseFrameLevel = RaiseFrameLevel
local BNConnected = BNConnected
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: FriendsFrameBroadcastInput_UpdateDisplay, FriendsFrame_CheckBattlenetStatus
-- GLOBALS: WhoFrameColumn_SetWidth, FRIENDS_TO_DISPLAY, MAX_DISPLAY_CHANNEL_BUTTONS

--Tab Regions
local tabs = {
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"Left",
	"Middle",
	"Right",
}

--Social Frame
local function SkinSocialHeaderTab(tab)
	if not tab then return end
	for _, object in pairs(tabs) do
		local tex = _G[tab:GetName()..object]
		tex:SetTexture(nil)
	end
	tab:GetHighlightTexture():SetTexture(nil)
	tab.backdrop = CreateFrame("Frame", nil, tab)
	tab.backdrop:SetTemplate("Default")
	tab.backdrop:SetFrameLevel(tab:GetFrameLevel() - 1)
	tab.backdrop:Point("TOPLEFT", 3, -8)
	tab.backdrop:Point("BOTTOMRIGHT", -6, 0)
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.friends ~= true then return end

	S:HandleScrollBar(FriendsFrameFriendsScrollFrameScrollBar, 5)
	S:HandleScrollBar(WhoListScrollFrameScrollBar, 5)
	S:HandleScrollBar(FriendsFriendsScrollFrameScrollBar)

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
		"FriendsFrame",
		"WhoFrame",
		"LFRQueueFrame",
	}

	for _, frame in pairs(mainFrames) do
		_G[frame]:StripTextures()
	end

	WhoFrameListInset:StripTextures()
	WhoFrameListInset.NineSlice:Hide()
	WhoFrameEditBoxInset:StripTextures()
	WhoFrameEditBoxInset.NineSlice:Hide()

	for i=1, FriendsFrame:GetNumRegions() do
		local region = select(i, FriendsFrame:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
			region:SetAlpha(0)
		end
	end

	FriendsFrame:SetTemplate('Transparent')

	S:HandleEditBox(FriendsFriendsList)
	S:HandleDropDownBox(FriendsFriendsFrameDropDown,150)

	FriendsTabHeaderSoRButton:SetTemplate('Default')
	FriendsTabHeaderSoRButton:StyleButton()
	FriendsTabHeaderSoRButtonIcon:SetDrawLayer('OVERLAY')
	FriendsTabHeaderSoRButtonIcon:SetTexCoord(unpack(E.TexCoords))
	FriendsTabHeaderSoRButtonIcon:SetInside()
	FriendsTabHeaderSoRButton:Point('TOPRIGHT', FriendsTabHeader, 'TOPRIGHT', -8, -56)

	local SoRBg = CreateFrame("Frame", nil, FriendsTabHeaderSoRButton)
	SoRBg:Point("TOPLEFT", -1, 1)
	SoRBg:Point("BOTTOMRIGHT", 1, -1)

	FriendsTabHeaderRecruitAFriendButton:SetTemplate("Default")
	FriendsTabHeaderRecruitAFriendButton:StyleButton()
	FriendsTabHeaderRecruitAFriendButtonIcon:SetDrawLayer("OVERLAY")
	FriendsTabHeaderRecruitAFriendButtonIcon:SetTexCoord(unpack(E.TexCoords))
	FriendsTabHeaderRecruitAFriendButtonIcon:SetInside()

	S:HandleScrollBar(FriendsFrameIgnoreScrollFrameScrollBar, 4)
	S:HandleDropDownBox(FriendsFrameStatusDropDown, 70)

	FriendsFrameStatusDropDown:ClearAllPoints()
	FriendsFrameStatusDropDown:Point("TOPLEFT", FriendsFrame, "TOPLEFT", -13, -28)

	FriendsFrameBattlenetFrame:StripTextures()
	FriendsFrameBattlenetFrame:GetRegions():Hide()

	FriendsFrameBattlenetFrame.UnavailableInfoFrame:Point("TOPLEFT", FriendsFrame, "TOPRIGHT", 1, -18)

	FriendsFrameBattlenetFrame.Tag:SetParent(FriendsListFrame)
	FriendsFrameBattlenetFrame.Tag:Point("TOP", FriendsFrame, "TOP", 0, -8)

	FriendsFrameBroadcastInput:CreateBackdrop("Default")
	FriendsFrameBroadcastInput:SetWidth(259)

	hooksecurefunc("FriendsFrame_CheckBattlenetStatus", function()
		if BNFeaturesEnabled() then
			local frame = FriendsFrameBattlenetFrame

			frame.BroadcastButton:Hide()

			if BNConnected() then
				frame:Hide()
				FriendsFrameBroadcastInput:Show()
				FriendsFrameBroadcastInput_UpdateDisplay()
			end
		end
	end)
	FriendsFrame_CheckBattlenetStatus()

	hooksecurefunc("FriendsFrame_Update", function()
		if FriendsFrame.selectedTab == 1 and FriendsTabHeader.selectedTab == 1 and FriendsFrameBattlenetFrame.Tag:IsShown() then
			FriendsFrameTitleText:Hide()
		else
			FriendsFrameTitleText:Show()
		end
	end)

	S:HandleEditBox(AddFriendNameEditBox)
	AddFriendFrame:SetTemplate("Transparent")
	ScrollOfResurrectionSelectionFrame:SetTemplate('Transparent')
	ScrollOfResurrectionSelectionFrameList:SetTemplate('Default')
	S:HandleScrollBar(ScrollOfResurrectionSelectionFrameListScrollFrameScrollBar, 4)
	S:HandleEditBox(ScrollOfResurrectionSelectionFrameTargetEditBox)
	RaiseFrameLevel(ScrollOfResurrectionSelectionFrameTargetEditBox)

	--Pending invites
	S:HandleButton(FriendsFrameFriendsScrollFrame.PendingInvitesHeaderButton)
	local function SkinFriendRequest(frame)
		if frame.isSkinned then return; end
		S:HandleButton(frame.DeclineButton, nil, true)
		S:HandleButton(frame.AcceptButton)
		frame.isSkinned = true
	end
	hooksecurefunc(FriendsFrameFriendsScrollFrame.invitePool, "Acquire", function()
		for object in pairs(FriendsFrameFriendsScrollFrame.invitePool.activeObjects) do
			SkinFriendRequest(object)
		end
	end)

	--Who Frame
	local function UpdateWhoSkins()
		WhoListScrollFrame:StripTextures()
	end

	WhoFrame:HookScript("OnShow", UpdateWhoSkins)
	hooksecurefunc("FriendsFrame_OnEvent", UpdateWhoSkins)

	--Increase width of Level column slightly
	WhoFrameColumn_SetWidth(WhoFrameColumnHeader3, 37) --Default is 32
	for i = 1, 17 do
		local level = _G["WhoFrameButton"..i.."Level"]
		if level then
			level:SetWidth(level:GetWidth() + 5)
		end
	end

	S:HandleCloseButton(FriendsFrameCloseButton,FriendsFrame.backdrop)
	S:HandleDropDownBox(WhoFrameDropDown,150)

	--Bottom Tabs
	for i = 1, 4 do
		S:HandleTab(_G["FriendsFrameTab"..i])
	end

	for i=1, 3 do
		SkinSocialHeaderTab(_G["FriendsTabHeaderTab"..i])
	end

	--View Friends BN Frame
	FriendsFriendsFrame:CreateBackdrop("Transparent")

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

	IgnoreListFrame:StripTextures()

	ScrollOfResurrectionFrame:StripTextures()
	S:HandleButton(ScrollOfResurrectionFrameAcceptButton)
	S:HandleButton(ScrollOfResurrectionFrameCancelButton)

	ScrollOfResurrectionFrameTargetEditBoxLeft:SetTexture(nil)
	ScrollOfResurrectionFrameTargetEditBoxMiddle:SetTexture(nil)
	ScrollOfResurrectionFrameTargetEditBoxRight:SetTexture(nil)
	ScrollOfResurrectionFrameNoteFrame:StripTextures()
	ScrollOfResurrectionFrameNoteFrame:SetTemplate()
	ScrollOfResurrectionFrameTargetEditBox:SetTemplate()
	ScrollOfResurrectionFrame:SetTemplate('Transparent')

	RecruitAFriendFrame:StripTextures()
	RecruitAFriendFrame:SetTemplate("Transparent")
	RecruitAFriendFrame.MoreDetails.Text:FontTemplate()
	S:HandleCloseButton(RecruitAFriendFrameCloseButton)
	S:HandleButton(RecruitAFriendFrameSendButton)
	S:HandleEditBox(RecruitAFriendNameEditBox)
	RecruitAFriendNoteFrame:StripTextures()
	S:HandleEditBox(RecruitAFriendNoteFrame)

	RecruitAFriendSentFrame:StripTextures()
	RecruitAFriendSentFrame:SetTemplate("Transparent")
	S:HandleCloseButton(RecruitAFriendSentFrameCloseButton)
	S:HandleButton(RecruitAFriendSentFrame.OKButton)
	hooksecurefunc("RecruitAFriend_Send", function()
		RecruitAFriendSentFrame:ClearAllPoints()
		RecruitAFriendSentFrame:Point("CENTER", E.UIParent, "CENTER", 0, 100)
	end)

	--Quick join
	S:HandleScrollBar(QuickJoinScrollFrameScrollBar, 5)
	S:HandleButton(QuickJoinFrame.JoinQueueButton)
	QuickJoinFrame.JoinQueueButton:SetSize(131, 21)  --Match button on other tab
	QuickJoinFrame.JoinQueueButton:ClearAllPoints()
	QuickJoinFrame.JoinQueueButton:Point("BOTTOMRIGHT", QuickJoinFrame, "BOTTOMRIGHT", -6, 4)
	QuickJoinScrollFrameTop:SetTexture(nil)
	QuickJoinScrollFrameBottom:SetTexture(nil)
	QuickJoinScrollFrameMiddle:SetTexture(nil)
	QuickJoinRoleSelectionFrame:StripTextures()
	QuickJoinRoleSelectionFrame:SetTemplate("Transparent")
	S:HandleButton(QuickJoinRoleSelectionFrame.AcceptButton)
	S:HandleButton(QuickJoinRoleSelectionFrame.CancelButton)
	S:HandleCloseButton(QuickJoinRoleSelectionFrame.CloseButton)
	S:HandleCheckBox(QuickJoinRoleSelectionFrame.RoleButtonTank.CheckButton)
	S:HandleCheckBox(QuickJoinRoleSelectionFrame.RoleButtonHealer.CheckButton)
	S:HandleCheckBox(QuickJoinRoleSelectionFrame.RoleButtonDPS.CheckButton)

	-- GameIcons
	for i = 1, FRIENDS_TO_DISPLAY do
		local button = _G["FriendsFrameFriendsScrollFrameButton"..i]
		local icon = _G["FriendsFrameFriendsScrollFrameButton"..i.."GameIcon"]

		icon:Size(22, 22)
		icon:SetTexCoord(.15, .85, .15, .85)

		icon:ClearAllPoints()
		icon:Point("RIGHT", button, "RIGHT", -24, 0)
		icon.SetPoint = E.noop
	end

	--Tutorial
	S:HandleCloseButton(FriendsTabHeader.FriendsFrameQuickJoinHelpTip.CloseButton)
end

S:AddCallback("Friends", LoadSkin)
