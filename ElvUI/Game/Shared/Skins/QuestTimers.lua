local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

function S:Blizzard_QuestTimer()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.questTimers) then return end

	local QuestTimerFrame = _G.QuestTimerFrame
	S:HandleFrame(QuestTimerFrame, true)

	if E.Modern then
		QuestTimerFrame.Header:StripTextures()
	else
		_G.QuestTimerHeader:Point('TOP', 1, 8)
	end
end

S:AddCallbackForAddon('Blizzard_QuestTimer')
