local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local function ButtonHeader_Update(header)
	local r, g, b = unpack(E.media.rgbvaluecolor)
	header.HighlightTexture:SetColorTexture(r, g, b, 0.25)
	header.HighlightTexture:SetInside()
	header.NormalTexture:SetTexture()
	header:SetTemplate('Transparent')
end

function S:Blizzard_Channels()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.channels) then return end

	local channelFrame = _G.ChannelFrame
	if channelFrame then
		S:HandlePortraitFrame(channelFrame)
		S:HandleButton(channelFrame.SettingsButton) -- using -4, 4
		S:HandleTrimScrollBar(channelFrame.ChannelRoster.ScrollBar)
		S:HandleButton(channelFrame.NewButton)
		channelFrame.NewButton:ClearAllPoints()
		channelFrame.NewButton:Point('BOTTOMLEFT', channelFrame, 4, 4) -- make it match settings button

		local channelList = channelFrame.ChannelList
		if channelList then
			S:HandleTrimScrollBar(channelList.ScrollBar)
			channelList.ScrollBar:Point('BOTTOMLEFT', channelList, 'BOTTOMRIGHT', 0, 15)
		end
	end

	local createChannelPopup = _G.CreateChannelPopup
	if createChannelPopup then
		createChannelPopup:StripTextures()
		createChannelPopup:SetTemplate('Transparent')
		createChannelPopup.Header:StripTextures()

		S:HandleCloseButton(createChannelPopup.CloseButton)
		S:HandleButton(createChannelPopup.OKButton)
		S:HandleButton(createChannelPopup.CancelButton)
		S:HandleEditBox(createChannelPopup.Name)
		S:HandleEditBox(createChannelPopup.Password)
	end

	local voiceChatPrompt = _G.VoiceChatPromptActivateChannel
	if voiceChatPrompt then
		voiceChatPrompt:StripTextures()
		voiceChatPrompt:SetTemplate('Transparent')
		S:HandleButton(voiceChatPrompt.AcceptButton)
		S:HandleCloseButton(voiceChatPrompt.CloseButton)
	end

	-- Hide the Channel Header Textures
	hooksecurefunc(_G.ChannelButtonHeaderMixin, 'Update', ButtonHeader_Update)
end

S:AddCallbackForAddon('Blizzard_Channels')
