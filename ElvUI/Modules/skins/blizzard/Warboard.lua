local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Warboard ~= true then return end

	local WarboardQuestChoiceFrame = _G["WarboardQuestChoiceFrame"]
	WarboardQuestChoiceFrame:StripTextures()
	WarboardQuestChoiceFrame:CreateBackdrop("Transparent")

	WarboardQuestChoiceFrame.Background:Hide()
	WarboardQuestChoiceFrame.Title:DisableDrawLayer("BACKGROUND")

	for i = 1, 4 do
		local option = WarboardQuestChoiceFrame["Option"..i]
		for x = 1, #option.OptionButtonsContainer.Buttons do
			S:HandleButton(option.OptionButtonsContainer.Buttons[x])
		end
		option.ArtworkBorder:SetAlpha(0)
	end

	local WarboardQuestChoiceDelayed = function(self)
		if not self then return end

		local frame
		for i = 1, 4 do
			frame = self["Option"..i]
			if frame and frame.WidgetContainer then
				S:SkinWidgetContainer(frame.WidgetContainer)
			end
		end
	end

	WarboardQuestChoiceFrame:HookScript("OnShow", function(self)
		E:Delay(.5, WarboardQuestChoiceDelayed, self)
	end)

	-- TODO Hide the "new" CloseButton.Border
	S:HandleCloseButton(WarboardQuestChoiceFrame.CloseButton)
end

S:AddCallbackForAddon("Blizzard_WarboardUI", "Warboard", LoadSkin)
