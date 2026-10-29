local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

S:AddCallbackForAddon('Blizzard_IslandsQueueUI', nil, nil, nil, nil, nil, 'islandQueue')

function S:Blizzard_IslandsQueueUI()
	local islandsFrame = _G.IslandsQueueFrame
	S:HandlePortraitFrame(islandsFrame)

	local queueButton = islandsFrame.DifficultySelectorFrame.QueueButton
	S:HandleButton(queueButton)
	queueButton.Flash:Kill()

	local weeklyQuest = islandsFrame.WeeklyQuest
	weeklyQuest.OverlayFrame:StripTextures()
	weeklyQuest.QuestReward.Icon:SetTexCoords()
	weeklyQuest.StatusBar:CreateBackdrop()

	local tutorialFrame = islandsFrame.TutorialFrame
	S:HandleButton(tutorialFrame.Leave)
	S:HandleCloseButton(tutorialFrame.CloseButton)
end
