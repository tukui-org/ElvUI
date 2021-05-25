local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_FlightMap()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.taxi) then return end

	local FlightMapFrame = _G.FlightMapFrame
	_G.FlightMapFramePortrait:Kill()
	FlightMapFrame:StripTextures()
	FlightMapFrame:SetTemplate('Transparent')
	S:HandleCloseButton(_G.FlightMapFrameCloseButton)
end

S:AddCallbackForAddon('Blizzard_FlightMap')
