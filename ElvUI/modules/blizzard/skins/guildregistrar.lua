local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales
if C["skin"].enable ~= true or C["skin"].guildregistrar ~= true then return end

local function LoadSkin()
	GuildRegistrarFrame:StripTextures(true)
	GuildRegistrarFrame:SetTemplate("Transparent")
	GuildRegistrarGreetingFrame:StripTextures()
	E.SkinButton(GuildRegistrarFrameGoodbyeButton)
	E.SkinButton(GuildRegistrarFrameCancelButton)
	E.SkinButton(GuildRegistrarFramePurchaseButton)
	E.SkinCloseButton(GuildRegistrarFrameCloseButton)
	E.SkinEditBox(GuildRegistrarFrameEditBox)
	for i=1, GuildRegistrarFrameEditBox:GetNumRegions() do
		local region = select(i, GuildRegistrarFrameEditBox:GetRegions())
		if region:GetObjectType() == "Texture" then
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

tinsert(E.SkinFuncs["ElvUI"], LoadSkin)