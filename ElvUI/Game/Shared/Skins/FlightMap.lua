local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

S:AddCallbackForAddon('Blizzard_FlightMap', nil, nil, nil, nil, nil, 'taxi')

function S:Blizzard_FlightMap()
	local FlightMapFrame = _G.FlightMapFrame
	_G.FlightMapFramePortrait:Kill()
	FlightMapFrame:StripTextures()
	FlightMapFrame:SetTemplate('Transparent')
	S:HandleCloseButton(_G.FlightMapFrameCloseButton)
end
