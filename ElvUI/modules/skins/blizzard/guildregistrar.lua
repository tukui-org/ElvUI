local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.guildregistrar ~= true then return end
	GuildRegistrarFrame:StripTextures(true)
	GuildRegistrarFrame:SetTemplate("Transparent")
	GuildRegistrarFrameInset:Kill()
	GuildRegistrarFrameEditBox:StripTextures()
	GuildRegistrarGreetingFrame:StripTextures()
	S:HandleButton(GuildRegistrarFrameGoodbyeButton)
	S:HandleButton(GuildRegistrarFrameCancelButton)
	S:HandleButton(GuildRegistrarFramePurchaseButton)
	S:HandleCloseButton(GuildRegistrarFrameCloseButton)
	S:HandleEditBox(GuildRegistrarFrameEditBox)
	for i=1, GuildRegistrarFrameEditBox:GetNumRegions() do
		local region = select(i, GuildRegistrarFrameEditBox:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			if region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Left" or region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Right" then
				region:Kill()
			end
		end
	end

	GuildRegistrarFrameEditBox:Height(20)

	for i=1, 2 do
		_G["GuildRegistrarButton"..i]:GetFontString():SetTextColor(1, 1, 1)
	end

	GuildRegistrarPurchaseText:SetTextColor(1, 1, 1)
	AvailableServicesText:SetTextColor(1, 1, 0)
end

S:RegisterSkin('ElvUI', LoadSkin)