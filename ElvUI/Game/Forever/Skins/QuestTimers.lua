local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

function S:Blizzard_QuestTimer()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.questTimers) then return end
end

S:AddCallbackForAddon('Blizzard_QuestTimer')
