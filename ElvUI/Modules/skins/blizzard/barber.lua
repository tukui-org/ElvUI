local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.barber ~= true then return end


	_G.BarberShopFrameOkayButton:Point("RIGHT", _G.BarberShopFrameSelector4, "BOTTOM", 2, -50)

	local buttons = {
		_G.BarberShopFrameOkayButton,
		_G.BarberShopFrameCancelButton,
		_G.BarberShopFrameResetButton,
	}

	for i = 1, #buttons do
		buttons[i]:StripTextures()
		S:HandleButton(buttons[i])
	end

	local BarberShopFrame = _G.BarberShopFrame
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

	_G.BarberShopFrameResetButton:ClearAllPoints()
	_G.BarberShopFrameResetButton:Point("BOTTOM", 0, 12)

	BarberShopFrame:StripTextures()
	BarberShopFrame:SetTemplate("Transparent")
	BarberShopFrame:Size(BarberShopFrame:GetWidth() - 30, BarberShopFrame:GetHeight() - 56)

	_G.BarberShopFrameMoneyFrame:StripTextures()
	_G.BarberShopFrameMoneyFrame:CreateBackdrop()
	-- BarberShopFrameBackground:Kill()

	_G.BarberShopBannerFrameBGTexture:Kill()
	_G.BarberShopBannerFrame:Kill()

	-- Move it to the top for now
	_G.BarberShopBannerFrameCaption:ClearAllPoints()
	_G.BarberShopBannerFrameCaption:Point("TOP", BarberShopFrame, 0, 0)
	_G.BarberShopBannerFrameCaption:SetParent(BarberShopFrame)

	_G.BarberShopAltFormFrameBorder:StripTextures()
	_G.BarberShopAltFormFrame:Point( "BOTTOM", BarberShopFrame, "TOP", 0, 5 )
	_G.BarberShopAltFormFrame:StripTextures()
	_G.BarberShopAltFormFrame:CreateBackdrop("Transparent")
end

S:AddCallbackForAddon("Blizzard_BarbershopUI", "Barbershop", LoadSkin)
