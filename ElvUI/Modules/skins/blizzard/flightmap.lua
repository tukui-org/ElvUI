local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.taxi ~= true then return end

	FlightMapFramePortrait:Kill()
	FlightMapFramePortraitFrame:Kill()
	FlightMapFrame:CreateBackdrop("Transparent")
	FlightMapFrame.BorderFrame:StripTextures()

	S:HandleCloseButton(FlightMapFrameCloseButton)
end

S:AddCallbackForAddon('Blizzard_FlightMap', "FlightMap", LoadSkin)