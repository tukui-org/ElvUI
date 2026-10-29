local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')

local _G = _G
local hooksecurefunc = hooksecurefunc

S:AddCallbackForAddon('Blizzard_AdventureMap', nil, nil, nil, nil, nil, 'adventureMap')

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
	local choiceDialog = _G.AdventureMapQuestChoiceDialog
	choiceDialog:StripTextures()
	choiceDialog:CreateBackdrop('Transparent')
	choiceDialog.backdrop:ClearAllPoints()
	choiceDialog.backdrop:Point('TOPLEFT', 0, -13)
	choiceDialog.backdrop:Point('BOTTOMRIGHT', 0, -3)

	choiceDialog.Portrait:SetDrawLayer('OVERLAY', 3)
	choiceDialog.Background:SetAlpha(0)

	hooksecurefunc(choiceDialog, 'RefreshRewards', SkinRewards)

	local choiceDetails = choiceDialog.Details.Child
	choiceDetails.TitleHeader:SetTextColor(1, 1, 0)
	choiceDetails.DescriptionText:SetTextColor(1, 1, 1)
	choiceDetails.ObjectivesHeader:SetTextColor(1, 1, 0)
	choiceDetails.ObjectivesText:SetTextColor(1, 1, 1)

	S:HandleCloseButton(choiceDialog.CloseButton)
	S:HandleTrimScrollBar(choiceDialog.Details.ScrollBar)
	S:HandleButton(choiceDialog.AcceptButton)
	S:HandleButton(choiceDialog.DeclineButton)
end
