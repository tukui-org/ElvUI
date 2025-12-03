local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:TaxiFrame()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.taxi) then return end

	S:HandleFrame(_G.TaxiFrame)
end

S:AddCallback('TaxiFrame')
