local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

function S:GuildRegistrarFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.guildregistrar) then return end

	local GuildRegistrarFrame = _G.GuildRegistrarFrame
	local pageBG = GuildRegistrarFrame.Bg:GetAtlas()
	S:HandlePortraitFrame(GuildRegistrarFrame)

	S:HandleTrimScrollBar(GuildRegistrarFrame.ScrollBar)

	_G.GuildRegistrarFrameEditBox:StripTextures()
	_G.GuildRegistrarGreetingFrame:StripTextures()
	S:HandleButton(_G.GuildRegistrarFrameGoodbyeButton)
	S:HandleButton(_G.GuildRegistrarFrameCancelButton)
	S:HandleButton(_G.GuildRegistrarFramePurchaseButton)
	S:HandleEditBox(_G.GuildRegistrarFrameEditBox)

	for _, region in next, { _G.GuildRegistrarFrameEditBox:GetRegions() } do
		if region:IsObjectType('Texture') and (region:GetTexture() == [[Interface\ChatFrame\UI-ChatInputBorder-Left]] or region:GetTexture() == [[Interface\ChatFrame\UI-ChatInputBorder-Right]]) then
			region:Kill()
		end
	end

	_G.GuildRegistrarFrameEditBox:Height(20)

	if E.private.skins.parchmentRemoverEnable then
		for i = 1, 2 do
			local text = _G['GuildRegistrarButton'..i]:GetFontString()
			text:SetTextColor(1, 1, 1)
		end

		_G.GuildRegistrarPurchaseText:SetTextColor(1, 1, 1)
		_G.AvailableServicesText:SetTextColor(1, 1, 0)
	else
		GuildRegistrarFrame.Bg:SetAtlas(pageBG)
		GuildRegistrarFrame.Bg:SetDrawLayer('BACKGROUND', 1) -- above the ElvUI backdrop
	end
end

S:AddCallbackForAddon('Blizzard_UIPanels_Game', 'GuildRegistrarFrame')
