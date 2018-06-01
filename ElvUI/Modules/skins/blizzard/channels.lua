local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local pairs, select = pairs, select
--WoW API / Variables
local C_Timer_After = C_Timer.After
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

	ChannelFrameInset:Hide()
	ChannelFrame.LeftInset:Hide()
	ChannelFrame.RightInset:Hide()

	ChannelFrame:CreateBackdrop("Transparent")
	CreateChannelPopup:CreateBackdrop("Transparent")

	S:HandleCloseButton(ChannelFrameCloseButton)
	S:HandleButton(ChannelFrame.NewButton)
	S:HandleButton(ChannelFrame.SettingsButton)

	--BUGFIX: ChannelFrame.ChannelRoster.ScrollFrame.scrollBar
	--Hide current scrollbar
	ChannelFrame.ChannelRoster.ScrollFrame.scrollBar.ScrollBarTop:Hide()
	ChannelFrame.ChannelRoster.ScrollFrame.scrollBar.ScrollBarTop = nil
	ChannelFrame.ChannelRoster.ScrollFrame.scrollBar.ScrollBarBottom:Hide()
	ChannelFrame.ChannelRoster.ScrollFrame.scrollBar.ScrollBarBottom = nil
	ChannelFrame.ChannelRoster.ScrollFrame.scrollBar.ScrollBarMiddle:Hide()
	ChannelFrameScrollUpButton:Hide()
	ChannelFrameScrollUpButton = nil
	ChannelFrameScrollDownButton:Hide()
	ChannelFrameScrollDownButton = nil
	select(2, ChannelFrame.ChannelRoster.ScrollFrame:GetChildren()):Hide()

	--Create new one with fixed template
	ChannelFrame.ChannelRoster.ScrollFrame.scrollBar = CreateFrame("Slider", nil, ChannelFrame.ChannelRoster.ScrollFrame, "HybridScrollBarTemplateFixed")
	S:HandleScrollBar(ChannelFrame.ChannelRoster.ScrollFrame.scrollBar)
	ChannelFrame.ChannelRoster.ScrollFrame.scrollBar:SetFrameLevel(ChannelFrame.ChannelRoster.ScrollFrame.scrollBar.trackbg:GetFrameLevel()) --Fix issue with background intercepting clicks
	C_Timer_After(0.25, function()
		--Scroll back to top
		ChannelFrame.ChannelRoster.ScrollFrame.scrollBar:SetValue(1)
		ChannelFrame.ChannelRoster.ScrollFrame.scrollBar:SetValue(0)
	end)

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