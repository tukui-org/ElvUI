local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule('Skins')
local TT = E:GetModule('Tooltip')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

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

	hooksecurefunc(_G.ContributionMixin, 'SetupContributeButton', function(s)
		-- Skin the Contribute Buttons
		if not s.isSkinned then
			S:HandleButton(s.ContributeButton)
			s.isSkinned = true
		end

		-- Skin the StatusBar
		local statusBar = s.Status
		if statusBar and not statusBar.backdrop then
			E:RegisterStatusBar(statusBar)
			statusBar:StripTextures()
			statusBar:CreateBackdrop()
		end
	end)

	-- Skin the reward icons
	hooksecurefunc(_G.ContributionMixin, 'AddReward', function(s, _, rewardID)
		local reward = s:FindOrAcquireReward(rewardID)
		if reward and not reward.backdrop then
			reward:SetFrameLevel(5)
			reward:CreateBackdrop()

			reward.Border:SetAlpha(0)
			reward.Icon:SetTexCoord(unpack(E.TexCoords))
			reward.Icon:SetDrawLayer('ARTWORK', -1)
			reward.backdrop:SetOutside(reward.Icon)
		end
	end)
end

S:AddCallbackForAddon('Blizzard_Contribution')
