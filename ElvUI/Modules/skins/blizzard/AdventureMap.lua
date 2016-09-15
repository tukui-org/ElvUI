local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions

--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: 

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.AdventureMap ~= true then return end

	--Quest Choise
	AdventureMapQuestChoiceDialog:StripTextures()
	AdventureMapQuestChoiceDialog:CreateBackdrop("Transparent")
	AdventureMapQuestChoiceDialog.backdrop:SetFrameStrata("LOW")

	-- Rewards
	local function SkinRewards()
		for reward in pairs(AdventureMapQuestChoiceDialog.rewardPool.activeObjects) do
			if not reward.isSkinned then
				S:HandleItemButton(reward)
				reward.Icon:SetTexCoord(unpack(E.TexCoords))
				reward.Icon:SetDrawLayer("OVERLAY")
				reward.isSkinned = true
			end
		end
	end
	hooksecurefunc(AdventureMapQuestChoiceDialog, "RefreshRewards", SkinRewards)

	-- Quick Fix for the Font Color
	AdventureMapQuestChoiceDialog.Details.Child.TitleHeader:SetTextColor(1, 1, 0)
	AdventureMapQuestChoiceDialog.Details.Child.DescriptionText:SetTextColor(1, 1, 1)
	AdventureMapQuestChoiceDialog.Details.Child.ObjectivesHeader:SetTextColor(1, 1, 0)
	AdventureMapQuestChoiceDialog.Details.Child.ObjectivesText:SetTextColor(1, 1, 1)

	--Buttons
	S:HandleCloseButton(AdventureMapQuestChoiceDialog.CloseButton)
	S:HandleScrollBar(AdventureMapQuestChoiceDialog.Details.ScrollBar)
	S:HandleButton(AdventureMapQuestChoiceDialog.AcceptButton)
	S:HandleButton(AdventureMapQuestChoiceDialog.DeclineButton)
end

S:AddCallbackForAddon('Blizzard_AdventureMap', "AdventureMap", LoadSkin)
