local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local hooksecurefunc = hooksecurefunc

local function SetupContributeButton(frame)
	if not frame.IsSkinned then
		S:HandleButton(frame.ContributeButton)
		frame.IsSkinned = true
	end

	local statusBar = frame.Status
	if not statusBar.backdrop then
		E:RegisterStatusBar(statusBar)
		statusBar:StripTextures()
		statusBar:CreateBackdrop()
	end
end

local function AddReward(frame, _, rewardID)
	local reward = frame:FindOrAcquireReward(rewardID)
	if not reward.backdrop then
		reward:SetFrameLevel(5)
		reward:CreateBackdrop()

		reward.Border:SetAlpha(0)
		reward.Icon:SetTexCoords()
		reward.Icon:SetDrawLayer('ARTWORK', -1)
		reward.backdrop:SetOutside(reward.Icon)
	end
end

function S:Blizzard_Contribution()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.contribution) then return end

	local MainFrame = _G.ContributionCollectionFrame
	S:HandleCloseButton(MainFrame.CloseButton)
	MainFrame.CloseButton.CloseButtonBackground:SetAlpha(0)

	-- Reward Tooltip
	if E.private.skins.blizzard.tooltip then
		local tt = _G.ContributionBuffTooltip
		S:HandleIcon(tt.Icon, true)
		tt.Border:SetAlpha(0)
		TT:SetStyle(tt)
	end

	hooksecurefunc(_G.ContributionMixin, 'SetupContributeButton', SetupContributeButton)
	hooksecurefunc(_G.ContributionMixin, 'AddReward', AddReward)
end

S:AddCallbackForAddon('Blizzard_Contribution')
