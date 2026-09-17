local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

function S:Blizzard_SwingTimer()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.swingTimer) then return end
end

S:AddCallbackForAddon('Blizzard_SwingTimer')
