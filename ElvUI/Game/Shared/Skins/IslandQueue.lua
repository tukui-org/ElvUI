local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G

local data = S:AddCallbackForAddon('Blizzard_IslandsQueueUI')
data.toggle = 'islandQueue'

function S:Blizzard_IslandsQueueUI()
	local IslandsFrame = _G.IslandsQueueFrame
	S:HandlePortraitFrame(IslandsFrame)

	local queueButton = IslandsFrame.DifficultySelectorFrame.QueueButton
	S:HandleButton(queueButton)
	queueButton.Flash:Kill()

	local WeeklyQuest = IslandsFrame.WeeklyQuest
	local StatusBar = WeeklyQuest.StatusBar
	WeeklyQuest.OverlayFrame:StripTextures()

	-- StatusBar
	StatusBar:CreateBackdrop()

	--StatusBar Icon
	WeeklyQuest.QuestReward.Icon:SetTexCoords()

	-- Maybe Adjust me
	local TutorialFrame = IslandsFrame.TutorialFrame
	S:HandleButton(TutorialFrame.Leave)
	S:HandleCloseButton(TutorialFrame.CloseButton)
end
