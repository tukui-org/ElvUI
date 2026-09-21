local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local next = next

function S:Blizzard_BarbershopUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.barber) then return end

	local BarberShopFrame = _G.BarberShopFrame
	S:HandleFrame(BarberShopFrame)

	for _, selector in next, BarberShopFrame.Selector do
		S:HandleNextPrevButton(selector.Prev)
		S:HandleNextPrevButton(selector.Next)
	end

	S:HandleButton(_G.BarberShopFrameResetButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(_G.BarberShopFrameCancelButton, nil, nil, nil, true, nil, nil, nil, true)
	S:HandleButton(_G.BarberShopFrameOkayButton, nil, nil, nil, true, nil, nil, nil, true)
end

S:AddCallbackForAddon('Blizzard_BarbershopUI')
