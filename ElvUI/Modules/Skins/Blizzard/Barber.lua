local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.barber ~= true then return end

	_G.BarberShopFrameOkayButton:Point("RIGHT", _G.BarberShopFrameSelector4, "BOTTOM", 2, -50)

	S:HandleButton(_G.BarberShopFrameOkayButton)
	S:HandleButton(_G.BarberShopFrameCancelButton)
	S:HandleButton(_G.BarberShopFrameResetButton)

	local BarberShopFrame = _G.BarberShopFrame
	for i = 1, #BarberShopFrame.Selector do
		local selector = BarberShopFrame.Selector[i]
		local previousSelector = BarberShopFrame.Selector[i-1]

		if selector then
			selector:StripTextures()
			S:HandleNextPrevButton(selector.Prev)
			S:HandleNextPrevButton(selector.Next)

			if i ~= 1 then
				selector:ClearAllPoints()
				selector:Point("TOP", previousSelector, "BOTTOM", 0, -3)
			end
		end
	end

	_G.BarberShopFrameResetButton:ClearAllPoints()
	_G.BarberShopFrameResetButton:Point("BOTTOM", 0, 12)

	BarberShopFrame:StripTextures()
	BarberShopFrame:SetTemplate("Transparent")
	BarberShopFrame:Size(BarberShopFrame:GetWidth() - 30, BarberShopFrame:GetHeight() - 56)

	_G.BarberShopFrameMoneyFrame:StripTextures()
	_G.BarberShopFrameMoneyFrame:CreateBackdrop()

	_G.BarberShopBannerFrameBGTexture:Kill()
	_G.BarberShopBannerFrame:Kill()

	_G.BarberShopBannerFrameCaption:ClearAllPoints()
	_G.BarberShopBannerFrameCaption:Point("TOP", BarberShopFrame, 0, 0)
	_G.BarberShopBannerFrameCaption:SetParent(BarberShopFrame)

	_G.BarberShopAltFormFrameBorder:StripTextures()
	_G.BarberShopAltFormFrame:Point( "BOTTOM", BarberShopFrame, "TOP", 0, 5 )
	_G.BarberShopAltFormFrame:StripTextures()
	_G.BarberShopAltFormFrame:CreateBackdrop("Transparent")
end

S:AddCallbackForAddon("Blizzard_BarbershopUI", "Barbershop", LoadSkin)
