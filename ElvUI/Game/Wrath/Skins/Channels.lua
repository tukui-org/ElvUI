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
		S:HandleFrame(channelFrame, true, nil, -5)
		S:HandleButton(channelFrame.SettingsButton)
		S:HandleButton(channelFrame.NewButton)
		channelFrame.NewButton:PointXY(-1, 4)
		_G.ChannelFrameCloseButton:PointXY(2, 2)
		S:HandleScrollBar(channelFrame.ChannelRoster.ScrollFrame.scrollBar)
		channelFrame.ChannelRoster.ScrollFrame.scrollBar:Point('TOPLEFT', channelFrame.ChannelRoster.ScrollFrame, 'TOPRIGHT', 1, -13)
		channelFrame.ChannelRoster.ScrollFrame.scrollBar:Point('BOTTOMLEFT', channelFrame.ChannelRoster.ScrollFrame, 'BOTTOMRIGHT', 1, 13)

		local channelList = channelFrame.ChannelList
		if channelList then
			S:HandleScrollBar(channelFrame.ChannelList.ScrollBar)
			channelFrame.ChannelList.ScrollBar:Point('BOTTOMLEFT', channelFrame.ChannelList, 'BOTTOMRIGHT', 0, 15)
		end
	end

	local createChannelPopup = _G.CreateChannelPopup
	if createChannelPopup then
		S:HandleFrame(createChannelPopup, true)
		S:HandleButton(createChannelPopup.OKButton)
		S:HandleButton(createChannelPopup.CancelButton)
		S:HandleEditBox(createChannelPopup.Name)
		S:HandleEditBox(createChannelPopup.Password)
		createChannelPopup.CloseButton:PointXY(2, 2)
	end

	local voiceChatPrompt = _G.VoiceChatPromptActivateChannel
	if voiceChatPrompt then
		S:HandleFrame(voiceChatPrompt, true)
		S:HandleButton(voiceChatPrompt.AcceptButton)
		S:HandleCloseButton(voiceChatPrompt.CloseButton, voiceChatPrompt.backrop)
	end

	-- Hide the Channel Header Textures
	hooksecurefunc(_G.ChannelButtonHeaderMixin, 'Update', ButtonHeader_Update)
end

S:AddCallbackForAddon('Blizzard_Channels')
