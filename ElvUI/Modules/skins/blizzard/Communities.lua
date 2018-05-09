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
	CommunitiesFrameCommunitiesList.InsetFrame:StripTextures()
	--CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide() -- Maybe we should keep this
	CommunitiesFrameInsetInsetBottomBorder:Hide()
	CommunitiesFrameInsetInsetBotLeftCorner:Hide()
	CommunitiesFrameCommunitiesListInsetBottomBorder:Hide()
	CommunitiesFrameInsetBottomBorder:Hide()

	CommunitiesFrame:CreateBackdrop("Transparent")

	--[[ FIX ME
	S:HandleScrollBar(CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar)
	S:HandleScrollBar(CommunitiesFrame.Chat.MessageFrame.ScrollBar)
	S:HandleScrollBar(CommunitiesFrame.MemberListListScrollFrame.scrollBar)

	S:HandleEditBox(CommunitiesFrame.ChatEditBox)
	]]

	S:HandleMaxMinFrame(CommunitiesFrame.MaximizeMinimizeFrame)
	S:HandleCloseButton(CommunitiesFrameCloseButton)
	S:HandleButton(CommunitiesFrame.InviteButton)
	S:HandleButton(CommunitiesFrame.AddToChatButton)
end

S:AddCallbackForAddon("Blizzard_Communities", "Communities", LoadSkin)