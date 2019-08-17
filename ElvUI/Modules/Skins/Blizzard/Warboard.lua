local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

local _G = _G

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Warboard ~= true then return end

	local WarboardQuestChoiceFrame = _G.WarboardQuestChoiceFrame
	WarboardQuestChoiceFrame:StripTextures()
	WarboardQuestChoiceFrame.NineSlice:Hide()
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
		if self.CloseButton.Border then self.CloseButton.Border:SetAlpha(0) end
		E:Delay(0.5, WarboardQuestChoiceDelayed, self)
	end)

	S:HandleCloseButton(WarboardQuestChoiceFrame.CloseButton)
end

S:AddCallbackForAddon("Blizzard_WarboardUI", "Warboard", LoadSkin)
