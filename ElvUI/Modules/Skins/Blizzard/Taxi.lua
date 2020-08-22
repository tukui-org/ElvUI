local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:TaxiFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.taxi) then return end

	local TaxiFrame = _G.TaxiFrame
	TaxiFrame:StripTextures()
	TaxiFrame:CreateBackdrop('Transparent')
	_G.TaxiRouteMap:CreateBackdrop()

	S:HandleCloseButton(TaxiFrame.CloseButton)
end

S:AddCallback('TaxiFrame')
