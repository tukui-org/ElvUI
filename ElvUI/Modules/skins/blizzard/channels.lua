local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, select = pairs, select
--WoW API / Variables
local ChannelFrame = _G["ChannelFrame"]
local CreateChannelPopup = _G["CreateChannelPopup"]
--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Channels ~= true then return end

	--Channel Frame
	local frames = {
		"ChannelFrame",
		"CreateChannelPopup",
	}

	for _, frame in pairs(frames) do
		_G[frame]:StripTextures()
	end

	ChannelFrameInset:Hide()
	ChannelFrame.LeftInset:Hide()
	ChannelFrame.RightInset:Hide()

	ChannelFrame:CreateBackdrop("Transparent")
	CreateChannelPopup:CreateBackdrop("Transparent")

	S:HandleCloseButton(ChannelFrameCloseButton)
	S:HandleButton(ChannelFrame.NewButton)
	S:HandleButton(ChannelFrame.SettingsButton)
	--S:HandleScrollBar(ChannelFrame.ChannelRoster.ScrollFrame.scrollBar)

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
		self:CreateBackdrop("Transparent")

		self.NormalTexture:SetTexture("")
		self.HighlightTexture:SetTexture("")

		-- TODO: Adjust the Texture Size
		if self:IsCollapsed() then
			self.Collapsed:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\PlusButton")
		else
			self.Collapsed:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\MinusButton")
		end
	end)
end

S:AddCallbackForAddon("Blizzard_Channels", "Channels", LoadSkin)