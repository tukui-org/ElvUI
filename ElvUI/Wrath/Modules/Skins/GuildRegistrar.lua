local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

function S:GuildRegistrarFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.guildregistrar) then return end

	local GuildRegistrarFrame = _G.GuildRegistrarFrame
	S:HandleFrame(GuildRegistrarFrame, true, nil, 12, -17, -28, 65)

	_G.GuildRegistrarFrameEditBox:StripTextures()
	_G.GuildRegistrarGreetingFrame:StripTextures()

	S:HandleCloseButton(_G.GuildRegistrarFrameCloseButton)
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

	for i = 1, 2 do
		_G['GuildRegistrarButton'..i]:GetFontString():SetTextColor(1, 1, 1)
	end

	_G.GuildRegistrarPurchaseText:SetTextColor(1, 1, 1)
	_G.GuildAvailableServicesText:SetTextColor(1, 1, 0)
end

S:AddCallback('GuildRegistrarFrame')
