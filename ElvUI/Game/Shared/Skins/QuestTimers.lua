local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

S:AddCallbackForAddon('Blizzard_QuestTimer', nil, nil, nil, nil, nil, 'questTimers')

function S:Blizzard_QuestTimer()
	local QuestTimerFrame = _G.QuestTimerFrame
	S:HandleFrame(QuestTimerFrame, true)

	if E.Modern then
		QuestTimerFrame.Header:StripTextures()
	else
		_G.QuestTimerHeader:Point('TOP', 1, 8)
	end
end
