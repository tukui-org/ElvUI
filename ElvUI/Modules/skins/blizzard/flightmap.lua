local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.taxi ~= true then return end

	-- According to the new Blizzard_FlightMap, i think it must be hooked
	FlightMapFrame:StripTextures()
	FlightMapFrame.ScrollContainer:StripTextures()
	FlightMapFrame.ScrollContainer:SetFrameLevel(5)
	FlightMapFrame.ScrollContainer:SetFrameStrata("HIGH")
	FlightMapFrameTitleText:SetAlpha(0)
	FlightMapFrameCloseButton:ClearAllPoints()
	FlightMapFrameCloseButton:SetPoint("TOPRIGHT", 0, -20)

	S:HandleCloseButton(FlightMapFrameCloseButton)
end

-- S:RegisterSkin('ElvUI', LoadSkin)