local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local pairs, select, unpack = pairs, select, unpack
--WoW API / Variables
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local BNFeaturesEnabled = BNFeaturesEnabled
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

local function BattleNetFrame_OnEnter(button)
	if not button.backdrop then return end
	local bnetColor = _G.FRIENDS_BNET_NAME_COLOR

	button.backdrop:SetBackdropBorderColor(bnetColor.r, bnetColor.g, bnetColor.b)
end

local function BattleNetFrame_OnLeave(button)
	if not button.backdrop then return end

	button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.friends ~= true then return end

	S:HandleScrollBar(_G.FriendsListFrameScrollFrame.scrollBar, 5)
	S:HandleScrollBar(_G.WhoListScrollFrame.scrollBar, 5)

	local StripAllTextures = {
		"FriendsTabHeaderTab1",
		"FriendsTabHeaderTab2",
		"WhoFrameColumnHeader1",
		"WhoFrameColumnHeader2",
		"WhoFrameColumnHeader3",
		"WhoFrameColumnHeader4",
		"AddFriendFrame",
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
	}

	for _, button in pairs(buttons) do
		S:HandleButton(_G[button])
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

	-- Kill the Portrait!
	for i = 1, FriendsFrame:GetNumRegions() do
		local region = select(i, FriendsFrame:GetRegions())
		if region:IsObjectType('Texture') then
			region:SetTexture()
			region:SetAlpha(0)
		end
	end

	_G.IgnoreListFrame:StripTextures()

	S:HandleScrollBar(_G.IgnoreListFrameScrollFrame.scrollBar, 4)
	S:HandleDropDownBox(_G.FriendsFrameStatusDropDown, 70)

	_G.FriendsFrameStatusDropDown:ClearAllPoints()
	_G.FriendsFrameStatusDropDown:SetPoint("TOPLEFT", FriendsFrame, "TOPLEFT", 5, -24)

	local FriendsFrameBattlenetFrame = _G.FriendsFrameBattlenetFrame
	FriendsFrameBattlenetFrame:StripTextures()
	FriendsFrameBattlenetFrame:CreateBackdrop("Transparent")
	FriendsFrameBattlenetFrame.backdrop:SetAllPoints()

	local bnetColor = _G.FRIENDS_BNET_BACKGROUND_COLOR
	local button = CreateFrame("Button", nil, FriendsFrameBattlenetFrame)
	button:SetPoint("TOPLEFT", FriendsFrameBattlenetFrame, "TOPLEFT")
	button:SetPoint("BOTTOMRIGHT", FriendsFrameBattlenetFrame, "BOTTOMRIGHT")
	button:SetSize(FriendsFrameBattlenetFrame:GetSize())
	button:CreateBackdrop()
	button.backdrop:SetBackdropColor(bnetColor.r, bnetColor.g, bnetColor.b, bnetColor.a)
	button.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))

	button:SetScript("OnClick", function() FriendsFrameBattlenetFrame.BroadcastFrame:ToggleFrame() end)
	button:SetScript("OnEnter", BattleNetFrame_OnEnter)
	button:SetScript("OnLeave", BattleNetFrame_OnLeave)

	FriendsFrameBattlenetFrame.BroadcastButton:Kill() -- We use the BattlenetFrame to enter a Status Message

	FriendsFrameBattlenetFrame.UnavailableInfoFrame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", 1, -18)

	FriendsFrameBattlenetFrame.BroadcastFrame:StripTextures()
	FriendsFrameBattlenetFrame.BroadcastFrame:CreateBackdrop("Transparent")
	FriendsFrameBattlenetFrame.BroadcastFrame.EditBox:StripTextures()
	S:HandleEditBox(FriendsFrameBattlenetFrame.BroadcastFrame.EditBox)
	S:HandleButton(FriendsFrameBattlenetFrame.BroadcastFrame.UpdateButton)
	S:HandleButton(FriendsFrameBattlenetFrame.BroadcastFrame.CancelButton)

	S:HandleEditBox(_G.AddFriendNameEditBox)
	_G.AddFriendFrame:SetTemplate("Transparent")

	--Pending invites
	S:HandleButton(_G.FriendsListFrameScrollFrame.PendingInvitesHeaderButton)
	hooksecurefunc(_G.FriendsListFrameScrollFrame.invitePool, "Acquire", function()
		for object in pairs(_G.FriendsListFrameScrollFrame.invitePool.activeObjects) do
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
	local FriendsFriendsFrame = _G.FriendsFriendsFrame
	FriendsFriendsFrame:StripTextures()
	FriendsFriendsFrame.ScrollFrameBorder:Hide()
	FriendsFriendsFrame:CreateBackdrop("Transparent")
	S:HandleDropDownBox(_G.FriendsFriendsFrameDropDown, 150)
	S:HandleButton(FriendsFriendsFrame.SendRequestButton)
	S:HandleButton(FriendsFriendsFrame.CloseButton)
	S:HandleScrollBar(_G.FriendsFriendsScrollFrame.scrollBar)

	--Quick join
	local QuickJoinFrame = _G.QuickJoinFrame
	local QuickJoinRoleSelectionFrame = _G.QuickJoinRoleSelectionFrame
	S:HandleScrollBar(_G.QuickJoinScrollFrame.scrollBar, 5)
	S:HandleButton(_G.QuickJoinFrame.JoinQueueButton)
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
		local button = _G["FriendsListFrameScrollFrameButton"..i]
		local icon = _G["FriendsListFrameScrollFrameButton"..i.."GameIcon"]

		icon:Size(22, 22)
		icon:SetTexCoord(.15, .85, .15, .85)

		icon:ClearAllPoints()
		icon:Point("RIGHT", button, "RIGHT", -24, 0)
		icon.SetPoint = E.noop
	end

	--Tutorial - 8.2.5 must fine the new name
	--S:HandleCloseButton(_G.FriendsTabHeader.FriendsFrameQuickJoinHelpTip.CloseButton)
end

S:AddCallback("Friends", LoadSkin)
