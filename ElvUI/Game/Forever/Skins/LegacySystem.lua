local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

-- /run ToggleLegacySystemUI()

function S:Blizzard_LegacySystem()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.legacySystem) then return end
end

S:AddCallbackForAddon('Blizzard_LegacySystem')
