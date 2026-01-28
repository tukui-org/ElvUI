local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function SkinRewards()
	local pool = _G.AdventureMapQuestChoiceDialog.rewardPool
	if not pool or not pool.EnumerateActive then return end

	for reward in pool:EnumerateActive() do
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

	-- Quest Choice
	local AdventureMapQuestChoiceDialog = _G.AdventureMapQuestChoiceDialog
	AdventureMapQuestChoiceDialog:StripTextures()
	AdventureMapQuestChoiceDialog:CreateBackdrop('Transparent')
	AdventureMapQuestChoiceDialog.backdrop:ClearAllPoints()
	AdventureMapQuestChoiceDialog.backdrop:Point('TOPLEFT', 0, -13)
	AdventureMapQuestChoiceDialog.backdrop:Point('BOTTOMRIGHT', 0, -3)
	AdventureMapQuestChoiceDialog.Portrait:SetDrawLayer('OVERLAY', 3)

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
