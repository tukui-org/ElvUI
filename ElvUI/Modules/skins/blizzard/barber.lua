local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G

--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

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

	local BarberShopFrame = _G["BarberShopFrame"]
	for i = 1, #BarberShopFrame.Selector do
		local selector = BarberShopFrame.Selector[i]
		local previousSelector = BarberShopFrame.Selector[i-1]

		if selector then
			selector:StripTextures()

			-- Next-/Prev. Button will be fixed in 7.1 see: http://git.tukui.org/Elv/elvui-beta/issues/5#note_10079
			--S:HandleNextPrevButton(selector.Prev)
			--S:HandleNextPrevButton(selector.Next)

			if i ~= 1 then
				selector:ClearAllPoints()
				selector:Point("TOP", previousSelector, "BOTTOM", 0, -3)
			end
		end
	end

	BarberShopFrameResetButton:ClearAllPoints()
	BarberShopFrameResetButton:Point("BOTTOM", 0, 12)

	BarberShopFrame:StripTextures()
	BarberShopFrame:SetTemplate("Transparent")
	BarberShopFrame:Size(BarberShopFrame:GetWidth() - 30, BarberShopFrame:GetHeight() - 56)

	BarberShopFrameMoneyFrame:StripTextures()
	BarberShopFrameMoneyFrame:CreateBackdrop()
	-- BarberShopFrameBackground:Kill()

	BarberShopBannerFrameBGTexture:Kill()
	BarberShopBannerFrame:Kill()

	-- Move it to the top for now
	BarberShopBannerFrameCaption:ClearAllPoints()
	BarberShopBannerFrameCaption:Point("TOP", BarberShopFrame, 0, 0)
	BarberShopBannerFrameCaption:SetParent(BarberShopFrame)

	BarberShopAltFormFrameBorder:StripTextures()
	BarberShopAltFormFrame:Point( "BOTTOM", BarberShopFrame, "TOP", 0, 5 )
	BarberShopAltFormFrame:StripTextures()
	BarberShopAltFormFrame:CreateBackdrop("Transparent")
end

S:AddCallbackForAddon("Blizzard_BarbershopUI", "Barbershop", LoadSkin)
