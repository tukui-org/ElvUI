local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local select = select

function S:GuildRegistrarFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.guildregistrar) then return end

	local GuildRegistrarFrame = _G.GuildRegistrarFrame
	S:HandlePortraitFrame(GuildRegistrarFrame)

	_G.GuildRegistrarFrameEditBox:StripTextures()
	_G.GuildRegistrarGreetingFrame:StripTextures()
	S:HandleButton(_G.GuildRegistrarFrameGoodbyeButton)
	S:HandleButton(_G.GuildRegistrarFrameCancelButton)
	S:HandleButton(_G.GuildRegistrarFramePurchaseButton)
	S:HandleEditBox(_G.GuildRegistrarFrameEditBox)

	for i = 1, _G.GuildRegistrarFrameEditBox:GetNumRegions() do
		local region = select(i, _G.GuildRegistrarFrameEditBox:GetRegions())
		if region and region:IsObjectType('Texture') then
			if region:GetTexture() == [[Interface\ChatFrame\UI-ChatInputBorder-Left]] or region:GetTexture() == [[Interface\ChatFrame\UI-ChatInputBorder-Right]] then
				region:Kill()
			end
		end
	end

	_G.GuildRegistrarFrameEditBox:Height(20)

	for i=1, 2 do
		_G['GuildRegistrarButton'..i]:GetFontString():SetTextColor(1, 1, 1)
	end

	_G.GuildRegistrarPurchaseText:SetTextColor(1, 1, 1)
	_G.AvailableServicesText:SetTextColor(1, 1, 0)
end

S:AddCallback('GuildRegistrarFrame')
