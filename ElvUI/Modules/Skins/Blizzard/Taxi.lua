local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.taxi ~= true then return end

	local TaxiFrame = _G.TaxiFrame
	TaxiFrame:StripTextures()
	TaxiFrame:CreateBackdrop("Transparent")
	_G.TaxiRouteMap:CreateBackdrop()

	S:HandleCloseButton(TaxiFrame.CloseButton)
end

S:AddCallback("Taxi", LoadSkin)
