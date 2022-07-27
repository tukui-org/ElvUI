local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs

function S:Blizzard_BarbershopUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.barber) then return end

	S:HandleFrame(_G.BarberShopFrame)

	_G.BarberShopFrameMoneyFrame:StripTextures()

	local nextPrev = {
		_G.BarberShopFrame.FaceSelector.Prev,
		_G.BarberShopFrame.FaceSelector.Next,
		_G.BarberShopFrame.HairStyleSelector.Prev,
		_G.BarberShopFrame.HairStyleSelector.Next,
		_G.BarberShopFrame.HairColorSelector.Prev,
		_G.BarberShopFrame.HairColorSelector.Next,
		_G.BarberShopFrame.FacialHairSelector.Prev,
		_G.BarberShopFrame.FacialHairSelector.Next,
		_G.BarberShopFrame.SkinColorSelector.Prev,
		_G.BarberShopFrame.SkinColorSelector.Next
	}

	for _, frame in pairs(nextPrev) do
		S:HandleNextPrevButton(frame)
	end

	S:HandleButton(_G.BarberShopFrameResetButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(_G.BarberShopFrameCancelButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(_G.BarberShopFrameOkayButton, nil, nil, nil, true, nil, nil, nil, true)
end
S:AddCallbackForAddon('Blizzard_BarbershopUI')
