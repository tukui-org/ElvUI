local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local ipairs = ipairs
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Contribution ~= true then return end

	S:HandleCloseButton(ContributionCollectionFrame.CloseButton)
	ContributionCollectionFrame.CloseButton.CloseButtonBackground:SetAlpha(0)
	ContributionBuffTooltip:StripTextures()
	ContributionBuffTooltip:SetTemplate("Transparent")
	ContributionTooltip:StripTextures()
	ContributionTooltip:CreateBackdrop("Transparent")

	hooksecurefunc(ContributionMixin, "SetupContributeButton", function(self)
		if (not self.isSkinned) then
			-- Skin the ContributeButtons
			S:HandleButton(self.ContributeButton)
			self.isSkinned = true
		end

		-- Skin the StatusBar
		local statusBar = self.Status
		if statusBar and not statusBar.isSkinned then
			statusBar:StripTextures()
			E:RegisterStatusBar(statusBar)
			statusBar:CreateBackdrop('Default')
			statusBar.isSkinned = true
		end
	end)
	
	hooksecurefunc(ContributionMixin, "AddReward", function(self, _, rewardID)
		local reward = self:FindOrAcquireReward(rewardID);
		if (reward and not reward.isSkinned) then
			reward:CreateBackdrop("Default", true)
			reward:StyleButton()
			reward.Border:SetAlpha(0)
			reward.Icon:SetTexCoord(unpack(E.TexCoords))
			reward.backdrop:SetOutside(reward.Icon)
			reward.isSkinned = true
		end
	end)
end

S:AddCallbackForAddon("Blizzard_Contribution", "Contribution", LoadSkin)