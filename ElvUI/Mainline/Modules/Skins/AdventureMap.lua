local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local pairs = pairs
local hooksecurefunc = hooksecurefunc

local function SkinRewards()
	local pool = _G.AdventureMapQuestChoiceDialog.rewardPool
	local objects = pool and pool.activeObjects
	if not objects then return end

	for reward in pairs(objects) do
		if not reward.IsSkinned then
			S:HandleItemButton(reward)
			S:HandleIcon(reward.Icon)
			reward.Icon:SetDrawLayer('OVERLAY')
			reward.IsSkinned = true
		end
	end
end

function S:Blizzard_AdventureMap()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.adventureMap) then return end

	--Quest Choise
	local AdventureMapQuestChoiceDialog = _G.AdventureMapQuestChoiceDialog
	AdventureMapQuestChoiceDialog:StripTextures()
	AdventureMapQuestChoiceDialog:SetTemplate('Transparent')

	-- Rewards
	hooksecurefunc(AdventureMapQuestChoiceDialog, 'RefreshRewards', SkinRewards)

	-- Quick Fix for the Font Color
	AdventureMapQuestChoiceDialog.Details.Child.TitleHeader:SetTextColor(1, 1, 0)
	AdventureMapQuestChoiceDialog.Details.Child.DescriptionText:SetTextColor(1, 1, 1)
	AdventureMapQuestChoiceDialog.Details.Child.ObjectivesHeader:SetTextColor(1, 1, 0)
	AdventureMapQuestChoiceDialog.Details.Child.ObjectivesText:SetTextColor(1, 1, 1)

	--Buttons
	S:HandleCloseButton(AdventureMapQuestChoiceDialog.CloseButton)
	S:HandleTrimScrollBar(AdventureMapQuestChoiceDialog.Details.ScrollBar)
	S:HandleButton(AdventureMapQuestChoiceDialog.AcceptButton)
	S:HandleButton(AdventureMapQuestChoiceDialog.DeclineButton)
end

S:AddCallbackForAddon('Blizzard_AdventureMap')
