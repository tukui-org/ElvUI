local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs = pairs
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Channels ~= true then return end

	local ChannelFrame = _G["ChannelFrame"]
	local CreateChannelPopup = _G["CreateChannelPopup"]

	--Channel Frame
	local frames = {
		"ChannelFrame",
		"CreateChannelPopup",
	}

	for _, frame in pairs(frames) do
		_G[frame]:StripTextures()
	end

	--ChannelFrameInset:Hide()

	ChannelFrame:CreateBackdrop("Transparent")
	CreateChannelPopup:CreateBackdrop("Transparent")

	S:HandleCloseButton(ChannelFrameCloseButton)
	S:HandleButton(ChannelFrame.NewButton)
	S:HandleButton(ChannelFrame.SettingsButton)

	S:HandleScrollSlider(ChannelFrame.ChannelRoster.ScrollFrame.scrollBar)
	ChannelFrame.ChannelRoster.ScrollFrame.scrollBar:SetPoint('TOPLEFT', ChannelFrame.ChannelRoster.ScrollFrame, 'TOPRIGHT', 1, -13)
	ChannelFrame.ChannelRoster.ScrollFrame.scrollBar:SetPoint('BOTTOMLEFT', ChannelFrame.ChannelRoster.ScrollFrame, 'BOTTOMRIGHT', 1, 13)

	S:HandleScrollSlider(ChannelFrame.ChannelList.ScrollBar)
	ChannelFrame.ChannelList.ScrollBar:SetPoint('BOTTOMLEFT', ChannelFrame.ChannelList, 'BOTTOMRIGHT', 0, 15)

	S:HandleCloseButton(CreateChannelPopup.CloseButton)
	S:HandleButton(CreateChannelPopup.OKButton)
	S:HandleButton(CreateChannelPopup.CancelButton)

	S:HandleEditBox(CreateChannelPopup.Name)
	S:HandleEditBox(CreateChannelPopup.Password)

	VoiceChatPromptActivateChannel:StripTextures()
	VoiceChatPromptActivateChannel:CreateBackdrop("Transparent")
	S:HandleButton(VoiceChatPromptActivateChannel.AcceptButton)
	S:HandleCloseButton(VoiceChatPromptActivateChannel.CloseButton)

	-- Hide the Channel Header Textures
	hooksecurefunc(ChannelButtonHeaderMixin, "Update", function(self)
		self:SetTemplate("Transparent")

		self.NormalTexture:SetTexture("")
	end)
end

S:AddCallbackForAddon("Blizzard_Channels", "Channels", LoadSkin)
