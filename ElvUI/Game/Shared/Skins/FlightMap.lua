local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local data = S:AddCallbackForAddon('Blizzard_FlightMap')
data.toggle = 'taxi'

function S:Blizzard_FlightMap()
	local FlightMapFrame = _G.FlightMapFrame
	_G.FlightMapFramePortrait:Kill()
	FlightMapFrame:StripTextures()
	FlightMapFrame:SetTemplate('Transparent')
	S:HandleCloseButton(_G.FlightMapFrameCloseButton)
end
