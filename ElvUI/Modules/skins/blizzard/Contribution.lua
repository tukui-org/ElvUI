local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
local ipairs = ipairs
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Contribution ~= true then return end

	ContributionCollectionFrame:CreateBackdrop("Transparent")
	S:HandleCloseButton(ContributionCollectionFrame.CloseButton)
	ContributionBuffTooltip:StripTextures()
	ContributionBuffTooltip:SetTemplate("Transparent")
	ContributionTooltip:StripTextures()
	ContributionTooltip:CreateBackdrop("Transparent")

	hooksecurefunc(ContributionMixin, "SetupContributeButton", function(self)
		-- Skin the ContributeButtons
		S:HandleButton(self.ContributeButton)

		-- Skin the StatusBar
		local statusBar = self.Status
		if statusBar and not statusBar.skinned then
			statusBar:StripTextures()
			E:RegisterStatusBar(statusBar)
			statusBar:CreateBackdrop('Default')
			statusBar.skinned = true
		end
	end)
end

S:AddCallbackForAddon("Blizzard_Contribution", "Contribution", LoadSkin)