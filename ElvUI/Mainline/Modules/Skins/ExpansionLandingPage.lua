local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_ExpansionLandingPage()
	if not (E.private.skins.blizzard.enable) then return end

	local ExpansionLandingPage = _G.ExpansionLandingPage

	--ToDo: WoW10
end

S:AddCallbackForAddon('Blizzard_ExpansionLandingPage')
