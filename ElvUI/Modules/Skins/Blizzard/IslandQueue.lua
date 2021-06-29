local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local unpack = unpack

function S:IslandsTooltips()
	local tt = _G.IslandsQueueFrame.WeeklyQuest.QuestReward.Tooltip
	TT:SetStyle(tt)

	local it = tt.ItemTooltip
	if it then
		it.Icon:SetTexCoord(unpack(E.TexCoords))
		it.IconBorder:Kill()
	end
end

function S:Blizzard_IslandsQueueUI()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.islandQueue) then return end

	local IslandsFrame = _G.IslandsQueueFrame
	S:HandlePortraitFrame(IslandsFrame)

	local selectorFrame = IslandsFrame.DifficultySelectorFrame
	local queueButton = selectorFrame and selectorFrame.QueueButton
	if queueButton  then
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

	if E.private.skins.blizzard.enable and E.private.skins.blizzard.tooltip then
		S:IslandsTooltips()
	end
end

S:AddCallbackForAddon('Blizzard_IslandsQueueUI')
