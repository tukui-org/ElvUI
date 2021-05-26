local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc

function S:Blizzard_Contribution()
	if not (E.private.skins.blizzard.enable and E.private.skins.blizzard.contribution) then return end

	--Main Frame
	local ContributionCollectionFrame = _G.ContributionCollectionFrame
	S:HandleCloseButton(ContributionCollectionFrame.CloseButton)
	ContributionCollectionFrame.CloseButton.CloseButtonBackground:SetAlpha(0)

	if E.private.skins.blizzard.tooltip then
		--Reward Tooltip
		local ContributionBuffTooltip = _G.ContributionBuffTooltip
		ContributionBuffTooltip:StripTextures()
		ContributionBuffTooltip:SetTemplate('Transparent')
		ContributionBuffTooltip:StyleButton()
		ContributionBuffTooltip.Border:SetAlpha(0)
		ContributionBuffTooltip.Icon:SetTexCoord(unpack(E.TexCoords))
	end

	local ContributionMixin = _G.ContributionMixin
	hooksecurefunc(ContributionMixin, 'SetupContributeButton', function(s)
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

	--Skin the reward icons
	hooksecurefunc(ContributionMixin, 'AddReward', function(s, _, rewardID)
		local reward = s:FindOrAcquireReward(rewardID)
		if reward and not reward.isSkinned then
			reward:SetFrameLevel(5)
			reward:SetTemplate()
			reward:StyleButton()
			reward.Border:SetAlpha(0)
			reward.Icon:SetDrawLayer('OVERLAY')
			reward.Icon:SetTexCoord(unpack(E.TexCoords))
			reward.isSkinned = true
		end
	end)
end

S:AddCallbackForAddon('Blizzard_Contribution')
