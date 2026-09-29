local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

local data = S:AddCallbackForAddon('Blizzard_AdventureMap')
data.toggle = 'adventureMap'

local function SkinRewards(frame)
	for reward in frame.rewardPool:EnumerateActive() do
		if not reward.IsSkinned then
			S:HandleItemButton(reward)
			S:HandleIcon(reward.Icon)
			reward.Icon:SetDrawLayer('OVERLAY')
			reward.IsSkinned = true
		end
	end
end

function S:Blizzard_AdventureMap()
	-- Quest Choice
	local AdventureMapQuestChoiceDialog = _G.AdventureMapQuestChoiceDialog
	AdventureMapQuestChoiceDialog:StripTextures()
	AdventureMapQuestChoiceDialog:CreateBackdrop('Transparent')
	AdventureMapQuestChoiceDialog.backdrop:ClearAllPoints()
	AdventureMapQuestChoiceDialog.backdrop:Point('TOPLEFT', 0, -13)
	AdventureMapQuestChoiceDialog.backdrop:Point('BOTTOMRIGHT', 0, -3)

	AdventureMapQuestChoiceDialog.Portrait:SetDrawLayer('OVERLAY', 3)
	AdventureMapQuestChoiceDialog.Background:SetAlpha(0)

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
