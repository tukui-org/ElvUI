local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_QuestTimer()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.questTimers) then return end

	S:HandleFrame(_G.QuestTimerFrame, true)
	_G.QuestTimerHeader:Point('TOP', 1, 8)
end

S:AddCallbackForAddon('Blizzard_QuestTimer')
