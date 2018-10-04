local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.taxi ~= true then return end

	local TaxiFrame = _G["TaxiFrame"]
	TaxiFrame:StripTextures()
	TaxiFrame:CreateBackdrop("Transparent")
	_G["TaxiRouteMap"]:CreateBackdrop("Default")
	_G["TaxiRouteMap"].backdrop.backdropTexture:Hide()

	S:HandleCloseButton(TaxiFrame.CloseButton)
end

S:AddCallback("Taxi", LoadSkin)
