local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local unpack = unpack
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Contribution ~= true then return end

	--Main Frame
	local ContributionCollectionFrame = _G.ContributionCollectionFrame
	S:HandleCloseButton(ContributionCollectionFrame.CloseButton)
	ContributionCollectionFrame.CloseButton.CloseButtonBackground:SetAlpha(0)

	if E.private.skins.blizzard.tooltip then
		--Reward Tooltip
		local ContributionBuffTooltip = _G.ContributionBuffTooltip
		ContributionBuffTooltip:StripTextures()
		ContributionBuffTooltip:SetTemplate("Transparent")
		ContributionBuffTooltip:CreateBackdrop()
		ContributionBuffTooltip:StyleButton()
		ContributionBuffTooltip.Border:SetAlpha(0)
		ContributionBuffTooltip.Icon:SetTexCoord(unpack(E.TexCoords))
		ContributionBuffTooltip.backdrop:SetOutside(ContributionBuffTooltip.Icon)
	end

	local ContributionMixin = _G.ContributionMixin
	hooksecurefunc(ContributionMixin, "SetupContributeButton", function(self)
		-- Skin the Contribute Buttons
		if (not self.isSkinned) then
			S:HandleButton(self.ContributeButton)
			self.isSkinned = true
		end

		-- Skin the StatusBar
		local statusBar = self.Status
		if statusBar and not statusBar.isSkinned then
			statusBar:StripTextures()
			E:RegisterStatusBar(statusBar)
			statusBar:CreateBackdrop()
			statusBar.isSkinned = true
		end
	end)

	--Skin the reward icons
	hooksecurefunc(ContributionMixin, "AddReward", function(self, _, rewardID)
		local reward = self:FindOrAcquireReward(rewardID);
		if (reward and not reward.isSkinned) then
			reward:SetFrameLevel(5)
			reward:CreateBackdrop()
			reward:StyleButton()
			reward.Border:SetAlpha(0)
			reward.Icon:SetDrawLayer("OVERLAY")
			reward.Icon:SetTexCoord(unpack(E.TexCoords))
			reward.backdrop:SetOutside(reward.Icon)
			reward.isSkinned = true
		end
	end)
end

S:AddCallbackForAddon("Blizzard_Contribution", "Contribution", LoadSkin)
