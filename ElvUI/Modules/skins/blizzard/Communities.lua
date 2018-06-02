local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Communities ~= true then return end

	local CommunitiesFrame = _G["CommunitiesFrame"]
	CommunitiesFrame:StripTextures()
	CommunitiesFrame.PortraitOverlay.Portrait:Hide()
	CommunitiesFrame.PortraitOverlay.PortraitFrame:Hide()
	CommunitiesFrame.CommunitiesList.InsetFrame:StripTextures()
	CommunitiesFrame.TopBorder:Hide()
	CommunitiesFrame.LeftBorder:Hide()
	CommunitiesFrame.TopLeftCorner:Hide()

	CommunitiesFrame:CreateBackdrop("Transparent")

	CommunitiesFrameTopTileStreaks:Hide()
	--CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide() -- Maybe we should keep this
	CommunitiesFrameCommunitiesListListScrollFrame:StripTextures()
	CommunitiesFrameInsetBg:Hide()
	CommunitiesFrameInsetInsetBottomBorder:Hide()
	CommunitiesFrameInsetInsetBotLeftCorner:Hide()
	CommunitiesFrameInsetInsetBotRightCorner:Hide()
	CommunitiesFrameInsetInsetRightBorder:Hide()
	CommunitiesFrameInsetInsetLeftBorder:Hide()
	CommunitiesFrameInsetInsetTopBorder:Hide()
	CommunitiesFrameInsetInsetTopRightCorner:Hide()
	CommunitiesFrameCommunitiesListInsetBottomBorder:Hide()
	CommunitiesFrameCommunitiesListInsetBotRightCorner:Hide()
	CommunitiesFrameCommunitiesListInsetRightBorder:Hide()
	CommunitiesFrameInsetBottomBorder:Hide()
	CommunitiesFrameInsetLeftBorder:Hide()
	CommunitiesFrameInsetRightBorder:Hide()
	CommunitiesFrameInsetTopRightCorner:Hide()
	CommunitiesFrameInsetTopLeftCorner:Hide()
	CommunitiesFrameInsetTopBorder:Hide()
	CommunitiesFrameInsetBotRightCorner:Hide()
	CommunitiesFrameInsetBotLeftCorner:Hide()

	S:HandleMaxMinFrame(CommunitiesFrame.MaximizeMinimizeFrame)
	S:HandleCloseButton(CommunitiesFrameCloseButton)
	S:HandleButton(CommunitiesFrame.InviteButton)
	S:HandleButton(CommunitiesFrame.AddToChatButton)
	S:HandleButton(CommunitiesFrame.GuildFinderFrame.FindAGuildButton)

	--[[ FIX ME
	S:HandleScrollBar(CommunitiesFrame.Chat.MessageFrame.ScrollBar)
	S:HandleScrollBar(CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar)
	S:HandleScrollBar(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar)
	S:HandleDropDownBox(CommunitiesFrame.StreamDropDownMenu)
	S:HandleDropDownBox(CommunitiesFrame.CommunitiesListDropDownMenu)
	]]

	-- CHAT TAB
	CommunitiesFrame.MemberList:StripTextures()
	CommunitiesFrame.MemberList.InsetFrame:StripTextures()
	CommunitiesFrame.MemberList.InsetFrame:SetTemplate("Transparent")

	CommunitiesFrame.Chat.InsetFrame:StripTextures()
	CommunitiesFrame.Chat.InsetFrame:SetTemplate("Transparent")

	CommunitiesFrame.GuildFinderFrame:StripTextures()
	CommunitiesFrame.GuildFinderFrame.InsetFrame:StripTextures()

	S:HandleEditBox(CommunitiesFrame.ChatEditBox)
	CommunitiesFrame.ChatEditBox:SetSize(120, 20)

	-- ROSTER TAB
	local MemberList = CommunitiesFrame.MemberList
	MemberList.ColumnDisplay:StripTextures()
	MemberList.ColumnDisplay.InsetBorderLeft:Hide()
	MemberList.ColumnDisplay.InsetBorderBottomLeft:Hide()
	MemberList.ColumnDisplay.InsetBorderTopLeft:Hide()
	MemberList.ColumnDisplay.InsetBorderTop:Hide()
	MemberList.ColumnDisplay.Background:Hide()
	MemberList.ColumnDisplay.TopTileStreaks:Hide()

	--[[FIX ME
	S:HandleDropDownBox(CommunitiesFrame.GuildMemberListDropDownMenu)
	]]
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton)
	S:HandleButton(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)

	-- PERKS TAB
	local GuildBenefitsFrame = CommunitiesFrame.GuildBenefitsFrame
	GuildBenefitsFrame.InsetBorderLeft:Hide()
	GuildBenefitsFrame.InsetBorderRight:Hide()
	GuildBenefitsFrame.InsetBorderBottomRight:Hide()
	GuildBenefitsFrame.InsetBorderBottomLeft:Hide()
	GuildBenefitsFrame.InsetBorderTopRight:Hide()
	GuildBenefitsFrame.InsetBorderTopLeft:Hide()

	GuildBenefitsFrame.Perks:StripTextures()
	GuildBenefitsFrame.Perks.TitleText:FontTemplate(nil, 14)

	for i = 1, 5 do
		local button = _G["CommunitiesFrameContainerButton"..i]
		button:DisableDrawLayer("BACKGROUND")
		button:DisableDrawLayer("BORDER")
		button:CreateBackdrop("Default")

		button.Icon:SetTexCoord(unpack(E.TexCoords))
	end

	GuildBenefitsFrame.Rewards.TitleText:FontTemplate(nil, 14)

	GuildBenefitsFrame.Rewards.Bg:Hide()

	hooksecurefunc("CommunitiesGuildRewards_Update", function(self)
		local scrollFrame = self.RewardsContainer
		local offset = HybridScrollFrame_GetOffset(scrollFrame)
		local buttons = scrollFrame.buttons
		local button, index
		local numButtons = #buttons
		local numRewards = GetNumGuildRewards()

		for i = 1, numButtons do
			button = buttons[i]
			index = offset + i
			button:CreateBackdrop("Default")

			button:SetNormalTexture("")
			button:SetHighlightTexture("")

			button.Icon:SetTexCoord(unpack(E.TexCoords))

			button:SetScript("OnEnter", S.SetModifiedBackdrop)
			button:SetScript("OnLeave", S.SetOriginalBackdrop)

			button.index = index
		end
		local totalHeight = numRewards * (COMMUNITIES_GUILD_REWARDS_BUTTON_HEIGHT + COMMUNITIES_GUILD_REWARDS_BUTTON_OFFSET)
		local displayedHeight = numButtons * (COMMUNITIES_GUILD_REWARDS_BUTTON_HEIGHT + COMMUNITIES_GUILD_REWARDS_BUTTON_OFFSET)
		HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)
	end)
end

S:AddCallbackForAddon("Blizzard_Communities", "Communities", LoadSkin)