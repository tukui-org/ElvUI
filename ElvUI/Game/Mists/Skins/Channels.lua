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
	S:HandleFrame(channelFrame, true, nil, -5)
	S:HandleButton(channelFrame.SettingsButton)
	S:HandleButton(channelFrame.NewButton)
	channelFrame.NewButton:PointXY(-1, 4)
	_G.ChannelFrameCloseButton:PointXY(2, 2)

	local rosterScrollFrame = channelFrame.ChannelRoster.ScrollFrame
	local rosterScrollBar = rosterScrollFrame.scrollBar
	S:HandleScrollBar(rosterScrollBar)
	rosterScrollBar:Point('TOPLEFT', rosterScrollFrame, 'TOPRIGHT', 1, -13)
	rosterScrollBar:Point('BOTTOMLEFT', rosterScrollFrame, 'BOTTOMRIGHT', 1, 13)

	local channelList = channelFrame.ChannelList
	S:HandleScrollBar(channelList.ScrollBar)
	channelList.ScrollBar:Point('BOTTOMLEFT', channelList, 'BOTTOMRIGHT', 0, 15)

	local createChannelPopup = _G.CreateChannelPopup
	S:HandleFrame(createChannelPopup, true)
	S:HandleButton(createChannelPopup.OKButton)
	S:HandleButton(createChannelPopup.CancelButton)
	S:HandleEditBox(createChannelPopup.Name)
	S:HandleEditBox(createChannelPopup.Password)
	createChannelPopup.CloseButton:PointXY(2, 2)

	local voiceChatPrompt = _G.VoiceChatPromptActivateChannel
	S:HandleFrame(voiceChatPrompt, true)
	S:HandleButton(voiceChatPrompt.AcceptButton)

	-- Hide the Channel Header Textures
	hooksecurefunc(_G.ChannelButtonHeaderMixin, 'Update', ButtonHeader_Update)
end

S:AddCallbackForAddon('Blizzard_Channels')
