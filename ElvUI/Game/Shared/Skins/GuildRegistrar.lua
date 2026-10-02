local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'GuildRegistrarFrame', nil, nil, nil, nil, 'guildregistrar')

function S:GuildRegistrarFrame()
	local GuildRegistrarFrame = _G.GuildRegistrarFrame
	S:HandlePortraitFrame(GuildRegistrarFrame)
	S:HandleTrimScrollBar(GuildRegistrarFrame.ScrollBar)

	_G.GuildRegistrarFrameEditBox:StripTextures()
	_G.GuildRegistrarFrameEditBox:Height(20)

	S:HandleEditBox(_G.GuildRegistrarFrameEditBox)
	S:HandleButton(_G.GuildRegistrarFrameGoodbyeButton)
	S:HandleButton(_G.GuildRegistrarFrameCancelButton)
	S:HandleButton(_G.GuildRegistrarFramePurchaseButton)

	for i = 1, 2 do
		local text = _G['GuildRegistrarButton'..i]:GetFontString()
		text:SetTextColor(1, 1, 1)
	end

	_G.GuildRegistrarPurchaseText:SetTextColor(1, 1, 1)

	local servicesText = E.Modern and _G.AvailableServicesText or _G.GuildAvailableServicesText
	servicesText:SetTextColor(1, 1, 0)
end
