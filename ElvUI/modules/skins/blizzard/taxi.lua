local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.taxi ~= true then return end
	TaxiFrame:StripTextures()
	TaxiFrame:CreateBackdrop("Transparent")
	TaxiRouteMap:CreateBackdrop("Default")
	TaxiRouteMap.backdrop.backdropTexture:Hide()


	S:HandleCloseButton(TaxiFrame.CloseButton)
end

S:RegisterSkin('ElvUI', LoadSkin)