local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

function S:Blizzard_Contribution()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.Contribution) then return end

	--Main Frame
	local ContributionCollectionFrame = _G.ContributionCollectionFrame
	S:HandleCloseButton(ContributionCollectionFrame.CloseButton)
	ContributionCollectionFrame.CloseButton.CloseButtonBackground:SetAlpha(0)

	if E.private.skins.blizzard.tooltip then
		--Reward Tooltip
		local ContributionBuffTooltip = _G.ContributionBuffTooltip
		ContributionBuffTooltip:StripTextures()
		ContributionBuffTooltip:SetTemplate('Transparent')
		ContributionBuffTooltip:CreateBackdrop()
		ContributionBuffTooltip:StyleButton()
		ContributionBuffTooltip.Border:SetAlpha(0)
		ContributionBuffTooltip.Icon:SetTexCoord(unpack(E.TexCoords))
		ContributionBuffTooltip.backdrop:SetOutside(ContributionBuffTooltip.Icon)
	end

	local ContributionMixin = _G.ContributionMixin
	hooksecurefunc(ContributionMixin, 'SetupContributeButton', function(s)
		-- Skin the Contribute Buttons
		if (not s.isSkinned) then
			S:HandleButton(s.ContributeButton)
			s.isSkinned = true
		end

		-- Skin the StatusBar
		local statusBar = s.Status
		if statusBar and not statusBar.isSkinned then
			statusBar:StripTextures()
			E:RegisterStatusBar(statusBar)
			statusBar:CreateBackdrop()
			statusBar.isSkinned = true
		end
	end)

	--Skin the reward icons
	hooksecurefunc(ContributionMixin, 'AddReward', function(s, _, rewardID)
		local reward = s:FindOrAcquireReward(rewardID);
		if (reward and not reward.isSkinned) then
			reward:SetFrameLevel(5)
			reward:CreateBackdrop()
			reward:StyleButton()
			reward.Border:SetAlpha(0)
			reward.Icon:SetDrawLayer('OVERLAY')
			reward.Icon:SetTexCoord(unpack(E.TexCoords))
			reward.backdrop:SetOutside(reward.Icon)
			reward.isSkinned = true
		end
	end)
end

S:AddCallbackForAddon('Blizzard_Contribution')
