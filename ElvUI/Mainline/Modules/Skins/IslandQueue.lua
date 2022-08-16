local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack

function S:Blizzard_IslandsQueueUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.islandQueue) then return end

	local IslandsFrame = _G.IslandsQueueFrame
	S:HandlePortraitFrame(IslandsFrame)

	local selectorFrame = IslandsFrame.DifficultySelectorFrame
	local queueButton = selectorFrame and selectorFrame.QueueButton
	if queueButton then
		S:HandleButton(queueButton)
		queueButton.Flash:Kill()
	end

	local WeeklyQuest = IslandsFrame.WeeklyQuest
	local StatusBar = WeeklyQuest.StatusBar
	WeeklyQuest.OverlayFrame:StripTextures()

	-- StatusBar
	StatusBar:CreateBackdrop()

	--StatusBar Icon
	WeeklyQuest.QuestReward.Icon:SetTexCoord(unpack(E.TexCoords))

	-- Maybe Adjust me
	local TutorialFrame = IslandsFrame.TutorialFrame
	S:HandleButton(TutorialFrame.Leave)
	S:HandleCloseButton(TutorialFrame.CloseButton)
end

S:AddCallbackForAddon('Blizzard_IslandsQueueUI')
