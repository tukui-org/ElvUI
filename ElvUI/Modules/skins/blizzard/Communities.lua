local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions

--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Communities ~= true then return end

	CommunitiesFrame:StripTextures()
	CommunitiesFrame.PortraitOverlay.Portrait:Hide()
	CommunitiesFrame.PortraitOverlay.PortraitFrame:Hide()
	CommunitiesFrame.CommunitiesList.InsetFrame:StripTextures()
	CommunitiesFrame.MemberList:StripTextures()
	CommunitiesFrame.MemberList.InsetFrame:StripTextures()
	CommunitiesFrame.MemberList.InsetFrame:SetTemplate("Transparent")
	CommunitiesFrame.MemberList.ColumnDisplay.InsetBorderLeft:Hide()
	CommunitiesFrame.MemberList.ColumnDisplay.InsetBorderBottomLeft:Hide()
	CommunitiesFrame.MemberList.ColumnDisplay.InsetBorderTopLeft:Hide()
	CommunitiesFrame.MemberList.ColumnDisplay.InsetBorderTop:Hide()
	CommunitiesFrame.MemberList.ColumnDisplay.Background:Hide()
	CommunitiesFrame.MemberList.ColumnDisplay.TopTileStreaks:Hide()
	CommunitiesFrameTopTileStreaks:Hide()
	--CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide() -- Maybe we should keep this
	CommunitiesFrameInsetBg:Hide()
	CommunitiesFrameInsetInsetBottomBorder:Hide()
	CommunitiesFrameInsetInsetBotLeftCorner:Hide()
	CommunitiesFrameInsetInsetBotRightCorner:Hide()
	CommunitiesFrameInsetInsetRightBorder:Hide()
	CommunitiesFrameInsetInsetTopBorder:Hide()
	CommunitiesFrameInsetInsetTopRightCorner:Hide()
	CommunitiesFrameCommunitiesListInsetBottomBorder:Hide()
	CommunitiesFrameInsetBottomBorder:Hide()
	CommunitiesFrameInsetLeftBorder:Hide()
	CommunitiesFrameInsetRightBorder:Hide()
	CommunitiesFrameInsetTopRightCorner:Hide()
	CommunitiesFrameInsetTopLeftCorner:Hide()
	CommunitiesFrameInsetTopBorder:Hide()
	CommunitiesFrameInsetBotRightCorner:Hide()
	CommunitiesFrameInsetBotLeftCorner:Hide()

	CommunitiesFrame.Chat.InsetFrame:StripTextures()
	CommunitiesFrame.Chat.InsetFrame:SetTemplate("Transparent")

	CommunitiesFrame.GuildFinderFrame:StripTextures()
	CommunitiesFrame.GuildFinderFrame.InsetFrame:StripTextures()
	CommunitiesFrame.TopBorder:Hide()
	CommunitiesFrame.LeftBorder:Hide()
	CommunitiesFrame.TopLeftCorner:Hide()

	CommunitiesFrame:CreateBackdrop("Transparent")

	--[[ FIX ME
	S:HandleScrollBar(CommunitiesFrame.Chat.MessageFrame.ScrollBar)
	S:HandleScrollBar(CommunitiesFrame.MemberListListScrollFrame.scrollBar)
	S:HandleScrollBar(CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar)
	S:HandleEditBox(CommunitiesFrame.ChatEditBox)
	S:HandleDropDownBox(CommunitiesFrame.StreamDropDownMenu)
	]]

	S:HandleMaxMinFrame(CommunitiesFrame.MaximizeMinimizeFrame)
	S:HandleCloseButton(CommunitiesFrameCloseButton)
	S:HandleButton(CommunitiesFrame.InviteButton)
	S:HandleButton(CommunitiesFrame.AddToChatButton)
	S:HandleButton(CommunitiesFrame.GuildFinderFrame.FindAGuildButton)
end

S:AddCallbackForAddon("Blizzard_Communities", "Communities", LoadSkin)