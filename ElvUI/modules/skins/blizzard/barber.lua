local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.barber ~= true then return end
	local buttons = {
		"BarberShopFrameOkayButton",
		"BarberShopFrameCancelButton",
		"BarberShopFrameResetButton",
	}
	BarberShopFrameOkayButton:Point("RIGHT", BarberShopFrameSelector4, "BOTTOM", 2, -50)

	for i = 1, #buttons do
		_G[buttons[i]]:StripTextures()
		S:HandleButton(_G[buttons[i]])
	end



	for i = 1, 5 do
		local f = _G["BarberShopFrameSelector"..i]
		local f2 = _G["BarberShopFrameSelector"..i-1]
		S:HandleNextPrevButton(_G["BarberShopFrameSelector"..i.."Prev"])
		S:HandleNextPrevButton(_G["BarberShopFrameSelector"..i.."Next"])

		if i ~= 1 then
			--f:ClearAllPoints()
			--f:Point("TOP", f2, "BOTTOM", 0, -3)
		end

		if f then
			f:StripTextures()
		end
	end

	BarberShopFrameSelector5:ClearAllPoints()
	BarberShopFrameSelector5:Point("TOP", 0, -12)

	BarberShopFrameResetButton:ClearAllPoints()
	BarberShopFrameResetButton:Point("BOTTOM", 0, 12)

	BarberShopFrame:StripTextures()
	BarberShopFrame:SetTemplate("Transparent")
	BarberShopFrame:Size(BarberShopFrame:GetWidth() - 30, BarberShopFrame:GetHeight() - 56)

	BarberShopFrameMoneyFrame:StripTextures()
	BarberShopFrameMoneyFrame:CreateBackdrop()
	--BarberShopFrameBackground:Kill()

	BarberShopBannerFrameBGTexture:Kill()
	BarberShopBannerFrame:Kill()
	
	BarberShopBannerFrameCaption:ClearAllPoints()
	BarberShopBannerFrameCaption:SetPoint("TOP", BarberShopFrameMoneyFrame, "BOTTOM", 0, -5)
	BarberShopBannerFrameCaption:SetParent(BarberShopFrame)

	BarberShopAltFormFrameBorder:StripTextures()
	BarberShopAltFormFrame:Point( "BOTTOM", BarberShopFrame, "TOP", 0, 5 )
	BarberShopAltFormFrame:StripTextures()
	BarberShopAltFormFrame:CreateBackdrop("Transparent")
end

S:RegisterSkin("Blizzard_BarbershopUI", LoadSkin)