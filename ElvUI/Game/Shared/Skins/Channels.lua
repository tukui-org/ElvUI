local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon('Blizzard_Channels', nil, nil, nil, nil, nil, 'channels')

local function ButtonHeader_Update(header)
	local r, g, b = unpack(E.media.rgbvaluecolor)
	header.HighlightTexture:SetColorTexture(r, g, b, 0.25)
	header.HighlightTexture:SetInside()
	header.NormalTexture:SetTexture()
	header:SetTemplate()
end

function S:Blizzard_Channels()
	local channelFrame = _G.ChannelFrame
	S:HandlePortraitFrame(channelFrame)
	S:HandleButton(channelFrame.SettingsButton) -- using -4, 4

	if E.Modern then
		S:HandleTrimScrollBar(channelFrame.ChannelRoster.ScrollBar)
	else
		local rosterScrollFrame = channelFrame.ChannelRoster.ScrollFrame
		local rosterScrollBar = rosterScrollFrame.scrollBar
		S:HandleScrollBar(rosterScrollBar)
		rosterScrollBar:Point('TOPLEFT', rosterScrollFrame, 'TOPRIGHT', 1, -13)
		rosterScrollBar:Point('BOTTOMLEFT', rosterScrollFrame, 'BOTTOMRIGHT', 1, 13)
	end

	S:HandleButton(channelFrame.NewButton)
	channelFrame.NewButton:ClearAllPoints()
	channelFrame.NewButton:Point('BOTTOMLEFT', channelFrame, 4, 4) -- make it match settings button

	local channelList = channelFrame.ChannelList
	if E.Modern then
		S:HandleTrimScrollBar(channelList.ScrollBar)
	else
		S:HandleScrollBar(channelList.ScrollBar)
	end

	channelList.ScrollBar:Point('BOTTOMLEFT', channelList, 'BOTTOMRIGHT', 0, 15)

	local createChannelPopup = _G.CreateChannelPopup
	createChannelPopup:StripTextures()
	createChannelPopup:SetTemplate('Transparent')

	if E.Modern then
		createChannelPopup.Header:StripTextures()
	end

	S:HandleCloseButton(createChannelPopup.CloseButton)
	S:HandleButton(createChannelPopup.OKButton)
	S:HandleButton(createChannelPopup.CancelButton)
	S:HandleEditBox(createChannelPopup.Name)
	S:HandleEditBox(createChannelPopup.Password)

	-- the classic close button is 32px instead of 24px, this lines it up with Mainline
	if not E.Modern then
		createChannelPopup.CloseButton:PointXY(2, 2)
	end

	local voiceChatPrompt = _G.VoiceChatPromptActivateChannel
	voiceChatPrompt:StripTextures()
	voiceChatPrompt:SetTemplate('Transparent')
	S:HandleButton(voiceChatPrompt.AcceptButton)
	S:HandleCloseButton(voiceChatPrompt.CloseButton)

	-- Hide the Channel Header Textures
	hooksecurefunc(_G.ChannelButtonHeaderMixin, 'Update', ButtonHeader_Update)
end
