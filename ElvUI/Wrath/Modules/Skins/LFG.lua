local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs, select = pairs, select

function S:Blizzard_LookingForGroupUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.lfg) then return end

	-- Needs full Wrath rework
end

S:AddCallbackForAddon('Blizzard_LookingForGroupUI')
