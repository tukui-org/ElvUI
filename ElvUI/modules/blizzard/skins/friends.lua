local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].friends ~= true then return end

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
	E.SkinScrollBar(FriendsFrameFriendsScrollFrameScrollBar, 5)
	E.SkinScrollBar(WhoListScrollFrameScrollBar, 5)
	E.SkinScrollBar(ChannelRosterScrollFrameScrollBar, 5)
	local StripAllTextures = {
		"FriendsListFrame",
		"FriendsTabHeader",
		"FriendsFrameFriendsScrollFrame",
		"WhoFrameColumnHeader1",
		"WhoFrameColumnHeader2",
		"WhoFrameColumnHeader3",
		"WhoFrameColumnHeader4",
		"ChannelListScrollFrame",
		"ChannelRoster",
		"FriendsFramePendingButton1",
		"FriendsFramePendingButton2",
		"FriendsFramePendingButton3",
		"FriendsFramePendingButton4",
		"ChannelFrameDaughterFrame",
		"AddFriendFrame",
		"AddFriendNoteFrame",
	}			

	local KillTextures = {
		"FriendsFrameTopLeft",
		"FriendsFrameTopRight",
		"FriendsFrameBottomLeft",
		"FriendsFrameBottomRight",
		"ChannelFrameVerticalBar",
		"FriendsFrameBroadcastInputLeft",
		"FriendsFrameBroadcastInputRight",
		"FriendsFrameBroadcastInputMiddle",
		"ChannelFrameDaughterFrameChannelNameLeft",
		"ChannelFrameDaughterFrameChannelNameRight",
		"ChannelFrameDaughterFrameChannelNameMiddle",
		"ChannelFrameDaughterFrameChannelPasswordLeft",
		"ChannelFrameDaughterFrameChannelPasswordRight",				
		"ChannelFrameDaughterFrameChannelPasswordMiddle",			
	}

	local buttons = {
		"FriendsFrameAddFriendButton",
		"FriendsFrameSendMessageButton",
		"WhoFrameWhoButton",
		"WhoFrameAddFriendButton",
		"WhoFrameGroupInviteButton",
		"ChannelFrameNewButton",
		"FriendsFrameIgnorePlayerButton",
		"FriendsFrameUnsquelchButton",
		"FriendsFramePendingButton1AcceptButton",
		"FriendsFramePendingButton1DeclineButton",
		"FriendsFramePendingButton2AcceptButton",
		"FriendsFramePendingButton2DeclineButton",
		"FriendsFramePendingButton3AcceptButton",
		"FriendsFramePendingButton3DeclineButton",
		"FriendsFramePendingButton4AcceptButton",
		"FriendsFramePendingButton4DeclineButton",
		"ChannelFrameDaughterFrameOkayButton",
		"ChannelFrameDaughterFrameCancelButton",
		"AddFriendEntryFrameAcceptButton",
		"AddFriendEntryFrameCancelButton",
		"AddFriendInfoFrameContinueButton",
	}			

	for _, button in pairs(buttons) do
		E.SkinButton(_G[button])
	end
	--Reposition buttons
	WhoFrameWhoButton:Point("RIGHT", WhoFrameAddFriendButton, "LEFT", -2, 0)
	WhoFrameAddFriendButton:Point("RIGHT", WhoFrameGroupInviteButton, "LEFT", -2, 0)
	WhoFrameGroupInviteButton:Point("BOTTOMRIGHT", WhoFrame, "BOTTOMRIGHT", -44, 82)
	--Resize Buttons
	WhoFrameWhoButton:Size(WhoFrameWhoButton:GetWidth() - 4, WhoFrameWhoButton:GetHeight())
	WhoFrameAddFriendButton:Size(WhoFrameAddFriendButton:GetWidth() - 4, WhoFrameAddFriendButton:GetHeight())
	WhoFrameGroupInviteButton:Size(WhoFrameGroupInviteButton:GetWidth() - 4, WhoFrameGroupInviteButton:GetHeight())
	E.SkinEditBox(WhoFrameEditBox)
	WhoFrameEditBox:Height(WhoFrameEditBox:GetHeight() - 15)
	WhoFrameEditBox:Point("BOTTOM", WhoFrame, "BOTTOM", -10, 108)
	WhoFrameEditBox:Width(WhoFrameEditBox:GetWidth() + 17)
	
	for _, texture in pairs(KillTextures) do
		_G[texture]:Kill()
	end

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end
	FriendsFrame:StripTextures(true)

	E.SkinEditBox(AddFriendNameEditBox)
	AddFriendFrame:SetTemplate("Transparent")			
	
	--Who Frame
	local function UpdateWhoSkins()
		WhoListScrollFrame:StripTextures()
	end
	--Channel Frame
	local function UpdateChannel()
		ChannelRosterScrollFrame:StripTextures()
	end
	--BNet Frame
	FriendsFrameBroadcastInput:CreateBackdrop("Default")
	ChannelFrameDaughterFrameChannelName:CreateBackdrop("Default")
	ChannelFrameDaughterFrameChannelPassword:CreateBackdrop("Default")			

	ChannelFrame:HookScript("OnShow", UpdateChannel)
	hooksecurefunc("FriendsFrame_OnEvent", UpdateChannel)

	WhoFrame:HookScript("OnShow", UpdateWhoSkins)
	hooksecurefunc("FriendsFrame_OnEvent", UpdateWhoSkins)

	ChannelFrameDaughterFrame:CreateBackdrop("Transparent")
	FriendsFrame:CreateBackdrop("Transparent")
	FriendsFrame.backdrop:Point( "TOPLEFT", FriendsFrame, "TOPLEFT", 11,-12)
	FriendsFrame.backdrop:Point( "BOTTOMRIGHT", FriendsFrame, "BOTTOMRIGHT", -35, 76)
	E.SkinCloseButton(ChannelFrameDaughterFrameDetailCloseButton,ChannelFrameDaughterFrame)
	E.SkinCloseButton(FriendsFrameCloseButton,FriendsFrame.backdrop)
	E.SkinDropDownBox(WhoFrameDropDown,150)
	E.SkinDropDownBox(FriendsFrameStatusDropDown,70)

	--Bottom Tabs
	for i=1, 4 do
		E.SkinTab(_G["FriendsFrameTab"..i])
	end

	for i=1, 3 do
		SkinSocialHeaderTab(_G["FriendsTabHeaderTab"..i])
	end

	local function Channel()
		for i=1, MAX_DISPLAY_CHANNEL_BUTTONS do
			local button = _G["ChannelButton"..i]
			if button then
				button:StripTextures()
				button:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
				
				_G["ChannelButton"..i.."Text"]:SetFont(C["media"].font, 12)
			end
		end
	end
	hooksecurefunc("ChannelList_Update", Channel)
	
	--View Friends BN Frame
	FriendsFriendsFrame:CreateBackdrop("Transparent")

	local StripAllTextures = {
		"FriendsFriendsFrame",
		"FriendsFriendsList",
		"FriendsFriendsNoteFrame",
	}

	local buttons = {
		"FriendsFriendsSendRequestButton",
		"FriendsFriendsCloseButton",
	}

	for _, object in pairs(StripAllTextures) do
		_G[object]:StripTextures()
	end

	for _, button in pairs(buttons) do
		E.SkinButton(_G[button])
	end

	E.SkinEditBox(FriendsFriendsList)
	E.SkinEditBox(FriendsFriendsNoteFrame)
	E.SkinDropDownBox(FriendsFriendsFrameDropDown,150)
	
	BNConversationInviteDialog:StripTextures()
	BNConversationInviteDialog:CreateBackdrop('Transparent')
	BNConversationInviteDialogList:StripTextures()
	BNConversationInviteDialogList:SetTemplate('Default')
	E.SkinButton(BNConversationInviteDialogInviteButton)
	E.SkinButton(BNConversationInviteDialogCancelButton)
	
	for i=1, BN_CONVERSATION_INVITE_NUM_DISPLAYED do
		E.SkinCheckBox(_G["BNConversationInviteDialogListFriend"..i].checkButton)
	end
end

tinsert(E.SkinFuncs["ElvUI"], LoadSkin)