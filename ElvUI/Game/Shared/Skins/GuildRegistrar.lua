local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local data = S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'GuildRegistrarFrame')
data.toggle = 'guildregistrar'

function S:GuildRegistrarFrame()
	local GuildRegistrarFrame = _G.GuildRegistrarFrame
	S:HandlePortraitFrame(GuildRegistrarFrame)

	S:HandleTrimScrollBar(GuildRegistrarFrame.ScrollBar)

	_G.GuildRegistrarFrameEditBox:StripTextures()
	S:HandleButton(_G.GuildRegistrarFrameGoodbyeButton)
	S:HandleButton(_G.GuildRegistrarFrameCancelButton)
	S:HandleButton(_G.GuildRegistrarFramePurchaseButton)
	S:HandleEditBox(_G.GuildRegistrarFrameEditBox)

	_G.GuildRegistrarFrameEditBox:Height(20)

	for i = 1, 2 do
		_G['GuildRegistrarButton'..i]:GetFontString():SetTextColor(1, 1, 1)
	end

	_G.GuildRegistrarPurchaseText:SetTextColor(1, 1, 1)

	local servicesText = E.Modern and _G.AvailableServicesText or _G.GuildAvailableServicesText
	servicesText:SetTextColor(1, 1, 0)
end
